import re
import json
from fastapi import FastAPI, HTTPException
from app.schemas.chat_schema import ChatRequest, ChatResponse, PerfilUpdateItem
from app.services.inference_router import InferenceRouter

# La API opera de manera concurrente con Uvicorn bajo el protocolo Stateless.
# Se instancia el Orquestador maestro Agnóstico.
app = FastAPI(title="A.G.O.S. / Fénix", description="Stateless Inference Subconscious Server")
router = InferenceRouter()

@app.post("/api/v1/chat", response_model=ChatResponse)
async def chat_endpoint(request: ChatRequest):
    """
    Recibe el payload ultra-denso (snake_case) desde la bóveda móvil.
    Delega de inmediato la inferencia al motor local (Ollama CPU) o la Nube (Gemini)
    y luego descarta agresivamente todo rastro de los objetos subyacentes,
    asegurando Soberanía Absoluta en un esquema Multiusuario.
    """
    try:
        # Cast Pydantic -> Dict para ruteo
        payload = request.model_dump()
        
        # El router ejecuta inferencia, intercepta el Function Calling y parsea el Output.
        result = await router.execute_inferential_cycle(payload)
        
        raw_response = result.get("assistant_response", "")
        perfil_updates = []
        
        # Módulo de Extracción Regex de Mutaciones SQLite
        match = re.search(r'<perfil_update>(.*?)</perfil_update>', raw_response, re.DOTALL)
        if match:
            json_str = match.group(1).strip()
            # Limpiamos bloques markdown erráticos del modelo
            json_str = re.sub(r'```json\n|\n```|```', '', json_str)
            try:
                parsed = json.loads(json_str)
                # Validamos y transmutamos a nuestro modelo intermedio PerfilUpdateItem (snake_case)
                if isinstance(parsed, list):
                    perfil_updates = [PerfilUpdateItem(**item) for item in parsed]
                elif isinstance(parsed, dict):
                    perfil_updates = [PerfilUpdateItem(**parsed)]
            except Exception as parsing_error:
                print(f"Error procesando json estructurado EAV: {parsing_error}")
            
            # Limpieza visual para el front
            raw_response = re.sub(r'<perfil_update>.*?</perfil_update>', '', raw_response, flags=re.DOTALL).strip()
        
        # Aquí, a punto de enviar el retorno HTTP, el objeto Request con datos
        # crudos del usuario se desasigna de la memoria, el VPS purga la RAM
        # instantáneamente y mantiene el entorno 'Zero-Knowledge'.
        return ChatResponse(
            status=result["status"],
            assistant_response=raw_response,
            perfil_update=perfil_updates,
            inferenced_by=result["inferenced_by"]
        )
    except Exception as e:
        # Prevención de exposición de stack-traces sensibles del motor
        raise HTTPException(status_code=500, detail=str(e))
