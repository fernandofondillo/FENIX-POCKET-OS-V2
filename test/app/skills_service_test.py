import pytest
from app.services.skills_service import execute
from fastapi import HTTPException

@pytest.mark.asyncio
async def test_execute_built_in_skills_success():
    # Validamos las 5
    res1 = await execute("memoria_recordar", {"clave": "test"}, "u01")
    assert res1["success"] is True
    
    res2 = await execute("web_search", {"query": "A.G.O.S"}, "u01")
    assert res2["success"] is True

    res3 = await execute("memoria_olvidar", {"clave": "test"}, "u01")
    assert res3["success"] is True
    
    res4 = await execute("notificacion_enviar", {"mensaje": "Test", "retraso_minutos": 0}, "u01")
    assert res4["success"] is True
    
    res5 = await execute("agenda_crear", {"titulo": "Comida", "fecha_hora": "2026-06-10"}, "u01")
    assert res5["success"] is True

@pytest.mark.asyncio
async def test_execute_pydantic_error():
    with pytest.raises(HTTPException) as exc:
        await execute("notificacion_enviar", {"falta": "argumento vital"}, "u02")
    assert exc.value.status_code == 400

@pytest.mark.asyncio
async def test_rate_limiting_triggers():
    user_fast = "user_flash_gordon"
    
    # Excedemos al ejecutar 10 veces en ventana de 60s
    for _ in range(10):
        await execute("memoria_recordar", {"clave": "t"}, user_fast)
        
    with pytest.raises(HTTPException) as exc:
        await execute("memoria_recordar", {"clave": "t"}, user_fast)
        
    assert exc.value.status_code == 429
    assert "Exceso en el umbral elástico" in exc.value.detail
