# Angelscript 插件设置项（Project Settings）改进、测试闭环与 DX 强化计划

## 背景与目标

### 当前状态事实

- 插件当前对"可配置行为"的入口主要是两个 UObject 配置类，分别落在 `AngelscriptRuntime/Core/AngelscriptSettings.h` 与 `AngelscriptRuntime/Testing/AngelscriptTestSettings.h`：
  - `UAngelscriptSettings`（`UCLASS(Config=Engine, DefaultConfig)`, 非 `UDeveloperSettings`）：运行时/编译时/preprocessor/warning 等共 **28 个字段**。
  - `UAngelscriptTestSettings`（`UDeveloperSettings`, `config=Editor`）：测试发现、GC 批次、Code Coverage、网络模拟等。
  - `UAngelscriptTestUserSettings`（`UDeveloperSettings`, `config=EditorPerProjectUserSettings`）：热重载测试触发、模块数上限。
- `UAngelscriptSettings` 由 `AngelscriptEditor` 模块手动注册到 `Project Settings → Plugins → Angelscript`，生命周期测试已在 `AngelscriptEditorModuleSettingsTests.cpp` 覆盖；但字段行为本身的覆盖极不均衡。
- `UAngelscriptTestSettings` / `UAngelscriptTestUserSettings` 在 `AngelscriptTest/` 整个目录下 **零直接测试**（全仓搜索 `UAngelscriptTestSettings`、`UAngelscriptTestUserSettings`、`bEnableTestDiscovery`、`GarbageCollectEveryNTests`、`CoverageExcludePatterns` 等字段名均为 0 命中）。
- 通过字段 × 使用点 × 测试盘点：`UAngelscriptSettings` 的 28 个字段中只有 **约 7 个字段**有真实行为断言（`DisabledBindNames`、`bDefaultFunctionBlueprintCallable`、`DefaultPropertyEditSpecifier(ForStructs)`、`DefaultPropertyBlueprintSpecifier`、`bWarnOnManualImportStatements`、`bScriptFloatIsFloat64`、`DebuggerBlacklistAutomaticFunctionEvaluationWithoutWorldContext`），另有少量"调试协议 mirror"式断言（`bAutomaticImports`、`bFloatIsFloat64`、`StaticClassDeprecation`），其余 **约 15 个字段完全没有测试**，包括所有 `Warnings and Errors` 分类下的开关。
- `UAngelscriptSettings` 与 `UAngelscriptTestSettings` 架构不一致：前者是 `UCLASS(Config=Engine)` + 手动 `ISettingsModule::RegisterSettings`，后者是 `UDeveloperSettings` + 自动发现。这种"两条路线并存"既是历史包袱，也是当前设置体验层面最明显的不一致点。

### 目标

本计划只做三件事，不扩展到运行时/编译器逻辑改造：

1. **摸清设置项的行为契约**：把 28 个 `UAngelscriptSettings` 字段 + 测试侧两个 `UDeveloperSettings` 的字段，逐条建立"字段 → 行为 → 用例"映射，让后续修改任一字段时都能先跑通一组锁行为测试。
2. **补齐行为测试**：优先补 `Warnings and Errors` 分类、`BlueprintLibraryNamespace*ToStrip`、`MathNamespace`、`AdditionalEditorOnlyScriptPackageNames`、`bAllowRawConstructorsForComponentsAndActors`、`bMarkNonUpropertyPropertiesAsTransient`、`bUseScriptNameForBlueprintLibraryNamespaces` 等零覆盖字段；为 `UAngelscriptTestSettings` / `UAngelscriptTestUserSettings` 建立首批直接测试。
3. **整理设置项 DX（开发者体验）**：在不破坏既有 ini 兼容的前提下，规范分类、Tooltip、ConfigRestartRequired 标记，评估把 `UAngelscriptSettings` 迁移到 `UDeveloperSettings` 的可行性与代价（对外仅评估，不强制落地到本计划）。

### 非目标

