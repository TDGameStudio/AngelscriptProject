# TOptional Reject 预期覆盖

- 日期: 2026-08-27
- 范围: 仅 `TestSource/Containers/TOptional/Reject`
- Bind 权威: `Bind_TOptional.cpp` 的 `TOptional.Declaration` 与 `TOptional.MethodSurface`
- 约定: 上级 `../Organization.md`

编译期拒绝：整份源码是非法程序，文件头 `@Kind CompileReject`，**一个非法程序一个文件**。容器套容器在 `../Negative/`，不要混进来。

---

## 1. 清单

| 文件 | 非法构造 | 位点 |
|---|---|---|
| `TOptionalMissingTypeArgs.as` | `TOptional Opt;` 缺模板参数 | local |
| `TOptionalAssignWrongElementType.as` | `TOptional<int> Opt; Opt = "hello";` 元素类型不符 | local 赋值 |
| `TOptionalUnknownElementType.as` | `TOptional<FNotAType> Opt;` 未知元素类型 | local |

## 2. 规则

1. 一个非法程序一个文件；编译器常在第一个错误停，合并会让后面的 case 变假覆盖。
2. 元素类型默认 `int`。
3. 容器嵌套（`TOptional<TArray<...>>` 等）不在这里，归 `../Negative/`。
4. 能编译、只是调用后 Throw 的不在这里，归 `../Exception/`。

## 3. 暂不收

- `TOptional<void>`：void 元素类型在本 Bind 下与未知类型同构，不另建文件
- 未绑定 API 别名：TOptional 无 `GenerateKeyArray` 类别名面
