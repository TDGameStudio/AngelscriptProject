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
LOAD_ASYNC_RELATIVE = "Containers/TSoftObjectPtr/LoadAsyncInvokesHandler.as"
LOAD_ASYNC_TAG = "Containers/TSoftObjectPtr/LoadAsyncInvokesHandler"


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
    path = AUTHOR_ROOT / Path(*relative_path.split("/"))
    return parse_source_file(make_source(relative_path, path.read_bytes(), path))


class TSoftObjectPtrDirectoryAuthorTests(unittest.TestCase):
    def test_LoadAsyncParses(self) -> None:
        path = AUTHOR_ROOT / Path(*LOAD_ASYNC_RELATIVE.split("/"))
        self.assertTrue(path.is_file(), LOAD_ASYNC_RELATIVE)
        parsed = parse_author(LOAD_ASYNC_RELATIVE)
        self.assertEqual(LOAD_ASYNC_TAG, parsed.source.file_tag)
        self.assertEqual("v1", parsed.format_version)
        self.assertEqual(("Containers",), parsed.topics)
        self.assertEqual(1, len(parsed.versions))
        version = parsed.versions[0]
        self.assertEqual("LoadAsyncInvokesHandler", version.tag)
        self.assertIsNone(version.parent)
        clean = version.clean_source
        self.assertEqual(clean.count(b"{"), clean.count(b"}"), "LoadAsync must be a complete program")
        self.assertIn(b"UCLASS()", clean)
        self.assertIn(b"HandleObjectLoaded", clean)
        self.assertIn(b"LoadAsync(", clean)
        self.assertNotIn(b"@Kind", clean)

    def test_FlatSoftPtrAbsent(self) -> None:
        sources = discover_sources(AUTHOR_ROOT)
        file_tags = {source.file_tag.replace("\\", "/") for source in sources}
        self.assertNotIn("Containers/TSoftObjectPtr", file_tags)
        self.assertIn(LOAD_ASYNC_TAG, file_tags)


if __name__ == "__main__":
    unittest.main()
