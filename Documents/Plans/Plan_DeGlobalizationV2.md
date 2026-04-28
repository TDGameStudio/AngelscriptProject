# Angelscript 去全局化 V2 — 引擎状态本地化

## 背景与目标

### 背景

去全局化工作已经历三个阶段：

1. **技术债 Phase 5**（已归档于 `Archives/Plan_TechnicalDebt.md`）— 完成低风险 containment：DebugServer 收口为 owner engine 注入、测试 helper 统一 scoped wrapper。
2. **`Plan_TestEngineIsolation.md` Phase 1**（已完成，2026-04-04）— `GAngelscriptEngine` 全局指针彻底移除、`FAngelscriptEngineContextStack` + `FAngelscriptEngineScope` RAII scope 落地、`FAngelscriptEngine` 转为 `USTRUCT()` + `UPROPERTY()` GC 追踪、测试统一使用 `FAngelscriptEngineScope`。
3. **TypeDatabase / BindState / ToString / BindDatabase 按 isolation key 分桶**（已完成）— 显著降低测试互相污染，但仍不是最终的 engine-instance 本地化形态。

对比 Hazelight 参考（`K:\UnrealEngine\UEAS\Engine\Plugins\Angelscript\`），当前项目在 `GAngelscriptEngine` 移除和 ContextStack 架构方面已**领先** Hazelight。但两边仍共有大量全局状态：

- ~10 个 `FAngelscriptEngine` 类静态 `bool` 标志
- 5 大核心单例（TypeDatabase / BindState / ToStringHelper / BindDatabase / CurrentWorldContext）
- 构造与蓝图事件全局状态（`GCurrentCall` / `GStoredCall` / `GConstructASObjectWithoutDefaults` / `CurrentObjectInitializers` 等）
- `thread_local` 上下文保护（合理设计，不需消除）
- 文档 / FName 缓存（实质只读，优先级最低）

旧的 `Plan_FullDeGlobalization.md` 在 `GAngelscriptEngine` 尚存时编写，三个 Phase 全部未开始且粒度偏粗；`Plan_TestEngineIsolation.md` 的 Phase 2-4 是实际剩余工作但嵌在一份已高度膨胀的历史记录文档中。本计划合并两者，给出干净的后续执行路径。

### 目标

1. 将 `FAngelscriptEngine` 的 ~10 个进程级静态标志迁移为引擎实例成员，使不同引擎实例拥有独立的运行时配置。
2. 将 5 大核心单例从进程级静态存储迁移为引擎实例成员，使每个引擎拥有完整独立的类型/绑定/上下文空间。
3. 移除单 Full Epoch 限制，允许多个 Full 引擎并存。
4. 清理构造/蓝图事件全局状态，收口为调用链上下文传递。
5. 标准化测试框架入口，归档旧计划。

最终状态：多个 Full 引擎可同时存活且互不干扰，测试引擎与生产引擎完全隔离。

### 与其他计划的关系

- **替代** `Plan_FullDeGlobalization.md`（待归档）和 `Plan_TestEngineIsolation.md` Phase 2-4（执行内容合入本计划）。
- `Plan_TestEngineIsolation.md` Phase 1 部分保留为历史参考文档，不再承载后续执行任务。
- `Archives/Plan_TechnicalDebt.md` Phase 5 的 containment 是本计划的起点。
- `Plan_PluginEngineeringHardening.md` 中 325 处全局依赖修复由本计划承接。

### 非目标

- `thread_local` 容器保护（`GArraysBeingIterated`、`GMapsBeingIterated` 等 ~7 个）— 这是合理的迭代器安全机制，不需消除。
- ~50+ 个 `static FName PP_NAME_*` 预处理器名称常量 — 实质只读，不构成状态污染。
- 文档缓存（`UnrealDocumentation` 等 4 个 TMap）— 进程生命期只写缓存，无隔离必要。
- RuntimeModule 委托单例（14 个 `GetPreCompile()` 等）— 进程级扩展点，设计意图为全局回调。
- ThirdParty AS 引擎内部全局变量 — 属于第三方代码，不在本计划范围。

## 当前事实状态快照（2026-04-28）

| 状态类别 | 数量 | 代表项 | 当前归属 |
|----------|------|--------|----------|
| **已消除** | 1 | `GAngelscriptEngine` 全局指针 | Phase 1 已完成 |
| **已收口** | ~25 处 | 测试 helper scope、DebugServer owner 注入 | 技术债 P5 已归档 |
| **已分桶** | 4 | TypeDatabase / BindState / ToString / BindDatabase | isolation key 分桶，非最终形态 |
| 静态 bool 标志 | ~10 | `bGeneratePrecompiledData`、`bIsHotReloading` 等 | `FAngelscriptEngine` 类静态成员 |
| 核心单例 | 5 | TypeDatabase、BindState、ToStringHelper、BindDatabase、CurrentWorldContext | Meyers 单例 / static 成员 |
| 构造/事件全局 | ~6 | `GCurrentCall`、`GStoredCall`、`GConstructASObjectWithoutDefaults`、`CurrentObjectInitializers`、`OverrideConstructingObject`、`GASDefaultConstructorOuter` | 文件作用域 static / extern |
| 调试/杂项全局 | ~4 | `GDebugBreaksEnabled`、`GEndPlayMapCount`、`GAngelscriptNullObject`、`GAngelscriptRecompileAvoidance` | 文件作用域 static |
| thread_local | ~7 | `GAngelscriptContextPool`、`GArraysBeingIterated` 等 | **非目标** |
| FName 缓存 | ~55 | `PP_NAME_*`、`NAME_ReplicatedUsing` 等 | **非目标** |

引擎解析路径：`FAngelscriptEngineContextStack::Peek()` → `UAngelscriptGameInstanceSubsystem::GetCurrent()` → `nullptr`（无 global fallback）。

## 分阶段执行计划

---

### Phase 1：静态标志迁移

> 目标：将 `FAngelscriptEngine` 的 ~10 个 `static bool` / `static TArray` 标志迁移为引擎实例成员。这是全局状态中最简单、影响面最窄的一类，适合作为 engine-local 迁移的首批实践。

- [ ] **P1.1** 审查并分类所有静态标志的读写点
  - 当前 `FAngelscriptEngine` 头文件中约 10 个静态成员标志（`bGeneratePrecompiledData`、`bStaticJITTranspiledCodeLoaded`、`bUseScriptNameForBlueprintLibraryNamespaces`、`BlueprintLibraryNamespacePrefixesToStrip`、`BlueprintLibraryNamespaceSuffixesToStrip`、`StaticNames`、`StaticNamesByIndex`、`GameThreadTLD`），以及 `.cpp` 文件中的 `GAngelscriptRecompileAvoidance`、`GAngelscriptLineReentry`
  - 逐一搜索每个标志在绑定层、编译器、JIT、测试代码中的所有读写点
  - 对每个标志分类为 **实例标志**（应随引擎而异，如 `bGeneratePrecompiledData`、namespace 配置）或 **进程标志**（所有引擎共享，如 `bStaticJITTranspiledCodeLoaded`、`GameThreadTLD`）
  - 产出分类清单文档，在 `Documents/Guides/GlobalStateContainmentMatrix.md` 中追加"静态标志分类"章节
- [ ] **P1.1** 📦 Git 提交：`[Docs/DeGlobal] Docs: classify static flags into instance vs process scope`

- [ ] **P1.2** 将实例标志移入 `FAngelscriptEngine` 实例
  - 根据 P1.1 分类，将"实例标志"类 `static` 成员改为 `FAngelscriptEngine` 的普通成员变量
  - 读写点通过 `FAngelscriptEngine::Get().MemberName` 或 `FAngelscriptEngineContextStack::Peek()->MemberName` 访问
  - 绑定层中无法方便获取引擎实例的位置，通过 `FAngelscriptEngineContextStack::Peek()` 获取当前上下文引擎
  - 保留旧 `static` 声明为 deprecated wrapper（转发到 `Peek()->Member`），在 Phase 5 统一移除
- [ ] **P1.2** 📦 Git 提交：`[Runtime/DeGlobal] Refactor: migrate instance-scoped static flags to engine members`

- [ ] **P1.3** 静态标志迁移回归测试
  - 在 `AngelscriptEngineIsolationTests.cpp` 中新增：两个引擎实例的实例标志互不影响、`FAngelscriptEngineScope` 切换后标志值跟随当前引擎、进程标志在所有引擎间仍共享
  - 构建 + CppTests + 定向回归
- [ ] **P1.3** 📦 Git 提交：`[Test/DeGlobal] Test: verify static flag migration with multi-engine scenarios`

---

### Phase 2：核心单例迁移

> 目标：将 `FAngelscriptTypeDatabase`、`FAngelscriptBinds` 状态、`FToStringHelper`、`FAngelscriptBindDatabase`、`CurrentWorldContext` 从进程级静态单例迁移为引擎实例成员。完成后每个引擎拥有独立的类型和绑定空间。这是去全局化的核心步骤，也是风险最高的阶段。

#### 待迁移单例清单

| 单例 | 引用规模 | 现有清理入口 |
|------|----------|-------------|
| `FAngelscriptTypeDatabase` | 70+ 文件 200+ 处间接访问 | `ResetTypeDatabase()` |
| `FAngelscriptBinds` 静态状态（7 容器 + 2 索引） | 45+ 处直接访问 | `ResetBindState()` |
| `FToStringHelper` 注册表 | 34 个 `Bind_*.cpp` 40+ 处 `Register()` | `FToStringHelper::Reset()` |
| `FAngelscriptBindDatabase` | 15 处引用 | `Clear()` |
| `CurrentWorldContext` (`GAmbientWorldContext`) | `AssignWorldContext` + `FAngelscriptGameThreadScopeWorldContext` | `SetGlobalEngine(nullptr)` 时清空 |

#### 迁移策略

所有单例采用统一的"双路径 + fallback"过渡策略：
1. 在 `FAngelscriptEngine` 中新增对应的实例成员
2. 静态方法内部改为：`ContextStack::Peek()` 非空时用实例成员，否则 fallback 到旧静态单例
3. 每个单例单独迁移、单独提交、单独回归
4. Phase 5 统一清理 fallback 路径

#### 执行任务

- [ ] **P2.1** 迁移 `FAngelscriptTypeDatabase` 为引擎实例成员
  - `FAngelscriptTypeDatabase` 是 `AngelscriptType.cpp` 中的函数内静态单例，被 `FAngelscriptType::GetTypes()`、`Register()`、`GetByAngelscriptTypeName()`、`GetByClass()`、`GetByData()`、`GetByProperty()` 等间接访问（70+ 文件 200+ 处）
  - 在 `FAngelscriptEngine` 中新增 `FAngelscriptTypeDatabase TypeDatabase` 实例成员，在 `Initialize` / `InitializeForTesting` 中填充
  - `FAngelscriptType` 的静态方法内部改为双路径：`Peek()` 非空时用实例 TypeDatabase，否则 fallback 到旧静态单例
  - `ResetTypeDatabase()` 改为引擎实例方法 + 旧静态路径的兼容调用
  - 由于是引用面最广的单例，需特别注意 bootstrapping 路径（引擎创建期间 ContextStack 尚未 push）
- [ ] **P2.1** 📦 Git 提交：`[Runtime/DeGlobal] Refactor: migrate FAngelscriptTypeDatabase to engine instance member`

- [ ] **P2.2** 迁移 `FAngelscriptBinds` 静态状态为引擎实例成员
  - 7 个静态容器（`ClassFuncMaps`、`RuntimeClassDB`、`EditorClassDB`、`BindModuleNames`、`SkipBinds`、`SkipBindNames`、`SkipBindClasses`）+ 2 个静态索引（`PreviouslyBoundFunction`、`PreviouslyBoundGlobalProperty`）
  - 将 9 个静态数据聚合为 `FAngelscriptBindState` 结构，移入 `FAngelscriptEngine` 实例
  - `FAngelscriptBinds` 中的静态方法（`AddFunctionEntry`、`SkipFunctionEntry`、`CheckForSkip` 等）改为通过 ContextStack 路由
  - `ResetBindState()` 改为引擎实例方法
- [ ] **P2.2** 📦 Git 提交：`[Runtime/DeGlobal] Refactor: migrate FAngelscriptBinds state to engine instance member`

- [ ] **P2.3** 迁移 `FToStringHelper` 注册表为引擎实例成员
  - `GetToStringList()` 函数内的 `static TArray<FToStringType>` 被 34 个 `Bind_*.cpp` 中 40+ 处 `Register()` 在 `BindScriptTypes` 时填充
  - 将 `TArray<FToStringType>` 移入 `FAngelscriptEngine` 实例
  - `FToStringHelper::Register()` 和 `Generic_AppendToString()` 改为通过 ContextStack 路由
  - 注意 `Bind_FString.cpp` 中绑定阶段遍历 `GetToStringList()` 生成 `FString` 重载方法的路径
- [ ] **P2.3** 📦 Git 提交：`[Runtime/DeGlobal] Refactor: migrate FToStringHelper to engine instance member`

- [ ] **P2.4** 迁移 `FAngelscriptBindDatabase` 为引擎实例成员
  - 类级 `static FAngelscriptBindDatabase Instance`，持有 cooked game 绑定缓存
  - 影响面最小（15 处引用），可与 P2.2 的 BindState 迁移协同或紧接完成
  - `Save()` / `Load()` / `Clear()` 改为操作引擎实例的 BindDatabase
- [ ] **P2.4** 📦 Git 提交：`[Runtime/DeGlobal] Refactor: migrate FAngelscriptBindDatabase to engine instance member`

- [ ] **P2.5** 迁移 `CurrentWorldContext` 为引擎实例成员
  - `FAngelscriptEngine::CurrentWorldContext` 目前是 `static UObject*`（对应 `GAmbientWorldContext`），所有引擎共享一个 world context 指针
  - 改为 `FAngelscriptEngine` 普通成员变量，每个引擎有独立的 world context
  - `AssignWorldContext` / `FAngelscriptGameThreadScopeWorldContext` 改为操作当前上下文引擎的实例成员
  - Tick 末尾的 `CurrentWorldContext != nullptr` Fatal 检查改为检查实例成员
- [ ] **P2.5** 📦 Git 提交：`[Runtime/DeGlobal] Refactor: migrate CurrentWorldContext to engine instance member`

- [ ] **P2.6** 核心单例迁移回归测试
  - 在 `AngelscriptEngineIsolationTests.cpp` 中新增：
    - 两个独立 Full 引擎各自注册类型，TypeDatabase 互不可见
    - 两个引擎各自 `BindScriptTypes`，BindState 互不影响
    - 两个引擎的 ToStringHelper 注册互不影响
    - 两个引擎各自持有不同的 CurrentWorldContext
    - Clone 引擎与 Source 引擎的 TypeDatabase 共享语义保持不变
  - 全量测试回归，确认无行为变化
- [ ] **P2.6** 📦 Git 提交：`[Test/DeGlobal] Test: verify core singleton migration with multi-engine isolation`

---

### Phase 3：Epoch 解除与构造/事件全局状态收口

> 目标：Phase 2 完成后，单 Full Epoch 限制的根因消除，移除该限制。同时收口构造和蓝图事件路径上仍依赖全局状态的变量。

- [ ] **P3.1** 移除单 Full Epoch 限制
  - 当前 `GAngelscriptActiveOwnedSharedStates > 0` 时拒绝创建新 Full 引擎，因为 TypeDatabase/BindState/ToStringHelper 是进程级单例
  - Phase 2 完成后这些状态已 engine-local，多个 Full 引擎不再争用同一套单例
  - 移除 `CreateTestingFullEngine` / `Initialize` 中的 epoch 检查拒绝逻辑
  - `ReleaseOwnedSharedStateResources` 中的进程级 reset 改为各引擎在自己的 `Shutdown` 中清理实例成员
  - `GAngelscriptActiveOwnedSharedStates` 可保留做诊断计数，不再作为创建阻塞条件
- [ ] **P3.1** 📦 Git 提交：`[Runtime/DeGlobal] Refactor: remove single Full epoch restriction`

- [ ] **P3.2** 审查构造/事件全局状态的调用链
  - 梳理以下全局变量的完整读写链路与生命周期：
    - `GCurrentCall` / `GStoredCall`（`Bind_BlueprintEvent.cpp`）— 蓝图事件调用上下文
    - `GConstructASObjectWithoutDefaults`（`ASClass.cpp`，extern 跨 TU）— 无默认构造标记
    - `CurrentObjectInitializers`（`ASClass.cpp`）— 对象初始化器栈
    - `UASClass::OverrideConstructingObject`（`ASClass.cpp`）— 构造覆盖对象
    - `GASDefaultConstructorOuter`（`ASClass.cpp`，thread_local）— 默认构造外部对象
  - 判断哪些可以改为调用链参数传递，哪些因为 UE 框架回调限制必须保留为全局/TLS
  - 产出分类文档
- [ ] **P3.2** 📦 Git 提交：`[Docs/DeGlobal] Docs: classify construction and event global state callchains`

- [ ] **P3.3** 收口可行的构造/事件全局变量
  - 根据 P3.2 的分类，对"可改为调用链传递"的全局变量执行迁移
  - 对"必须保留为全局/TLS"的变量标注原因，不做强行迁移
  - `GCurrentCall` / `GStoredCall` 如果可行，改为通过 `asCContext` 用户数据或引擎实例成员传递
  - `CurrentObjectInitializers` 如果可行，改为 TLS 或引擎实例内的栈结构
- [ ] **P3.3** 📦 Git 提交：`[Runtime/DeGlobal] Refactor: localize feasible construction and event global state`

- [ ] **P3.4** 构造/事件路径回归测试
  - 覆盖 Actor 构造、Blueprint 事件分发、默认对象初始化等路径
  - 确保 hot-reload 场景下构造状态不串引擎
- [ ] **P3.4** 📦 Git 提交：`[Test/DeGlobal] Test: verify construction and event global state localization`

---

### Phase 4：调试/杂项全局状态收口

> 目标：收口调试和杂项全局变量。这些变量影响面较小但仍是进程级可变状态。

- [ ] **P4.1** 收口调试/杂项全局变量
  - `GDebugBreaksEnabled`（`Bind_Debugging.cpp`）— 判断是否可改为 engine 实例标志或 debug server 实例成员
  - `GEndPlayMapCount`（`Bind_Debugging.cpp`）— 判断是否可改为 world/subsystem 级别
  - `GAngelscriptNullObject`（`Bind_UObject.cpp`）— 判断是否可改为 engine 实例成员或函数内 static const
  - `GScriptEnumTypeLookupByName`（`Bind_UEnum.cpp`）— 枚举类型查找缓存，判断是否随 TypeDatabase 迁入 engine 实例
  - `GScriptNativeForms`（`StaticJITBinds.cpp`）— JIT native form 映射，随 JIT 子系统迁移
  - 对每个变量分类后执行迁移或标注为"合理保留"
- [ ] **P4.1** 📦 Git 提交：`[Runtime/DeGlobal] Refactor: localize debug and miscellaneous global state`

- [ ] **P4.2** 回归测试
  - 构建通过 + CppTests 全通过 + 定向 Debugging/JIT 测试回归
- [ ] **P4.2** 📦 Git 提交：`[Test/DeGlobal] Test: verify debug and misc global state localization`

---

### Phase 5：Legacy 清理与测试框架标准化

> 目标：Phase 1-4 的双路径 fallback 已完成过渡使命，统一清理旧静态路径。标准化测试框架入口。

- [ ] **P5.1** 移除所有 legacy static fallback 路径
  - Phase 1 中 deprecated 的 static wrapper → 删除
  - Phase 2 中各单例静态方法的"ContextStack 为空时 fallback 到旧静态单例"路径 → 审查：
    - 如果 fallback 无调用方，移除 fallback 和旧静态单例
    - 如果 bootstrapping 路径仍需 fallback，保留并标注 `// Required: bootstrapping before any engine exists`
  - 搜索仓库中所有残余的 deprecated 标记并清除
