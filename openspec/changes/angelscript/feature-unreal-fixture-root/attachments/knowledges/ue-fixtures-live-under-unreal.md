# UE fixtures live under Unreal, not Language

Disposition: candidate.

## Reusable Insight

`UCLASS`, `UFUNCTION`, spawned actors, and World stories are UE-feature fixtures. Their FileTag prefix is `Unreal/`. Core-language `cast<T>` and host-free class syntax stay under `Language/`. The directory name `Bindings` is not reused.

## Evidence

`ObjectCastAndTypeChecks.as` uses `UCLASS` and `SpawnActor`. First-wave Language design excluded UClass and FString observers. Q22 named Unreal.

## Boundaries

Does not admit the 580 Bindings leftovers, compile World programs, or move host-free Auto/Class/Mixin into Unreal.

## Application

Use when routing a Pending Language/UClass or World file and when teaching the test Skill.

## Sources

[Design](../drafts/design.md), [unreal-home](../drafts/findings/unreal-home.md).
