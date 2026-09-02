# 当前 AST 架构与后续任务地图（2026-08-25）

## 本轮问题

> 现在整体 AST 架构都搞得进度差不多了吧，后面的 task 都在做什么？

## 结论

是的，**Canonical Typed AST 的架构形态已经基本定型**。当前已经不是继续设计“AST 应该长什么样”，而是在完成生产编译器切换：补齐新 Sema 对真实语言和预处理生成代码的语义覆盖，让 Bytecode、TypedASTJIT、Hot Reload、generation、commandlet 和 Standalone 都只消费同一份已验证、已 Seal 的 AST，然后删除 HIR 读路径和旧语义权威。

需要同时保留三个进度口径：

| 口径 | 当前判断 | 含义 |
| --- | ---: | --- |
| AST 架构形态 | 约 **88%–90%** | SourceManager、节点/类型、Sema 分层、Verifier、Seal、Snapshot/Lease、遍历/查询/调试工具、稳定身份和发布协议均已成形 |
| 生产切换工程 | 约 **78%–80%** | 主要纵向切片已经贯通，但完整语言覆盖、全部入口和旧路径移除还未闭环 |
| OpenSpec 机械进度 | **78 / 119 = 65.5%** | 还有 41 个未勾选项；这些任务存在大量交叉和重复验收，不能把 65.5% 直接理解为代码只做了三分之二 |

## 当前真实架构

```text
                               已基本定型
                                   |
.as source                       v
    |
    v
Lexer / Parser ---> Canonical Sema ---> Canonical Typed AST
    |                  |                     |
    |                  |              Verify + Seal
    |                  |                     |
    |                  |              Immutable Snapshot / Lease
    |                  |                     |
    |                  |          +----------+-----------+
    |                  |          |          |           |
    |                  |          v          v           v
    |                  |       Bytecode   TypedASTJIT  AST Debug/Query
    |                  |       CodeGen                 Hot Reload/Cache DTO
    |                  |
    +--> LEGACY asCScriptNode -> asCBuilder/asCCompiler
              ^
              |
              +-- 迁移期的显式 opt-out / 差分 oracle；不能成为
                  Canonical 遇到缺口时的生产静默回退
```

架构问题已经从“有没有新 AST”变成了下面这个更严格的问题：

```text
同一份 source
    |
    v
Canonical Sema 是否已经表达全部后端决定？
    |
    +-- 是 --> Seal --> Canonical CodeGen / JIT / Snapshot
    |
    +-- 否 --> 必须 fail closed 并补语义；不能偷偷调用 asCCompiler
```

## 41 个未完成 task 实际分成什么

### 1. 补齐 Canonical Sema 权威：14 项

对应 `4.2–4.6`、`5.2–5.9`、`13.2`。

它们不是 14 套实现，而是同一组 Sema 收口的声明、表达式、语句、调用、生命周期和复核验收：

- 声明、命名空间、类型、模板、默认参数和依赖信息完全由 Sema 产生；
- 重载、转换、receiver、参数来源/次序和调用路由固化到 AST；
- 循环、switch、break/continue/return 的目标和阶段固化到 AST；
- 临时对象、引用/句柄、析构、异常和 transfer cleanup 固化到 AST；
- delegate、lambda、funcdef、container、import、global 和生成函数覆盖完整；
- 后端不能重新扫描 `asCScriptNode` 或借旧 compiler 推导这些事实。

这是剩余工作的最大块，也是决定默认切换是否安全的核心。

### 2. 补齐后端消费者：9 项

对应 `7.2/7.4/7.5/7.8`、`9.1/9.5/9.6/9.7`、`13.6`。

这组任务做两件事：

1. TypedASTJIT 的 eligibility、调用闭包、cleanup、依赖分析彻底从 HIR 迁到 Canonical AST；
2. Canonical Bytecode CodeGen 补齐对象、容器、delegate、lambda、异常、debug metadata、stack/local layout，并保证失败时不污染模块。

Canonical ProductionCodeGen 纵向切片最近一次完整组结果是 **85/85 PASS**。这个数字只代表已经列入该组的支持面，不等于 AngelScript 全语言已经覆盖；generation、完整语言矩阵和最终切换闸门仍然是独立验收面。

### 3. 生产入口切换与旧路径退休：8 项

对应 `10.1–10.7` 和 `10.9`。

需要证明以下入口都在编译开始前选择 Canonical，而且最终 Bytecode 发布者确实是 `asCBytecodeCodeGen`：

```text
Primary Build
Hot Reload
CompileFunction
StaticJIT generation
commandlet
Standalone
```

随后才执行：

- CANONICAL 成为默认，LEGACY 只保留显式 opt-out/差分用途；
- 删除生产 HIR capture、builder、accessor 和消费者；
- `asCScriptNode` 不再作为生产语义函数体；
- 禁止生产 `dual` 模式和 Canonical 缺口时的静默 LEGACY 回退；
- 跑完整切换闸门。

### 4. Snapshot、SourceManager 与对抗性协议复核：4 项

对应 `3.4`、`13.8`、`13.10`、`13.11`。

主体实现已经存在，这些任务主要是最终合并审计：

- 每个发布者都遵守 candidate verify/seal 后再原子替换；
- concurrent Acquire 与 publish 不发生悬空访问；
- failed rebuild 保留上一代 AST 和可执行代码；
- CompileFunction、Hot Reload、generation 的 snapshot 策略一致；
- SourceManager 坐标贯穿 Lexer/Parser/Sema/diagnostics/backend；
- public view 的小结构体、foreign ID、同 index 不同 snapshot、CodeGen 失败无模块污染都有对抗测试。

### 5. 闸门、迁移文档与最终全量验证：6 项

对应 `0.2`、`0.3`、`11.4`、`12.2`、`12.4`、`13.12`。

这部分主要不是新架构代码，而是证明前四组确实完成：

