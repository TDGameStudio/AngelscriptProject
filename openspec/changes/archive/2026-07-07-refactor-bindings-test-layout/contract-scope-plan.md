# Stage 2 — Bindings Contract-Smoke Consolidation Plan

This is the ready-to-execute plan for narrowing `AngelscriptTest/Bindings` from a second coverage-matrix layer into a **binding-surface contract/smoke layer**. Stage 1 already normalized formatting and recorded the boundary in `responsibility-boundary.md` and the spec; the source and docs do not yet match that boundary. This document is the disposition map for making them match.

## What the layers mean (decision rubric)

A test belongs in **Bindings/** when the primary question is:

> "Is this manually/default-bound class / function / method / property / operator / namespace entry visible to AS, callable through the expected declaration, and wired to the intended native path?"

A test belongs in **Coverage/** when the primary question is behavior saturation: many values, many language positions, many runtime/world states, cross-feature interaction, or a tracked coverage-gap row.

### Four dispositions per Bindings `.cpp`

- **Keep as contract** — already a narrow entrypoint/dispatch smoke; leave it.
- **Trim to smoke** — keep a minimal "bind exists + one representative call reaches native path" check; move the semantic body out.
- **Move/Delete duplicate** — Coverage already owns an equivalent matrix row; remove from Bindings after confirming the Coverage row exists.
- **Needs missing contract** — a high-value bind with no clear entrypoint smoke; add a small one.

## Non-negotiable migration safety rule

**Never delete a Bindings test before Coverage has an equivalent matrix row.** If the row is missing, add it to `Coverage/` first (with an `Angelscript.TestModule.Coverage.` test), verify it passes, and only then trim/remove the Bindings duplicate. This prevents net coverage loss during consolidation.

## Keep in Bindings (these ARE the contract layer)

These entrypoint kinds are exactly where binding dispatch breaks, so they stay:

- Overloads and overload resolution to the intended native path.
- Namespace / static functions (`System::...`, `Math::...`, `FString::Join/Format/ApplyFormat` existence-level).
- Operators, mixins, reflective fallback / fallback cache dispatch.
- Cross-module / direct-bind entries, delegate / dynamic-signature binds.
- Negative binding contracts only: null guard, wrong overload, intentionally exposed exception path, unsupported-boundary minimal compile/runtime assertion.
- Registration/dispatch proofs already pointed the right way: `ConsoleCommand` lifecycle, `ReflectiveFallbackCache`, EnhancedInput `BindAction` dynamic signature, `AssetManager` mixin callable from AS — keep, but do not let them grow into system-semantic matrices.

## Do NOT keep in Bindings (route to Coverage or functional)

- FString full method semantics, `ApplyFormat` format-specifier matrix, Split/Join/Mutation boundary combinations → Coverage `01-basic-types` (already has FString Property/Expression/Function/Method rows incl. Split/ParseIntoArray at `matrices/01-basic-types.md:163`).
- TArray/TMap/TSet type matrix, return-value matrix, nested-rejection matrix, large error-path matrix → Coverage `03-containers`.
- Math shortest-path, projection, exact color string, transform interpolation numeric semantics (`AngelscriptMathBindingsTests.cpp`) → Coverage `02-math-structs`.
- WorldCollision hit/miss parity, stale-output clearing, async callback tick → Coverage/Physics (`13-physics-collision`).
- UObject root lifecycle, flag mutation, object chain/nesting; AssetRegistry live query counts; EnhancedInput full mapping construction → Coverage `04-object-references` / assets / `12-input`, or functional tests.
- Anything that already has both a Coverage matrix row and a Coverage `TEST_METHOD` → migrate the reference or delete the duplicate; do not maintain a second matrix in Bindings.

## First-batch file disposition (heaviest, most Coverage-overlapping)

Confirm the Coverage target row exists (or add it) before trimming each.

| File | Current state | Disposition | Coverage target |
|---|---|---|---|
| `AngelscriptFStringBindingsTests.cpp` | Full semantic surface: Construction/Operators/Substring/Search/Mutation/Split/Format/Join/ApplyFormat/Pass-Return (header §Sections) | Trim to smoke: keep construct/operator/namespace-func existence + pass/return marshalling | `01-basic-types` §4 Strings |
| `AngelscriptTArrayBindingsTests.cpp` | `TArrayTypeMatrix`/`ObjectTypes`/`ReturnValues`/`ErrorPaths`/`NestedContainerRejection` via file-level `VerifyTArrayTypeMatrix` | Trim to smoke: declaration + representative method/operator + null/nested-rejection contract | `03-containers` |
| `AngelscriptMapBindingsTests.cpp` | `MapTypeMatrix`/`MapApiCoverage` | Trim to smoke | `03-containers` |
| `AngelscriptSetBindingsTests.cpp` (+ `...AdvancedTests.cpp`) | `SetTypeMatrix`/`SetApiCoverage` | Trim to smoke | `03-containers` |
| `AngelscriptWorldCollisionBindingsTests.cpp` | `SyncQueries` covers LineTrace/Sweep/Overlap hit/miss + native parity + output clearing | Trim: one callable smoke per `System::...` entrypoint | `13-physics-collision` |
| `AngelscriptWorldCollisionFunctionLibraryTraceTests.cpp` | LineTraceMultiHit/Miss/Sweep/Overlap behavior | Trim / Move behavior to Coverage; keep mixin bind existence | `13-physics-collision` |
| `AngelscriptWorldCollisionAsync*BindingsTests.cpp` | Async callback tick behavior | Keep async-registration smoke; move tick/behavior to Coverage | `13-physics-collision` |
| `AngelscriptUObjectBindingsTests.cpp` | `RootLifecycle`/`FlagMutation`/`ObjectChainAndNesting` | Trim: keep `NewObject`/`Cast`/`IsValid`/`GetClass` contract | `04-object-references` |
| `AngelscriptEnhancedInputBindingsTests.cpp` | `InputMappingContextRuntimeConstruction` builds 8 WASD/arrow mappings | Trim: keep BindAction dynamic-signature + namespace callable smoke | `12-input` |
| `AngelscriptAssetRegistryBindingsTests.cpp` | `QueryFilters` compares live registry results | Trim: keep namespace-function resolvable/callable smoke | assets matrix |
| `AngelscriptMathBindingsTests.cpp` | Shortest-path/projection/exact color/transform interpolation numerics | Trim: keep bind existence + representative call | `02-math-structs` |

The remaining Bindings `.cpp` files are triaged in task 6.2 using the same rubric. The current working tree has `90` active `.cpp` files and `5` `.h` helper/fixture headers under `Bindings/` after this change added `AngelscriptBlueprintTypeBindingsTests.cpp` and removed the obsolete `AngelscriptTArrayBindingsTestHelpers.h`.

## First-batch per-method disposition

Method lists below are the actual `TEST_METHOD`s in each file. Each file uses the "method delegates to a file-level `Verify*`/`Run*Section` helper" pattern, so trimming means (a) fold the kept methods into a small contract smoke and (b) delete the moved methods **and their now-unused file-level helpers**. Coverage target column names the existing `Angelscript.TestModule.Coverage.*` method; `ADD FIRST` means Coverage has no equivalent and the row must be added before deleting from Bindings.

### `AngelscriptFStringBindingsTests.cpp` (prefix `Bindings.FString`, 21 methods)

| Method | Disposition | Coverage target |
|---|---|---|
| `Construction`, `Operators`, `OperatorIndexError` | Keep as contract (ctor + operator dispatch + negative bounds) | — |
| `TypeConcat` | Keep as contract (opAdd overloads → `FToStringHelper` path) | — |
| `StaticConstruction` | Keep as contract (`FString::` namespace functions exist) | — |
| `ReturnFString`, `PassFString` | Keep as contract (return/arg marshalling) | — |
| `LengthAndCapacity`, `Substring`, `Search`, `CaseAndTrim`, `Conversion` | Move/Delete duplicate | `01-basic-types` §4 String Method/Expression |
| `Mutation`, `MutationExtended` | Move/Delete duplicate | `01-basic-types` §4 String Method |
| `Split`, `SplitExtended` | Move/Delete duplicate | `SplitMethods` `ParseIntoArrayDelimiterVariants` |
| `FormatString`, `Join`, `ApplyFormat` | Move (verify Coverage has Format/Join/ApplyFormat; else `ADD FIRST`) | `01-basic-types` §4 String Function |
| `Logging` | Move | debug/logging matrix `17` |

Result: FString shrinks from 21 methods to ~7 contract methods.

### Containers

`AngelscriptTArrayBindingsTests.cpp` (prefix `Bindings.Container.TArray`, 8 methods):

| Method | Disposition | Coverage target |
|---|---|---|
| `TArrayBaseline`, `TArrayIteration`, `TArrayOperations` | Trim → fold into one `TArrayContractSmoke` | — |
| `TArrayTypeMatrix`, `TArrayObjectTypes`, `TArrayReturnValues`, `TArrayErrorPaths` | Move/Delete duplicate | `03-containers` §1, §4 |
| `TArrayNestedContainerRejection` | Keep one minimal negative (binding boundary contract); move the large matrix | `03-containers` §5 `TArrayNestedContainers` |

`AngelscriptMapBindingsTests.cpp` (prefix `Bindings.Container.TMap`, 6 methods): keep `MapBaseline` + `MapFindFailureAndFindOrAddRef` (FindOrAdd ref dispatch) folded into `TMapContractSmoke`; Move `MapTypeMatrix`, `MapApiCoverage`, `MapReturnTypes`, `MapLogDiagnostics` → `03-containers` §2.

`AngelscriptSetBindingsTests.cpp` (prefix `Bindings.Container.TSet`, 5 methods): keep `SetBaseline` → `TSetContractSmoke`; Move `SetTypeMatrix`, `SetApiCoverage`, `SetReturnTypes`, `SetLogDiagnostics` → `03-containers` §3. Re-triage `AngelscriptSetBindingsAdvancedTests.cpp` and `AngelscriptContainerCompareBindingsTests.cpp` in the same pass.

Executed disposition:

| File | Result |
|---|---|
| `AngelscriptTArrayBindingsTests.cpp` | Trimmed to `TArrayContractSmoke` plus one `TArrayNestedContainerRejection` negative contract. |
| `AngelscriptMapBindingsTests.cpp` | Trimmed to one `TMapContractSmoke` covering Add/Find/FindOrAdd/ref-return dispatch. |
| `AngelscriptSetBindingsTests.cpp` | Trimmed to one `TSetContractSmoke` covering Add/Contains/Append/copy/compare dispatch. |
| `AngelscriptSetBindingsAdvancedTests.cpp` | Re-triaged and reduced to one `TSetAdvancedContractSmoke`; semantic append/copy/assignment/empty matrix remains owned by `03-containers`. |
| `AngelscriptContainerCompareBindingsTests.cpp` | Re-triaged and reduced to `SetAndMapCompareContractSmoke` plus native `OptionalTypeCompare` and `MapDebugger` contract tests. |
| `AngelscriptTArraySyntaxCompatBindingsTests.cpp` | Reduced from the old `int[]` API/type/return/error matrix to `TArraySyntaxContractSmoke`, `TArraySyntaxNestedContainerRejection`, and `ObjectArraySyntaxBoundary`. |
| `AngelscriptTArrayBindingsTestHelpers.h` | Removed because no remaining file uses the old TArray matrix helper surface. |

### `AngelscriptWorldCollisionBindingsTests.cpp` (prefix `Bindings.WorldCollision`, 1 method)

`SyncQueries` bundles LineTrace/Sweep/Overlap hit+miss + native parity + output-array clearing. Split into `SyncQueryEntrypointSmoke`: one callable `System::LineTrace*`, one `System::Sweep*`, one `System::Overlap*` proving each entrypoint reaches native. Move hit/miss parity + stale-output clearing → `13-physics-collision` §3 (`TraceOperations`, `OverlapDetection`, `TraceObjectProfileAndSweepVariants` already exist → mostly delete after confirm). Apply same to `AngelscriptWorldCollisionFunctionLibraryTraceTests.cpp`, `AngelscriptWorldCollisionFunctionLibraryComponentTests.cpp`, `AngelscriptWorldCollisionAsyncBindingsTests.cpp`, `AngelscriptWorldCollisionAsyncSweepBindingsTests.cpp` (keep async-registration smoke; move tick/behavior).

### `AngelscriptUObjectBindingsTests.cpp` (prefix `Bindings.UObject`, 13 methods)

| Method | Disposition | Coverage target |
|---|---|---|
| `CreateAndIdentity`, `NewObjectVariants` | Keep (NewObject dispatch) | — |
| `TypeQueryAndCast`, `ClassReflection` | Keep (Cast / GetClass) | — |
| `NullAndIsValid`, `ReturnValueCrossCheck`, `CppToScriptPassthrough` | Keep (IsValid + marshalling) | — |
| `FindAndLookup` | Keep (StaticFind binds) | — |
| `HierarchyAndOuter` | Trim: keep minimal `GetOuter` contract; move deep chain | `04` §1 (partial) |
| `RootLifecycle` | Move | `04` §6 `GCRootReachability` |
| `FlagMutation` | Move — `ADD FIRST` (no Coverage row for object flags) | `05-uclass` / `04` `ADD FIRST` |
| `ObjectChainAndNesting` | Move — verify vs `HierarchyAndOuter`; else `ADD FIRST` | `04` §1 |
| `LogAndDiagnostics` | Move | `17-debug-logging` |

### `AngelscriptEnhancedInputBindingsTests.cpp` (prefix `Bindings.EnhancedInput`, 9 methods)

| Method | Disposition | Coverage target |
|---|---|---|
| `InputActionValueMulAssign`, `InputActionValueConstructorsAndAxisTypes`, `InputActionValueConvertToType` | Keep (operator/ctor/convert dispatch) | — |
| `EnhancedInputComponentConstAccess`, `EnhancedInputComponentBindActionAcceptsDynamicSignature`, `EnhancedInputComponentRemoveBindingCompiles` | Keep (BindAction dynamic-signature dispatch — high value) | — |
| `InputDebugKeyBindingExecute`, `EnhancedInputComponentEditorDelegateFlags` | Keep (mixin/editor-flag dispatch) | — |
| `InputMappingContextRuntimeConstruction` | Move/Delete duplicate | `12-input` `EnhancedInputMappingContextAndActionValues` |

### `AngelscriptMathBindingsTests.cpp` (prefix `Bindings.Math`, 2 methods)

Both are numeric semantics. Replace with one `MathNamespaceBindSmoke` proving representative `Math::`/struct methods exist and dispatch. Move the numerics:

| Method | Disposition | Coverage target |
|---|---|---|
| `ShortestPathAndTransformSemantics` | Move (transform interp/composition exist); shortest-path rotation `ADD FIRST` if absent | `02` §5 `TransformInterpolation` `TransformComposition` |
| `PlanarProjectionAndColorFormatting` | Move (color formatting exists); planar projection `ADD FIRST` if absent | `02` §6 LinearColor + Vector rows |

## Bind_*.cpp → Bindings contract-smoke inventory (task 6.1)

`AngelscriptRuntime/Binds` has `~121` `Bind_*.cpp` files. This pass does not attempt to create a one-to-one test file for every bind file; it records the high-value manual binds that are easiest to break and must have an explicit Bindings-layer contract smoke.

| Manual bind | Contract smoke status | Binding test owner |
|---|---|---|
| `Bind_AActor.cpp` | Has dedicated contract smoke | `AngelscriptNativeEngineBindingsTests.cpp::NativeActorMethods`, `ActorComponentFactoryContract` |
| `Bind_APlayerController.cpp` | Has dedicated contract smoke | `AngelscriptNativeEngineBindingsTests.cpp::PlayerControllerContract` |
| `Bind_UActorComponent.cpp` | Has dedicated contract smoke | `AngelscriptNativeEngineBindingsTests.cpp::ComponentDestroy`, `ComponentActivationAndTag`, `ActorComponentFactoryContract` |
| `Bind_USceneComponent.cpp` | Has dedicated contract smoke | `AngelscriptNativeEngineBindingsTests.cpp::NativeComponentMethods` |
| `Bind_UProjectileMovementComponent.cpp` | Has dedicated contract smoke | `AngelscriptMeshComponentBindingsTests.cpp::ProjectileMovement` |
| `Bind_Delegates.cpp` | Has dedicated contract smoke | `AngelscriptFileAndDelegateBindingsTests.cpp::ScriptDelegateBinding`, `ScriptDelegateExecution`, `DelegateWithPayloadPaths` |
| `Bind_BlueprintCallable.cpp` | Has dedicated contract smoke | `AngelscriptReflectiveFallbackCacheTests.cpp` plus `AngelscriptBlueprintTypeBindingsTests.cpp::BlueprintEventAndUStructContractSmoke` |
| `Bind_BlueprintEvent.cpp` | Has dedicated contract smoke | `AngelscriptBlueprintTypeBindingsTests.cpp::BlueprintEventAndUStructContractSmoke` |
| `Bind_BlueprintType.cpp` | Has dedicated contract smoke | `AngelscriptClassBindingsTests.cpp::{StaticClassAccess, NativeStaticClassNamespace, NativeStaticTypeGlobal, UClassReflection}` and `AngelscriptBlueprintTypeBindingsTests.cpp::BlueprintEventAndUStructContractSmoke` |
| `Bind_UStruct.cpp` | Has dedicated contract smoke | `AngelscriptBlueprintTypeBindingsTests.cpp::BlueprintEventAndUStructContractSmoke`; deeper execution matrix remains in Delegate/Compiler/Coverage |
| `Bind_WorldCollision.cpp` | Has dedicated contract smoke after trim | `AngelscriptWorldCollisionBindingsTests.cpp`, `AngelscriptWorldCollisionFunctionLibraryTraceTests.cpp`, `AngelscriptWorldCollisionFunctionLibraryComponentTests.cpp`, async registration smokes |
| `Bind_UObject.cpp` | Has dedicated contract smoke after trim | `AngelscriptUObjectBindingsTests.cpp` plus migrated object-reference Coverage rows |
| `Bind_UEnhancedInputComponent.cpp`, `Bind_UInputMappingContext.cpp`, `Bind_FInputActionValue.cpp` | Has dedicated contract smoke after trim | `AngelscriptEnhancedInputBindingsTests.cpp`; full mapping matrix moved to Coverage |
| `Bind_AssetRegistry.cpp` | Has dedicated contract smoke after trim | `AngelscriptAssetRegistryBindingsTests.cpp`; live query parity moved to Coverage |

Result for task 6.1: no high-value bind from the flagged list remains `missing`. Several broad semantic bind families still deserve future trimming, but they are no longer blockers for this Stage 2 source pass.

## FunctionLibraries placement decision (task 6.3)

Several files physically in `Bindings/` register with `Angelscript.TestModule.FunctionLibraries.*` (e.g. `AngelscriptAssetManagerFunctionLibraryTests.cpp`) instead of `Angelscript.TestModule.Bindings.*`. This is not an immediate error but the directory responsibility is ambiguous. Choose one and record it:

- **Option A (recommended):** declare function-library mixin binds part of the Bindings contract surface; normalize their prefix to `Angelscript.TestModule.Bindings.FunctionLibraries.*` and keep them in `Bindings/`.
- **Option B:** split function-library mixin tests into their own directory/prefix.

Recommendation: Option A — mixin binds are exactly "does this AS-visible library function exist and dispatch to native", which is the Bindings contract question.

Decision: **Option A is adopted for Stage 2.** Function-library mixin binds stay in `Bindings/` as binding-surface contract tests. Follow-up source batches should normalize `Angelscript.TestModule.FunctionLibraries.*` prefixes to `Angelscript.TestModule.Bindings.FunctionLibraries.*` only when touching those files, so this responsibility cleanup does not become an unrelated mass rename.

## Coverage ownership check (task 5.3)

Checked against `openspec/changes/test-coverage` and current `Plugins/Angelscript/Source/AngelscriptTest/Coverage` files:

| Domain shed from Bindings | Coverage owner | Result before trimming |
|---|---|---|
| FString length/search/mutation/case/split/format/conversion semantics | `matrices/01-basic-types.md` §4, `AngelscriptCoverageFString*Tests.cpp` | Covered. `FormatMethods`, `SplitMethods`, `ParseIntoArrayDelimiterVariants`, expression/property/function/method rows own the semantic matrix. `FString::Join` is represented by existing string-family/text join coverage but remains only smoke-level in Bindings. |
| TArray/TMap/TSet operation/type/return/nested matrices | `matrices/03-containers.md`, `AngelscriptCoverageTArrayAdvancedTests.cpp`, `AngelscriptCoverageTMapAdvancedTests.cpp`, `AngelscriptCoverageTSetAdvancedTests.cpp`, nested/parameter tests | Covered. Nested container diagnostics and return/parameter coverage exist. |
| WorldCollision hit/miss, trace/sweep/overlap variants, stale output behavior | `matrices/13-physics-collision.md`, `AngelscriptCoveragePhysicsTests.cpp` | Trace/sweep/overlap variants are covered. Async tick/callback exact behavior still needs add-first if removed from Bindings. |
| UObject root reachability / weak invalidation / object inspection | `matrices/04-object-references.md`, `matrices/17-debug-logging.md`, GC/Handle/Debug coverage tests | Root/UPROPERTY reachability and object inspection are covered. Object flag mutation and object-chain/nesting need add-first or explicit matrix row before deletion. |
| EnhancedInput mapping context / action values | `matrices/12-input.md`, `AngelscriptCoverageInputTests.cpp` | MappingContext/ActionValue owner exists. Do not delete Swizzle/FOVScaling-specific binding checks until G22 is handled; G20 trigger-event reflection assertions also remain pending. |
| AssetRegistry live query comparisons | `matrices/16-assets-and-save.md`, asset loading/literal asset coverage | Asset path/loading coverage exists, but live AssetRegistry query-count parity is not clearly owned. Add a Coverage row/test before deleting `QueryFilters`. |
| Math shortest-path / transform / projection / color formatting numerics | `matrices/02-math-structs.md`, math struct/function coverage tests | Transform/color/geometric struct coverage exists. The Bindings file was reduced to a representative `MathNamespaceBindSmoke`; any future exact shortest-path/projection assertion belongs in Coverage. |

## Per-file disposition table (task 6.2)

| File | Disposition | Notes |
|---|---|---|
| `AngelscriptAssetManagerFunctionLibraryTests.cpp` | Keep as contract | Function-library mixin callable/null-guard contract. |
| `AngelscriptAssetRegistryBindingsTests.cpp` | Trimmed to smoke | Kept top-level path/null-parent contract; live query parity moved to Coverage. |
| `AngelscriptBlueprintTypeBindingsTests.cpp` | Needs missing contract -> added | New focused contract for `BlueprintEvent`, `BlueprintType`, AS `USTRUCT`, and callable reflection flags. |
| `AngelscriptBodyInstanceBindingsTests.cpp` | Keep as contract | Single value-type default construction smoke. |
| `AngelscriptBox3fBindingsTests.cpp` | Keep as contract | Box/bounds constructor surface smoke. |
| `AngelscriptClassBindingsTests.cpp` | Keep as contract | UClass/TSubclassOf/static-type binding surface; broader class semantics stay elsewhere. |
| `AngelscriptCollisionBindingsTests.cpp` | Keep as contract | Collision shape/query params constructor smoke. |
| `AngelscriptCollisionParamsBindingsTests.cpp` | Trim later | Still behavior-heavy; `13-physics-collision` should own any large params matrix. |
| `AngelscriptCollisionProfileBindingsTests.cpp` | Keep as contract | Object/trace profile conversion entrypoints. |
| `AngelscriptCollisionValueBindingsTests.cpp` | Keep as contract | Collision value accessor surface. |
| `AngelscriptColorBindingsTests.cpp` | Keep as contract | Construction/conversion smoke. |
| `AngelscriptCompatBindingsTests.cpp` | Trim later | Mixed compatibility scenarios; keep until a separate compatibility/Coverage owner is mapped. |
| `AngelscriptConsoleBindingsTests.cpp` | Keep as contract | Console variable/command registration and negative signature contracts. |
| `AngelscriptConsoleCommandArgumentBindingsTests.cpp` | Keep as contract | Console argument order/empty marker contract. |
| `AngelscriptConsoleCommandErrorBindingsTests.cpp` | Keep as contract | Console error contract. |
| `AngelscriptConsoleCommandLifecycleBindingsTests.cpp` | Keep as contract | Registration replacement/unload contract. |
| `AngelscriptConsoleVariableIdentityTests.cpp` | Keep as contract | Existing CVar identity contract. |
| `AngelscriptContainerBindingsTests.cpp` | Move/Delete duplicate | Deprecated empty placeholder; no registration. |
| `AngelscriptContainerCompareBindingsTests.cpp` | Trimmed to smoke | Reduced to compare/debugger contract smokes. |
| `AngelscriptCoreMiscBindingsTests.cpp` | Trim later | Paths/guid/formatting mixed surface; currently acceptable but broader than smoke. |
| `AngelscriptCpuProfilerBindingsTests.cpp` | Keep as contract | Scoped profiler binding smoke. |
| `AngelscriptCurveFunctionLibraryTests.cpp` | Keep as contract | Runtime curve function-library entrypoints. |
| `AngelscriptDataTableBindingsTests.cpp` | Keep as contract | DataTable row handle/category/error surface. |
| `AngelscriptDateTimeBindingsTests.cpp` | Trim later | Parse/format semantic matrix should move to Coverage in a later batch. |
| `AngelscriptDebugBindingsTests.cpp` | Keep as contract | Callstack/throw entrypoint smoke. |
| `AngelscriptEngineBindingsTests.cpp` | Trim later | FName array/foreach/value paths overlap with Coverage but not part of this batch. |
| `AngelscriptEnhancedInputBindingsTests.cpp` | Trimmed to smoke | Runtime mapping matrix moved to Coverage; dynamic-signature and binding-handle smokes remain. |
| `AngelscriptEnumBindingsTests.cpp` | Keep as contract | Enum name/index/string/display binding surface. |
| `AngelscriptFileAndDelegateBindingsTests.cpp` | Keep as contract | Delegate, soft path, source metadata, file helper contracts. |
| `AngelscriptFNameBindingsTests.cpp` | Keep as contract | FName constructor/equality/string smoke. |
| `AngelscriptForeachBindingsTests.cpp` | Trim later | Iteration behavior matrix likely belongs under container Coverage. |
| `AngelscriptFormatEngineScopeTests.cpp` | Keep as contract | Multi-engine type-info binding regression. |
| `AngelscriptFrameTimeFunctionLibraryTests.cpp` | Keep as contract | Function-library baseline/mixin surface. |
| `AngelscriptFStringBindingsTests.cpp` | Trimmed to smoke | Semantic string matrix moved to Coverage/logging. |
| `AngelscriptFStringFormatMultiEngineTests.cpp` | Keep as contract | Multi-engine binding lifetime regression. |
| `AngelscriptGameInstanceLocalPlayerBindingsTests.cpp` | Keep as contract | GameInstance/LocalPlayer accessor contracts. |
| `AngelscriptGameplayFunctionLibraryTests.cpp` | Keep as contract | Async save/load delegate binding contracts. |
| `AngelscriptGlobalBindingsTests.cpp` | Keep as contract | Global/commandlet variable binding surface. |
| `AngelscriptGuidBindingsTests.cpp` | Keep as contract | GUID format/parse/string constructor contracts. |
| `AngelscriptHitResultBindingsTests.cpp` | Keep as contract | Hit/overlap value-type constructor/accessor smoke. |
| `AngelscriptHitResultFunctionLibraryTests.cpp` | Keep as contract | HitResult mixin accessor smoke. |
| `AngelscriptInputBindingsTests.cpp` | Keep as contract | FInputActionValue/FKey construction surface. |
| `AngelscriptInputComponentMixinBindingsTests.cpp` | Keep as contract | Platform application mixin entrypoint. |
| `AngelscriptInstancedStructBindingsTests.cpp` | Keep as contract | FInstancedStruct availability/default/reset smoke. |
| `AngelscriptIntVectorBindingsTests.cpp` | Keep as contract | Int vector arithmetic/constructor smoke. |
| `AngelscriptIteratorBindingsTests.cpp` | Keep as contract | Iterator entrypoint contracts; broader foreach matrix remains separate. |
| `AngelscriptJsonBindingsTests.cpp` | Keep as contract | JSON object/error path binding surface. |
| `AngelscriptJsonObjectConverterBindingsTests.cpp` | Keep as contract | UStruct JSON conversion entrypoints and error boundaries. |
| `AngelscriptMapBindingsTests.cpp` | Trimmed to smoke | Container semantic matrix moved to `03-containers`. |
| `AngelscriptMathAndPlatformBindingsTests.cpp` | Trim later | Broad math/platform semantics; leave for future Coverage-backed split. |
| `AngelscriptMathBindingsTests.cpp` | Trimmed to smoke | Numeric semantics moved to math Coverage. |
| `AngelscriptMathOrientationBindingsTests.cpp` | Trim later | Orientation numeric matrix should move to `02-math-structs` in a later batch. |
| `AngelscriptMemoryReaderBindingsTests.cpp` | Keep as contract | Read/out-of-bounds binding surface. |
| `AngelscriptMeshComponentBindingsTests.cpp` | Keep as contract | Projectile movement and mesh accessor contracts. |
| `AngelscriptMessageDialogBindingsTests.cpp` | Keep as contract | Type-check surface. |
| `AngelscriptNativeEngineBindingsTests.cpp` | Needs missing contract -> added | Expanded actor/component/player-controller contract smokes. |
| `AngelscriptObjectBindingsTests.cpp` | Keep as contract | Object pointer / soft object pointer surface. |
| `AngelscriptOptionalBindingsTests.cpp` | Trim later | Still has type/API/return/error matrix; future Coverage owner needed before shrinking. |
| `AngelscriptPathsBindingsTests.cpp` | Keep as contract | FPaths/FApp/FCommandLine entrypoint smoke. |
| `AngelscriptPlatformMiscBindingsTests.cpp` | Keep as contract | Core globals/platform/timer entrypoint smoke. |
| `AngelscriptPrimitiveComponentBindingsTests.cpp` | Trim later | Mutable primitive-component state is broader than contract; keep pending Coverage owner. |
| `AngelscriptQuat3fBindingsTests.cpp` | Keep as contract | 3f rotator/quat/transform construction smoke. |
| `AngelscriptQuatBindingsTests.cpp` | Trim later | Quat numeric matrix should move to math Coverage in a later batch. |
| `AngelscriptRandomStreamBindingsTests.cpp` | Trim later | Random sequence semantics belong in Coverage if reduced. |
| `AngelscriptReflectiveFallbackCacheTests.cpp` | Keep as contract | BlueprintCallable reflective fallback dispatch contract. |
| `AngelscriptScriptFunctionLibraryTests.cpp` | Keep as contract | Global init context/library entrypoints. |
| `AngelscriptSetBindingsAdvancedTests.cpp` | Trimmed to smoke | Advanced set semantics moved to `03-containers`. |
| `AngelscriptSetBindingsTests.cpp` | Trimmed to smoke | Container semantic matrix moved to `03-containers`. |
| `AngelscriptSoftReferenceFunctionLibraryTests.cpp` | Keep as contract | Async delegate soft-reference function-library contracts. |
| `AngelscriptSphere3fBindingsTests.cpp` | Keep as contract | Sphere/plane constructor smoke. |
| `AngelscriptStringTableBindingsTests.cpp` | Keep as contract | Localized string table lookup contract. |
| `AngelscriptSubsystemBindingsTests.cpp` | Keep as contract | Subsystem namespace/static/local-player accessor contracts. |
| `AngelscriptTArrayBindingsTests.cpp` | Trimmed to smoke | Container semantic matrix moved to `03-containers`. |
| `AngelscriptTArraySyntaxCompatBindingsTests.cpp` | Trimmed to smoke | Old `int[]` syntax matrix reduced to syntax/negative contracts. |
| `AngelscriptTextFormattingBindingsTests.cpp` | Keep as contract | FText ordered/named formatting surface. |
| `AngelscriptTimespanBindingsTests.cpp` | Trim later | Timespan semantic matrix should move to Coverage in a later batch. |
| `AngelscriptTransformBindingsTests.cpp` | Trim later | Transform numeric semantics overlap `02-math-structs`. |
| `AngelscriptUILayoutBindingsTests.cpp` | Keep as contract | FMargin/FAnchors construction smoke. |
| `AngelscriptUObjectBindingsTests.cpp` | Trimmed to smoke | Lifecycle/flags/outer-chain coverage moved to Coverage/logging. |
| `AngelscriptUserWidgetBindingsTests.cpp` | Keep as contract | Widget tree accessor/error contracts. |
| `AngelscriptUtilityBindingsTests.cpp` | Trim later | Hash/parse/random/string utility mix is broad; future owner needed. |
| `AngelscriptVolumeBindingsTests.cpp` | Keep as contract | Volume/FX system type availability smoke. |
| `AngelscriptWidgetFunctionLibraryTests.cpp` | Keep as contract | Widget render-transform null guard contract. |
| `AngelscriptWorldBindingsTests.cpp` | Keep as contract | World context/global accessor smoke. |
| `AngelscriptWorldCollisionAsyncBindingsTests.cpp` | Trimmed to smoke | Async registration smoke only; callback/tick matrix belongs to physics Coverage. |
| `AngelscriptWorldCollisionAsyncSweepBindingsTests.cpp` | Trimmed to smoke | Async sweep registration smoke only. |
| `AngelscriptWorldCollisionBindingsTests.cpp` | Trimmed to smoke | Sync trace/sweep/overlap entrypoint smoke only. |
| `AngelscriptWorldCollisionFunctionLibraryComponentTests.cpp` | Trimmed to smoke | Component query function-library entrypoint smoke. |
| `AngelscriptWorldCollisionFunctionLibraryTraceTests.cpp` | Trimmed to smoke | Trace function-library entrypoint smoke. |
| `AngelscriptWorldFunctionLibraryTests.cpp` | Keep as contract | World streaming function-library null guard/access contracts. |

## Source execution notes (Stage 2)

- `AngelscriptFStringBindingsTests.cpp`: executed 7.2 source trim. The file now has 7 contract methods (`Construction`, `Operators`, `OperatorIndexError`, `TypeConcat`, `StaticConstruction`, `ReturnFString`, `PassFString`) and no longer carries the FString semantic matrix.
- `AngelscriptTArrayBindingsTests.cpp`, `AngelscriptMapBindingsTests.cpp`, `AngelscriptSetBindingsTests.cpp`, `AngelscriptSetBindingsAdvancedTests.cpp`, `AngelscriptContainerCompareBindingsTests.cpp`, `AngelscriptTArraySyntaxCompatBindingsTests.cpp`: executed 7.3 container trim. The files now retain binding-surface smoke coverage only; container API/type/return/error matrices remain owned by `03-containers`. Removed obsolete `AngelscriptTArrayBindingsTestHelpers.h`.
- `AngelscriptMathBindingsTests.cpp`: executed 7.7 source trim. The file now has one `MathNamespaceBindSmoke` method proving representative `Math::`, `FTransform`, `FVector`, and debug-string bindings resolve and dispatch.
- `AngelscriptWorldCollisionBindingsTests.cpp`, `AngelscriptWorldCollisionFunctionLibraryTraceTests.cpp`, `AngelscriptWorldCollisionFunctionLibraryComponentTests.cpp`, `AngelscriptWorldCollisionAsyncBindingsTests.cpp`, `AngelscriptWorldCollisionAsyncSweepBindingsTests.cpp`: executed 7.4 source trim. Sync query and function-library files now prove representative trace/sweep/overlap entrypoints, while async files retain registration smokes only.
- `AngelscriptUObjectBindingsTests.cpp`: executed 7.5 source trim. The file now has 8 contract methods for NewObject/identity, outer, type query/cast, find object, null/IsValid, class reflection, return/argument marshalling, and C++→script passthrough. `UObjectFlagMutationAndTransientState` and `UObjectOuterChainAndPathMatrix` were added to Coverage first.
- `AngelscriptEnhancedInputBindingsTests.cpp`: executed 7.6 source trim. The runtime mapping-context matrix moved to `Coverage/AngelscriptCoverageInputTests.cpp::EnhancedInputRuntimeMappingContextMatrix`; dynamic-signature, action-value, debug-key, and editor delegate contracts remain.
- `AngelscriptAssetRegistryBindingsTests.cpp`: executed 7.6 source trim. The live registry query parity moved to `Coverage/AngelscriptCoverageAssetLoadingTests.cpp::AssetRegistryLiveQueryParity`; Bindings keeps `TopLevelPathAndNullParent`.
- `AngelscriptNativeEngineBindingsTests.cpp`: executed 7.8 high-value expansion for AActor component factory helpers, APlayerController accessors, and additional UActorComponent/USceneComponent entrypoints.
- `AngelscriptBlueprintTypeBindingsTests.cpp`: executed 7.8 missing-contract addition for `Bind_BlueprintEvent.cpp`, `Bind_BlueprintType.cpp`, and `Bind_UStruct.cpp`.

## Why doc realignment goes first

`UnitTest.md` §4 currently tells authors to organize Bindings by "type matrix / API entry-point coverage / boundary / exception", and `TestConventions.md` labels Bindings "按类型的绑定覆盖". Until those are rewritten to the contract-smoke framing, any trimming done in source will be re-grown by the next author following the docs. Realign docs (tasks 5.1–5.2) before executing the source dispositions.
