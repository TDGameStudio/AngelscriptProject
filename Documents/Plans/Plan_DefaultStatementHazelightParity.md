# `default` 语句与 Hazelight 引擎能力对齐计划

## 背景与目标

通过对照分析（详见 `Documents/Knowledges/ZH/Diff_HazelightDefaultStatement.md` 与 `Documents/Knowledges/ZH/Diff_HazelightInsightsToBorrow.md`），当前项目（`Plugins/Angelscript/`）在 `default` 语句的核心实现上与 Hazelight 引擎方案**完全一致**，但存在四类差异：

1. **架构性差异**（`AngelscriptPropertyFlags` 字段、`FAngelscriptManager`/`FAngelscriptEngine` 拆分）：受"独立插件不能改 UE 引擎核心"约束，无法直接平移
2. **设计改进差异**（`__WorldContext` 函数化、`CallableWithoutWorldContext` 新 meta）：当前项目主动改进，不回滚
3. **AS 编译期安全能力缺失**（AS 内核 `unsafe_during_construction` + `defaults` 两个 trait、`APF_RuntimeGenerated` / `APF_WorldContext` 缺失）：已补足 / 已走插件化替代
4. **UE Meta → AS 修饰符桥接缺失**（`ScriptAllowTemporaryThis` UE Meta → `accept_temporary_this` AS 修饰符的自动追加逻辑缺失，AS Token 已存在）：已补足

**目标**：
1. 评估并补足 AS 内核的两个 default 安全 trait（`unsafe_during_construction` / `defaults`），让 `default` 语句与构造函数中的危险 API 调用能在编译期被拦截
2. 补足 `ScriptAllowTemporaryThis` UE Meta 到 AS `accept_temporary_this` 修饰符的自动桥接，让 UFUNCTION 端能与 Hazelight 一致地启用该修饰符
3. 调研 `AngelscriptPropertyFlags` 在独立插件场景的可行替代方案，恢复运行时生成参数与 WorldContext 参数的快速识别能力
4. 将以上差异分析与处理决策正式归档，作为后续 AS 2.38 backport 与"插件化 vs 引擎集成"权衡的参考输入

## 范围与边界

### 在范围内

- 在 `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/` 中按需 backport `unsafe_during_construction` / `defaults` 相关代码（4 处源文件）
- 在 `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/` 中追加针对新 trait 的标记机制（如有必要）
- 在 `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Helper_FunctionSignature.h` 中补足 `ScriptAllowTemporaryThis` UE Meta → `accept_temporary_this` 修饰符的自动追加逻辑
- 调研并实现 `APF_RuntimeGenerated` / `APF_WorldContext` 的非侵入式替代（UProperty meta、外挂 TMap、运行时缓存等）
- 编写覆盖新行为的回归测试

### 不在范围内

- 修改 UE 引擎核心（`Engine/Source/Runtime/CoreUObject/`）以加入 `AngelscriptPropertyFlags` 字段——这违反"独立插件"目标
- 把 `__WorldContext` 从函数形式回滚到 Hazelight 的全局变量形式
- 把 `FAngelscriptEngine` 拆分回 `FAngelscriptManager` + `FAngelscriptEngine` 两层
- AS 2.38 的其他 backport（由 `Plan_AS238*.md` 系列覆盖）

## 前置条件

- `AgentConfig.ini` 中 `References.HazelightAngelscriptEngineRoot` 指向有效的 Hazelight 引擎源码（默认 `K:\UnrealEngine\UEAS`）
- `Reference/angelscript-v2.38.0/` 已通过 `Tools\PullReference\PullReference.bat angelscript` 拉取
- 已熟悉 `Documents/Knowledges/ZH/Syntax_DefaultStatement.md` 中描述的 default 实现两路径（路径 ① 属性 default → `__InitDefaults`；路径 ② 函数参数 default → `defaultArgs[]`）

## 分阶段执行计划

### Phase 0 — 上游一致性扫描

> 目标：判断 `unsafe_during_construction` / `defaults` 两个 trait 是 Hazelight 私有扩展还是已被 AS 上游接收，决定 backport 策略。

- [ ] **P0.1** 扫描 `Reference/angelscript-v2.38.0/sdk/angelscript/source/` 中是否存在以下符号
  - `UNSAFE_DURING_CONSTRUCTION_TOKEN` 与 `asTRAIT_UNSAFE_DURING_CONSTRUCTION`
  - `DEFAULTS_TOKEN` 与 `asTRAIT_DEFAULTS_ONLY`
  - 检查 `as_tokendef.h` / `as_parser.cpp` / `as_builder.cpp` / `as_compiler.cpp` / `as_scriptfunction.h`
  - 输出扫描结果到本计划下方"决策记录"
