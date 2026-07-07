## Context

`FAngelscriptClassGenerator` is the runtime pipeline inside the broader AS-to-Unreal Generator boundary. The directory name is historical: it does not only generate `UClass`; it also generates and wires `UASFunction`, `UASStruct`, properties, metadata, CDO/default-component state, hot-reload identity, and reinstance behavior. In this first-stage change, "ClassGenerator" refers to the existing directory/change name, while the architectural responsibility is the Generator pipeline from AngelScript declarations to Unreal reflection/runtime artifacts.

`FAngelscriptClassGenerator` turns compiled AngelScript type descriptors (`FAngelscriptClassDesc` / `FAngelscriptEnumDesc` / `FAngelscriptDelegateDesc`) into live `UASClass` / `UASStruct` / `UASFunction` objects, and re-runs incrementally on hot reload. It is on the compile/reload hot path, has thin direct tests, and heavy global-state coupling. Any refactor must be **behavior-preserving and test-guarded**, not a redesign of reload semantics.

## Goals / Non-Goals

Goals:
- Reduce the two monster files to cohesive single-responsibility units.
- Make the reload pipeline phases (analyze → plan → full/soft reload → generate → finalize → reinstance) individually readable and testable.
- Reduce copy-paste risk in the `UASFunction_*` dispatch matrix without asking UHT to parse macro-expanded `UCLASS()` declarations.
- Pin current behavior with characterization tests first.

Non-Goals:
- No change to hot-reload requirement rules, generated reflection shapes, JIT dispatch selection, or public APIs.
- No de-globalization (deferred). No haze-macro removal (other change).

## Current structure (as measured)

`AngelscriptClassGenerator.cpp` should be treated as a symbol-anchored file during this change: line numbers below are planning snapshots and MUST be re-measured before each batch because the current file has already drifted past the original `5390`-line estimate. Major functions and phases:

| Phase | Representative functions | Approx lines |
|---|---|---|
| Bookkeeping | `AddModule`, `GetUnrealName`, `EnsureClassAnalyzed`, `GetClassDesc` | small |
| Analyze | `Analyze(Module)`, `Analyze(Module,Class)` (~1360), `Analyze(Module,Delegate)`, `InitEnums`, `AnalyzeEnums`, `SetupModule`, `TryGenerateClassRenameRedirects` | ~1900 |
| Reload planning | `ShouldFullReload*`, `HasInterfaceListChanged`, `HasReloadedReflectedScriptType`, `AddReloadDependency`, `PropagateReloadRequirements`, `ResolvePendingReloadDependees`, `GetReloadRequirementForNewScriptType` | ~350 |
| Reload driver | `PerformReload` (~400), `PerformFullReload`, `PerformSoftReload`, `EnsureReloaded*`, `EnsureClassFinalized` | ~500 |
| Full reload | `CreateFullReloadClass/Struct/Delegate`, `DoFullReload*`, `DoFullReloadClass` (~470), `DoFullReloadStruct`, `ResolveClassRedirectReplacedClass`, `FullReloadRemoveClass`, `CopyClassInheritedMetaData` | ~1200 |
| Soft reload | `DoSoftReload` (~650), `PrepareSoftReload`, `LinkSoftReloadClasses*`, `SoftReloadFunction`, `SoftReloadType` | ~900 |
| Generation | `AddClassProperties` (~280), `AddFunctionArgument`, `AddFunctionReturnType`, `ResolveCodeSuperForProperty`, `GetDataFor` | ~450 |
| Finalize | `FinalizeClass`, `FinalizeActorClass` (~230), `FinalizeComponentClass`, `FinalizeObjectClass`, `VerifyClass` (~230), `InitClassTickSettings`, `CallPostInitFunctions`, `InitDefaultObject(s)`, `SetScriptStaticClass`, `UpdateConstructAndDefaultsFunctions` | ~900 |
| Reinstancing | `DestructScriptObject`, `ReinitializeScriptObject`, `DetectAngelscriptReferences`, `CreateDebugValuePrototype`, `CleanupRemovedClass` | ~300 |

