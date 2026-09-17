from __future__ import annotations

import hashlib
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

REQUIRED_VERSION_TAGS = {
    "Language/Inheritance/Extends": (
        "derived-as-base-handle",
        "derived-local-as-base-handle",
        "inherited-method",
        "inherited-method-with-argument",
        "inherited-field-read",
    ),
    "Language/Inheritance/ExtendsCompileFail": (
        "invalid-implicit-base-to-derived",
        "invalid-class-self-inheritance",
        "invalid-unknown-ancestor-field",
        "invalid-unknown-base",
    ),
    "Language/Inheritance/Override": (
        "method-override",
        "override-with-argument",
        "three-level-override",
        "middle-override",
    ),
    "Language/Inheritance/OverrideCompileFail": (
        "invalid-override-without-parent-method",
        "invalid-override-wrong-return-type",
        "invalid-override-wrong-arity",
        "invalid-override-extra-parameter",
        "invalid-unknown-inherited-method",
    ),
    "Language/Inheritance/Super": (
        "super-call",
        "super-field-read",
        "super-field-plus-own-field",
        "leaf-calls-super",
    ),
    "Language/Inheritance/SuperCompileFail": (
        "invalid-super-outside-class",
        "invalid-super-without-base",
        "invalid-super-unknown-field",
        "invalid-unknown-super-type",
    ),
    "Language/Inheritance/Final": (
        "final-method",
        "override-final-method",
    ),
    "Language/Inheritance/Nested": (
        "nested",
        "middle-reads-root-field",
    ),
    "Language/Inheritance/Handle": (
        "derived-handle-as-base",
    ),
}

RETIRED_FLAT_TAGS = (
    "Language/Inheritance",
    "Language/InheritanceCompileFail",
)

SUPER_OUTSIDE_CLASS_TAG = "invalid-super-outside-class"
SUPER_OUTSIDE_CLASS_OWNER = "Language/Inheritance/SuperCompileFail"


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


class InheritanceAuthorTests(unittest.TestCase):
    def test_InheritanceSlicesParseWithRequiredBegins(self) -> None:
        for file_tag, expected_tags in REQUIRED_VERSION_TAGS.items():
            with self.subTest(file_tag=file_tag):
                full_path = AUTHOR_ROOT / Path(f"{file_tag}.as")
                self.assertTrue(full_path.is_file(), f"{file_tag} must exist")
                parsed = parse_author(file_tag)
                tags = tuple(version.tag for version in parsed.versions)
                self.assertEqual(file_tag, parsed.source.file_tag)
                self.assertEqual("v1", parsed.format_version)
                self.assertTrue(parsed.versions)
                self.assertTrue(any(version.parent is None for version in parsed.versions))
                self.assertNotIn("root", tags)
                self.assertEqual(expected_tags, tags)

    def test_RetiredInheritanceFlatAbsent(self) -> None:
        sources = discover_sources(AUTHOR_ROOT)
        file_tags = {source.file_tag for source in sources}
        for retired in RETIRED_FLAT_TAGS:
            self.assertNotIn(retired, file_tags)

    def test_SuperOutsideClassExclusive(self) -> None:
        owners: list[str] = []
        for source in discover_sources(AUTHOR_ROOT):
            if not source.file_tag.startswith("Language/"):
                continue
            parsed = parse_source_file(
                make_source(source.relative_path, source.content, full_path=source.full_path)
            )
            if any(version.tag == SUPER_OUTSIDE_CLASS_TAG for version in parsed.versions):
                owners.append(parsed.source.file_tag)
        self.assertEqual([SUPER_OUTSIDE_CLASS_OWNER], owners)


if __name__ == "__main__":
    unittest.main()
