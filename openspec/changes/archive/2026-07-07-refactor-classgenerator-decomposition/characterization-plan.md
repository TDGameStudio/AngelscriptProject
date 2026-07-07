# ClassGenerator Characterization Test Plan (per-branch)

Concrete, executable test cases for the confirmed gaps in `coverage-gaps.md`. Each case names the file to add it in, the setup, and the exact assertion. All tests follow `Documents/UnitTest/UnitTest.md` (gate, in-class flow, class engine lifecycle, matcher asserts, `ASTEST_AS`; hot-reload cases assert observable behavior + clean up module/delegate handles). Prefix: `Angelscript.TestModule.ClassGenerator.*`.

Legend: **ADD FIRST** = must exist before extracting the matching phase unit.

## Gap 1 — Reload dependency propagation (ADD FIRST, before batch 3.3 `_ReloadPlanning`)

Target: `AddReloadDependency`, `PropagateReloadRequirements`, `ResolvePendingReloadDependees`. New file `AngelscriptClassGeneratorReloadPropagationTests.cpp`. Each case compiles V1, then reloads an edit that forces one type to require full reload, and asserts stable public behavior: the module reports full reload through the public reload query path, dependent reflected types are retargeted to the new type graph, and runtime-visible behavior remains correct. Do not rely on private per-class `EReloadRequirement` state unless a public test seam already exposes it.

| # | Scenario | Setup | Assertion |
|---|---|---|---|
| 1.1 | Single-hop property dependency | `A` has `UPROPERTY B B_Member`; edit `B` to force full reload | module reports full reload; `A.B_Member` points at the new `B` reflected type |
| 1.2 | Multi-hop A→B→C | `A`↦`B`↦`C` via property; force `C` full | module reports full reload; both `B` and `A` reflected properties retarget to the new chain |
| 1.3 | Cyclic A↔B | `A` has `B` member, `B` has `A` member; force one full | reload completes without recursion failure; both sides resolve to current reflected types |
| 1.4 | Super-class dependency | `A` extends script class `B`; force `B` full | `A` is rebuilt against the new `B` superclass and remains spawnable/queryable |
| 1.5 | Method signature type dependency | `A` has method `void M(B)` or `B M()`; force `B` full | generated `UFunction` parameters/return types retarget to the new `B` reflected type |
| 1.6 | Container subtype dependency | `A` has `TArray<B>` property; force `B` full | generated container inner type retargets to the new `B` reflected type |
| 1.7 | Delegate dependency | `A` uses delegate `D` (param/property); force `D` signature full | delegate signature and any `A` property/function using it retarget to the new delegate type |
| 1.8 | No over-escalation | `B` only soft-reloads (body-only) | module does not require full reload; `A` stays queryable and runtime behavior updates only where expected |

## Gap 2 — Interface-list-change classification (ADD FIRST, before batch 3.3)

Target: `HasInterfaceListChanged` (compares `ImplementedInterfaces`; old-invalid ⇒ true when new has any). File: `AngelscriptClassGeneratorInterfaceListTests.cpp`. Assert classification through public reload behavior and reflected interface metadata, not by reading the private comparison helper directly.

| # | Scenario | Assertion |
|---|---|---|
| 2.1 | Add an implemented interface on reload | module requires full reload; generated class exposes the added interface |
| 2.2 | Remove an implemented interface on reload | module requires full reload; generated class no longer exposes the removed interface |
| 2.3 | Reorder interface list only | current array-order behavior is pinned through resulting reload classification and interface metadata order |
| 2.4 | No interface change (body edit) | module does not require full reload solely because of interfaces |
| 2.5 | First compile with an interface (no old class) | generated class publishes with the expected interface metadata; no old-class comparison is asserted |

## Gap 3 — `VerifyClass` reject branches (before batch 3.7 `_Finalize`)

Target: `VerifyClass` (actor-only, `WITH_EDITOR`). Implemented in `AngelscriptComponentMetadataValidationTests.cpp`. Existing negative coverage for missing override and non-existent attach parent remains; the added cases pin stable public diagnostics/reflection behavior. Editor-only parent/root checks currently report `VerifyClass` error diagnostics while the helper compile path remains handled and can still publish the class, so tests assert the diagnostic and observable generated shape rather than hard compile failure. The `Dev.*` helper-module case characterizes the current boundary and does **not** assert a developer-only bypass unless a real published script-module path proves `UASClass::IsDeveloperOnly()`.

| # | Branch | Setup | Assertion |
|---|---|---|---|
| 3.1 | Accept path | valid actor with root + attached scene components | no error diagnostics; class publishes and generated actor/component metadata is queryable |
| 3.2 | Attach parent not a SceneComponent | `Attach` points to a non-scene component property | expected compile error is emitted; class is not published or prior published class remains intact |
| 3.3 | Non-editor comp → editor-only attach parent | child non-editor, parent editor-only, actor not editor-only | expected `VerifyClass` error diagnostic is emitted; handled compile still exposes the generated actor for observation |
| 3.4 | Editor-only comp as Root of non-editor actor | root default comp editor-only, actor not editor-only | expected `VerifyClass` error diagnostic is emitted; handled compile still exposes the generated actor for observation |
| 3.5 | `NotAngelscriptSpawnable` component type | default component of a `NotAngelscriptSpawnable` class | expected compile error is emitted; class is not published or prior class remains intact |
| 3.6 | Deprecated component type | default component of `CLASS_Deprecated` type | expected warning is emitted, not an error; class still publishes |
| 3.7 | `Dev.*` helper-module boundary | `Dev.*` module with an editor-only root default component | current behavior still reports the editor-only root `VerifyClass` diagnostic; class/property publication is observed without asserting developer-only bypass |

