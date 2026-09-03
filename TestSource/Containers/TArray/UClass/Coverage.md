# TArray UClass 预期覆盖

- 日期: 2026-08-26
- 范围: 仅 `TestSource/Containers/TArray/UClass`
- Bind 权威: `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_TArray.cpp`
- 约定: 上级 `../Organization.md`

本目录只收 **TArray 挂在 UPROPERTY / 活 Actor 引用** 的正例。不要把 Bind API 再套一层 Actor + BeginPlay。全局 `UFUNCTION` RoundTrip 在 `../Function/`。非法嵌套在 `../Negative/`。

`@Harness UClass`。NewObject 宿主用 `@Kind Observe`；`SpawnActor` 用 `@Kind WorldStory`。

## 文件

| 文件 | 形状 | Kind | 入口 |
|---|---|---|---|
| `TArrayProperty.as` | UPROPERTY `TArray<int>` / `FString` / `FName` / `FVector` | Observe | `TArrayTest::PropertyAddPersists` |
| `ArrayOfStructsContainingArrays.as` | `TArray<FArrayPayload>`，payload 含 `TArray<int>` | Observe | `TArrayTest::StructPayloadArrayPersistsIndependentInners` |
| `TArrayUObjectReferences.as` | UPROPERTY `TArray<AActor>` + Spawn | WorldStory | `ATArrayUObjectReferencesActor::BeginPlay` |

不在本目录：GameState/PlayerState 表面、FRotator/FTransform 成员 UFUNCTION store、FName/FString/FVector 的 API Actor 壳。
