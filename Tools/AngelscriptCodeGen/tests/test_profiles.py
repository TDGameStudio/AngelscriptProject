from __future__ import annotations

import json
import sys
from pathlib import Path

import pytest


sys.path.insert(0, str(Path(__file__).parents[1] / "src"))

from angelscript_codegen.profiles.loader import ProfileValidationError, load_profile


def write_profile(directory: Path, name: str, document: dict[str, object]) -> None:
    (directory / f"{name}.json").write_text(json.dumps(document), encoding="utf-8")


def test_profile_inherits_types_and_callables_from_its_parent(tmp_path: Path) -> None:
    write_profile(
        tmp_path,
        "native-core",
        {
            "schema_version": 1,
            "id": "native-core",
            "harness": "native-sdk",
            "types": [{"name": "int", "kind": "primitive"}],
            "callables": [
                {"name": "Record", "return_type": "void", "parameters": ["int"]}
            ],
            "fragments": [],
            "invalid_rules": ["type-mismatch"],
            "limits": {"max_depth": 3},
        },
    )
    write_profile(
        tmp_path,
        "ue-values",
        {
            "schema_version": 1,
            "id": "ue-values",
            "extends": "native-core",
            "harness": "ue-module",
            "types": [{"name": "FVector", "kind": "value"}],
            "callables": [
                {"name": "Length", "return_type": "int", "parameters": ["FVector"]}
            ],
            "fragments": [],
            "invalid_rules": ["missing-required-context"],
            "limits": {"max_statements": 10},
        },
    )

    profile = load_profile("ue-values", tmp_path)

    assert profile.id == "ue-values"
    assert profile.harness == "ue-module"
    assert tuple(profile.types) == ("int", "FVector")
    assert tuple(callable.name for callable in profile.callables) == ("Record", "Length")
    assert profile.invalid_rules == ("type-mismatch", "missing-required-context")
    assert profile.limits == {"max_depth": 3, "max_statements": 10}


def test_profile_rejects_callable_references_to_unknown_types(tmp_path: Path) -> None:
    write_profile(
        tmp_path,
        "broken",
        {
            "schema_version": 1,
            "id": "broken",
            "harness": "native-sdk",
            "types": [{"name": "int", "kind": "primitive"}],
            "callables": [
                {"name": "Missing", "return_type": "MissingType", "parameters": []}
            ],
            "fragments": [],
            "invalid_rules": [],
            "limits": {},
        },
    )

    with pytest.raises(ProfileValidationError, match="MissingType"):
        load_profile("broken", tmp_path)


def test_profile_rejects_unknown_parent(tmp_path: Path) -> None:
    write_profile(
        tmp_path,
        "child",
        {
            "schema_version": 1,
            "id": "child",
            "extends": "not-present",
            "harness": "native-sdk",
            "types": [],
            "callables": [],
            "fragments": [],
            "invalid_rules": [],
            "limits": {},
        },
    )

    with pytest.raises(ProfileValidationError, match="not-present"):
        load_profile("child", tmp_path)


def test_profile_rejects_fragment_context_not_declared_by_the_profile(tmp_path: Path) -> None:
    write_profile(
        tmp_path,
        "broken-fragment",
        {
            "schema_version": 1,
            "id": "broken-fragment",
            "harness": "native-sdk",
            "types": [{"name": "int", "kind": "primitive"}],
            "callables": [],
            "fragments": [
                {
                    "id": "world-only",
                    "requires": ["ue-world"],
                    "source": "void GeneratedFragment() {}",
                }
            ],
            "invalid_rules": [],
            "limits": {},
        },
    )

    with pytest.raises(ProfileValidationError, match="ue-world"):
        load_profile("broken-fragment", tmp_path)


def test_profile_inherits_explicit_contexts_used_by_child_fragments(tmp_path: Path) -> None:
    write_profile(
        tmp_path,
        "parent",
        {
            "schema_version": 1,
            "id": "parent",
            "harness": "native-sdk",
            "contexts": ["actor-lifecycle"],
            "types": [{"name": "int", "kind": "primitive"}],
            "callables": [],
            "fragments": [],
            "invalid_rules": [],
            "limits": {},
        },
    )
    write_profile(
        tmp_path,
        "child",
        {
            "schema_version": 1,
            "id": "child",
            "extends": "parent",
            "harness": "ue-world",
            "types": [],
            "callables": [],
            "fragments": [
                {
                    "id": "lifecycle",
                    "requires": ["actor-lifecycle", "ue-world"],
                    "source": "void GeneratedFragment() {}",
                }
            ],
            "invalid_rules": [],
            "limits": {},
        },
    )

    profile = load_profile("child", tmp_path)

    assert profile.contexts == ("native-sdk", "actor-lifecycle", "ue-world")
