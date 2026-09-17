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
CONTAINS_KEY = AUTHOR_ROOT / "Containers" / "TMap" / "ContainsKey.as"
TMAP_TREE = AUTHOR_ROOT / "Containers" / "TMap"


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


def parse_relative(relative_path: str):
    path = AUTHOR_ROOT / Path(relative_path)
    return parse_source_file(make_source(relative_path, path.read_bytes(), path))


def collect_tmap_version_tags() -> set[str]:
    tags: set[str] = set()
    if TMAP_TREE.is_dir():
        for path in sorted(TMAP_TREE.rglob("*.as")):
            relative = path.relative_to(AUTHOR_ROOT).as_posix()
            parsed = parse_source_file(make_source(relative, path.read_bytes(), path))
            tags.update(version.tag for version in parsed.versions)
    for source in discover_sources(AUTHOR_ROOT):
        if source.file_tag == "Containers/TMap" or source.file_tag.startswith("Containers/TMap/"):
            parsed = parse_source_file(source)
            tags.update(version.tag for version in parsed.versions)
    return tags


class TMapDirectoryAuthorTests(unittest.TestCase):
    def test_ContainsKeyParses(self) -> None:
        parsed = parse_relative("Containers/TMap/ContainsKey.as")
        self.assertEqual("Containers/TMap/ContainsKey", parsed.source.file_tag)
        matches = [version for version in parsed.versions if version.tag == "ContainsKey"]
        self.assertEqual(1, len(matches))
        self.assertIsNone(matches[0].parent)

    def test_DumpTagAbsent(self) -> None:
        tags = collect_tmap_version_tags()
        self.assertNotIn("contains-contains", tags)

    def test_FlatTMapAbsent(self) -> None:
        sources = discover_sources(AUTHOR_ROOT)
        file_tags = [source.file_tag for source in sources]
        self.assertNotIn("Containers/TMap", file_tags)
        self.assertIn("Containers/TMap/ContainsKey", file_tags)


if __name__ == "__main__":
    unittest.main()
