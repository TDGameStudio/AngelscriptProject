## Context

Hot reload is a **state pipeline**, not a single `Recompile()` call. Wiki already describes it (`reload-pipeline-internals`, `RT_HotReload.md`). Runtime ClassGenerator is already physically split. Editor recovery is `FClassReloadHelper` plus BlueprintImpact. Tests live in `AngelscriptTest/HotReload/` with inline v1/v2 AS.

A 2026-06-30 runtime audit (`Documents/Guides/RuntimeArchitectureAudit_20260630.md` §D) still names the real production debts: Runtime files with editor branches, Editor helper including ClassGenerator internals, `ClassReloadHelper.h` mixing UnrealEd + Runtime, and three `*TestHooks` structs on the production helper. `FClassReloadHelper` comments already admit `FReloadState` is a **single static** after deglobalization of engine delegates.

This change freezes the refactor map. It does **not** start by rewriting `AngelscriptClassGenerator_Analyze.cpp`. Test-pair extraction is `test-as-hotreload-script-corpus`.

This record is plan-only.

## Goals / Non-Goals

**Goals:**

- One ownership table everyone uses when touching reload.
- Ordered workstreams: tests → identity → Editor recovery isolation → optional header splits. Each stream has a verification prefix.
- Make `FReloadState` / helper includes a recorded problem with a partition plan, not an accidental global.
- Keep watcher (Editor) and file-time thread (standalone `bScriptDevelopmentMode`) as **two signal sources** into the same Engine queues.

**Non-Goals:**

- Change `EReloadRequirement` order or planner `>` lattice (`SoftReload < FullReloadSuggested < FullReloadRequired < Error`).
- Merge Runtime ClassGenerator with Editor ClassReloadHelper.
- Add HotReload as a DataDriven engine profile.
- Rewrite `AngelscriptClassGenerator_Analyze.cpp` as Wave A.
- Cartesian reload pairs against Cache V2 / typed-ast / Runtime JIT in this change.
- Move BlueprintImpact scanner into Runtime.
- Replace existing HotReload CQTest wholesale (that is the corpus sibling, dual-run).
- Trust 2026-06-30 line counts for `AngelscriptClassGenerator.cpp` (~5000 lines in that audit). The facade `.cpp` is now a small dispatcher; re-count `WITH_EDITOR` / `GIsEditor` / `bIsHotReload` at apply time across the `_*.cpp` split.

## Decisions

### 1. Seven stages, two signal sources, three owners

```text
0  save/delete/rename .as
1  signal   Editor: DirectoryWatcher → QueueScriptFileChanges
            Standalone dev: AngelscriptHotReload thread FileTime poll
            both push Engine FileChangesDetectedForReload / FileDeletionsDetectedForReload
2  Tick     FAngelscriptEngine::CheckForHotReload / PerformHotReload
3  compile  preprocessor + CompileModules (failure keeps old code)
4  plan     ClassGenerator::Setup + FAngelscriptClassReloadPlanner (monotonic upgrade)
5  apply    PerformSoftReload or PerformFullReload + reinstancing / version chain
6  recover  FClassReloadHelper::FReloadState (objects, BP, editor caches)
7  impact   BlueprintImpactScanner queues BP compile (Editor)
```

| Stage | Owner | Must not do |
|---|---|---|
| 1 | Editor **or** Engine file-time thread | Decide soft vs full |
| 2–5 | Runtime | Refresh BlueprintActionDatabase / Class Viewer |
| 6–7 | Editor | Re-implement descriptor diff or planner |

Tests (`AngelscriptTest/HotReload`) are evidence, not a fourth production owner.

### 2. Four workstreams (do not run as one PR)

| ID | Change / work | Unblocks |
|---|---|---|
| **T** | `test-as-hotreload-script-corpus` | Safe production moves; pair identity |
| **I** | Reload identity: catalog `filename` vs `/Angelscript/Memory/TestCorpus/HotReload/<id>.as` through `CompileAnnotatedModuleFromMemory` / watcher logical paths | Disk-watcher tests, corpus logs |
| **E** | Editor recovery isolation: per-engine `FReloadState` (or documented single-editor-engine invariant + test), split `ClassReloadHelper.h` so UnrealEd includes stay in `.cpp` | Multi-engine editor tests, include hygiene |
| **B** | Boundary audit: re-count editor branches in ClassGenerator `_*` files; only move a branch if it is Editor recovery leaking into Runtime | D1 from the 2026-06-30 audit |

