from __future__ import annotations

import sys
import unittest
from pathlib import Path

TOOL_ROOT = Path(__file__).resolve().parents[1]
REPO_ROOT = TOOL_ROOT.parents[1]
sys.path.insert(0, str(TOOL_ROOT))

from angelscript_test_codegen.container_parser import parse_source_file
from angelscript_test_codegen.model import SourceInput

AUTHOR_ROOT = REPO_ROOT / "AngelscriptTestCode"

REQUIRED_BEGINS = {
    "Language/Syntax/FunctionReturn": (
        "function-return",
        "return-bool",
        "return-float",
        "return-void-early",
        "return-string",
        "return-from-nested-if",
    ),
    "Language/Syntax/EmptyFunction": (
        "empty-function",
        "empty-void-no-statements",
        "empty-inner-block",
        "empty-void-trailing-comment",
        "empty-global-void",
    ),
    "Language/Syntax/Variables": (
        "variables",
        "global-int",
        "multi-declarator-int",
        "int8-local",
        "uint16-local",
        "float64-local",
    ),
    "Language/Syntax/StringLiterals": (
        "string-literal-assignment",
        "empty-string-literal",
        "string-escape-sequences",
        "string-concat-in-declaration",
        "heredoc-string-literal",
    ),
    "Language/Syntax/NamedArguments": (
        "named-arguments",
        "named-arguments-all-named",
        "named-arguments-trailing-only",
        "named-arguments-mixed-positional-then-named",
        "named-arguments-default-skipped",
    ),
    "Language/Syntax/ForNested": (
        "for-nested",
        "for-nested-three-deep",
        "for-nested-with-break",
        "for-nested-continue-inner",
        "for-nested-independent-indices",
    ),
    "Language/Syntax/Const": (
        "const",
        "const-method-on-struct",
        "const-int-local",
        "const-float-local",
        "const-string-local",
    ),
    "Language/Syntax/References": (
        "references",
        "function-reference-parameter-combinations",
        "ref-to-local",
        "ref-inout-chain",
        "ref-out-parameter",
        "ref-to-member",
    ),
    "Language/Syntax/Blocks": (
        "blocks",
        "deeply-parenthesized-addition",
        "long-chained-addition",
        "multiple-statements-in-one-function",
        "short-circuit-skips-right-hand-side",
        "nested-block-shadow",
        "empty-block",
    ),
    "Language/Syntax/StructFields": (
        "fields-two",
        "add-field",
        "anonymous-struct-compiles",
        "struct-member-defaults",
        "struct-empty-body",
        "three-fields",
        "struct-bool-field",
    ),
    "Language/Syntax/StructConstructors": (
        "struct-constructors",
        "default-constructor-only",
        "constructor-overload-set",
        "constructor-with-two-args",
        "constructor-initializes-two-fields",
    ),
    "Language/Syntax/StructConst": (
        "struct-const",
        "struct-const-method",
        "struct-const-reader-method",
        "const-method-on-struct",
        "const-struct-local",
        "const-method-returns-field",
    ),
}


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


def version_tags(parsed) -> set[str]:
    return {version.tag for version in parsed.versions}


class SyntaxAuthorTests(unittest.TestCase):
    def test_syntax_required_begins_present(self) -> None:
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
                missing = set(required) - version_tags(parsed)
                self.assertFalse(missing, f"{file_tag} missing begins {sorted(missing)}")

    def test_variables_strings_and_auto_fail_moved(self) -> None:
        for file_tag in (
            "Language/Syntax/Variables",
            "Language/Syntax/VariablesCompileFail",
            "Language/Syntax/FunctionReturn",
            "Language/Syntax/StringLiterals",
        ):
            path = author_path(file_tag)
            self.assertTrue(path.is_file(), f"missing {path.as_posix()}")

        variables = version_tags(parse_tag("Language/Syntax/Variables"))
        variables_fail = version_tags(parse_tag("Language/Syntax/VariablesCompileFail"))
        function_return = version_tags(parse_tag("Language/Syntax/FunctionReturn"))
        string_literals = version_tags(parse_tag("Language/Syntax/StringLiterals"))

        self.assertNotIn("string-literal-assignment", variables)
        self.assertNotIn("empty-string-literal", variables)
        self.assertNotIn("string-escape-sequences", variables)
        self.assertNotIn("invalid-auto-without-initializer", variables_fail)
        self.assertNotIn("int-return-function", function_return)
        self.assertIn("string-literal-assignment", string_literals)
        self.assertIn("empty-string-literal", string_literals)
        self.assertIn("string-escape-sequences", string_literals)

    def test_const_mashup_split(self) -> None:
        tags = version_tags(parse_tag("Language/Syntax/Const"))
        self.assertNotIn("const-values-methods-and-references", tags)


if __name__ == "__main__":
    unittest.main()
