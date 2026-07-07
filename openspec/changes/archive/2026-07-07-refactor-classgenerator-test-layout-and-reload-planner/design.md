## Context

`FAngelscriptClassGenerator` currently owns both dependency discovery and requirement propagation. Existing reload tests compile AngelScript modules to observe the result, which is still needed for script integration, but it makes the pure propagation rules harder to reason about.

## Goals / Non-Goals

**Goals:**

- Keep existing reload behavior stable.
- Separate generator test files by semantic area.
- Use the `Generator` test directory and Automation prefix for the test-facing theme while leaving runtime `ClassGenerator` implementation names intact.
- Extract only the pure propagation graph into a testable runtime seam.
- Leave script parsing, type discovery, reflected-surface comparison, and reload execution inside `FAngelscriptClassGenerator`.

**Non-Goals:**

- Rewrite class generation or hot reload.
- Change script-visible behavior.

## Decisions

- Add `FAngelscriptClassReloadPlanner` under `AngelscriptRuntime/ClassGenerator` with exported API so `AngelscriptTest` can directly test it.
- Use opaque node handles and a fixed-point propagation pass. A consumer depends on a provider; the provider's higher reload requirement propagates to the consumer. Cycles converge because requirements only increase across a finite enum.
- Keep generator-owned dependency discovery in `AngelscriptClassGenerator_ReloadPlanning.cpp`, then synchronize discovered edges into the planner.
- Group test files under `AngelscriptTest/Generator` by AS surface (`ASClass`, `ASFunction`, `ASStruct`, `ScriptClass`) and generator concerns (`ReloadPlanning`, `ComponentValidation`, `Core`).
- Rename Automation prefixes from `Angelscript.TestModule.ClassGenerator.*` to `Angelscript.TestModule.Generator.*`.

## Risks / Trade-offs

- Directory moves can obscure diffs; mitigation is no content churn during moves except where includes or docs require it.
- A pure planner seam does not replace integration tests; mitigation is keeping existing reload propagation tests under `ReloadPlanning`.
- `Error` remains the highest requirement by enum order; planner tests pin that ordering.
