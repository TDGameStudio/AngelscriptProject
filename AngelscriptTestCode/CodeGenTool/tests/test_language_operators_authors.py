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
from angelscript_test_codegen.model import SourceInput

REQUIRED_FILE_TAGS = (
    "Language/Operators/Arithmetic",
    "Language/Operators/Assignment",
    "Language/Operators/Bitwise",
    "Language/Operators/Comparison",
    "Language/Operators/Logical",
    "Language/Operators/Ternary",
    "Language/Operators/ExpressionEdges",
    "Language/Operators/DefiniteAssignment",
)

REQUIRED_VERSION_TAGS = {
    "Language/Operators/Arithmetic": (
        "add-int",
        "sub-int",
        "mul-int",
        "div-int",
        "mod-int",
        "add-float",
        "sub-float",
        "mul-float",
        "div-float",
        "unary-minus-int",
        "unary-plus-int",
        "power-int",
        "prefix-increment",
        "postfix-increment",
        "prefix-decrement",
        "postfix-decrement",
        "string-concatenation-plus",
    ),
    "Language/Operators/Assignment": (
        "assign-int",
        "assign-float",
        "assign-bool",
        "add-assign-int",
        "sub-assign-int",
        "mul-assign-int",
        "div-assign-int",
        "mod-assign-int",
        "power-assign-int",
        "and-assign-int",
        "or-assign-int",
        "xor-assign-int",
        "shift-left-assign-int",
        "shift-right-assign-int",
        "shift-right-arith-assign-int",
        "string-concatenation-plus-assign",
    ),
    "Language/Operators/Bitwise": (
        "bitwise-and-int",
        "bitwise-or-int",
        "bitwise-xor-int",
        "bitwise-not-int",
        "shift-left-int",
        "shift-right-int",
        "shift-right-arith-int",
        "bitmask-protocol",
    ),
    "Language/Operators/Comparison": (
        "equal-int",
        "not-equal-int",
        "less-int",
        "less-equal-int",
        "greater-int",
        "greater-equal-int",
        "equal-float",
        "equal-bool",
        "string-equality-operator",
    ),
    "Language/Operators/Logical": (
        "logical-and-true",
        "logical-and-false",
        "logical-or-true",
        "logical-or-false",
        "logical-not-true",
        "logical-not-false",
        "logical-xor-true",
        "short-circuit-and",
        "short-circuit-or",
    ),
    "Language/Operators/Ternary": (
        "ternary",
        "nested-ternary",
        "ternary-as-return",
        "ternary-false-arm",
        "ternary-nested-else",
        "ternary-as-argument",
        "ternary-int-arms",
    ),
    "Language/Operators/ExpressionEdges": (
        "expression-edges",
        "unary-minus-versus-subtract",
        "deeply-nested-parens",
        "parenthesized-primary",
    ),
    "Language/Operators/DefiniteAssignment": (
        "definite-assignment",
        "partial-then-complete",
        "branch-definite-assignment",
        "partial-definite-assignment",
        "assigned-on-all-returns",
        "assigned-before-nested-block",
        "assigned-on-both-if-else-arms",
    ),
}

RETIRED_MASHUP_TAGS = (
    "arithmetic",
    "assignment",
    "bitwise",
    "comparison",
    "logical",
)


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


class OperatorAuthorTests(unittest.TestCase):
    def test_OperatorRequiredBeginsPresent(self) -> None:
        self.assertEqual(REQUIRED_FILE_TAGS, tuple(REQUIRED_VERSION_TAGS))
        for file_tag, required_tags in REQUIRED_VERSION_TAGS.items():
            with self.subTest(file_tag=file_tag):
                full_path = AUTHOR_ROOT / Path(f"{file_tag}.as")
                self.assertTrue(full_path.is_file(), f"{file_tag} must exist")
                parsed = parse_author(file_tag)
                tags = {version.tag for version in parsed.versions}
                self.assertEqual(file_tag, parsed.source.file_tag)
                self.assertEqual("v1", parsed.format_version)
                self.assertTrue(parsed.versions)
                self.assertTrue(any(version.parent is None for version in parsed.versions))
                self.assertNotIn("root", tags)
                missing = set(required_tags) - tags
                self.assertFalse(missing, f"{file_tag} missing {sorted(missing)}")

    def test_OperatorMashupsRetired(self) -> None:
        collected: set[str] = set()
        for file_tag in REQUIRED_FILE_TAGS:
            parsed = parse_author(file_tag)
            collected.update(version.tag for version in parsed.versions)
        present = [tag for tag in RETIRED_MASHUP_TAGS if tag in collected]
        self.assertEqual([], present)


if __name__ == "__main__":
    unittest.main()
