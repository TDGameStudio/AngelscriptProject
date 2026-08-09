# Runtime FunctionLibraries Research

## Evidence policy

This record was prepared on 2026-08-08. Current plugin source and generated runtime state are authoritative for this change. Knot searches against `UnrealEngine@UnrealEngine-ue5-main` and `scottmei@myas-master` are used to confirm UE and upstream behavior. Repository documents are supporting context only because some local FunctionLibrary notes predate the current UE 5.7/plugin architecture.

No conclusion below is based only on a legacy plan under `Documents/Plans/`.

## Current source inventory

Anchored source scans (`^\s*UCLASS\s*\(` and `^\s*UFUNCTION\s*\(`) produce the following current inventory:

| Area | Files | UCLASS | UFUNCTION | active class `ScriptMixin` |
| --- | ---: | ---: | ---: | ---: |
| `AngelscriptRuntime/FunctionLibraries` | 18 | 31 | 237 | 21 |
| `AngelscriptEditor/FunctionLibraries` | 6 | 5 | 16 | 0 |

Runtime exposure is split across three mechanisms:

1. `Bind_BlueprintType.cpp` enumerates reflected UClasses and considers Blueprint-callable/pure or `ScriptCallable` UFunctions for script exposure, subject to opt-out metadata and supported signatures.
2. `Helper_FunctionSignature.h` converts the UFunction to an AS declaration. A class `ScriptMixin` value is parsed as a space-separated target list; the first reflected argument is removed and the function becomes an instance method only when its AS type matches one target.
3. Post-reflection files such as `Bind_FunctionLibraryMixins.cpp`, `Bind_AssetManagerScriptMixins.cpp`, and `Bind_InputComponentScriptMixins.cpp` supplement signatures that reflection/UHT cannot express directly.

The critical current failure mode is in step 2: a class advertises `ScriptMixin`, but an empty, unresolved, or incompatible first argument leaves `bFoundMixin=false`; the code then assigns the ordinary library namespace and binds the function as static. This changes API shape without rejecting the invalid metadata.

`Bind_FunctionLibraryMixins.cpp` also mixes exact declarations with name-only `HasMethod` guards. A name-only check cannot distinguish a true duplicate from a valid overload and can make the final surface depend on which path registered first.

## Confirmed Runtime defects

### Math

- `WrapIndexUInt` calculates `(Value - Min) % Range` in `uint32`; values below `Min` underflow before the modulo, and `ModValue >= 0` is tautologically true. The signed version performs `Value - Min` and `Max - Min` in `int32`, so extreme inputs can overflow.
- The `FVector3f` arbitrary-up `Dist2D` and `DistSquared2D` helpers project both vectors and then call `DistSquaredXY`. That performs a second, fixed-Z projection and is wrong when the supplied up direction is not Z. The `FVector` versions correctly use full distance after projection.
- `AngularDistance` divides by the product of vector lengths without a zero-length guard and passes an unclamped quotient to `Acos`; finite inputs near the floating-point boundary can produce NaN.

### Curves

- `FRuntimeFloatCurve::AddDefaultKey` always writes `EditorCurveData`, but Knot's UE5-main `FRuntimeFloatCurve::GetRichCurve()` implementation returns `ExternalCurve->FloatCurve` whenever `ExternalCurve` is set. Reads and writes can therefore target different curves.
- `AddSmartAutoCurveKey` sets `RCTM_Auto`, making it behaviorally identical to `AddAutoCurveKey`; it must set `RCTM_SmartAuto`.
- `UCurveFloat` mutation wrappers directly modify `FloatCurve` without a shared null guard, editor transaction/dirty step, or `OnCurveChanged` notification. Knot confirms `UCurveBase::OnCurveChanged()` is the update broadcast point used by curve owners.

### Input

The Runtime wrapper declares:

- `GetEngineDefinedActionMappings(UPlayerInput*, FName ActionName)`
- `GetEngineDefinedAxisMappings(UPlayerInput*, FName AxisName)`

Both names are ignored. Knot confirms UE5-main exposes only the static, parameterless `UPlayerInput::GetEngineDefinedActionMappings()` and `GetEngineDefinedAxisMappings()` methods returning the complete arrays. The same unused parameters exist in the referenced UE-Angelscript source, so upstream parity is evidence of lineage, not correctness.