## Gap 4 — `Error` reload-requirement / name-conflict (ADD FIRST, before batch 3.2 `_Analyze`)

Target: `Analyze` name-conflict paths raising `ScriptCompileError` + error reload outcome. File: `AngelscriptClassGeneratorNameConflictTests.cpp`. Assert via expected diagnostics, compile/reload result, published-class absence, and follow-up reload behavior; do not read private `bModuleSwapInError` directly.

| # | Scenario | Assertion |
|---|---|---|
| 4.1 | Struct name conflicts with a non-struct UObject of same Unreal name | expected `ScriptCompileError` is emitted; conflicting generated type is not published |
| 4.2 | Class name collision with existing native/non-AS object | expected error is emitted; generated class is not published |
| 4.3 | Reload after a previous swap-in error forces full reload | after a rejected reload, a fixing reload reports/executes the full-reload path and publishes the corrected class |

## Gap 5 — Argument/return marshalling matrix (ADD FIRST, before batch 3.6 `_Generation`)

Target: `AddFunctionArgument` / `AddFunctionReturnType` flags + `UASFunction::FinalizeArguments` behavior classification. File: `AngelscriptASFunctionArgumentMatrixTests.cpp` (complement existing dispatch-selection + OptimizedCall + WorldContext tests; here assert generated `FProperty` flags AND real value round-trip through a call).

| # | Arg/return kind | Assertion |
|---|---|---|
| 5.1 | by-value POD (int/float/bool) | property flags `CPF_Parm` only; value passes in correctly |
| 5.2 | out ref (`bBlueprintOutRef`) | `CPF_OutParm` set (not `CPF_ReferenceParm`); write-back observed by caller |
| 5.3 | in-out ref (`bBlueprintInRef`) | `CPF_ReferenceParm|CPF_OutParm`; value read AND written |
| 5.4 | const ref | `CPF_ConstParm` set; value read-only |
| 5.5 | object pointer arg | `EArgumentVMBehavior::ObjectPointer`; pointer identity preserved |
| 5.6 | return object value vs POD vs pointer | correct `ReturnObject*` behavior; returned value/object correct |
| 5.7 | `FloatExtendedToDouble` arg and return | float↔double widening path both directions |
| 5.8 | default value | `CPP_Default_<arg>` metadata present (WITH_EDITOR) |

## Gap 6 — `ResolveCodeSuperForProperty` (before batch 3.6)

File: fold into gap-5 file or `AngelscriptScriptClassShapeTests.cpp`. Case: an object/subclass property whose type usage resolves to a native code super; assert the generated `FObjectProperty`/`FClassProperty` `PropertyClass`/`MetaClass` equals the resolved native super.

## Gap 7 — `CreateDebugValuePrototype` (before batch 3.8 `_Reinstancing`)

File: `AngelscriptASClassDebugValuePrototypeTests.cpp` only if `WITH_AS_DEBUGVALUES` exposes a stable observable path. Case: generate a class with several property kinds; assert the debugger-visible prototype/evaluation result contains the expected names/types. If no stable public or debugger-facing observation is available, record the gap as conditionally covered in `verification.md` and do not add a brittle private-field test.

## Gap 8 — Live-instance reinstancing across full reload (before batch 3.8)

Target: `DestructScriptObject` / `ReinitializeScriptObject`. File: `AngelscriptClassGeneratorReinstancingTests.cpp` (hot-reload rules apply). Case: spawn an instance of `A` (set a member value), full-reload `A` adding a property; assert the live instance is still valid, resolves to the new generated class/layout, preserves prior state, exposes the new property/default, and survives cleanup without double-destroy symptoms. Reuse `FAngelscriptTestWorld`; do not require an exact script destructor count unless an existing stable hook already exposes it.

## Gaps 9–10 — Finalize override-component detail + namespaced UCLASS (before batch 3.7)

- 9: extend `AngelscriptASClassComponentMetadataTests.cpp` — override-component variable binding/offset correctness, editor-only default component flag captured, attach **socket** (distinct from attach parent) recorded.
- 10: new/extend shape test — a namespaced `UCLASS` (`namespace X { UCLASS() class ... }`) generates and resolves via `GetNamespacedTypeInfoForClass`; assert the generated class is discoverable and spawnable under the expected name.

## Ordering summary

ADD FIRST (before their phase unit): gaps 1, 2 (before 3.3); gap 4 (before 3.2); gaps 5, 6 (before 3.6). Accompany their batch: gap 3, 9, 10 (with 3.7); gaps 7, 8 (with 3.8).