- 每个剩余语义切片先做 sealed-AST 断言，再做 CodeGen/执行断言；
- 记录 embedding client 的 AST API V1、retention、lease、Cache/SaveByteCode 边界；
- 跑 SDK、Hot Reload、StaticJIT、Debugger、Coverage、Standalone Debug/Release 和 All；
- 最终才允许声明完成或归档。

## 当前正在做的具体工作

当前在推进 `10.1` 的 **StaticJIT generation 真实入口**，不是只检查配置枚举。

已经完成：

- TypedAST generation profile 会在 source compile 之前选择 `CANONICAL`；
- 关闭 transitional Typed HIR capture；
- 要求 Retained Canonical AST；
- 基础真实 project-source-graph 测试 **2/2 PASS**；
- 测试同时验证 publisher=`CANONICAL_CODEGEN`、legacy compiler invocation=`0`、sealed-AST digest 存在。

完整 generation Engine 回归已经从 **11/32 PASS** 推进到 **12/32 PASS，20/32 FAIL**。以下此前被“LEGACY Bytecode + Canonical sidecar”掩盖的前端语义缺口已经完成收口：

1. 显式 enum 初始化改为消费 sealed AST 中的 Canonical 常量，不再构造 `asCCompiler`；
2. 预处理器生成的 delegate/class helper 中显式 `this` 已绑定为专用 typed receiver expression；
3. 原生 generic `?&` 已有显式 Wildcard QualType，`__Evt_PushArgument` / `__DelegateSignature` 一类 helper 调用可以稳定解析；
4. 字符串字面量改为使用 Engine 权威字符串类型，`Throw(const FString&in)` 一类原生调用可以稳定解析。

这四组失败 token 在最新 generation 报告中都已经归零。随后又完成了两层生产边界收口：

1. source-level value parameter 与 runtime `const T&inout` prepared shell 的 ABI 归一化；
2. bare `const T&` 参数到默认 `asTM_INOUTREF` passing 的精确映射。

对应的 declaration/runtime binding 已保持 fail-closed，并补上了字段级 mismatch 诊断；完整 `ProductionCodeGen` 当前为 **85/85 PASS**。generation 仍为 **12/32 PASS、20/32 FAIL**，但所有 `cannot bind its sealed declaration` 失败已经归零。

随后，generated accessor 的 runtime shell / relocation 也已经闭合：新增的 AST-first 测试同时证明 sealed AST 中 getter/setter 指向精确 backing field、调用节点绑定精确 accessor declaration，并证明 prepared module 中生成了 live `GetValue` / `SetValue` 方法和对应 `CALL` relocation。该修复没有在 CodeGen 中重新解释字段语法，也没有回退到 LEGACY。

完整 generation 最近一次全组记录仍为 **12/32 PASS、20/32 FAIL**，但 accessor relocation 失败已经全部归零。随后定位出的下一层共同根因是：预处理器生成的 delegate wrapper 默认构造函数需要初始化一个 32-byte、带构造/析构/赋值语义的非 POD application value object（`_FScriptDelegate`），而 Canonical Bytecode CodeGen 的 member-initialization 分支此前仍按标量宽度写入处理它，因此 fail closed。

这个生命周期问题的第一条纵向切片现已打通：sealed AST 先证明精确 backing field、精确 native value QualType 和精确零参数 native constructor declaration；CodeGen 再把 `this + sealed field offset` 直接作为目标地址调用已解析构造函数，并在 owner 析构时调用精确 native destructor。聚焦执行结果为 **1/1 PASS**，构造/析构计数为 **1/1**，没有放宽为 32-byte 裸 `memcpy`。完整 ProductionCodeGen 与 generation 组仍需在该改动后重新运行，因此不能把先前的 12/32 直接改写成新的全组数字。

构造切片之后重新运行真实 generation，结果仍为 **12/32 PASS、20/32 FAIL**，但失败 token 已经前进并统一收敛到预处理器生成的 wrapper `opAssign`：`_Inner = Other._Inner` 尚未在 sealed AST 中绑定精确 native `opAssign`，CodeGen 因此尝试标量读取 32-byte `_FScriptDelegate`。

这条 `opAssign` 纵向切片现已聚焦闭合：Sema 把唯一匹配的精确 native `opAssign` 固化到 `Assign.resolvedDecl`；CodeGen 只消费该 declaration，按引用 ABI 对 lhs/rhs 各取址一次并发出精确 `CALLSYS`，没有按对象大小裸复制，也没有在后端按名字重新查找操作符。聚焦执行结果为 **1/1 PASS**，赋值一次、复制 payload `41`、两个 live member 各析构一次。完整 generation 32-test group 尚未在这次修复后重跑，因此最新全组数字仍只能引用修复前的 **12/32**，不能提前宣布提升。

`opAssign` 修复后的真实 generation 已重跑：`Saved/Tests/cta-generation-after-native-opassign/20260825_034741_039_c00eb687` 仍为 **12/32 PASS、20/32 FAIL**，但原来的 assignment 失败 token 已全部归零。新的二十项共同边界统一落在 delegate `Execute` 的 `_Inner.IsBound()`：sealed AST 已经绑定精确 native method 和 `_Inner` receiver，CodeGen 却仍用普通 value emission 读取 receiver，因而在 32-byte `_FScriptDelegate` 上 fail closed。

native value-object method receiver 纵向切片随后已经聚焦闭合：新增 AST-first fixture 先证明 native method、owner、32-byte 非 POD receiver、隐式 trailing receiver child 和精确 QualType 都已经固化在 sealed AST；CodeGen 再通过统一左值取址路径传入真实 object pointer，而不是读取或复制 receiver。聚焦执行记录为 **1/1 PASS**：

- Build：`Saved/Build/cta-native-value-receiver-green2-build/20260825_035859_795_c20ff7b0`
- Test：`Saved/Tests/cta-native-value-receiver-green2/20260825_035935_671_c3680c21`

