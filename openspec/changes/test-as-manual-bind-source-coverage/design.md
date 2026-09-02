## Context

`TestSource` 最初由本 change 规划为 614 个 Bindings/TestFramework 文件，随后扩展为当前 3,041 个 `.as` 和 11 个测试主题。旧实现检查主要证明“路径存在、符号存在、不是 void、没有明显恒真式”，没有证明调用者能传入真实参数、读取原始结果、观察 out/inout 写回，或按当前 `FAngelscriptTestWorld`、ProcessEvent、TimerManager、delegate 和 GC 生命周期执行。

静态审计得到以下基线：

- 6,927 处 `Observe_*`、342 处 `SurfaceNNN`、2,905 处 `_Nominal`。
- 六个主要根目录的 5,970 个 Observe 函数中，4,041 个零参数、4,603 个只返回 bool、3,061 个用 `&&`/`||` 聚合，显式 `&out/&inout` 为 0。
- World/Actor/Component/Timer 重点范围的 170 个 observer 全部缺少直接函数级注释；49 个文件、83 处成功 predicate 错误要求 runtime DefaultComponent 为 null。
- `Generation/Rules/Authored` 的 614 个 v1 记录没有逐函数 CaseId、精确 declaration、typed arguments、vectors、writebacks 或 exception oracle；exporter 把整段 `plannedSymbols` 同时写入 declaration 和 entryPoint。

OpenSpec 先于全量实现更新。每个主题在修改源码之前，必须先产生经审核的完整函数映射；执行中发现的新事实允许继续改写本设计和 tasks，但不能绕过 contract gate。

## Goals / Non-Goals

**Goals:**

- 让每个测试案例具有稳定 CaseId，让每个 callable 具有语义名称和精确 AS 声明。
- 让输入、return、out/inout、对象身份、容器内容、诊断、lifecycle phase 和 cleanup 可被未来外部 runner 直接消费。
- 让每个 callable 声明正上方都有足以理解目的、参数、结果和边界的英文知识注释。
- 清除旧生成式函数名和 compound-bool 自证，并修正当前 UE 5.7 framework 不兼容的 Actor、NewObject、Blueprint、HotReload 等 fixture。
- 用 TestSource-local schema、Contracts、Tasks 投影和 validator 机械保证不遗漏函数、不漂移声明、不重复 CaseId。
- 通过 TArray 先验证约束，再在互斥目录并行迁移全部 TestSource。

**Non-Goals:**

- 本轮不修改插件 C++ runner、CQTest、Automation、bindings 或 Runtime API。
- 本轮不把 TestSource 移进插件，不维护第二份可编辑 `.as`。
- 本轮不声称整个 TestSource 已被 UE 编译或执行；静态 contract acceptance 与 runtime acceptance 分开记录。
- 本轮不重排整个目录树；除正/负源码隔离、HotReload 版本链或一个文件混合不兼容 module 状态外，保留现有路径。

## Decisions

### CaseId 与函数名分层

CaseId 是稳定行为身份，函数名描述操作，不把流水号嵌入函数名。例如：

```text
CaseId: TS-BIND-TARRAY-004.FindIndex.FirstDuplicate
Function: FindFirstIndex
Declaration: int32 FindFirstIndex(const TArray<int32>&in Values, int32 Value)
```

旧 `Observe_*`、`SurfaceNNN` 和 `_Nominal` 只进入 `legacySymbols`/`legacyDeclaration`，源码不保留兼容转发。已有 CaseId 继续使用；一个文件内的多行为使用稳定语义 subcaseId。

### v2 contract 是函数设计真源

权威文件位于：

```text
TestSource/Generation/schema/authored-case-contract-v2.json
TestSource/Generation/Contracts/<SourceRelativePath>.json
TestSource/Generation/Contracts/index.json
```

每个 contract 至少记录：`schemaVersion`、`caseId`、`subcaseId`、`sourcePath`、`namespace`、`sourceShape`、`executionProfile`、`legacySymbols`、`functions[]`、`sourceAssertions[]`、`coverage` 和 `review`。普通 callable source 至少有一个 function；零 callable source 必须有非空 source assertion，二者不能同时为空。source-only assertion 用于 compile diagnostic、类型/属性声明和 HotReload 版本状态，不得伪造 no-op callable。

