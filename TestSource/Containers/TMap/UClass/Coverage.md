# TMap UClass 预期覆盖

- 日期: 2026-08-26
- 范围: 仅 `TestSource/Containers/TMap/UClass`
- Bind 权威: `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_TMap.cpp`
- 约定: 上级 `../Organization.md`

本目录只收 **TMap 挂在 UPROPERTY / 活 Actor 引用** 的正例。不要把 Bind API 再套一层 Actor + BeginPlay。全局 `UFUNCTION` RoundTrip 在 `../Function/`。非法嵌套在 `../Negative/`。

`@Harness UClass`。NewObject 宿主用 `@Kind Observe`；`SpawnActor` 用 `@Kind WorldStory`。

## 文件

| 文件 | 形状 | Kind | 入口 |
|---|---|---|---|
| `TMapProperty.as` | UPROPERTY `TMap<int,int>` / `FString` / `FName` / `FVector` / `FString->FName` | Observe | `TMapTest::PropertyAddPersists` |
| `MapOfStructsContainingArrays.as` | `TMap<int, FMapPayload>`，payload 含 `TArray<int>` | Observe | `TMapTest::StructPayloadMapPersistsIndependentInners` |
| `TMapUObjectReferences.as` | UPROPERTY `TMap<int, AActor>` + Spawn | WorldStory | `ATMapUObjectReferencesActor::BeginPlay` |

不在本目录：Enhanced Input / Log helper、FName/FString 的 API Actor 壳。