- 不修改任何 warning/error 的**产生逻辑**，只补测试锁定行为。
- 不做新的 Bind 覆盖、Debugger 协议扩展，不与 `Plan_TestCoverageExpansion.md`、`Plan_ASDebuggerUnitTest.md` 的主工作线重叠。
- 不在本计划落地"把 `UAngelscriptSettings` 改成 `UDeveloperSettings`"这类结构改动；本计划仅形成**评估文档 + 建议路径**，真正落地由后续专项 Plan 承接。
- 不改 `UProperty` 名称（避免 `DefaultConfig` ini 迁移风险），只在 Meta/Tooltip/Category 层面做无破坏性改进。

### 与既有计划的关系

- 与 `Plan_StatusPriorityRoadmap.md` 的 "交付基线 / 插件化硬化" 主线对齐：设置面暴露、Tooltip、测试闭环属于"对外使用者体验"范畴，而非新能力。
- 与 `Plan_TestCoverageExpansion.md` 的"测试覆盖率系统性扩展"互补：该计划按 Bind/FunctionLibrary/GAS/StaticJIT 横向扩展；本计划只聚焦配置项这一纵向切面。
- 与 `Plan_PluginEngineeringHardening.md`、`Plan_TestSystemNormalization.md` 协同：测试侧 settings 的首批覆盖应沉淀进 `TESTING_GUIDE.md`。
- 与 `Plan_FunctionalGapClosure.md` 不重叠：不涉及 UClass/Subsystem 能力闭环。

## 范围与边界

### 在范围内

- `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptSettings.h`：28 个字段的行为契约盘点 + Meta/Tooltip 可选改进。
- `Plugins/Angelscript/Source/AngelscriptRuntime/Testing/AngelscriptTestSettings.h`：两个 `UDeveloperSettings` 的行为契约盘点与首批测试。
- `Plugins/Angelscript/Source/AngelscriptTest/Core/AngelscriptSettingsBehaviorTests.cpp`（新增）：覆盖 `Warnings and Errors` 分类、MathNamespace 等零覆盖字段。
- `Plugins/Angelscript/Source/AngelscriptTest/Core/AngelscriptBindConfigTests.cpp`（已有，扩展）：补 `BlueprintLibraryNamespacePrefixesToStrip/SuffixesToStrip`、`bUseScriptNameForBlueprintLibraryNamespaces`。
- `Plugins/Angelscript/Source/AngelscriptTest/Testing/AngelscriptTestSettingsTests.cpp`（新增）：覆盖 `bEnableTestDiscovery`、`GarbageCollectEveryNTests`、`CoverageExcludePatterns`、`UnitTest/IntegrationTestNamingConvention`、网络模拟字段。
- `Documents/Guides/Settings.md`（新增）：字段清单、分类、Tooltip、默认值、是否需要重启、测试引用——作为对外与对内的单一入口文档。

### 不在范围内

- `StaticJITConfig.h` 等编译期宏开关（非 UPROPERTY 配置，不属于 "Project Settings" 范畴）。
- `AgentConfig.ini` 本地机器配置（已由 `Tools/Bootstrap/*` 管辖）。
- AngelScript 语言侧 warning/error 产生逻辑变更。
- 迁移 `UAngelscriptSettings` 到 `UDeveloperSettings` 的实际落地（只做可行性评估）。

## 当前字段 × 用法 × 测试 对照表（事实快照）

> 用于 Phase 1 盘点基线，后续各 Phase 的补齐以本表"无覆盖/弱覆盖"为起点。

### `UAngelscriptSettings`

