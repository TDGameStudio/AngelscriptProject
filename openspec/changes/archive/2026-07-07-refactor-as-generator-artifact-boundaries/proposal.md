## Why

`AngelscriptRuntime/ClassGenerator` is a historical name for a broader runtime Generator boundary. After the first-stage `FAngelscriptClassGenerator` phase split, the next risk is `ASClass.cpp/.h`: it still mixes generated class runtime behavior, generated function reflection/call behavior, and explicit dispatch variant declarations in one unit.

This change records the follow-up boundary before implementation so the next refactor separates artifact responsibilities without changing generated Unreal behavior or reopening the completed phase-split scope.

## What Changes

- Define the AS-to-Unreal Generator artifact boundary explicitly: AngelScript declarations/descriptors flow into Unreal reflected artifacts (`UASClass`, `UASStruct`, `UASFunction`, properties, metadata, CDO/default-component state, reload/reinstance identity).
- Split the follow-up responsibility model into three artifact layers: `UASClass` runtime class layer, `UASFunction` base reflection/call layer, and explicit `UASFunction_*` dispatch variant layer.
- Preserve UHT-facing `UCLASS()` declarations as explicit committed C++ declarations; table/macro generation is allowed only for non-UHT implementation bodies or checked-in generated source.
- Add only narrow characterization tests for known remaining ASClass/Generator gaps before moving implementation bodies: namespaced-UCLASS positive generation, default/override component wiring details, and any stable public debugger prototype observation if a public seam exists.
- Normalize non-compliant `ClassGenerator` CQTest files against `Documents/UnitTest/UnitTest.md` before relying on them as artifact-boundary regression coverage: class-level engine lifecycle, `ASTEST_AS` inline scripts, visible CQTest hooks, and main flow inside `TEST_METHOD`.
- Defer broad directory/test-prefix renaming from `ClassGenerator` to `Generator`; naming cleanup is a separate churn-heavy decision after artifact boundaries are stable.

## Capabilities

### New Capabilities

- `as-generator-artifact-boundaries`: Defines the runtime Generator artifact ownership contract and behavior-preserving split rules for `UASClass`, `UASFunction`, and dispatch variants.

### Modified Capabilities

- None. This is an internal structural refactor record; generated reflection/runtime behavior requirements remain unchanged.

## Impact

- Source: `Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator/ASClass.h`, `ASClass.cpp`, follow-up `ASFunction.*`, and follow-up dispatch-variant units.
- Tests: `Plugins/Angelscript/Source/AngelscriptTest/ClassGenerator/` existing `Angelscript.TestModule.ClassGenerator.ASClass` and `ASFunction` tests, with narrow additions only where public behavior is under-covered.
- OpenSpec: follows `refactor-classgenerator-decomposition`; does not extend that completed first-stage change.
- Behavior: no intended changes to generated `UClass`/`UStruct`/`UFunction` shapes, dispatch selection, hot reload, or runtime/editor behavior.