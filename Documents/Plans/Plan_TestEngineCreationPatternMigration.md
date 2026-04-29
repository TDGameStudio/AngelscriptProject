# 测试骨架效率优化：引擎创建模式迁移 + 单 Entry 测试合并

## 背景与目标

当前测试模块中，`ASTEST_CREATE_ENGINE_SHARE_CLEAN()` 已成为经过验证的标准模式（381 处调用），但历史遗留仍有两类低效/不规范的引擎创建方式散布在 ~50 个测试文件中：

1. **`ASTEST_CREATE_ENGINE_FULL()`**（60 处）：每次调用都从零创建一个完整隔离的 `FAngelscriptEngine`，需要完整注册所有类型、绑定和函数库。对于绝大多数"编译脚本 → 执行 → 验证返回值"的纯功能测试来说，这完全没有必要，共享引擎即可满足需求。
2. **`ASTEST_CREATE_ENGINE_SHARE()`**（136 处）：旧版共享引擎模式，不做模块清理。连续测试在同一引擎上不断 `BuildModule`，模块会累积，可能出现模块名冲突或类型注册残留，且与当前 `SHARE_CLEAN` 标准不一致。

已经重构完成的 `Template_GlobalFunctions.cpp` 和 `AngelscriptTArrayBindingsTests.cpp` 是正面范例，均使用 `ASTEST_CREATE_ENGINE_SHARE_CLEAN()` + 对应 `ASTEST_BEGIN/END_SHARE_CLEAN` 生命周期宏。

本计划的目标是把上述两类调用批量迁移到 `SHARE_CLEAN`（或按实际隔离需求选用 `MODULE_CLEAN` / `SHARE_FRESH`），统一测试引擎管理模式，减少不必要的引擎创建开销。

## 范围与边界

- **范围内**
  - `Plugins/Angelscript/Source/AngelscriptTest/` 下所有使用 `ASTEST_CREATE_ENGINE_FULL()` 的 `.cpp` 文件
  - `Plugins/Angelscript/Source/AngelscriptTest/` 下所有使用 `ASTEST_CREATE_ENGINE_SHARE()` 的 `.cpp` 文件
  - 对应的 `ASTEST_BEGIN_FULL` / `ASTEST_END_FULL` → `ASTEST_BEGIN_SHARE_CLEAN` / `ASTEST_END_SHARE_CLEAN` 生命周期宏替换
  - 对应的 `ASTEST_BEGIN_SHARE` / `ASTEST_END_SHARE` → `ASTEST_BEGIN_SHARE_CLEAN` / `ASTEST_END_SHARE_CLEAN` 生命周期宏替换
- **范围外**
  - 不改变测试的业务逻辑和断言内容
  - 不删减或新增测试用例
  - `ASTEST_CREATE_ENGINE_BARE()` 和 `ASTEST_CREATE_ENGINE_NATIVE()` 不在迁移范围（SDK 层有独立语义）
  - `Template_ReflectionAccess.cpp` 中有注释明确说明需要 `IsolatedFull` 以保持 script-defined class 的类型元数据存活——此类有正当理由的 FULL 调用应保留，在 Plan 中标注豁免
- **决策规则**
  - 默认迁移到 `SHARE_CLEAN`
  - 如果测试内部需要跨多个 `BuildModule` 调用但不希望前一个 section 的模块干扰后续 section，使用 `MODULE_CLEAN`
  - 如果测试真正需要引擎隔离（如测试引擎启动行为本身、SkipBinds 配置、Docs dump 等依赖引擎初始状态的场景），保留 `FULL` 并标注豁免理由

## 当前事实状态快照

引擎创建模式全局分布（扫描于 2026-04-29）：

| 模式 | 调用次数 | 语义 |
|---|---|---|
| `SHARE_CLEAN` | 381 | 共享引擎 + 清理模块（**标准模式**） |
| `SHARE`（旧模式） | 136 | 共享引擎，不清理模块 |
| `FULL` | 60 | 每次创建全新隔离引擎 |
| `SHARE_FRESH` | 36 | 共享引擎 + 完整重建 |
| `MODULE_CLEAN` | 34 | 共享引擎 + 仅清理本作用域新增模块 |
| `BARE` | 11 | SDK 裸引擎 |
| `NATIVE` | 0 | 原生 SDK 引擎 |