- [ ] **P5.1** 📦 Git 提交：`[Runtime/DeGlobal] Refactor: remove legacy static fallback paths`

- [ ] **P5.2** 实现 `FAngelscriptTestFixture` 标准化测试入口
  - 在 `AngelscriptTestUtilities.h` 中新增 `FAngelscriptTestFixture`，封装三种测试模式：
    - `SharedClone`：使用共享 clone 引擎（默认模式，最轻量）
    - `IsolatedFull`：创建独立 Full 引擎（Phase 3 后不再受 epoch 限制）
    - `ProductionLike`：尝试获取生产引擎，失败时创建 Full
  - Fixture 内部持有 `FAngelscriptEngineScope`，构造时自动建立隔离 scope
  - 提供便捷方法：`GetEngine()`、`BuildModule(Name, Source)`、`ExecuteInt(Function, OutResult)` 等
- [ ] **P5.2** 📦 Git 提交：`[Test/DeGlobal] Feat: add FAngelscriptTestFixture as standardized test entry point`

- [ ] **P5.3** 首批迁移现有测试到 `FAngelscriptTestFixture`
  - 选择 3-5 个高频使用 scope 的测试文件进行迁移：
    - `AngelscriptEngineCoreTests.cpp`：引擎核心测试
    - `AngelscriptBindConfigTests.cpp`：配置测试
    - `AngelscriptDelegateScenarioTests.cpp`：委托测试，涉及 WorldContext
  - 迁移原则：用 `FAngelscriptTestFixture` 替换手动 scope 组合；不改变测试逻辑本身
  - 后续新增测试必须使用 `FAngelscriptTestFixture` 或 `FAngelscriptEngineScope`
