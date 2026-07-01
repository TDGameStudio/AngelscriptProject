# USTRUCT Coverage Matrix

> **This matrix is the design specification ("header") for USTRUCT tests**: each row is a concrete verifiable scenario used to guide implementation in `AngelscriptCoverageUStructTests.cpp` / `AngelscriptCoverageUStructMemberTests.cpp`.
> Rows marked ⬜ are pending tests; ✅ rows identify the covering `TEST_METHOD`.
>
> - Test files: `AngelscriptCoverageUStructTests.cpp` (43 methods), `AngelscriptCoverageUStructMemberTests.cpp` (4 methods)
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
| `HasNativeMake` / `HasNativeBreak` specifiers | ⬜? | — | Pending (G15): UE UHT uses these specifiers to point to native custom Make/Break node bindings; grep finds no `HasNativeMake/HasNativeBreak` parser path in this fork; current `UStructUnsupportedSpecifiers` only covers `Atomic`/`Immutable`/`NoExport`. Add one compile-failure probe row (expected `Unknown class specifier`) and classify it as a 🚫 boundary |

## 3. Members and Defaults

| Scenario | Status | Covering Test Method | Notes / Pending Work |
|------|------|------------|-------------|
| Member declaration and access | ✅ | `UStructMembers` / `UStructMember*` (member file) | Basic member read/write |
| Extended member type matrix | ✅ | `UStructExtendedMemberTypeMatrix` | UE types as members, including TWeakObjectPtr / TSoftObjectPtr / TSoftClassPtr / TSubclassOf / FText / math structs / UObject references |
| Enum / FText / property-flag members | ✅ | `UStructEnumTextAndPropertyFlags` | enum/FText members |
| Default-value type matrix | ✅ | `UStructDefaultValueTypeMatrix` | Reflected defaults for each type |
| Nested struct default-value reflection | ✅ | `UStructNestedDefaultsReflection` | Nested defaults (3 levels: Outer→Branch→Leaf) |
| `FInstancedStruct` as a USTRUCT member / UPROPERTY | ⬜ | — | Pending (G11): the fork already binds `FInstancedStruct` (see `Bind_FInstancedStruct.cpp` and `AngelscriptInstancedStructBindingsTests.cpp` `DefaultConstruction`/`ResetClears`), but the Coverage domain does not cover it yet. Add coverage for UPROPERTY reflection, `InitializeAs<FFoo>` / `Get<FFoo>()` round trip, function parameter/return shapes, and TArray elements |

## 4. Value Semantics, Operators, and Member Methods

| Scenario | Status | Covering Test Method | Notes / Pending Work |
|------|------|------------|-------------|
| Value semantics (copy/assignment independence) | 🟡 | `UStructValueSemantics` | Value-type copy isolation (G12): currently only asserts copy/assignment independence for int + FString members; deep-copy independence for TArray/TMap/TSet members (mutating the copied container does not affect the source container) is not asserted yet |
| Operator overloads (`==`, `!=`, etc.) | 🟡 | `UStructOperators` | Currently covers `opEquals` / `opAdd` / `opAssign` / `opCmp` / `opIndex` (G13): missing runtime assertions for `opSub` / `opMul` / `opDiv` / `opNeg` and compound assignments `opAddAssign` / `opSubAssign` / `opMulAssign` / `opDivAssign` |
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
| `FInstancedPropertyBag` / `FPropertyBag` | ⬜? | — | (G14): no PropertyBag binding was found in this fork (no `Bind_FPropertyBag*`); likely a 🚫 boundary but not yet proven with a compile-failure probe. First test one line such as `FInstancedPropertyBag Foo;`, then decide whether it is a 🚫 boundary or a ⬜ candidate |
| USTRUCT custom `Serialize(FArchive&)` entry point | ⬜? | — | Pending/boundary (G16): UE C++ can customize USTRUCT binary serialization via `Serialize(FArchive&)` overloads or the `WithSerializer` Cpp struct trait; grep finds no AS exposure for `FArchive` or a `Serialize` hook binding. Expected 🚫 boundary (AS struct should rely on default reflection serialization), requiring a one-line `void Serialize(FArchive& Ar)` compile-failure probe |
| USTRUCT `NetSerialize` / replication serialization entry point | ⬜? | — | Pending/boundary (G17): UE implements compressed struct network serialization via `NetSerialize(FArchive&,UPackageMap*,bool&)` + `WithNetSerializer`; grep finds no `NetSerialize` binding. AS structs can only rely on default field-by-field replication (already covered through UPROPERTY reflection), and scripts cannot override `NetSerialize`. Expected 🚫 boundary, requiring the corresponding compile-failure probe |
| AS USTRUCT static member (`static int Foo`) | ⬜? | — | Pending/boundary (G18): the AS language layer does not support class/struct static fields (already recorded in the delegate domain as a `BindStatic` boundary in `coverage-gaps.md §2.4`). The USTRUCT domain lacks the matching compile-failure row; add a one-line `static int Foo` USTRUCT-member compile-failure probe and harden it as a 🚫 boundary |

