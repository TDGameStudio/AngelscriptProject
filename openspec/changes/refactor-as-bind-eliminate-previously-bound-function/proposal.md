## Why

`FAngelscriptBinds` currently couples each AS engine registration with a static global `FAngelscriptBindState::PreviouslyBoundFunction` (`Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptBinds.cpp:78-86`, `:530-554`). After every `BindMethod` / `BindGlobalFunction` / `BindBehaviour` write, callers reach into ~9 free-function trait setters (`SetPreviousBindIsEditorOnly`, `DeprecatePreviousBind`, `MarkAsImplicitConstructor`, `CompileOutPreviousBind`, …) that read this static. The implicit `register → trait-set` strict-serial-on-the-same-thread contract spans ~120 hand-written `Bind_*.cpp` callsites and is the **single biggest structural blocker** to extending the proven Prepare/Commit parallel pattern (already shipped for `Bind_Defaults`, 36 220 ms → 147 ms — see `Documents/Guides/BlueprintTypeBindingsOptimization.md`) to other heavyweight binds (`Bind_StructDetails`, `Bind_BlueprintEvent`, generated `ASRuntimeBind_*` shards).

This change does **not** itself deliver runtime speedup — it removes the keystone obstacle so the next OpenSpec change can generalize Phase 2A/2B Prepare/Commit across all binds, and folds in two trivial, low-risk co-located optimizations (pre-sort cache + per-bind timing instrumentation) that prepare baseline data for that follow-up.

## What Changes

- Introduce `FBoundFunction` and `FBoundProperty` return types in `AngelscriptBinds.h` carrying `int32 FunctionId` / global-property id and chainable trait setters: `EditorOnly()`, `Deprecate(msg)`, `PropertyAccessor(bool)`, `NoDiscard(bool)`, `RequiresWorldContext(bool)`, `NotCallable()`, `GeneratedAccessor(bool)`, `ImplicitConstructor()`, `CompileOut()`, `CompileOutAsMethodChain()`, `ForceConstArgumentExpressions(bool)`, `ArgumentDeterminesOutputType(int)`, `PassScriptFunctionAsFirstParam()`, `PassScriptObjectTypeAsFirstParam()`, `PureConstant<T>(value)`.
- Change `FAngelscriptBinds::BindMethod` / `BindExternMethod` / `BindBehaviour` / `BindExternBehaviour` / `BindStaticBehaviour` / `BindGlobalFunction` / `BindGlobalFunctionDirect` / `BindGlobalGenericFunction` / `BindMethodDirect` / `GenericMethod` / `BindProperty` / `BindGlobalVariable` to return the new types; corresponding `Method()` / `Constructor()` / `Factory()` / `Destructor()` / `Property()` template wrappers chain through.
- Mark legacy free-function trait setters (`SetPreviousBindIsEditorOnly`, `SetPreviousBindIsPropertyAccessor`, `SetPreviousBindIsCallable`, `SetPreviousBindNoDiscard`, `SetPreviousBindRequiresWorldContext`, `SetPreviousBindIsGeneratedAccessor`, `SetPreviousBindForceConstArgumentExpressions`, `SetPreviousBindArgumentDeterminesOutputType`, `PreviousBindPassScriptFunctionAsFirstParam`, `PreviousBindPassScriptObjectTypeAsFirstParam`, `DeprecatePreviousBind`, `MarkAsImplicitConstructor`, `CompileOutPreviousBind`, `CompileOutPreviousBindAsMethodChain`, `SetPreviousBoundGlobalVariablePureConstant`) `[[deprecated]]` but keep functional. `OnBind()` continues writing `PreviouslyBoundFunction` so legacy callsites stay correct during migration.
- Migrate all hand-written `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/*.cpp` callsites (~120 files) to the new chained API. Mechanical pattern-replace covers the bulk; rare complex sequences hand-converted.
- **Co-located optimizations** (no behavior change):
  - Cache the sorted bind array in `GetSortedBindArray()` (`AngelscriptBinds.cpp:182-187`), invalidate on `ResetBindState()`. Eliminates per-`CallBinds` O(n log n) re-sort + full-array copy.
  - Add per-bind timing instrumentation in `CallBinds` (`AngelscriptBinds.cpp:303-340`) under `WITH_DEV_AUTOMATION_TESTS || AS_PRINT_STATS`, recording `{BindName, BindOrder, DurationMs}` into `FAngelscriptBindExecutionObservation`. Zero-cost in shipping. Output drives the next-change priority decision.