- [ ] **P5.3** 📦 Git 提交：`[Test/DeGlobal] Refactor: migrate first batch of tests to FAngelscriptTestFixture`

- [ ] **P5.4** 全量回归与文档更新
  - 全量构建 + 全量测试回归
  - `Documents/Guides/Test.md` 新增"测试引擎隔离"章节
  - `Documents/Guides/GlobalStateContainmentMatrix.md` 更新为最终状态
  - `AGENTS.md` / `AGENTS_ZH.md` 更新架构决策章节
  - 归档 `Plan_FullDeGlobalization.md`（追加归档头：被 `Plan_DeGlobalizationV2.md` 替代）
  - 归档 `Plan_TestEngineIsolation.md`（追加归档头：Phase 1 已完成，Phase 2-4 执行内容合入 V2）
  - 更新 `Plan_OpportunityIndex.md` 状态
- [ ] **P5.4** 📦 Git 提交：`[Docs/DeGlobal] Docs: update architecture docs and archive superseded plans`

---

## 影响范围

### 操作类型定义

本次迁移涉及以下操作（按需组合）：

- **静态成员迁移**：`static Type Member` → `Type Member`（实例成员）+ deprecated wrapper
- **访问路径双路径化**：静态方法内部增加 `ContextStack::Peek()` 检查
- **Fallback 清理**：移除 deprecated wrapper 和旧静态路径
- **测试迁移**：手动 scope 组合 → `FAngelscriptTestFixture`
- **文档更新**：架构文档、指南、计划归档

