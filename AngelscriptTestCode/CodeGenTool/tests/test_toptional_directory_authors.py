from __future__ import annotations

import sys
import unittest
from pathlib import Path

TOOL_ROOT = Path(__file__).resolve().parents[1]
AUTHOR_ROOT = TOOL_ROOT.parent
sys.path.insert(0, str(TOOL_ROOT))

from angelscript_test_codegen.container_parser import parse_source_file
from angelscript_test_codegen.discovery import discover_sources


class TOptionalDirectoryAuthorsTests(unittest.TestCase):
    def test_StoredZeroIsSetParses(self) -> None:
        sources = discover_sources(AUTHOR_ROOT)
        by_tag = {source.file_tag: source for source in sources}
        self.assertIn("Containers/TOptional/StoredZeroIsSet", by_tag)

        parsed = parse_source_file(by_tag["Containers/TOptional/StoredZeroIsSet"])

        self.assertEqual("Containers/TOptional/StoredZeroIsSet", parsed.source.file_tag)
        self.assertEqual("v1", parsed.format_version)
        self.assertEqual(1, len(parsed.versions))
        version = parsed.versions[0]
        self.assertEqual("StoredZeroIsSet", version.tag)
        self.assertIsNone(version.parent)
        clean = version.clean_source
        self.assertIn(b"TOptional<int32>", clean)
        self.assertIn(b"Set(0)", clean)
        self.assertIn(b"IsSet", clean)

    def test_FlatTOptionalAbsent(self) -> None:
        tags = {source.file_tag for source in discover_sources(AUTHOR_ROOT)}
        self.assertNotIn("Containers/TOptional", tags)


if __name__ == "__main__":
    unittest.main()