receiver 修复后的真实 generation 也已重跑：`Saved/Tests/cta-generation-after-value-receiver/20260825_040037_935_16e4bf64` 仍为 **12/32 PASS、20/32 FAIL**，但所有 32-byte receiver read-width 失败均已归零。新的二十项共同根因已经继续前移到字符串字面量：sealed AST 中可以看到 `kind=StringLiteral`、类型为 `const FString`、精确 native callee 已解析，但当前 literal payload 仍保留带引号的原始 source spelling，Canonical CodeGen 也尚未从 Engine string factory 生成可按引用 ABI 传递的字符串常量。

为缩短这种 fail-closed 根因的定位时间，Canonical CodeGen 的 unsupported-expression 诊断已经补充 expression ID/kind/literal/type/resolved declaration/receiver/children。聚焦 generation 诊断记录 `Saved/Tests/cta-generation-unsupported-expr-diagnostic/20260825_040506_694_af76b128` 精确指出：

```text
expr=45 kind=StringLiteral literal="Executing unbound delegate."
type=const FString children=0
```

因此当前切片是字符串字面量的 **Sema-authoritative payload + CodeGen string-constant lifetime/ABI**：Sema 负责把 raw token 解码成带精确长度的语义字节（包括 escape 和内嵌 NUL），CodeGen 只消费解码结果，通过 Engine string factory 和临时引用 lease 发出常量；禁止在后端重新解析引号/escape，也不能借 legacy compiler 生成该表达式。

## 后续实际执行顺序

```text
[当前]
generation 真实入口
    |
    +--> enum / this / wildcard helper / Engine string 已闭合
    +--> 参数 QualType / passing / stable signature 已闭合
    +--> generated accessor runtime shell / relocation 已闭合
    +--> native 非 POD value-object 原位构造/反向析构已闭合
    +--> native 非 POD Assign 绑定并调用精确 opAssign 已聚焦闭合
    +--> generation 已确认 opAssign token 归零
    +--> native value-object method receiver 取址已闭合
    +--> generation 已确认 receiver read-width token 归零
    +--> 当前：StringLiteral 解码、精确长度、string factory 与引用 lease
    +--> 随后：按新 generation token 继续对象/容器/delegate/lambda 等闭包
    |
    v
generation 32/32 + publisher/digest/zero-legacy
    |
    v
commandlet + Standalone 真实选择/发布来源审计
    |
    v
补齐剩余 Sema / Bytecode / TypedASTJIT 全语言闭包
    |
    v
删除 HIR 生产读取与 asCScriptNode 语义依赖
    |
    v
默认 CANONICAL + LEGACY 显式 opt-out
    |
    v
完整 AST gate / SDK / StaticJIT / HotReload / Standalone / All
```

Cache V2 已默认关闭并明确延期重构。它只需维持 default-off 边界和不干扰当前切换，不是这轮 AST 默认切换的主阻塞项。

## 通俗判断

可以把当前状态理解成：

```text
新道路的路线、桥梁结构、收费口和监控系统：基本建完
已开放的受控车道：大部分可跑，并且有严格检测
现在的工作：让所有车型和所有入口都能上新路
最后的工作：关闭旧主路的自动分流，保留人工应急入口
```

所以“整体 AST 架构差不多了”是准确的；但“新版编译器已经可以无条件替换旧编译器”还不准确。后续任务的重点是**语义覆盖、消费者迁移、入口证明、旧路径删除和全量验证**，而不是再重画 AST 架构。

## 2026-08-25 04:45 最新复核：架构接近完成，生产闭环仍有硬尾项

本次再次按 OpenSpec 的 119 项清单复核，机械进度仍为
**78/119（65.5%）**，剩余 **41** 项。它们不是 41 个彼此独立的新功能，
而是大量相互重叠的实现项与最终验收项，可压缩成下面五条关键链：

| 收尾链 | 未完成 task 数 | 实际目的 |
| --- | ---: | --- |
| Canonical Sema 权威 | 14 | 补全声明、类型、表达式、调用、控制流、对象生命周期和生成代码语义，使后端不再重新解释 Parser 节点 |
| Bytecode / TypedASTJIT 消费者 | 9 | 让两个后端只消费 sealed AST，并补齐对象、容器、闭包、异常、调试与 cleanup lowering |
| 生产切换与旧 HIR/语义树退休 | 8 | 覆盖全部真实编译入口，默认选择 Canonical，删除生产 HIR 读取和 `asCScriptNode` 语义函数体依赖 |
| Snapshot / SourceManager / 对抗协议 | 4 | 复核原子发布、并发 lease、失败保留上一代、坐标真相与恶意/错配输入 |
| AST-first 闸门、迁移文档与最终验证 | 6 | 证明前四条链确实完成，运行全部 focused、Standalone 和 All 闸门 |

最新完成的字符串字面量纵向切片进一步验证了架构路径：

```text
raw string token
      |
      v
Sema 解码精确语义字节（包括 escape 与内嵌 NUL）
      |
      v
sealed StringLiteral：Engine FString QualType + 精确 byte length
      |
      +--> AST sidecar 按长度持久化
      |
      v
Canonical CodeGen -> Engine string factory -> reference ABI -> temporary lease
```

聚焦证据已经绿色：

- StringLiteral SemaAuthority：**1/1 PASS**；
- 内嵌 NUL 的 AST sidecar round trip：**1/1 PASS**；
- string factory、引用 ABI、临时引用和函数持有引用生命周期：**1/1 PASS**。

但是随后的完整 Canonical ProductionCodeGen 组为 **88/90 PASS**，目前有两项
失败需要先按根因定位：

- `CanonicalTemporaryConstructPublishesCodeGenAndExecutes`；
- `PreparedFactoryEmissionFailureRestoresEveryRuntimeShellAndBehaviour`。