### 按模块分组的影响文件

**AngelscriptRuntime/Core/（~5 个核心文件）**：
- `AngelscriptEngine.h` / `.cpp` — 静态成员迁移 + 访问路径双路径化 + Fallback 清理
- `AngelscriptType.h` / `.cpp` — TypeDatabase 静态单例迁移
- `AngelscriptBinds.h` / `.cpp` — BindState 静态成员迁移

**AngelscriptRuntime/Binds/（~40 个文件间接影响）**：
- 34 个 `Bind_*.cpp` 含 `FToStringHelper::Register()` — 通过双路径化自动路由，无需逐个修改
- `Bind_FString.cpp` — ToStringHelper 读取路径变更
- `Bind_BlueprintEvent.cpp` — `GCurrentCall` / `GStoredCall` 收口
- `Bind_Debugging.cpp` — `GDebugBreaksEnabled` / `GEndPlayMapCount` 收口
- `Bind_UEnum.cpp` — `GScriptEnumTypeLookupByName` 迁移

**AngelscriptRuntime/ClassGenerator/（~3 个文件）**：
- `ASClass.cpp` — 构造全局变量收口
- `AngelscriptClassGenerator.cpp` — TypeDatabase/BindState 访问路径变更

**AngelscriptRuntime/StaticJIT/（~2 个文件）**：
- `StaticJITBinds.cpp` — `GScriptNativeForms` 迁移
- `AngelscriptStaticJIT.cpp` — JIT Database 访问路径变更

