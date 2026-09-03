# TSet UClass 预期覆盖

- 日期: 2026-08-27
- 范围: 仅 `TestSource/Containers/TSet/UClass`
- Bind 权威: `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_TSet.cpp`
- 约定: 上级 `../Organization.md`

本目录只收 **TSet 挂在 UPROPERTY / 活 Actor 引用** 的正例。不要把 Bind API 再套一层 Actor + BeginPlay。全局 `UFUNCTION` RoundTrip 在 `../Function/`。非法嵌套在 `../Negative/`。

`@Harness UClass`。NewObject 宿主用 `@Kind Observe`；`SpawnActor` 用 `@Kind WorldStory`。

## 文件

| 文件 | 形状 | Kind | 入口 |
|---|---|---|---|
| `TSetProperty.as` | UPROPERTY `TSet<int>` / `FString` / `FName` / `FVector` | Observe | `TSetTest::PropertyAddPersists` |
| `SetOfStructsContainingArrays.as` | `TSet<FSetPayload>`，payload 含 `TArray<int>`；`Hash`/`opEquals` 只认 Score | Observe | `TSetTest::StructPayloadSetPersistsInnerArrays` |
| `TSetUObjectReferences.as` | UPROPERTY `TSet<AActor>` + Spawn | WorldStory | `ATSetUObjectReferencesActor::BeginPlay` |

不在本目录：Physics / Input / Asset helper、带 EditAnywhere FVector specifier 的原 Actor oracle（错位在 `../Function/FVectorSpecifierAndSetProperties`）。