每个 function 记录：`owner`（完整 namespace + class/struct/interface/outer-callable identity）、`role`、`name`、`declaration`、`legacyDeclaration`、`requiredNameReason`、`fixture`、`phase`、`cleanupOwner`、`parameters`、`return`、`writebacks`、`vectors` 和 `commentFacts`。唯一性与 source parity 使用 `owner + declaration`，不能只用未限定声明；不同类型或 namespace 可以合法拥有相同声明，只有同一 owner 内的真实重复才失败。

`Contracts/index.json` 与 `Generation/Tasks/<Domain>.md` 都从 contract 确定性生成。Tasks 直接展示 owner、旧声明、新名称、完整声明、输入/返回/writeback vectors、注释摘要、fixture/cleanup 和验证命令，但不是独立可编辑真源。投影只消费 `reviewed` 且通过全局唯一性与当前源码 parity 的 row；draft、legacy-only、stale、duplicate 或 source-drift 输入使生成 fail closed，不得写出标称 reviewed 的投影。

### OpenSpec normalized planning ledger 与用户 review gate

在 materialize TestSource contract 之前，OpenSpec 使用 `attachments/contracts/normalized/` 保存一次可复现的计划快照。canonical denominator 固定为 3,041 个 source 和 11,987 个当前 owner-qualified callable；不同审计 parser 的数量只能作为待 reconcile 的输入，不能替代 denominator。ledger 按 `sourcePath + owner + callable kind + exact declaration block + source position/body hash` 对齐现有 callable，并把 1-to-N split 展开成一个 replacement callable 一行。

每个 normalized row 必须包含精确的当前 identity、建议 owner/name/declaration、相邻英文注释全文、参数/default/direction、raw return、writebacks、body plan、prohibited direct calls、concrete typed vectors、fixture/invocation/cleanup、coverage evidence、status、blocker 和输入证据 hash。每个 source-only row 必须包含具体 source assertion 与诊断或版本向量。任何缺失字段都形成显式 blocker；执行代理不能在修改 `.as` 时自行补设计。

正式 `tasks.md` 是这个 ledger 的完整 review projection：每个 proposed callable 一个 checkbox、每个 source-only assertion 一个 checkbox、每个文件一个 verification checkbox。任务不得包含 `expand later`、`remaining`、省略号、占位类型或待执行代理发明的声明。计划包先由用户 review；只有 reviewed row hash 被接受，后续 source implementation gate 才开放。当前已存在但尚未获最终独立 review 的 Contract V2 infrastructure 仅记为 `existing-unaccepted-implementation-snapshot`，不能因为测试 GREEN 就把 OpenSpec acceptance checkbox 自动勾选。

`attachments/contracts/audit-index.md` 是审计与数量索引；`attachments/reviews/plan-review-guide.md` 是人类 review 导航。二者都由 normalized manifest/task projection 的最终计数反向核对，不能用 prose 数量覆盖机器清单。

### typed value 和 oracle 不使用自由文本代替

参数明确记录 AS 类型拼写、方向 `value|in|out|inout`、调用前值和调用后值。比较模式限定为 `exact`、`near`、`sameIdentity`、`differentIdentity`、`orderedElements`、`unorderedElements`、`contains`、`atLeast`、`relation`、`exception` 或 `compileDiagnostic`；`near` 必须有 tolerance。

UObject-like 值通过 fixture identity、null、class、outer、name 和 flags 表达；容器记录元素、顺序、重复、mutation 和 copy independence。out/inout 没有 writeback vector 时 contract 无效。

### 参数传入和结果传出优先

