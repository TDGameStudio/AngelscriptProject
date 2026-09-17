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

PRODUCES_FILE_TAGS = (
    "Language/Destructors/ClassDestructor",
    "Language/Destructors/ClassDestructorCompileFail",
    "Language/Destructors/StructDestructor",
    "Language/Destructors/StructDestructorCompileFail",
    "Language/Destructors/Inheritance",
)

REQUIRED_BEGINS = {
    "Language/Destructors/ClassDestructor": (
        "class-destructor",
        "destructor-reads-field",
        "destructor-reads-two-fields",
    ),
    "Language/Destructors/ClassDestructorCompileFail": (
        "invalid-destructor-return-type",
        "invalid-duplicate-destructor",
        "invalid-global-destructor",
        "invalid-destructor-wrong-name",
        "invalid-destructor-with-parameter",
    ),
    "Language/Destructors/StructDestructor": (
        "struct-destructor",
        "struct-destructor-reads-field",
    ),
    "Language/Destructors/StructDestructorCompileFail": (
        "invalid-struct-destructor-return-type",
        "invalid-struct-destructor-with-parameter",
    ),
    "Language/Destructors/Inheritance": (
        "base-and-derived",
        "derived-destructor-only",
        "base-destructor-only",
    ),
}

RETIRED_FLAT_TAGS = (
    "Language/Destructors",
    "Language/DestructorsCompileFail",
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


class DestructorsAuthorTests(unittest.TestCase):
    def test_DestructorSlicesParseWithRequiredBegins(self) -> None:
        parsed_tags: list[str] = []
        for file_tag, expected in REQUIRED_BEGINS.items():
            path = AUTHOR_ROOT / Path(f"{file_tag}.as")
            with self.subTest(file_tag=file_tag):
                self.assertTrue(path.is_file(), f"missing {path.as_posix()}")
                parsed = parse_author(file_tag)
                parsed_tags.append(parsed.source.file_tag)
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
                self.assertEqual(expected, tuple(version.tag for version in parsed.versions))

        self.assertEqual(list(PRODUCES_FILE_TAGS), parsed_tags)

    def test_RetiredDestructorsFlatAbsent(self) -> None:
        sources = discover_sources(AUTHOR_ROOT)
        file_tags = {source.file_tag for source in sources}
        for retired in RETIRED_FLAT_TAGS:
            with self.subTest(retired=retired):
                self.assertNotIn(retired, file_tags)


if __name__ == "__main__":
    unittest.main()
