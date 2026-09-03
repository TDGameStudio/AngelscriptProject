"""Valid-baseline negative mutations: exactly one named invalid change."""

from __future__ import annotations

from typing import Any

from .schema import SchemaError


def apply_single_mutation(baseline: dict[str, Any], mutation: dict[str, Any]) -> dict[str, Any]:
    name = mutation.get("name")
    if not name:
        raise SchemaError("missing_field", "mutation.name is required")
    extra = [key for key in mutation if key not in {"name", "anchor", "detail"}]
    if extra:
        raise SchemaError("multiple_mutations", f"unexpected mutation fields {extra}")
    result = dict(baseline)
    result["negativeMutation"] = {
        "name": name,
        "anchor": mutation.get("anchor", ""),
        "detail": mutation.get("detail", ""),
    }
    result["oracle"] = dict(baseline.get("oracle") or {})
    result["oracle"]["kind"] = result["oracle"].get("kind", "diagnostic")
    result["oracle"]["compileStatus"] = "fail"
    return result


def require_one_mutation(case: dict[str, Any]) -> str:
    mutation = case.get("negativeMutation")
    if not isinstance(mutation, dict) or not mutation.get("name"):
        raise SchemaError("missing_field", "negative case requires exactly one named mutation")
    return str(mutation["name"])