| 字段 | 使用点 | 现有测试 | 本计划 Phase |
|---|---|---|---|
| `PreprocessorFlags` | `AngelscriptPreprocessor.cpp:47` 注入 | ❌ settings→preprocessor 接线未测 | P2 |
| `bAllowImplicitPropertyAccessors` | `AngelscriptType.cpp` / `Helper_FunctionSignature.h` | ❌ | P2 |
| `DisabledBindNames` | `CollectDisabledBindNames()` | ✅ `AngelscriptBindConfigTests.cpp` | — |
| `bAutomaticImports` | `ShouldUseAutomaticImportMethod()` | 🟡 仅调试协议 mirror | P3 |
| `bWarnOnManualImportStatements` | Preprocessor | ✅ `AngelscriptPreprocessorImportTests.cpp` | — |
| `MathNamespace` | `Bind_FMath.cpp`（`Math::` vs `FMath::`） | ❌ | P2 |
| `bDefaultFunctionBlueprintCallable` | ClassGenerator | ✅ `AngelscriptCompilerPipelineFunctionFlagTests.cpp` | — |
| `DefaultPropertyEditSpecifier` | Preprocessor | ✅ `AngelscriptPreprocessorStructTests.cpp` | — |
| `DefaultPropertyEditSpecifierForStructs` | Preprocessor | ✅ 同上 | — |
| `DefaultPropertyBlueprintSpecifier` | Preprocessor | ✅ `AngelscriptPreprocessorPropertyTests.cpp` | — |
| `bMarkNonUpropertyPropertiesAsTransient` | ClassGenerator | ❌ | P2 |
| `StaticClassDeprecation` | `Bind_BlueprintType.cpp` / DebugServer | 🟡 仅调试协议 mirror | P2 |
| `bUseScriptNameForBlueprintLibraryNamespaces` | `AngelscriptBinds.cpp` | ❌ | P2 |
| `BlueprintLibraryNamespacePrefixesToStrip` | `AngelscriptBinds.cpp` | ❌ | P2 |
| `BlueprintLibraryNamespaceSuffixesToStrip` | `AngelscriptBinds.cpp` | ❌ | P2 |
| `bAllowRawConstructorsForComponentsAndActors` | `Bind_UActorComponent.cpp` | ❌ | P2 |
| `bForceConstWithinDevelopmentOnlyFunctions` | `as_compiler.cpp` / `as_builder.cpp` | ❌ | P3 |
| `EditorMaximumScriptExecutionTime` | `AngelscriptEngine.cpp:5846` | 🟡 只作为 fixture save/restore | P3 |
| `bScriptFloatIsFloat64` | `Bind_Primitives.cpp` | ✅ `AngelscriptTypeTests.cpp` | — |
| `bDeprecateDoubleType` | `Bind_FMath.cpp` / `Bind_Primitives.cpp` | 🟡 部分分支未验证警告 | P3 |
| `bWarnOnFloatConstantsForDoubleValues` | `as_compiler.cpp` | ❌ | P3 |
| `bWarnIntegerDivision` | `as_compiler.cpp` | ❌ | P3 |
| `bOpenFolderOnVSCodeSourceLinks` | `SourceCodeNavigation` | ✅ `BuildVSCodeOpenParametersForTesting` | — |
| `VSCodeWorkspacePath` | `SourceCodeNavigation` / AngelscriptEngine | ✅ 同上 | — |
| `bErrorWhenUsingInvalidWorldContext` | `as_compiler.cpp` | ❌ | P3 |
| `bWarnOnUnusedReturnValueForConstMethods` | `as_compiler.cpp` | ❌ | P3 |
| `bWarnOnImplicitSignedUnsignedConversion` | `as_compiler.cpp` | ❌ | P3 |
| `bErrorOnIncorrectEditorOnlyCode` | `as_compiler.cpp` / `as_builder.cpp` | ❌ | P3 |
| `bWarnOnDivergentComparisonOperatorOverloads` | `as_compiler.cpp` | ❌ | P3 |
| `bWarnOnIncrementDecrementInComplexExpression` | `as_compiler.cpp` | ❌ | P3 |
| `AdditionalEditorOnlyScriptPackageNames` | `Bind_BlueprintType.cpp:918` | ❌ | P2 |
| `DebuggerBlacklistAutomaticFunctionEvaluation` | DebugServer | ❌（只覆盖了 WithoutWorldContext 变体） | P3 |
| `DebuggerBlacklistAutomaticFunctionEvaluationWithoutWorldContext` | DebugServer | ✅ `AngelscriptDebuggerAutoEvaluationTests.cpp` | — |

### `UAngelscriptTestSettings` / `UAngelscriptTestUserSettings`