因此当前最准确的口径仍然是：

```text
AST / compiler 架构形态   [##################--] 约 89%
生产切换可交付进度       [################----] 约 79%
OpenSpec 机械清单         [#############-------] 65.5%（78/119）
```

下一步不是继续设计第三套 AST，而是先清掉上述 CodeGen 回归，再让真实
generation 从当前 **12/32** 沿新的 fail-closed token 继续推进；随后闭合
commandlet / Standalone、完整 Sema 与后端语言面，物理删除 HIR，最后执行默认
切换与全量验证。Cache V2 restore / 跨 Engine 恢复仍然默认关闭并延期重构，
不计入这条关键路径。

## 2026-08-25 05:31 复核补记：AST 定型，剩余工作是生产闭环

本轮再次核对 `tasks.md`，机械进度仍为 **78/119（65.5%）**，41 个未完成
task 的分组没有变化。架构判断可以更明确地表述为：Canonical Typed AST 的
核心对象模型、类型系统、SourceManager、Sema/Verifier/Seal 边界、只读
Snapshot/Lease、调试遍历和 Bytecode/TypedASTJIT 消费入口都已经形成；当前
不需要再设计一套新的 AST。未完成项主要是把真实语言面和全部生产入口收进
这套架构，再退休旧权威。

04:45 记录中的两个 ProductionCodeGen 回归已经修复，后续又闭合了：

- native/global 参数的 `&in` / `&out` / `&inout` QualType 方向导入；
- 32-byte 非 POD native value 对象作为引用实参时的 formal-aware 取址传递；
- source-level by-value 与 Runtime prepared shell 的差异继续由 sealed formal
  区分，CodeGen 没有把所有 Runtime reference 一律误判成源语言引用。

最新完整 Canonical ProductionCodeGen 结果为 **91/91 PASS**：

- `Saved/Tests/cta-production-codegen-after-wide-native-ref/20260825_052355_026_8129a05d`

真实 StaticJIT generation 仍为 **12/32 PASS、20/32 FAIL**：

- `Saved/Tests/cta-generation-after-wide-native-ref/20260825_052431_076_7f75ebc5`

但旧的 delegate `Execute(...)` 引用实参失败已经归零。新的共同 fail-closed
边界位于预处理生成的 delegate wrapper：
`FJITGenerationOnlySignal_*::GetUObject() const` 读取 32-byte
`_FScriptDelegate` 字段时走到了 `decl-ref-this-property` 普通值读取路径。
这说明真实 generation 正在继续发现尚未覆盖的表达式/receiver 序列形状；它是
Sema/CodeGen 语言面收口问题，不是 AST 基础架构需要推倒重来。

当前进度口径维持为：

```text
AST / compiler 架构形态   [##################--] 约 90%
生产切换可交付进度       [################----] 约 80%
OpenSpec 机械清单         [#############-------] 65.5%（78/119）
```

后续 task 可以压缩为五条连续工作链：补齐 Canonical Sema 权威、补齐
Bytecode/TypedASTJIT 消费语言面、覆盖全部生产入口、删除生产 HIR 与
`asCScriptNode` 语义依赖、执行全量切换闸门。Cache V2 restore 和跨 Engine
恢复保持默认关闭并延期，不属于当前关键路径。

## 2026-08-25 最新补记：后续 task 不是继续搭 AST，而是把生产闭环做完

目前可以明确回答“整体 AST 架构是否差不多了”：**是，核心架构已经基本
定型，约 90%**。SourceManager、Canonical Type、Decl/Stmt/Expr、Sema、
Verifier/Seal、不可变 Snapshot/Lease、稳定身份、公开只读遍历/查询/调试以及
Bytecode/TypedASTJIT 消费入口都已经存在。当前继续改动这些层，是补真实语义
覆盖和校正契约，不是重新设计第三套 AST。

最新一条真实 generation 失败已经证明了这一点。预处理生成的非 POD native
value-object method call 曾形成：

```text
Sequence(receiver,
         MaterializeTemporary(Call(receiver)))
```

同一个 receiver 因而被求值两次，第一次被当作 32-byte 标量读取。AST-first
测试先在 sealed graph 上观察到 `DeclRef` 同时被 `Call` 和 `Sequence` 直接拥有，
随后修复 Sema：只有底层 `Call` 精确拥有该 receiver 时，才从外层 sequence
移除旧 base。CodeGen 没有通过跳过错误节点来掩盖问题。

验证结果：

- focused AST + CodeGen + lifecycle：**1/1 PASS**；
- Canonical ProductionCodeGen：**92/92 PASS**；
- 报告：`Saved/Tests/cta-production-codegen-after-materialized-receiver-sema/20260825_055727_564_5610fa6e`。

真实 generation 的 `GetUObject()` receiver 失败已经消失；下一个共同边界已经
前移到自动生成的 `Get_Inner()` accessor。它需要返回 32-byte 非 POD
`_FScriptDelegate` 字段，而当前 generated-accessor lowering 仍走标量
`EmitReadValue`。下一条工作会先证明 getter 的 sealed return/field/copy-lifetime
契约，再实现隐藏返回对象和精确复制/生命周期调用；不能用裸 `memcpy` 放宽。

剩余 **41** 个未勾选 task 实际是五组交叉实现/验收项，而非 41 个新的 AST
组件：

1. **Canonical Sema 权威收口**：把 declaration/type/call/control/lifetime、
   delegate/lambda/container/import/global 和预处理生成代码的全部决定固化在
   sealed AST 中。
2. **后端语言面收口**：Bytecode CodeGen 与 TypedASTJIT 只消费 sealed AST，
   补齐对象、容器、闭包、异常、cleanup、debug/coverage/stack layout。
