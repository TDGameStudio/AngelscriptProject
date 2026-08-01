# Why

当前 fork 在注册脚本声明的全局变量时，要求公开变量必须是 `const`，同时拒绝对象句柄。现有指南将这一差异概括为“防止脚本侧全局状态副作用”，但没有完整记录限制位于哪里、底层运行时是否仍支持写入、热重载与多 World 场景会产生什么语义，以及放开限制需要补齐哪些契约。

在成熟 fork 中直接删除检查会把一个语法限制变成运行时状态模型变更。需要先建立可复核的研究记录，让后续决策基于当前代码证据，而不是把“能编译”误当作“已经具备可交付语义”。

# What Changes

- 记录当前限制、内部下划线逃生口、原生注册全局属性例外及其本地历史来源。
- 对照 vanilla AngelScript 2.38，确认该限制属于当前 Unreal fork 的策略差异，而不是 AngelScript VM 的固有限制。
- 记录编译器、解释器、StaticJIT、预编译数据、模块初始化/析构、调试器和热重载路径中已经存在的能力与尚未定义的语义。
- 区分“代码直接证明的事实”“项目文档给出的维护理由”和“由架构推导出的风险”，避免把推断写成历史事实。
- 中立记录四类候选方向及其决策门槛，不在本 change 中选择实现路线：
  1. 无条件移除前端检查；
  2. 增加默认关闭的引擎属性或 UE 设置，并明确类型支持矩阵；
  3. 补齐 vanilla 风格的对象、引用、生命周期和重载语义；
  4. 保持脚本全局变量只读，改用 UE Engine/World/GameInstance Subsystem 承载可变状态。
- 明确任何行为实现都必须另建 feature OpenSpec；本 change 只形成研究与决策输入。

# Capabilities

## New Capabilities

None. This research-only change does not introduce a runtime capability.

## Modified Capabilities

None. No existing specification or observable behavior is changed.

# Impact

- 仅新增 `openspec/changes/docs-as-mutable-global-feasibility/` 下的研究记录。
- 不修改 AngelScript 编译器、运行时、StaticJIT、热重载、调试器、UE 设置、公开 API 或测试基线。
- 不新增 capability delta，因此不创建 `specs/`。
- 潜在的后续实现可能触及 `as_builder.cpp`、全局变量编译/模块生命周期、StaticJIT、热重载和 AngelScript SDK 测试，但这些文件均不属于本 change 的修改范围。
- 本 change 保持未归档状态，供后续 feature proposal 引用。
