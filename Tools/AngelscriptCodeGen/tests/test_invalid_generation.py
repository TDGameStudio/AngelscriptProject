from __future__ import annotations

import sys
from pathlib import Path

import pytest


sys.path.insert(0, str(Path(__file__).parents[1] / "src"))

from angelscript_codegen.generation.invalid import InvalidProgramGenerator
from angelscript_codegen.model.types import TypeKind, TypeSpec
from angelscript_codegen.profiles.loader import FragmentSpec, Profile


def profile_with_type_mismatch() -> Profile:
    return Profile(
        id="native-core",
        harness="native-sdk",
        types={
            "int": TypeSpec("int", TypeKind.PRIMITIVE),
            "bool": TypeSpec("bool", TypeKind.PRIMITIVE),
        },
        callables=(),
        fragments=(),
        invalid_rules=("type-mismatch",),
        limits={"max_depth": 3, "max_statements": 8},
    )


def test_invalid_generation_applies_only_the_requested_rule() -> None:
    generated = InvalidProgramGenerator(
        profile_with_type_mismatch(),
        seed=99,
        max_depth=3,
        max_statements=5,
    ).generate(ordinal=1, rule="type-mismatch")

    function = generated.program.functions[0]

    assert generated.kind == "invalid"
    assert generated.expected == "compile-fail"
    assert generated.invalid_rule == "type-mismatch"
    assert "int invalid_value = true;" in function.statements[0].source
    assert all("UnknownGeneratedSymbol" not in statement.source for statement in function.statements)


def test_invalid_generation_rejects_rule_not_enabled_by_profile() -> None:
    generator = InvalidProgramGenerator(
        profile_with_type_mismatch(),
        seed=99,
        max_depth=3,
        max_statements=5,
    )

    with pytest.raises(ValueError, match="unknown-symbol"):
        generator.generate(ordinal=0, rule="unknown-symbol")


def test_invalid_generation_retains_the_selected_profile_fragments() -> None:
    int_type = TypeSpec("int", TypeKind.PRIMITIVE)
    profile = Profile(
        id="ue-annotated",
        harness="ue-annotated",
        types={"int": int_type, "bool": TypeSpec("bool", TypeKind.PRIMITIVE)},
        callables=(),
        fragments=(FragmentSpec("annotated-class", (), "UCLASS()\nclass AGenerated : AActor\n{\n}"),),
        invalid_rules=("type-mismatch",),
        limits={},
    )

    generated = InvalidProgramGenerator(
        profile,
        seed=1,
        max_depth=1,
        max_statements=3,
    ).generate(ordinal=0, rule="type-mismatch")

    assert generated.program.fragments == ("UCLASS()\nclass AGenerated : AActor\n{\n}",)