## 影响范围

本次迁移涉及以下操作（按需组合）：

- **引擎宏替换**：`ASTEST_CREATE_ENGINE_FULL()` → `ASTEST_CREATE_ENGINE_SHARE_CLEAN()`，或 `ASTEST_CREATE_ENGINE_SHARE()` → `ASTEST_CREATE_ENGINE_SHARE_CLEAN()`
- **生命周期宏替换**：`ASTEST_BEGIN_FULL` / `ASTEST_END_FULL` → `ASTEST_BEGIN_SHARE_CLEAN` / `ASTEST_END_SHARE_CLEAN`，或 `ASTEST_BEGIN_SHARE` / `ASTEST_END_SHARE` → `ASTEST_BEGIN_SHARE_CLEAN` / `ASTEST_END_SHARE_CLEAN`
- **清理语句调整**：`FULL` 模式下 `ASTEST_BEGIN_FULL` 内置了 `ON_SCOPE_EXIT { DiscardModule }` 自动清理；迁移到 `SHARE_CLEAN` 后如果测试内部有手动 `DiscardModule` 或 `ResetSharedCloneEngine` 调用，需要确认是否保留或简化
- **豁免标注**：对需要保留 `FULL` 的测试，补充 `// Requires FULL: <理由>` 注释

### Phase 1 — `ASTEST_CREATE_ENGINE_FULL()` 迁移（30 个文件，60 处调用）

Angelscript/（11 个文件，30 处）：
- `AngelscriptControlFlowTests.cpp` — 引擎宏替换 × 11 + 生命周期宏替换（**最重的文件**）
- `AngelscriptCoreExecutionTests.cpp` — 引擎宏替换 × 4 + 生命周期宏替换
- `AngelscriptFunctionTests.cpp` — 引擎宏替换 × 3 + 生命周期宏替换
- `AngelscriptInheritanceTests.cpp` — 引擎宏替换 × 3 + 生命周期宏替换
- `AngelscriptHandleTests.cpp` — 引擎宏替换 × 2 + 生命周期宏替换
- `AngelscriptTypeTests.cpp` — 引擎宏替换 × 1 + 生命周期宏替换

StaticJIT/（3 个文件，8 处）：
- `AngelscriptStaticJITPrimitiveConversionTests.cpp` — 引擎宏替换 × 3
- `AngelscriptStaticJITExceptionTests.cpp` — 引擎宏替换 × 3
- `AngelscriptStaticJITNativeBridgeTests.cpp` — 引擎宏替换 × 2

Bindings/（12 个文件，14 处）：
- `AngelscriptBlueprintCallableReflectiveFallbackTests.cpp` — 引擎宏替换 × 3
- `AngelscriptWorldFunctionLibraryTests.cpp` — 引擎宏替换 × 2
- `AngelscriptWorldCollisionFunctionLibraryComponentTests.cpp` — 引擎宏替换 × 2
- `AngelscriptUserWidgetBindingsTests.cpp` — 引擎宏替换 × 2
- `AngelscriptHitResultFunctionLibraryTests.cpp` — 引擎宏替换 × 1
- `AngelscriptWorldCollisionFunctionLibraryTraceTests.cpp` — 引擎宏替换 × 1
- `AngelscriptWorldCollisionBindingsTests.cpp` — 引擎宏替换 × 1
- `AngelscriptWorldCollisionAsyncSweepBindingsTests.cpp` — 引擎宏替换 × 1
- `AngelscriptWorldCollisionAsyncBindingsTests.cpp` — 引擎宏替换 × 1
- `AngelscriptWorldBindingsTests.cpp` — 引擎宏替换 × 1
- `AngelscriptGameInstanceLocalPlayerBindingsTests.cpp` — 引擎宏替换 × 1
- `AngelscriptWidgetFunctionLibraryTests.cpp` — 引擎宏替换 × 1
- `AngelscriptNativeEngineBindingsTests.cpp` — 引擎宏替换 × 1

Validation/（2 个文件，3 处）：
- `AngelscriptCompilerMacroValidationTests.cpp` — 引擎宏替换 × 2
- `AngelscriptMacroValidationTests.cpp` — 引擎宏替换 × 1

