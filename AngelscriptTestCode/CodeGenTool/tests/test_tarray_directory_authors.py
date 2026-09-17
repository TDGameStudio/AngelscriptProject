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
TARRAY_TREE = AUTHOR_ROOT / "Containers" / "TArray"


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


def collect_tarray_version_tags() -> set[str]:
    tags: set[str] = set()
    if not TARRAY_TREE.is_dir():
        return tags
    for path in TARRAY_TREE.rglob("*.as"):
        relative = path.relative_to(AUTHOR_ROOT).as_posix()
        parsed = parse_author(relative)
        tags.update(version.tag for version in parsed.versions)
    return tags


class TArrayDirectoryAuthorTests(unittest.TestCase):
    def test_AddAndOrderParses(self) -> None:
        parsed = parse_author("Containers/TArray/AddAndOrder.as")
        self.assertEqual("Containers/TArray/AddAndOrder", parsed.source.file_tag)
        self.assertEqual("v1", parsed.format_version)
        parentless = [version for version in parsed.versions if version.parent is None]
        self.assertEqual(1, len(parentless))
        self.assertEqual("AddAndOrder", parentless[0].tag)
        self.assertIn(b"Values.Add", parentless[0].clean_source)

    def test_EmptyConstructionRenamed(self) -> None:
        tags = collect_tarray_version_tags()
        self.assertIn("EmptyConstruction", tags)
        self.assertNotIn("array", tags)

    def test_FlatTArrayAbsent(self) -> None:
        sources = discover_sources(AUTHOR_ROOT)
        file_tags = {source.file_tag.replace("\\", "/") for source in sources}
        self.assertNotIn("Containers/TArray", file_tags)
        self.assertIn("Containers/TArray/AddAndOrder", file_tags)

    def test_DiscoverySkipsPendingTArray(self) -> None:
        pending = AUTHOR_ROOT / "Pending" / "Containers" / "TArray" / "TArrayAddAndOrder.as"
        self.assertTrue(pending.is_file())
        sources = discover_sources(AUTHOR_ROOT)
        relative_paths = [source.relative_path.replace("\\", "/") for source in sources]
        self.assertNotIn("Pending/Containers/TArray/TArrayAddAndOrder.as", relative_paths)


if __name__ == "__main__":
    unittest.main()
