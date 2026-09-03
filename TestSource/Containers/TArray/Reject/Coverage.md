# TArray Reject 预期覆盖

- 日期: 2026-08-26
- 范围: 仅 `TestSource/Containers/TArray/Reject`
- Bind 权威: `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_TArray.cpp`
- 约定: 上级 `../Organization.md`

CompileReject for **wrong types, string index, and unbound UE APIs**. Nested containers live in `../Negative/`. Runtime Throw lives in `../Exception/`. Float index truncation is Function (`TArrayFloatIndexTruncation`).

`@Harness CompileReject`。类型/下标各一份非法程序。未绑定 API 按家族一份：编译器会对每个调用报 `No matching signatures`（C++ `CompileAndExpectFailure` 已按条核对）。不要 Actor 壳。

## 类型 / 下标

| 文件 | 非法构造 | `@Return` 片段 |
|---|---|---|
| `TArrayVoidType.as` | `TArray<void>` | does not compile |
| `TArrayUnknownElementType.as` | `TArray<NonExistent>` | `'NonExistent' is not declared` |
| `TArrayMissingTypeArgs.as` | `TArray` 无类型实参 | `Template 'TArray' expects 1 sub type(s)` |
| `TArrayAddWrongElementType.as` | `TArray<int>.Add("hello")` | `No matching signatures to 'TArray::Add` |
| `TArrayAssignWrongElementType.as` | `TArray<int> = TArray<FString>` | 两种实例之间不能赋值 |
| `TArrayStringIndexAccess.as` | `Arr["key"]` | `No appropriate indexing operator found` |

## 未绑定 UE 别名

合法对应：`FindIndex`、`Remove`、`Sort`。不要把这些名字写进 Function 当漏测。

| 文件 | 调用 | 期望 diagnostic |
|---|---|---|
| `TArrayUnsupportedApiAliases.as` | `Find` / `FindLast` / `Reverse` / `RemoveAll` | `No matching signatures to 'TArray::Find(const int)'` 以及 FindLast / Reverse / RemoveAll 同形 |
| `TArrayUnsupportedAlgorithms.as` | `StableSort` / `FilterByPredicate` / `FindByKey` / `FindByPredicate` / `Heapify` / `HeapPop` / `HeapPush` / `LowerBound` / `UpperBound` | `No matching signatures to 'TArray::StableSort()'` 以及其余名字同形 |
