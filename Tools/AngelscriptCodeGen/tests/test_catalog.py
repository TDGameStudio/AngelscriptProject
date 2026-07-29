from __future__ import annotations

import json
import sys
from pathlib import Path


sys.path.insert(0, str(Path(__file__).parents[1] / "src"))

from angelscript_codegen.model.case import GenerationCase
from angelscript_codegen.model.program import Function, Program, Statement
from angelscript_codegen.model.types import TypeKind, TypeSpec
from angelscript_codegen.output.writer import write_cases


INT = TypeSpec("int", TypeKind.PRIMITIVE)


def test_writer_emits_source_and_matching_catalog_hash(tmp_path: Path) -> None:
    case = GenerationCase(
        case_id="ASCG-native-core-valid-00000000",
        profile="native-core",
        kind="valid",
        seed=0,
        expected="compile-pass",
        harness="native-sdk",
        program=Program(
            functions=(
                Function("GeneratedCase", INT, (Statement("return 42;", INT),)),
            )
        ),
    )

    index_path = write_cases((case,), tmp_path)
    document = json.loads(index_path.read_text(encoding="utf-8"))
    source_path = tmp_path / "ASCG-native-core-valid-00000000.as"

    assert source_path.is_file()
    assert document["schema_version"] == 1
    assert document["cases"] == [
        {
            "case_id": case.case_id,
            "expected": "compile-pass",
            "harness": "native-sdk",
            "invalid_rule": None,
            "kind": "valid",
            "path": source_path.name,
            "profile": "native-core",
            "seed": 0,
            "sha256": document["cases"][0]["sha256"],
            "verification": "source-only",
        }
    ]
    assert len(document["cases"][0]["sha256"]) == 64
