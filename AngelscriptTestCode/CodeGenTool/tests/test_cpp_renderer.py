from __future__ import annotations

import hashlib
import sys
import unittest
from pathlib import Path

TOOL_ROOT = Path(__file__).resolve().parents[1]
REPO_ROOT = TOOL_ROOT.parents[1]
sys.path.insert(0, str(TOOL_ROOT))

from angelscript_test_codegen.container_parser import parse_source_file
from angelscript_test_codegen.cpp_renderer import (
    GENERATOR_SIGNATURE,
    plan_registration_symbols,
    render_projection,
)
from angelscript_test_codegen.model import CodegenError, SourceInput


FIXTURE_ROOT = TOOL_ROOT / "tests" / "fixtures" / "renderer"


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


def parse_relative(relative_path: str, content: bytes):
    return parse_source_file(make_source(relative_path, content))


def extract_raw_literals(text: str) -> list[bytes]:
    literals: list[bytes] = []
    token = 'AS_TEST_SOURCE(R"'
    cursor = 0
    while True:
        start = text.find(token, cursor)
        if start < 0:
            return literals
        delimiter_begin = start + len(token)
        paren = text.find("(", delimiter_begin)
        delimiter = text[delimiter_begin:paren]
        closer = ")" + delimiter + '"'
        body_begin = paren + 1
        body_end = text.find(closer, body_begin)
        literals.append(text[body_begin:body_end].encode("utf-8"))
        cursor = body_end + len(closer)


def normalize_as_test_source(literal: bytes) -> bytes:
    def linebreak(index: int) -> int:
        if index >= len(literal):
            return 0
        if literal[index] == 0x0D:
            return 2 if index + 1 < len(literal) and literal[index + 1] == 0x0A else 1
        return 1 if literal[index] == 0x0A else 0

    def is_hws(byte: int) -> bool:
        return byte in (0x20, 0x09)

    begin = 0
    end = len(literal)
    first_end = 0
    while first_end < end and linebreak(first_end) == 0:
        first_end += 1
    opening = linebreak(first_end)
    removed_opening = opening > 0 and all(is_hws(literal[index]) for index in range(first_end))
    if removed_opening:
        begin = first_end + opening

    last_break = -1
    last_start = begin
    index = begin
    while index < end:
        length = linebreak(index)
        if length == 0:
            index += 1
            continue
        last_break = index
        index += length
        last_start = index
    if last_break >= 0 and all(is_hws(literal[pos]) for pos in range(last_start, end)):
        end = last_break
    elif removed_opening and all(is_hws(literal[pos]) for pos in range(begin, end)):
        end = begin

    prefix_start = -1
    prefix_length = 0
    found_content = False
    line_start = begin
    while line_start <= end:
        line_end = line_start
        while line_end < end and linebreak(line_end) == 0:
            line_end += 1
        indent = 0
        while line_start + indent < line_end and is_hws(literal[line_start + indent]):
            indent += 1
        if line_start + indent < line_end:
            if not found_content:
                prefix_start = line_start
                prefix_length = indent
                found_content = True
            else:
                prefix_length = min(prefix_length, indent)
                match = 0
                while (
                    match < prefix_length
                    and literal[prefix_start + match] == literal[line_start + match]
                ):
                    match += 1
                prefix_length = match
        if line_end >= end:
            break
        line_start = line_end + linebreak(line_end)

    output = bytearray()
    line_start = begin
    while line_start < end:
        line_end = line_start
        while line_end < end and linebreak(line_end) == 0:
            line_end += 1
        has_prefix = prefix_length == 0 or (
            line_end - line_start >= prefix_length
            and literal[line_start : line_start + prefix_length]
            == literal[prefix_start : prefix_start + prefix_length]
        )
        content_start = line_start + prefix_length if has_prefix else line_start
        output.extend(literal[content_start:line_end])
        break_length = linebreak(line_end)
        output.extend(literal[line_end : line_end + break_length])
        line_start = line_end + break_length
    return bytes(output)


