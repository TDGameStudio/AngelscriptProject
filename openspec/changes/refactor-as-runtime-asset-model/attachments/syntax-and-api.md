# Dynamic Asset syntax and generated API contract

## 1. Public grammar

```text
asset-declaration := "asset" identifier "of" primary-asset-type asset-body
asset-body        := "{" asset-statement* "}"
asset-statement   := asset-path-assignment | bundle-mutation
```

There is no `UASSET` specifier. `primary-asset-type` is an identifier converted to `FPrimaryAssetType`; it is not resolved as a UClass. If it does resolve to a UClass in the legacy shape, the migration diagnostic wins instead of silently using the class name as an opaque Type.

The declaration may appear at module top level or in a namespace. `PrimaryAssetType:Name` is global AssetManager identity, so namespace/module do not alter the ID.

## 2. Canonical source

```angelscript
namespace Catalog
{
    asset WeaponCatalog of GameplayCatalog
    {
        AssetPath = FSoftObjectPath("/Game/Data/DA_WeaponCatalog.DA_WeaponCatalog");
        Bundles.AddBundleAsset(
            n"Client",
            FTopLevelAssetPath("/Game/Weapons/SK_Rifle.SK_Rifle"));
        Bundles.AddBundleAsset(
            n"Server",
            FTopLevelAssetPath("/Game/Data/DT_WeaponStats.DT_WeaponStats"));
    }
}
```

Normalized ID: `GameplayCatalog:WeaponCatalog`.

## 3. Builder allowlist

V1 accepts only expressions that can be reduced to descriptor data without running general AngelScript:

- zero or one assignment to `AssetPath` using a compile-time `FSoftObjectPath` value;
- `Bundles.AddBundleAsset(FName, FTopLevelAssetPath)`;
- `Bundles.AddBundleAssets(FName, const TArray<FTopLevelAssetPath>&)` when the array literal/content is compile-time known;
- `Bundles.SetBundleAssets(FName, const TArray<FTopLevelAssetPath>&)` with compile-time-known content;
- optional `Bundles.Reset()` only as deterministic local builder mutation, subject to final non-empty validation.

No other receiver, field, call, local mutable variable, loop, branch, return, UObject reference, global read or load operation is legal. The parser should represent allowed statements directly as descriptor operations instead of executing a hidden builder function.

## 4. Validation and normalization

Process in source order, then normalize:

1. validate non-None PrimaryAssetType and Name and construct a valid `FPrimaryAssetId`;
2. validate AssetPath is null or a canonical asset path;
3. reject `NAME_None` Bundle names;
4. validate every path as a non-null top-level asset path;
5. merge duplicate Bundle names;
6. sort Bundle entries by normalized `FName` value;
7. sort and deduplicate paths in each Bundle;
8. remove no-op empty entries;
9. require at least one path across all Bundles;
10. hash ID + AssetPath + normalized Bundle names/paths into a stable fingerprint.

The normalized descriptor, not source statement order, drives reload and cross-Engine conflict detection.

## 5. Generated namespace surface

For the example above:

```angelscript
FPrimaryAssetId Catalog::WeaponCatalog::GetId();

void Catalog::WeaponCatalog::LoadAsync(
    int32 Priority = 0,
    UObject OptionalCallbackObject = nullptr,
    FName OptionalFinishedCallbackFunctionName = NAME_None,
    FName OptionalCanceledCallbackFunctionName = NAME_None);

void Catalog::WeaponCatalog::LoadAsync(
    const TArray<FName>& LoadBundles,
    int32 Priority = 0,
    UObject OptionalCallbackObject = nullptr,
    FName OptionalFinishedCallbackFunctionName = NAME_None,
    FName OptionalCanceledCallbackFunctionName = NAME_None);

int Catalog::WeaponCatalog::Unload();
```

Generated hidden names include module/namespace/declaration hash so separate source owners with the same PrimaryAssetId do not collide at the script symbol layer.

## 6. Call semantics

| API | If Unmaterialized | If Materialized | Loads resources? | Removes record? |
| --- | --- | --- | --- | --- |
| `GetId()` | EnsureMaterialized, then return ID | return ID | no | no |
| `LoadAsync(...)` | EnsureMaterialized, then request load | request load | asynchronously | no |
| `Unload()` | return 0, no backend call | `UnloadPrimaryAsset(ID)` | releases AssetManager load state | no |
| module/Engine owner release | no AssetManager call | decrement owner; last owner unload+remove | may release load state | only on last owner |

The no-Bundle-array LoadAsync overload builds a stable list of all normalized declared Bundle names. It does not mean “load base AssetPath synchronously.” The subset overload forwards the requested array through the same existing adapter; UE determines the result of names with no matching entry.

## 7. Preferred usage

Most callers load directly:

```angelscript
WeaponCatalog::LoadAsync(
    0,
    this,
    n"OnWeaponCatalogLoaded",
    n"OnWeaponCatalogCanceled");
```

Subset load:

```angelscript
TArray<FName> Bundles = { n"Client" };
WeaponCatalog::LoadAsync(Bundles);
```

GetId is for interoperability, not a required preflight:

```angelscript
FPrimaryAssetId CatalogId = WeaponCatalog::GetId();
Log(f"Register-only ID: {CatalogId}");
```

Release load state while keeping the logical record:

```angelscript
int ReleasedHandles = WeaponCatalog::Unload();
```

## 8. Descriptor data

```text
FAngelscriptDynamicAssetDesc
  SourceFile / SourceLine / SourceColumn
  ModuleStableId / Namespace / DeclarationName
  SourceOwnerId
  PrimaryAssetId
  Optional AssetPath
  Normalized Bundle entries
  Normalized Bundle-name list for default LoadAsync
  DescriptorFingerprint
  Generated GetId/LoadAsync/Unload entries
```

The source owner is not backend identity. Multiple owners may share one PrimaryAssetId only when fingerprints match.

## 9. Diagnostic catalogue

| Code | Condition | Required guidance |
| --- | --- | --- |
| `AS-ASSET-001` | malformed declaration/body | show canonical Dynamic Asset syntax |
| `AS-ASSET-002` | invalid PrimaryAssetId | identify Type and Name |
| `AS-ASSET-003` | disallowed builder statement | list allowed AssetPath/Bundle operations |
| `AS-ASSET-004` | invalid path | print field/Bundle and offending path |
| `AS-ASSET-005` | empty/None Bundle | require at least one named Bundle path |
| `AS-ASSET-006` | disk-scanned Type | choose a dedicated Dynamic Asset Type |
| `AS-ASSET-007` | ID fingerprint/owner conflict | show both source owners and fingerprints |
| `AS-ASSET-008` | backend unavailable/AddDynamicAsset failed | keep unmaterialized and allow retry |
| `AS-ASSET-009` | former UObject literal | show full `USINGLETON` + `singleton` + `Init` migration |
| `AS-ASSET-010` | related reload rejected during PIE | stop PIE or wait for queued full reload |

## 10. Legacy migration example

Former source:

```angelscript
asset DefaultConfig of UGameConfig
{
    Profile = n"Default";
}
```

Required migration:

```angelscript
USINGLETON(Global)
singleton DefaultConfig of UGameConfig
{
    Init
    {
        Profile = n"Default";
    }
}

UGameConfig Config = DefaultConfig::Get();
```