- 外部输入进入函数参数，不能全部硬编码在函数体。
- expected 值进入 vectors，不作为 `Expected*` 参数让 AS 自行判定。
- API 原始返回值直接返回；多个实际结果使用 `&out`；receiver/container mutation 使用 `&inout`。
- bool 只有在被测 API 原始返回 bool 时才是合格原始输出。
- `return A && B && C` 不能作为多结果的唯一 oracle。
- 合法零参数 entry 必须记录 `zeroArgumentReason`，例如默认构造或 UE 固定 callback。
- override/interface 的精确声明优先于机械补 `&inout`；若绑定要求裸 `&`，contract 记录方向语义和 `requiredNameReason`。

### 每个 callable 必须有直接知识注释

注释统一使用英文 `//`，直接附着于 global function、method、constructor/destructor、operator/free mixin、delegate/event/import、lambda、UFUNCTION、Blueprint override、生命周期 callback、helper 和 negative trigger。对于 annotation，注释放在 `UFUNCTION(...)` 等 callable annotation 正上方；lambda 注释放在包含匿名函数的赋值或调用表达式正上方。前一个语句同行的尾随注释不能算作下一 callable 的注释。

注释至少表达 CaseId、role/purpose、inputs 或 fixture/phase、outputs/side effects、cleanup/boundary。文件头只能提供文件级背景，不能抵扣函数注释。

### callable inventory 与 strict parity

inventory 必须覆盖当前 TestSource 语法，包括不同 namespace/类型内的同声明 callable、constructor/destructor、operator、delegate、event、import declaration、free mixin、`function()` lambda、`[](){}` negative lambda、annotation、多行声明、default argument、reference direction，以及 comments/strings 中的伪声明。匿名 callable 使用稳定的 outer-callable owner 加源码序号/位置 identity，不要求给源码发明可调用别名。

strict parity 同时核对 owner、callable role/kind、semantic return type、parameter name/type/direction/default、annotation 与 exact declaration。comparison oracle 必须按 comparison kind 携带相应 typed payload；expected return、exception 与 compile diagnostic 互斥且语义一致。固定 framework/override/import/event/mixin/lambda 名称必须有 `requiredNameReason`，legacy declaration 必须与 legacy history 对应。

legacy v1 adapter 只能产出 `legacy-unreviewed` / `audit-only` 迁移证据。活动 authored export 必须要求 reviewed、source-parity-clean 的 v2 contract；缺失 v2 时 fail closed，禁止继续把 `plannedSymbols` 猜成 declaration/entryPoint 或默认写入 compile pass。

### required framework 名称不重命名

`BeginPlay`、`Tick`、`Construct`、Blueprint event/override、TestFramework discovery/hook 名称和约定 delegate handler 只有在当前框架允许时才能重命名。保留时 contract 必须填写 `requiredNameReason`；清理旧测试入口名称不得破坏引擎协议。

### 生命周期按真实外部驱动拆分

World story 使用 Arrange/Act/Read/Release/Cleanup phase，而不是直接调用 callback 后自证：

- runtime Actor 非 CDO，属于 case-owned World。
- DefaultComponent 在正确 spawn 后必须物化，不能把 null 当成功。
- exact tick 由 direct dispatch 驱动；manager tick 单独记录弱保证。
- timer acceptance 必须经过 TimerManager advance；直接 callback 是不同 subcase。
- delegate acceptance 必须经过真实 Broadcast；direct handler call 是不同 subcase。
- destroy 后读取限定为 drain 后、GC 前；GC 后只观察 weak/null。
- 普通 reachability 将 create/retain/release/host-GC/read 分相位；脚本内 GC 仅保留给 GC API 自身测试。
- Blueprint/Inheritance 将 AS direct dispatch 与 external ProcessEvent 分开；HotReload 明确 retained/replaced identity、surface、body 和 cleanup。

### 主题先审计、后实现

每个主题执行顺序固定为：

1. 子代理只读审计当前 `.as`、对应 Bind/当前 C++ oracle 和 framework。
2. 生成该主题完整 contract 和 Task 投影，覆盖每个 callable。
3. 独立审查后把 contract 标为 `Reviewed`。
4. 才允许修改该主题 `.as`。
5. 运行主题 strict validator 并独立复核。

共享 index/projection 只由 contract 工具确定性生成；并行代理只写互不重叠的 source/contract 路径。

