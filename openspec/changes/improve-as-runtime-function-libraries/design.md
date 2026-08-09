## Context

Runtime FunctionLibraries are a hybrid script API: reflected eligibility chooses candidate UFunctions, `FAngelscriptFunctionSignature` transforms them into namespace or mixin declarations, and post-reflection providers fill gaps. The current flow is permissive at exactly the wrong boundary: malformed mixin metadata can silently change the API shape, and manual supplements can use name-only guards. Behavior tests are dispersed across Core and Bindings even though FunctionLibraries are now a mature Runtime theme.

This design treats `FunctionLibraries` as Runtime by default. The Editor folder is excluded because current engine-state evidence shows registered types but no bound methods and no Editor-owned provider.

## Goals / Non-Goals

**Goals:**

- Give every Runtime FunctionLibrary UFunction an unambiguous exposed, explicitly hidden, or removed disposition derived from current metadata rules.
- Reject invalid mixin receiver declarations and exact duplicates before a partial AS surface is published.
- Correct the confirmed behavior and ownership defects recorded in `research.md`, including intentional breaking cleanup.
- Move focused tests to one flat `AngelscriptTest/FunctionLibraries/` theme and make `Documents/UnitTest/UnitTest.md` the structural authority.
- Remain compatible with the binding phase/provider API that exists when implementation starts.

**Non-Goals:**

- No Editor FunctionLibrary provider, late bind replay, Editor behavior cleanup, or Editor tests.
- No redesign of the global binding collection, semantic phases, seal lifecycle, UHT generation strategy, or NativeModuleFunctionAddress transport.
- No new GameplayTags/GAS behavior, Standalone branches, host-project logic, or compatibility aliases for removed script APIs.
- No hand-maintained manifest enumerating all 237 current Runtime UFunctions.

## Decisions

### 1. Derive the contract from reflection metadata

Automation discovers classes whose package is `/Script/AngelscriptRuntime` and whose `ModuleRelativePath` is under `FunctionLibraries/`. It inspects only UFunctions declared by each class, not inherited UObject functions.

Each declaration has exactly one disposition:

- **Exposed**: BlueprintCallable, BlueprintPure, or `ScriptCallable`, and not opted out by `NotInAngelscript`.
- **Explicitly hidden**: carries the explicit opt-out metadata used by the current binder.
- **Removed**: no longer exists because the wrapper has no supported AS purpose.

A reflected FunctionLibrary method with none of these outcomes is a contract failure. This avoids a static allowlist while making bare `UFUNCTION()` drift visible.

Alternative rejected: a checked-in row for every UFunction. It would duplicate UHT metadata, require constant manual synchronization, and still would not prove the final AS declaration.

### 2. Validate mixin intent before namespace fallback

Signature construction records whether mixin intent exists, the parsed target list, the first reflected parameter type, and whether one target matched. Function-level `ScriptMethod` retains its UE 5.7 compatibility path.

If mixin intent exists but there is no compatible receiver, registration fails; it does not set the ordinary library namespace. The failure identifies the owner class, UFunction, target list, first parameter, and attempted declaration. The existing engine initialization failure accumulator/publish gate is used; this change does not create a second diagnostics framework.

The validation code stays Runtime-internal. Although the generic signature helper naturally protects any processed mixin, the exhaustive census and capability guarantee cover Runtime FunctionLibraries; optional-plugin prefixes provide regression protection.

Alternative rejected: automation-only validation. It would catch checked-in mistakes but still let dynamically supplied invalid metadata silently alter a development engine.

### 3. Use full declaration identity for supplements

Post-reflection supplements query the receiver/namespace for the exact AS declaration. An existing exact declaration suppresses only the duplicate; a same-name different declaration remains a valid overload. Any failed registration is routed through the existing bind failure path.

This is limited to FunctionLibrary supplement code. Provider ownership and phase names follow `refactor-as-manual-binding-architecture` if that change lands first.

### 4. Lock the behavior changes

- Compute signed and unsigned `WrapIndex` intermediates in a wider signed domain, normalize the remainder, preserve `[Min, Max)`, swap reversed bounds, and return the bound when both are equal.
- After arbitrary-up plane projection, calculate full vector distance for both `FVector` and `FVector3f` paths.
- Clamp angular dot ratios and return zero for any zero-length operand.
- Mutate an embedded `FRuntimeFloatCurve` through `GetRichCurve()`. When `ExternalCurve` is selected, route AddDefaultKey through the same `UCurveFloat` mutation path used by direct asset helpers so the external asset receives editor modification/dirty and `OnCurveChanged` semantics. That narrow internal path checks null, begins editor modification when available, performs the mutation, and sends `OnCurveChanged` with the affected curve info.
- Use `RCTM_SmartAuto` for `AddSmartAutoCurveKey`.
- Remove the unused ActionName/AxisName parameters while preserving the `UPlayerInput` mixin receiver and full-array return behavior.

