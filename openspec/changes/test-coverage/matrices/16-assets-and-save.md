# Asset Loading / Material / Save Coverage Matrix

> **This matrix is the design specification header for asset, material, and save tests**: each row is a concrete verifiable scenario guiding the four test files. ⬜ means pending and ✅ identifies the covering `TEST_METHOD`.
>
> - Test files: `AssetLoading`(6) / `LiteralAsset`(7) / `Material`(3) / `SaveGame`(4) Tests.cpp
> - Automation prefix: `Angelscript.TestModule.Coverage.<AssetLoading|LiteralAsset|Material|SaveGame>`
> - See `../coverage-matrix.md` for the legend.

## 1. Asset Loading, AssetLoadingTests 6

| Scenario | Status | Coverage Test Method |
|------|------|------------|
| Synchronous soft object path load / synchronous soft class path load | ✅ | `SynchronousSoftObjectPathLoad` `SynchronousSoftClassPathLoad` |
| Global LoadObject | ✅ | `GlobalLoadObject` |
| Soft reference path construction and pending state | ✅ | `SoftReferencePathConstructionAndPending` |
| Soft path string identity and missing-class boundary / soft reference async boundary | ✅ | `SoftPathStringIdentityAndMissingClassBoundaries` `SoftReferenceAsyncBoundaries` |

## 2. Literal Assets, LiteralAssetTests 7

| Scenario | Status | Coverage Test Method |
|------|------|------------|
| Asset declaration basics / singleton behavior | ✅ | `AssetDeclarationBasics` `AssetSingletonBehavior` |
| Compile-time materialization / empty declaration | ✅ | `AssetCompileTimeMaterialization` `AssetEmptyDeclaration` |
| Complex initialization / incremental initialization | ✅ | `AssetComplexInitialization` `AssetIncrementalInitialization` |
| Null safety | ✅ | `AssetNullSafety` |

## 3. Materials, MaterialTests 3

| Scenario | Status | Coverage Test Method |
|------|------|------------|
| Component material slot round trip | ✅ | `ComponentMaterialSlotRoundTrip` |
| Dynamic material parameter assignment / readback | ✅ | `DynamicMaterialParametersAndAssignment` `DynamicMaterialParameterReadback` |

## 4. SaveGame, SaveGameTests 4

| Scenario | Status | Coverage Test Method |
|------|------|------------|
| SaveGame subclass and properties | ✅ | `SaveGameSubclassAndProperties` |
| Synchronous slot round trip | ✅ | `SynchronousSlotRoundTrip` |
| Missing slot returns null | ✅ | `MissingSlotReturnsNull` |
| **Nested struct / array field save -> load round trip** | ✅ | `ComplexStructAndArraySlotRoundTrip` |

---

## Summary

| File | Methods |
|------|------|
| AssetLoading | 6 |
| LiteralAsset | 7 |
| Material | 3 |
| SaveGame | 4 |
| **Total** | **20** |

**Closed on 2026-07-01**: G2 — `AngelscriptCoverageSaveGameTests.cpp::ComplexStructAndArraySlotRoundTrip` covers save -> load round-trip assertions for nested USTRUCT, `TArray<int>`, and `TArray<USTRUCT>`.
