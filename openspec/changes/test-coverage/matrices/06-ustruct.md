# USTRUCT Coverage Matrix

> **This matrix is the design specification ("header") for USTRUCT tests**: each row is a concrete verifiable scenario used to guide implementation in `AngelscriptCoverageUStructTests.cpp` / `AngelscriptCoverageUStructMemberTests.cpp`.
> Rows marked ⬜ are pending tests; ✅ rows identify the covering `TEST_METHOD`.
>
> - Test files: `AngelscriptCoverageUStructTests.cpp` (47 methods), `AngelscriptCoverageUStructMemberTests.cpp` (4 methods)
> - Automation prefixes: `Angelscript.TestModule.Coverage.UStruct`, `...UStructMember`
> - Legend: ✅ covered / 🟡 partially covered / ⬜ pending / 🚫 fork-unsupported boundary. See `../coverage-matrix.md` for the full legend.

## 1. Declaration and Reflection

| Scenario | Status | Covering Test Method | Notes / Pending Work |
|------|------|------------|-------------|
| Basic USTRUCT declaration + reflection registration | ✅ | `UStructBasicDeclaration` | Type registration and visible fields |
| Declaration / construction edge combinations | ✅ | `UStructDeclarationAndConstructionEdgeMatrix` | Default construction and aggregate-initialization boundaries |
| Namespaced declaration and reflection | ✅ | `UStructNamespacedDeclarationAndReflection` | Reflected struct names under `namespace` |
| Type identity is consistent across reflection sites | ✅ | `UStructTypeIdentityAcrossReflectionSites` | Same type at parameter/return/member sites |
| BlueprintGeneratedClass association boundary | ✅ | `UStructBlueprintGeneratedClassBoundary` | Interaction boundary with BP-generated classes |

## 2. Specifiers and Metadata

| Scenario | Status | Covering Test Method | Notes / Pending Work |
|------|------|------------|-------------|
| Supported USTRUCT specifiers | ✅ | `UStructSpecifiers` | BlueprintType / Atomic, etc. |
| Unsupported USTRUCT specifiers (boundary) | 🚫 | `UStructUnsupportedSpecifiers` | Records rejected specifiers |
| Property specifier flag matrix | ✅ | `UStructPropertySpecifierFlagMatrix` | EditAnywhere/BlueprintReadWrite/SaveGame and related flags |
| Optional + specifier combinations | ✅ | `UStructOptionalAndSpecifierCombinations` | Combination rules |
| Metadata aliases and deprecation | ✅ | `UStructMetadataAliasAndDeprecationMatrix` | meta alias / deprecated |
| Advanced metadata | ✅ | `UStructAdvancedMetadata` | Custom meta-key round trip |
| `HasNativeMake` / `HasNativeBreak` specifiers | 🚫 | `UStructUnsupportedBoundaryInventory` | Current fork has no parser path for native Make/Break specifiers |

## 3. Members and Defaults

| Scenario | Status | Covering Test Method | Notes / Pending Work |
|------|------|------------|-------------|
| Member declaration and access | ✅ | `UStructMembers` / `UStructMember*` (member file) | Basic member read/write |
| Extended member type matrix | ✅ | `UStructExtendedMemberTypeMatrix` | UE types as members, including TWeakObjectPtr / TSoftObjectPtr / TSoftClassPtr / TSubclassOf / FText / math structs / UObject references |
| Enum / FText / property-flag members | ✅ | `UStructEnumTextAndPropertyFlags` | enum/FText members |
| Default-value type matrix | ✅ | `UStructDefaultValueTypeMatrix` | Reflected defaults for each type |
| Nested struct default-value reflection | ✅ | `UStructNestedDefaultsReflection` | Nested defaults (3 levels: Outer→Branch→Leaf) |
| `FInstancedStruct` as a USTRUCT member / UPROPERTY | ✅ | `FInstancedStructCoverageSemantics` | UPROPERTY reflection, TArray shape, reset behavior, and parameter/return declaration shape; AS-struct initialization remains a known separate hazard |

## 4. Value Semantics, Operators, and Member Methods

| Scenario | Status | Covering Test Method | Notes / Pending Work |
|------|------|------------|-------------|
| Value semantics (copy/assignment independence) | ✅ | `UStructValueSemantics` `UStructNestedContainerCopySemantics` | Scalar and nested TArray/TMap/TSet copy independence |
| Operator overloads (`==`, `!=`, etc.) | ✅ | `UStructOperators` `UStructOperatorExpansion` | Existing and expanded arithmetic/unary/compound assignment operator coverage |
| Member method invocation matrix | ✅ | `UStructMemberMethodInvocationMatrix` | Runtime assertions for const / non-const / struct-returning / `CopyFrom(const&in)` shapes |

## 5. Parameters and Return Values

| Scenario | Status | Covering Test Method | Notes / Pending Work |
|------|------|------------|-------------|
| struct as script function parameter | ✅ | `UStructAsParameter` | value/in/out/inout |
| struct as script function return value | ✅ | `UStructAsReturn` | Return round trip |
| struct as UFUNCTION parameter call | ✅ | `UStructUFunctionParameterInvocation` | Reflected input call |
| struct as UFUNCTION return call | ✅ | `UStructUFunctionReturnInvocation` | Reflected return call |
| Function-shape matrix (parameter × return combinations) | ✅ | `UStructFunctionShapeMatrix` | Shape permutations |
| Optional return matrix | ✅ | `UStructOptionalReturnMatrix` | optional returns |

