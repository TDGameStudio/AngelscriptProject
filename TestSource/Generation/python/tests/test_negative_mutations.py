from __future__ import annotations

import pytest

from angelscript_generation.mutations import apply_single_mutation, require_one_mutation
from angelscript_generation.schema import SchemaError


def test_exactly_one_named_mutation() -> None:
    baseline = {"oracle": {"kind": "compile", "compileStatus": "pass"}, "source": "void f(){}"}
    mutated = apply_single_mutation(baseline, {"name": "missing-semicolon", "anchor": "f:1"})
    assert require_one_mutation(mutated) == "missing-semicolon"
    assert mutated["oracle"]["compileStatus"] == "fail"
    assert baseline["oracle"]["compileStatus"] == "pass"


def test_extra_mutation_fields_are_rejected() -> None:
    with pytest.raises(SchemaError) as caught:
        apply_single_mutation({}, {"name": "a", "other": "b"})
    assert caught.value.code == "multiple_mutations"
