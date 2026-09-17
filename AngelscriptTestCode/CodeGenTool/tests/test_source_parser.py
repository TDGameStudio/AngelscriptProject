from __future__ import annotations

import hashlib
import sys
import tempfile
import unittest
from pathlib import Path

TOOL_ROOT = Path(__file__).resolve().parents[1]
REPO_ROOT = TOOL_ROOT.parents[1]
sys.path.insert(0, str(TOOL_ROOT))

from angelscript_test_codegen.container_parser import parse_source_file
from angelscript_test_codegen.discovery import discover_sources
from angelscript_test_codegen.model import CodegenError, SourceInput


def make_source(
    relative_path: str,
    content: bytes,
    *,
    full_path: Path | None = None,
) -> SourceInput:
    file_tag = relative_path[: -len(".as")] if relative_path.endswith(".as") else relative_path
    return SourceInput(
        full_path=full_path or Path(relative_path),
        relative_path=relative_path,
        file_tag=file_tag,
        output_relative_path=f"{file_tag}.generated.cpp",
        content=content,
        content_sha256=hashlib.sha256(content).hexdigest(),
        symbol_suffix=hashlib.sha256(file_tag.encode("utf-8")).hexdigest()[:12],
    )


def diagnostic_codes(error: CodegenError) -> list[str]:
    return [diagnostic.code for diagnostic in error.diagnostics]


