import pytest
from app.services.skill_extractor import SkillExtractor

@pytest.mark.asyncio
async def test_extract_and_execute_skills_valid():
    raw_response = 'Claro, lo agenda así: <skill name="agenda_crear" args=\'{"titulo": "Reunion vital", "fecha_hora": "2026-10-10T14:00Z"}\'/>.'
    
    executed_skills, sanitized_text = await SkillExtractor.extract_and_execute_skills(raw_response, "user_1")
    
    assert "Claro, lo agenda así:" in sanitized_text
    assert "<skill name" not in sanitized_text
    
    assert len(executed_skills) == 1
    assert executed_skills[0]["skill_name"] == "agenda_crear"
    assert executed_skills[0]["args"]["titulo"] == "Reunion vital"
    assert executed_skills[0]["result"]["success"] is True

@pytest.mark.asyncio
async def test_extract_malformed_json_fallback():
    raw_response = 'Fallando intencionalmente <skill name="agenda_crear" args=\'{"titulo": esto_no_es_json}\'/>. Sigo text.'
    
    executed_skills, sanitized = await SkillExtractor.extract_and_execute_skills(raw_response, "user_1")
    
    assert len(executed_skills) == 1
    assert executed_skills[0]["skill_name"] == "agenda_crear"
    assert executed_skills[0]["result"]["success"] is False
    assert "Cuerpo JSON inviable o corrupto" in executed_skills[0]["result"]["error"]

@pytest.mark.asyncio
async def test_extract_non_existent_skill():
    raw_response = '<skill name="lanzar_misil" args=\'{"a": "b"}\' />'
    
    executed_skills, sanitized = await SkillExtractor.extract_and_execute_skills(raw_response, "user_2")
    
    assert len(executed_skills) == 1
    assert executed_skills[0]["result"]["success"] is False
    assert "Esa cápsula no contiene habilidades listadas en el registro maestro." in executed_skills[0]["result"]["error"]
