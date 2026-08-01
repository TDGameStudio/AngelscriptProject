## Why

`Documents/Reports/` contains 13 substantive review reports (plus 2,653 auto-generated `FunctionReview_*` files) that together identify a large body of architecture-level debt in the Angelscript plugin. That material is currently unusable as a work driver for three reasons:

1. **It is stale.** The reports are dated 2026-05-11 through 2026-06-03. Since then 104 OpenSpec changes were archived (2026-05-12 → 2026-07-30). Several report findings are already fixed, and a few have measurably **regressed** — so acting on the reports directly would waste effort on solved problems and understate live ones.
2. **It is not indexed against OpenSpec.** There is no mapping from a report finding to the change that covers it, so it is impossible to tell what is tracked and what is not.
3. **`Documents/Reports/` is not a lifecycle surface.** Per `AGENTS.md`, all planning and tracking lives in `openspec/changes/`. Findings parked in reports never enter the task lifecycle.

This change records a **verified** architecture-debt registry: every finding re-checked against the code as of 2026-07-31, classified as still-true / partly-fixed / fixed / regressed, and mapped to either an existing OpenSpec change or an explicit "not covered" gap.

This is a **record-and-triage change, not an implementation change.** It deliberately does not fix the debt. Its output is a verified registry plus follow-up change proposals, so that remediation lands as separately scoped changes with their own verification.

## What Changes

- Record the verified architecture-debt registry in `findings.md`, one row per finding with current-state evidence (`file:line`), verification verdict, and OpenSpec coverage mapping.
- Record the verification method and the discrepancies found between the reports and current code in `verification.md`, including findings whose severity **increased** since the reports were written.
- Establish a durable requirement that architecture findings carry a re-verification date and a coverage mapping, so a finding cannot be cited as live without evidence.
- Identify the themes with **no** OpenSpec coverage — hot-reload thread-safety, remaining god objects, ThirdParty include boundary, dual execution-path divergence — as candidate follow-up changes.
- Mark the superseded reports in `Documents/Reports/` as historical, pointing at this registry as the current source of truth.

Explicitly out of scope: fixing any finding. No plugin source is modified by this change.

## Capabilities

### New Capabilities

- `plugin-architecture-debt-registry`: Defines what a recorded architecture finding must contain (current-state evidence, verification date and verdict, coverage mapping) for it to drive work.

## Impact

- `openspec/changes/docs-plugin-architecture-debt-audit/` — registry, verification record, and spec delta.
- `Documents/Reports/` — superseded-notice only; report content is retained for history.
- No change to `Plugins/Angelscript/` source. Follow-up remediation changes will carry that impact.

## Key Findings Summary

Verified against the code on 2026-07-31. Full detail in `findings.md`.

**Regressed since the reports (worse now than when measured):**

| Finding | Then | Now |
| --- | --- | --- |
| Direct `#include "source/as_*.h"` outside a central entry header | 152 | 203 |
| `AS_*` static constants in `Bind_Primitives.cpp` using non-UE prefix | 31 | 42 |
| `AngelscriptEditorCodeGen.cpp` dead/commented lines | 588 | 593 |

**Fixed since the reports — do not re-open:**

- `AngelscriptClassGenerator.cpp` — was ~208 KB monolith, now split across 7 files (coordinator + Analyze/FullReload/SoftReload/Finalize/ReloadPlanning/Reinstancing).
- `ASClass.cpp` — was ~100 KB, now 18 lines plus `ASClass_Construction.cpp` / `ASClass_Metadata.cpp`.
- UE-side hook fragmentation — consolidated behind `FAngelscriptEngineExtensionRegistry` and inlined `FAngelscriptEngine` delegate accessors, removing 133 indirect call sites.
- `ActiveTickOwners` — identifier no longer exists.

**Still true and not covered by any active OpenSpec change:**

- Hot-reload thread-safety cluster: `GAmbientWorldContext` (`AngelscriptEngine.cpp:249`, volatile-cast write / unguarded read at :443), `volatile bool bWaitingForHotReloadResults` (`AngelscriptEngine.h:572`), `FileChangesDetectedForReload` Add/Empty across threads (`AngelscriptEngine.h:658`), non-atomic `LastFileChangeDetectedTime` (`AngelscriptEngine.h:660`), check-then-set on `bHotReloadThreadStarted` (`AngelscriptEngine.cpp:2146-2148`).
- Confirmed data race: `bHadCompileErrors` written from the `ParallelFor` worker lambda at `AngelscriptEngine.cpp:3911` with no atomic.
- Remaining god objects: `AngelscriptEngine.cpp` 6,639 lines with `CompileModules()` alone at **1,247 lines**; `AngelscriptBytecodes.cpp` 6,747; `AngelscriptPreprocessor.cpp` 4,769; `AngelscriptStaticJIT.cpp` 3,970; `AngelscriptDebugServer.cpp` 3,328. `AngelscriptEditorCodeGen.cpp` is 2,812 lines with **no header file**.
- Dual execution paths that can silently diverge: `CallBlueprintCallableReflectiveFallback()` cached-vs-legacy behind `as.ReflectiveFallback.UseCache`, with the helper's `bool` return **ignored** at `BlueprintCallableReflectiveFallback.cpp:713,722`; `AngelscriptCallFromBPVM()` JIT-vs-context paths each marshalling parameters independently, JIT sizing `VMArgs` by the unchecked formula `Alloca(8 * ArgumentCount + 16)` (`ASFunction_CallHelpers.h:156`).
- Out-param bounds check present in the legacy path (`:632`) but **absent** in the cached path (`:430`); only bind-time validation prevents overflow.
- `vfTableIdx` not re-validated after hot reload — guarded by `checkSlow()` only, so shipping builds carry no check.
- Busy-wait `while (!bInitializationDone)` with `Sleep(0.002f)` and no timeout (`AngelscriptEngine.cpp:962-967`).
- No UE multicast delegate for script exceptions; no post-`CallBinds()` hook for external modules; no GC start/finish events; `SetTranslateAppExceptionCallback` never registered (fork builds with `AS_NO_EXCEPTIONS`).
- `SetInstructionCallback` still patched into the vendored `as_context.cpp` hot loop (`:1682`) despite the instrumentation review recommending removal — carries per-instruction cost and fork-maintenance burden.
- `Binds/` still holds full `UCLASS` definitions (`UObjectInWorld.h`, `UObjectTickable.h`) rather than bindings only.
- 11 virtual functions missing `override`; 8 internal helper structs exported via `ANGELSCRIPTRUNTIME_API`; 168/212 `BlueprintCallable` functions lack `Category`; `AS_FORCE_LINK` defined twice (`AngelscriptBinds.h:32,34` and `StaticJITHeader.h:43,45`).

**Already covered — mapped, not re-proposed:** UHT binding pipeline (`refactor-uht-plugin-hardening`, `refactor-uht-binding-registry`, `refactor-function-binding-strategy`), manual binding architecture (`refactor-as-manual-binding-architecture`), test-module architecture (`refactor-as-native-sdk-regression-suite`, `refactor-as-reflected-script-test-suites`, `test-as-native-sdk-comprehensive-coverage`), automation reliability (`fix-automation-suite-reliability`), global-state research (`docs-as-mutable-global-feasibility`), memory leaks (archived `fix-as-engine-shutdown-memory-leak`), wiki toolchain (5 wiki changes).