**AngelscriptTest/Shared/（~3 个文件）**：
- `AngelscriptTestUtilities.h` — `FAngelscriptTestFixture` 新增
- `AngelscriptEngineIsolationTests.cpp` — 新增回归测试

**文档（~6 个文件）**：
- `GlobalStateContainmentMatrix.md`、`Test.md`、`AGENTS.md`、`AGENTS_ZH.md`、`Plan_OpportunityIndex.md`、归档文档

## 验收标准

### Phase 1
- 实例标志在不同引擎实例间互相独立
- 进程标志保持全局共享语义
- 所有现有测试行为不变

### Phase 2
- 两个独立 Full 引擎各自拥有独立的 TypeDatabase、BindState、ToStringHelper、CurrentWorldContext
- Clone 引擎与 Source 引擎的共享语义保持不变
- 所有现有测试通过率不低于迁移前

### Phase 3
- 单 Full Epoch 限制已移除，多个 Full 引擎可同时创建
- 可行的构造/事件全局变量已收口为调用链传递或引擎实例成员
- 不可行的全局变量已标注原因

### Phase 4
- 调试/杂项全局变量已分类处理
- 无新增全量测试回归

### Phase 5
- Legacy static fallback 已清理或标注
- `FAngelscriptTestFixture` 可正常工作
- 首批测试已迁移
- 旧计划已归档，文档已更新