Core/（2 个文件，2 处）：
- `AngelscriptDocsTests.cpp` — 引擎宏替换 × 1（**评估豁免**：Docs dump 可能依赖完整引擎状态）
- `AngelscriptSkipBindsTests.cpp` — 引擎宏替换 × 1（**评估豁免**：SkipBinds 测试可能需要隔离引擎配置）
- `AngelscriptScriptObjectTypeTests.cpp` — 引擎宏替换 × 1

AngelScriptSDK/（1 个文件，1 处）：
- `AngelscriptTypeRegistryTests.cpp` — 引擎宏替换 × 1

StaticJIT/（1 个文件，1 处）：
- `AngelscriptPrecompiledDataArchiveTests.cpp` — 引擎宏替换 × 1

Template/（1 个文件，2 处，**豁免**）：
- `Template_ReflectionAccess.cpp` — 保留 FULL（代码注释已解释需要隔离引擎保持 script-defined class 的类型元数据存活）

### Phase 2 — `ASTEST_CREATE_ENGINE_SHARE()` 迁移（~31 个文件，136 处调用）

Angelscript/（10 个文件，~60 处）：
- `AngelscriptTypeTests.cpp` — 引擎宏替换 × 17 + 生命周期宏替换
- `AngelscriptExecutionTests.cpp` — 引擎宏替换 × 10 + 生命周期宏替换
- `AngelscriptFunctionTests.cpp` — 引擎宏替换 × 7 + 生命周期宏替换
- `AngelscriptObjectModelTests.cpp` — 引擎宏替换 × 6 + 生命周期宏替换
- `AngelscriptMiscTests.cpp` — 引擎宏替换 × 5 + 生命周期宏替换
- `AngelscriptOperatorTests.cpp` — 引擎宏替换 × 4 + 生命周期宏替换
- `AngelscriptUpgradeCompatibilityTests.cpp` — 引擎宏替换 × 3 + 生命周期宏替换
- `AngelscriptInheritanceTests.cpp` — 引擎宏替换 × 2 + 生命周期宏替换
- `AngelscriptHandleTests.cpp` — 引擎宏替换 × 2 + 生命周期宏替换
- `AngelscriptControlFlowTests.cpp` — 引擎宏替换 × 1 + 生命周期宏替换
- `AngelscriptCoreExecutionTests.cpp` — 引擎宏替换 × 2 + 生命周期宏替换
- `AngelscriptAutoTypeTests.cpp` — 引擎宏替换 × 1
- `AngelscriptTypeConversionTests.cpp` — 引擎宏替换 × 1
- `AngelscriptExecutionScriptRangeTests.cpp` — 引擎宏替换 × 1
- `AngelscriptExecutionNestedCallTests.cpp` — 引擎宏替换 × 1

Compiler/（1 个文件，~16 处）：
- `AngelscriptCompilerPipelineTests.cpp` — 引擎宏替换 × 16 + 生命周期宏替换

HotReload/（1 个文件，9 处）：
- `AngelscriptHotReloadAnalysisTests.cpp` — 引擎宏替换 × 9 + 生命周期宏替换

Bindings/（~10 个文件，~30 处）：
- `AngelscriptGameplayTagBindingsTests.cpp` — 引擎宏替换 × 6
- `AngelscriptClassBindingsTests.cpp` — 引擎宏替换 × 6
- `AngelscriptUtilityBindingsTests.cpp` — 引擎宏替换 × 5
- `AngelscriptEngineBindingsTests.cpp` — 引擎宏替换 × 4
- `AngelscriptCompatBindingsTests.cpp` — 引擎宏替换 × 4
- `AngelscriptCoreMiscBindingsTests.cpp` — 引擎宏替换 × 3
- `AngelscriptNativeEngineBindingsTests.cpp` — 引擎宏替换 × 3
- `AngelscriptMathAndPlatformBindingsTests.cpp` — 引擎宏替换 × 3
- `AngelscriptObjectBindingsTests.cpp` — 引擎宏替换 × 2
- `AngelscriptContainerCompareBindingsTests.cpp` — 引擎宏替换 × 2

FileSystem/（1 个文件，5 处）：
- `AngelscriptFileSystemTests.cpp` — 引擎宏替换 × 5 + 生命周期宏替换

Core/（1 个文件，2 处）：
- `AngelscriptEngineCoreTests.cpp` — 引擎宏替换 × 2

