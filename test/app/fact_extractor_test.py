import pytest
from app.services.fact_extractor import FactExtractor

def test_extract_eav_valid():
    raw = "Hola, he actualizado tu perfil.\\n<perfil_update>\\n[{\\"categoria\\": \\"salud\\", \\"clave\\": \\"peso\\", \\"valor\\": \\"70kg\\"}]\\n</perfil_update>"
    updates, sanitized = FactExtractor.extract_eav_mutations(raw)
    assert len(updates) == 1
    assert updates[0]["clave"] == "peso"
    assert "Hola, he actualizado tu perfil." in sanitized
    assert "<perfil_update>" not in sanitized

def test_extract_eav_markdown_json():
    raw = "Aquí tienes.\\n<perfil_update>\\n```json\\n[{\\"categoria\\": \\"gym\\", \\"clave\\": \\"rm_banca\\", \\"valor\\": \\"80kg\\"}]\\n```\\n</perfil_update>"
    updates, sanitized = FactExtractor.extract_eav_mutations(raw)
    assert len(updates) == 1
    assert updates[0]["clave"] == "rm_banca"
    assert "<perfil_update>" not in sanitized

def test_extract_eav_malformed():
    raw = "malformed \\n<perfil_update>\\n[{\\"categoria\\": \\"gym\\", clave: missing_quotes}]\\n</perfil_update>"
    updates, sanitized = FactExtractor.extract_eav_mutations(raw)
    assert len(updates) == 0
    assert "malformed" in sanitized

def test_no_tags():
    raw = "Este es un mensaje normal sin rastro de etiquetas de edición EAV."
    updates, sanitized = FactExtractor.extract_eav_mutations(raw)
    assert len(updates) == 0
    assert sanitized == raw
