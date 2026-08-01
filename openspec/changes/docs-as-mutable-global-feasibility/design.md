# Context

当前项目基于 AngelScript 2.33 并选择性吸收 2.38 能力。脚本作者声明全局变量时，fork 会在 builder 注册阶段拒绝公开的非 `const` 变量；这与 vanilla AngelScript 2.38 的行为不同。

问题不能只用“删除一条报错”来描述。脚本全局变量的存储由 AngelScript engine/module 拥有，而 Unreal 项目同时存在编辑器热重载、PIE、多 World、GameInstance 生命周期、解释器与 StaticJIT 双后端、预编译数据和调试器等集成面。即使底层字节码能够写全局地址，产品仍需要定义状态属于谁、何时初始化和销毁、热重载时重置还是迁移，以及哪些类型可以安全进入首批支持范围。

本设计是研究记录，不是实现设计批准。它以当前仓库和本地参考仓库为证据边界，不为原始 Hazelight 作者补写无法从历史验证的动机。

# Goals / Non-Goals

## Goals

- 定位当前 const-only 限制和相关例外。
- 判断限制来自 VM 能力缺失，还是 fork 的前端/产品策略。
- 盘点可变全局变量涉及的执行、生命周期和 Unreal 集成路径。
- 把事实、项目维护理由和架构推断分开记录。
- 给出可供后续 feature proposal 使用的候选路线、类型矩阵和验收门槛。

## Non-Goals

- 不移除或放宽任何编译检查。
- 不新增引擎属性、项目设置、控制台变量或兼容开关。
- 不决定默认开启还是默认关闭。
- 不承诺对象句柄、容器、委托或任意引用类型可安全作为脚本全局变量。
- 不修改现有负向测试，也不运行 UE 构建或自动化测试。
- 不把本地初始导入之前无法验证的设计动机写成确定历史。

# Evidence and Findings

## 1. 当前限制位于 builder 注册阶段

代码事实：

- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_builder.cpp` 的 `asCBuilder::RegisterGlobalVar` 对普通脚本全局变量执行两项额外检查：
  - 对象句柄会报错：`Class types are not supported for global variables`；
  - 非只读变量会报错：`Mutable global variables are not supported`。
- 名称以下划线开头的全局变量会绕过包裹这些检查的条件分支。附近注释把它定义为引擎内部使用、调用方需要自行保证正确性的路径。
- 因而 const-only 不是 parser 无法识别赋值，也不是 VM 没有全局存储，而是 fork 在公开脚本声明进入常规注册路径时主动施加的策略。
- 下划线分支只是机械上的内部逃生口。它没有公开兼容契约、类型矩阵或 Unreal 生命周期保证，不应作为面向脚本作者的现有功能来宣传。

边界事实：

- 限制针对“脚本声明的普通全局变量”，不等同于所有 AngelScript global property 都只读。
- 应用通过 embedding API 注册的原生全局属性可以是可变的。现有测试 `AngelscriptNativePrimitiveTypeTests.cpp` 注册了非 const 的 `int8 gvar`，脚本能够对其赋值并读回；绑定代码中也存在类似 `uint GFrameNumber` 的可变原生属性。

## 2. 该限制是 fork 差异，不是 vanilla AngelScript 约束

代码事实：

- 本地 `Reference/angelscript-v2.38.0` 的 `asCBuilder::RegisterGlobalVar` 没有当前 fork 增加的 const-only 和对象句柄拒绝分支，而是继续注册全局属性描述。
- 当前插件历史中，字符串追踪和 blame 只能追溯到插件快照的初始导入提交；本地 Hazelight 参考快照包含同样检查。

可证明的维护理由：

- `Documents/Guides/AngelscriptForkStrategy.md` 将该差异描述为“防止脚本侧全局状态副作用”，并将 mutable globals 列为通常不吸收的 fork 差异。
- `Documents/Guides/ASSDK_Fork_Differences.md` 记录了相同拒绝行为和替代方向。

不可证明的部分：

- 当前本地历史不足以还原最初引入限制时的完整讨论，不能断言某一个具体 Unreal 场景就是原作者唯一或首要原因。
- 下文关于多 World、PIE 和热重载的内容是根据现有所有权与执行路径得出的风险分析，用来解释为什么这项策略在当前架构中仍有价值；它不是历史归因。

## 3. 编译器和执行后端保留了写全局变量的基础能力

代码事实：

- `asCCompiler::CompileGlobalVariable` 仍会为全局属性分配存储并生成初始化代码。
- 编译器只在“primitive 且 read-only”时把属性标记为 pure constant；这反向说明非只读全局属性的非纯常量路径仍存在。
- 解释器实现了 `asBC_CpyVtoG4`、`asBC_SetG4` 等写全局地址字节码。
- StaticJIT 对应处理这些字节码，并通过 `ReferenceGlobalVariable` 记录或解析全局地址。
- 预编译数据和 bytecode restore 路径包含这些全局写操作引用的保存与重定位逻辑。
- 原生注册的可变 global property 已有脚本读写测试，证明当前运行时不是全局禁止写入。

结论范围：

- 上述证据足以说明“primitive 可变全局变量在底层具有可行基础”。
- 上述证据不足以说明“删除 builder 检查即可完整支持所有脚本声明类型”。前端限制目前阻止相关组合进入大量生命周期与热重载场景，因此这些路径缺少面向该功能的系统性覆盖。

## 4. 模块生命周期存在初始化和析构能力，但产品语义尚未定义

代码事实：

- `asCModule::ResetGlobalVars` 会先执行 `CallExit`，再执行 `CallInit`。
- `CallInit` 会清零或初始化非 pure-constant 的全局存储，并执行初始化函数。
- `UninitializeGlobalProp` 与 `CallExit` 包含对象释放和析构路径。
- bytecode 持久化记录全局属性声明、类型和初始化函数，不持久化某一运行时实例的当前值。
- 编译器在自动 import 场景下禁止用另一个 module 的全局变量初始化当前全局变量，并明确指出对方可能尚未初始化；这表明跨模块初始化顺序本来就是需要防守的边界。

架构推断：

- 这些机制说明 AngelScript 核心具备模块级全局生命周期，但当前 Unreal 集成没有为“用户可变状态”定义保存、复制、回滚或跨 session 持久化契约。
- 对 primitive 标量而言，初始化和销毁风险较小；对对象、句柄、容器或拥有外部资源的值类型而言，需要额外验证 GC、引用计数、析构顺序、初始化异常和编译失败回滚。

## 5. 当前状态所有权是 engine/module 级，而不是 World/GameInstance 级

代码事实：

- `UAngelscriptSubsystem` 是 `UEngineSubsystem`，并持有或采用一个 primary AngelScript engine。
- 脚本 module 及其 global property 存储由该 engine 管理。
- World/GameInstance 上下文由其他集成层提供，但脚本全局变量本身没有自动按 World 或 GameInstance 分片的存储模型。

架构推断：

- 同一 Unreal engine 实例内的多个 World、PIE 实例或 GameInstance 若加载同一个脚本 module，会观察到同一 module 级状态，而不是天然隔离的 World/GI 状态。
- 这可能造成测试顺序依赖、PIE 会话串扰、编辑器预览与游戏世界共享状态，以及网络 authority/replication 语义被误解。
- 如果产品真正需要的是“每 World”或“每 GameInstance”的可变状态，UE Subsystem 明确表达的所有权通常比裸脚本全局变量更匹配；这是一种候选架构，不是本 change 的既定结论。

## 6. 热重载当前更接近重新初始化，而不是值迁移

代码事实：

- 热重载会构造 `ScriptUpdateMap.GlobalVariablePointers`，把旧 bytecode 对全局地址的引用更新到新 module 的存储。
- module 更新逻辑按名称、namespace 和类型匹配新旧全局属性，建立指针映射。
- 后续 globals stage 会调用 `ResetGlobalVars(0)`。
- 在已检查路径中没有观察到把旧 global property 的当前运行时值复制到新存储的通用迁移步骤。

结论与边界：

- 当前证据支持“引用会重定位，而新 module 的全局状态会重新初始化”这一描述。
- 如果未来希望保留可变全局值，必须显式定义按类型迁移、类型变化、变量删除、初始化失败和回滚的语义；不能从现有指针重定位推断出值已经保留。
- 如果未来明确采用“热重载总是重置”，也需要把它作为公开契约并建立测试，避免用户把开发期状态重置当成缺陷。

## 7. 调试、预编译和后端一致性需要单独验收

代码事实：

- Debug Server 能从 `allScriptGlobalVariables` 查找并读取脚本全局变量。
- 当前检查未证明 Debug Server 对脚本全局变量提供安全的写入/Set Value 能力，因此不能把“可观察”写成“可交互编辑”。
- 解释器、StaticJIT 和预编译数据都能识别相关全局地址操作，但未来功能仍需用同一组行为测试验证结果一致，而不能只依赖实现存在。

# Why Const-Only Still Has Architectural Value

下表严格区分证据层次：

| 判断 | 类型 | 依据 |
|---|---|---|
| 当前 fork 有意拒绝公开的 mutable script globals | 代码事实 | `asCBuilder::RegisterGlobalVar` 的明确诊断和分支 |
| vanilla 2.38 没有同一限制 | 代码事实 | 本地 2.38 参考实现对照 |
| 项目维护该差异是为了减少脚本侧全局状态副作用 | 项目文档给出的理由 | `AngelscriptForkStrategy.md` |
| VM/编译器完全没有写全局变量能力 | 被证据否定 | 写全局字节码、编译路径、原生 mutable property 测试均存在 |
| 可变脚本全局状态会天然按 World/GI 隔离 | 被架构证据否定 | 存储所有权位于 primary engine/module |
| 限制最初就是专门为 PIE 或热重载设计 | 无法验证的历史主张 | 当前历史只到初始导入，不应作此归因 |
| 放开限制后必须定义隔离、重载和类型生命周期 | 架构推断/产品要求 | 当前 ownership、ResetGlobalVars 和类型销毁路径共同导出 |

因此，当前限制更准确的定位是：它是一个产品级状态约束，建立在仍然具备可变全局能力的 AngelScript 核心之上。是否放开取决于项目愿意承诺什么状态模型，而不是取决于能否删除一段检查。

# Type Feasibility Matrix

此矩阵是未来调查和分阶段设计的起点，不是支持声明：

| 类型类别 | 当前公开脚本声明 | 已有基础证据 | 放开前必须补齐 |
|---|---|---|---|
| primitive 标量（整数、浮点、bool） | mutable 被拒绝 | 编译、解释器、StaticJIT、原生 mutable property 读写均存在 | 初始化/重置契约、热重载、PIE/多 World、跨后端测试 |
| enum 类型变量 | mutable 被拒绝，枚举常量本身不等同于变量 | 可沿 primitive 存储方向评估 | 单独表征赋值、初始化、调试和 JIT 行为，不能仅由 primitive 推定 |
| 应用注册的原生 global property | 已允许由注册签名决定 constness | 现有 `gvar` 测试和运行时绑定 | 保持既有 embedding 契约；与脚本声明功能分开说明 |
| 非句柄值类型 | mutable 路径被 const 检查阻断，具体类型还受现有规则影响 | 核心有初始化/析构路径 | copy/assign/destruct、初始化异常、重载迁移或重置、预编译/JIT 覆盖 |
| UObject、脚本 class 或其他对象句柄 | 被单独明确拒绝 | vanilla 核心存在 global object 机制，当前 fork 未形成支持契约 | GC/引用计数、UE 对象有效性、World ownership、热重载 reinstancing、析构顺序 |
| 容器、委托及资源拥有型复合类型 | mutable 路径被阻断，能力依具体绑定而异 | 不足以形成支持声明 | 深拷贝/移动/析构、绑定生命周期、异常回滚、并发与重载覆盖 |

# Candidate Approaches

以下方案保持中立，不排序、不推荐。后续 feature OpenSpec 必须明确选择其中一种或提出可验证的新方案。

## Approach A: Unconditionally Remove the Front-End Check

做法：

- 删除公开非 const 全局变量的 builder 拒绝分支；对象句柄限制是否保留需要另行决定。

价值：

- 改动小，最接近 vanilla 的语法入口。
- primitive 路径可快速获得实验性覆盖。

风险和工作量：

- “编译通过”会立即被用户理解为受支持功能，但状态 scope、热重载、类型矩阵和兼容性尚未定义。
- 现有大量负向测试需要重新分类，且所有进入的新类型组合都可能扩大风险面。
- 没有回退开关，容易对依赖当前诊断的项目产生行为变化。

## Approach B: Add a Default-Off Engine Property or UE Setting

做法：

- 保持当前默认行为，通过 AngelScript engine property、UE 项目设置或二者之间的明确桥接，选择性允许 mutable script globals。
- 同时发布显式类型白名单/矩阵；例如首期只评估 primitive 标量，不自动包含对象句柄。

价值：

- 可以保留 fork 的默认安全边界并建立兼容迁移窗口。
- 便于用同一测试矩阵对“关闭时保持旧诊断”和“开启时验证新行为”分别验收。

风险和工作量：

- 必须决定设置生效时点；编译开始后改变开关可能导致 module 行为不一致。
- engine property 与 UE 配置需要唯一真源、序列化和编辑器重启/重编译语义。
- feature gate 不能替代生命周期设计；开启后的支持边界仍需完整定义。

## Approach C: Implement Full Vanilla-Style Global Support

做法：

- 不只允许 primitive 写入，同时审计并补齐值类型、对象/句柄、引用、初始化/析构、bytecode、调试、StaticJIT 和热重载语义。

价值：

- 与 vanilla AngelScript 的能力模型最接近。
- 可减少 fork 在语言层面的特殊规则。

风险和工作量：

- 是跨编译器、运行时和 Unreal integration 的完整功能项目，不是单点 backport。
- UObject/脚本 class 生命周期、GC、reinstancing、多 World ownership 和失败回滚是高风险面。
- 即使实现正确，engine/module 级共享状态仍可能不符合 gameplay 状态的预期 scope。

## Approach D: Keep Script Globals Read-Only and Use UE-Scoped State

做法：

- 保留 const-only 语言策略。
- 通过 `UEngineSubsystem`、`UWorldSubsystem` 或 `UGameInstanceSubsystem` 暴露可变状态，根据需求明确 ownership 和生命周期。

价值：

- 状态 scope 与 Unreal 生命周期直接对应。
- 可以利用 UObject/UPROPERTY、GC、复制、测试 fixture 和编辑器重建等既有机制。

风险和工作量：

- 语法不如裸全局变量简洁，调用方需要取得正确上下文。
- 并非所有数据都天然适合 UObject/subsystem，纯算法或模块缓存可能显得过重。
- 如果用户明确需要 vanilla 语言兼容，这一方向不能满足语法兼容目标。

# Future Decision and Acceptance Gates

任何后续 feature OpenSpec 至少应回答并验证以下事项：

| 决策面 | 必须形成的明确结论 |
|---|---|
| 目标用例 | mutable globals 用于常量缓存、工具状态、gameplay 状态，还是 vanilla 兼容 |
| 默认策略 | 无条件启用、默认关闭 gate，或继续禁止 |
| 类型边界 | 首批精确支持哪些 primitive/enum/value/object/container 类型 |
| 状态 scope | engine、module、World、GameInstance、PIE instance 和网络角色之间如何共享或隔离 |
| 初始化 | module 顺序、跨 module 引用、初始化异常及失败回滚 |
| 销毁 | 对象/容器析构、GC/引用计数和 engine shutdown 顺序 |
| 热重载 | 总是重置、按条件迁移，或禁止特定类型；类型变化和变量删除如何处理 |
| 后端一致性 | interpreter、StaticJIT、预编译/restore 的相同行为与诊断 |
| 调试体验 | globals 可见性、只读查看或写入能力，以及重载后的地址有效性 |
| 兼容性 | gate 关闭时旧诊断和现有负向测试保持不变 |
| 文档与替代方案 | 明示状态 scope，并说明何时应选择 UE Subsystem |

未来最低验证矩阵应覆盖：

- 声明、初始化、赋值、复合赋值、函数内读写和多次调用后的持久性；
- module reset、失败编译回滚、engine shutdown；
- 热重载后重置或迁移的既定语义；
- 两个 PIE/World/GameInstance 场景的隔离或共享契约；
- interpreter 与 StaticJIT 等价结果；
- 预编译数据保存/加载后的全局地址重定位；
- 支持类型的构造、析构、引用和 GC；
- gate 关闭时的诊断兼容；
- Debug Server 对 globals 的既定观察/修改行为。

# Risks / Trade-offs

- **共享状态污染**：module 级变量容易造成测试顺序依赖和 PIE/多 World 串扰。
- **热重载状态丢失或悬空**：仅重定位 bytecode 地址不等于迁移当前值；对象状态尤其危险。
- **类型生命周期扩大**：从 primitive 扩到对象、容器和委托会引入 GC、引用计数、析构及异常回滚问题。
- **跨模块初始化不确定性**：现有编译器已经防守部分未初始化依赖；新功能不能绕过该边界。
- **后端漂移**：解释器可用不代表 StaticJIT、预编译 restore 和 Debug Server 具有相同语义。
- **网络误解**：全局变量不会自动复制，也不天然区分 authority/client；公开功能需要避免暗示 replication。
- **兼容性成本**：移除旧诊断会使过去明确失败的脚本开始编译，并改变既有负向测试及项目编码约束。
- **feature gate 的复杂度**：默认关闭能控制迁移，但会增加配置时点、缓存和 module 一致性要求。

# Migration

本 change 不改变运行时行为，因此没有代码或资产迁移。

如果后续决定实现：

1. 新建独立 feature OpenSpec，引用本研究记录并明确选择的 approach。
2. 先锁定目标用例、默认策略和首批类型矩阵。
3. 用负向/正向自动化测试定义 gate、生命周期和热重载契约，再修改实现。
4. 对每个新增类型类别逐步扩展覆盖，不把对象句柄支持隐含在“允许 mutable”之中。
5. 同步更新 fork strategy、SDK difference 文档和脚本作者指南。

不需要为本研究 change 执行 `openspec archive`；它应保持可引用状态，直到后续决策明确。

# OpenSpec Validation Boundary

当前项目仅安装 `spec-driven` schema；该 schema 的 `openspec validate` 要求每个 change 至少包含一个 capability delta。由于本 change 明确不批准行为或 capability 变化，`specs/` 被有意省略。因此：

- `proposal.md`、`design.md` 和 `tasks.md` 可以被 artifact status 正常识别；
- change 会保持 `specs` 为 `ready`、整体 `isComplete: false`；
- strict validation 会报告 `No deltas found`；
- 该结果是 research-only 记录与当前 CLI schema 之间的已知表达边界，不应通过虚构运行时 requirement 来消除。

如果后续 feature OpenSpec 选择了具体路线，它应包含真实 capability delta 并通过 strict validation。本研究记录本身只要求 Markdown、范围和证据一致性检查通过。

# Open Questions

- 首要需求究竟是 vanilla 语言兼容，还是某个具体的 Unreal gameplay/tooling 状态用例？
- 如果允许，首期是否只考虑 primitive 标量；enum 和非句柄值类型应如何分阶段？
- 是否需要兼容旧项目的默认关闭 gate？gate 属于 AngelScript engine property、UE project setting，还是两层映射？
- mutable script global 的正式 scope 是否接受 engine/module 级共享？如果不接受，裸 global 是否仍是正确抽象？
- 热重载应明确重置还是尝试迁移？迁移是否只允许 trivially copyable 类型？
- 对初始化函数失败、编译失败和 module 替换失败，旧状态是否保留、销毁还是回滚？
- Debug Server 只需查看 mutable globals，还是必须支持安全写入？
- 对网络游戏，是否需要额外诊断或文档阻止用户误认为状态会 replication？

# Decision Status

本研究确认 mutable script globals 在当前 fork 中“技术上存在基础可行性”，同时确认它不是一个只需删除诊断的封闭改动。四类候选方向均保持开放；本 change 不批准、不推荐也不实施任何路线。
