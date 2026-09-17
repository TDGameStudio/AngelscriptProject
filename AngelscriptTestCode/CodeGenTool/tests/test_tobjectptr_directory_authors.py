from __future__ import annotations

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
DEFAULT_NULL_RELATIVE = "Containers/TObjectPtr/DefaultConstructionIsNull.as"
DEFAULT_NULL_TAG = "Containers/TObjectPtr/DefaultConstructionIsNull"


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


class TObjectPtrDirectoryAuthorTests(unittest.TestCase):
    def test_DefaultNullParses(self) -> None:
        path = AUTHOR_ROOT / Path(*DEFAULT_NULL_RELATIVE.split("/"))
        self.assertTrue(path.is_file(), DEFAULT_NULL_RELATIVE)
        parsed = parse_source_file(
            make_source(DEFAULT_NULL_RELATIVE, path.read_bytes(), path)
        )
        self.assertEqual(DEFAULT_NULL_TAG, parsed.source.file_tag)
        self.assertEqual("v1", parsed.format_version)
        parentless = [version for version in parsed.versions if version.parent is None]
        self.assertEqual(1, len(parentless))
        self.assertEqual("DefaultConstructionIsNull", parentless[0].tag)

    def test_FlatObjectPtrAbsent(self) -> None:
        sources = discover_sources(AUTHOR_ROOT)
        tags = {source.file_tag.replace("\\", "/") for source in sources}
        self.assertNotIn("Containers/TObjectPtr", tags)
        self.assertIn(DEFAULT_NULL_TAG, tags)


if __name__ == "__main__":
    unittest.main()
