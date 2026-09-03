"""Typed oracle round-trip without coercing values to int."""

from __future__ import annotations

from typing import Any

from .canonical import canonical_json_bytes
from .schema import SchemaError

ORACLE_KINDS = {
    "compile",
    "bool",
    "int",
    "uint",
    "float",
    "string",
    "name",
    "text",
    "enum",
    "math",
    "aggregate",
    "object",
    "writeback",
    "metadata",
    "bytecode",
    "trace",
    "lifecycle",
    "exception",
    "cleanup",
    "isolation",
    "save-load",
    "diagnostic",
    "recovery",
    "authored",
}

COMPARISON_MODES = {
    "exact",
    "bits",
    "tolerance",
    "identity",
    "nullability",
    "contains",
    "order",
}


def validate_oracle(oracle: dict[str, Any]) -> dict[str, Any]:
    if "kind" not in oracle:
        raise SchemaError("missing_field", "oracle.kind is required")
    kind = oracle["kind"]
    if kind not in ORACLE_KINDS:
        raise SchemaError("invalid_oracle_kind", f"unsupported oracle kind {kind}")
    comparison = oracle.get("comparison", "exact")
    if comparison not in COMPARISON_MODES:
        raise SchemaError("invalid_comparison", f"unsupported comparison {comparison}")
    payload = dict(oracle.get("payload") or {})
    if kind in {"int", "uint"} and "width" not in payload:
        raise SchemaError("missing_field", f"{kind} oracle requires width")
    if kind == "float" and comparison == "bits" and "bitPattern" not in payload:
        raise SchemaError("missing_field", "float bits oracle requires bitPattern")
    if kind == "float" and comparison == "tolerance" and "tolerance" not in payload:
        raise SchemaError("missing_field", "float tolerance oracle requires tolerance")
    if kind == "object" and "nullable" not in payload:
        raise SchemaError("missing_field", "object oracle requires nullable")
    return {
        "kind": kind,
        "comparison": comparison,
        "compileStatus": oracle.get("compileStatus", "pass"),
        "payload": payload,
    }


def oracle_bytes(oracle: dict[str, Any]) -> bytes:
    return canonical_json_bytes(validate_oracle(oracle))
