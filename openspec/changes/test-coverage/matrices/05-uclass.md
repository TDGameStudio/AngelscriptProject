# UCLASS and Class System Coverage Matrix

> **This matrix is the design specification ("header") for UCLASS/class-system tests**: each row is a concrete verifiable scenario that guides implementation across five test files. ⬜ = pending, ✅ identifies the covering `TEST_METHOD`, and 🚫 = fork-unsupported/rejected boundary.
>
> - Test files: `UClass`(36) / `UClassProperty`(18) / `UClassDefaultComponent`(6) / `ClassLifecycle`(9) / `ClassFeatures`(14) Tests.cpp
> - Automation prefixes: `Angelscript.TestModule.Coverage.UClass`, `UClass.Property`, `UClass.DefaultComponent`, `ClassLifecycle`, `ClassFeatures`
> - See `../coverage-matrix.md` for the legend.

## 1. Class Declarations (UClassTests)

| Scenario | Status | Covering Test Method |
|------|------|------------|
| Basic type declarations (`AActor` and other base classes) | ✅ | `UClassBaseTypeDeclarations` |
| Common engine base class declarations | ✅ | `UClassCommonEngineBaseDeclarations` |
| Gameplay framework reference surface | ✅ | `UClassGameFrameworkReferenceSurface` |

## 2. Specifiers and Metadata (UClassTests + ClassFeatures)

| Scenario | Status | Covering Test Method |
|------|------|------------|
| Blueprintable/Abstract specifiers | ✅ | `UClassBlueprintAndAbstractSpecifiers` |
| Config/Inline creation specifiers | ✅ | `UClassConfigAndInlineCreationSpecifiers` |
| Behavior flags / inherited flags and Config | ✅ | `UClassBehaviorFlags` `UClassInheritedFlagsAndConfig` |
| Display/category/special/script-only metadata | ✅ | `UClassDisplayAndCategoryMetadata` `UClassSpecialAndInheritedMetadata` `UClassScriptOnlyAndDisplayNameMetadata` |
| Ignore-category keywords in subclasses | ✅ | `UClassIgnoreCategoryKeywordsInSubclasses` |
| Specifier cross-product/order/duplicate-ordering matrix | ✅ | `UClassSpecifierCrossProductMatrix` `UClassSpecifierOrderAndBoundaryCombinations` `UClassSpecifierDuplicateOrderingMatrix` |
| Specifiers and metadata (ClassFeatures) | ✅ | `ClassFeatures::UClassSpecifiersAndMetadata` `UClassSpecifierCombinations` |
| Specifier-list syntax / invalid combinations / unsupported boundaries | 🚫 | `UClassSpecifierListSyntaxBoundaryMatrix` `UClassNonActorComponentSpecifierMetadataBoundary` `UClassUnsupportedSpecifierBoundaries` |

## 3. Access Control and Inheritance (UClassTests + ClassFeatures)

| Scenario | Status | Covering Test Method |
|------|------|------------|
| Default inherited-property surface | ✅ | `UClassDefaultInheritancePropertySurface` |
| private/AllowPrivateAccess visibility | ✅ | `UClassPrivateAllowPrivateAccessPropertyVisibility` |
| Access-control compile failures (boundary) | 🚫 | `UClassAccessControlCompileFailures` |
| Access modifiers / abstract classes / inheritance chains / casts / composition references | ✅ | `ClassFeatures::AccessModifiers` `AbstractClass` `InheritanceChain` `ClassCasting` `CompositionReferences` |
| Script class implements native UINTERFACE runtime dispatch / script-level interface rejection boundary | ✅ | `ClassFeatures::InterfaceImplementation` |

## 4. Runtime Dispatch and Lifecycle (UClassTests + ClassLifecycle)

