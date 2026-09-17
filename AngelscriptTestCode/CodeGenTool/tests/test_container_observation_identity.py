from __future__ import annotations

import re
import sys
import unittest
from pathlib import Path

TOOL_ROOT = Path(__file__).resolve().parents[1]
AUTHOR_ROOT = TOOL_ROOT.parent
sys.path.insert(0, str(TOOL_ROOT))

from angelscript_test_codegen.container_parser import parse_source_file
from angelscript_test_codegen.model import SourceInput

CONTAINERS = AUTHOR_ROOT / "Containers"

# Bare API / method-alias stems. Type-axis files (ContainsKeyFString) are not listed.
METHOD_ALIAS_STEMS = frozenset(
    {
        "AddElement",
        "AddOverwrite",
        "AddPair",
        "Capacity",
        "ContainsValue",
        "FindIndex",
        "FindMissing",
        "FindOrAdd",
        "FindValue",
        "Get",
        "GetAllocatedSize",
        "GetAssetName",
        "GetAssetPath",
        "GetKey",
        "GetKeys",
        "GetLongPackageName",
        "GetSlack",
        "GetValue",
        "GetValues",
        "IndexAccess",
        "IsAsset",
        "IsEmpty",
        "IsNull",
        "IsPending",
        "IsSet",
        "IsSubobject",
        "IsValid",
        "IsValidIndex",
        "LoadAsync",
        "RemoveElement",
        "RemoveKey",
        "Reset",
        "ResolveClass",
        "ResolveObject",
        "SetNum",
        "SetNumZeroed",
        "ToSoftObjectPath",
        "ToString",
        "TryLoad",
        "TryLoadClass",
    }
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


def parse_author(relative_path: str):
    path = AUTHOR_ROOT / Path(relative_path)
    return parse_source_file(make_source(relative_path, path.read_bytes(), path))


class ContainerObservationIdentityTests(unittest.TestCase):
    def test_AddAndOrderEntryMatchesStem(self) -> None:
        parsed = parse_author("Containers/TArray/AddAndOrder.as")
        self.assertEqual("AddAndOrder", parsed.versions[0].tag)
        self.assertIn(b"bool AddAndOrder(", parsed.versions[0].clean_source)

    def test_EveryAuthorMatchesObservationIdentity(self) -> None:
        authors = sorted(CONTAINERS.rglob("*.as"))
        self.assertGreater(len(authors), 0)
        for path in authors:
            relative = path.relative_to(AUTHOR_ROOT).as_posix()
            stem = path.stem
            with self.subTest(relative=relative):
                self.assertNotIn(stem, METHOD_ALIAS_STEMS)
                raw = path.read_bytes()
                self.assertRegex(
                    raw.decode("utf-8"),
                    rf"(?m)^\s*\*\s+{re.escape(stem)}(?:\s+//\s+\S.*)?\s*$",
                    "file header must list the version tag",
                )
                parsed = parse_author(relative)
                self.assertEqual(1, len(parsed.versions), relative)
                version = parsed.versions[0]
                self.assertEqual(stem, version.tag, relative)
                self.assertIsNone(version.parent, relative)
                clean = version.clean_source
                clean_text = clean.decode("utf-8")
                has_entry = (
                    re.search(
                        rf"(?m)^(?:UFUNCTION\(\)\s*)?[\w:<>,\s]+\s+{re.escape(stem)}\s*\(",
                        clean_text,
                    )
                    is not None
                )
                class_only = b"UCLASS()" in clean and not has_entry
                self.assertTrue(
                    has_entry or class_only,
                    f"{relative}: entry function must be {stem}(), or a class-only program",
                )


if __name__ == "__main__":
    unittest.main()
