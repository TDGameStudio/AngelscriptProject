from __future__ import annotations

import sys
from pathlib import Path

from fastapi.testclient import TestClient


sys.path.insert(0, str(Path(__file__).parents[1] / "src"))

from angelscript_codegen.web.server import create_app


def test_preview_page_exposes_semantic_controls_and_static_assets() -> None:
    client = TestClient(create_app())

    page = client.get("/")
    script = client.get("/assets/app.js")
    stylesheet = client.get("/assets/app.css")

    assert page.status_code == 200
    assert "AngelScript CodeGen" in page.text
    assert 'id="scenario-list"' in page.text
    assert 'id="preview-form"' in page.text
    assert 'for="seed"' in page.text
    assert 'id="preview-error"' in page.text
    assert 'aria-live="polite"' in page.text
    assert 'id="source-preview"' in page.text
    assert script.status_code == 200
    assert '"/api/scenarios"' in script.text
    assert stylesheet.status_code == 200
