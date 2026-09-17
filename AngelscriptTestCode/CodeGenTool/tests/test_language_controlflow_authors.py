from __future__ import annotations

import re
import sys
import unittest
from pathlib import Path

TOOL_ROOT = Path(__file__).resolve().parents[1]
REPO_ROOT = TOOL_ROOT.parents[1]
sys.path.insert(0, str(TOOL_ROOT))

from angelscript_test_codegen.container_parser import parse_source_file
from angelscript_test_codegen.model import SourceInput

AUTHOR_ROOT = REPO_ROOT / "AngelscriptTestCode"
AUTO_TOKEN = re.compile(rb"(?<![A-Za-z0-9_])auto(?![A-Za-z0-9_])")

REQUIRED_BEGINS = {
    "Language/ControlFlow/If": (
        "if",
        "if-conditions",
        "bare-if-true",
        "if-unbraced-body",
        "if-false-skips-body",
        "if-compound-and-condition",
        "if-compound-or-condition",
        "if-not-condition",
    ),
    "Language/ControlFlow/IfNested": (
        "if-nested",
        "if-nested-three-deep",
        "if-nested-in-else",
        "if-nested-unbraced-inner",
        "if-nested-false-outer",
        "if-nested-false-inner",
    ),
    "Language/ControlFlow/IfElse": (
        "if-else",
        "if-else-false-condition",
        "else-if-chain",
        "unbraced-if-else",
        "compound-condition-if-else",
        "else-if-false-middle",
        "if-else-nested-else",
    ),
    "Language/ControlFlow/While": (
        "while",
        "while-zero-iterations",
        "while-nested",
        "while-one-iteration",
        "while-compound-condition",
    ),
    "Language/ControlFlow/DoWhile": (
        "do-while",
        "do-while-once",
        "do-while-nested",
        "do-while-false-after-first",
        "do-while-compound-condition",
    ),
    "Language/ControlFlow/LoopJump": (
        "loop-jump",
        "break-in-loop",
        "continue-in-loop",
        "break-in-nested-loop",
        "continue-in-nested-loop",
        "break-in-while",
        "continue-in-while",
        "break-in-do-while",
    ),
    "Language/ControlFlow/Foreach": (
        "foreach",
        "foreach-break-continue",
        "foreach-container-mutation",
        "foreach-value-reference",
        "foreach-empty-range",
        "foreach-over-array",
        "foreach-keyword-syntax",
    ),
    "Language/ControlFlow/Switch": (
        "switch",
        "switch-enum",
        "switch-basic",
        "switch-break",
        "switch-integer-types",
        "switch-fallthrough-to-default",
        "switch-default-only",
        "switch-no-default",
        "switch-empty-case-fallthrough",
        "switch-explicit-fallthrough",
    ),
    "Language/ControlFlow/SwitchCompileFail": ("invalid-fallthrough-outside-switch",),
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


def parse_author(file_tag: str):
    path = author_path(file_tag)
    return parse_source_file(make_source(f"{file_tag}.as", path.read_bytes(), path))


class ControlFlowAuthorTests(unittest.TestCase):
    def test_control_flow_required_begins_present(self) -> None:
        for file_tag, required in REQUIRED_BEGINS.items():
            with self.subTest(file_tag=file_tag):
                path = author_path(file_tag)
                self.assertTrue(path.is_file(), f"missing {path.as_posix()}")
                parsed = parse_author(file_tag)
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
                tags = {version.tag for version in parsed.versions}
                missing = set(required) - tags
                self.assertFalse(missing, f"{file_tag} missing begins: {sorted(missing)}")

    def test_foreach_has_no_auto(self) -> None:
        parsed = parse_author("Language/ControlFlow/Foreach")
        clean = b"\n".join(version.clean_source for version in parsed.versions)
        self.assertIsNone(
            AUTO_TOKEN.search(clean),
            "Language/ControlFlow/Foreach clean source must not contain an auto token",
        )


if __name__ == "__main__":
    unittest.main()