| 字段 | 使用点 | 现有测试 | 本计划 Phase |
|---|---|---|---|
| `bRunUnitTestsOnHotReload` | `UnitTest.cpp:654` | ❌ | P4 |
| `LimitNModulesToTestOnHotReload` | `UnitTest.cpp:552` | ❌ | P4 |
| `bEnableTestDiscovery` | `AngelscriptEngine.cpp:2503/4423` | ❌ | P4 |
| `IntegrationTestMapRoot` | `IntegrationTest.cpp:832` | ❌ | P4 |
| `GarbageCollectEveryNTests` | `UnitTest.cpp:222/604` | ❌ | P4 |
| `UnitTestGameInstanceClass` | `UnitTest.cpp:286` | ❌ | P4 |
| `bEnableCodeCoverage` | `AngelscriptCodeCoverage.cpp:48` | ❌ | P4 |
| `CoverageExcludePatterns` | `AngelscriptCodeCoverage.cpp:204` | ❌ | P4 |
| `bEnableDebugBreaksInTests` | `UnitTest.cpp:266` / `IntegrationTest.cpp:341` | ❌ | P4 |
| `IntegrationTestNamingConvention` | `IntegrationTest.cpp:820` | ❌ | P4 |
| `UnitTestNamingConvention` | `UnitTest.cpp:700` | ❌ | P4 |
| `bEnableNetworkEmulation` + 6 个网络参数 | `IntegrationTest.cpp:323` 附近 | ❌ | P4 |

## 分阶段执行计划

### Phase 1 — 字段契约盘点与文档基线（前置）

> 目标：把"字段含义、使用点、重启要求、默认值、当前测试"沉淀成可被下游 Phase 引用的单一来源。

- [ ] **P1.1** 新增 `Documents/Guides/Settings.md`
  - 结构：按 `UAngelscriptSettings` / `UAngelscriptTestSettings` / `UAngelscriptTestUserSettings` 三节。
  - 每条字段必须包含：字段名、UPROPERTY Category、默认值、`ConfigRestartRequired` 标记、使用点（源文件+行）、当前测试引用（若无则显式标 `无`）。
  - 直接把本 Plan 的"对照表"正文迁入并保持双向可追溯。
- [ ] **P1.2** 在 `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptSettings.h` 内，对目前**缺少 Tooltip 注释**的字段补注释（例如 `bAllowImplicitPropertyAccessors` 当前注释偏短、`bMarkNonUpropertyPropertiesAsTransient` 含义不直观）。
  - 只补 `/** */` Tooltip 与补齐 `Meta = (Tooltip=)`，不改字段类型/名称/默认值/Category。
  - 验收：`SettingsTestHook` 通过 `FProperty::GetToolTipText()` 验证每个可见字段都有非空 Tooltip（见 P1.3）。
- [ ] **P1.3** 新增 `AngelscriptTest/Core/AngelscriptSettingsMetadataTests.cpp`
  - 测试 1：对 `UAngelscriptSettings` 每个 `UPROPERTY(EditDefaultsOnly)` 字段断言 `FProperty::GetToolTipText()` 非空。
  - 测试 2：对每个字段断言存在 `Category` MetaData。
  - 测试 3：对每个标 `ConfigRestartRequired` 的字段，其 Meta 必须显式 `ConfigRestartRequired = true`（防御重构时误删）。
  - 作用：把"字段文档完整性"从人工 review 降成自动化守护。

### Phase 2 — `UAngelscriptSettings` 行为零覆盖字段的首批用例

> 目标：让所有有运行时分支作用的字段都有至少 1 条 happy-path + 1 条 toggled-path 的行为断言。编译侧字段（as_compiler 的 warning/error）合并到 P3。

- [ ] **P2.1** 新增 `AngelscriptTest/Core/AngelscriptSettingsBehaviorTests.cpp`（预计 300–400 行）
  - 固定 fixture：按 `TESTING_GUIDE.md` 使用 `FScriptedEngineFixture` 或 `FAngelscriptSettingsScope`（新写），负责在 Setup 时备份字段、Teardown 时还原。
  - 字段子用例：
    - `MathNamespace = Math`：脚本 `Math::Sin(0.f)` 能通过编译；`= FMath` 时 `FMath::Sin(0.f)` 能通过编译，两种模式互斥生效。
    - `bMarkNonUpropertyPropertiesAsTransient = true`：ClassGenerator 生成的"隐式 UPROPERTY（仅为 GC 可见）"带 `Transient` 标记；`= false` 时不带。
    - `bAllowRawConstructorsForComponentsAndActors = false`（默认）：脚本中直接 `new AMyActor()` 应被拒；`= true` 时允许。
    - `bUseScriptNameForBlueprintLibraryNamespaces` + `BlueprintLibraryNamespacePrefixesToStrip`/`SuffixesToStrip`：对一条含 `UKismet*Library` 的虚拟 Bind 注册，断言生成的命名空间按规则被去前缀/去后缀。
    - `AdditionalEditorOnlyScriptPackageNames`：在 `Bind_BlueprintType.cpp:918` 分支中，当前 package 被纳入 editor-only 名单时，非编辑器构建下相关 UClass 不应被暴露；反之亦然。