3. **全部生产入口切换**：逐一证明 Build、Hot Reload、CompileFunction、
   StaticJIT generation、commandlet、Standalone 的实际 publisher 是 Canonical
   CodeGen，且 legacy compiler invocation 为零。
4. **旧权威退休**：TypedASTJIT 完成迁移后删除生产 HIR 读取；生产路径不再把
   `asCScriptNode` 当语义函数体；CANONICAL 成为默认，LEGACY 只保留显式
   opt-out 和隔离差分 oracle。
5. **最终闸门与记录**：完成 AST-first 卡片、snapshot/public-view 对抗测试、
   embedding 迁移说明，并运行 focused、Standalone 与 All 全量验证。

因此当前三个进度口径仍应分开看：

```text
AST 架构形态             [##################--] 约 90%
生产切换可交付进度       [################----] 约 80%
OpenSpec 机械清单         [#############-------] 65.5%（78/119）
```

机械进度偏低，是因为很多总括 task 只有在整组语言面和最终验证全部完成后才能
勾选。Cache V2 restore/跨 Engine 恢复继续默认关闭并延期，不阻塞当前关键路径。

## 2026-08-25 06:21 状态答复：架构已定型，后续 task 是生产收口

整体判断不变：**Canonical Typed AST 的架构主体已经基本完成，约 90%**。
后面不是继续增加一套 Decl/Stmt/Expr 或重新设计类型系统，而是让已经存在的
Sema、sealed AST、Snapshot 和后端覆盖全部真实语言面，并完成生产默认切换。

剩余 **41** 个未勾选 task 里，有不少是同一实现结果在不同层的验收项。例如
一个 delegate/lambda 生命周期缺口，可能同时挂在 Sema `5.x`、Bytecode
`9.5`、生产切换 `10.x` 和总复核 `13.2/13.6` 下面；它们不能理解为 41 个
互不相关的新组件。按实际工作可以压缩成：

```text
sealed AST 语义事实补齐
        |
        v
Bytecode / TypedASTJIT 消费全部语言面
        |
        v
Build / HotReload / CompileFunction / generation /
commandlet / Standalone 全部使用 Canonical publisher
        |
        v
删除生产 HIR 与 asCScriptNode 语义依赖
        |
        v
CANONICAL 默认 + LEGACY 显式对照入口 + 全量闸门
```

五组 task 的通俗含义是：

1. `4.x/5.x/13.2`：补齐 Sema 权威。所有 overload、conversion、receiver、
   argument、control target、temporary 和 cleanup 决定必须已经在 sealed AST
   中，后端不能再猜。
2. `7.x/9.x/13.6`：补齐消费者。Bytecode 与 TypedASTJIT 要覆盖对象、容器、
   delegate、lambda、global/import、异常、安全点、debug/coverage 和栈布局。
3. `10.1-10.4/10.7`：逐一切换真实入口，并证明实际 executable publisher 是
   Canonical CodeGen、legacy invocation 为零，而不只是配置枚举选中了
   `CANONICAL`。
4. `7.8/10.5/10.6`：完成 TypedASTJIT 迁移后物理移除生产 HIR；生产编译不再
   使用 `asCScriptNode` 作为语义函数体。LEGACY 仍可作为显式 opt-out 和隔离
   差分 oracle 保留。
5. `0.x/3.4/11.x/12.x/13.8-13.12`：完成 snapshot 原子发布、并发 lease、
   SourceManager、public view 对抗测试、迁移说明和最终 focused/Standalone/All
   验证。这些大多是最终证明，不是再搭 AST 基础设施。

当前最靠前的真实切片是预处理器生成的非 POD `Get_Inner()` accessor。已经
完成并有测试覆盖的事实包括：精确 backing field、精确 native copy constructor、
getter copy-construction plan，以及 caller-owned hidden return object ABI。最新
focused 闸门：

- Build：`Saved/Build/cta-equivalent-postfix-receiver-ast-green-build/20260825_061846_861_0c90fdef`；
- Test：`Saved/Tests/cta-equivalent-postfix-receiver-status-check/20260825_062033_530_b2c44f89`；
- 结果：**0/1 PASS、1/1 FAIL**，失败在 sealed arena 中仍有 3 个等价
  `GetInner` Call，只有一个直接作为 `ReadStored.receiver`，说明 postfix 重写
  尚未清理不可达旧表达式/尚未把单次求值协议证明完整。

因此这条切片当前是 **AST 形状仍为 RED**，还不能进入完整 93-test
ProductionCodeGen 或 generation 的成功声明。下一步先在 Sema 源头消除/隔离
不可达 rewrite 产物，再让返回的非 POD 临时对象只求值一次、可取址、按精确
copy/destroy 路线执行；随后才重跑 ProductionCodeGen 和 generation 32 项。

当前进度口径：

```text
AST 架构形态             [##################--] 约 90%
生产切换可交付进度       [################----] 约 80%
OpenSpec 机械清单         [#############-------] 65.5%（78/119）
当前 getter 纵向切片      [AST RED：不可达重复 Call，尚未闭合]
```

Cache V2 restore/跨 Engine 恢复继续默认关闭并延期，不属于当前关键路径。

## 2026-08-25 本轮纠正与答复：AST 骨架接近完成，后续是语义/后端/切换收口

对上一节 `GetInner` 的 `AST RED` 结论作后续证据纠正：`asCASTContext` 的 arena
允许保留已经被替换、但不可达的 recovery/rewrite 节点；同时 canonical method
Call 会把同一个 effective receiver 同时编码为具名 `receiver` edge 和末尾的
implicit reverse-formal child。通用结构遍历因此可能沿两条 edge 看见同一个
ExprId，不能把 arena 节点数或遍历回调次数直接当成运行时求值次数。

测试改为从函数声明根遍历可达图并按 ExprId 去重后，证明：

