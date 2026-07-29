from __future__ import annotations

import sys
from pathlib import Path


sys.path.insert(0, str(Path(__file__).parents[1] / "src"))

from angelscript_codegen.profiles.loader import built_in_profile_directory, load_profile


def test_builtin_profiles_form_the_declared_native_to_world_hierarchy() -> None:
    directory = built_in_profile_directory()

    native = load_profile("native-core", directory)
    values = load_profile("ue-values", directory)
    annotated = load_profile("ue-annotated", directory)
    world = load_profile("ue-world", directory)

    assert native.harness == "native-sdk"
    assert {"int", "bool"} <= set(native.types)
    assert native.evidence
    assert {"FString", "FVector", "TArray<int>"} <= set(values.types)
    assert values.evidence
    assert "annotated-class" in {fragment.id for fragment in annotated.fragments}
    assert all(fragment.evidence for fragment in annotated.fragments)
    assert world.harness == "ue-world"
    assert "actor-lifecycle" in {fragment.id for fragment in world.fragments}
    assert {"int", "FVector", "AActor"} <= set(world.types)
    assert "type-mismatch" in world.invalid_rules
    assert {"ue-world", "actor-lifecycle"} <= set(world.contexts)