Learning/Runtime/（2 个文件，2 处）：
- `AngelscriptLearningHotReloadDecisionTraceTests.cpp` — 引擎宏替换 × 1
- `AngelscriptLearningReloadAndClassAnalysisTests.cpp` — 引擎宏替换 × 1

## 分阶段执行计划

### Phase 1：迁移 `ASTEST_CREATE_ENGINE_FULL()` 调用

> 目标：消除不必要的全新引擎创建开销，保留少量有正当理由的豁免。

- [ ] **P1.1** 迁移 Angelscript/ 目录下的 FULL 调用（6 个文件，~24 处）
  - 这是 FULL 调用最密集的区域，尤其 `AngelscriptControlFlowTests.cpp` 一个文件就有 11 处。这些测试全部是"编译脚本 → 执行 → 检查返回值"的纯功能测试，不依赖引擎初始状态或隔离配置
  - 将 `ASTEST_CREATE_ENGINE_FULL()` 替换为 `ASTEST_CREATE_ENGINE_SHARE_CLEAN()`，同时将 `ASTEST_BEGIN_FULL` / `ASTEST_END_FULL` 替换为 `ASTEST_BEGIN_SHARE_CLEAN` / `ASTEST_END_SHARE_CLEAN`
  - `FULL` 生命周期宏内置了 `ON_SCOPE_EXIT { DiscardModule }` 自动清理逻辑；迁移后需要检查测试内部是否有手动清理代码需要调整
  - 每个文件迁移后应能通过 `Angelscript.TestModule.*` 或 `Angelscript.Template.*` 对应前缀的自动化测试
- [ ] **P1.1** 📦 Git 提交：`[AngelscriptTest] Refactor: migrate FULL engine to SHARE_CLEAN in Angelscript/ tests`

- [ ] **P1.2** 迁移 StaticJIT/ 目录下的 FULL 调用（3 个文件，8 处）
  - StaticJIT 测试验证 JIT 编译、原生桥接和异常处理，不需要引擎隔离
  - 同样执行 `FULL` → `SHARE_CLEAN` + 生命周期宏替换
- [ ] **P1.2** 📦 Git 提交：`[AngelscriptTest] Refactor: migrate FULL engine to SHARE_CLEAN in StaticJIT/ tests`

- [ ] **P1.3** 迁移 Bindings/ 目录下的 FULL 调用（12 个文件，14 处）
  - Bindings 测试为标准的"编译脚本 → 调用函数 → 验证绑定行为"模式，全部可用 `SHARE_CLEAN`
  - 注意 `AngelscriptWorldFunctionLibraryTests.cpp` 和 `AngelscriptWorldCollisionFunctionLibraryComponentTests.cpp` 各有 2 处，需确认两个测试间是否有模块名冲突
- [ ] **P1.3** 📦 Git 提交：`[AngelscriptTest] Refactor: migrate FULL engine to SHARE_CLEAN in Bindings/ tests`

- [ ] **P1.4** 迁移 Validation/ + Core/ + AngelScriptSDK/ 目录下的 FULL 调用（5 个文件，6 处）
  - `AngelscriptDocsTests.cpp` 和 `AngelscriptSkipBindsTests.cpp` 需要逐个评估：如果测试依赖引擎配置差异（如 SkipBinds 列表），保留 FULL 并补注释
  - 其余文件（`AngelscriptScriptObjectTypeTests.cpp`、`AngelscriptTypeRegistryTests.cpp`、`AngelscriptPrecompiledDataArchiveTests.cpp`、`AngelscriptCompilerMacroValidationTests.cpp`、`AngelscriptMacroValidationTests.cpp`）统一迁移
- [ ] **P1.4** 📦 Git 提交：`[AngelscriptTest] Refactor: migrate FULL engine to SHARE_CLEAN in Validation/Core/SDK tests`

- [ ] **P1.5** 标注豁免清单
  - `Template_ReflectionAccess.cpp`（2 处）：已有注释说明需要 FULL，确认注释充分即可
  - Phase 1 中评估后决定保留 FULL 的文件，统一补充 `// Requires FULL: <理由>` 注释
- [ ] **P1.5** 📦 Git 提交：`[AngelscriptTest] Docs: annotate FULL engine exemptions with rationale`

### Phase 2：迁移 `ASTEST_CREATE_ENGINE_SHARE()` 调用