- 可达 `GetInner` Call 只有 **1** 个；
- `ReadStored.receiver` 精确指向该 Call；
- backing field、native copy constructor 与 getter copy plan 均精确；
- caller-owned hidden return object 只构造/复制/销毁一次规定的生命周期路线。

随后新增了 CodeGen 对“by-value object Call result 可取址”的精确路线。它复用
`EmitCall` 已经建立的 typed result slot，不重新求值 getter，也不使用裸
`memcpy` 绕过 copy constructor。当前证据：

- focused generated getter：**1/1 PASS**，报告
  `Saved/Tests/cta-generated-getter-call-result-address-green/20260825_063140_279_27441998`；
- Canonical ProductionCodeGen：**93/93 PASS**，报告
  `Saved/Tests/cta-production-codegen-after-generated-nonpod-getter/20260825_063220_172_a21a7e5a`。

当前最小工作点已经前移到 verifier：CodeGen 会 fail-closed 校验 getter 的
copy plan，但 AST verifier 还没有在 backend 之前拒绝 malformed getter init。
新的 `RejectsGeneratedGetterInitWithoutExactCopyConstructionPlan` 已取得预期 RED；
下一步是让 verifier 只接受“零 init（标量/POD）”或“唯一且精确的
Construct(copy-ctor, exact-field-ref) 计划”，然后重跑 focused verifier、
ProductionCodeGen 与真实 generation。

从整体架构看，可以说 Canonical Typed AST 的**结构设计已经差不多完成**，但
不能说编译体系已经全部完成：

```text
源码
  |
  v
Parser actions -> Sema -> sealed Canonical AST -> verifier/snapshot
                         |                    |
                         |                    +-> dump/query/diff/debug
                         +-> Bytecode CodeGen +-> TypedASTJIT
```

上图的盒子和边都已经存在。剩余工作主要是保证每一类真实 AS 语义都能走完这些
边，而不是继续发明新的 AST 层。`tasks.md` 当前机械计数仍为 **78/119，65.5%**；
剩余 **41** 项存在大量交叉验收，不能当作 41 个互不相关的新功能。按工程工作包
归并为：

1. **Sema 权威补齐（4.x、5.x、13.2）**：把声明、类型、overload、conversion、
   receiver、参数来源/顺序、控制目标、temporary、cleanup，以及
   container/delegate/lambda/import/global/generated-code 的决定全部固化到 sealed
   AST。
2. **后端消费面补齐（7.x、9.x、13.6）**：Bytecode 与 TypedASTJIT 覆盖对象、
   容器、闭包、global/import、exception/cleanup、安全点、debug/coverage、栈布局，
   且只能读取 AST，不能重新做 Sema。
3. **Snapshot/publication 收口（3.4、13.8、13.10、13.11）**：证明 verify-before-
   publish、失败不污染 module、Acquire/publish 并发 lease、SourceManager 和小尺寸
   public view 等对抗边界。
4. **所有生产入口切换（10.1-10.4、10.7）**：逐项证明 Build、Hot Reload、
   CompileFunction、generation、commandlet、Standalone 发布的真实 Bytecode 来自
   sealed AST 上的 Canonical CodeGen，而不仅是配置值叫 `CANONICAL`。
5. **旧权威删除（7.8、10.5、10.6）**：TypedASTJIT 不再读取 HIR 后，删除生产
   HIR capture/accessor；生产路径不再把 `asCScriptNode` 当语义函数体。LEGACY
   暂时只作为显式 opt-out 和隔离差分 oracle。
6. **最终交付闸门（0.x、11.4、12.x、13.12）**：补迁移说明，跑完整 AST-first
   matrix、focused、Standalone 和 All，最后才允许默认切换与完成声明。

因此当前更有意义的三个口径仍是：

```text
AST 数据模型/工具架构      [##################--] 约 90%
生产切换可交付进度         [################----] 约 80%
OpenSpec 严格机械清单      [#############-------] 65.5%（78/119）
```

前两个百分比是工程判断，第三个是严格 checkbox 计数。Cache V2 restore 与跨
Engine 恢复继续默认关闭并延期，不在当前关键路径。

## 2026-08-25 当前答复：AST 架构主体已接近完成，后续在做生产编译闭环

可以把当前状态概括为：**AST 的“器官和骨架”已经接近完成，后续任务主要在接
神经、血管并替换旧系统，而不是再造一棵 AST。** `Decl/Type/Stmt/Expr`、arena、
seal/verifier、稳定 ID、SourceManager、snapshot/public view、dump/query/diff、
AST-first matcher，以及 Canonical Bytecode CodeGen 的主体入口均已存在。

OpenSpec 严格计数仍为 **78/119 完成、41 项未完成（65.5%）**。这个计数低于真实
架构成熟度，因为 `4.x/5.x`、`9.x`、`10.x` 和 `13.x` 常常是在不同层验收同一个
语言语义。例如一个非 POD generated setter，需要同时满足 Sema 赋值计划、
verifier 防火墙、Bytecode 生命周期和最终 cutover，最后会关闭多个 task，但实现
上是一条纵向切片。

剩余工作按依赖关系归并为五包：

```text
1. Sema 语义权威补齐
   类型/重载/转换/receiver/参数/控制目标/temporary/cleanup
                         |
                         v
2. 后端消费闭环
   Bytecode + TypedASTJIT 覆盖对象、delegate、lambda、容器、
   global/import、exception、debug/coverage、安全点和栈布局
                         |
                         v
3. Snapshot 与真实入口发布
   Build / CompileFunction / HotReload / generation / commandlet / Standalone
                         |
                         v
4. 默认切换和旧权威清退
   CANONICAL 成为生产默认；删除生产 HIR；asCScriptNode 不再承载语义函数体；
   LEGACY 仅保留显式 opt-out 与隔离差分 oracle
                         |
                         v
5. 最终交付闸门
   AST gate matrix + focused suites + Standalone Debug/Release + All
```

