# Canonical primitive `++` / `--` 与 CodeGen 失败诊断（2026-08-23）

## 本次完成的窄切片

本次没有尝试扩大 Canonical CodeGen 的通用 lvalue、对象运算符或引用语义覆盖面。完成的是一个可验证的基础语言切片：局部变量或按值参数上的单 dword `int` / `uint` 前置、后置 `++` / `--`，以及与该切片直接相关的失败诊断。

```text
源代码 `++x` / `x++` / `--x` / `x--`
              |
              v
Canonical Sema
  `pre++` / `post++` / `pre--` / `post--`  <- sealed AST literal
              |
              v
Canonical CodeGen
  读取 target 一次
  后置：保留旧值作为表达式结果
  计算 ADDi / SUBi
  回写 target 一次
              |
              v
VM bytecode + Canonical publisher
```

`asCSema::ActOnUnaryExpr()` 不再把 builtin 的 `++` / `--` 留为没有前后置差异的原始拼写；它在 sealed Canonical AST 中记录 `pre++`、`post++`、`pre--`、`post--`。这使 AST dump、快照、摘要和后续消费者可以观察到真正的语言语义，而不是重新从旧 Parser 节点推断。

CodeGen 的 `EmitPrimitiveIncrementOrDecrement()` 只接受已经被 Sema 定型的上述形式，并且 fail-closed：目标必须是 `DeclRef` lvalue、绑定到局部变量或参数、非引用、非 handle、单 dword 的 `int` 或 `uint`。全局变量、字段、下标、解引用、宽整数、对象以及运算符重载仍不会被伪装成这个 builtin 路径。

## 语义保证与明确边界

| 表达式形式 | 表达式值 | 写回 | 本切片状态 |
| --- | --- | --- | --- |
| `++x` | 更新后的值 | 一次 | 已支持（限定目标） |
| `x++` | 更新前的值 | 一次 | 已支持（限定目标） |
| `--x` | 更新后的值 | 一次 | 已支持（限定目标） |
| `x--` | 更新前的值 | 一次 | 已支持（限定目标） |
| `obj.Field++` / `array[i]++` / `*ref++` | 需要更完整的地址/副作用计划 | 未假装支持 | 后续工作 |
| 重载 `opPreInc` / `opPostInc` | Sema 保持 CALL 选择 | 不走 builtin helper | 保持既有路径 |

前置与后置返回类型都保持 operand 的 sealed 类型，特别是 `uint` 不会因 Sema 的旧默认值退化成 `int`。这是必要条件，因为随后的 `/`、比较等操作必须从 sealed 类型选择有符号或无符号 bytecode。

## 发现并修复的实际缺口

组合覆盖用例第一次失败时，新的失败详情报告：

```text
Canonical CodeGen failed code=-7 line=3057:
unsupported conversion function=F() expr=64 literal=conv
srcToken=69 srcBytes=4 dstToken=76 dstBytes=4
```

`as_tokendef.h` 中 `69` 是 `ttInt`，`76` 是 `ttUInt`。根因不是 `++` 指令，而是转换 fast path 只检查了 `IsIntegerType()`；该 API 在本 fork 中只匹配有符号整型，`uint` 必须通过 `IsUnsignedType()` 识别。

修复后的同宽 32-bit 转换只对 signed/unsigned primitive 组合进行表示不变处理：`int <-> uint` 不生成额外 bytecode，也不改变 slot 的 bits。它不放宽不同位宽、浮点、对象、handle 或引用的转换规则。`EmitBinary()` 仍基于 sealed operand type 选择 `DIVi/DIVu`、`MODi/MODu` 等具体指令。

## 失败诊断工具

`asCBytecodeCodeGen` 现在保留第一次终止失败的 `GetFailureDetail()`，并且模块构建失败会把它写到正常 diagnostic：

```text
function=<stable-key> emitterLine=<line> error=<code>

unsupported conversion function=<stable-key> expr=<Canonical expr id>
literal=<literal> srcType=<formatted type> srcToken=<token> srcBytes=<bytes>
dstType=<formatted type> dstToken=<token> dstBytes=<bytes>
```

这只是诊断接口，控制流仍以 `Generate()` 返回值、`GetError()` 和 fail-closed transaction rollback 为权威。这样既能快速定位 Canonical lowering 缺口，又不会把日志字符串误当作 Cache、ABI 或成功状态。

事务测试 `CodeGenEmitterFailureAfterPriorFunctionLeavesNoTables` 现在验证失败同时拥有非空 `GetFailureDetail()`；它和既有的表回滚断言共同保证“可诊断”不会破坏 atomic publication。

## Cache V2 / 摘要影响

本切片没有改变 Cache V2 格式、缓存 key 或恢复协议。`pre++` 等 semantic literal 属于 sealed Canonical AST 本身，因此会自然进入 address-free AST dump 和已存在的 FNV-1a canonical digest；Cache V2 仍只能消费当前已验证的构建产物，而不是从缓存反推旧 AST 节点。没有因为这个局部 lowering 宣称已完成 AST 的跨进程恢复或默认链路切换。

## 验证证据

| 验证 | 结果 | 证据 |
| --- | --- | --- |
| Sema action 直接测试：前/后置 literal 与返回类型 | 1/1 PASS | `Saved/Tests/cta-primitive-incdec-sema/20260823_111810_103_c16d0e18/RunMetadata.json` |
| 原始 postfix red：`Value++` | 如预期失败，暴露未支持 lowering | `Saved/Tests/cta-primitive-postfix-red/20260823_110432_152_61ca0dc8/RunMetadata.json` |
| postfix green：旧值与一次写回 | 1/1 PASS | `Saved/Tests/cta-primitive-postfix-green/20260823_111730_381_d00477d6/RunMetadata.json` |
| signed/unsigned 组合 red + 诊断 | 如预期失败，定位 `int -> uint` | `Saved/Tests/cta-primitive-incdec-diagnostic2/20260823_112651_746_d96bc124/RunMetadata.json` |
| signed/unsigned 组合 green | 1/1 PASS | `Saved/Tests/cta-primitive-incdec-green/20260823_112816_995_5ee43733/RunMetadata.json` |
| Production CodeGen 回归组（最终二进制） | 58/58 PASS | `Saved/Tests/cta-primitive-incdec-final-production-codegen/20260823_113342_552_050eb601/RunMetadata.json` |
| `failureDetail` + transaction rollback 断言 | 1/1 PASS | `Saved/Tests/cta-codegen-failure-detail/20260823_113125_768_728748a3/RunMetadata.json` |
| 最后增量构建（Runtime + Test） | PASS，7 actions | `Saved/Build/cta-codegen-failure-detail-test-build/20260823_113104_100_272ff657/RunMetadata.json` |

最终 Production CodeGen 回归已在 diagnostic type-name 格式增强后的二进制上完成；Sema Authority 的最终组验证为 `252/252 PASS`：`Saved/Tests/cta-primitive-incdec-sema-authority/20260823_113259_532_528bd79d/RunMetadata.json`。

## 后续建议

下一步不要立刻把字段、index、reference 的 `++/--` 塞进当前 helper。应先把 lvalue address plan / cleanup plan 的显式 representation 完成，再让这些目标获得“只求值一次”的语义；否则会重复求值 receiver 或 index，违反 AngelScript 的可观察副作用顺序。
