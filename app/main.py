import re
import json
import gc
import uuid
import asyncio
from fastapi import FastAPI, HTTPException, status
from pydantic import BaseModel
from typing import Dict, Any, Optional

from app.schemas.chat_schema import ChatRequest, ChatResponse, PerfilUpdateItem, ConsolidateRequest, ConsolidateResponse
from app.services.inference_router import InferenceRouter
from app.services.fact_extractor import FactExtractor
from app.services.skill_extractor import SkillExtractor
from app.services.skills_service import skill_router

from arq import create_pool
from arq.connections import RedisSettings

# Configuración de Conexión a Redis para Arq
REDIS_SETTINGS = RedisSettings(host='localhost', port=6379)

app = FastAPI(title="A.G.O.S. / Fénix", description="Stateless Inference Subconscious Server - Event Driven Pipeline")
app.include_router(skill_router, prefix="/api/v1/skills", tags=["Skills"])

class TaskResponse(BaseModel):
    status: str
    task_id: str

class TaskStatusResponse(BaseModel):
    status: str
    result: Optional[ChatResponse] = None

# Dependencia global de Redis Pool
@app.on_event("startup")
async def startup():
    app.state.redis = await create_pool(REDIS_SETTINGS)

# Worker Function que consumirá la cola asíncrona de Redis
async def process_inference_task(ctx, task_id: str, payload: dict):
    """
    Función Worker de Arq.
    Recibe el payload ultra-denso (snake_case) desde la bóveda móvil, encapsulado en la cola de Redis.
    Delega la inferencia al motor local (Ollama CPU) o la Nube (Gemini) a su propio ritmo.
    Guarda el resultado en caché (Redis) y limpia agresivamente la RAM.
    """
    try:
        print(f"[WORKER] Procesando tarea {task_id} para el usuario: {payload.get('user_id', 'Anónimo')}")
        
        router = InferenceRouter()
        result = await router.execute_inferential_cycle(payload)
        
        raw_response = result.get("assistant_response", "")

        user_id = payload.get("user_id", "Anónimo")
        executed_skills, response_temp = await SkillExtractor.extract_and_execute_skills(raw_response, user_id)
        
        # Utilizando el Extractor de Hechos (FactExtractor)
        perfil_updates, sanitized_response = FactExtractor.extract_eav_mutations(response_temp)
        
        response_data = {
            "status": result.get("status", "success"),
            "assistant_response": sanitized_response,
            "perfil_update": perfil_updates,
            "executed_skills": executed_skills,
            "inferenced_by": result.get("inferenced_by", "llama_server_local_x86")
        }
        
        # Almacenamos el resultado en Redis usando la clave task_id (Expira en 1 hora por seguridad Zero-Knowledge)
        redis = await create_pool(REDIS_SETTINGS)
        await redis.setex(f"fenix_task_result:{task_id}", 3600, json.dumps(response_data))
        
        print(f"[WORKER] Tarea {task_id} procesada exitosamente y guardada en caché.")
        return response_data

    except Exception as e:
        print(f"[WORKER ERROR] Tarea {task_id} falló: {str(e)}")
        redis = await create_pool(REDIS_SETTINGS)
        error_data = {"status": "error", "assistant_response": f"Error de inferencia: {str(e)}", "perfil_update": [], "inferenced_by": "SystemError"}
        await redis.setex(f"fenix_task_result:{task_id}", 3600, json.dumps(error_data))
    
    finally:
        # HIGIENE ABSOLUTA DE MEMORIA
        del payload
        gc.collect()

# Definición del Worker de Arq para lanzarse vía CLI
class WorkerSettings:
    functions = [process_inference_task]
    redis_settings = REDIS_SETTINGS
    max_jobs = 2  # Hard-limit estricto para no ahogar la concurrencia de Ollama en el VPS 