截至本次答复，generated non-POD getter 的 verifier 已完成 fail-closed 校验：

- focused verifier：**28/28 PASS**；
- generated getter lifecycle：**1/1 PASS**；
- Canonical ProductionCodeGen：**93/93 PASS**；
- 真实 StaticJIT generation 已不再失败于 `Get_Inner()`，而是前移到
  `_FScriptDelegate::Set_Inner(_FScriptDelegate)`。

新的 setter 失败不是 AST 架构缺失，而是下一条复杂语义闭环：非 POD by-value
参数不能裸复制，generated setter 也不能按标量写字段。Sema 必须在 sealed AST
中记录精确的 `opAssign`/参数所有权/cleanup 计划，verifier 校验它，CodeGen 再按
该计划生成调用与生命周期。完成这一类剩余语言面后，工作重心会自然前移到入口
切换和 HIR/asCScriptNode 清退。

当前建议继续使用三个不同口径：

```text
AST 数据模型与诊断工具架构   [##################--] 约 90%
生产切换可交付进度           [################----] 约 80%
OpenSpec 严格机械清单         [#############-------] 65.5%（78/119）
```

因此，“整体 AST 架构已经差不多了”这个判断是成立的；但“现在已经可以直接删掉
HIR、把 CANONICAL 设为唯一默认并结束”还不成立。后面的核心不是继续设计 AST，
而是证明它已经完整承载所有生产语义，并安全接管所有发布入口。

## 2026-08-25 后续推进：generated non-POD setter 已闭环

上一节所述的 non-POD generated setter 已完成 Sema、verifier、Canonical
Bytecode CodeGen 和 runtime lifecycle 纵向闭环：

```text
lvalue argument
  -> sealed exact copy-construction plan
  -> caller ALLOC(copyCtor)
  -> script-call ownership transfer
  -> callee pointer-bound by-value parameter
  -> generated setter exact opAssign
  -> callee FREE
```

当前证据为 focused setter **1/1 PASS**、verifier **30/30 PASS**、Canonical
ProductionCodeGen **94/94 PASS**。完整设计、RED/GREEN 路径和生命周期 oracle 见
`canonical-generated-nonpod-setter-ownership-gate-2026-08-25.md`。

真实 StaticJIT generation 已越过 setter 问题，最早失败点进一步前移到 snapshot
freeze：runtime 暴露的 value-returning constructor/factory-like function 与
canonical constructor declaration stable identity 尚未绑定一致。它属于
“Snapshot/production publication 收口”工作包，不是新的 AST 架构缺口。

因此当前状态仍可概括为：AST 架构约 **90%**，生产切换可交付约 **80%**，严格
OpenSpec checklist 为 **78/119（65.5%）**。后续主要是在完成语义覆盖、后端消费、
真实入口发布、旧权威清退和最终全量门，而不是重新设计 AST。

## 2026-08-25 后续推进：声明身份与 lambda production publication 已闭环

真实 StaticJIT generation 暴露的 constructor/factory identity 和 generated
accessor ABI 已经完成精确绑定：factory 保持 global wrapper ABI，但通过 exact
artifact owner、return handle、namespace 和参数绑定到 constructor DeclId；generated
accessor 不再错误套用 authored Builder parameter normalization。snapshot freeze
诊断也会给出 invocation kind、Runtime/artifact owner 和结构性 mismatch。

prepared-module Canonical CodeGen 现在还会为嵌套 lambda 建立 detached Runtime
shell，追加 Sema-sealed capture 参数，生成函数体并随 candidate 原子发布。匿名函数
恢复 `$<parent-stable-key>$<source-offset>` Runtime 协议；真正身份仍由
`canonicalASTStableDeclKey` 承担，不使用 rank 猜测。

最新验证结果：

- generated factory identity：**1/1 PASS**；
- generated accessor identity + non-POD setter lifecycle：**1/1 PASS**；
- 真实 StaticJIT generation：**1/1 PASS**；
- StaticJIT CanonicalASTIdentity：**12/12 PASS**；
- sibling captured-lambda execution：**1/1 PASS**，两个不同 FunctionId 分别捕获
  `X=21`，最终执行 `42`；
- Canonical ProductionCodeGen：**94/94 PASS**。

完整证据见
`canonical-declaration-identity-and-lambda-publication-gate-2026-08-25.md`。这使生产
切换工程成熟度从约 **80%** 上调到约 **81%**；AST 架构仍约 **90%**，严格任务
计数仍为 **78/119（65.5%）**，因为 stored closure、exception/suspend、所有生产
入口、HIR/asCScriptNode 清退和最终全量闸门尚未完成。

## 2026-08-25 状态复核：81% 的含义与当前 lambda 存储边界

本次复核后，三个口径没有发生虚假的任务数跳变：严格任务表仍是
**78/119（65.5%）**，Canonical AST 数据模型/工具架构约 **90%**，整个 OpenSpec
达到可默认切换、可清退旧权威并通过最终门禁的工程完成度约 **81%**。最后一个
数字是按依赖和风险加权的交付成熟度，不是把 119 个 checkbox 等权相加。

当前正在审计 Task 9.5 的 lambda/funcdef 生命周期。已经确认的 ABI 边界是：

```text
非捕获 lambda -> 可存入 funcdef handle -> CallPtr 后续调用

捕获 lambda   -> 当前 Canonical 扩展可直接调用/IIFE
              -> 调用点把 sealed capture 作为隐藏参数传入
              -> 不能直接存入现有 funcdef handle
                 （funcdef 只保存函数指针，没有 capture environment）
```

因此本阶段不应悄悄发明一种会改变 AngelScript 语言和运行时 ABI 的堆闭包对象。
正确的收口目标是：为“存储非捕获 lambda”建立执行回归；对“捕获 lambda 逃逸到
funcdef 存储”在 Sema/seal 阶段给出稳定、可测试的拒绝，而不是等 CodeGen 因签名
不匹配偶然失败。这一边界闭环之后，Task 9.5 仍需继续覆盖对象/temporary、
containers、delegate/funcdef、global/import、generated lifecycle、exception/suspend。

