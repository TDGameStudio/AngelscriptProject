from __future__ import annotations

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
GLOSSARY_LEAVES = (
    "Unreal/Casting",
    "Unreal/Strings",
    "Unreal/GarbageCollection",
    "Unreal/Input",
    "Unreal/Events",
    "Unreal/Reflection",
    "Unreal/ActorClass",
    "Unreal/Hooks",
    "Unreal/World/Actor",
    "Unreal/World/Component",
    "Unreal/World/Blueprint",
    "Unreal/World/Streaming",
    "Unreal/World/Subsystem",
)


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


def is_glossary_or_fail(file_tag: str) -> bool:
    for leaf in GLOSSARY_LEAVES:
        if file_tag == leaf or file_tag == f"{leaf}CompileFail" or file_tag == f"{leaf}RuntimeFail":
            return True
    return False


class UnrealAuthorTests(unittest.TestCase):
    def test_unreal_pockets_parse(self) -> None:
        for file_tag in GLOSSARY_LEAVES:
            with self.subTest(file_tag=file_tag):
                path = author_path(file_tag)
                self.assertTrue(path.is_file(), f"missing {path.as_posix()}")
                parsed = parse_tag(file_tag)
                self.assertEqual(file_tag, parsed.source.file_tag)
                self.assertTrue(parsed.source.file_tag.startswith("Unreal/"))
                self.assertTrue(is_glossary_or_fail(parsed.source.file_tag))
                self.assertEqual("v1", parsed.format_version)
                self.assertTrue(
                    any(version.parent is None for version in parsed.versions),
                    f"{file_tag} has no parentless version",
                )
                self.assertFalse(
                    any(version.tag == "root" for version in parsed.versions),
                    f"{file_tag} still uses privileged root",
                )
                self.assertIn("Unreal", parsed.topics)

    def test_casting_is_not_language(self) -> None:
        unreal = author_path("Unreal/Casting")
        language = AUTHOR_ROOT / "Language" / "Casting" / "ClassHandleCast.as"
        self.assertTrue(unreal.is_file(), f"missing {unreal.as_posix()}")
        self.assertTrue(language.is_file())
        unreal_parsed = parse_tag("Unreal/Casting")
        language_parsed = parse_source_file(
            make_source(
                "Language/Casting/ClassHandleCast.as",
                language.read_bytes(),
                language,
            )
        )
        self.assertEqual("Unreal/Casting", unreal_parsed.source.file_tag)
        self.assertEqual("Language/Casting/ClassHandleCast", language_parsed.source.file_tag)
        unreal_bodies = b"".join(version.clean_source for version in unreal_parsed.versions)
        language_bodies = b"".join(version.clean_source for version in language_parsed.versions)
        self.assertIn(b"UCLASS", unreal_bodies)
        self.assertNotIn(b"UCLASS", language_bodies)
        self.assertTrue(
            any(b"Cast<" in version.clean_source for version in unreal_parsed.versions)
        )

    def test_discovery_admits_unreal(self) -> None:
        self.assertTrue(
            (AUTHOR_ROOT / "Pending" / "Language" / "Casting" / "UClass" / "ObjectCastAndTypeChecks.as").is_file()
        )
        sources = discover_sources(AUTHOR_ROOT)
        relative_paths = [source.relative_path.replace("\\", "/") for source in sources]
        file_tags = [source.file_tag.replace("\\", "/") for source in sources]
        self.assertIn("Unreal/Casting.as", relative_paths)
        self.assertIn("Unreal/Casting", file_tags)
        self.assertFalse(
            any(path.startswith("Pending/") for path in relative_paths)
        )
        self.assertNotIn(
            "Pending/Language/Casting/UClass/ObjectCastAndTypeChecks.as",
            relative_paths,
        )


if __name__ == "__main__":
    unittest.main()