- [ ] **P2.2** 在现有 `AngelscriptBindConfigTests.cpp` 扩展 `BlueprintLibraryNamespace*ToStrip` 的增量场景
  - 避免新开文件，直接复用 `Settings->DisabledBindNames` 场景的 ON_SCOPE_EXIT 模式。
- [ ] **P2.3** `bAllowImplicitPropertyAccessors` 开/关两种模式下，同一 `UObject::GetFoo()` 在脚本中以属性方式访问的编译结果差异（通过 Preprocessor+编译两阶段断言）。
- [ ] **P2.4** `PreprocessorFlags` settings → Preprocessor 注入链路：在设置中新增 `"PROJ_FOO"` 后，`#if PROJ_FOO` 的分支在脚本编译中被激活；移除后失效。

### Phase 3 — Compiler / Debugger 相关 warning/error 字段的锁行为

> 目标：把 `Warnings and Errors` 分类下所有开关"触发一次实际编译并断言 warning/error 输出"。注意这些字段会进入 `as_compiler.cpp` / `as_builder.cpp`（ThirdParty），本 Phase 不修改 ThirdParty，仅以脚本触发。

- [ ] **P3.1** 新增 `AngelscriptTest/Core/AngelscriptSettingsWarningTests.cpp`
  - 每个字段一组用例（toggle on → 产生诊断；toggle off → 不产生）。字段清单：
    - `bWarnOnFloatConstantsForDoubleValues`
    - `bWarnIntegerDivision`
    - `bWarnOnUnusedReturnValueForConstMethods`
    - `bWarnOnImplicitSignedUnsignedConversion`
    - `bWarnOnDivergentComparisonOperatorOverloads`
    - `bWarnOnIncrementDecrementInComplexExpression`
    - `bErrorOnIncorrectEditorOnlyCode`
    - `bErrorWhenUsingInvalidWorldContext`
    - `bForceConstWithinDevelopmentOnlyFunctions`
    - `bDeprecateDoubleType`（与 `bScriptFloatIsFloat64` 组合）
  - 约束：断言基于"编译日志中是否出现对应诊断字符串或编译是否成功"，不依赖 warning 文本稳定性；若现有编译器用 `FCompilerResult::Warnings` 数组暴露诊断结构，优先对结构化字段断言。
- [ ] **P3.2** `bAutomaticImports = false` 下，省略显式 `import` 语句的模块引用必须产生编译错误；`= true` 下自动解析。同时断言 `bWarnOnManualImportStatements` 在 `bAutomaticImports=false` 时不生效（EditCondition 行为）。
- [ ] **P3.3** `EditorMaximumScriptExecutionTime`：在 `<= 0.1f` 的极短阈值下，执行一个故意 busy loop 的脚本，验证 `Context->SetException("Script function took too long...")` 被抛出；还原后恢复正常。
- [ ] **P3.4** `StaticClassDeprecation` 的三种值（Allowed/Deprecated/Disallowed）对 `AMyActor::StaticClass()` 在脚本中的调用各产生何种诊断（pass/warn/error）各一条用例。
- [ ] **P3.5** `DebuggerBlacklistAutomaticFunctionEvaluation`（非 WithoutWorldContext 变体）：在脚本世界可用的前提下，断言黑名单中的函数不会被调试器自动求值。

### Phase 4 — 测试侧 `UDeveloperSettings` 的首批覆盖

> 目标：把测试自身依赖的配置项纳入自动化验证，避免"改了 TestSettings 但没人知道"。

