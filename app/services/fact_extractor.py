import re
import json
import logging
from typing import Tuple, List, Dict, Any
from app.schemas.chat_schema import PerfilUpdateItem

logger = logging.getLogger(__name__)

class FactExtractor:
    @staticmethod
    def extract_eav_mutations(raw_response: str) -> Tuple[List[Dict[str, Any]], str]:
        """
        Analiza el texto plano buscando la presencia del patrón <perfil_update>...</perfil_update>.
        Si lo encuentra, extrae los hechos EAV mutantes, los valida contra Pydantic y limpia el texto para
        que la UI del móvil reciba un mensaje pulcro.
        Retorna:
            (lista_de_updates_validados_como_dict, string_sanitizado)
        """
        perfil_updates = []
        sanitized_text = raw_response
        
        match = re.search(r'<perfil_update>(.*?)</perfil_update>', raw_response, re.DOTALL)
        if match:
            json_str = match.group(1).strip()
            # Limpiamos bloques markdown erráticos del modelo generativo (ej. ```json ... ```)
            json_str = re.sub(r'```(?:json)?\n?|\n?```', '', json_str).strip()
            try:
                parsed = json.loads(json_str)
                # Validamos contra esquema pydantic y transmutamos a dicts nativos
                if isinstance(parsed, list):
                    perfil_updates = [PerfilUpdateItem(**item).model_dump() for item in parsed]
                elif isinstance(parsed, dict):
                    perfil_updates = [PerfilUpdateItem(**parsed).model_dump()]
            except Exception as parsing_error:
                logger.error(f"Error procesando json estructurado EAV (JSON malformado o modelo inválido): {parsing_error}")
            
            # Sanitizamos (borramos) las etiquetas estructurales de la respuesta final del usuario
            sanitized_text = re.sub(r'<perfil_update>.*?</perfil_update>', '', raw_response, flags=re.DOTALL).strip()
        
        return perfil_updates, sanitized_text
