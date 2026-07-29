from __future__ import annotations

import sys
from pathlib import Path

import pytest


sys.path.insert(0, str(Path(__file__).parents[1] / "src"))

from angelscript_codegen.web.scenarios import ScenarioNotFoundError, get_scenario, list_scenarios


def test_reviewed_preview_scenarios_map_to_existing_profiles_and_profile_limits() -> None:
    scenarios = list_scenarios()

    assert [(scenario.id, scenario.profile_id) for scenario in scenarios] == [
        ("native-control-flow", "native-core"),
        ("ue-value-environment", "ue-values"),
        ("uclass-annotation", "ue-annotated"),
        ("actor-lifecycle", "ue-world"),
    ]
    assert [(scenario.max_depth, scenario.max_statements) for scenario in scenarios] == [
        (3, 8),
        (4, 12),
        (4, 16),
        (5, 20),
    ]
    assert all(scenario.title_zh and scenario.description_zh for scenario in scenarios)


def test_ue_value_environment_copy_does_not_promise_unimplemented_value_expression_generation() -> None:
    scenario = get_scenario("ue-value-environment")

    assert scenario.profile_id == "ue-values"
    assert "能力环境" in scenario.description_zh
    assert "FVector" not in scenario.description_zh
    assert "FString" not in scenario.description_zh


def test_unknown_preview_scenario_is_rejected() -> None:
    with pytest.raises(ScenarioNotFoundError, match="not-present"):
        get_scenario("not-present")
