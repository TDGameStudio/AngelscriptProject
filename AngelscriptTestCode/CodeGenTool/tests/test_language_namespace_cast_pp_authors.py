from __future__ import annotations

import re
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

REQUIRED_BEGINS = {
    "Language/Namespace/Shadowing": (
        "shadowing",
        "parameter-shadows-namespace",
        "inner-block-shadows-local",
        "function-shadows-namespace-function",
        "local-shadows-namespace-const",
    ),
    "Language/Namespace/QualifiedName": (
        "qualified-name",
        "namespace-qualified-call",
        "namespace-qualified-name",
        "multi-segment-qualifier",
        "qualified-enum-member",
        "qualified-struct-type",
    ),
    "Language/Namespace/Nested": (
        "nested",
        "namespace-nested-access",
        "namespace-nested-scope",
        "three-level-nested",
        "inner-calls-outer",
    ),
    "Language/Namespace/GlobalVersusScoped": (
        "global-versus-scoped",
        "namespace-global-versus-scoped",
        "namespace-scoped-global",
        "unqualified-finds-global",
        "scoped-hides-global",
    ),
    "Language/Namespace/Enum": (
        "enum",
        "namespace-with-enum",
        "enum-qualified-from-nested-namespace",
        "two-enums-same-namespace",
        "enum-as-function-argument",
    ),
    "Language/Casting/NullHandle": (
        "handle-null-assignment",
        "handle-null-comparison",
        "cast-null-is-null",
        "handle-null-then-is-null",
        "handle-assign-null-after-object",
    ),
    "Language/Casting/NumericExplicitConversion": (
        "explicit-float-to-int",
        "explicit-int-to-float",
        "explicit-int-to-uint8",
        "explicit-float-to-uint8",
        "explicit-int64-to-int",
        "explicit-bool-to-int",
    ),
    "Language/Casting/ClassHandleCast": (
        "implicit-derived-to-base",
        "cast-to-parent",
        "cast-downcast",
        "cast-downcast-null-guard",
        "cast-round-trip",
        "cast-null-handle",
        "cast-same-type",
    ),
    "Language/Preprocessor/DirectiveInString": (
        "directive-in-string",
        "elif-in-string",
        "endif-in-string",
        "if-in-line-comment",
        "if-in-block-comment",
        "define-looking-string",
        "include-looking-comment",
    ),
}

LIVE_SPELLING_TAGS = (
    "Language/Casting/NullHandle",
    "Language/Casting/ClassHandleCast",
)

NULL_TOKEN = re.compile(rb"\bnull\b")
IS_TOKEN = re.compile(rb"\bis\b")


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


def author_path(file_tag: str) -> Path:
    return AUTHOR_ROOT / f"{file_tag}.as"


def parse_tag(file_tag: str):
    path = author_path(file_tag)
    return parse_source_file(make_source(f"{file_tag}.as", path.read_bytes(), path))


def joined_clean_source(parsed) -> bytes:
    return b"\n".join(version.clean_source for version in parsed.versions)


class NamespaceCastPpAuthorTests(unittest.TestCase):
    def test_namespace_cast_pp_required_begins_present(self) -> None:
        for file_tag, required in REQUIRED_BEGINS.items():
            with self.subTest(file_tag=file_tag):
                path = author_path(file_tag)
                self.assertTrue(path.is_file(), f"missing {path.as_posix()}")
                parsed = parse_tag(file_tag)
                self.assertEqual(file_tag, parsed.source.file_tag)
                self.assertEqual("v1", parsed.format_version)
                self.assertTrue(
                    any(version.parent is None for version in parsed.versions),
                    f"{file_tag} has no parentless version",
                )
                self.assertFalse(
                    any(version.tag == "root" for version in parsed.versions),
                    f"{file_tag} still uses privileged root",
                )
                actual = {version.tag for version in parsed.versions}
                missing = set(required) - actual
                self.assertFalse(missing, f"{file_tag} missing {sorted(missing)}")

    def test_class_cast_stays_absent(self) -> None:
        sources = discover_sources(AUTHOR_ROOT)
        file_tags = {source.file_tag.replace("\\", "/") for source in sources}
        self.assertNotIn("Language/Casting/ClassCast", file_tags)
        self.assertIn("Language/Casting/ClassHandleCast", file_tags)

    def test_live_null_and_cast_spellings(self) -> None:
        for file_tag in LIVE_SPELLING_TAGS:
            with self.subTest(file_tag=file_tag):
                parsed = parse_tag(file_tag)
                bodies = joined_clean_source(parsed)
                self.assertIn(b"nullptr", bodies)
                self.assertIn(b"Cast<", bodies)
                self.assertIsNone(
                    NULL_TOKEN.search(bodies),
                    f"{file_tag} still contains leftover token null",
                )
                self.assertNotIn(b"cast<", bodies)
                self.assertIsNone(
                    IS_TOKEN.search(bodies),
                    f"{file_tag} still contains leftover token is",
                )
                self.assertNotIn(b"!is", bodies)


if __name__ == "__main__":
    unittest.main()