`ASClass.cpp` (2833 lines): `UASClass` (construction/CDO/tick/replication/defaults) + `UASFunction` (argument finalization, `OptimizedCall_*`, thunks) + `~40` `UASFunction_*` `RuntimeCallFunction`/`RuntimeCallEvent` overrides that differ only by argument/return marshalling behavior.

## Decision: split by phase into shared-type translation units (not a class redesign)

Keep the `FAngelscriptClassGenerator` type and its private data members intact (declared once in the header). Move method **definitions** into per-phase `.cpp` files that all include the existing header. This is the lowest-risk decomposition: no signature changes, no new indirection, git history stays reviewable, and behavior is trivially preserved because only definition location moves.

Proposed translation units (names in `decomposition-map.md`):
- `AngelscriptClassGenerator.cpp` (driver: `Setup`, `AddModule`, `PerformReload`, bookkeeping)
- `AngelscriptClassGenerator_Analyze.cpp`
- `AngelscriptClassGenerator_ReloadPlanning.cpp`
- `AngelscriptClassGenerator_FullReload.cpp`
- `AngelscriptClassGenerator_SoftReload.cpp`
- `AngelscriptClassGenerator_Generation.cpp`
- `AngelscriptClassGenerator_Finalize.cpp`
- `AngelscriptClassGenerator_Reinstancing.cpp`

Within each unit, extract the giant functions into `static` file-local helpers or private methods (added to the header only when they need member access), preserving exact control flow.

### Alternative considered: collaborator classes (Analyzer/Planner/Generator/Finalizer)

A deeper redesign into separate collaborator classes with explicit interfaces was considered. Rejected for the first pass because it forces data-ownership decisions on the shared `FModuleData`/`FClassData` structures and materially raises regression risk on a thin-test hot path. The phase-split above is a prerequisite that makes a later collaborator extraction feasible; this change stops at the split and leaves collaborator extraction as an optional follow-up.

## Decision: tabulate the `UASFunction_*` dispatch matrix without macro-expanded UHT declarations

The `~40` `UASFunction_*` subclasses are a Cartesian product of {arg behavior} × {return behavior} × {JIT?} × {thread-safety}. The first safe step is to move `UASFunction` base behavior into `ASFunction.cpp` and move the dispatch variants into an explicit dispatch-variant header/source pair. The UHT-facing `UCLASS()` declarations MUST remain explicit committed C++ declarations, either moved verbatim or produced by a checked-in generator output. A macro list such as `AS_FUNCTION_DISPATCH_VARIANTS(X)` may generate non-UHT implementation bodies and factory tables, but MUST NOT be the only source of `UCLASS()` declarations parsed by UHT. This still removes the riskiest copy-paste in call bodies while keeping identical generated classes (verified by comparing UHT `.generated.h` output and dispatch behavior tests). Move these into `ASFunctionDispatchVariants.h/.cpp`, leaving `ASClass.cpp` for `UASClass` and `ASFunction.cpp` for the `UASFunction` base.

## Risk / mitigation

- **Uneven tests on a hot path** → Broad coverage already exists (see `coverage-gaps.md`); Characterization tests FIRST (task group 2) fill only the confirmed gaps (reload dependency propagation, interface-list-change classification, `VerifyClass` reject branches, argument-marshalling matrix, `ResolveCodeSuperForProperty`, debug-value prototype, live-instance reinstancing) before extracting the corresponding phase unit. Do not re-add already-covered scenarios.
- **Unity build masking include gaps** → build with and without unity (`-NoXGE` / verify non-unity) after each batch.
- **Behavior drift in extraction** → extract mechanically (cut/paste bodies, no logic edits); review each batch with `git diff` focused on moved-only hunks.
- **Overlap with haze/de-globalization changes** → `decomposition-map.md` marks lines owned by other changes; skip them here.

## Rollout

One phase-unit per batch, each batch: extract → build (unity + non-unity) → run affected `Angelscript.TestModule.*` themes → commit. Complete the ClassGenerator phase split before starting the `ASClass`/`UASFunction` split; if the phase split becomes large, move the dispatch-variant work into a follow-up OpenSpec change instead of mixing risks. Characterization tests land before batch 1.