@app.post("/api/v1/chat", response_model=TaskResponse, status_code=status.HTTP_202_ACCEPTED)
async def chat_endpoint(request: ChatRequest):
    """
    Endpoint Ingestor No-Bloqueante (Event-Driven).
    Recibe la ráfaga cognitiva efímera del móvil y la encola instantáneamente en Redis.
    """
    try:
        payload = request.model_dump()
        task_id = str(uuid.uuid4())
        
        print(f"[INGEST ORCHESTRATOR] Encolando petición multiusuario para {payload.get('user_id', 'Anónimo')}")
        
        await app.state.redis.enqueue_job('process_inference_task', task_id, payload)
        return TaskResponse(status="queued", task_id=task_id)

    except Exception as e:
        raise HTTPException(status_code=500, detail="Error encolando tarea de inferencia en la matriz de Redis")
    finally:
        del request
        gc.collect()

@app.get("/api/v1/task/{task_id}", response_model=TaskStatusResponse)
async def get_task_status(task_id: str):
    """
    Endpoint de Long-Polling rápido (Alta Frecuencia).
    Comprueba si el Worker de Arq ha finalizado de forma asíncrona.
    """
    try:
        redis = app.state.redis
        result_json = await redis.get(f"fenix_task_result:{task_id}")
        
        if result_json:
            # Result retrieved, process and destroy from memory (Zero-Knowledge)
            data = json.loads(result_json.decode('utf-8'))
            await redis.delete(f"fenix_task_result:{task_id}")
            
            return TaskStatusResponse(
                status="completed",
                result=ChatResponse(**data)
            )
        else:
            # Tarea aún en cola o procesándose por Ollama/Gemini
            return TaskStatusResponse(status="processing", result=None)

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/api/v1/consolidate", response_model=ConsolidateResponse)
async def consolidate_endpoint(request: ConsolidateRequest):
    """
    Endpoint Asíncrono de Consolidación Subconsciente.
    Procesa todo el historial del día con su propio System Prompt para extraer resúmenes y Alertas (JSON regex).
    """
    try:
        router = InferenceRouter()
        
        payload_consolidacion = {
            "capsula_activa": {
                "system_prompt": "Eres un núcleo analítico de memoria. Analiza el historial provisto. Retorna SOLAMENTE un JSON estructurado con: 'resumen_markdown' (string largo), 'nuevos_datos_perfil' (lista de diccionarios con 'categoria', 'clave', 'valor' para perfil EAV SQLite), 'alertas_coach' (string con notas para la salud del usuario). No añadas texto fuera del bloque ```json ... ```.",
                "id": "consolidation_core"
            },
            "perfil_identidad": "",
            "contexto_rag_hibrido": {},
            "historial_reciente": [],
            "mensaje_actual": f"Consolida el siguiente historial de transacciones de hoy:\n\n{request.historial_dia}"
        }
        
        result = await router.execute_inferential_cycle(payload_consolidacion)
        raw_response = result.get("assistant_response", "")
        
        # Aislar el bloque JSON tolerando markdown delimiters
        match = re.search(r'```(?:json)?(.*?)```', raw_response, re.DOTALL)
        if match:
            json_str = match.group(1).strip()
        else:
            json_str = raw_response.strip()
            
        parsed_json = json.loads(json_str)
        # Validar y retornar mediante esquema pydantic
        response_model = ConsolidateResponse(**parsed_json)
        return response_model
        
    except Exception as e:
        print(f"[CONSOLIDATE ERROR] Fallo durante la consolidación: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        del request
        gc.collect()

# =====================================================================
# RUNBOOK TÉCNICO DE DESPLIEGUE EVENT-DRIVEN (A.G.O.S)
# =====================================================================
"""
Hermes Agent: El Ingestion Pipeline ha sido actualizado a Eventos Asíncronos vía Redis.

1. REQUISITOS DEL HOST Y CACHÉ
   $ sudo apt-get install redis-server
   $ sudo systemctl enable redis-server
   $ pip install arq redis

2. DESPLIEGUE DEL INGESTOR (FASTAPI)
   Maneja miles de conexiones entrantes sin ocupar tiempo de CPU.
   $ uvicorn app.main:app --host 0.0.0.0 --port 8000 --workers 4

3. DESPLIEGUE DEL WORKER DE ARQ (MODEL CONSUMER)
   Consume la cola limitándola estrictamente. Ejecutar en terminal adyacente o SystemD.
   $ arq app.main.WorkerSettings
"""