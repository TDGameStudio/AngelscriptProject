# TOptional Negative 预期覆盖

- 日期: 2026-08-27
- 范围: 仅 `TestSource/Containers/TOptional/Negative`
- Bind 权威: `Bind_TOptional.cpp` 的 `ValidateOptionalOperations`
- 约定: 上级 `../Organization.md`

**容器不能再嵌套容器。** `ValidateOptionalOperations` 在 `!Type.CanBeTemplateSubType()` 时返回诊断：

```
Containers cannot be nested in other containers
```

本目录只收**外层是 TOptional** 的非法嵌套。外层是别的容器（`TArray<TOptional<int>>` 等）归那个容器自己的 Negative 目录。

---

## 1. 清单

| 文件 | 位点 | 类型 |
|---|---|---|
| `TOptionalOfArrayLocal.as` | local | `TOptional<TArray<int>>` |
| `TOptionalOfArrayProperty.as` | UPROPERTY | `TOptional<TArray<int>>` |
| `TOptionalOfMapLocal.as` | local | `TOptional<TMap<int, int>>` |
| `TOptionalOfOptionalLocal.as` | local | `TOptional<TOptional<int>>` |

## 2. 收口规则

1. 去重按「外层容器 × 内层容器 × 声明位点」。`TOptional<TArray<int>>` 与 `TOptional<TOptional<int>>` 是两种模板实例。
2. 每个非法程序单独一个文件。
3. 元素类型默认 `int`；不建两层/三层深度文件，深度不改变走的错误路径。
4. 位点取 local + UPROPERTY 两个代表；签名位点（参数/返回值）不另建文件。

## 3. 交叉矩阵（本目录已覆盖）

| 外层 \ 内层 | TArray | TMap | TSet | TOptional |
|---|---|---|---|---|
| TOptional | local + property | local | 不在本目录 | local |

`TSet` 内层与 `TMap` 内层同构（都是容器），不重复建文件。

## 4. 允许的「看起来像嵌套」

结构体成员里再放容器是合法的：`TOptional<FMyPayload>`，且 `FMyPayload` 含 `TArray<int>`。这是一层容器 + 一层 USTRUCT，不是容器套容器。本目录暂无此正例，需要时进 `../UClass/`。
