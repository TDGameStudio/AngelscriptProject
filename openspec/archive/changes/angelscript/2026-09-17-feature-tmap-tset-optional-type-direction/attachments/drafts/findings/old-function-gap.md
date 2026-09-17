# Remaining containers versus TestSource-old Function

Compared 2026-09-17. Workspace `git_3b46972bbc7ef05a4244fd2890d18183`. TArray L2/L3 already landed in archived Change `angelscript/2026-09-17-feature-tarray-type-and-direction-coverage`. This page covers the other eight trees.

Source draft: `openspec/drafts/angelscript/remaining-container-type-direction/findings/old-function-gap.md`.

## Old Function contract (L2 / L3)

`TestSource-old/Containers/<Type>/Function/Coverage.md` matches TArray for parameterized containers:

- L2: every Function Subject except empty construction has `const&in` / `&out` / `&inout`
- L3: the same Subject carries type suffixes; old files packed many UFUNCTIONs, current authors are one observation per file

| Type | Old Function `.as` | Old UFUNCTION | Old `&in` / `&out` / `&inout` | Current observes | Current directions | Current type suffixes |
|---|---:|---:|---|---:|---|---|
| TMap | 12 | 297 | 186 / 258 / 132 | 70 | `*In` (`&in`) only | Contains / Num / Index have FString, FName, Bool, FVector, UObject |
| TSet | 9 real Subjects + 10 misplaced files | 225 (includes misplaced) | 132 / 186 / 96 | 28 | none | `EmptyConstructionFName` only |
| TOptional | 7 | 184 | 102 / 143 / 72 | 16 | none | none |
| SoftObjectPath | 0 | 0 | no old Function pile | 18 | none | not an element-parameterized type |
| TObjectPtr | 2 | 17 | 6 / 8 / 4 | 21 | Assign three directions already present | L3 pins UObject |
| TSoftObjectPtr | 5 | 41 | 15 / 20 / 10 | 21 | none | L3 pins UObject |
| TWeakObjectPtr | 3 | 22 | 9 / 12 / 6 | 23 | none (`ReadAssignedTarget` is a local Get) | L3 pins UObject |
| TSubclassOf | 3 | 26 | 9 / 12 / 6 | 24 | none (`ReadAssignedClass` is a local Get) | L3 pins UObject |

Physics / Input / Asset files under old TSet Function are marked misplaced in that Coverage. Do not port them.

## Current holes

TMap is a half layer: `ContainsKey` / `NumCountsPairs` / `IndexAccess` have typed leaves and `*In`, but the tree has no `&out` / `&inout`. `AddPairInsertsKeyValue` is still one local `TMap<FName,int32>` and does not match old `TMapAdd.as` (int canonical + five types + three directions).

TSet and TOptional match pre-archive TArray: local int observes exist; Function directions and the type axis are almost absent.

Pointer-wrapper L3 is target-class shape (UObject canonical; AActor stays on UClass), not Float/Bool. TObjectPtr Assign already has real `ReadAssignedTarget` / `FillWithNewObject` / `ReplaceTarget`. TWeak / TSubclass `Read*` file names are local Gets, not `const&in`.

SoftObjectPath has no old Function pile. Do not invent a TArray-style element-type axis.

## Not this wave

- `Advance/` compose, sidecars, returned containers
- `Negative/` nested containers
- `Reject/` aliases
- `Exception/` (current RuntimeFail already exists)
- Misplaced TSet Function files
- Renaming admitted TMap `*In` to `Read*` (unauthorized churn)

## Scale (rough, one observation per file)

Remaining TMap work, TSet, and TOptional are each about one to two hundred new hand-written `.as` files. Pointer wrappers are an order of magnitude smaller and use a different L3 contract.
