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
DERIVED_RELATIVE = "Containers/TSubclassOf/AssignDerivedClassIntoBaseHolder.as"
DERIVED_TAG = "Containers/TSubclassOf/AssignDerivedClassIntoBaseHolder"


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


class TSubclassOfDirectoryAuthorTests(unittest.TestCase):
    def test_DerivedIntoBaseParses(self) -> None:
        path = AUTHOR_ROOT / Path(*DERIVED_RELATIVE.split("/"))
        self.assertTrue(path.is_file(), DERIVED_RELATIVE)
        parsed = parse_source_file(
            make_source(DERIVED_RELATIVE, path.read_bytes(), path)
        )
        self.assertEqual(DERIVED_TAG, parsed.source.file_tag)
        self.assertEqual("v1", parsed.format_version)
        versions = [
            version
            for version in parsed.versions
            if version.tag == "AssignDerivedClassIntoBaseHolder"
        ]
        self.assertEqual(1, len(versions))
        self.assertIsNone(versions[0].parent)

    def test_FlatSubclassAbsent(self) -> None:
        sources = discover_sources(AUTHOR_ROOT)
        tags = {source.file_tag for source in sources}
        self.assertNotIn("Containers/TSubclassOf", tags)


if __name__ == "__main__":
    unittest.main()
