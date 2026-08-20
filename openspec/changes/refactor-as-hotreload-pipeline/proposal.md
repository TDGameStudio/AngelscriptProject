## Why

Hot reload is already a working cross-module pipeline (Editor watcher or standalone file-time thread → Engine Tick → preprocess/compile → ClassGenerator Setup/planner → soft or full reload → ClassReloadHelper reinstancing → BlueprintImpact). Production files are already split (`_Analyze` / `_SoftReload` / `_FullReload` / `_ReloadPlanning` / `_Reinstancing`). The remaining refactor is **not** “split the god `.cpp` again”. It is: freeze ownership, stop Editor/Runtime from eating each other’s internals, give reloads a stable script identity, and stop authoring every v1/v2 body inside CQTest. Test authoring is a sibling change; this change is the pipeline map and the production-boundary work.

## What Changes

- Record the HotReload pipeline as **seven stages** with a frozen Runtime / Editor / Test ownership table. Do not merge ClassReloadHelper into Runtime, and do not teach Runtime to refresh BlueprintActionDatabase.
- Sequence production cleanup **after** the test corpus (`test-as-hotreload-script-corpus`): `FReloadState` is still a process-wide static; `ClassReloadHelper.h` still mixes UE Editor headers with ClassGenerator internals; ClassGenerator still carries editor-only branches (re-count at apply time; the 2026-06-30 audit numbers are stale after the file split).
- Treat compile/reload **identity** (module + filename / virtual path) as a first-class contract so watcher, `AnalyzeReloadFromMemory`, and the TestCorpus key agree.
- Explicitly **not** an engine-profile DataDriven leaf (`vm` / cache / JIT). Soft-reload JIT dispatch already rereads the current binding; do not cartesian HotReload pairs onto StaticJIT generate in this change.
- Plan-only in this recording session. No ClassGenerator behavior change in Wave A.

## Capabilities

### New Capabilities

- `as-hotreload-pipeline-boundaries`: Stage list, module ownership, forbidden merges, relationship to the test corpus and the engine-matrix harness.
- `as-hotreload-editor-recovery-isolation`: Editor recovery (`FClassReloadHelper` / `FReloadState`) stays Editor-owned; test hooks and engine subscription must not keep expanding as process-wide statics without a recorded partition plan.

### Modified Capabilities

- None. Reload classification (`EReloadRequirement` lattice) and existing `hotreload-test-coverage` stay. This change does not rewrite planner policy.

## Impact

- Future production edits under `AngelscriptRuntime/ClassGenerator/`, `AngelscriptRuntime/Core` (`CheckForHotReload` / `PerformHotReload`), `AngelscriptEditor/HotReload/`, `AngelscriptEditor/BlueprintImpact/`.
- Sibling OpenSpec: `test-as-hotreload-script-corpus` (test pairs + COMPLEX analyze leaves). Prerequisite corpus API: `test-as-data-driven-engine-harness` Decision 16.
- Docs: `Documents/Knowledges/ZH/RT_HotReload.md`, pipeline wiki supplements, Chinese-first `AGENTS_ZH.md` / Test layering at apply time.
- Dual-repo later: OpenSpec in parent, code in `Plugins/Angelscript`.