### 5. Make cleanup evidence-based and breaking

Delete the three bare AssetManager wrappers named in the proposal. Preserve `UAngelscriptLevelStreamingLibrary::GetShouldBeVisibleInEditor` and its supplement under matching `#if WITH_EDITOR` guards because current source exposes real native editor visibility on a Runtime-owned type rather than a constant runtime fallback. For `UAngelscriptComponentLibrary`, compare final exact AS declarations with the engine-provided scene-component surface and remove only wrappers that duplicate a richer engine entry while discarding semantics. Unique quaternion overloads and plugin-specific helpers stay.

Remove the invalid Widget world-context metadata. Move direct `asCModule::InitializingGlobalProperty` inspection behind a Runtime Core internal query so the FunctionLibrary implementation no longer includes `source/as_module.h`.

No aliases preserve removed parameters or removed wrappers; compile failures are the migration signal.

### 6. Keep the test theme flat

All focused files live directly under:

`Plugins/Angelscript/Source/AngelscriptTest/FunctionLibraries/`

There are no `Runtime`, `Contract`, `Math`, or other child directories. File names and automation IDs carry the grouping, for example:

- `AngelscriptFunctionLibraryContractTests.cpp` -> `Angelscript.TestModule.FunctionLibraries.Contract.*`
- `AngelscriptMathFunctionLibraryTests.cpp` -> `Angelscript.TestModule.FunctionLibraries.Math.*`
- `AngelscriptCurveFunctionLibraryTests.cpp` -> `Angelscript.TestModule.FunctionLibraries.Curve.*`
- `AngelscriptInputFunctionLibraryTests.cpp` -> `Angelscript.TestModule.FunctionLibraries.Input.*`

Primarily FunctionLibrary files move from Bindings/Core. Mixed files are split only for their FunctionLibrary methods. Coverage and Functional tests stay in place when their primary concern is a broader matrix, world lifecycle, physics, actor/component behavior, or coverage accounting.

Every touched CQTest registration follows `Documents/UnitTest/UnitTest.md`: `WITH_ANGELSCRIPT_UNITTESTS` body gate, `TEST_CLASS_WITH_FLAGS`, scenario-specific `TEST_METHOD`, class-level engine lifecycle, method-owned cleanup, `ASTEST_AS`, matcher assertions, class-private helpers, and restored `public:` visibility.

### 7. Treat Editor as a recorded follow-up boundary

No `FunctionLibraries/Editor` test directory or `Angelscript.TestModule.FunctionLibraries.Editor` prefix is created. If an Editor-owned surface is later designed, it uses the established Editor automation root such as `Angelscript.Editor.FunctionLibraries.*` and must first provide a real registration lifecycle.

## Risks / Trade-offs

- **Existing scripts use removed signatures** -> Treat compile errors as intentional migration guidance; record old/new signatures in release-facing notes if a live guide references them.
- **Generic mixin validation reveals optional-plugin defects** -> Run the optional GameplayTags/GAS prefixes as regression gates without expanding this change's behavior scope.
- **Active binding-architecture work changes helper APIs** -> Preserve the requirements and adapt only the mechanical provider/failure calls to the landed architecture; do not reintroduce name-only or silent fallback behavior.
- **Moving tests drops suite coverage** -> Add the new FunctionLibraries prefix to suite definitions and shard estimates before deleting old registrations; compare discovered test counts and run `All`.
- **Curve mutation causes editor side effects** -> Use transient assets in tests, observe the update delegate/dirty state, and restore or destroy all test objects per method.
- **Component cleanup removes a unique overload by mistake** -> Require an exact-declaration inventory and a red compile/dispatch test for every proposed removal before deleting the wrapper.

## Migration Plan

1. Add contract and focused behavior tests under the flat FunctionLibraries directory and update suite routing while old implementations remain.
2. Add mixin validation and exact-declaration supplement guards.
3. Fix Math, Curve, and Input behavior in independent TDD batches.
4. Perform the explicit dead/redundant API cleanup and Runtime Core private-VM boundary extraction.
5. Move/split remaining focused tests, remove old registrations, update current docs only where searches find live references, then run focused and full verification.

Rollback is a source revert of this change before release. No runtime compatibility toggle or duplicate legacy test prefix is retained.

## Open Questions

None. Editor binding remains deliberately deferred rather than unresolved inside this change.