> 目标：将旧版无清理共享模式统一升级为 `SHARE_CLEAN`，消除模块累积隐患。

- [ ] **P2.1** 迁移 Angelscript/ 目录下的 SHARE 调用（~11 个文件，~55 处）
  - 这是 SHARE 调用最密集的区域，`AngelscriptTypeTests.cpp` 有 17 处、`AngelscriptExecutionTests.cpp` 有 10 处
  - `SHARE` 的生命周期宏是 `ASTEST_BEGIN_SHARE` / `ASTEST_END_SHARE`，需一并替换为 `ASTEST_BEGIN_SHARE_CLEAN` / `ASTEST_END_SHARE_CLEAN`
  - 部分测试可能依赖"上一个测试编译的模块仍然存在"的隐式行为——迁移后需要确认测试仍 PASS，如果出现模块找不到的问题说明存在跨测试依赖，需要在测试内部显式 `BuildModule`
- [ ] **P2.1** 📦 Git 提交：`[AngelscriptTest] Refactor: migrate SHARE engine to SHARE_CLEAN in Angelscript/ tests`

- [ ] **P2.2** 迁移 Compiler/ 目录下的 SHARE 调用（1 个文件，16 处）
  - `AngelscriptCompilerPipelineTests.cpp` 单文件 16 处 SHARE 调用，是第二密集的文件
  - 需要特别注意：编译器管线测试如果在同一个共享引擎上依次编译不同脚本，模块名不能冲突
- [ ] **P2.2** 📦 Git 提交：`[AngelscriptTest] Refactor: migrate SHARE engine to SHARE_CLEAN in Compiler/ tests`

- [ ] **P2.3** 迁移 HotReload/ 目录下的 SHARE 调用（1 个文件，9 处）
  - `AngelscriptHotReloadAnalysisTests.cpp` 有 9 处 SHARE 调用
  - 热重载分析测试可能需要更精细的隔离——如果 `SHARE_CLEAN` 不够，考虑使用 `MODULE_CLEAN` 或保留说明
- [ ] **P2.3** 📦 Git 提交：`[AngelscriptTest] Refactor: migrate SHARE engine to SHARE_CLEAN in HotReload/ tests`

- [ ] **P2.4** 迁移 Bindings/ 目录下的 SHARE 调用（~10 个文件，~38 处）
  - 涉及 `GameplayTag`、`Class`、`Utility`、`Engine`、`Compat` 等多个绑定测试文件
  - 这些都是标准的绑定验证测试，统一迁移到 `SHARE_CLEAN`
- [ ] **P2.4** 📦 Git 提交：`[AngelscriptTest] Refactor: migrate SHARE engine to SHARE_CLEAN in Bindings/ tests`

- [ ] **P2.5** 迁移 FileSystem/ + Core/ + Learning/ 目录下的剩余 SHARE 调用（~4 个文件，~9 处）
  - `AngelscriptFileSystemTests.cpp`（5 处）、`AngelscriptEngineCoreTests.cpp`（2 处）和 Learning 目录下的 2 个文件
  - 文件系统测试需要确认模块路径发现是否依赖引擎全局状态
- [ ] **P2.5** 📦 Git 提交：`[AngelscriptTest] Refactor: migrate SHARE engine to SHARE_CLEAN in remaining directories`

### Phase 3：单 Entry 测试合并（Bindings/ 目录）

> 目标：将大量使用 `int Entry()` 单入口模式的独立小测试合并为 TArray 式多函数批量验证测试，减少重复的引擎获取、模块编译和函数查找开销，同时提升覆盖面。

**当前问题**：Bindings/ 目录下有 ~43 个文件使用 `"int Entry()"` 模式，累计 ~120 处。典型模式是：每个 `IMPLEMENT_SIMPLE_AUTOMATION_TEST` 注册一个独立测试 → 获取引擎 → `BuildModule` 编译包含单个 `int Entry()` 的脚本 → `GetFunctionByDecl("int Entry()")` → `ExecuteIntFunction` → `TestEqual(Result, 1)` → 关闭生命周期。N 个测试 = N 次引擎获取/清理 + N 次模块编译 + N 次函数查找。

**正面模板**：`AngelscriptTArrayBindingsTests.cpp` — 一次引擎获取，一个模块编译包含多个命名函数（`int IntDefaultIsEmpty()`、`int IntReserveKeepsNum()` 等），用 `ExpectGlobalInts` helper 批量调用验证。函数名即文档，失败时直接定位到具体函数。

