# TSet Reject 预期覆盖

- 日期: 2026-08-27
- 范围: 仅 `TestSource/Containers/TSet/Reject`
- Bind 权威: `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_TSet.cpp`
- 约定: 上级 `../Organization.md`

CompileReject for **wrong types and unbound UE APIs**. Nested containers live in `../Negative/`. Runtime Throw lives in `../Exception/`.

`@Harness CompileReject`。类型各一份非法程序。未绑定 API 按家族一份：编译器会对每个调用报 `No matching signatures`。不要 Actor 壳（错位的 `SetupPlayerInputComponent` 除外，保留原类名给 C++ oracle）。

## 类型 / 按值修改

| 文件 | 非法构造 | `@Return` 片段 |
|---|---|---|
| `TSetVoidType.as` | `TSet<void>` | does not compile |
| `TSetUnknownElementType.as` | `TSet<NonExistent>` | does not compile |
| `TSetMissingTypeArgs.as` | `TSet` 无类型实参 | does not compile |
| `TSetAddWrongElementType.as` | `TSet<int>.Add("hello")` | does not compile |
| `TSetByValueMutation.as` | by-value `TSet<int>` 上 `Add` | `Non-const method call on read-only object reference` |

## 未绑定 UE 别名

合法对应：`Contains`、`Add`/`Remove`、`Append`。不要把这些名字写进 Function 当漏测。TSet **没有** `[]`。

| 文件 | 调用 | 期望 diagnostic |
|---|---|---|
| `TSetUnsupportedApiAliases.as` | `Find` / `FindOrAdd` / `Reserve` / `Shrink` / `Sort` / `Array` / `GetMaxIndex` / `Union` / `Intersect` / `Difference` / `Includes` | `No matching signatures` 及同形 |

## 错位 CompileReject（不是 TSet API）

| 文件 | 非法构造 | 期望 diagnostic |
|---|---|---|
| `SetupPlayerInputComponent.as` | `BlueprintOverride SetupPlayerInputComponent` | `BlueprintOverride method SetupPlayerInputComponent` |
