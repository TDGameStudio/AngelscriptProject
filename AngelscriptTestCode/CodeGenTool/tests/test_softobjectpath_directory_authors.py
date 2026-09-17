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
CLASS_PATH_IS_VALID_RELATIVE = "Containers/SoftObjectPath/ClassPathIsValid.as"
CLASS_PATH_IS_VALID_TAG = "Containers/SoftObjectPath/ClassPathIsValid"


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


class SoftObjectPathDirectoryAuthorTests(unittest.TestCase):
    def test_ClassPathIsValidParses(self) -> None:
        path = AUTHOR_ROOT / Path(*CLASS_PATH_IS_VALID_RELATIVE.split("/"))
        self.assertTrue(path.is_file(), CLASS_PATH_IS_VALID_RELATIVE)
        parsed = parse_source_file(
            make_source(CLASS_PATH_IS_VALID_RELATIVE, path.read_bytes(), path)
        )
        self.assertEqual(CLASS_PATH_IS_VALID_TAG, parsed.source.file_tag)
        tags = {version.tag for version in parsed.versions}
        self.assertNotIn("Queries_02-is-valid", tags)
        parentless = [version for version in parsed.versions if version.parent is None]
        self.assertEqual(1, len(parentless))
        self.assertEqual("ClassPathIsValid", parentless[0].tag)

    def test_FlatPathAbsent(self) -> None:
        sources = discover_sources(AUTHOR_ROOT)
        file_tags = {source.file_tag.replace("\\", "/") for source in sources}
        self.assertNotIn("Containers/SoftObjectPath", file_tags)


if __name__ == "__main__":
    unittest.main()