| Scenario | Status | Covering Test Method |
|------|------|------------|
| Abstract inheritance and runtime casting | ✅ | `UClassAbstractInheritanceAndCastingRuntime` |
| CDO default object and method dispatch | ✅ | `UClassUObjectDefaultObjectAndMethodDispatch` |
| CDO ↔ instance independence (new instances inherit CDO mutations; instance mutations do not pollute the CDO) | ✅ | `UClassDefaultObjectAndInstanceStateIndependence` |
| Common lifecycle/subsystem/Gameplay event function surface | ✅ | `UClassCommonLifecycleFunctionSurface` `UClassSubsystemFunctionSurface` `UClassGameFrameworkEventFunctionSurface` |
| Actor/Pawn/Component/Widget lifecycle | ✅ | `ClassLifecycle::ActorLifecycle` `PawnLifecycle` `ComponentLifecycle` `WidgetLifecycle` |
| Actor-owned Tick/EndPlay/Destroyed runtime dispatch assertions | 🟡 | (G9): `ActorLifecycle` and `MultiLevelInheritanceLifecycle` declare script-side Tick/EndPlay/Destroyed overrides but only assert BeginPlay; test comments acknowledge that this needs more complex world/lifecycle setup. The Component side already drives Tick/EndPlay through `DispatchComponentTick` + `DestroyComponent` in `ComponentLifecycle`; the Actor side is still missing that equivalent coverage |
| Actor construction script / component initialization / multi-level inheritance lifecycle | ✅ | `ClassLifecycle::ActorConstructionScript` `ActorComponentInitialization` `MultiLevelInheritanceLifecycle` |
| Abstract Actor spawn is rejected (boundary) | 🚫 | `UClassAbstractActorSpawnIsRejected` |
| HUD DrawHUD reflection-dispatch boundary | 🚫 | `UClassHUDDrawHUDReflectionDispatchBoundary` |
| Subsystem lifecycle reflection boundary | 🚫 | `ClassLifecycle::SubsystemLifecycleReflectionBoundaries` |
| PostInitializeComponents cannot be used as BlueprintOverride (boundary, implicitly covered) | 🚫 | Included in `ClassLifecycle::ActorComponentInitialization` |
| BlueprintOverride boundary for native-only virtual methods such as PostLoad / PreSave / PostInitProperties / BeginDestroy / FinishDestroy / Reset | 🚫 | `ClassLifecycle::NativeOnlyVirtualOverrideBoundaries` |

## 5. Default Subobject Components (UClassTests + UClassDefaultComponent + ClassFeatures)

| Scenario | Status | Covering Test Method |
|------|------|------------|
| Default component tree and reference surface / runtime operations | ✅ | `UClassDefaultComponentTreeAndReferenceSurface` `UClassComponentRuntimeOperationSurface` |
| Component-derived type matrix | ✅ | `UClassComponentDerivedTypeMatrix` |
| Default component specifier permutations / implicit-root permutations | ✅ | `UClassDefaultComponentSpecifierPermutationMatrix` `UClassDefaultComponentImplicitRootPermutation` |
| Override/native-parent override component matrix | ✅ | `UClassOverrideComponentSpecifierMatrix` `UClassNativeParentOverrideComponentMatrix` |
| Root/attach/socket/inheritance/implicit-root/invalid specifiers (DefaultComponent file) | ✅ | `DefaultComponentRootAttachSocketRuntimeMatrix` `DefaultComponentShowOnActorSpecifierSurface` `DefaultComponentNativeComponentTypeMatrix` `DefaultComponentInheritanceAndForwardAttachMatrix` `DefaultComponentImplicitRootAndDelayedAttachMatrix` `DefaultComponentInvalidSpecifierBoundaryMatrix` |
| Component declarations/specifiers/types (ClassFeatures + `default` keyword) | ✅ | `ClassFeatures::ComponentDeclaration` `ComponentSpecifierMetadata` `ComponentTypes` `DefaultKeywordOverride` `DefaultKeywordMethods` `DefaultKeywordContainersAndComponents` |
| Invalid component specifier combinations (boundary) | 🚫 | `UClassComponentSpecifierInvalidCombinationBoundaries` |

## 6. UObject Property Reference Semantics (UClassPropertyTests 18)

