# Unreal directory for UClass material

Date: 2026-09-17. Q22 user: put UClass-related files in an Unreal directory; they are UE features. Source draft finding (Chinese original; approval R27).

## Neighbors

Admitted author roots currently include only `AngelscriptTestCode/Language` (95). There is no `Unreal/` or `Bindings/`.

Pending:

```
Pending/
├─ Language/.../UClass/          124 files
├─ World/                        124 files
├─ Bindings-不要这个目录了测试之后收集移交/  580 files
└─ Feature / Gameplay / …
```

The name `Bindings` is already rejected by that holding-directory name. The user named `Unreal` for UE features (`UCLASS` / `UFUNCTION` / `AActor` / `SpawnActor` / host `Cast<T>`).

`ObjectCastAndTypeChecks.as` is this class of fixture: spawned actors, `IsA` / `GetClass`, not core-language `cast<T>`.

## Not the Language second wave

The Language Change stays host-free: Auto / Class / Inheritance / Destructors / Typedef / Mixin.

## Chosen name

`Unreal` (user-named). Do not revive `Bindings`. `World` is absorbed into `Unreal/World/` in this Change. The 580 Bindings leftovers stay parked.
