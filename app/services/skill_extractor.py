import re
import json
import logging
from typing import Tuple, List, Dict, Any
from app.services.skills_service import execute
from fastapi import HTTPException

logger = logging.getLogger(__name__)

class SkillExtractor:
    @staticmethod
    async def extract_and_execute_skills(raw_response: str, user_id: str) -> Tuple[List[Dict[str, Any]], str]:
        """
        Analizador sintáctico por Expresiones Regulares con Complejidad O(N).
        Detecta el sub-bloque <skill name="abc" args='{...}' />, lo purga por seguridad
        visual front-end, e invoca al SkillRouter de inmediato de manera concurrente.
        Retorna la matriz estructural inyectada para el App móvil de Flutter.
        """
        executed_skills = []
        sanitized_text = raw_response
        
        # Tolerancia en validación para quotes simples o dobles
        pattern = r'<skill\s+name=[\'"]?(\w+)[\'"]?\s+args=[\'"]?({[^<]+})[\'"]?\s*/>'
        matches = re.finditer(pattern, raw_response, re.DOTALL)
        
        for match in matches:
            skill_name = match.group(1)
            args_str = match.group(2)
            
            try:
                # Bypass inicial de escapeo HTML errático
                args_str_fixed = args_str.replace('&quot;', '"').strip()
                args_json = json.loads(args_str_fixed)
                
                # Despacho en hilo asíncrono sin bloqueo
                result = await execute(skill_name, args_json, user_id)
                executed_skills.append({
                    "skill_name": skill_name,
                    "args": args_json,
                    "result": result
                })
            except json.JSONDecodeError as e:
                logger.error(f"Falla de desestabilización en el JSON anidado '{skill_name}': {e}")
                executed_skills.append({
                    "skill_name": skill_name,
                    "args": None,
                    "result": {"success": False, "error": "Cuerpo JSON inviable o corrupto"}
                })
            except HTTPException as e:
                logger.error(f"Falla HTTP en runtime (Pydantic/Route): {e.detail}")
                executed_skills.append({
                    "skill_name": skill_name,
                    "args": args_json if 'args_json' in locals() else None,
                    "result": {"success": False, "error": str(e.detail)}
                })
            except Exception as e:
                logger.critical(f"Segfault global escapado en skill_extractor. Motor: {e}")
                executed_skills.append({
                    "skill_name": skill_name,
                    "args": None,
                    "result": {"success": False, "error": "Critical Engine Stop"}
                })
                
        # Proceso final de Pulido Estético para el Client-Side Render (Dart Widget)
        sanitized_text = re.sub(pattern, '', raw_response, flags=re.DOTALL).strip()
        
        return executed_skills, sanitized_text
