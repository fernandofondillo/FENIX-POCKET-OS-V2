from pydantic import BaseModel, Field
from typing import List, Optional

# ==========================================
# CONTRATOS DE RED (SNAKE_CASE STRICT)
# ==========================================

class Message(BaseModel):
    role: str = Field(..., description="Role del remitente (transparente a frontend), e.g., 'user' o 'assistant'")
    content: str = Field(..., description="Contenido en texto crudo del mensaje")

class CapsulaActiva(BaseModel):
    id: str = Field(..., description="Identificador único de la cápsula agnóstica")
    system_prompt: str = Field(..., description="Directiva conductual raíz estructural")
    allowed_skills: List[str] = Field(default_factory=list, description="Las skills autorizadas para esta cápsula")

class RagContext(BaseModel):
    historial_usuario: Optional[str] = Field("", description="Payload RAG de diarios incrustado localmente")
    conocimiento_experto: Optional[str] = Field("", description="Módulos expertos leídos por el vector en el móvil")

class ChatRequest(BaseModel):
    user_id: str = Field(..., description="ID anónimo perimetral para logs (no atado a bases de datos en la nube)")
    capsula_activa: CapsulaActiva
    active_skills: List[str] = Field(default_factory=list, description="Skills globales actualmente conectadas al UI dinámico")
    perfil_identidad: str = Field(..., description="El string ultradenso renderizado por PerfilDbService EAV en Flutter")
    contexto_rag_hibrido: RagContext
    historial_reciente: List[Message] = Field(..., description="Cola FIF0 límite estricto de historial (8 mensajes)")
    mensaje_actual: str = Field(..., description="El prompt terminal a inferir")

class PerfilUpdateItem(BaseModel):
    categoria: str = Field(..., description="Categoría de la entidad EAV, ej. 'salud', 'longevidad', 'preferencias'")
    clave: str = Field(..., description="Llave del atributo EAV en snake_case, ej. 'lesion_sacroiliaca'")
    valor: str = Field(..., description="Valor correspondiente deducido por el modelo en texto plano")

class ChatResponse(BaseModel):
    status: str = Field(..., description="'success' o 'interrupted'")
    assistant_response: str = Field(..., description="Texto purgado listo para renderizarse en la UI del móvil")
    perfil_update: List[PerfilUpdateItem] = Field(default_factory=list, description="Array de diccionarios con las mutaciones EAV de SQLite a sincronizar")
    executed_skills: List[dict] = Field(default_factory=list, description="Array con el log y resultado dictaminado por los skills interceptados")
    inferenced_by: str = Field(..., description="Orquestador utilizado vía Cloud Bypass (ollama_offline_x86 / google_gemini_sdk_cloud / llama_server_local_x86)")

class ConsolidateRequest(BaseModel):
    historial_dia: str = Field(..., description="String crudo del historial del día a consolidar")

class ConsolidateResponse(BaseModel):
    resumen_markdown: str = Field(..., description="Resumen consolidado en formato Markdown")
    nuevos_datos_perfil: List[dict] = Field(default_factory=list, description="Datos extraídos para el perfil EAV")
    alertas_coach: str = Field(..., description="Alertas proactivas detectadas durante la consolidación")