---

## Summary

| Dimension | Covered Scenarios | Status |
|------|----------|------|
| 1 Declaration and reflection | 5 | ✅ |
| 2 Specifiers and metadata | 6 ✅ (including 1 boundary) + 1 proof candidate (G15) | 🟡 |
| 3 Members and defaults | 5 + 1 ⬜ (G11) | 🟡 |
| 4 Value semantics/operators/methods | 1 ✅ + 2 🟡 (G12/G13) | 🟡 |
| 5 Parameters/return values | 6 | ✅ |
| 6 Delegate interaction | 4 | ✅ |
| 7 Container interaction | 12 | ✅ |
| 8 Nesting | 2 | ✅ |
| 9 Boundaries | 3 🚫 + 4 proof candidates (G14/G16/G17/G18) | — |

**Corresponding test methods**: `UStructTests.cpp` 43 + `UStructMemberTests.cpp` 4 = 47 methods.

**Pending (⬜ / 🟡)**:
- `G11` ⬜ `FInstancedStruct` as USTRUCT member / UPROPERTY reflection + `InitializeAs<FFoo>` / `Get<FFoo>()` round trip + container/parameter shapes. The fork already binds it (`Bind_FInstancedStruct.cpp`), but the Coverage domain does not cover it.
- `G12` 🟡 Strengthen value-semantics deep-copy independence: current `UStructValueSemantics` only covers int+FString members; extend it to TArray/TMap/TSet members where mutating the copied container does not affect the source.
- `G13` 🟡 Complete operator-overload coverage: current `UStructOperators` covers `opEquals`/`opAdd`/`opAssign`/`opCmp`/`opIndex`; add runtime assertions for `opSub`/`opMul`/`opDiv`/`opNeg` + compound assignments `opAddAssign`/`opSubAssign`/`opMulAssign`/`opDivAssign`.
- `G14` 🚫? Proof candidate: is `FInstancedPropertyBag` / `FPropertyBag` bound in this fork? Run a one-line compile-failure probe first, then classify it as a 🚫 boundary or ⬜ candidate.
- `G15` 🚫? Proof candidate: USTRUCT specifiers `HasNativeMake` / `HasNativeBreak`; the fork has no parser path. Harden as a 🚫 boundary with a one-line compile-failure probe.
- `G16` 🚫? Proof candidate: USTRUCT custom `Serialize(FArchive&)` entry point; the fork has no AS binding for `FArchive`. Harden as a 🚫 boundary with a one-line compile-failure probe.
- `G17` 🚫? Proof candidate: USTRUCT `NetSerialize` replication-serialization overload; the fork has no `NetSerialize` binding. Harden as a 🚫 boundary with a one-line compile-failure probe.
- `G18` 🚫? Proof candidate: USTRUCT static member `static int Foo;`; AS language does not support this. Harden as a 🚫 boundary with a one-line compile-failure probe.

> Historical conclusion "USTRUCT is one of the most mature coverage domains" still holds: all 47 methods contain real behavior/reflection assertions at assertion depth, with no broad "false ✅" area. Of the 8 NEW items added by this review, G11~G13 are **capability-surface enhancements** (non-blocking), while G14~G18 are **boundary proof candidates** (each only needs one compile-failure test row to harden as a 🚫 boundary).