- [ ] **P0.1** 📦 Git 提交：`[Docs] Plans: record AS 2.38 upstream scan for default safety traits`

- [ ] **P0.2** 根据扫描结果选择 backport 路径
  - 情况 A：上游已合并 → 走 AS 2.38 cherry-pick 流程，与 `Plan_AS238BugfixCherryPick.md` 协调
  - 情况 B：仅 Hazelight 私有 → 走纯 Hazelight 移植，不涉及上游基线
  - 在本计划中明确选定路径，并标注涉及的源文件与行号差异
- [ ] **P0.2** 📦 Git 提交：`[Docs] Plans: choose default safety trait backport path`

### Phase 1 — `unsafe_during_construction` + `defaults` Trait Backport

> 目标：让用户在 `default` 语句或构造函数中调用 Hazelight 标记为不安全的 API 时，AS 编译器能在编译期报错。

- [ ] **P1.1** 移植 token 与 trait 定义
  - 在 `as_tokendef.h` 末尾添加：
    - `const char * const UNSAFE_DURING_CONSTRUCTION_TOKEN = "unsafe_during_construction";`
    - `const char * const DEFAULTS_TOKEN = "defaults";`
  - 在 `as_scriptfunction.h` 中添加：
    - `asTRAIT_UNSAFE_DURING_CONSTRUCTION = 0x2000000`
    - `asTRAIT_DEFAULTS_ONLY = 0x4000000`
  - 注意检查现有 trait bit 是否已占用 `0x1000000` / `0x4000000`，避免冲突
- [ ] **P1.1** 📦 Git 提交：`[ThirdParty/angelscript] Feat: define unsafe_during_construction and defaults tokens/traits`

- [ ] **P1.2** 移植 parser 识别
  - 在 `as_parser.cpp` 的两个相关位置（约 `IdentifierIs(t1, ...)` 列表）追加新 token 识别
  - 验证 `.as` 脚本中能写出形如 `void DangerousFunc() unsafe_during_construction { ... }` 而 parser 不报语法错误
- [ ] **P1.2** 📦 Git 提交：`[ThirdParty/angelscript] Feat: parse unsafe_during_construction / defaults modifiers`

- [ ] **P1.3** 移植 builder 标记 trait
  - 在 `as_builder.cpp` 函数声明 decorator 处理处追加 trait 设置（参考 Hazelight 行号 `1478-1481` / `4706-4709`）
  - 确认对脚本声明、注册声明、模板函数三种路径都生效
- [ ] **P1.3** 📦 Git 提交：`[ThirdParty/angelscript] Feat: builder applies unsafe_during_construction / defaults traits`

- [ ] **P1.4** 移植 compiler 调用点检查
  - 在 `as_compiler.cpp` 函数调用编译处追加：
    ```cpp
    if ((m_isInitDefaults || ((m_isConstructor || m_isDefaultConstructor)
            && (outFunc->objectType->GetFlags() & asOBJ_REF)))
        && descr->traits.GetTrait(asTRAIT_UNSAFE_DURING_CONSTRUCTION))
    {
        asCString msg;
        msg.Format("Function %s is unsafe during construction and cannot be called from defaults",
            descr->name.AddressOf());
        Error(msg, ctx->exprNode);
    }
    ```
  - 同时为 `asTRAIT_DEFAULTS_ONLY` 添加反向检查（**仅在** `default` 上下文允许）
  - 注意当前项目的 `m_isInitDefaults` / `m_isConstructor` / `m_isDefaultConstructor` 标志已存在（已在 Syntax_DefaultStatement §1.4 描述）
- [ ] **P1.4** 📦 Git 提交：`[ThirdParty/angelscript] Feat: compiler enforces unsafe_during_construction / defaults_only checks`

- [ ] **P1.5** 在工厂函数注册时打 trait（参考 Hazelight `as_builder.cpp:4198/4203`）
  - 类工厂函数自动加 `asTRAIT_UNSAFE_DURING_CONSTRUCTION`
  - 评估当前项目类工厂注册路径，决定相同 trait 标记的注入位置
- [ ] **P1.5** 📦 Git 提交：`[ThirdParty/angelscript] Feat: mark factory functions as unsafe during construction`