class SourceParserTests(unittest.TestCase):
    def test_counter_metadata_and_branch(self) -> None:
        authored = (
            TOOL_ROOT / "tests" / "fixtures" / "parser" / "Language" / "Counter.as"
        )
        content = authored.read_bytes()
        parsed = parse_source_file(make_source("Language/Counter.as", content, full_path=authored))

        self.assertEqual("Language/Counter", parsed.source.file_tag)
        self.assertEqual("v1", parsed.format_version)
        self.assertEqual("Counter source variants.", parsed.summary)
        self.assertEqual(("Language", "Reload"), parsed.topics)
        self.assertEqual(("root", "add-step"), tuple(version.tag for version in parsed.versions))

        root, child = parsed.versions
        self.assertIsNone(root.parent)
        self.assertEqual("Define the initial counter.", root.summary)
        self.assertEqual(("Baseline",), root.topics)
        self.assertEqual(
            b"class Counter\n{\n    int Value = /** @point initial-value */0;\n}\n",
            root.body,
        )
        self.assertEqual(b"class Counter\n{\n    int Value = 0;\n}\n", root.clean_source)
        self.assertTrue(root.body.endswith(b"\n"))
        self.assertEqual("root", child.parent)
        self.assertEqual("Add a configurable counter step.", child.summary)
        self.assertEqual(("Fields", "Reload"), child.topics)
        self.assertEqual(
            b"class Counter\n{\n    int Value = 0;\n"
            b"    /** @breakpoint before-add */int Step = "
            b"/** @range-begin delta */1/** @range-end delta */;\n}\n",
            child.body,
        )
        self.assertEqual(
            b"class Counter\n{\n    int Value = 0;\n    int Step = 1;\n}\n",
            child.clean_source,
        )
        self.assertTrue(child.body.endswith(b"\n"))

        root_body_offset = content.index(root.body)
        child_body_offset = content.index(child.body)
        self.assertEqual(root_body_offset, root.authored_body_offset)
        self.assertEqual(child_body_offset, child.authored_body_offset)
        self.assertEqual(content.count(b"\n", 0, root_body_offset) + 1, root.authored_body_line)
        self.assertEqual(content.count(b"\n", 0, child_body_offset) + 1, child.authored_body_line)

    def test_invalid_angelscript_remains_material(self) -> None:
        body = b"int Value = Missing;\n"
        content = (
            b"/**\n"
            b" * @version v1\n"
            b" * @summary Negative language remains material.\n"
            b" */\n"
            b"/**\n"
            b" * @version root\n"
            b" * @summary Keep the invalid assignment.\n"
            b" */\n"
            + body
            + b"/** @end */\n"
        )
        parsed = parse_source_file(make_source("Language/Missing.as", content))
        self.assertEqual(1, len(parsed.versions))
        self.assertEqual(body, parsed.versions[0].body)

    def test_transport_normalization(self) -> None:
        body = "string Label = \"α\";\n".encode("utf-8")
        content = (
            b"\xef\xbb\xbf"
            b"/**\r\n"
            b" * @version v1\r\n"
            b" * @summary File uses mixed endings.\r\n"
            b" */\r\n"
            b"/**\r"
            b" * @version root\r"
            b" * @summary Unicode body text.\r"
            b" */\r"
            + body.replace(b"\n", b"\r")
            + b"/** @end */\r"
        )
        parsed = parse_source_file(make_source("Language/Transport.as", content))
        self.assertEqual("v1", parsed.format_version)
        self.assertEqual("File uses mixed endings.", parsed.summary)
        self.assertEqual("Unicode body text.", parsed.versions[0].summary)
        self.assertEqual(body, parsed.versions[0].body)
        self.assertEqual(9, parsed.versions[0].authored_body_line)
        self.assertEqual(123, parsed.versions[0].authored_body_offset)

    def test_independent_metadata_failures_accumulate(self) -> None:
        content = (
            b"/**\n"
            b" * @version v1\n"
            b" * @summary Independent metadata failures.\n"
            b" */\n"
            b"/**\n"
            b" * @version child\n"
            b" * @parent child\n"
            b" * @summary\n"
            b" */\n"
            b"int First;\n"
            b"/** @end */\n"
            b"/**\n"
            b" * @version child\n"
            b" * @parent child\n"
            b" * @summary Duplicate tag.\n"
            b" */\n"
            b"int Second;\n"
            b"/** @end */\n"
        )
        with self.assertRaises(CodegenError) as raised:
            parse_source_file(make_source("Language/Broken.as", content))

        codes = diagnostic_codes(raised.exception)
        self.assertIn("EmptyVersionSummary", codes)
        self.assertIn("DuplicateVersionTag", codes)
        self.assertNotIn("VersionCycle", codes)

    def test_topology_is_checked_as_a_complete_set(self) -> None:
        forward_parent = (
            b"/**\n"
            b" * @version v1\n"
            b" * @summary Forward parent is valid.\n"
            b" */\n"
            b"/**\n"
            b" * @version child\n"
            b" * @parent root\n"
            b" * @summary Declared before its parent.\n"
            b" */\n"
            b"int Child;\n"
            b"/** @end */\n"
            b"/**\n"
            b" * @version root\n"
            b" * @summary The later root.\n"
            b" */\n"
            b"int Root;\n"
            b"/** @end */\n"
        )
        parsed = parse_source_file(make_source("Language/Forward.as", forward_parent))
        self.assertEqual(("child", "root"), tuple(version.tag for version in parsed.versions))
        self.assertEqual("root", parsed.versions[0].parent)

        missing_parent = (
            b"/**\n"
            b" * @version v1\n"
            b" * @summary Missing parent.\n"
            b" */\n"
            b"/**\n"
            b" * @version root\n"
            b" * @summary Root version.\n"
            b" */\n"
            b"int Root;\n"
            b"/** @end */\n"
            b"/**\n"
            b" * @version child\n"
            b" * @parent absent\n"
            b" * @summary Names no declared parent.\n"
            b" */\n"
            b"int Child;\n"
            b"/** @end */\n"
        )
        with self.assertRaises(CodegenError) as raised_missing:
            parse_source_file(make_source("Language/MissingParent.as", missing_parent))
        self.assertIn("MissingParent", diagnostic_codes(raised_missing.exception))

        cycle = (
            b"/**\n"
            b" * @version v1\n"
            b" * @summary Cycle.\n"
            b" */\n"
            b"/**\n"
            b" * @version left\n"
            b" * @parent right\n"
            b" * @summary Left.\n"
            b" */\n"
            b"int Left;\n"
            b"/** @end */\n"
            b"/**\n"
            b" * @version right\n"
            b" * @parent left\n"
            b" * @summary Right.\n"
            b" */\n"
            b"int Right;\n"
            b"/** @end */\n"
        )
        with self.assertRaises(CodegenError) as raised_cycle:
            parse_source_file(make_source("Language/Cycle.as", cycle))
        self.assertIn("VersionCycle", diagnostic_codes(raised_cycle.exception))

        missing_root = (
            b"/**\n"
            b" * @version v1\n"
            b" * @summary No root.\n"
            b" */\n"
            b"/**\n"
            b" * @version child\n"
            b" * @parent root\n"
            b" * @summary Not a root.\n"
            b" */\n"
            b"int Child;\n"
            b"/** @end */\n"
        )
        with self.assertRaises(CodegenError) as raised_missing_root:
            parse_source_file(make_source("Language/NoRoot.as", missing_root))
        self.assertIn("MissingRoot", diagnostic_codes(raised_missing_root.exception))

        multiple_roots = (
            b"/**\n"
            b" * @version v1\n"
            b" * @summary Two roots.\n"
            b" */\n"
            b"/**\n"
            b" * @version root\n"
            b" * @summary First root.\n"
            b" */\n"
            b"int First;\n"
            b"/** @end */\n"
            b"/**\n"
            b" * @version root\n"
            b" * @summary Second root.\n"
            b" */\n"
            b"int Second;\n"
            b"/** @end */\n"
        )
        with self.assertRaises(CodegenError) as raised_multiple:
            parse_source_file(make_source("Language/TwoRoots.as", multiple_roots))
        self.assertIn("MultipleRoots", diagnostic_codes(raised_multiple.exception))

    def test_discovery_identity_remains_path_owned(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            author_root = Path(directory)
            counter = author_root / "Language" / "Counter.as"
            counter.parent.mkdir(parents=True)
            counter.write_bytes(
                (TOOL_ROOT / "tests" / "fixtures" / "parser" / "Language" / "Counter.as").read_bytes()
            )

            sources = discover_sources(author_root)

            self.assertEqual(["Language/Counter.as"], [source.relative_path for source in sources])
            self.assertEqual(["Language/Counter"], [source.file_tag for source in sources])
            self.assertEqual(
                ["Language/Counter.generated.cpp"],
                [source.output_relative_path for source in sources],
            )


if __name__ == "__main__":
    unittest.main()
