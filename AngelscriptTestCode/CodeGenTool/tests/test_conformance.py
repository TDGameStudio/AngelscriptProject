from __future__ import annotations

import hashlib
import sys
import unittest
from pathlib import Path

TOOL_ROOT = Path(__file__).resolve().parents[1]
FIXTURE_ROOT = Path(__file__).resolve().parent / "fixtures" / "conformance"
sys.path.insert(0, str(TOOL_ROOT))

from angelscript_test_codegen.container_parser import parse_source_file
from angelscript_test_codegen.model import CodegenError, SourceInput


def load_fixture(name: str) -> SourceInput:
    path = FIXTURE_ROOT / name
    content = path.read_bytes()
    file_tag = f"conformance/{path.stem}"
    return SourceInput(
        full_path=path,
        relative_path=f"conformance/{name}",
        file_tag=file_tag,
        output_relative_path=f"{file_tag}.generated.cpp",
        content=content,
        content_sha256=hashlib.sha256(content).hexdigest(),
        symbol_suffix="",
    )


def map_clean(version, clean_offset: int) -> int:
    if clean_offset == len(version.clean_source):
        return version.authored_end
    for span in version.origin_spans:
        if span.clean_begin <= clean_offset < span.clean_begin + span.length:
            return span.authored_begin + (clean_offset - span.clean_begin)
    raise AssertionError(f"clean offset {clean_offset} is not covered")


def primary_diagnostic(error: CodegenError, code: str):
    for diagnostic in error.diagnostics:
        if diagnostic.code == code:
            return diagnostic
    raise AssertionError(f"{code} not present in {[item.code for item in error.diagnostics]}")