- [ ] **P1.6** 编写编译期错误回归测试
  - 在 `Plugins/Angelscript/Source/AngelscriptTest/` 下新增测试 `default_UnsafeDuringConstruction_Test.cpp`
  - 用例 1：在 `default` 语句中调用标记 `unsafe_during_construction` 的函数 → 期待编译错误，包含 `cannot be called from defaults`
  - 用例 2：在构造函数中调用同函数 → 期待相同错误（仅 ref 类型）
  - 用例 3：在普通函数中调用同函数 → 期待编译通过
  - 用例 4：`defaults`-only 函数在 default 之外调用 → 期待编译错误
- [ ] **P1.6** 📦 Git 提交：`[Test/Angelscript] Test: add unsafe_during_construction / defaults_only compile-time error coverage`

- [ ] **P1.7** 文档同步
  - 在 `Documents/Knowledges/ZH/Syntax_DefaultStatement.md` 中更新 §一相关内容（编译期错误诊断点新增条目）
  - 在 `Documents/Knowledges/ZH/Diff_HazelightDefaultStatement.md` 中将差异 ③ 状态从"建议补足"改为"已对齐"
  - 在 `Documents/Plans/Plan_StatusPriorityRoadmap.md` 中登记本阶段完成
- [ ] **P1.7** 📦 Git 提交：`[Docs] Docs: sync default safety trait completion status`

### Phase 1.5 — UE Meta → AS 修饰符桥接补足

> 目标：补足 `ScriptAllowTemporaryThis` 这一 UE Meta 到 AS 修饰符的自动桥接，让 UFUNCTION 端写法与 Hazelight 一致。
>
> 背景：当前项目 AS 内核解析器**已识别** `accept_temporary_this` 修饰符（`as_tokendef.h` 中 `ACCEPT_TEMPORARY_TOKEN` 已存在），但 `Helper_FunctionSignature.h` 中**没有读取 UE Meta 并自动追加该修饰符到 Declaration 的逻辑**。Hazelight 在 `Helper_FunctionSignature.h:350` 有 3 行桥接代码，当前项目缺失这部分。

- [ ] **P1.5.1** 在 `Helper_FunctionSignature.h` 顶部已有的 `static const FName NAME_*` 列表中新增（若尚未声明）
  - `static const FName NAME_ScriptAllowTemporaryThis("ScriptAllowTemporaryThis");`
  - 注意确认是否需要包在 `#if WITH_EDITOR` 中（参考 Hazelight 行号 `34`）
- [ ] **P1.5.1** 📦 Git 提交：`[Plugin/Angelscript] Refactor: declare NAME_ScriptAllowTemporaryThis meta key`

- [ ] **P1.5.2** 在 `Helper_FunctionSignature.h` 中追加 `accept_temporary_this` 自动追加逻辑
  - 位置：紧接 `no_discard` / `allow_discard` 追加块之后（参考 Hazelight 行号 `350-351`）
  - 修改示例：
    ```cpp
    // 在 no_discard / allow_discard 追加之后
    if (Function->HasMetaData(NAME_ScriptAllowTemporaryThis))
        Declaration += TEXT(" accept_temporary_this");
    ```
  - 注意当前项目 `Helper_FunctionSignature.h` 中此处的 ReturnType 包裹结构与 Hazelight 略有不同（已在 Syntax_DefaultStatement §7.13 描述过 `if (ReturnType.IsValid())` 包裹），需要决定 `accept_temporary_this` 应在 `ReturnType.IsValid()` 块内还是块外（Hazelight 是块外）
- [ ] **P1.5.2** 📦 Git 提交：`[Plugin/Angelscript] Feat: bridge ScriptAllowTemporaryThis meta to accept_temporary_this modifier`

- [ ] **P1.5.3** 编写桥接生效回归测试
  - 在 `Plugins/Angelscript/Source/AngelscriptTest/` 下新增测试 `Bind_AcceptTemporaryThis_Test.cpp`（或归入既有 Bindings 测试簇）
  - 用例 1：定义带 `meta = (ScriptAllowTemporaryThis)` 的 C++ UFUNCTION，验证 AS 端可以在临时对象上调用该方法编译通过
  - 用例 2：未带该 meta 的对照 UFUNCTION，验证 AS 端在临时对象上调用应当编译失败（行为与改造前相同）
  - 用例 3：在 Bind_FString 等已用字面量声明 `accept_temporary_this` 的位置抽样验证不受影响（向后兼容）
- [ ] **P1.5.3** 📦 Git 提交：`[Test/Angelscript] Test: cover ScriptAllowTemporaryThis meta bridge`

