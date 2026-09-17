from __future__ import annotations

import hashlib
import re
import sys
import unittest
from pathlib import Path

TOOL_ROOT = Path(__file__).resolve().parents[1]
REPO_ROOT = TOOL_ROOT.parents[1]
AUTHOR_ROOT = REPO_ROOT / "AngelscriptTestCode"
sys.path.insert(0, str(TOOL_ROOT))

from angelscript_test_codegen.container_parser import parse_source_file
from angelscript_test_codegen.discovery import discover_sources
from angelscript_test_codegen.model import SourceInput

AUTO_FILE_TAGS = (
    "Language/Auto/InferFromLiteral",
    "Language/Auto/InferFromLiteralCompileFail",
    "Language/Auto/InferFromCall",
    "Language/Auto/InferFromCallCompileFail",
    "Language/Auto/InferInLoop",
    "Language/Auto/Qualifiers",
    "Language/Auto/QualifiersCompileFail",
)

REQUIRED_VERSION_TAGS = {
    "Language/Auto/InferFromLiteral": frozenset(
        {
            "infer-from-bool",
            "infer-from-false",
            "infer-from-int",
            "infer-from-int-hex",
            "infer-from-uint",
            "infer-from-float",
            "infer-from-double",
            "infer-from-string",
            "infer-from-name",
            "infer-from-enum",
            "infer-from-handle",
            "infer-multiple-declarators",
            "reassign-same-type-bool",
            "reassign-same-type-int",
            "reassign-same-type-float",
            "auto-int-in-expression",
            "auto-as-argument",
            "auto-as-return",
        }
    ),
    "Language/Auto/InferFromLiteralCompileFail": frozenset(
        {
            "invalid-auto-without-initializer",
            "auto-reassign-wrong-type",
            "invalid-auto-bool-to-int",
            "invalid-auto-float-to-bool",
            "invalid-auto-reassign-string-to-int",
            "invalid-auto-bare-null",
        }
    ),
    "Language/Auto/InferFromCall": frozenset(
        {
            "infer-from-constructor",
            "default-score",
            "infer-from-function-return",
            "infer-from-method-return",
            "infer-from-member-read",
            "infer-from-subscript",
            "infer-from-ternary",
            "infer-from-cast",
        }
    ),
    "Language/Auto/InferFromCallCompileFail": frozenset(
        {
            "auto-void",
            "invalid-auto-void-type",
            "invalid-constructor-wrong-arity",
            "invalid-auto-from-void-method",
        }
    ),
    "Language/Auto/InferInLoop": frozenset(
        {
            "infer-for-initializer",
            "infer-for-increment-use",
            "infer-foreach-value",
            "infer-foreach-reference",
            "infer-foreach-key-value",
        }
    ),
    "Language/Auto/Qualifiers": frozenset(
        {
            "const-auto-local",
            "const-auto-from-call",
        }
    ),
    "Language/Auto/QualifiersCompileFail": frozenset(
        {
            "invalid-const-auto-reassign",
        }
    ),
}

INTEGER_U_SUFFIX = re.compile(
    r"\b(?:0[xX][0-9A-Fa-f]+|0[bBoOdD][0-9A-Fa-f]+|\d+)[uU]\b"
)
LEFTOVER_NULL = re.compile(r"(?<![A-Za-z_])null(?!ptr)(?![A-Za-z0-9_])")
LEFTOVER_CAST = re.compile(r"\bcast\s*<")
LEFTOVER_IS = re.compile(r"(?<![A-Za-z_])(?:!is|is)(?![A-Za-z0-9_])")
LOCAL_AUTO_REF = re.compile(r"\bauto\s*&")


def make_source(relative_path: str, content: bytes, *, full_path: Path) -> SourceInput:
    file_tag = relative_path[: -len(".as")] if relative_path.endswith(".as") else relative_path
    return SourceInput(
        full_path=full_path,
        relative_path=relative_path,
        file_tag=file_tag,
        output_relative_path=f"{file_tag}.generated.cpp",
        content=content,
        content_sha256=hashlib.sha256(content).hexdigest(),
        symbol_suffix=hashlib.sha256(file_tag.encode("utf-8")).hexdigest()[:12],
    )