## 6. Delegate Interaction

| Scenario | Status | Covering Test Method | Notes / Pending Work |
|------|------|------------|-------------|
| struct as delegate parameter round trip | ✅ | `UStructDelegateParameterRoundTrip` | Delegate broadcasts struct |
| struct container as delegate parameter round trip | ✅ | `UStructDelegateContainerRoundTrip` | TArray<struct> delegate |
| Extended Map delegate permutation matrix | ✅ | `UStructExtendedMapDelegatePermutationMatrix` | Delegates with TMap values containing struct |
| Map key/value delegate permutation matrix | ✅ | `UStructMapKeyValueDelegatePermutationMatrix` | Key/value struct delegate permutations |

## 7. Container Interaction

| Scenario | Status | Covering Test Method | Notes / Pending Work |
|------|------|------------|-------------|
| struct in containers (TArray/TMap/TSet elements) | ✅ | `UStructInContainers` | As element |
| struct as hashable Map key / Set element | ✅ | `UStructHashableMapKeyAndSetElement` | GetTypeHash path |
| Empty container shape matrix | ✅ | `UStructEmptyContainerShapeMatrix` | Empty-container boundary |
| Containers as parameter shape matrix | ✅ | `UStructContainerParameterShapeMatrix` | Container input permutations |
| Containers as member shape matrix | ✅ | `UStructContainerMemberShapeMatrix` | Container member permutations |
| Extended Map member permutation matrix | ✅ | `UStructExtendedMapMemberPermutationMatrix` | TMap member permutations |
| Reflected container parameter invocation | ✅ | `UStructReflectedContainerParameterInvocation` | Reflected call with container input |
| Key-container parameter and return matrix | ✅ | `UStructKeyContainerParameterAndReturnMatrix` | Key-container shapes |
| struct→struct Map parameter and return | ✅ | `UStructStructToStructMapParameterAndReturnMatrix` | TMap<struct,struct> |
| Map key/value shape matrix | ✅ | `UStructMapKeyValueShapeMatrix` | Key/value type permutations |
| Map key/value parameter and return matrix | ✅ | `UStructMapKeyValueParameterAndReturnMatrix` | Key/value parameters/returns |
| Primitive Map key/value parameter and return | ✅ | `UStructMapPrimitiveKeyValueParameterAndReturnMatrix` | Primitive key/value types |

## 8. Nesting

| Scenario | Status | Covering Test Method | Notes / Pending Work |
|------|------|------------|-------------|
| Nested struct (struct containing struct member) | ✅ | `UStructNested` | Multi-level nested read/write |
| struct containing array, then used as an outer array element | ✅ | `UStructInContainers` / `UStructNested` | See `../coverage-gaps.md §2.2` (allowed shape) |

## 9. Boundaries — fork unsupported / not applicable

| Scenario | Status | Covering Test Method | Notes |
|------|------|------------|------|
| Unsupported combinations (nested containers, etc.) | 🚫 | `UStructUnsupportedCombinationBoundaries` | Compile diagnostics assert the boundary; see `../coverage-gaps.md §2.2` |
| Unsupported USTRUCT specifiers (`Atomic` / `Immutable` / `NoExport`) | 🚫 | `UStructUnsupportedSpecifiers` | Compile diagnostics assert the boundary (`Unknown class specifier ...`) |
| `TMap<FStruct,V>` / `TSet<FStruct>` without `Hash`+`opEquals` | 🚫 | `UStructUnsupportedCombinationBoundaries` | Compile diagnostic: `Key type does not have a hash function defined` |
| `FInstancedPropertyBag` / `FPropertyBag` | 🚫 | `UStructUnsupportedBoundaryInventory` | Current fork has no PropertyBag binding |
| USTRUCT custom `Serialize(FArchive&)` entry point | 🚫 | `UStructUnsupportedBoundaryInventory` | AS structs use reflection serialization; `FArchive` hooks are not exposed |
| USTRUCT `NetSerialize` / replication serialization entry point | 🚫 | `UStructUnsupportedBoundaryInventory` | AS structs use field-level replication; `NetSerialize` is not exposed |
| AS USTRUCT static member (`static int Foo`) | 🚫 | `UStructUnsupportedBoundaryInventory` | Static fields remain unsupported in the AS language layer |

---

## Summary

| Dimension | Covered Scenarios | Status |
|------|----------|------|
| 1 Declaration and reflection | 5 | ✅ |
| 2 Specifiers and metadata | 7 ✅/🚫 | ✅ |
| 3 Members and defaults | 6 ✅ | ✅ |
| 4 Value semantics/operators/methods | 3 ✅ | ✅ |
| 5 Parameters/return values | 6 | ✅ |
| 6 Delegate interaction | 4 | ✅ |
| 7 Container interaction | 12 | ✅ |
| 8 Nesting | 2 | ✅ |
| 9 Boundaries | 8 🚫 | ✅ |

**Corresponding test methods**: `UStructTests.cpp` 47 + `UStructMemberTests.cpp` 4 = 51 methods.

**Implementation status**: G11-G13 have semantic Coverage methods; G14-G18 have explicit 🚫 boundary probes in `UStructUnsupportedBoundaryInventory`. The complete USTRUCT prefix passed 51/51 on 2026-08-01.

> Historical conclusion "USTRUCT is one of the most mature coverage domains" still holds: the 51 methods now include semantic expansion and explicit boundary probes, with no broad "false ✅" area. The focused validation passed 51/51 on 2026-08-01.
