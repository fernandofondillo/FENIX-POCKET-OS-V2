import os
import logging
import json
from typing import Dict, Any, List
import httpx

# Configuración de Logging Asíncrono
logging.basicConfig(level=logging.INFO, format="%(asctime)s [%(levelname)s] %(message)s")
logger = logging.getLogger(__name__)

class InferenceRouter:
    """
    Orquestador FastAPI de Inferencia. 
    Actúa como un procesador de lenguaje ciego sin estado (Stateless).
    Maneja el ruteo interno a llama-server On-Premise compatible con OpenAI API.
    """
    def __init__(self):
        # Entorno base local (llama-server OpenAI-compatible)
        self.llama_url = os.getenv("LLAMA_HOST_URL", "http://127.0.0.1:8090/v1/chat/completions")
        self.llama_model = "qwen2.5-7b-instruct"
        
        # Parámetros dictaminados para prevenir la saturación de CPU y mitigar sobrepensamientos:
        # Temperature baja garantiza enfoque heurístico directo, límite estricto de tokens de salida (máx 500 según las reglas).
        self.temperature = 0.3
        self.top_p = 0.9
        self.max_tokens = 300

    async def _call_llama_cpp_local(self, messages: List[Dict[str, Any]]) -> str:
        """Comunica asíncronamente con el Daemon Local compatible con OpenAI API"""
        logger.info(f"Ruteo Offline → Invocando Inferencia Local sobre {self.llama_model}")
        payload = {
            "model": self.llama_model,
            "messages": messages,
            "temperature": self.temperature,
            "top_p": self.top_p,
            "max_tokens": self.max_tokens,
            "stream": False
        }
        
        # Timeout agresivo para evitar congestiones en el backend (60 seg)
        async with httpx.AsyncClient(timeout=60.0) as client:
            try:
                response = await client.post(self.llama_url, json=payload)
                response.raise_for_status()
                data = response.json()
                
                # Parse OpenAI compliant response
                choices = data.get("choices", [])
                if choices:
                    return choices[0].get("message", {}).get("content", "")
                return ""
            except httpx.TimeoutException as e:
                logger.error(f"Timeout en Inferencia LLM: {str(e)}")
                raise RuntimeError(f"Tiempo de espera agotado al conectar con el servidor LLM (60s).")
            except httpx.RequestError as e:
                logger.error(f"Error de red en Inferencia LLM: {str(e)}")
                raise RuntimeError(f"Excepción de red conectando al backend LLM local: {str(e)}")
            except Exception as e:
                logger.error(f"Error genérico Inferencia LLM: {str(e)}")
                raise RuntimeError(f"Error parseando respuesta del LLM local: {str(e)}")

    async def execute_inferential_cycle(self, payload: Dict[str, Any]) -> Dict[str, Any]:
        """
        Ejecuta el pipeline completo y resuelve el contrato Pydantic. 
        Este es el Endpoint Hook principal desde main.py.
        """
        # Desempacado del Contrato de Datos Frontend (snake_case)
        capsula = payload.get("capsula_activa", {})
        system_prompt = capsula.get("system_prompt", "Eres Ciego a la persona. Procesa matemáticamente la información adjunta.")
        identity_sqlite = payload.get("perfil_identidad", "")
        rag_payload = payload.get("contexto_rag_hibrido", {})
        conversational_history = payload.get("historial_reciente", [])
        active_message = payload.get("mensaje_actual", "")

        # Fusión Crítica del Contexto Inicial
        fused_system_directive = f"""
        {system_prompt}
        --- 
        Métricas de Identidad Móvil:
        {identity_sqlite}
        
        RAG Semántico extraído en dispositivo (Límite 400w):
        {json.dumps(rag_payload)}
        
        SISTEMA DE MUTACIÓN: Si detectas que el usuario menciona una nueva preferencia, métrica física o condición técnica, inserta en tu respuesta un bloque XML así para que el SO del móvil lo extraiga, con formato lista de dicts:
        <perfil_update>[{{"categoria": "rango", "clave": "valor", "valor": "dato"}}]</perfil_update>
        """

        # Preparación de Vector compatible con OpenAI API Local
        messages = [{"role": "system", "content": fused_system_directive}]
        for m in conversational_history:
            messages.append({"role": m.get("role", "user"), "content": m.get("content", "")})
        if active_message:
            messages.append({"role": "user", "content": active_message})

        raw_llm_response = ""
        processing_engine = "llama_server_local_x86"

        try:
            # --- INFERENCIA LOCAL CERO COSTE ---
            raw_llm_response = await self._call_llama_cpp_local(messages)
            
        except Exception as severe_e:
            logger.error(f"FALLO DE MOTOR COGNITIVO. Razón: {severe_e}")
            raw_llm_response = "Disculpa, he perdido temporalmente el enlace a la matriz cognitiva y de respaldo híbrido. Reintenta."
            processing_engine = "system_failure"

        return {
            "status": "success" if processing_engine != "system_failure" else "interrupted",
            "assistant_response": raw_llm_response,
            "inferenced_by": processing_engine
        }