从用户可感知的里程碑看，剩余约 19% 依次是：

1. 补齐上述剩余 Sema/lifetime/CodeGen 语言面和 debug/coverage/safe-point 元数据；
2. 让 TypedASTJIT 只消费 sealed Canonical AST，并清除生产 HIR 读取；
3. 让 Build、CompileFunction、Hot Reload、generation、commandlet、Standalone 的
   source compile 入口统一走 Canonical；
4. 将 CANONICAL 设为默认，保留 LEGACY 作为显式 opt-out/隔离差分 oracle，并让
   `asCScriptNode` 退出 Canonical 生产语义函数体；
5. 跑 AST gate matrix、各 focused suite、Standalone Debug/Release 和最终 All。

Cache V2 已默认关闭且计划另行重构，不计入当前关键路径，也不会阻塞这次 AST
切换；这里只保留“默认关闭边界不回归”的门禁。

## 2026-08-25 后续推进：lambda 存储边界已闭环

“捕获 lambda”是指匿名函数读取或修改了外层函数的局部变量。例如 lambda 中读取
外层 `X`，执行时就不仅需要函数身份，还需要能找到 `X` 的捕获环境：

```text
非捕获 lambda value = { FunctionIdentity }

捕获 lambda closure = { FunctionIdentity, CaptureEnvironment }
                                           |
                                           +-- X
```

当前 AngelScript funcdef 值与 `CallPtr` ABI 只能表示前一种函数身份。Canonical
编译器已经支持直接捕获调用/IIFE：调用点把 Sema-sealed capture 当作隐藏参数传给
lambda；也已经支持把非捕获 lambda 存入 funcdef local 后再间接调用。真正把捕获
lambda 存储、返回或传出当前生命周期则需要新的 closure layout、GC/refcount、复制/
析构、调用、异常、suspend 和 hot-reload ABI，本次没有暗中改变现有语言语义。

现在这条边界已经从“后端因签名不匹配偶然失败”升级为 AST/Sema 权威规则：整个
candidate graph 中，捕获 lambda 若不是 exact resolved direct call，就在 seal/
publication 前产生稳定的 `capturing-lambda-cannot-escape`。assignment、conversion、
return 或 call-argument wrapper 都不能隐藏逃逸。

最新验证为：exact Sema **1/1 PASS**、stored noncapturing execution **1/1 PASS**、
stored capturing rejection **1/1 PASS**、完整 ProductionCodeGen **96/96 PASS**、
focused `CompileFunction` capture **1/1 PASS**、StaticJIT CanonicalASTIdentity
**12/12 PASS**。完整 RED/GREEN 证据和语言边界见
`canonical-lambda-storage-boundary-gate-2026-08-25.md`。

这次完成的是 Task 9.5 的一个明确纵向切片，未改变严格 checkbox 数：仍为
**78/119（65.5%）**；AST 架构成熟度仍约 **90%**，整体默认切换工程成熟度仍约
**81%**。下一步继续补齐 Task 9.5 的 object/temporary、container/template、
delegate/funcdef 其他生命周期、global/import、generated/list factory、exceptional
cleanup 与 suspend/resume，不能因为 lambda 边界已经清晰就提前勾选 9.5。

用户随后确认项目实际很少使用 lambda，因此完整 heap closure 已从本次范围中明确
延期。Canonical 默认切换只要求保持最小现有兼容面：直接捕获调用可执行、非捕获
lambda 可存储调用、捕获逃逸在 Sema 早期稳定拒绝；不会继续投入资源改变 funcdef、
GC 或调用 ABI。后续优先级转回 import/global、对象/容器生命周期、exceptional
cleanup、suspend/debug metadata 和真实生产入口。

## 2026-08-25 后续推进：真实 prepared import production 入口已闭环

真实 UE staged compile 不是让 Canonical CodeGen 自己重新创建 import。Builder
Stage2 已经占用了 authoritative Engine import slot 和 FunctionId；sealed AST 之后必须
精确绑定到这个 shell。`GeneratePreparedModule()` 原先对任何非空
`bindInformations` 都硬拒绝，因此早期 detached import GREEN 并未覆盖生产入口。

当前链路已经变成：

```text
sealed import Decl
  -> producer stable key + origin + namespace + source signature
  -> exact Stage2 asFUNC_IMPORTED shell / Engine slot
  -> DeclId relocation
  -> CALLBND
  -> public BindImportedFunction
  -> provider result 41 + caller 1 = 42
```

身份不匹配会在任何 body/import mutation 前返回稳定诊断；恢复 identity 后同一模块可
重试成功。带 primitive value 参数的 import 也证明了双层签名模型：stable key 保留
源码 `int`，Runtime shell 保持 Builder 的 `const int`；call emitter 仍根据 sealed
source formal 决定按值复制/所有权语义，不能从规范化后的 Runtime reference 反推。

最新 fresh evidence：参数化 prepared import **1/1 PASS**、Canonical
ProductionCodeGen **98/98 PASS**、Module Imports **7/7 PASS**、StaticJIT
CanonicalASTIdentity **12/12 PASS**。详细 RED/GREEN、失败事务和非声明范围见
`canonical-prepared-import-publication-gate-2026-08-25.md`。

这仍是 Task 9.5 的一个纵向切片，严格 checkbox 保持 **78/119（65.5%）**；AST
架构成熟度仍约 **90%**，默认切换工程成熟度约 **81%**。imported/indirect non-POD
ownership、globals/containers、exceptional cleanup、suspend/debug metadata、生产入口
统一和 HIR/asCScriptNode 清退仍需继续完成。
