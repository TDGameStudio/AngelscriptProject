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

REQUIRED_CONTAINER_TAGS = (
    "Containers/TArray",
    "Containers/TArrayCompileFail",
    "Containers/TArrayRuntimeFail",
    "Containers/TMap",
    "Containers/TSet",
    "Containers/TOptional",
    "Containers/TSoftObjectPtr",
    "Containers/TWeakObjectPtr",
    "Containers/TSubclassOf",
    "Containers/TObjectPtr",
    "Containers/SoftObjectPath",
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


class HostApiAuthorTests(unittest.TestCase):
    def test_containers_tarray_parses(self) -> None:
        parsed = parse_author("Containers/TArray")
        self.assertEqual("Containers/TArray", parsed.source.file_tag)
        self.assertEqual("v1", parsed.format_version)
        self.assertTrue(parsed.versions)
        self.assertTrue(any(version.parent is None for version in parsed.versions))

    def test_tarray_runtime_fail_from_pending(self) -> None:
        parsed = parse_author("Containers/TArrayRuntimeFail")
        tags = {version.tag for version in parsed.versions}
        self.assertIn("index-out-of-bounds", tags)

    def test_discovery_admits_containers_skips_pending(self) -> None:
        sources = discover_sources(AUTHOR_ROOT)
        file_tags = {source.file_tag for source in sources}
        relative_paths = {source.relative_path for source in sources}
        self.assertIn("Containers/TArray", file_tags)
        self.assertNotIn("Pending/Containers/TArray/TArraySetNumGrow", file_tags)
        self.assertNotIn("Pending/Containers/TArray/TArraySetNumGrow.as", relative_paths)

    def test_required_container_pockets_parse(self) -> None:
        for file_tag in REQUIRED_CONTAINER_TAGS:
            with self.subTest(file_tag=file_tag):
                parsed = parse_author(file_tag)
                self.assertEqual(file_tag, parsed.source.file_tag)
                self.assertEqual("v1", parsed.format_version)
                self.assertTrue(parsed.versions)
                self.assertTrue(any(version.parent is None for version in parsed.versions))

    def test_unreal_fmath_parses(self) -> None:
        parsed = parse_author("Unreal/FMath")
        self.assertTrue(parsed.source.file_tag.startswith("Unreal/"))
        self.assertEqual("v1", parsed.format_version)
        self.assertTrue(parsed.versions)
        self.assertTrue(any(version.parent is None for version in parsed.versions))

    def test_actor_not_under_containers(self) -> None:
        sources = discover_sources(AUTHOR_ROOT)
        file_tags = {source.file_tag for source in sources}
        self.assertNotIn("Containers/AActor", file_tags)

    def test_pending_math_merged(self) -> None:
        parsed = parse_author("Unreal/FVector")
        tags = {version.tag for version in parsed.versions}
        self.assertIn("equals", tags)
        self.assertIn("construction", tags)
        sources = discover_sources(AUTHOR_ROOT)
        file_tags = {source.file_tag for source in sources}
        self.assertNotIn("Pending/Math/FVector/FVectorConstruction", file_tags)


if __name__ == "__main__":
    unittest.main()
