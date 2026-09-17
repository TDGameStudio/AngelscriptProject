from __future__ import annotations

import hashlib
import sys
import unittest
from pathlib import Path

TOOL_ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(TOOL_ROOT))

from angelscript_test_codegen.annotation_parser import parse_annotations
from angelscript_test_codegen.container_parser import parse_source_file
from angelscript_test_codegen.model import (
    CodegenError,
    ParsedVersion,
    SourceInput,
)


def make_source(relative_path: str, content: bytes) -> SourceInput:
    file_tag = relative_path[: -len(".as")]
    return SourceInput(
        full_path=Path(relative_path),
        relative_path=relative_path,
        file_tag=file_tag,
        output_relative_path=f"{file_tag}.generated.cpp",
        content=content,
        content_sha256=hashlib.sha256(content).hexdigest(),
        symbol_suffix=hashlib.sha256(file_tag.encode("utf-8")).hexdigest()[:12],
    )


def version_with_body(body: bytes, authored_begin: int = 0) -> ParsedVersion:
    return ParsedVersion(
        tag="root",
        parent=None,
        summary="Annotated body.",
        topics=(),
        body=body,
        authored_body_line=1,
        authored_body_offset=authored_begin,
        authored_offsets=tuple(range(authored_begin, authored_begin + len(body) + 1)),
    )


def diagnostic_codes(error: CodegenError) -> list[str]:
    return [diagnostic.code for diagnostic in error.diagnostics]


def map_clean(version: ParsedVersion, clean_offset: int) -> int:
    if clean_offset == len(version.clean_source):
        return version.authored_end
    for span in version.origin_spans:
        if span.clean_begin <= clean_offset < span.clean_begin + span.length:
            return span.authored_begin + (clean_offset - span.clean_begin)
    raise AssertionError(f"clean offset {clean_offset} is not covered by origin spans")


class AnnotationParserTests(unittest.TestCase):
    def test_typed_clean_byte_coordinates(self) -> None:
        body = (
            b"a" * 32
            + b"/** @point initial-value */"
            + b"b" * 34
            + b"/** @breakpoint before-add */"
            + b"c" * 9
            + b"/** @range-begin delta */1/** @range-end delta */"
        )
        parsed = parse_annotations(version_with_body(body))
        self.assertEqual(b"a" * 32 + b"b" * 34 + b"c" * 9 + b"1", parsed.clean_source)
        self.assertNotIn(b"/** @", parsed.clean_source)
        self.assertEqual(1, len(parsed.annotations.points))
        self.assertEqual("initial-value", parsed.annotations.points[0].name)
        self.assertEqual(32, parsed.annotations.points[0].offset)
        self.assertEqual(1, len(parsed.annotations.breakpoints))
        self.assertEqual("before-add", parsed.annotations.breakpoints[0].name)
        self.assertEqual(66, parsed.annotations.breakpoints[0].offset)
        self.assertEqual(1, len(parsed.annotations.ranges))
        self.assertEqual("delta", parsed.annotations.ranges[0].name)
        self.assertEqual(75, parsed.annotations.ranges[0].begin)
        self.assertEqual(76, parsed.annotations.ranges[0].end)

    def test_nested_ranges_and_cross_kind_names(self) -> None:
        body = (
            b"/** @range-begin outer */"
            b"x"
            b"/** @range-begin inner */"
            b"y"
            b"/** @range-end inner */"
            b"z"
            b"/** @range-end outer */"
            b"/** @point site */"
            b"/** @breakpoint site */"
        )
        parsed = parse_annotations(version_with_body(body))
        self.assertEqual(b"xyz", parsed.clean_source)
        by_name = {item.name: item for item in parsed.annotations.ranges}
        self.assertEqual({"outer", "inner"}, set(by_name))
        self.assertEqual((0, 3), (by_name["outer"].begin, by_name["outer"].end))
        self.assertEqual((1, 2), (by_name["inner"].begin, by_name["inner"].end))
        self.assertEqual("site", parsed.annotations.points[0].name)
        self.assertEqual(3, parsed.annotations.points[0].offset)
        self.assertEqual("site", parsed.annotations.breakpoints[0].name)
        self.assertEqual(3, parsed.annotations.breakpoints[0].offset)

    def test_escaped_marker_remains_source(self) -> None:
        parsed = parse_annotations(version_with_body(b"/** @@point cursor */"))
        self.assertEqual(b"/** @point cursor */", parsed.clean_source)
        self.assertEqual((), parsed.annotations.points)

    def test_malformed_annotation_set_fails_structurally(self) -> None:
        with self.assertRaises(CodegenError) as duplicate:
            parse_annotations(version_with_body(b"/** @point p *//** @point p */"))
        self.assertIn("DuplicatePoint", diagnostic_codes(duplicate.exception))

        with self.assertRaises(CodegenError) as missing_begin:
            parse_annotations(version_with_body(b"/** @range-end r */"))
        self.assertIn("MissingRangeBegin", diagnostic_codes(missing_begin.exception))

        with self.assertRaises(CodegenError) as missing_end:
            parse_annotations(version_with_body(b"/** @range-begin r */"))
        self.assertIn("MissingRangeEnd", diagnostic_codes(missing_end.exception))

        with self.assertRaises(CodegenError) as crossing:
            parse_annotations(
                version_with_body(
                    b"/** @range-begin a */x/** @range-begin b */y/** @range-end a */z/** @range-end b */"
                )
            )
        self.assertIn("CrossingRange", diagnostic_codes(crossing.exception))

    def test_terminal_removed_marker_preserves_eof(self) -> None:
        body = b"ab/** @point eof */"
        parsed = parse_annotations(version_with_body(body, authored_begin=21))
        self.assertEqual(b"ab", parsed.clean_source)
        self.assertEqual("eof", parsed.annotations.points[0].name)
        self.assertEqual(2, parsed.annotations.points[0].offset)
        self.assertEqual(40, parsed.authored_end)
        self.assertEqual(21, map_clean(parsed, 0))
        self.assertEqual(22, map_clean(parsed, 1))
        self.assertEqual(40, map_clean(parsed, 2))
        last_span = parsed.origin_spans[-1]
        self.assertNotEqual(last_span.authored_begin + last_span.length, parsed.authored_end)

    def test_newline_discontinuities_retain_original_bytes(self) -> None:
        body_text = "α/** @point mark */β\n"
        content = (
            b"\xef\xbb\xbf"
            b"/**\r\n"
            b" * @version v1\r\n"
            b" * @summary Transport annotations.\r\n"
            b" */\r\n"
            b"/**\r\n"
            b" * @version root\r\n"
            b" * @summary Root.\r\n"
            b" */\r\n"
            + body_text.encode("utf-8").replace(b"\n", b"\r\n")
            + b"/** @end */\r\n"
        )
        parsed_file = parse_source_file(make_source("Language/AnnoTransport.as", content))
        parsed = parse_annotations(parsed_file.versions[0])
        self.assertEqual("αβ\n".encode("utf-8"), parsed.clean_source)
        self.assertEqual(2, parsed.annotations.points[0].offset)
        raw_len = len(content)
        for clean_offset in range(len(parsed.clean_source) + 1):
            authored = map_clean(parsed, clean_offset)
            self.assertGreaterEqual(authored, 0)
            self.assertLessEqual(authored, raw_len)


if __name__ == "__main__":
    unittest.main()