**合并原则**：
- 同一主题的小测试合并为一个 `RunTest` + 多函数模块（按主题分 Section）
- 函数不再叫 `Entry()`，而是有语义的命名（如 `int OptionalDefaultIsEmpty()`、`int SetAddDuplicate()`）
- 错误路径/异常路径测试可保留独立入口（因为需要 `AddExpectedError` 等特殊设置）
- 合并后单个 `.cpp` 文件可参照 TArray 范例的 Section 结构

**合并候选（按优先级排序，仅 Bindings/ 目录）**：

- [ ] **P3.1** 合并 Container 容器系列测试（当前 3 个文件，~22 个 Entry）
  - `AngelscriptContainerBindingsTests.cpp`（14 个 Entry）：Optional / Set / Map / foreach 系列。当前 14 个独立测试可合并为 1 个测试 + 3-4 个 Section（OptionalOps / SetOps / MapOps / ForeachMatrix），正常路径的 Entry 函数改为命名函数批量验证；`OptionalGetValueUnsetError` 这类异常路径保留独立入口
  - `AngelscriptContainerCompareBindingsTests.cpp`（4 个 Entry）：Set/Map 比较操作，合并为 1 个 Section
  - `AngelscriptSetBindingsAdvancedTests.cpp`（1 个 Entry）：可并入容器测试
  - 合并后预期从 ~19 个独立测试 → 1-2 个巨型测试 + 少量异常路径独立测试
- [ ] **P3.1** 📦 Git 提交：`[AngelscriptTest] Refactor: consolidate container binding tests into multi-function sections`

- [ ] **P3.2** 合并 GameplayTag 系列测试（当前 3 个文件，~10 个 Entry）
  - `AngelscriptGameplayTagBindingsTests.cpp`（8 个 Entry，8 个测试）：Tag / TagContainer / TagQuery 等，合并为 1 个测试 + 2-3 个 Section
  - `AngelscriptGameplayTagContainerFunctionLibraryTests.cpp`（1 个 Entry）
  - `AngelscriptGameplayTagEmptyContractTests.cpp`（1 个 Entry）
- [ ] **P3.2** 📦 Git 提交：`[AngelscriptTest] Refactor: consolidate GameplayTag binding tests`

- [ ] **P3.3** 合并 EnhancedInput 系列测试（1 个文件，8 个 Entry）
  - `AngelscriptEnhancedInputBindingsTests.cpp`（8 个 Entry，8 个测试）：InputAction / InputBinding / InputComponent 等，合并为 1 个测试 + 2 个 Section
- [ ] **P3.3** 📦 Git 提交：`[AngelscriptTest] Refactor: consolidate EnhancedInput binding tests`

- [ ] **P3.4** 合并 Console 系列测试（当前 4 个文件，~9 个 Entry）
  - `AngelscriptConsoleBindingsTests.cpp`（6 个 Entry，5 个测试）：CVar / ConsoleCommand / CommandReplacement / Signature 等
  - `AngelscriptConsoleCommandArgumentBindingsTests.cpp`（1 个 Entry）
  - `AngelscriptConsoleCommandErrorBindingsTests.cpp`（1 个 Entry，异常路径，可能保留独立）
  - `AngelscriptConsoleVariableIdentityTests.cpp`（1 个 Entry）
- [ ] **P3.4** 📦 Git 提交：`[AngelscriptTest] Refactor: consolidate Console binding tests`

- [ ] **P3.5** 合并 Class / Compat / Utility / Engine 系列测试（当前 4 个文件，~20 个 Entry）
  - `AngelscriptClassBindingsTests.cpp`（6 个 Entry，7 个测试）：ClassLookup / TSubclassOf / StaticClass 等
  - `AngelscriptCompatBindingsTests.cpp`（5 个 Entry，5 个测试）：ObjectCast / EditorOnly / Timespan / DateTime 等
  - `AngelscriptUtilityBindingsTests.cpp`（5 个 Entry，5 个测试）：工具函数绑定
  - `AngelscriptEngineBindingsTests.cpp`（4 个 Entry，4 个测试）：ValueTypes / FNameArray 等