- [ ] **P1.5.4** 文档同步
  - 在 `Documents/Knowledges/ZH/Syntax_DefaultStatement.md` §7.13 中移除"`accept_temporary_this` 不通过 UFunction meta 自动追加"的描述，改为"已通过 `ScriptAllowTemporaryThis` Meta 自动桥接"
  - 在 `Documents/Knowledges/ZH/Diff_HazelightInsightsToBorrow.md` §二.3 中将状态从"❌ 缺失自动追加"改为"已对齐"
  - 在 `Documents/Knowledges/ZH/Diff_HazelightDefaultStatement.md` 关联章节同步更新
- [ ] **P1.5.4** 📦 Git 提交：`[Docs] Docs: sync ScriptAllowTemporaryThis bridge completion status`

### Phase 2 — `AngelscriptPropertyFlags` 替代方案调研与实现

> 目标：在不修改 UE 引擎核心的前提下，恢复 `APF_RuntimeGenerated` / `APF_WorldContext` 提供的快速识别能力。

- [ ] **P2.1** 调研可选方案，列出优劣
  - 方案 A：UProperty meta（如 `RuntimeGenerated="true"` / `WorldContextParam="true"`）
    - 优点：完全不动引擎核心；与现有 `CPP_Default_*` meta 同机制
    - 缺点：每次查询 `Function->GetMetaData(...)` 有 FName 哈希查询开销，热路径敏感
  - 方案 B：sidecar TMap<FProperty*, EFlags>，在 `AngelscriptClassGenerator` 模块内维护
    - 优点：O(1) 查询，无引擎依赖
    - 缺点：需要在所有 FProperty 销毁路径上维护 TMap 同步；跨模块共享需要额外暴露 API
  - 方案 C：复用现有 UE FProperty 标志位（`CPF_RuntimeGenerated` 等）
    - 优点：UE 5.7 可能已有近似标志可借用
    - 缺点：需先扫描 UE 5.7 `CPF_*` 全集，可能无完美对应
  - 方案 D：完全去除该机制，重写所有依赖快速识别的调用点
    - 优点：零运行时开销
    - 缺点：工作量最大，可能影响热路径性能
- [ ] **P2.1** 📦 Git 提交：`[Docs] Plans: enumerate AngelscriptPropertyFlags replacement options`

- [ ] **P2.2** 评估当前项目对 `APF_RuntimeGenerated` / `APF_WorldContext` 的实际依赖范围
  - 全文搜索 Hazelight 源码中所有 `APF_RuntimeGenerated` / `APF_WorldContext` 使用点
  - 列出每个使用点的语义和热度（启动期 / 热路径 / 编辑器专用）
  - 对应到当前项目相同位置，标注需要补能力的源文件清单
- [ ] **P2.2** 📦 Git 提交：`[Docs] Plans: map AngelscriptPropertyFlags consumers to current project`

- [ ] **P2.3** 选定最终方案并撰写设计稿
  - 依据 P2.1/P2.2 输出选定方案
  - 在本计划下方"决策记录"明确选择理由
  - 输出实施细化方案，列出新增/修改源文件清单
- [ ] **P2.3** 📦 Git 提交：`[Docs] Plans: finalize AngelscriptPropertyFlags replacement design`

- [ ] **P2.4** 实施替代方案
  - 按 P2.3 设计稿改造 `AngelscriptClassGenerator.cpp` `AddFunctionArgument`
  - 同步改造所有依赖快速识别的调用点
  - 注意保留性能（避免在热路径上加 FName 哈希查询）
- [ ] **P2.4** 📦 Git 提交：`[Plugin/Angelscript] Feat: implement non-invasive AngelscriptPropertyFlags replacement`

- [ ] **P2.5** 性能与功能回归测试
  - 添加单元测试覆盖：判断 FProperty 是 AS 运行时生成、判断 FProperty 是 WorldContext 参数
  - 跑一轮完整 `Tools\RunTests.ps1 -Group AngelscriptSmoke` 确认无回归
  - 可选：用 `unrealinsights` 或 `Stat` 命令对比改造前后的关键路径耗时
- [ ] **P2.5** 📦 Git 提交：`[Test/Angelscript] Test: cover replacement flag mechanism`

- [ ] **P2.6** 文档同步
  - 在 `Documents/Knowledges/ZH/Diff_HazelightDefaultStatement.md` 中将差异 ② 状态从"走替代方案"改为具体方案描述
  - 在 `Documents/Knowledges/ZH/Syntax_DefaultStatement.md` 中追加新机制说明
- [ ] **P2.6** 📦 Git 提交：`[Docs] Docs: sync AngelscriptPropertyFlags replacement design`

### Phase 3 — 不追平差异的归档

> 目标：把"主动选择不追平"的设计决策正式归档，避免后续被误判为"漏洞"。