**T before E/B.** Without pair goldens, recovery/isolation refactors have no cheap analyze leaf.

Engine-matrix harness stays unrelated (VM/cache/JIT). Soft reload must keep JIT wrappers reading the **current** binding (`ASFunction_JITDispatch.cpp` already documents that). Prove with a later HotReload pair + existing Runtime JIT CQTest if needed — not this change’s Wave A.

### 3. Do not “finish splitting ClassGenerator” first

Physical split already exists. Wave A production work is **E** (header / `FReloadState`) and **I** (identity), not another `_Foo.cpp` extract from Analyze.

### 4. `FReloadState` stays Editor-only; partition is explicit

Today: engine-owned `GetOnClassReload()` etc. (per-engine) feed a **static** `FReloadState`. Comment in `ClassReloadHelper.h` says Editor only drives one engine in practice.

Wave A of **E**: keep the static if tests prove single-editor-engine, but **stop adding** new process-wide maps. Next slice: key recovery state by `FAngelscriptEngine*` or forbid overlapping reloads across engines with a hard assert.

Test hooks stay behind `WITH_DEV_AUTOMATION_TESTS`. Do not grow a fourth `*TestHooks` struct; prefer the corpus COMPLEX + existing hooks.

### 5. Compile failure is a feature

`PerformHotReload` preprocess/compile failure must keep the previous executable module and surface diagnostics. Functional golden already exists (`FailureKeepsOldCodeAndDiagnostics`). Corpus sibling MAY extract it later; this change must not “simplify” failure into a full discard.

## File map

No production file moves in Wave A of this change except if **E** starts (apply later):

Likely later modify:

- `AngelscriptEditor/HotReload/ClassReloadHelper.h/.cpp` — include split; optional `FReloadState` partition
- `AngelscriptEditor/HotReload/AngelscriptDirectoryWatcherInternal.*` — identity only if **I** needs logical path
- `AngelscriptRuntime/Core/AngelscriptEngine.cpp` — `CheckForHotReload` / `PerformHotReload` (behavior freeze; no policy change)
- `AngelscriptRuntime/ClassGenerator/AngelscriptClassGenerator*.cpp` — branch audit only unless a leak is proven

Docs:

- `Documents/Knowledges/ZH/RT_HotReload.md` pointer to this map
- `Documents/Guides/RuntimeArchitectureAudit_20260630.md` §D “status: sequenced under this change”

Sibling: `openspec/changes/test-as-hotreload-script-corpus/`

## Risks / Trade-offs

- [Stale audit] Treating `AngelscriptClassGenerator.cpp` as a 5000-line god file → Re-count; facade is already split.
- [Big-bang split] Rewriting Analyze without corpus goldens → Fail classification silently → **T** first.
- [Per-engine state] Partitioning `FReloadState` without tests → Lost reinstancing in PIE → Assert + HotReload.MultiEngineHooks tests.
- [Identity change] Switching annotated compile `Filename` to a long virtual path → Breaks ClassGenerator section names → Catalog keeps short `filename` until proven.

## Migration Plan

1. Land this map (OpenSpec). No code.
2. Apply `test-as-data-driven-engine-harness` corpus API, then `test-as-hotreload-script-corpus` Wave A goldens.
3. Identity audit (**I**) with those goldens.
4. ClassReloadHelper include / `FReloadState` (**E**) with `Angelscript.TestModule.HotReload` + Corpus prefixes.
5. Optional ClassGenerator editor-branch moves (**B**) one branch at a time.
6. Rollback any production slice by reverting that PR; planner policy never changes here.

## Open Questions

Resolved:

- Not a DataDriven engine profile.
- Not a ClassGenerator resplit-first refactor.
- Test corpus is a sibling, not this change’s files.

Open until apply:

- Exact `WITH_EDITOR` counts per `_Analyze` / `_SoftReload` / `_FullReload` after the split.
- Whether `FReloadState` partition is required before any other Editor helper cleanup (default: include split first, partition second).
