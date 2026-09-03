# TSet Exception 预期覆盖

- 日期: 2026-08-27
- 范围: 仅 `TestSource/Containers/TSet/Exception`
- Bind 权威: `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_TSet.cpp`
- 约定: 上级 `../Organization.md`；合法路径仍在 `../Function/`

本目录只收 **能编译、调用后 Throw** 的全局 `UFUNCTION`。`@Harness RuntimeException`，每个入口 `@Kind RuntimeException`。不要混 Observe / RoundTrip。不要放进 `../Negative/`（那边是编不过的嵌套容器）。

Runner 应对 `ExecuteAndExpectException` 与 `@Return` 里的英文原文。这不是进程崩溃。

---

## 1. 约定

- 一文件一个抛错家族（同一文案或同一 API）。
- 同一模块可以有多个入口：分别调用，编译器不会在第一错停。
- 默认 `int`，不套 Function 的类型后缀四件套。
- `@Tag` = `Containers.TSet.<FileStem>`。
- `Contains` 返回 false、`Remove` 返回 false 仍在 Function。TSet 没有 `[]`。

**暂不写：** foreach 中途改 set（`AS_ITERATOR_DEBUGGING`：`TSet is being modified during for loop iteration`）、`opEquals` 遇到不可比较类型（`Cannot compare set element type for equality.`）。

---

## 2. 文件与文案

| 文件 | `@Covers` | 期望异常原文 |
|---|---|---|
| `TSetIteratorOutOfBounds` | `TSet.Iterator` | `Iterator out of bounds.` |

入口：空 set `Proceed`；越过末尾再 `Proceed`。写法对齐 `TArray/Exception/TArrayIteratorOutOfBounds.as`（`return It.Proceed()`）。TSet iterator 没有 GetKey / SetValue / RemoveCurrent。

嵌套容器在 `../Negative/`。未绑定别名在 `../Reject/`。
