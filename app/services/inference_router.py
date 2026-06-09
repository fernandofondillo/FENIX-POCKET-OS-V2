import os
import logging
import json
import re
from typing import Dict, Any, List
import httpx
from google import genai
from google.genai import types

# Configuración de Logging Asíncrono
logging.basicConfig(level=logging.INFO, format="%(asctime)s [%(levelname)s] %(message)s")
logger = logging.getLogger(__name__)

class InferenceRouter:
    """
    Orquestador FastAPI de Inferencia. 
    Actúa como un procesador de lenguaje ciego sin estado (Stateless).
    Maneja el ruteo interno a Ollama On-Premise y posee una válvula de escape 'Cloud Fallback'.
    """
    def __init__(self):
        # Entorno base local (Ollama CPU)
        self.ollama_url = os.getenv("OLLAMA_HOST_URL", "http://127.0.0.1:11434")
        self.ollama_model = "qwen2.5:7b"
        
        # Bandera forzada para traspasar la carga térmica a Cloud (Google GenAI)
        self.use_cloud_fallback = os.getenv("USE_CLOUD_FALLBACK", "False").lower() in ["true", "1", "yes"]
        
        # Parámetros dictaminados para prevenir la saturación de CPU y mitigar sobrepensamientos:
        # Temperature baja garantiza enfoque heurístico directo, límite estricto de tokens de salida.
        self.temperature = 0.3
        self.top_p = 0.9
        self.max_tokens = 250

        # SDK de Fallback Cloud
        api_key = os.getenv("GEMINI_API_KEY")
        self.genai_client = genai.Client(api_key=api_key) if api_key else None

    async def _call_ollama_local(self, messages: List[Dict[str, Any]]) -> str:
        """Comunica asíncronamente con el Daemon Local de Ollama"""
        logger.info(f"Ruteo Offline → Invocando Inferencia Local sobre {self.ollama_model}")
        payload = {
            "model": self.ollama_model,
            "messages": messages,
            "stream": False,  # Respuestas Block-Wait puras para la PoC inicial
            "options": {
                "temperature": self.temperature,
                "top_p": self.top_p,
                "num_predict": self.max_tokens
            }
        }
        
        # Timeout optimizado para prevenir atascos de Gunicorn/Uvicorn (15 seg max CPU bleed limit)
        async with httpx.AsyncClient(timeout=15.0) as client:
            response = await client.post(f"{self.ollama_url}/api/chat", json=payload)
            response.raise_for_status()
            data = response.json()
            return data.get("message", {}).get("content", "")

    async def _call_gemini_cloud(self, system_instruction: str, history: List[Dict[str, Any]], current_msg: str) -> str:
        """Deriva el Payload (Stateless) usando SDK oficial de Google GenAI Gemini 2.0"""
        if not self.genai_client:
            raise ValueError("GEMINI_API_KEY crítica ausente, pero el Cloud Fallback fue activado.")
        
        logger.warning(f"Ruteo Cloud Fallback Activado → Invocando Gemini 2.0 Pro")
        
        # Mapeador de Roles: Aisla al móvil de las nomenclaturas propietarias.
        # "assistant" en Dart se enmascara translúcidamente como "model" en GenAI.
        mapped_history = []
        for msg in history:
            mapped_role = "model" if msg["role"] == "assistant" else "user"
            mapped_history.append(
                types.Content(role=mapped_role, parts=[types.Part.from_text(text=msg["content"])])
            )

        # Configurador de Comportamiento Restrictivo (Respetando el Contrato Fénix de 400w y latencia)
        config = types.GenerateContentConfig(
            system_instruction=system_instruction,
            temperature=self.temperature,
            top_p=self.top_p,
            max_output_tokens=self.max_tokens,
        )

        contents = mapped_history + [types.Content(role="user", parts=[types.Part.from_text(text=current_msg)])]
        
        # El VPS hace de passthrough usando generation state-less
        response = self.genai_client.models.generate_content(
            model='gemini-2.0-pro',
            contents=contents,
            config=config
        )
        return response.text

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

        # Preparación de Vector compatible con Ollama local
        ollama_injection = [{"role": "system", "content": fused_system_directive}]
        for m in conversational_history:
            ollama_injection.append({"role": m["role"], "content": m["content"]})
        ollama_injection.append({"role": "user", "content": active_message})

        raw_llm_response = ""
        processing_engine = "ollama_offline_x86"

        try:
            if self.use_cloud_fallback:
                raise httpx.RequestError("Bypass Directo: Regla USE_CLOUD_FALLBACK=True Forzada.")
            
            # --- TRY INFERENCIA LOCAL DE CERO COSTE ---
            raw_llm_response = await self._call_ollama_local(ollama_injection)
            
        except (httpx.RequestError, httpx.TimeoutException) as network_error:
            logger.warning(f"Saturación de Servidor VCPU o Bypass local detectado ({network_error}). Conmutando carga térmica a API Gateways Cloud...")
            try:
                # --- DERIVACIÓN AL SDK GEMINI ---
                raw_llm_response = await self._call_gemini_cloud(
                    system_instruction=fused_system_directive,
                    history=conversational_history,
                    current_msg=active_message
                )
                processing_engine = "google_gemini_sdk_cloud"
            except Exception as severe_e:
                logger.error(f"FALLO DE PUENTE NUBE Y LOCAL. Motor inoperante. Razón: {severe_e}")
                raw_llm_response = "Disculpa, he perdido temporalmente el enlace a la matriz cognitiva y de respaldo híbrido. Reintenta."
                processing_engine = "system_failure"

        # La extracción de heurísticas EAV se desplaza hacia main.py según la nueva arquitectura
        return {
            "status": "success" if processing_engine != "system_failure" else "interrupted",
            "assistant_response": raw_llm_response,
            "inferenced_by": processing_engine
        }