class CppRendererTests(unittest.TestCase):
    def test_counter_readable_golden(self) -> None:
        authored = (FIXTURE_ROOT / "Language" / "Counter.as").read_bytes()
        expected = (FIXTURE_ROOT / "Language" / "Counter.generated.cpp").read_bytes()
        rendered = render_projection(parse_relative("Language/Counter.as", authored))
        self.assertEqual(expected, rendered)

    def test_annotations_and_origin_are_typed(self) -> None:
        content = (
            b"/**\n"
            b" * @version v1\n"
            b" * @summary Annotated counter.\n"
            b" */\n"
            b"/**\n"
            b" * @version root\n"
            b" * @summary Root.\n"
            b" */\n"
            + (
                b"a" * 32
                + b"/** @point initial-value */"
                + b"b" * 34
                + b"/** @breakpoint before-add */"
                + b"c" * 9
                + b"/** @range-begin delta */1/** @range-end delta */\n"
            )
            + b"/** @end */\n"
        )
        text = render_projection(parse_relative("Language/Annotated.as", content)).decode("utf-8")
        self.assertIn("FAngelscriptTestSourceDescriptor", text)
        self.assertIn('TEXT("initial-value")', text)
        self.assertIn(".Offset = 32", text)
        self.assertIn('TEXT("before-add")', text)
        self.assertIn(".Offset = 66", text)
        self.assertIn('TEXT("delta")', text)
        self.assertIn(".Begin = 75", text)
        self.assertIn(".End = 76", text)
        self.assertIn(".OriginSpans", text)
        self.assertIn(".AuthoredEnd", text)
        self.assertNotIn("OriginalByteOffsets", text)
        self.assertNotIn("0x", text.split("AS_TEST_SOURCE", 1)[0])

    def test_macro_normalization_preserves_bytes(self) -> None:
        rows = (
            (b"class A {}\n", "terminal LF survives delimiter-margin removal"),
            (b"\nclass A {}\n\n", "intentional leading/trailing blank lines survive"),
            (b"class A {\n\tvoid f();\n}\n", "common tab prefix is not converted to spaces"),
            (
                'class Å { string S = " )\\" text"; }\n'.encode("utf-8"),
                "UTF-8 and delimiter-like content remain exact",
            ),
        )
        for clean, _reason in rows:
            content = (
                b"/**\n * @version v1\n * @summary Macro bytes.\n */\n"
                b"/**\n * @version root\n * @summary Root.\n */\n"
                + clean
                + b"/** @end */\n"
            )
            text = render_projection(parse_relative("Language/Macro.as", content)).decode("utf-8")
            literals = extract_raw_literals(text)
            self.assertEqual(1, len(literals), clean)
            self.assertEqual(clean, normalize_as_test_source(literals[0]))

    def test_readable_symbols_are_deterministic_and_collision_checked(self) -> None:
        planned = plan_registration_symbols(
            ("Language/Counter", "A/Same", "B/Same", "A-B", "A/B")
        )
        self.assertEqual("Language_Counter", planned["Language/Counter"])
        self.assertEqual("A_Same", planned["A/Same"])
        self.assertEqual("B_Same", planned["B/Same"])
        self.assertNotEqual(planned["A-B"], planned["A/B"])
        self.assertEqual(planned, plan_registration_symbols(tuple(planned)))
        with self.assertRaises(CodegenError):
            plan_registration_symbols(("A/B", "A_B"))

    def test_runtime_parser_path_is_absent(self) -> None:
        authored = (FIXTURE_ROOT / "Language" / "Counter.as").read_bytes()
        text = render_projection(parse_relative("Language/Counter.as", authored)).decode("utf-8")
        for forbidden in (
            "constexpr uint8 GSource",
            "FAngelscriptTestSourceParser",
            "BuildCounter",
            "namespace {",
            "GRegistration_427f18f4cff8",
        ):
            self.assertNotIn(forbidden, text)
        self.assertIn("GRegistration_Language_Counter", text)

    def test_provenance_remains_content_bound(self) -> None:
        parsed = parse_relative(
            "Language/Prov.as",
            b"/**\n * @version v1\n * @summary Provenance.\n */\n"
            b"/**\n * @version root\n * @summary Root.\n */\n"
            b"int X;\n"
            b"/** @end */\n",
        )
        first = render_projection(parsed)
        second = render_projection(parsed)
        text = first.decode("utf-8")
        self.assertEqual(first, second)
        self.assertIn(GENERATOR_SIGNATURE, text)
        self.assertIn("source=Language/Prov.as", text)
        self.assertIn(f"length={len(parsed.source.content)}", text)
        self.assertIn(parsed.source.content_sha256, text)
        self.assertNotIn("C:/", text)
        self.assertNotIn("D:/", text)
        self.assertNotIn("timestamp", text.lower())


if __name__ == "__main__":
    unittest.main()