- [ ] **P4.1** 新增 `AngelscriptTest/Testing/AngelscriptTestSettingsTests.cpp`
  - 用例：
    - `bEnableTestDiscovery = false`：`FAngelscriptEngine::BuildTestsFromModule` 入口不返回任何测试（通过 reflect/调用对应 collector 的 stub 路径实现）。
    - `GarbageCollectEveryNTests` 生效：构造 N+1 个 fake UnitTest，断言分批触发 GC 回调。
    - `CoverageExcludePatterns`：当 pattern 匹配时，`AngelscriptCodeCoverage` 的 `ShouldInstrument` 返回 false。
    - `IntegrationTestMapRoot` 空/非空两种场景下 `IntegrationTest` 的 map 解析行为。
    - `UnitTestNamingConvention` / `IntegrationTestNamingConvention` 通配符生效性。
    - `bEnableNetworkEmulation = true` 时，`InPackets*/OutPackets*` 值被写入网络驱动（mock 端即可）。
- [ ] **P4.2** `UAngelscriptTestUserSettings.bRunUnitTestsOnHotReload` 与 `LimitNModulesToTestOnHotReload` 的热重载触发条件测试（可复用已有热重载 fixture）。
- [ ] **P4.3** 把 `bEnableDebugBreaksInTests` 的读取路径用 mock 做一次 round-trip 断言（避免调试时误触 `DebugBreak()`）。

### Phase 5 — DX（开发者体验）与架构一致性评估

> 目标：只产出**评估文档**与**不破坏兼容**的微调；不落地大的架构迁移。

- [ ] **P5.1** 新增 `Documents/Knowledges/ZH/Note_SettingsArchitectureEvaluation.md`
  - 评估把 `UAngelscriptSettings` 从 `UCLASS(Config=Engine, DefaultConfig)` + 手动 `ISettingsModule::RegisterSettings` 迁到 `UDeveloperSettings` 的：
    - 兼容性代价（`Config=Engine` 与 `Config=Editor`/`EditorPerProjectUserSettings` 的存储位置差异）。
    - 对 `DefaultEngine.ini` 里已有 `[/Script/AngelscriptRuntime.AngelscriptSettings]` 段的迁移策略（是否需要双读双写过渡）。
    - 与 `AngelscriptEditorModuleProjectSettingsLifecycleTest` 的契约变化。
  - 结论：给出"建议保留现状"或"建议在 M+1 开专项 Plan"的明确取舍，不在本计划落地迁移。
- [ ] **P5.2** `UAngelscriptSettings` Meta 体检并做无破坏性改进
  - 对当前所有 `Meta = (ConfigRestartRequired = true)` 字段复核"是否真的需要重启"（例如 `DebuggerBlacklist*` 系列明显不需要，当前也确实没有该 Meta——保持）。
  - `EditCondition` 一致性：`bWarnOnManualImportStatements` 已带 `EditCondition = "bAutomaticImports"`；同类组合（如 `bDeprecateDoubleType` 是否应依赖 `bScriptFloatIsFloat64`）统一审一次。
- [ ] **P5.3** 建议性新增字段评估（**不在本计划强制落地**，仅写入 Settings.md "Proposed" 小节，作为候选池）
  - `bEnableStaticJIT`（Runtime 级 JIT 开关，当前只有编译期宏 `AS_CAN_GENERATE_JIT`，缺 UI 入口）。
  - `DebugServerPort` / `bEnableDebugServer`（当前 `DebugServer` 启停与端口走代码路径，不在设置面）。
  - `HotReloadDebounceMs`（热重载去抖当前是硬编码常量）。
  - `DumpOutputDirectory`（`FAngelscriptStateDump` 当前写入 `Saved/` 下硬编码子目录）。
  - `CoverageReportFormat`（Html/Json/Both）。
  - `bTreatWarningsAsErrors` / 白名单——对照 `Warnings and Errors` 分类的粗粒度开关。
  - 每条候选注明：期望字段名、Category、默认值、是否 RestartRequired、是否替代既有宏、初步成本评估。

## 验收标准

