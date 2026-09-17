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


class TArrayCapacityCopyTypeDirectionTests(unittest.TestCase):
    def test_CopyAssignFStringParses(self) -> None:
        parsed = parse_author("Containers/TArray/CopyAssignFString.as")
        self.assertEqual("Containers/TArray/CopyAssignFString", parsed.source.file_tag)
        parentless = [version for version in parsed.versions if version.parent is None]
        self.assertEqual(1, len(parentless))
        self.assertEqual("CopyAssignFString", parentless[0].tag)
        self.assertIn(b"TArray<FString>", parentless[0].clean_source)

    def test_ReadCopyAssignParses(self) -> None:
        parsed = parse_author("Containers/TArray/ReadCopyAssign.as")
        parentless = [version for version in parsed.versions if version.parent is None]
        self.assertEqual(1, len(parentless))
        self.assertEqual("ReadCopyAssign", parentless[0].tag)
        self.assertIn(b"const TArray<int32>&in", parentless[0].clean_source)

    def test_ConstIteratorFStringParses(self) -> None:
        parsed = parse_author("Containers/TArray/ConstIteratorWalkFString.as")
        parentless = [version for version in parsed.versions if version.parent is None]
        self.assertEqual(1, len(parentless))
        self.assertEqual("ConstIteratorWalkFString", parentless[0].tag)
        clean = parentless[0].clean_source
        self.assertTrue(
            b"TArrayConstIterator<FString>" in clean or b"TArray<FString>" in clean,
            clean,
        )
        self.assertIn(b"Iterator", clean)

    def test_ExistingCopyAssignControl(self) -> None:
        parsed = parse_author("Containers/TArray/CopyAssign.as")
        parentless = [version for version in parsed.versions if version.parent is None]
        self.assertEqual(1, len(parentless))
        self.assertEqual("CopyAssign", parentless[0].tag)


if __name__ == "__main__":
    unittest.main()