### TArray 是首个完整试点

`Bindings/TArray` 的八个文件、40 个正向 callable 和 5 个负向入口先完整迁移。试点覆盖 empty/populated、duplicates、first/missing index、copy independence、move 后 source、inout mutation、ordered/swap semantics、iterator alias、invalid access、capacity relation 和 nondeterministic shuffle invariants。

试点 strict 通过并完成审查后，约束才推广到其余主题。

### 状态分层且不得虚报

每个案例状态分为：`PlanDesigned`、`PlanReviewed`、`Materialized`、`ContractReviewed`、`SourceStrict`、`CompileVerified`、`RuntimeVerified`、`ExternalOracleVerified`。当前 plan-only review turn 只允许完成 `PlanDesigned` 并请求 `PlanReviewed`；用户 review 前不推进 source 状态。没有插件 runner 的案例不得标记后三项。

### 下游 generation 只能消费 Reviewed contract

`test-as-source-generation-rules` 不再从 `plannedSymbols` 或名称猜测函数。authored export 只能读取 v2 contract 中的精确 declaration、typed arguments、vectors、writebacks、diagnostics 和 comments；未 `Reviewed` 的 contract 不进入 release mirror。

## Risks / Trade-offs

- **约 7,000 个旧入口需要语义重命名，工作量大** → 每主题先生成完整 contract/task 投影，按目录分批实施并独立审查；禁止一条全局正则直接完成语义迁移。
- **静态 lexer 可能误识别注释、字符串或 annotation** → 先用 TDD 覆盖多行声明、namespace、annotation、delegate、negative source 和嵌套 body，再在 TArray pilot 验证。
- **过度参数化可能破坏 override/interface** → requiredNameReason 和精确声明证据优先，机械规则只作用于 runner-owned entry。
- **全量函数注释增加源码体积** → 注释要求知识完整但不要求固定五行；简单 helper 可紧凑说明，文件头仍保留背景。
- **TestSource-only 无法证明 runtime 行为** → status 分层，当前 C++ oracle 作为设计证据，后续 typed runner 才升级 runtime/external 状态。
- **并行代理可能改到共享 index** → agents 只写互斥 contract/source，index/tasks 由单一确定性生成步骤更新。
- **旧 OpenSpec 任务历史过大且与现状冲突** → 原工件已保存到 history attachment，正式 tasks 只保留当前可执行计划。

## Migration Plan

1. 保存旧 OpenSpec 工件并冻结 plan-only scope。
2. 全量只读审计并 reconcile 3,041 个 source / 11,987 个 current callable，形成带证据 hash 的 normalized planning ledger。
3. 为每个 replacement callable/source-only assertion 展开完整 `tasks.md`；先运行计划自审与 OpenSpec strict，然后停止并交由用户 review。
4. 用户接受计划后，独立复核当前 `existing-unaccepted-implementation-snapshot` 的 v2 schema、lexer/auditor、index/task generator 和 focused tests；未复核前不视为 Task 1 accepted。
5. 按 reviewed row hash 实现完整 Bindings/TArray 与 Containers/TArray pilot。
6. 依次迁移：其余 Bindings；Containers+Optional；Language+Definitions+Feature；World+Gameplay；HotReload；TestFramework+Debugger。
7. 在 World/UObject/Blueprint/GC/Timer/Delegate/HotReload waves 中优先修复已识别的错误语义，禁止用机械改名掩盖。
8. 每个 wave 完成 strict validator 和独立代码审查后，再开始下一 wave。
9. 全量生成 index/tasks，验证 100% source/callable/comment/contract 覆盖和旧名称零残留。
10. 更新下游 source-generation OpenSpec 的 authored-consumer 前置条件；不在本轮实现插件 release mirror。
11. 运行 OpenSpec strict、Generation pytest、TestSource 全量 strict 和工作区范围审计。

## Open Questions

无。实际 UE typed runner 和插件镜像明确留给后续消费者变更；本轮不以缺少 runner 为理由降低 TestSource 源码契约质量。