- `Documents/Guides/Settings.md` 存在，且每个 `UAngelscriptSettings` / `UAngelscriptTestSettings` / `UAngelscriptTestUserSettings` 字段都能在文档中查到 "使用点 + 现有测试" 双链。
- `AngelscriptSettingsMetadataTests.cpp` 通过，作为字段 Tooltip/Category 完整性的守护。
- `AngelscriptSettingsBehaviorTests.cpp` / `AngelscriptSettingsWarningTests.cpp` / `AngelscriptTestSettingsTests.cpp` 全部绿，且每个字段**至少有一条断言实际影响产物**（编译结果/诊断/运行时分支）。
- 本 Plan 对照表中标 ❌ 的字段在 Phase 4 完成时比例 **≥ 80% 转为 ✅**，余下字段需在文档中显式注明"零分支/无法断言"的原因。
- 通过 `Tools\RunTests.ps1` 的相关 suite（建议一次 suite 覆盖 `Angelscript.TestModule.Core.Settings*` 与 `Angelscript.Testing.Settings*`）在受控环境下稳定绿。
- `Plan_StatusPriorityRoadmap.md` 的"当前事实状态快照"小节在 Phase 5 完成后追加一行：设置面字段行为已建立测试基线。

## 风险与对策

| 风险 | 可能影响 | 对策 |
|---|---|---|
| `as_compiler.cpp` / `as_builder.cpp` 的诊断字符串不稳定 | P3 的"断言 warning 文本"用例脆弱 | 优先断言"是否产生诊断"而不是"诊断文本等于某字符串"；必要时在 `FAngelscriptEngine` 侧暴露结构化 `GetDiagnosticCodes()` 列表 |
| `UAngelscriptSettings` 是 `GetMutableDefault` 单例，测试并发写字段 | 测试间相互污染 | 强制通过 `FAngelscriptSettingsScope` RAII 备份/还原；在 P1.3 的 metadata 测试里断言字段备份还原路径的对称性 |
| 迁移 `UAngelscriptSettings` 到 `UDeveloperSettings` 会动 ini Section 名 | 既有用户项目 ini 丢失 | 本计划明确**不落地迁移**，只出评估文档；任何落地动作单开专项 Plan 并附双读双写过渡方案 |
| `EditorMaximumScriptExecutionTime` 测试会人为触发异常 | 日志噪音 / CI flake | 用 `FScopedLogCategorySuppress` 屏蔽相关日志类别；在 test shutdown 明确还原 |
| P5.3 "建议性新增字段" 被误当作本计划落地项 | 工作量外溢 | 文档标题显式写 "Proposed（非本计划落地）"；每条候选只写评估不写实现 |

## 执行顺序建议

1. Phase 1（文档基线 + 字段元信息守护）——必须先做，后续 Phase 引用。
2. Phase 2（`UAngelscriptSettings` 运行时分支字段零覆盖补齐）——成本低、ROI 高。
3. Phase 3（warning/error 字段）——体量最大，建议拆成两个小周期提交。
4. Phase 4（测试侧 `UDeveloperSettings` 首批覆盖）——独立，可与 Phase 3 并行。
5. Phase 5（架构评估与候选字段）——放最后，避免前面四个 Phase 过程中争论 architecture。

## 附录 A：新增/修改文件清单预估

- 新增
  - `Documents/Guides/Settings.md`
  - `Documents/Knowledges/ZH/Note_SettingsArchitectureEvaluation.md`
  - `Plugins/Angelscript/Source/AngelscriptTest/Core/AngelscriptSettingsMetadataTests.cpp`
  - `Plugins/Angelscript/Source/AngelscriptTest/Core/AngelscriptSettingsBehaviorTests.cpp`
  - `Plugins/Angelscript/Source/AngelscriptTest/Core/AngelscriptSettingsWarningTests.cpp`
  - `Plugins/Angelscript/Source/AngelscriptTest/Testing/AngelscriptTestSettingsTests.cpp`
  - （可选）`Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptSettingsScope.h`（RAII 备份/还原 helper）
- 修改
  - `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptSettings.h`（仅 Tooltip/Meta/EditCondition 微调）
  - `Plugins/Angelscript/Source/AngelscriptTest/Core/AngelscriptBindConfigTests.cpp`（追加 namespace strip 用例）
  - `Documents/Plans/Plan_StatusPriorityRoadmap.md`（追加快照脚注）
  - `Documents/Guides/TestCatalog.md`（同步新增测试入口）