- [ ] **P3.5** 📦 Git 提交：`[AngelscriptTest] Refactor: consolidate Class/Compat/Utility/Engine binding tests`

- [ ] **P3.6** 合并 File/Delegate / Math / CoreMisc / 其余小文件（当前 ~10 个文件，~25 个 Entry）
  - `AngelscriptFileAndDelegateBindingsTests.cpp`（7 个 Entry）
  - `AngelscriptMathAndPlatformBindingsTests.cpp`（4 个 Entry）
  - `AngelscriptCoreMiscBindingsTests.cpp`（4 个 Entry）
  - `AngelscriptDataTableBindingsTests.cpp`（3 个 Entry）
  - `AngelscriptIteratorBindingsTests.cpp`（3 个 Entry）
  - 其余各 1-2 个 Entry 的文件按主题就近合并
- [ ] **P3.6** 📦 Git 提交：`[AngelscriptTest] Refactor: consolidate remaining binding tests into multi-function sections`

### Phase 3B：单 Entry 测试合并（Compiler / SDK / Preprocessor 目录）

> 目标：与 Phase 3 同理，将 Compiler/、AngelScriptSDK/、Preprocessor/ 目录中碎片化的单 Entry 测试按主题聚合。

**规模统计**：
- Compiler/：16 个文件，~17 个 Entry（大部分是 1 文件 = 1 个 Pipeline 功能点）
- AngelScriptSDK/：6 个文件，~17 个 Entry
- Preprocessor/：9 个文件，~13 个 Entry

- [ ] **P3B.1** 合并 Compiler Pipeline 系列（当前 16 个文件，可按编译阶段聚合）
  - 语法/表达式组：`ControlFlow` + `RangeFor` + `Struct` + `Namespace` + `FormatString` → `CompilerPipelineSyntaxTests`
  - 元数据组：`SpecifierMetadata` + `PropertyMetadata` + `PropertyReplicationCondition` + `FunctionDefault` → `CompilerPipelineMetadataTests`
  - 模块管理组：`Import` + `ImportReload` + `Recompile` → `CompilerPipelineModuleTests`
  - 运行时组：`Execution` + `DelegateRuntime` + `Failure` → `CompilerPipelineRuntimeTests`
  - `CompilerPipelineTests.cpp` 本身如果已经较大可保持原样
- [ ] **P3B.1** 📦 Git 提交：`[AngelscriptTest] Refactor: consolidate Compiler pipeline tests by compilation stage`

- [ ] **P3B.2** 合并 AngelScriptSDK 系列（当前 6 个文件）
  - `CompilerTests`（4 Entry）+ `BuilderTests`（4 Entry）→ 编译器验证组
  - `CallingConvTests`（3 Entry）+ `OperatorTests`（1 Entry）+ `TypeTests`（2 Entry）+ `NativeRegistrationTests`（3 Entry）→ SDK 原生 API 验证组
- [ ] **P3B.2** 📦 Git 提交：`[AngelscriptTest] Refactor: consolidate AngelScriptSDK tests`

- [ ] **P3B.3** 合并 Preprocessor 系列（当前 9 个文件）
  - 指令组：`DirectiveTests`（4 Entry）+ `DirectiveWhitespaceTests`（2 Entry）+ `RestrictUsageTests`（1 Entry）→ `PreprocessorDirectiveTests`
  - Import 组：`ImportTests`（1 Entry）+ `ImportDedupTests`（1 Entry）+ `NamespaceTests`（1 Entry）→ `PreprocessorImportTests`
  - Literal 组：`LiteralTests`（1 Entry）+ `LiteralAssetTests`（1 Entry）+ `StressTests`（1 Entry）→ `PreprocessorLiteralAndStressTests`
- [ ] **P3B.3** 📦 Git 提交：`[AngelscriptTest] Refactor: consolidate Preprocessor tests`

### Phase 4：验证与收口

- [ ] **P4.1** 全量测试回归
  - 运行 `RunTestSuite.ps1 -Suite Smoke` 确认快速回归通过
  - 运行 `RunTests.ps1 -Group AngelscriptRuntimeUnit` 确认运行时测试通过
  - 运行完整 `Angelscript.TestModule.Bindings.` 前缀回归
  - 如果有新增失败，定位是迁移引入的跨测试隐式依赖还是预存问题
