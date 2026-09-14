from __future__ import annotations

import hashlib
import sys
import unittest
from pathlib import Path

TOOL_ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(TOOL_ROOT))

from angelscript_test_codegen.cpp_renderer import GENERATOR_SIGNATURE, render_projection
from angelscript_test_codegen.model import SourceInput


def make_source(relative_path: str, content: bytes) -> SourceInput:
    file_tag = relative_path[:-3]
    output_path = f"{file_tag}.generated.cpp"
    return SourceInput(
        full_path=Path("C:/fixture") / Path(relative_path),
        relative_path=relative_path,
        file_tag=file_tag,
        output_relative_path=output_path,
        content=content,
        content_sha256=hashlib.sha256(content).hexdigest(),
        symbol_suffix=hashlib.sha256(file_tag.encode("utf-8")).hexdigest()[:12],
    )


class CppRendererTests(unittest.TestCase):
    def test_exact_bytes_metadata_and_determinism(self) -> None:
        source = make_source("Binary/Exact.as", bytes((0x00, 0x0A, 0xFF, 0x22)))

        first = render_projection(source)
        second = render_projection(source)
        text = first.decode("utf-8")

        self.assertEqual(first, second)
        self.assertIn(GENERATOR_SIGNATURE, text)
        self.assertIn("source=Binary/Exact.as", text)
        self.assertIn("length=4", text)
        self.assertIn(
            "sha256=4ac7501e124bdd2de2807f87f20ab05305143e985e9779e5833c3b397fb450ae",
            text,
        )
        self.assertIn("0x00, 0x0a, 0xff, 0x22", text)
        self.assertIn('TEXT("Binary/Exact")', text)
        self.assertTrue(first.endswith(b"\n"))
        self.assertNotIn("C:/fixture", text)

    def test_same_basename_uses_distinct_stable_unity_safe_symbols(self) -> None:
        left = render_projection(make_source("A/Same.as", b"same")).decode("utf-8")
        right = render_projection(make_source("B/Same.as", b"same")).decode("utf-8")

        self.assertIn("679f597dc378", left)
        self.assertNotIn("679f597dc378", right)
        self.assertIn("033b9adb7f38", right)
        self.assertNotIn("033b9adb7f38", left)
        for text in (left, right):
            self.assertIn("FAngelscriptTestCodeRegistration", text)
            self.assertIn("FAngelscriptTestSourceParser::Parse", text)

    def test_registration_uses_inline_captureless_factory(self) -> None:
        text = render_projection(make_source("Language/Counter.as", b"class Counter {}\n")).decode(
            "utf-8"
        )

        self.assertNotIn("BuildSource_", text)
        self.assertIn("+[](const FAngelscriptTestFileMeta& FileMeta)", text)
        self.assertEqual(1, text.count("FAngelscriptTestSourceParser::Parse"))


if __name__ == "__main__":
    unittest.main()