- Update `Documents/Plans/Plan_BindParallelization.md` Phase 1.1 / Phase 2 / Phase 3.1 status.

**Not BREAKING.** Legacy API preserved with deprecation; binary/textual API surface only adds — does not remove.

## Capabilities

### New Capabilities

- `as-bind-trait-fluent-api`: Chainable bind-trait API — `FBoundFunction` / `FBoundProperty` return values from `FAngelscriptBinds` registration calls, exposing `EditorOnly()` / `Deprecate()` / `NoDiscard()` / `PropertyAccessor()` / `ImplicitConstructor()` / `CompileOut()` / etc. as member methods. Replaces the static-global `PreviouslyBoundFunction` plus free-function `SetPreviousBind*` pattern. Legacy free-function path remains as deprecated compatibility surface.
- `as-bind-execution-timing`: Per-bind execution timing observation — under `WITH_DEV_AUTOMATION_TESTS` / `AS_PRINT_STATS`, `CallBinds` records each bind's `{BindName, BindOrder, DurationMs}` into `FAngelscriptBindExecutionObservation`. Tests and diagnostics can read the per-bind timing list to identify hot binds.

### Modified Capabilities

<!-- None — no existing spec covers FAngelscriptBinds API surface or bind-time observation. -->

## Impact

- **Affected modules**: `AngelscriptRuntime` (Core + Binds + Testing).
- **Affected files (primary)**:
  - `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptBinds.h` — new types, return-type changes, template-wrapper chaining
  - `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptBinds.cpp` — `OnBind` keeps legacy write; sort cache; timing instrumentation
  - `Plugins/Angelscript/Source/AngelscriptRuntime/Testing/AngelscriptBindExecutionObservation.{h,cpp}` — per-bind timing collection
  - `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/*.cpp` — ~120 callsite migrations
  - `Documents/Plans/Plan_BindParallelization.md` — phase status update
- **Affected APIs**: `FAngelscriptBinds::*` registration methods gain new return types (additive — old `void` / `int` returns become `FBoundFunction` / `FBoundProperty` which implicitly convert / are ignorable). `FAngelscriptBindExecutionObservation` gains per-bind data accessors.
- **Dependencies**: None new. Internal-only refactor.
- **External plugins / submodules**: `Plugins/UnrealEvent`, `Plugins/AngelscriptGAS` (if present) keep working through the deprecated free-function path; they may opt into the new chained API at their own pace.
- **Build & test**: `Tools\RunBuild.ps1` (Editor + Test targets) + `Tools\RunTests.ps1` full suite must pass. No new build flags introduced.
- **Performance**: Pre-sort cache trims a small `O(n log n)` per `CallBinds` (~ <50 ms expected). Timing instrumentation is dev-only. No shipping-path change.
- **Out of scope (deferred to future OpenSpec changes)**:
  - `FBindStaged` Prepare/Commit generalization across binds beyond `Bind_Defaults`.
  - Build-time codegen of signature literals / property offsets via `AngelscriptUHTTool` (UnrealSharp-style approach).
  - Removing the `[[deprecated]]` legacy free-function trait setters (later cleanup change).
  - Any change to AS engine fork (`asCArray`, `asCMap`, `defaultNamespace`, `nextScriptFunctionId`).
  - Investigation of FBind-constructor parallel `Add` (analytically cold-pathed in plan appendix; revisit only if Phase 1 timing data shows `>200 ms` cumulative).
