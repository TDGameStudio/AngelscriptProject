from __future__ import annotations

import sys
from pathlib import Path

from fastapi.testclient import TestClient
import pytest


sys.path.insert(0, str(Path(__file__).parents[1] / "src"))

from angelscript_codegen.output import writer
from angelscript_codegen.web.server import create_app


@pytest.fixture()
def client() -> TestClient:
    return TestClient(create_app())


def test_scenarios_endpoint_returns_the_four_reviewed_cards(client: TestClient) -> None:
    response = client.get("/api/scenarios")

    assert response.status_code == 200
    assert [scenario["id"] for scenario in response.json()] == [
        "native-control-flow",
        "ue-value-environment",
        "uclass-annotation",
        "actor-lifecycle",
    ]


def test_preview_returns_one_lifted_source_only_case_for_the_selected_scenario(client: TestClient) -> None:
    response = client.post(
        "/api/preview",
        json={
            "scenario_id": "uclass-annotation",
            "seed": 42,
            "max_depth": 4,
            "max_statements": 16,
        },
    )

    body = response.json()

    assert response.status_code == 200
    assert body["profile"] == "ue-annotated"
    assert body["expected"] == "compile-pass"
    assert body["verification"] == "source-only"
    assert "// @as_codegen.profile: ue-annotated" in body["source"]
    assert "UCLASS()" in body["source"]


def test_preview_rejects_unknown_scenarios_and_bounds_outside_profile_limits(client: TestClient) -> None:
    unknown = client.post(
        "/api/preview",
        json={"scenario_id": "unknown", "seed": 0, "max_depth": 1, "max_statements": 1},
    )
    excessive = client.post(
        "/api/preview",
        json={
            "scenario_id": "native-control-flow",
            "seed": 0,
            "max_depth": 4,
            "max_statements": 8,
        },
    )

    assert unknown.status_code == 404
    assert "unknown" in unknown.json()["detail"]
    assert excessive.status_code == 422
    assert "max_depth" in excessive.json()["detail"]


def test_preview_rejects_invalid_unsigned_64_bit_seeds(client: TestClient) -> None:
    negative = client.post(
        "/api/preview",
        json={
            "scenario_id": "native-control-flow",
            "seed": -1,
            "max_depth": 3,
            "max_statements": 8,
        },
    )
    too_large = client.post(
        "/api/preview",
        json={
            "scenario_id": "native-control-flow",
            "seed": 2**64,
            "max_depth": 3,
            "max_statements": 8,
        },
    )

    assert negative.status_code == 422
    assert too_large.status_code == 422


def test_preview_does_not_use_the_output_writer(client: TestClient, monkeypatch: pytest.MonkeyPatch) -> None:
    def fail_if_written(*_args: object, **_kwargs: object) -> None:
        raise AssertionError("Web preview must not write generated artifacts.")

    monkeypatch.setattr(writer, "write_cases", fail_if_written)

    response = client.post(
        "/api/preview",
        json={"scenario_id": "native-control-flow", "seed": 0, "max_depth": 3, "max_statements": 8},
    )

    assert response.status_code == 200
    assert "int GeneratedCase_000000()" in response.json()["source"]
