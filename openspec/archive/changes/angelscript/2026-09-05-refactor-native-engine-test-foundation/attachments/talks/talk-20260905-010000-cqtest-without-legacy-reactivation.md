# CQTest without legacy framework reactivation

## Context

The reconstruction baseline needs expressive C++ unit tests, but the old AngelScript test corpus and its framework were intentionally quarantined. The current module exposes `CQTest` only inside the disabled legacy dependency branch, while the only replacement baseline uses plain Unreal Automation.

## Evidence

- `Plugins/Angelscript/Source/AngelscriptTest/AngelscriptTest.Build.cs` places `CQTest`, the legacy force include, editor dependencies, and legacy include paths under the same `bCompileLegacyTests` condition.
- `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/AngelscriptIsolationBaselineTests.cpp` proves replacement discovery without legacy helpers.
- The archived quarantine Change measured the same three-test baseline at about 27.0 seconds ordinary and 26.8 seconds Fast, while test execution itself was about 0.13 seconds.
- `.agents/skills/angelscript-test-guide/SKILL.md` correctly treats current CQTest instructions as legacy-only until a new explicit Change establishes a replacement contract.

## Options

1. Continue using only plain Unreal Automation. This preserves isolation but gives each new frontend area a weaker scenario and matcher layer.
2. Restore the legacy CQTest force include and fixtures. This would reintroduce hidden dependencies, engine lifecycle, and the quarantined framework.
3. Expose CQTest independently and create replacement-local fixtures. This retains isolation while using the maintained UE testing library.

## Settled Decision

Use option 3. CQTest itself is not the legacy framework. Replacement tests include it explicitly under `WITH_ANGELSCRIPT_TESTS`; no legacy header, macro, engine pool, or prefix becomes reachable. The initial plain-Automation baseline remains unchanged.

## Consequences and Flip Condition

Each frontend Change owns one exact `Angelscript.UnitTest.NativeEngine.<Area>` prefix. Scenario methods remain individually visible but share one managed UE process. Reconsider the process model only if a future supported Harness capability can preserve Automation discovery, isolation, reporting, cancellation, and exit validation while materially reducing measured startup cost.

## Visual

```text
WITH_ANGELSCRIPT_TESTS=1
        |
        +-- explicit CQTest dependency
        +-- NewVersion/NativeEngine support
        `-- Angelscript.UnitTest.NativeEngine.*

WITH_ANGELSCRIPT_UNITTESTS=0
        `-- Legacy/.ubtignore + old framework remain unreachable
```

## Sources

- `Plugins/Angelscript/Source/AngelscriptTest/AngelscriptTest.Build.cs`
- `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/AngelscriptIsolationBaselineTests.cpp`
- `openspec/archive/changes/angelscript/2026-09-04-refactor-legacy-runtime-tests-quarantine/attachments/data/test-startup-timing.md`
- `.agents/skills/angelscript-test-guide/SKILL.md`
