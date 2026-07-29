from __future__ import annotations

import sys
from pathlib import Path


sys.path.insert(0, str(Path(__file__).parents[1] / "src"))

from angelscript_codegen.generation.valid import ValidProgramGenerator
from angelscript_codegen.model.types import TypeKind, TypeSpec
from angelscript_codegen.profiles.loader import Profile


def native_profile() -> Profile:
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


def test_valid_generation_is_seeded_and_keeps_the_statement_bound() -> None:
    generator = ValidProgramGenerator(
        native_profile(),
        seed=424242,
        max_depth=3,
        max_statements=5,
    )

    first = generator.generate(ordinal=0)
    second = generator.generate(ordinal=0)

    assert first == second
    assert first.kind == "valid"
    assert first.expected == "compile-pass"
    assert first.harness == "native-sdk"
    assert len(first.program.functions) == 1
    assert len(first.program.functions[0].statements) <= 5


def test_valid_generation_uses_only_profile_types() -> None:
    generated = ValidProgramGenerator(
        native_profile(),
        seed=7,
        max_depth=2,
        max_statements=4,
    ).generate(ordinal=3)

    function = generated.program.functions[0]

    assert function.return_type.name == "int"
    assert all(statement.type.name in {"int", "bool", "void"} for statement in function.statements)


def test_valid_generation_excludes_runtime_unsafe_remainder_expressions() -> None:
    generated = ValidProgramGenerator(
        native_profile(),
        seed=20260723,
        max_depth=3,
        max_statements=6,
    ).generate(ordinal=0)

    assert all("%" not in statement.source for statement in generated.program.functions[0].statements)