- [ ] **P4.1** 📦 Git 提交：`[AngelscriptTest] Test: verify full regression after engine creation pattern migration`

- [ ] **P4.2** 更新文档
  - 更新 `TESTING_GUIDE.md` 和 `TESTING_GUIDE_ZH.md` 中关于引擎选择的决策树，明确 `FULL` 仅限于需要引擎配置隔离的场景
  - 更新 `Shared/README_MACROS.md` 补充迁移后的模式使用统计和合并后的测试密度指标
  - 更新 `AGENTS.md` 中测试基线数字（如果数字变化的话）
- [ ] **P4.2** 📦 Git 提交：`[Docs] Docs: update testing guides with engine creation pattern and test consolidation results`

## 验收标准

1. `ASTEST_CREATE_ENGINE_FULL()` 在测试 `.cpp` 文件中的调用降至 ≤5 处（全部有豁免注释说明理由）。
2. `ASTEST_CREATE_ENGINE_SHARE()` 在测试 `.cpp` 文件中的调用降至 0 处。
3. Bindings/ 目录中 `"int Entry()"` 模式的独立测试数从 ~120 降至 ≤20（剩余为异常路径/副作用类测试的正当保留）。
4. 合并后的 Bindings/ 目录测试数（`IMPLEMENT_SIMPLE_AUTOMATION_TEST`）从当前的 ~80+ 降至 ~15-25 个，但覆盖函数数不减少。
5. 全量测试回归无新增失败（相对迁移前的 live suite baseline）。
6. `TESTING_GUIDE.md` / `README_MACROS.md` 已更新引擎创建模式决策树、测试合并示例和使用统计。

## 风险与注意事项

### 风险

1. **跨测试隐式模块依赖**：部分使用 `SHARE`（无清理）的测试可能隐式依赖"上一个测试编译的模块仍然存在"。迁移到 `SHARE_CLEAN` 后，每个测试开始前模块会被清理，可能暴露此类隐式依赖。
   - **缓解**：逐文件迁移后立即运行对应前缀测试，如果出现 "module not found" 类错误，说明测试内部缺少显式 `BuildModule` 调用，需补齐。

2. **FULL 引擎有正当需求的场景被误迁移**：如 SkipBinds 测试需要修改引擎配置、Docs 测试需要检查完整引擎注册状态。
   - **缓解**：Phase 1 中对 `Core/` 和 `Validation/` 目录的文件逐个评估，不做盲目批量替换。

3. **HotReload 测试对引擎状态敏感**：热重载分析测试可能需要特殊的模块生命周期管理。
   - **缓解**：Phase 2.3 中对 HotReload 目录单独处理，如果 `SHARE_CLEAN` 不够，考虑 `MODULE_CLEAN`。

4. **合并后单个测试失败定位变难**：将 N 个独立测试合并为 1 个后，如果 `RunTest` 失败，不如独立测试能精确定位哪个场景失败。
   - **缓解**：合并后的每个函数使用唯一命名并返回唯一错误码（如 TArray 模板的 Section + 错误码设计）。`TestEqual` 的描述文本应包含函数名。失败时信息与独立测试等价。

5. **异常路径测试不适合合并**：需要 `AddExpectedError`、`UE_SET_LOG_VERBOSITY(Fatal)` 或自定义上下文的测试不能简单地和正常路径测试共享模块。
   - **缓解**：异常路径测试保留独立 `IMPLEMENT_SIMPLE_AUTOMATION_TEST`，在合并清单中用 `[exempt: error-path]` 标注。

### 已知行为变化

1. **FULL → SHARE_CLEAN 后引擎不再是完全隔离的**：所有使用 `SHARE_CLEAN` 的测试共享同一个进程级引擎实例。如果某个测试修改了引擎的全局配置（如注册新的全局类型），可能影响后续测试。
   - 当前已迁移到 `SHARE_CLEAN` 的 381 个测试没有出现此类问题，说明绝大多数测试不修改引擎全局配置。
   - 影响文件：`AngelscriptSkipBindsTests.cpp`（可能需要保留 FULL）

2. **SHARE → SHARE_CLEAN 后模块不再跨测试累积**：之前在 `SHARE` 模式下，测试 A 编译的模块在测试 B 中仍可见。迁移后每个测试开始前模块被清理。
   - 如果有测试依赖此行为，需要在测试内部显式重建所需模块。