def parse_author(file_tag: str):
    relative_path = f"{file_tag}.as"
    full_path = AUTHOR_ROOT / Path(relative_path)
    content = full_path.read_bytes()
    return parse_source_file(make_source(relative_path, content, full_path=full_path))


class AutoAuthorTests(unittest.TestCase):
    def test_AutoSlicesParseWithRequiredBegins(self) -> None:
        parsed_by_tag = {}
        for file_tag in AUTO_FILE_TAGS:
            with self.subTest(file_tag=file_tag):
                full_path = AUTHOR_ROOT / f"{file_tag}.as"
                self.assertTrue(full_path.is_file(), f"missing {file_tag}")
                parsed = parse_author(file_tag)
                self.assertEqual(file_tag, parsed.source.file_tag)
                self.assertEqual("v1", parsed.format_version)
                self.assertIn("Language", parsed.topics)
                self.assertIn("Auto", parsed.topics)
                self.assertTrue(parsed.versions)
                self.assertTrue(any(version.parent is None for version in parsed.versions))
                self.assertFalse(any(version.tag == "root" for version in parsed.versions))
                self.assertFalse(any(version.parent is not None for version in parsed.versions))
                self.assertEqual(REQUIRED_VERSION_TAGS[file_tag], {version.tag for version in parsed.versions})
                parsed_by_tag[file_tag] = parsed

        self.assertEqual(len(AUTO_FILE_TAGS), len(parsed_by_tag))

        literal = parsed_by_tag["Language/Auto/InferFromLiteral"]
        hex_bodies = [
            version.clean_source.decode("utf-8")
            for version in literal.versions
            if version.tag == "infer-from-int-hex"
        ]
        self.assertEqual(1, len(hex_bodies))
        self.assertRegex(hex_bodies[0], r"0[xX][0-9A-Fa-f]+")

        for file_tag, parsed in parsed_by_tag.items():
            for version in parsed.versions:
                text = version.clean_source.decode("utf-8")
                self.assertIsNone(
                    INTEGER_U_SUFFIX.search(text),
                    f"{file_tag}:{version.tag} uses a u integer suffix",
                )
                self.assertIsNone(
                    LEFTOVER_NULL.search(text),
                    f"{file_tag}:{version.tag} uses leftover null",
                )
                self.assertIsNone(
                    LEFTOVER_CAST.search(text),
                    f"{file_tag}:{version.tag} uses leftover cast<>",
                )
                self.assertIsNone(
                    LEFTOVER_IS.search(text),
                    f"{file_tag}:{version.tag} uses leftover is",
                )

        qualifiers = parsed_by_tag["Language/Auto/Qualifiers"]
        for version in qualifiers.versions:
            self.assertIsNone(
                LOCAL_AUTO_REF.search(version.clean_source.decode("utf-8")),
                f"Qualifiers:{version.tag} authors local auto&",
            )

        loop = parsed_by_tag["Language/Auto/InferInLoop"]
        reference_bodies = [
            version.clean_source.decode("utf-8")
            for version in loop.versions
            if version.tag == "infer-foreach-reference"
        ]
        self.assertEqual(1, len(reference_bodies))
        self.assertRegex(reference_bodies[0], r"\bauto\s*&")

    def test_RetiredAutoFlatAbsent(self) -> None:
        sources = discover_sources(AUTHOR_ROOT)
        file_tags = {source.file_tag for source in sources}
        self.assertNotIn("Language/Auto", file_tags)
        self.assertNotIn("Language/AutoCompileFail", file_tags)
        for file_tag in AUTO_FILE_TAGS:
            self.assertIn(file_tag, file_tags)

    def test_DiscoverySkipsPendingAuto(self) -> None:
        pending_auto = AUTHOR_ROOT / "Pending" / "Language" / "Auto"
        self.assertTrue(pending_auto.is_dir())
        self.assertTrue(any(pending_auto.rglob("*.as")))
        sources = discover_sources(AUTHOR_ROOT)
        relative_paths = [source.relative_path.replace("\\", "/") for source in sources]
        self.assertFalse(any(path.startswith("Pending/") for path in relative_paths))


if __name__ == "__main__":
    unittest.main()