### Exposure and ownership

- `UAssetManagerMixinLibrary` contains `GetPrimaryAssetTypeInfo`, `GetPrimaryAssetTypeInfoList`, and `GetPrimaryAssetRules` as bare `UFUNCTION()` methods. They are neither BlueprintCallable/ScriptCallable nor manually registered and therefore are C++ wrappers, not AS API; current tests call them only as C++ null-guard helpers.
- `UAngelscriptWidgetMixinLibrary::GetRenderTransform` declares `WorldContext="WorldContextObject"` although it has no such parameter.
- `UAngelscriptLevelStreamingLibrary::GetShouldBeVisibleInEditor` is already enclosed by `#if WITH_EDITOR` in current source, and its manual supplement is guarded the same way. It is a valid editor-conditional helper for the Runtime-owned `ULevelStreaming` type, not an `AngelscriptEditor/FunctionLibraries` bind and not a non-editor no-op; it remains supported.
- `UAngelscriptComponentLibrary` contains simplified scene-component transforms that can overlap UE K2/reflected entries while discarding sweep, hit-result, or teleport choices. Removal must be based on an exact declaration/surface comparison; unique quaternion and plugin-specific helpers remain eligible.
- `AngelscriptScriptLibrary.cpp` includes `source/as_module.h` and reads `asCModule::InitializingGlobalProperty` directly. A FunctionLibrary should consume a Runtime Core adapter rather than own VM-private structure knowledge.

## Editor boundary

The Editor folder is not evidence of an Editor AS FunctionLibrary surface:

- `FAngelscriptEditorModule::StartupModule()` does not submit a FunctionLibrary binding provider or replay reflected binds.
- Runtime reflection binding is prepared and sealed during primary engine initialization. Runtime cannot depend on `AngelscriptEditor`; the actual dependency direction is `AngelscriptEditor -> AngelscriptRuntime`.
- A captured full state dump registers `UAssetToolsStatics`, `UBlueprintMixinLibrary`, `UEditorStatics`, and `UEditorSubsystemLibrary` as AS types, but each has `MethodCount=0`. The corresponding `Functions.csv`, `AsFunctionInternalState.csv`, and `BindRegistrations.csv` contain none of the representative Editor functions (`DuplicateSelected`, `IsFixupReferencersInProgress`, `GetEditorSubsystem`, `SpawnActorFromClass`, `GetGeneratedClass`).
- The preprocessor can synthesize `UEditorSubsystemLibrary::GetEditorSubsystem(...)`, and the archived `as-library-full-namespaces` spec describes that desired spelling, but current runtime state does not provide the method. This is an existing gap, not a surface to test or repair inside Runtime FunctionLibraries.

A real Editor solution needs a separately owned pre-seal provider or another explicitly designed Editor registration lifecycle. This change records that gap and otherwise excludes it.

## Existing test placement

FunctionLibrary coverage is currently split across:

- `Core/AngelscriptFunctionLibrarySignatureTests.cpp` and FunctionLibrary sections in `Core/AngelscriptEngineParityTests.cpp`;
- twelve primarily FunctionLibrary files under `Bindings/` covering AssetManager, curves, HitResult, Gameplay, FrameTime, math orientation, world, world collision, widget, soft references, and Script helpers;
- deeper `Coverage/` and Functional tests that happen to call the same APIs.

`Documents/UnitTest/UnitTest.md` now defines `Bindings/` as a narrow AS-visible entrypoint contract/smoke layer. A dedicated flat `AngelscriptTest/FunctionLibraries/` theme can own both the FunctionLibrary contract and its behavior without retaining the misleading Bindings placement. Coverage and world/actor tests remain where their primary concern is broader than FunctionLibraries.

## Conclusion

Use Runtime as the implicit FunctionLibraries domain, derive the contract from reflection metadata rather than a hand-maintained 237-row allowlist, fail on invalid mixin placement, and consolidate the focused tests into one flat directory. Keep the implementation compatible with the binding architecture present when the change is applied, and do not invent Editor coverage before an Editor-owned binding path exists.
