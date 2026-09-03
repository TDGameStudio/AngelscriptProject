# TOptional Exception 预期覆盖

- 日期: 2026-08-27
- 范围: 仅 `TestSource/Containers/TOptional/Exception`
- Bind 权威: `Bind_TOptional.cpp` 的 `FAngelscriptOptionalBinds::GetValue`
- 约定: 上级 `../Organization.md`

能编译、调用入口后 Throw 的文件。文件头 `@Harness RuntimeException`，每个入口 `@Kind RuntimeException`。**不要**和正例 Observe / RoundTrip 同文件。

---

## 1. Throw 面

TOptional 只有一个 Throw 点。`GetValue` 在 unset 时：

```cpp
FAngelscriptEngine::Throw("GetValue() called on Optional when not set! Check the optional with IsSet() first.");
```

const 与 non-const 两个 overload 共用同一个实现，所以共用同一条文案。

## 2. 清单

| 文件 | 覆盖的 Throw |
|---|---|
| `TOptionalGetValueUnset.as` | unset 读 / Reset 后读 / 从 unset optional 赋值后读；含 `FString`、`FVector` 两个非平凡元素类型 |

入口：

| 入口 | 构造 | 边界 |
|---|---|---|
| `ReadUnset` | 默认构造后直接 `GetValue()` | 从未 set |
| `ReadAfterReset` | Set(42) → Reset() → `GetValue()` | 值已销毁，不是归零 |
| `ReadAfterAssigningUnset` | Set(42) → 赋一个 unset optional → `GetValue()` | unset 状态经 opAssign 传播 |
| `ReadUnsetFString` | 默认构造 `TOptional<FString>` → `GetValue()` | 非平凡元素类型 |
| `ReadUnsetFVector` | 默认构造 `TOptional<FVector>` → `GetValue()` | 结构体元素类型 |

## 3. 不是 Exception 的

| 入口 | unset 时行为 | 归属 |
|---|---|---|
| `Get(DefaultValue)` | 返回 fallback | `../Function/TOptionalGet` |
| `IsSet()` | 返回 false | `../Function/TOptionalIsSet` |
| `Reset()` | no-op | `../Function/TOptionalReset` |
| `opAssign` 从 unset | 传播 unset | `../Function/TOptionalCopyAssign` |

只有 **`GetValue` 的 unset 读** 进本目录。不要为 `Get` / `IsSet` / `Reset` 编造 Throw 用例。
