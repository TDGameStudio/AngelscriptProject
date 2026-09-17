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

FILE_TAGS = (
    "Language/Interface/Declare",
    "Language/Interface/DeclareCompileFail",
    "Language/Interface/Implement",
    "Language/Interface/ImplementCompileFail",
    "Language/Interface/Handle",
    "Language/Interface/HandleCompileFail",
    "Language/Syntax/FunctionModifiers",
    "Language/Syntax/FunctionModifiersCompileFail",
)

REQUIRED_BEGINS = {
    "Language/Interface/Declare": (
        "declare-empty-interface",
        "declare-method",
        "declare-two-methods",
        "declare-const-method",
        "interface-extends-interface",
    ),
    "Language/Interface/DeclareCompileFail": (
        "invalid-interface-without-name",
        "invalid-interface-with-field",
        "invalid-interface-with-constructor",
        "invalid-interface-extends-class",
    ),
    "Language/Interface/Implement": (
        "implement-one-interface",
        "implement-method-body",
        "implement-two-methods",
        "implement-multiple-interfaces",
    ),
    "Language/Interface/ImplementCompileFail": (
        "invalid-missing-interface-method",
        "invalid-wrong-interface-signature",
        "invalid-multiple-object-bases",
    ),
    "Language/Interface/Handle": (
        "interface-handle-local",
        "class-to-interface-handle",
        "interface-handle-null",
        "cast-to-interface-handle",
    ),
    "Language/Interface/HandleCompileFail": (
        "invalid-unrelated-class-to-interface",
    ),
    "Language/Syntax/FunctionModifiers": (
        "local-function",
        "local-function-returns-int",
        "local-function-with-parameter",
        "access-policy-declaration",
        "access-member-prefix",
    ),
    "Language/Syntax/FunctionModifiersCompileFail": (
        "invalid-local-on-class-method",
        "invalid-access-at-global-scope",
    ),
}

REMOVED_KEYWORD = re.compile(rb"\b(?:import|funcdef|property)\b")


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


class InterfaceAuthorTests(unittest.TestCase):
    def test_interface_and_modifiers_parse_with_required_begins(self) -> None:
        sources = discover_sources(AUTHOR_ROOT)
        discovered_tags = {source.file_tag.replace("\\", "/") for source in sources}

        for file_tag in FILE_TAGS:
            with self.subTest(file_tag=file_tag):
                path = author_path(file_tag)
                self.assertTrue(path.is_file(), f"missing {path.as_posix()}")
                self.assertIn(file_tag, discovered_tags)
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
                self.assertEqual(REQUIRED_BEGINS[file_tag], tuple(version.tag for version in parsed.versions))
                self.assertTrue(
                    all(version.parent is None for version in parsed.versions),
                    f"{file_tag} has a parented version",
                )
                self.assertTrue(
                    all(version.clean_source.strip() for version in parsed.versions),
                    f"{file_tag} has an empty @begin body",
                )

    def test_removed_syntax_absent(self) -> None:
        for file_tag in FILE_TAGS:
            with self.subTest(file_tag=file_tag):
                path = author_path(file_tag)
                self.assertTrue(path.is_file(), f"missing {path.as_posix()}")
                parsed = parse_tag(file_tag)
                for version in parsed.versions:
                    match = REMOVED_KEYWORD.search(version.clean_source)
                    found = match.group(0).decode("ascii") if match is not None else ""
                    self.assertEqual(
                        "",
                        found,
                        f"{file_tag}/{version.tag} contains removed syntax {found!r}",
                    )


if __name__ == "__main__":
    unittest.main()
