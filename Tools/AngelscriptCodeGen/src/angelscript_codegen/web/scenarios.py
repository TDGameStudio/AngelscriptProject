from __future__ import annotations

from dataclasses import dataclass

from angelscript_codegen.profiles.loader import built_in_profile_directory, load_profile


class ScenarioNotFoundError(ValueError):
    """Raised when a Web preview requests an unknown reviewed scenario."""


@dataclass(frozen=True)
class PreviewScenario:
    id: str
    profile_id: str
    title_zh: str
    description_zh: str
    max_depth: int
    max_statements: int


_SCENARIO_COPY: tuple[tuple[str, str, str, str], ...] = (
    (
        "native-control-flow",
        "native-core",
        "原生表达式与控制流",
        "生成可复现的 int/bool 表达式、条件分支、循环与类型化返回。",
    ),
    (
        "ue-value-environment",
        "ue-values",
        "UE 值类型能力环境",
        "使用受审查的 UE 值类型能力环境；当前随机函数体仍使用原生 int/bool 表达式。",
    ),
    (
        "uclass-annotation",
        "ue-annotated",
        "UCLASS 注解类",
        "在有效函数样本前加入受审查的 UCLASS、UPROPERTY 与 UFUNCTION 源码片段。",
    ),
    (
        "actor-lifecycle",
        "ue-world",
        "Actor 生命周期",
        "在注解类上下文中加入受审查的 AActor BeginPlay 生命周期源码片段。",
    ),
)


def list_scenarios() -> tuple[PreviewScenario, ...]:
    directory = built_in_profile_directory()
    scenarios: list[PreviewScenario] = []
    for scenario_id, profile_id, title_zh, description_zh in _SCENARIO_COPY:
        profile = load_profile(profile_id, directory)
        scenarios.append(
            PreviewScenario(
                id=scenario_id,
                profile_id=profile_id,
                title_zh=title_zh,
                description_zh=description_zh,
                max_depth=profile.limits["max_depth"],
                max_statements=profile.limits["max_statements"],
            )
        )
    return tuple(scenarios)


def get_scenario(scenario_id: str) -> PreviewScenario:
    for scenario in list_scenarios():
        if scenario.id == scenario_id:
            return scenario
    raise ScenarioNotFoundError(f"Unknown preview scenario '{scenario_id}'.")
