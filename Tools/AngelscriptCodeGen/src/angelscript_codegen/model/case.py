from __future__ import annotations

from dataclasses import dataclass

from angelscript_codegen.model.program import Program


@dataclass(frozen=True)
class GenerationCase:
    case_id: str
    profile: str
    kind: str
    seed: int
    expected: str
    harness: str
    program: Program
    invalid_rule: str | None = None
    verification: str = "source-only"
