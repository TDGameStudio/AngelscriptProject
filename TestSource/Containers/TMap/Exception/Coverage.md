# TMap Exception 预期覆盖

- 日期: 2026-08-26
- 范围: 仅 `TestSource/Containers/TMap/Exception`
- Bind 权威: `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_TMap.cpp` / `Bind_TMap.h`
- 约定: 上级 `../Organization.md`；合法路径仍在 `../Function/`

本目录只收 **能编译、调用后 Throw** 的全局 `UFUNCTION`。`@Harness RuntimeException`，每个入口 `@Kind RuntimeException`。不要混 Observe / RoundTrip。不要放进 `../Negative/`（那边是编不过的嵌套容器）。

Runner 应对 `ExecuteAndExpectException` 与 `@Return` 里的英文原文。这不是进程崩溃。

---

## 1. 约定

- 一文件一个抛错家族（同一文案或同一 API）。
- 同一模块可以有多个入口：分别调用，编译器不会在第一错停。
- 默认 `int`，不套 Function 的类型后缀四件套。
- `@Tag` = `Containers.TMap.<FileStem>`。
- 合法 `[]`、`Contains` 返回 false、`Find` 返回 false 仍在 Function。

**暂不写：** foreach 中途改 map（`AS_ITERATOR_DEBUGGING`：`TMap is being modified during for loop iteration`）、`opEquals` 遇到不可比较类型（`Cannot compare map key/value type for equality.`）。

---

## 2. 文件与文案

| 文件 | `@Covers` | 期望异常原文 |
|---|---|---|
| `TMapIndexMissingKey` | `TMap.opIndex` | `Could not find key in map for index operator.` |
| `TMapIteratorOutOfBounds` | `TMap.Iterator` | `Iterator out of bounds.` |

`Pair.Key` 拒绝在 `../Reject/TMapForEachPairUnsupported`。嵌套容器在 `../Negative/`。