## 风险与注意事项

### 风险

1. **Phase 2 TypeDatabase 迁移风险最高**：70+ 文件 200+ 处间接访问，是绑定层核心基础设施。双路径 + fallback 策略可最大化降低一次性破坏面，但 bootstrapping 路径（引擎创建期间 ContextStack 尚未 push）需要特别处理。
   - **缓解**：每个单例单独迁移、单独提交、单独回归。先从引用面最小的 BindDatabase（15 处）开始试水。
2. **Epoch 移除后的多 Full 并存**：原本被拒绝的多 Full 场景变为可用路径，需要确保 Phase 2 的 engine-local 迁移确实覆盖了所有竞争点。
   - **缓解**：Phase 3 P3.1 在 Phase 2 完成后才执行；先补多 Full 并存测试再移除限制。
3. **构造全局状态的 UE 框架限制**：部分构造回调（`UObject::PostInitProperties`、`FObjectInitializer`）由 UE 框架驱动，参数签名不可变，可能无法完全消除全局/TLS 依赖。
   - **缓解**：P3.2 先审查再执行，接受部分变量保留为全局/TLS。

### 已知行为变化

1. **`FAngelscriptType::GetByXxx` 解析行为变化**：Phase 2 后，无 ContextStack scope 时 fallback 到旧静态单例（过渡期）；Phase 5 后 fallback 移除，无 scope 时可能返回空结果或 assert。
   - 影响范围：所有在 `FAngelscriptEngineScope` 外部调用 `GetByXxx` 的代码路径（应在 Phase 5 前全部审查）
2. **与 Hazelight 合入代码的适配**：Phase 2 完成后，TypeDatabase/BindState/ToStringHelper 的访问模式与 Hazelight 原版显著不同。从 Hazelight 合入代码时需要额外注意这些路径。
