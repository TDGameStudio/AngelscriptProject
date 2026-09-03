# TArray Exception 预期覆盖

- 日期: 2026-08-26
- 范围: 仅 `TestSource/Containers/TArray/Exception`
- Bind 权威: `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_TArray.cpp`
- 约定: 上级 `../Organization.md`；合法路径仍在 `../Function/`

本目录只收 **能编译、调用后 Throw** 的全局 `UFUNCTION`。`@Harness RuntimeException`，每个入口 `@Kind RuntimeException`。不要混 Observe / RoundTrip。不要放进 `../Negative/`（那边是编不过的嵌套容器）。

Runner 应对 `ExecuteAndExpectException` 与 `@Return` 里的英文原文。这不是进程崩溃。

---

## 1. 约定

- 一文件一个抛错家族（同一文案或同一 API）。
- 同一模块可以有多个入口：分别调用，编译器不会在第一错停。
- 默认 `int`，不套 Function 的类型后缀四件套。
- `@Tag` = `Containers.TArray.<FileStem>`。
- 合法下标、`IsValidIndex` 返回 false、`FindIndex` 返回 -1 仍在 Function。

**暂不写：** foreach 中途改数组（`AS_ITERATOR_DEBUGGING`）、Sort 元素不可比。

---

## 2. 文件与文案

| 文件 | `@Covers` | 期望异常原文 |
|---|---|---|
| `TArrayIndexOutOfBounds` | `TArray.opIndex` | `Array index out of bounds.` |
| `TArrayLastOutOfBounds` | `TArray.Last` | `Array index out of bounds.` |
| `TArraySwapOutOfBounds` | `TArray.Swap` | `Array index out of bounds.` |
| `TArrayRemoveAtOutOfBounds` | `TArray.RemoveAt` / `RemoveAtSwap` | `Array index out of bounds.` |
| `TArrayInsertOutOfBounds` | `TArray.Insert` | `Array index out of bounds. Need to insert between 0 and ArraySize` |
| `TArrayCopyExceptions` | `TArray.Copy` | `Cannot copy an array into itself.` / `Count should not be negative.` / `Source array out of bounds.` / `Target array out of bounds.` |
| `TArrayMoveAssignSelf` | `TArray.MoveAssignFrom` | `Cannot move assign an array into itself.` |
| `TArraySetNumInvalid` | `TArray.SetNum` / `SetNumZeroed` | `Invalid negative Num` / `SetNumZeroed is not valid for arrays of non-primitive types.` |
| `TArrayAliasAddInsert` | `TArray.Add` / `TArray.Insert` | `Cannot Add an element from the same array by reference. Copy it to a temporary first.` / Insert 对应句 |
| `TArrayIteratorOutOfBounds` | `TArray.Iterator` | `Iterator out of bounds.` |

字符串下标拒绝在 `../Reject/TArrayStringIndexAccess`。嵌套容器在 `../Negative/`。
