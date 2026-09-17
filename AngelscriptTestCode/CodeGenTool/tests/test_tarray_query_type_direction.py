from __future__ import annotations

import sys
import unittest
from pathlib import Path

TOOL_ROOT = Path(__file__).resolve().parents[1]
REPO_ROOT = TOOL_ROOT.parents[1]
sys.path.insert(0, str(TOOL_ROOT))

from angelscript_test_codegen.container_parser import parse_source_file
from angelscript_test_codegen.model import SourceInput

AUTHOR_ROOT = REPO_ROOT / "AngelscriptTestCode"


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


def parse_author(relative_path: str):
    path = AUTHOR_ROOT / Path(relative_path)
    return parse_source_file(make_source(relative_path, path.read_bytes(), path))


class TArrayQueryTypeDirectionTests(unittest.TestCase):
    def test_ContainsFStringParses(self) -> None:
        parsed = parse_author("Containers/TArray/ContainsReportsMembershipFString.as")
        self.assertEqual("Containers/TArray/ContainsReportsMembershipFString", parsed.source.file_tag)
        parentless = [version for version in parsed.versions if version.parent is None]
        self.assertEqual(1, len(parentless))
        self.assertEqual("ContainsReportsMembershipFString", parentless[0].tag)
        self.assertIn(b"TArray<FString>", parentless[0].clean_source)
        self.assertIn(b"Contains", parentless[0].clean_source)

    def test_ReadContainsParses(self) -> None:
        parsed = parse_author("Containers/TArray/ReadContainsReportsMembership.as")
        parentless = [version for version in parsed.versions if version.parent is None]
        self.assertEqual(1, len(parentless))
        self.assertEqual("ReadContainsReportsMembership", parentless[0].tag)
        self.assertIn(b"const TArray<int32>&in", parentless[0].clean_source)

    def test_EmptyConstructionFStringParses(self) -> None:
        parsed = parse_author("Containers/TArray/EmptyConstructionFString.as")
        parentless = [version for version in parsed.versions if version.parent is None]
        self.assertEqual(1, len(parentless))
        self.assertEqual("EmptyConstructionFString", parentless[0].tag)
        self.assertIn(b"TArray<FString>", parentless[0].clean_source)
        self.assertIn(b"IsEmpty", parentless[0].clean_source)

    def test_ExistingContainsControl(self) -> None:
        parsed = parse_author("Containers/TArray/ContainsReportsMembership.as")
        parentless = [version for version in parsed.versions if version.parent is None]
        self.assertEqual(1, len(parentless))
        self.assertEqual("ContainsReportsMembership", parentless[0].tag)


if __name__ == "__main__":
    unittest.main()
