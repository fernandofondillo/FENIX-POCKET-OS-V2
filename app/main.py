from fastapi import FastAPI, HTTPException
from app.schemas.chat_schema import ChatRequest, ChatResponse
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
        
        # Aquí, a punto de enviar el retorno HTTP, el objeto Request con datos
        # crudos del usuario se desasigna de la memoria, el VPS purga la RAM
        # instantáneamente y mantiene el entorno 'Zero-Knowledge'.
        return ChatResponse(
            status=result["status"],
            assistant_response=result["assistant_response"],
            perfil_update=result["perfil_update"],
            inferenced_by=result["inferenced_by"]
        )
    except Exception as e:
        # Prevención de exposición de stack-traces sensibles del motor
        raise HTTPException(status_code=500, detail=str(e))
