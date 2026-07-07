## Why

`AngelscriptRuntime/ClassGenerator` has a historical name that is narrower than its real responsibility. The directory is effectively the runtime **AS-to-Unreal Generator** boundary: it turns AngelScript declarations into Unreal-facing reflected artifacts (`UASClass` / `UASStruct` / `UASFunction`, properties, metadata, CDO/default-component data, reload/reinstance state). It has grown into the least maintainable hot path in the plugin: `AngelscriptClassGenerator.cpp` is currently measured by symbol anchors rather than fixed line numbers, with several 400–1360 line functions, and `ASClass.cpp` is `2833` lines mixing `UASClass`, `UASFunction`, and `~40` near-duplicate `UASFunction_*` dispatch subclasses. A single `FAngelscriptClassGenerator` struct owns analysis, reload-requirement planning, full/soft reload, property/function generation, finalization, verification, tick setup, default-object init, redirects, and script-object construct/destruct. This module is also the top global-state hotspot (`81` `FAngelscriptEngine::Get()`/`CurrentWorldContext` references) and carries leftover Hazelight `WILL-EDIT` markers and commented-out dead code. Test coverage is broad but uneven: `AngelscriptTest/ClassGenerator/` has `32` test files and the `HotReload`/`Compiler`/`Coverage`/`Functional` themes exercise generation heavily, yet a few high-risk pipeline branches (reload dependency propagation, interface-list-change classification, `VerifyClass` reject branches, argument-marshalling matrix, `ResolveCodeSuperForProperty`, debug-value prototype) lack direct assertions — exactly the branches a decomposition must not silently break. See `coverage-gaps.md`.

## What Changes

The goal is a **behavior-preserving structural decomposition** that turns two monster files into cohesive, single-responsibility translation units guarded by characterization tests. Runtime behavior, public APIs, generated `UClass`/`UStruct`/`UFunction` shapes, and hot-reload semantics MUST NOT change.

- Split `AngelscriptClassGenerator.cpp` along its existing internal phases into separate translation units while keeping the `FAngelscriptClassGenerator` type and private data declared once in `AngelscriptClassGenerator.h`: `Analyze` (module/class/enum/delegate analysis), `ReloadPlanning` (reload-requirement computation + propagation), `FullReload`, `SoftReload`, `Generation` (`AddClassProperties` / `AddFunctionArgument` / `AddFunctionReturnType`), `Finalize` (class/actor/component/object + verify + tick + default objects), and `Reinstancing` (script-object construct/destruct, reference detection). This first pass moves method definitions only; a private-header or collaborator extraction is deferred until the phase split is green.
- Extract the largest functions (`Analyze(class)` ~1360 lines, `DoSoftReload` ~650, `DoFullReloadClass` ~470, `PerformReload` ~400) into named private steps with clear inputs/outputs, without changing control flow.
- Split `ASClass.cpp`/`ASClass.h` as a second stage after the ClassGenerator phase split is stable: separate `UASClass` from the `UASFunction` base, and move the explicit `UASFunction_*` dispatch subclasses into a dedicated dispatch-variant unit. UHT-facing `UCLASS()` declarations remain explicit in committed headers; any macro/table generation is limited to implementation bodies or to checked-in generated source reviewed before build.
- Remove dead code and stale `WILL-EDIT`/commented-out fragments **only where they are unambiguously dead** and not owned by `refactor-as-audit-remove-with-angelscript-haze` (coordinate, do not duplicate that change).
- Add characterization tests that pin current class-generation, reload-requirement, and finalize behavior **before** any code moves, so the decomposition is verifiable.
- Establish a per-file/per-function decomposition map (`decomposition-map.md`) as the execution contract.

### Explicitly out of scope (deferred to existing/other work)

- **De-globalization** of `FAngelscriptEngine::Get()`/`CurrentWorldContext` (the `81` references): tracked separately (legacy `Plan_FullDeGlobalization.md`); this refactor keeps call sites as-is, only relocating them.
- **Haze macro / `WITH_ANGELSCRIPT_HAZE` removal**: owned by `refactor-as-audit-remove-with-angelscript-haze`.
- Any semantic change to hot-reload requirement rules, JIT dispatch selection, or generated reflection.

## Capabilities

### New Capabilities

- `as-classgenerator-structure`: Defines the responsibility decomposition and behavior-preservation contract for the ClassGenerator module (file/unit boundaries, characterization-test gating, no-behavior-change guarantee).

### Modified Capabilities

- None. This is an internal structural refactor; no existing spec-level requirement changes.

## Impact

- Source: `Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator/` — `AngelscriptClassGenerator.cpp/.h`, `ASClass.cpp/.h`, `ASStruct.cpp/.h`, `AngelscriptClassRedirects.cpp/.h`. New translation units + a private shared header; `Build.cs` unity/include implications reviewed.
- Tests: `Plugins/Angelscript/Source/AngelscriptTest/ClassGenerator/` gains characterization tests; existing `HotReload` and `NativeScriptHotReload.Phase2A/2B` themes act as the behavior-preservation net.
- Coordination: `refactor-as-audit-remove-with-angelscript-haze` (haze/WILL-EDIT) and the deferred de-globalization plan must not be duplicated; overlaps are called out in `decomposition-map.md`.
- Behavior: none intended. Runtime, editor, generated reflection, and hot-reload semantics remain identical.
- Validation: full plugin build + `Angelscript.TestModule.*` (at minimum `ClassGenerator`, `HotReload`, `Inheritance`, `Interface`, `Component`, `Actor`, `Delegate`, `GC` themes) before and after each decomposition batch.
