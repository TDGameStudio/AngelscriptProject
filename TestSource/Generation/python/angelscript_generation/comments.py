"""Structured knowledge-comment facts. Wording is not snapshotted."""

from __future__ import annotations

from typing import Any

from .schema import SchemaError

REQUIRED_FACTS = ("feature", "inputs", "expectations")


def validate_comment_facts(facts: dict[str, Any]) -> dict[str, Any]:
    if facts.get("schemaVersion") not in {None, "comment-facts-v1"}:
        raise SchemaError("unsupported_schema_version", "unsupported comment-facts schema")
    for key in REQUIRED_FACTS:
        value = facts.get(key)
        if not isinstance(value, str) or not value.strip():
            raise SchemaError("missing_comment_fact", f"comment fact {key} is required")
    return {
        "schemaVersion": "comment-facts-v1",
        "feature": facts["feature"].strip(),
        "inputs": facts["inputs"].strip(),
        "expectations": facts["expectations"].strip(),
        "boundary": str(facts.get("boundary") or "").strip(),
        "references": list(facts.get("references") or []),
        "attachment": str(facts.get("attachment") or "").strip(),
    }


def render_comment_block(facts: dict[str, Any]) -> str:
    checked = validate_comment_facts(facts)
    lines = [
        f"// Purpose: {checked['feature']}",
        f"// Inputs: {checked['inputs']}",
        f"// Expected observations: {checked['expectations']}",
    ]
    if checked["boundary"]:
        lines.append(f"// Boundary/ownership: {checked['boundary']}")
    return "\n".join(lines) + "\n"
