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

REQUIRED_FILE_TAGS = (
    "Language/Typedef/Alias",
    "Language/Typedef/AliasCompileFail",
    "Language/Typedef/Chain",
    "Language/Typedef/ChainCompileFail",
    "Language/Typedef/InField",
    "Language/Typedef/Handle",
    "Language/Typedef/HandleCompileFail",
    "Language/Typedef/InReturn",
)

REQUIRED_VERSION_TAGS = {
    "Language/Typedef/Alias": (
        "alias",
        "typedef-of-float",
        "typedef-of-bool",
        "alias-round-trip-with-int",
    ),
    "Language/Typedef/AliasCompileFail": (
        "invalid-duplicate-typedef",
        "invalid-typedef-without-name",
        "invalid-typedef-unknown-type",
    ),
    "Language/Typedef/Chain": (
        "typedef-chain",
        "chain-as-parameter",
    ),
    "Language/Typedef/ChainCompileFail": (
        "invalid-chain-unknown-first-alias",
    ),
    "Language/Typedef/InField": (
        "struct-field",
        "two-aliased-fields",
        "aliased-field-zero",
        "typedef-class-field",
        "two-aliased-class-fields",
        "aliased-field-initializer",
    ),
    "Language/Typedef/Handle": (
        "typedef-handle",
        "handle-alias-local",
    ),
    "Language/Typedef/HandleCompileFail": (
        "invalid-handle-alias-of-unknown-class",
    ),
    "Language/Typedef/InReturn": (
        "typedef-in-return",
        "typedef-return-of-float",
        "typedef-return-from-method",
    ),
}

RETIRED_FLAT_TAGS = (
    "Language/Typedef",
    "Language/TypedefCompileFail",
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


class TypedefAuthorTests(unittest.TestCase):
    def test_TypedefSlicesParseWithRequiredBegins(self) -> None:
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

    def test_RetiredTypedefFlatAbsent(self) -> None:
        sources = discover_sources(AUTHOR_ROOT)
        file_tags = {source.file_tag for source in sources}
        for retired in RETIRED_FLAT_TAGS:
            self.assertNotIn(retired, file_tags)


if __name__ == "__main__":
    unittest.main()
