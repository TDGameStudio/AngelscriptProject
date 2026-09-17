# One Change for TMap / TSet / TOptional type-axis and directions

Source draft: `openspec/drafts/angelscript/remaining-container-type-direction/designs/tmap-tset-optional/design.md` (Chinese original; approval R3).

Status: accepted.

## What to add

Follow the archived TArray Change: keep existing int local observes; hand-write new `.as` files; stem = `@begin` = entry; FileTag `Containers/<Type>/<Observation>`.

New direction leaves (TArray contract):

- `Read<Stem>` — `const T&in`
- `FillBy<Stem>` — `T&out`
- `Mutate<Stem>` — `T&inout`; keep a more precise verb when the old Function file already names one

Type suffixes come from each tree's old Coverage, not TArray's Float table:

| Tree | Canonical | Suffixes | Omit |
|---|---|---|---|
| TMap | `TMap<int,int>` | FString (key), FName (key), Bool (value), FVector (value), UObject (value) | float keys |
| TSet | `TSet<int>` | FString, FName, Bool, FVector, UObject | float elements |
| TOptional | `TOptional<int>` | FString, FName, Bool, FVector, UObject | float |

`EmptyConstruction` gets typed observes only, not a three-direction set.

TMap already has `ContainsKey*In` / `NumCountsPairs*In` / `IndexAccess*In`. Keep those FileTags. Add only `&out` / `&inout` and missing subjects (Add / Remove / Find / …). Do not rewrite admitted tags.

## How the Change is scheduled

Three author groups have no edges. Generate and corpus join after the authors — same shape as TArray 1.x–6.x / 7.1 / 8.1, cut by type rather than by TArray subject family.

## Out of scope

- SoftObjectPath, TObjectPtr / TSoftObjectPtr / TWeakObjectPtr / TSubclassOf
- Advance compose boxes and returned containers
- Negative / Reject
- Misplaced Physics / Input files under old TSet Function
