from __future__ import annotations

import json
from pathlib import Path

import pytest

from angelscript_generation.schema import (
    SCHEMA_VERSION_REQUEST,
    SchemaError,
    load_request,
    load_result,
)

SCHEMA_DIR = Path(__file__).resolve().parents[2] / "schema"


def test_request_schema_file_exists() -> None:
    path = SCHEMA_DIR / "generation-request-v1.json"
    payload = json.loads(path.read_text(encoding="utf-8"))
    assert payload["$id"] == "generation-request-v1"


def test_valid_request_round_trip() -> None:
    request = load_request(
        {
            "schemaVersion": SCHEMA_VERSION_REQUEST,
            "caseKey": "TestSource/Bindings/AActor/Test_Queries_01",
            "origin": "Authored",
            "recipeId": "authored-source-export",
            "recipeVersion": "1",
            "seed": "0",
        }
    )
    assert request.seed_u64 == 0
    assert request.output_mode == "memory"


def test_unknown_schema_version_is_stable_error() -> None:
    with pytest.raises(SchemaError) as caught:
        load_request(
            {
                "schemaVersion": "generation-request-v0",
                "caseKey": "TestSource/Bindings/AActor/Test_Queries_01",
                "origin": "Authored",
                "recipeId": "authored-source-export",
                "recipeVersion": "1",
                "seed": "0",
            }
        )
    assert caught.value.code == "unsupported_schema_version"


def test_absolute_case_key_rejected() -> None:
    with pytest.raises(SchemaError) as caught:
        load_request(
            {
                "schemaVersion": SCHEMA_VERSION_REQUEST,
                "caseKey": r"D:\Workspace\TestSource\Bindings\AActor\Test_Queries_01",
                "origin": "Authored",
                "recipeId": "authored-source-export",
                "recipeVersion": "1",
                "seed": "0",
            }
        )
    assert caught.value.code == "invalid_case_key"


def test_result_requires_complete_fields() -> None:
    with pytest.raises(SchemaError) as caught:
        load_result({"schemaVersion": "generation-result-v1"})
    assert caught.value.code == "missing_field"