class ConformanceTests(unittest.TestCase):
    def test_positive_protocol_matrix(self) -> None:
        cases = (
            self._check_bom_crlf,
            self._check_unicode,
            self._check_annotations,
            self._check_branch_trailing_lf,
            self._check_parentless_begin,
        )
        for check in cases:
            with self.subTest(check.__name__):
                check()

    def _check_bom_crlf(self) -> None:
        parsed = parse_source_file(load_fixture("bom-crlf.as"))
        self.assertEqual("v1", parsed.format_version)
        self.assertEqual("conformance/bom-crlf", parsed.source.file_tag)
        self.assertEqual("BOM and CRLF container.", parsed.summary)
        self.assertEqual((), parsed.topics)
        self.assertEqual(1, len(parsed.versions))
        root = parsed.versions[0]
        self.assertEqual("root", root.tag)
        self.assertIsNone(root.parent)
        self.assertEqual("Root body.", root.summary)
        self.assertEqual(b"int X = 1;\n", root.clean_source)
        self.assertEqual(9, root.authored_body_line)
        self.assertEqual(118, root.authored_body_offset)
        self.assertEqual(130, root.authored_end)
        self.assertEqual(
            [118, 119, 120, 121, 122, 123, 124, 125, 126, 127, 128, 130],
            [map_clean(root, offset) for offset in range(len(root.clean_source) + 1)],
        )

    def _check_unicode(self) -> None:
        parsed = parse_source_file(load_fixture("unicode.as"))
        root = parsed.versions[0]
        self.assertEqual("Unicode positions.", parsed.summary)
        self.assertEqual('string S = "αβ";\n'.encode("utf-8"), root.clean_source)
        self.assertEqual(1, len(root.annotations.points))
        self.assertEqual("after-alpha", root.annotations.points[0].name)
        self.assertEqual(14, root.annotations.points[0].offset)
        self.assertEqual([206, 177], list(root.clean_source[12:14]))
        self.assertEqual([206, 178], list(root.clean_source[14:16]))
        self.assertEqual(109, map_clean(root, 12))
        self.assertEqual(110, map_clean(root, 13))
        self.assertEqual(136, map_clean(root, 14))
        self.assertEqual(141, map_clean(root, len(root.clean_source)))

    def _check_annotations(self) -> None:
        parsed = parse_source_file(load_fixture("annotations.as"))
        root = parsed.versions[0]
        self.assertEqual(b"abxy/** @point literal */\n", root.clean_source)
        self.assertEqual(("site", 1), (root.annotations.points[0].name, root.annotations.points[0].offset))
        self.assertEqual(
            ("site", 2),
            (root.annotations.breakpoints[0].name, root.annotations.breakpoints[0].offset),
        )
        ranges = {item.name: (item.begin, item.end) for item in root.annotations.ranges}
        self.assertEqual((2, 3), ranges["inner"])
        self.assertEqual((2, 4), ranges["outer"])
        self.assertEqual(("inner", "outer"), tuple(item.name for item in root.annotations.ranges))
        self.assertNotIn(b"/** @point site", root.clean_source)
        self.assertIn(b"/** @point literal */", root.clean_source)
        self.assertEqual(97, map_clean(root, 0))
        self.assertEqual(261, map_clean(root, len(root.clean_source)))

    def _check_branch_trailing_lf(self) -> None:
        parsed = parse_source_file(load_fixture("branch-trailing-lf.as"))
        self.assertEqual(("child", "root"), tuple(version.tag for version in parsed.versions))
        child, root = parsed.versions
        self.assertEqual("root", child.parent)
        self.assertEqual(b"class Child {}\n", child.clean_source)
        self.assertEqual(b"class Root {}\n", root.clean_source)
        self.assertTrue(child.clean_source.endswith(b"\n"))
        self.assertTrue(root.clean_source.endswith(b"\n"))
        self.assertEqual(149, map_clean(child, len(child.clean_source)))
        self.assertEqual(225, map_clean(root, len(root.clean_source)))

    def _check_parentless_begin(self) -> None:
        parsed = parse_source_file(load_fixture("parentless-begin.as"))
        self.assertEqual("v1", parsed.format_version)
        self.assertEqual("conformance/parentless-begin", parsed.source.file_tag)
        self.assertEqual("Two parentless begin cases.", parsed.summary)
        self.assertEqual(("Language",), parsed.topics)
        self.assertEqual(("alpha", "beta"), tuple(version.tag for version in parsed.versions))
        alpha, beta = parsed.versions
        self.assertIsNone(alpha.parent)
        self.assertIsNone(beta.parent)
        self.assertIn(b"@function AlphaValue", alpha.body)
        self.assertEqual(b"int Beta = 2;\n", beta.clean_source)
        ranges = {item.name: (item.begin, item.end) for item in alpha.annotations.ranges}
        self.assertIn("alpha-const", ranges)
        self.assertEqual(1, ranges["alpha-const"][1] - ranges["alpha-const"][0])
        self.assertEqual(b"1", alpha.clean_source[ranges["alpha-const"][0]:ranges["alpha-const"][1]])

    def test_negative_protocol_matrix(self) -> None:
        rows = (
            ("unknown-directive.as", "UnknownMetadataDirective", 4, 53),
            ("missing-summary.as", "MissingFileSummary", 1, 0),
            ("duplicate-version.as", "DuplicateVersionTag", 17, 216),
            ("missing-parent.as", "MissingParent", 10, 122),
            ("cycle.as", "VersionCycle", 1, 0),
            ("duplicate-point.as", "DuplicatePoint", 9, 110),
            ("missing-range-end.as", "MissingRangeEnd", 9, 120),
            ("crossing-range.as", "CrossingRange", 9, 137),
        )
        for name, code, line, byte_offset in rows:
            with self.subTest(name):
                with self.assertRaises(CodegenError) as raised:
                    parse_source_file(load_fixture(name))
                diagnostic = primary_diagnostic(raised.exception, code)
                self.assertEqual(line, diagnostic.line)
                self.assertEqual(byte_offset, diagnostic.byte_offset)

    def test_message_prose_is_not_the_oracle(self) -> None:
        with self.assertRaises(CodegenError) as raised:
            parse_source_file(load_fixture("unknown-directive.as"))
        diagnostic = primary_diagnostic(raised.exception, "UnknownMetadataDirective")
        self.assertEqual(4, diagnostic.line)
        self.assertEqual(53, diagnostic.byte_offset)
        self.assertTrue(diagnostic.message)
        self.assertNotEqual("UnknownMetadataDirective", diagnostic.message)


if __name__ == "__main__":
    unittest.main()
