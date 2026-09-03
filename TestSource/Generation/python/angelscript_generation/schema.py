"""Versioned generation request/result loading."""

from __future__ import annotations

import json
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any

SCHEMA_VERSION_REQUEST = "generation-request-v1"
SCHEMA_VERSION_RESULT = "generation-result-v1"
SUPPORTED_ORIGINS = {"Authored", "NativeSDK", "Coverage", "Inline"}
SUPPORTED_OUTPUT = {"memory", "saved", "golden", "release"}
UINT64_MAX = (1 << 64) - 1


class SchemaError(ValueError):
    def __init__(self, code: str, message: str) -> None:
        super().__init__(message)
        self.code = code


def _uint64_string(value: Any, field_name: str) -> str:
    if isinstance(value, bool) or not isinstance(value, (int, str)):
        raise SchemaError("invalid_seed", f"{field_name} must be an unsigned 64-bit decimal string")
    if isinstance(value, int):
        if not 0 <= value <= UINT64_MAX:
            raise SchemaError("invalid_seed", f"{field_name} out of uint64 range")
        return str(value)
    if not value.isdigit():
        raise SchemaError("invalid_seed", f"{field_name} must be an unsigned 64-bit decimal string")
    parsed = int(value)
    if parsed > UINT64_MAX:
        raise SchemaError("invalid_seed", f"{field_name} out of uint64 range")
    return str(parsed)


@dataclass(frozen=True)
class GenerationRequest:
    schema_version: str
    case_key: str
    origin: str
    recipe_id: str
    recipe_version: str
    seed: str
    explicit_axes: dict[str, Any] = field(default_factory=dict)
    enumerate_all: bool = False
    output_mode: str = "memory"
    reference_ids: tuple[str, ...] = ()
    required_harness: tuple[str, ...] = ()

    @property
    def seed_u64(self) -> int:
        return int(self.seed)


@dataclass(frozen=True)
class GenerationResult:
    schema_version: str
    origin: str
    case_key: str
    recipe_id: str
    recipe_version: str
    seed: str
    selected_axes: dict[str, Any]
    source_bundle: tuple[dict[str, Any], ...]
    manifest_utf8: str
    cells: tuple[dict[str, Any], ...]
    oracle: dict[str, Any]
    comment_facts: dict[str, Any]
    references: tuple[str, ...]
    harness: tuple[str, ...]
    error: dict[str, str] | None = None
    negative_mutation: dict[str, Any] | None = None
    recovery_source_hex: str | None = None


def _require(payload: dict[str, Any], key: str) -> Any:
    if key not in payload:
        raise SchemaError("missing_field", f"missing required field {key}")
    return payload[key]


def load_request(payload: dict[str, Any] | str | Path) -> GenerationRequest:
    data = _as_object(payload)
    version = _require(data, "schemaVersion")
    if version != SCHEMA_VERSION_REQUEST:
        raise SchemaError("unsupported_schema_version", f"unsupported request schema {version}")
    origin = _require(data, "origin")
    if origin not in SUPPORTED_ORIGINS:
        raise SchemaError("invalid_origin", f"unsupported origin {origin}")
    output_mode = data.get("outputMode", "memory")
    if output_mode not in SUPPORTED_OUTPUT:
        raise SchemaError("invalid_output_mode", f"unsupported output mode {output_mode}")
    case_key = _require(data, "caseKey")
    if not isinstance(case_key, str) or not case_key or "\\" in case_key or ":" in case_key:
        raise SchemaError("invalid_case_key", "caseKey must be a logical slash-separated identity")
    return GenerationRequest(
        schema_version=version,
        case_key=case_key,
        origin=origin,
        recipe_id=str(_require(data, "recipeId")),
        recipe_version=str(_require(data, "recipeVersion")),
        seed=_uint64_string(_require(data, "seed"), "seed"),
        explicit_axes=dict(data.get("explicitAxes") or {}),
        enumerate_all=bool(data.get("enumerateAll", False)),
        output_mode=output_mode,
        reference_ids=tuple(data.get("referenceIds") or ()),
        required_harness=tuple(data.get("requiredHarness") or ()),
    )


def load_result(payload: dict[str, Any] | str | Path) -> GenerationResult:
    data = _as_object(payload)
    version = _require(data, "schemaVersion")
    if version != SCHEMA_VERSION_RESULT:
        raise SchemaError("unsupported_schema_version", f"unsupported result schema {version}")
    error = data.get("error")
    if error is not None and not isinstance(error, dict):
        raise SchemaError("invalid_error", "error must be an object or null")
    return GenerationResult(
        schema_version=version,
        origin=str(_require(data, "origin")),
        case_key=str(_require(data, "caseKey")),
        recipe_id=str(_require(data, "recipeId")),
        recipe_version=str(_require(data, "recipeVersion")),
        seed=_uint64_string(_require(data, "seed"), "seed"),
        selected_axes=dict(_require(data, "selectedAxes")),
        source_bundle=tuple(_require(data, "sourceBundle")),
        manifest_utf8=str(_require(data, "manifestUtf8")),
        cells=tuple(_require(data, "cells")),
        oracle=dict(_require(data, "oracle")),
        comment_facts=dict(_require(data, "commentFacts")),
        references=tuple(_require(data, "references")),
        harness=tuple(_require(data, "harness")),
        error=error,
        negative_mutation=data.get("negativeMutation"),
        recovery_source_hex=data.get("recoverySourceHex"),
    )


def _as_object(payload: dict[str, Any] | str | Path) -> dict[str, Any]:
    if isinstance(payload, Path):
        payload = payload.read_text(encoding="utf-8")
    if isinstance(payload, str):
        payload = json.loads(payload)
    if not isinstance(payload, dict):
        raise SchemaError("invalid_object", "payload must be a JSON object")
    return payload