| Scenario | Status | Covering Test Method |
|------|------|------------|
| Scalar/text/struct member matrix | ✅ | `UClassScalarTextStructMemberMatrix` |
| Reference members / reference-container member matrix | ✅ | `UClassReferenceMemberMatrix` `UClassReferenceContainerMemberMatrix` |
| Interface member matrix | ✅ | `UClassInterfaceMemberMatrix` |
| Container/enum-container/script-struct-container member matrix | ✅ | `UClassContainerMemberMatrix` `UClassEnumContainerMemberMatrix` `UClassScriptStructMemberContainerMatrix` |
| Optional member matrix | ✅ | `UClassOptionalMemberMatrix` |
| Delegate member series (return/parameter/typed payload/struct payload/container payload) | ✅ | `UClassDelegateMemberMatrix` `UClassDelegateReturnMemberMatrix` `UClassDelegateParameterMemberMatrix` `UClassDelegateTypedPayloadMemberMatrix` `UClassDelegateStructPayloadMemberMatrix` `UClassDelegateContainerPayloadMemberMatrix` |
| Defaults and CDO matrix (including inherited `default` overrides and custom-container default-call boundary) | ✅ | `UClassDefaultValueAndCDOMatrix` |
| Access and BP visibility matrix | ✅ | `UClassAccessAndBlueprintVisibilityMatrix` |
| Non-UPROPERTY member matrix | ✅ | `UClassNonUPropertyMemberMatrix` |
| Property specifier and metadata matrix | ✅ | `UClassPropertySpecifierAndMetadataMatrix` |

---

## Summary

| File | Methods |
|------|------|
| UClass | 36 |
| UClass.Property | 18 |
| UClass.DefaultComponent | 6 |
| ClassLifecycle | 9 |
| ClassFeatures | 14 |
| **Total** | **83** |

**Pending (⬜/🟡)** (soft candidates added by the 2026-06-30 deep review, **non-blocking**; numbers use the global G IDs from `coverage-gaps.md §1`):

- `G9` 🟡 Actor-owned Tick/EndPlay/Destroyed runtime dispatch is not asserted (`ActorLifecycle`/`MultiLevelInheritanceLifecycle` declare script-side overrides but only assert BeginPlay; the Component side already uses `DispatchComponentTick` + `DestroyComponent` for real driving, while the Actor side has no equivalent coverage yet).

**Closed**:

- G8 — `UClassDefaultObjectAndInstanceStateIndependence` asserts that CDO mutation only affects later `NewObject` instances, does not retroactively modify existing instances, and that instance mutation does not write back to the CDO or pollute later instances. Verification: `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Coverage.UClass"` → `60/60`.
- G10 — `NativeOnlyVirtualOverrideBoundaries` asserts that native-only virtual methods such as `PostLoad` / `PreSave` / `PostInitProperties` / `BeginDestroy` / `FinishDestroy` / direct `Reset` fail to compile as `BlueprintOverride`; the legal `OnReset` path remains covered by UFunction/Actor lifecycle tests. Verification: `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Coverage.ClassLifecycle"` → `9/9`.

> Historical conclusion: "class-system coverage is very mature, and unsupported specifiers/combinations are hardened as 🚫 boundaries." This deep review additionally checked assertion depth: aside from the remaining soft candidate, no "false ✅ downgrade" item was found. Sampled `Surface` methods (`UClassDefaultComponentTreeAndReferenceSurface` / `UClassComponentRuntimeOperationSurface` / `UClassUObjectDefaultObjectAndMethodDispatch` / `UClassDefaultObjectAndInstanceStateIndependence` / `UClassAbstractInheritanceAndCastingRuntime` / `UClassDefaultInheritancePropertySurface`, etc.) all include runtime behavior assertions (spawn / NewObject → `VerifyByPath` readback) and satisfy the mixed standard. The `...FunctionSurface` series is intentionally a reflection-upper-boundary surface by matrix design (row label "function surface") and is not counted as a gap.