- [ ] **P3.1** 在 `Documents/Knowledges/ZH/Diff_HazelightDefaultStatement.md` §四 决策汇总表中确认所有"不追平"项有清晰理由
- [ ] **P3.1** 📦 Git 提交：`[Docs] Docs: confirm "not pursuing" diff decisions`

- [ ] **P3.2** 在 `AGENTS.md` 或 `AGENTS_ZH.md` 中加入指向 `Diff_HazelightDefaultStatement.md` 的索引
  - 帮助后续 AI 代理与新成员快速找到差异分析
- [ ] **P3.2** 📦 Git 提交：`[Docs] Docs: link Hazelight diff analysis from agents guide`

## 风险与依赖

### 风险

- **AS 内核 backport 引入回归**：修改 `as_compiler.cpp` 调用编译路径有破坏现有脚本的风险——必须有完整 P1.6 测试覆盖才允许提交
- **trait bit 冲突**：Hazelight 的 `asTRAIT_UNSAFE_DURING_CONSTRUCTION = 0x1000000` 与当前 fork 的 `asTRAIT_EXPLICIT` 冲突；当前实现改用空闲 bit `0x2000000`，`asTRAIT_DEFAULTS_ONLY` 使用 `0x4000000`
- **替代方案性能回退**：方案 A（UProperty meta）在热路径上可能引入 FName 哈希开销——P2.5 必须做性能验证
- **Hazelight 引擎更新**：本计划基于当前快照（`HazelightAngelscriptEngineRoot` 指向版本），Hazelight 后续可能有新增差异——建议每季度重跑差异扫描

### 依赖

- 不依赖任何其他正在进行的 Plan
- 与 `Plan_AS238BugfixCherryPick.md` 在 `as_compiler.cpp` 修改上可能有冲突——建议先完成本计划再做 AS 2.38 cherry-pick
- 与 `Plan_HazelightCapabilityGap.md` / `Plan_HazelightScriptFeatureParity.md` 在主题上相关，但不重叠（那两个 Plan 关注业务能力 parity，本 Plan 仅聚焦 default 语句）

## 验证标准

完成本计划后应满足：

1. ✅ AS 编译器能在 `default` 语句中调用 `unsafe_during_construction` 函数时给出与 Hazelight 一致的编译错误
2. ✅ 用户可以用 `defaults` 修饰符标记函数限定在 `default` 上下文
3. ✅ 标注 `meta = (ScriptAllowTemporaryThis)` 的 C++ UFUNCTION 在 AS 端能够在临时对象上调用，行为与 Hazelight 一致
4. ✅ 当前项目内部能在 O(1) 时间判断 FProperty 是否为 AS 运行时生成 / 是否为 WorldContext 参数
5. ✅ `Documents/Knowledges/ZH/Diff_HazelightDefaultStatement.md` 与 `Diff_HazelightInsightsToBorrow.md` 中所有差异条目状态明确（已对齐 / 已选替代方案 / 不追平）
6. ✅ 所有现有 AS 测试通过，且新增测试覆盖新机制
7. ✅ `AGENTS.md` 知识库索引指向差异分析文档

## 决策记录

> 本节用于阶段执行过程中累积关键决策，便于回溯。

- [x] P0.2 backport 路径选择：本地 `Reference/angelscript-v2.38.0` 缺失，按 Hazelight 私有扩展路径移植；实现前已对照 `K:\UnrealEngine\UEAS`。
- [x] P1.5.2 `accept_temporary_this` 追加位置决策：放在 `if (ReturnType.IsValid())` 块外，因为它描述 this 调用能力，不依赖返回值。
- [x] P2.3 `AngelscriptPropertyFlags` 替代方案选择：不改 UE Core，不建 sidecar TMap；新增 `IsAngelscriptGenerated(const FProperty*)` / `IsAngelscriptWorldContextProperty(const FProperty*)` 查询 API。

## 关联文档

- 实现原理：`Documents/Knowledges/ZH/Syntax_DefaultStatement.md`
- 差异分析（default 专题）：`Documents/Knowledges/ZH/Diff_HazelightDefaultStatement.md`
- 差异分析（全插件可借鉴汇总）：`Documents/Knowledges/ZH/Diff_HazelightInsightsToBorrow.md`
- AS Fork 策略：`Documents/Guides/AngelscriptForkStrategy.md`
- 上游 backport 协调：`Documents/Plans/Plan_AS238BugfixCherryPick.md`
- 状态登记：`Documents/Plans/Plan_StatusPriorityRoadmap.md`
