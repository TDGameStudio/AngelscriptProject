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
STALE_TAG = "Containers/TWeakObjectPtr/InvalidatedIsStaleNotExplicitlyNull"


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


class TWeakObjectPtrDirectoryAuthorTests(unittest.TestCase):
    def test_StaleAfterGcParses(self) -> None:
        path = AUTHOR_ROOT / f"{STALE_TAG}.as"
        self.assertTrue(path.is_file(), f"missing {path.as_posix()}")
        parsed = parse_source_file(make_source(f"{STALE_TAG}.as", path.read_bytes(), path))
        self.assertEqual(STALE_TAG, parsed.source.file_tag)
        self.assertEqual("v1", parsed.format_version)
        parentless = [version for version in parsed.versions if version.parent is None]
        self.assertEqual(1, len(parentless))
        self.assertEqual("InvalidatedIsStaleNotExplicitlyNull", parentless[0].tag)
        self.assertIn(b"IsStale", parentless[0].clean_source)

    def test_FlatWeakAbsent(self) -> None:
        file_tags = [
            source.file_tag.replace("\\", "/") for source in discover_sources(AUTHOR_ROOT)
        ]
        self.assertNotIn("Containers/TWeakObjectPtr", file_tags)


if __name__ == "__main__":
    unittest.main()
