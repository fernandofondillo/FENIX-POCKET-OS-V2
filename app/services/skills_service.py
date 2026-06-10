import time
import logging
from typing import Dict, Any
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from app.services.skill_catalogue import CATALOGUE

logger = logging.getLogger(__name__)

skill_router = APIRouter()

# Implementación de Limitador en Memoria RAM para Rate Limiting
RATE_LIMIT_STORE: Dict[str, list] = {}
RATE_LIMIT_MAX = 10
RATE_LIMIT_WINDOW = 60  # Segundos (10 requests máximas por minuto rotativo)

class SkillExecutionRequest(BaseModel):
    skill_name: str
    args: Dict[str, Any]
    user_id: str

class SkillExecutionResponse(BaseModel):
    success: bool
    result: Dict[str, Any]

def _check_rate_limit(user_id: str) -> bool:
    current_time = time.time()
    if user_id not in RATE_LIMIT_STORE:
        RATE_LIMIT_STORE[user_id] = []
    
    # Prune expirados de la ventana
    RATE_LIMIT_STORE[user_id] = [ts for ts in RATE_LIMIT_STORE[user_id] if current_time - ts <= RATE_LIMIT_WINDOW]
    
    if len(RATE_LIMIT_STORE[user_id]) >= RATE_LIMIT_MAX:
        return False
    
    RATE_LIMIT_STORE[user_id].append(current_time)
    return True

async def execute(skill_name: str, args: dict, user_id: str) -> dict:
    """Ejecutor Agnóstico de Habilidades. Mantiene el acoplamiento Zero-Knowledge al inyectar Pydantic models."""
    logger.info(f"Petición de sub-rutina de habilidad detectada -> {skill_name} | Operador ID: {user_id}")
    
    if not _check_rate_limit(user_id):
        logger.warning(f"Límite anti-colapso accionado para el usuario: {user_id}")
        raise HTTPException(status_code=429, detail="Exceso en el umbral elástico. Máx 10 invocaciones por minuto permitido.")

    if skill_name not in CATALOGUE:
        logger.error(f"Intento de acceso a habilidad inexistente: '{skill_name}'.")
        raise HTTPException(status_code=404, detail="Esa cápsula no contiene habilidades listadas en el registro maestro.")

    skill_def = CATALOGUE[skill_name]
    
    try:
        validated_args = skill_def["schema"](**args)
    except     Exception as e:
        logger.error(f"Rechazo en capa Pydantic para '{skill_name}': {e}")
        raise HTTPException(status_code=400, detail="Contrato JSON violado o parámetros disfuncionales.")
        
    try:
        result = await skill_def["handler"](validated_args)
        logger.info(f"Sub-rutina completada exitosamente.")
        return {"success": True, "result": result}
    except Exception as e:
        logger.critical(f"Segfault virtual o excepción delegada en {skill_name}: {e}")
        raise HTTPException(status_code=500, detail="El bloque asíncrono no finalizó limpiamente en la máquina.")

@skill_router.post("/execute", response_model=SkillExecutionResponse)
async def execute_endpoint(request: SkillExecutionRequest):
    result = await execute(request.skill_name, request.args, request.user_id)
    return SkillExecutionResponse(success=True, result=result)
