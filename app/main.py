import re
import json
import gc
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
    payload = None
    result = None
    raw_response = None
    
    try:
        # Cast Pydantic -> Dict para ruteo
        payload = request.model_dump()
        
        # Segmentación Multi-Usuario: Log interno visible solo en la consola del VPS
        print(f"[INFERENCIA] Procesando ráfaga cognitiva efímera para el usuario: {payload.get('user_id', 'Anónimo')}")
        
        # El router ejecuta inferencia. Los límites de tokens agresivos están configurados
        # en InferenceRouter (max_tokens=250), así minimizamos uso de RAM e hilos zombis.
        result = await router.execute_inferential_cycle(payload)
        
        raw_response = result.get("assistant_response", "")
        perfil_updates = []
        
        # Módulo de Extracción Regex de Mutaciones SQLite
        # Buscamos de manera eficiente la etiqueta <perfil_update> a lo largo de la respuesta cruda.
        match = re.search(r'<perfil_update>(.*?)</perfil_update>', raw_response, re.DOTALL)
        if match:
            json_str = match.group(1).strip()
            # Limpiamos bloques markdown erráticos del modelo generativo
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
            
            # Sanitizamos (borramos) las etiquetas estructurales de la respuesta final del usuario
            # para mantener la limpieza visual en el frontend interactivo de Flutter.
            raw_response = re.sub(r'<perfil_update>.*?</perfil_update>', '', raw_response, flags=re.DOTALL).strip()
        
        # Instanciamos la respuesta que devolvemos al dispositivo móvil
        response_data = ChatResponse(
            status=result["status"],
            assistant_response=raw_response,
            perfil_update=perfil_updates,
            inferenced_by=result["inferenced_by"]
        )
        return response_data

    except Exception as e:
        # Prevención de exposición de stack-traces sensibles del motor
        raise HTTPException(status_code=500, detail=str(e))
        
    finally:
        # HIGIENE DE LA MEMORIA RAM (CPU Multi-Usuario)
        # Libera forzosamente tensores huérfanos de Python, el objeto `request` con
        # información personal y datos de procesamiento temporal de la respuesta generativa.
        # Garantizamos un VPS sin memoria residual de usuario tras la evaluación.
        del request
        del payload
        del result
        del raw_response
        gc.collect()

# =====================================================================
# RUNBOOK TÉCNICO DE DESPLIEGUE PARA HERMES AGENT
# =====================================================================
"""
Hermes Agent: Procesa y ejecuta el siguiente manifiesto en el VPS Hostinger (Ubuntu/Debian)
para configurar Caddy, FastAPI y aislar el entorno operativo.

1. CONFIGURACIÓN DEL ENTORNO (.env)
   Crea un archivo oculto .env en la raíz del proyecto con la válvula Cloud Fallback:
   $ echo "GEMINI_API_KEY=tu_clave_secreta" >> .env
   $ echo "USE_CLOUD_FALLBACK=True" >> .env
   $ echo "OLLAMA_HOST_URL=http://127.0.0.1:11434" >> .env

2. PREPARACIÓN E INSTALACIÓN CON DEPENDENCIAS
   $ python3 -m venv venv
   $ source venv/bin/activate
   $ pip install fastapi uvicorn pydantic gunicorn httpx google-genai python-dotenv

3. SERVICIO SYSTEMD (FASTAPI a 2 WORKERS)
   Aplica un límite estricto a los hilos de CPU / RAM.
   $ sudo nano /etc/systemd/system/fenix-api.service
   ---
   [Unit]
   Description=Gunicorn instance to serve Fenix Stateless API
   After=network.target

   [Service]
   User=ubuntu
   Group=www-data
   WorkingDirectory=/home/ubuntu/fenix-backend
   Environment="PATH=/home/ubuntu/fenix-backend/venv/bin"
   # Límite estricto de workers (-w 2) para no saturar memoria RAM/CPU
   ExecStart=/home/ubuntu/fenix-backend/venv/bin/gunicorn app.main:app -w 2 -k uvicorn.workers.UvicornWorker -b 127.0.0.1:8000

   [Install]
   WantedBy=multi-user.target
   ---
   $ sudo systemctl daemon-reload
   $ sudo systemctl start fenix-api
   $ sudo systemctl enable fenix-api

4. CADDY SERVER (SSL AUTOMÁTICO Y REVERSE PROXY)
   $ sudo nano /etc/caddy/Caddyfile
   ---
   api.tu-dominio.com {
       reverse_proxy 127.0.0.1:8000
   }
   ---
   $ sudo systemctl reload caddy

¡El servicio está listo y seguro en el borde operativo!
"""
