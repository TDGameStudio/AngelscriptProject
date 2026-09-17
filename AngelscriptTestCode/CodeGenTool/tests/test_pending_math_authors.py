from __future__ import annotations

import re
import sys
import unittest
from pathlib import Path

TOOL_ROOT = Path(__file__).resolve().parents[1]
REPO_ROOT = TOOL_ROOT.parents[1]
sys.path.insert(0, str(TOOL_ROOT))

from angelscript_test_codegen.container_parser import parse_source_file
from angelscript_test_codegen.discovery import discover_sources
from angelscript_test_codegen.model import SourceInput

AUTHOR_ROOT = REPO_ROOT / "AngelscriptTestCode"
FUNCTION_STEMS = (
    "FunctionDefaultParameters",
    "FunctionParametersIn",
    "FunctionParametersInOut",
    "FunctionParametersOut",
    "FunctionParametersValue",
    "FunctionReturnValues",
)
TYPES = (
    "FLinearColor",
    "FRotator",
    "FTransform",
    "FVector",
    "FVector2D",
)


def kebab(name: str) -> str:
    stepped = re.sub(r"(?<!^)(?=[A-Z])", "-", name).replace("_", "-")
    return re.sub(r"-{2,}", "-", stepped).strip("-").lower()


LEFTOVERS = tuple(
    (type_name, kebab(stem))
    for type_name in TYPES
    for stem in FUNCTION_STEMS
)


def make_source(relative_path: str, content: bytes, full_path: Path) -> SourceInput:
    file_tag = relative_path[: -len(".as")]
    return SourceInput(
        full_path=full_path,
        relative_path=relative_path,
        file_tag=file_tag,
        output_relative_path=f"{file_tag}.generated.cpp",
        content=content,
        content_sha256="",
        symbol_suffix="",
    )


def parse_type(type_name: str):
    path = AUTHOR_ROOT / "Unreal" / f"{type_name}.as"
    return parse_source_file(make_source(f"Unreal/{type_name}.as", path.read_bytes(), path))


class PendingMathAuthorTests(unittest.TestCase):
    def test_function_parameters_in_parses(self) -> None:
        parsed = parse_type("FVector")
        versions = {version.tag: version for version in parsed.versions}
        self.assertIn("function-parameters-in", versions)
        version = versions["function-parameters-in"]
        self.assertIsNone(version.parent)
        self.assertIn(b"&in", version.clean_source)

    def test_all_thirty_stems_present(self) -> None:
        for type_name, tag in LEFTOVERS:
            with self.subTest(type_name=type_name, tag=tag):
                parsed = parse_type(type_name)
                tags = {version.tag for version in parsed.versions}
                self.assertIn(tag, tags)

    def test_discovery_skips_pending_math(self) -> None:
        pending = (
            AUTHOR_ROOT / "Pending" / "Math" / "FVector" / "FunctionParametersIn.as"
        )
        self.assertTrue(pending.is_file())
        sources = discover_sources(AUTHOR_ROOT)
        relative_paths = [source.relative_path.replace("\\", "/") for source in sources]
        self.assertFalse(any(path.startswith("Pending/") for path in relative_paths))
        self.assertIn("Unreal/FVector.as", relative_paths)
        self.assertNotIn("Pending/Math/FVector/FunctionParametersIn.as", relative_paths)


if __name__ == "__main__":
    unittest.main()
