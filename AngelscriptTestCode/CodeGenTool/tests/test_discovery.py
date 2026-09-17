from __future__ import annotations

import sys
import tempfile
import unittest
from pathlib import Path

TOOL_ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(TOOL_ROOT))

from angelscript_test_codegen.discovery import _validate_unique_paths, discover_sources
from angelscript_test_codegen.model import CodegenError


class DiscoveryTests(unittest.TestCase):
    def test_discovers_as_in_ordinal_order_and_excludes_tool_subtree(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            author_root = Path(directory)
            fixtures = {
                "Reload/Actor.as": b"reload",
                "Language/Counter.as": b"counter",
                "CodeGenTool/tests/fixtures/Hidden.as": b"hidden",
                "Language/Notes.txt": b"notes",
            }
            for relative_path, content in fixtures.items():
                path = author_root / Path(relative_path)
                path.parent.mkdir(parents=True, exist_ok=True)
                path.write_bytes(content)

            sources = discover_sources(author_root)

            self.assertEqual(
                ["Language/Counter.as", "Reload/Actor.as"],
                [source.relative_path for source in sources],
            )
            self.assertEqual(
                ["Language/Counter", "Reload/Actor"],
                [source.file_tag for source in sources],
            )
            self.assertEqual(b"counter", sources[0].content)
            self.assertEqual(
                ["Language/Counter.generated.cpp", "Reload/Actor.generated.cpp"],
                [source.output_relative_path for source in sources],
            )

    def test_duplicate_generated_basenames_are_uniquified(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            author_root = Path(directory)
            for relative_path in (
                "Language/Syntax/Enum.as",
                "Language/Namespace/Enum.as",
            ):
                path = author_root / Path(relative_path)
                path.parent.mkdir(parents=True, exist_ok=True)
                path.write_bytes(b"enum")

            sources = discover_sources(author_root)
            self.assertEqual(
                ["Language/Namespace/Enum", "Language/Syntax/Enum"],
                [source.file_tag for source in sources],
            )
            self.assertEqual(
                [
                    "Language/Namespace/Language_Namespace_Enum.generated.cpp",
                    "Language/Syntax/Language_Syntax_Enum.generated.cpp",
                ],
                [source.output_relative_path for source in sources],
            )

    def test_case_fold_collision_is_rejected_with_both_paths(self) -> None:
        with self.assertRaises(CodegenError) as raised:
            _validate_unique_paths(["Folder/Case.as", "folder/case.as"])

        message = str(raised.exception)
        self.assertIn("Folder/Case.as", message)
        self.assertIn("folder/case.as", message)


if __name__ == "__main__":
    unittest.main()
