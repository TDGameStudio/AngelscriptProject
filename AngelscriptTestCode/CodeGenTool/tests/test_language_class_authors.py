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

CLASS_SLICES = (
    "Language/Class/Declaration",
    "Language/Class/DeclarationCompileFail",
    "Language/Class/Constructor",
    "Language/Class/ConstructorCompileFail",
    "Language/Class/Fields",
    "Language/Class/FieldsCompileFail",
    "Language/Class/Methods",
    "Language/Class/MethodsCompileFail",
    "Language/Class/Access",
    "Language/Class/AccessCompileFail",
    "Language/Class/This",
    "Language/Class/ThisCompileFail",
    "Language/Class/Handle",
)

REQUIRED_BEGINS = {
    "Language/Class/Declaration": (
        "empty-body",
        "empty-class-as-parameter",
    ),
    "Language/Class/DeclarationCompileFail": (
        "invalid-class-without-name",
        "invalid-class-without-braces",
        "invalid-duplicate-class-name",
        "invalid-unknown-member-on-empty",
    ),
    "Language/Class/Constructor": (
        "constructor",
        "constructor-two-args",
        "constructor-overload-set",
        "default-construct",
    ),
    "Language/Class/ConstructorCompileFail": (
        "invalid-constructor-wrong-arity",
        "invalid-constructor-unknown-arg-type",
        "invalid-constructor-return-type",
    ),
    "Language/Class/Fields": (
        "field-assign",
        "field-compound-assign",
        "field-initializer",
        "float-field-initializer",
        "initializer-then-assign",
        "two-int-fields",
        "bool-field-initializer",
    ),
    "Language/Class/FieldsCompileFail": (
        "invalid-unknown-field",
        "invalid-unknown-member-type",
        "invalid-void-member",
    ),
    "Language/Class/Methods": (
        "method-call",
        "method-calls-field-writer",
        "const-method",
        "const-method-on-const-handle",
        "const-method-adds-locals",
        "method-with-argument",
        "method-returns-field",
        "get-value-accessor",
    ),
    "Language/Class/MethodsCompileFail": ("invalid-unknown-method",),
    "Language/Class/Access": (
        "private-access",
        "private-method-from-inside",
        "public-field-from-outside",
        "protected-field-from-subclass",
        "protected-method-from-subclass",
    ),
    "Language/Class/AccessCompileFail": (
        "invalid-private-field-from-outside",
        "invalid-protected-field-from-outside",
    ),
    "Language/Class/This": (
        "this-keyword",
        "this-compound-write",
        "this-as-argument",
    ),
    "Language/Class/ThisCompileFail": ("invalid-this-outside-class",),
    "Language/Class/Handle": (
        "handle-local",
        "handle-member-read",
        "handle-null-then-construct",
    ),
}

RETIRED_FLAT_TAGS = (
    "Language/Class",
    "Language/ClassCompileFail",
)

EXCLUSIVE_WITHOUT_NAME = "invalid-class-without-name"
WITHOUT_NAME_OWNER = "Language/Class/DeclarationCompileFail"


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


class LanguageClassAuthorTests(unittest.TestCase):
    def test_class_slices_parse_with_required_begins(self) -> None:
        self.assertEqual(set(CLASS_SLICES), set(REQUIRED_BEGINS))
        for file_tag in CLASS_SLICES:
            with self.subTest(file_tag=file_tag):
                full_path = AUTHOR_ROOT / f"{file_tag}.as"
                self.assertTrue(full_path.is_file(), f"missing {full_path.as_posix()}")
                parsed = parse_author(file_tag)
                self.assertEqual(file_tag, parsed.source.file_tag)
                self.assertEqual("v1", parsed.format_version)
                self.assertTrue(parsed.versions)
                self.assertTrue(
                    any(version.parent is None for version in parsed.versions),
                    f"{file_tag} has no parentless version",
                )
                self.assertFalse(
                    any(version.tag == "root" for version in parsed.versions),
                    f"{file_tag} still uses privileged root",
                )
                self.assertEqual(
                    REQUIRED_BEGINS[file_tag],
                    tuple(version.tag for version in parsed.versions),
                )

    def test_retired_class_flat_absent(self) -> None:
        sources = discover_sources(AUTHOR_ROOT)
        file_tags = {source.file_tag for source in sources}
        for retired in RETIRED_FLAT_TAGS:
            self.assertNotIn(retired, file_tags)
        for file_tag in CLASS_SLICES:
            self.assertIn(file_tag, file_tags)

    def test_class_without_name_exclusive(self) -> None:
        owners: list[str] = []
        for source in discover_sources(AUTHOR_ROOT):
            if not source.file_tag.startswith("Language/"):
                continue
            parsed = parse_source_file(source)
            if any(version.tag == EXCLUSIVE_WITHOUT_NAME for version in parsed.versions):
                owners.append(source.file_tag)
        self.assertEqual([WITHOUT_NAME_OWNER], owners)


if __name__ == "__main__":
    unittest.main()
