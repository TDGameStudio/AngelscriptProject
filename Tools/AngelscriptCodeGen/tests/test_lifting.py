from __future__ import annotations

import sys
from pathlib import Path


sys.path.insert(0, str(Path(__file__).parents[1] / "src"))

from angelscript_codegen.lifting.angelscript import lift_case
from angelscript_codegen.model.case import GenerationCase
from angelscript_codegen.model.program import Function, Program, Statement
from angelscript_codegen.model.types import TypeKind, TypeSpec


INT = TypeSpec("int", TypeKind.PRIMITIVE)


def test_lifter_emits_metadata_and_allman_function_formatting() -> None:
    case = GenerationCase(
        case_id="ASCG-native-core-valid-00000000",
        profile="native-core",
        kind="valid",
        seed=0,
        expected="compile-pass",
        harness="native-sdk",
        program=Program(
            functions=(
                Function(
                    name="GeneratedCase",
                    return_type=INT,
                    statements=(Statement("return 42;", INT),),
                ),
            )
        ),
    )

    source = lift_case(case)

    assert "// @as_codegen.case_id: ASCG-native-core-valid-00000000" in source
    assert "// @as_codegen.profile: native-core" in source
    assert "// @as_codegen.verification: source-only" in source
    assert "int GeneratedCase()\n{" in source
    assert "\treturn 42;\n}" in source
    assert source.endswith("\n")


def test_lifter_places_profile_fragments_between_metadata_and_functions() -> None:
    case = GenerationCase(
        case_id="ASCG-ue-annotated-valid-00000000",
        profile="ue-annotated",
        kind="valid",
        seed=0,
        expected="compile-pass",
        harness="ue-annotated",
        program=Program(
            fragments=("UCLASS()\nclass AGenerated : AActor\n{\n}",),
            functions=(
                Function(
                    name="GeneratedCase",
                    return_type=INT,
                    statements=(Statement("return 42;", INT),),
                ),
            ),
        ),
    )

    source = lift_case(case)

    assert source.index("UCLASS()") < source.index("int GeneratedCase()")
    assert "UCLASS()\nclass AGenerated : AActor" in source
