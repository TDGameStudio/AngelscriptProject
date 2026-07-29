from __future__ import annotations

from hashlib import sha256

from angelscript_codegen.model.case import GenerationCase


def case_index_entry(case: GenerationCase, filename: str, source: str) -> dict[str, object]:
    return {
        "case_id": case.case_id,
        "expected": case.expected,
        "harness": case.harness,
        "invalid_rule": case.invalid_rule,
        "kind": case.kind,
        "path": filename,
        "profile": case.profile,
        "seed": case.seed,
        "sha256": sha256(source.encode("utf-8")).hexdigest(),
        "verification": case.verification,
    }


def build_index(entries: list[dict[str, object]]) -> dict[str, object]:
    return {"schema_version": 1, "cases": entries}
