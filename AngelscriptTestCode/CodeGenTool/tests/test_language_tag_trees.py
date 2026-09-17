from __future__ import annotations

import sys
import unittest
from pathlib import Path

TOOL_ROOT = Path(__file__).resolve().parents[1]
AUTHOR_ROOT = TOOL_ROOT.parent
sys.path.insert(0, str(TOOL_ROOT))

from angelscript_test_codegen.tag_tree import report_author_tag_trees


class LanguageTagTreeTests(unittest.TestCase):
    def test_every_language_author_lists_explained_tag_tree(self) -> None:
        diagnostics = report_author_tag_trees(AUTHOR_ROOT)
        self.assertEqual(
            (),
            tuple(f"{item.source_path}:{item.line}:{item.code}:{item.version_tag}" for item in diagnostics),
        )


if __name__ == "__main__":
    unittest.main()
