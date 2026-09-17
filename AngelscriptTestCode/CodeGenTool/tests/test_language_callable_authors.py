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
FUNCDEF_TOKEN = re.compile(r"\bfuncdef\b")

REQUIRED_TAGS = {
    "Language/Delegate/Declare": (
        "declare-delegate",
        "declare-delegate-with-parameter",
        "declare-delegate-void",
    ),
    "Language/Delegate/DeclareCompileFail": (
        "invalid-delegate-without-name",
        "invalid-delegate-missing-semicolon",
    ),
    "Language/Event/Declare": (
        "declare-event",
        "declare-event-with-parameter",
    ),
    "Language/Event/DeclareCompileFail": (
        "invalid-event-without-name",
        "invalid-event-missing-semicolon",
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


def parse_author(file_tag: str):
    path = author_path(file_tag)
    content = path.read_bytes()
    return parse_source_file(make_source(f"{file_tag}.as", content, path))


class CallableAuthorTests(unittest.TestCase):
    def test_delegate_and_event_parse_with_required_begins(self) -> None:
        for file_tag, expected_tags in REQUIRED_TAGS.items():
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
                self.assertEqual(expected_tags, tuple(version.tag for version in parsed.versions))

    def test_funcdef_absent_from_callable_authors(self) -> None:
        for file_tag in REQUIRED_TAGS:
            with self.subTest(file_tag=file_tag):
                path = author_path(file_tag)
                self.assertTrue(path.is_file(), f"missing {path.as_posix()}")
                parsed = parse_author(file_tag)
                for version in parsed.versions:
                    clean = version.clean_source.decode("utf-8")
                    self.assertIsNone(
                        FUNCDEF_TOKEN.search(clean),
                        f"{file_tag} {version.tag} clean source contains funcdef",
                    )


if __name__ == "__main__":
    unittest.main()
