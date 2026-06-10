import pytest
import httpx
from app.services.inference_router import InferenceRouter

@pytest.mark.asyncio
async def test_inference_router_success(respx_mock):
    # Mock de HTTPX para coincidir con la URL de llama-server
    router = InferenceRouter()
    
    mock_response = {
        "choices": [
            {
                "message": {
                    "content": "Respuesta simulada del LLM."
                }
            }
        ]
    }
    
    respx_mock.post(router.llama_url).respond(200, json=mock_response)
    
    payload = {
        "capsula_activa": {"system_prompt": "Eres un asistente analítico."},
        "perfil_identidad": "",
        "contexto_rag_hibrido": {},
        "historial_reciente": [],
        "mensaje_actual": "Hola LLM"
    }
    
    result = await router.execute_inferential_cycle(payload)
    assert result["status"] == "success"
    assert "Respuesta simulada del LLM" in result["assistant_response"]
    assert result["inferenced_by"] == "llama_server_local_x86"

@pytest.mark.asyncio
async def test_inference_router_network_error(respx_mock):
    router = InferenceRouter()
    respx_mock.post(router.llama_url).mock(return_value=httpx.Response(500))
    
    payload = {
        "mensaje_actual": "Peligro"
    }
    
    result = await router.execute_inferential_cycle(payload)
    assert result["status"] == "interrupted"
    assert "perdido temporalmente el enlace" in result["assistant_response"]
    assert result["inferenced_by"] == "system_failure"
