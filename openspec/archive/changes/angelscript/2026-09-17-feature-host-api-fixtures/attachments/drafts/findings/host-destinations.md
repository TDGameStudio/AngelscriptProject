# Where the 580 types land after the third Change

Date: 2026-09-17. Source draft: `openspec/drafts/angelscript/language-fixture-quality/findings/host-destinations.md` (Chinese original). Q32=`Containers/`; Q33=all 580; Q34=third Change; Q35=A split roots.

```
Bindings 126 type folders
├─ TArray TMap TSet TOptional TSoftObjectPtr
├─ SoftObjectPath
├─ (Pending/Containers also has TWeak TSubclass TObjectPtr)
└─ remaining ~93 folders     // FMath, FString, AActor, Json, …
```

## Sibling boundary

```
feature-language-second-wave-fixtures    Language/ six themes
feature-unreal-fixture-root              Unreal/ UClass 124 + World 124
feature-host-api-fixtures                Bindings 580 + Pending/Containers 240
```

The Unreal Change handoff still parks the 580 leftovers. This Change later writes more FileTags under the same `Unreal/` root. Colliding themes merge; they must not become two FString inventories.

| Unreal first-batch theme | Bindings folders that may collide |
|---|---|
| Unreal/Strings | FString / FText / FName |
| Unreal/Input | InputEvents / UInputMappingContext / FInput* |
| Unreal/World/Actor | AActor / UWorld |
| Unreal/Casting | Bindings has almost no language `cast<T>` |

## Accepted landing (Q35=A)

Same Change, two roots: `Containers/` for T* + SoftObjectPath + Pending/Containers; remaining 93 folders become `Unreal/<Type>`. `Pending/Math` 111 merges into math pockets. Options B (everything under Containers), C (new Library/), and D (T* only) were not selected.
