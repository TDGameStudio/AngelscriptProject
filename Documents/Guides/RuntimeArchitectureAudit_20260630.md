# AngelscriptRuntime 模块架构问题盘点 — 2026/06/30

## 0. 元数据

- **日期**：2026/06/30
- **范围**：`Plugins/Angelscript/Source/AngelscriptRuntime/` 全模块、对端的 `AngelscriptEditor/HotReload/`、相关 `Build.cs` 与 ThirdParty 目录、相关已记录债务（`TechnicalDebtInventory.md`、`AngelscriptForkStrategy.md`）。
- **方法**：派发 5 个并行只读 agent 调查 5 个独立维度（Core / Bindings / ClassGenerator+HotReload / 横切子系统 / 模块边界+ThirdParty）；agent 触发服务限流后改为直接 Read/Grep/Glob 串行 + 并行批量取证。本盘点不修改任何源代码。
- **基线**：209 cpp 文件 / 15 顶层目录 / 27 个 Build.cs 模块依赖（公共 9 + 私有 15 + 编辑器条件 3）/ ThirdParty AS 2.33 vendored 78 文件 / 121 `Bind_*.cpp` / `FAngelscriptEngine::Get*()` 在 runtime 内部被 329 次调用跨 57 文件。
- **目的**：把分散的 runtime 架构问题汇总到单一索引；不给改进建议，仅描述现状。改进路径走 OpenSpec 单独立项。

## 1. 调查范围与边界

本盘点**只**关注架构层问题（god class、模块边界、抽象层、全局状态、跨模块耦合、ThirdParty 卫生），不重复列举：

- 单个 binding gap（属 `BindGapAuditMatrix.md` 范畴）。
- 单个 .as 编译/运行 bug。
- 文档措辞、注释修复等细节。

## 2. 问题地图（按架构层切分）

### A. God Class / God File

文件膨胀已经成为模块架构的首要观察。下表按字节数排序：

| 文件 | 字节数 | 行数估算 | 角色 |
|------|--------|---------|------|
| `ClassGenerator/AngelscriptClassGenerator.cpp` | 212 199 | ~5 000+ | 动态 UClass 生成 |
| `StaticJIT/AngelscriptBytecodes.cpp` | 205 327 | ~5 000+ | JIT 字节码翻译 |
| `Preprocessor/AngelscriptPreprocessor.cpp` | 145 961 | ~3 500 | 预处理器（单文件） |
| `StaticJIT/AngelscriptStaticJIT.cpp` | 123 213 | ~3 000 | JIT 入口 |
| `ClassGenerator/ASClass.cpp` | 101 964 | ~2 500 | UASClass 实现 |
| `Debugging/AngelscriptDebugServer.cpp` | 99 960 | ~2 500 | DAP 协议（单文件） |
| `StaticJIT/PrecompiledData.cpp` | 97 962 | ~2 400 | JIT 预编译数据 |
| `Binds/Bind_BlueprintType.cpp` | 85 205 | ~2 100 | Blueprint 类型绑定（最大 Bind） |
| `Core/AngelscriptEngine.cpp` | 6 629 行 | — | 主引擎类（god class） |
| `Core/AngelscriptEngine.h` | 1 647 行 | — | 暴露 ~242 处方法形签名 |

观察：`Debugging/`、`Preprocessor/`、`StaticJIT/` 都是"1 主 .cpp + 1–2 辅 .cpp"模式，没有进一步内部模块化。`Binds/Bind_UPackage.cpp` 仅 313 字节（5 个大于 60 KB 的 Bind 与 5 个小于 1 KB 的 Bind 共存，**1000:1 比例**）。

### B. 引擎身份与生命周期

| 编号 | 问题 | 证据 |
|------|------|------|
| B1 | **5+ 个并行的 engine 访问入口** | `Core/AngelscriptEngine.h` 第 223、224、639、641、842 行分别声明 `TryGetCurrentEngine` / `Get` / `TryGetGlobalEngine` / `GetOrCreate` / `Peek`；另有 `FAngelscriptEngineScope` RAII（L851）和 `FAngelscriptEngineContextStack::Push/Peek/Pop` 静态栈（`AngelscriptEngine.cpp:478,500`）。 |
| B2 | **329 处全局访问跨 57 文件** | `FAngelscriptEngine::Get()` / `TryGetCurrentEngine` / `TryGetGlobalEngine` 在 runtime 内被引用 329 次跨 57 文件；与 `TechnicalDebtInventory.md §5` 中"325 sites / 57 files"对账成立。 |
| B3 | **三层入口职责重叠** | `FAngelscriptRuntimeModule::InitializeAngelscript()`（`AngelscriptRuntimeModule.cpp:35`）通过 `bInitializeAngelscriptCalled` bool 守卫并 route 到 `UAngelscriptEngineSubsystem::EnsurePrimaryEngineInitialized()`；`UAngelscriptGameInstanceSubsystem` 又是第三层入口；`AGENTS.md` 自陈"compatibility API"实际上仍在做工作。 |
| B4 | **跨类静态 tick 握手** | `UAngelscriptGameInstanceSubsystem::ActiveTickOwners` 是 `static int32`（`AngelscriptGameInstanceSubsystem.h:43, .cpp:8`），由 `UAngelscriptEngineSubsystem::Tick()` 第 63 行通过 `HasAnyTickOwner()` 读取以决定是否跳过自身 tick。两个 UE 子系统通过隐式静态计数器握手。 |
| B5 | **EngineSubsystem 4 标志位 + 4 个 *ForTesting 接口** | `AngelscriptEngineSubsystem.h:38-41` 公开 `SetStartupEnvironmentOverrideForTesting`、`ClearStartupEnvironmentOverrideForTesting`、`SetInitializeOverrideForTesting`、`ResetInitializeStateForTesting`，且持有 `bInitializedPrimaryEngine` / `bOwnsPrimaryEngine` / `bUsesOverridePrimaryEngine` / `bPushedPrimaryEngineContext` 四个正交布尔。生产类内嵌测试接口。 |

> **后续状态（2026-07-17）**：B5 已由 OpenSpec `cleanup-as-subsystem-test-hooks` 收口。当前 `UAngelscriptSubsystem` 不含 `WITH_DEV_AUTOMATION_TESTS`、`*ForTesting` API 或测试 override 状态；scan-free engine 只由 CQTest fixture 持有，不再接管生产 Subsystem 启动。

### C. 绑定层

| 编号 | 问题 | 证据 |
|------|------|------|
| C1 | **Bind 文件 1000:1 体量比** | 见 §A 表；`Bind_BlueprintType.cpp` 85 KB vs `Bind_UPackage.cpp` 313 字节，最大 5 个 Bind 占绝大部分代码量，分类粒度不一致。 |
| C2 | **Bind 入口函数命名混合** | grep `^void\s+(Bind\|Register\|Init)` 抽样：`BindProperties` / `BindBlueprintEvent` / `BindBlueprintEvent_Prepare` / `BindBlueprintEvent_FromPrep` / `BindAliasedPushArgument` / `BindSoftPtrBaseMethods` 等多套并存，存在 `Bind<Subject>`、`Bind<Subject>_<Stage>`、`Bind<Subject><Detail>` 三种风格。 |
| C3 | **FunctionLibraries 命名碎片化** | `Plugins/Angelscript/Source/AngelscriptRuntime/FunctionLibraries/` 下 18 文件用 3 套后缀（`Library` / `Statics` / `MixinLibrary`），且 7 个文件缺 `Angelscript` 前缀（`GameplayLibrary.h`、`SoftReferenceStatics.h`、`WidgetBlueprintStatics.h`、`WorldCollisionStatics.h`、`SubsystemLibrary.h`、`UAssetManagerMixinLibrary.h`、`InputComponentScriptMixinLibrary.h`）。 |
| C4 | **FunctionLibraries 几乎全 header-only** | 18 文件中仅 `AngelscriptScriptLibrary.cpp` 是 .cpp，其余全部头文件实现 — 与"Library"语义不符，更像 inline mixin 集合。 |

### D. ClassGenerator 与 Editor HotReload 跨模块耦合

| 编号 | 问题 | 证据 |
|------|------|------|
| D1 | **Runtime 内 47 处 editor 分支** | `ClassGenerator/` 下 `WITH_EDITOR` / `GIsEditor` / `bIsHotReload` / `WITH_DEV_AUTOMATION_TESTS` 共 47 次出现，其中 40 次集中在 `AngelscriptClassGenerator.cpp` — 名义上的 runtime 模块大量包含编辑期分支。 |
| D2 | **Editor HotReload 直接 reach 进 Runtime 内部** | `Plugins/Angelscript/Source/AngelscriptEditor/HotReload/` 下 4 个文件共 26 次引用 `AngelscriptRuntime` / `FAngelscriptEngine` / `UASClass` / `AngelscriptClassGen`；`ClassReloadHelper.h:13-14` 直接 include `ClassGenerator/AngelscriptClassGenerator.h` 与 `Core/AngelscriptEngineExtensionRegistry.h`，把 runtime 内部子系统暴露给 editor 模块。 |
| D3 | **Helper 头同时 mix UE Editor 和 Runtime 内部头** | `ClassReloadHelper.h:3-14` 串接 `Editor.h` / `BlueprintActionDatabase.h` / `Kismet2/EnumEditorUtils.h` / `ComponentTypeRegistry.h`（UE Editor）与 runtime `AngelscriptClassGenerator.h` / `AngelscriptEngineExtensionRegistry.h`，跨层抽象在同一 header 上塌陷。 |
| D4 | **Helper 内部直接持有 3 套 *TestHooks 结构** | `ClassReloadHelper.h:30-50` 公开 `FClassReloadHelperClassReloadTestHooks`、`FClassReloadHelperPostReloadTestHooks`、`FClassReloadHelperPerformReinstanceTestHooks`，每套是若干 `TFunction<>` — 测试 hook 不是通过抽象注入而是直接在生产 helper 上挖洞。 |

### E. 模块边界 / Runtime AS 测试框架 / Public 表面

| 编号 | 问题 | 证据 |
|------|------|------|
| E1 | **Runtime/Testing/ 是 Runtime-owned 的 AS 测试框架** | 顶层 `Testing/` 下包含 `IntegrationTest.cpp`、`UnitTest.cpp`、`AngelscriptTest.cpp`、`DiscoverTests.cpp`、`LatentAutomationCommand.cpp/h`、`LatentAutomationCommandClientExecutor.*` 和 `Network/`；这些代码负责 `.as` 测试的发现、注册、执行、latent/network 支持，并通过 `Misc/AutomationTest.h` 桥接 UE Automation。它不是 `AngelscriptTest` 模块的 C++ 单元测试实现；需要审计的是 bridge、编译条件、配置和开发期探针边界。 |
| E2 | **Core/ 内含 Runtime 序列化自检辅助代码与 Editor 概念** | `Core/UnversionedPropertySerializationTest.h/.cpp` 是可选的 Runtime 序列化一致性自检路径（`#define UE_ENABLE_UNVERSIONED_PROPERTY_TEST WITH_EDITORONLY_DATA`）；`Core/AngelscriptEditorDebugBridge.h` 在 runtime/Core 公开 `FAngelscriptEditorCreateBlueprint`、`FAngelscriptEditorGetCreateBlueprintDefaultAssetPath` 这种"Editor"概念委托。 |
| E3 | **Public/ 名实不符** | `Public/` 目录下只有 `UHT/` 子目录、无任何顶层 public 头；公开 API 实际上通过 `ANGELSCRIPTRUNTIME_API` 宏挂在 `Core/` 内部头上。`Build.cs:18-21` 把 `Core/` 与 `Core/Commandlets/` 都加入 `PublicIncludePaths` — runtime 把 commandlet 内部头公开给所有依赖方。 |
| E4 | **顶层 `Hash/` 是单文件 3rd 方** | `Hash/` 仅 `xxhash.h` + `xxhash.inl`，0 个 .cpp，本应位于 `ThirdParty/`。 |
| E5 | **`Subsystem/` 顶层与 Core 子系统命名重叠** | 顶层 `Subsystem/` 含 4 个 header-only：`ScriptEngineSubsystem.h` / `ScriptGameInstanceSubsystem.h` / `ScriptLocalPlayerSubsystem.h` / `ScriptWorldSubsystem.h`（脚本侧 mixin 包装）；`Core/` 内同时有 `AngelscriptEngineSubsystem.*` / `AngelscriptGameInstanceSubsystem.*`（真正的 UE 子系统派生）。两套 "Subsystem" 命名空间并行，归属与命名易混。 |
| E6 | **Build.cs 27 个依赖且 editor 升 public** | Public 9（含 `StructUtils`、`DeveloperSettings`）+ Private 15（含 `Slate`、`SlateCore`、`UMG`、`Sockets`、`Networking`、`PhysicsCore`）；`bBuildEditor` 时 Public 又新增 `UnrealEd` + `EditorSubsystem`，Private 增 `UMGEditor` — runtime 模块在编辑期把 `UnrealEd` 升为公共依赖。`AddGeneratedFunctionBindingModuleWrappers` 还为 `UnrealEd` 4 shards、`UMGEditor` 2 shards 自动生成绑定包装。 |

### F. ThirdParty AS 2.33 fork 卫生

| 编号 | 问题 | 证据 |
|------|------|------|
| F1 | **本地 patch 缺乏统一标记** | `ThirdParty/angelscript/source/`（41 cpp + 37 h = 78 文件）下 0 处出现 `// MODIFIED` / `// PATCHED` / `// HAZELIGHT` / `// PROJECT_CHANGE` 等惯例标记；`HAZELIGHT` / `UE_CHANGE` / `PROJECT_CHANGE` / `AS_VERSION` / `2.38` 五种关键字总计仅 14 次出现跨 8 文件。`AngelscriptForkStrategy.md` 自陈"已偏离过远无法整体升级，选择性吸收 2.38"，但源码层无法定位具体改了什么。 |
| F2 | **2.38 backport 不可追溯** | F1 的 14 次匹配集中在 `as_module.cpp/.h`、`as_typeinfo.cpp/.h`、`as_scriptengine.cpp/.h`、`as_objecttype.h`、`as_restore.cpp` — 仅 8 文件含可识别版本注释，其它 70 文件的本地修改无法从源码侧识别。 |

### G. 配置 / 设置 / 硬编码 UE 符号

| 编号 | 问题 | 证据 |
|------|------|------|
| G1 | **`UAngelscriptSettings` 单 UCLASS 21+ 配置项** | `Core/AngelscriptSettings.h` 215 行包含 21+ `UPROPERTY(Config)`（Preprocessor flags、Math 命名空间、Edit/Blueprint specifier 默认值、float64 切换、Editor 超时、各类 warning 开关），混合了语言层（`MathNamespace`、`bScriptFloatIsFloat64`）、绑定层（`DisabledBindNames`）、编辑器层（`bOpenFolderOnVSCodeSourceLinks`、`VSCodeWorkspacePath`）、调试器层（`DebuggerBlacklistAutomaticFunctionEvaluation`）等多重关注点于一个 UCLASS。 |
| G2 | **`UAngelscriptSettings` 默认值硬编码 UE 函数名** | `AngelscriptSettings.h:203-208` 把 `"AActor.GetWorldTimerManager"`、`"AActor.GetGameInstance"`、`"AActor.GetPhysicsVolume"`、`"AActor.GetActorTimeDilation"` 作为 `DebuggerBlacklistAutomaticFunctionEvaluationWithoutWorldContext` 的代码硬编码默认 — UE 端任意一个改名都需要同步修这里，且没有 `WITH_*` 版本守卫。 |
| G3 | **`Core/AngelscriptSkipBinds.cpp` 18 行硬编码跳过表** | 文件全部内容是 `AS_FORCE_LINK` 注册的 lambda，里面手写 `StaticMesh.GetMinLODForQualityLevels`、`SkeletalMesh.GetMinLODForQualityLevels`、`SourceEffectEQPreset.SetSettings`、`ClothingSimulationInteractorNv`、`NiagaraPreviewGrid`、`GameplayCamerasSubsystem`、`AsyncAction_PerformTargeting` 等 7 项。无每项注释、无版本/平台守卫；UE 升级时易腐烂。 |
| G4 | **配置项行为耦合而非独立** | `bAutomaticImports`（L59）+ `bWarnOnManualImportStatements`（L62）+ Preprocessor 第 758 行"Automatic imports are active, import statements will be ignored" 三处共同决定 `import` 关键字行为；用户层语义来自三处 OR-合成且不可见，对应 `TechnicalDebtInventory.md §17` 的 import gap 实际不仅是"未实现"，是"配置驱动的静默忽略"。 |

### H. 可观测面 / Dump / Console / Log

| 编号 | 问题 | 证据 |
|------|------|------|
| H1 | **Dump 知道每个子系统的内部** | `Dump/AngelscriptStateDump.cpp` 写出 **34 张** distinct `*.csv` 表（grep 结果去重）：覆盖 AS 引擎内部（`AsEngineInternalState` / `AsModuleInternalState` / `AsTypeInternalState` / `AsFunctionInternalState`）、JIT（`JITDatabase` / `StaticJITState` / `PrecompiledData`）、Debugger（`DebugBreakpoints` / `DebugServerState`）、Coverage（`CodeCoverage`）、HotReload（`HotReloadState`）、Editor（`EditorReloadState` / `EditorMenuExtensions`）、Docs（`DocumentationStats`）等。"pure observer"约束之下，仍然必须知道每个子系统的可见状态形状。 |
| H2 | **Editor-concept 表写在 runtime/Dump** | H1 中 `EditorReloadState.csv` 与 `EditorMenuExtensions.csv` 由 runtime/Dump 注册（`AngelscriptStateDump.cpp:269-270` 调 `AddExtensionTableResult`），但概念归属编辑器；与 §E2 中 `AngelscriptEditorDebugBridge.h` 的 editor 概念渗透形成同一 pattern。 |
| H3 | **9 处 CVar / Console 命令分散 8 文件** | grep `FAutoConsoleCommand` / `FAutoConsoleVariableRef` / `TAutoConsoleVariable<` 共 9 次跨 8 文件：`Core/AngelscriptEngine.cpp:135`（`angelscript.UseRecompileAvoidance`）、`Binds/Bind_BlueprintType.cpp:51`（`BindParallelPrepare`）、`Binds/BlueprintCallableReflectiveFallback.cpp:112`（`ReflectiveFallbackUseCache`）、`Dump/AngelscriptCrashSnapshot.cpp:205`、`Dump/AngelscriptDumpCommand.cpp:60`、`StaticJIT/StaticJITDiagnostics.cpp:150`、`Core/AngelscriptSnippet.cpp:227`。无统一注册中心或命名前缀公约。 |
| H4 | **`Testing/` 内的开发期探针注册诊断 CVar** | `Testing/AngelscriptEnumTableBaselineProbe.cpp:59,289` 在 runtime/Testing/ 内部注册 `CVarAutoDump` 和 `GDumpCommand`。这属于 `WITH_DEV_AUTOMATION_TESTS` 下的开发期探针/诊断入口，不应被误称为 C++ 单元测试；仍需明确其编译条件、诊断接口和 Runtime AS 测试框架之间的边界。 |

### I. 跨模块隐式耦合（在 §B 全局之外）

| 编号 | 问题 | 证据 |
|------|------|------|
| I1 | **CodeCoverage 反向耦合 Test Settings 配置** | `CodeCoverage/AngelscriptCodeCoverage.cpp:6` `#include "Testing/AngelscriptTestSettings.h"`；`AngelscriptCodeCoverage.cpp:97` 读取 `bEnableCodeCoverage`，`225,231` 读取 `CoverageExcludePatterns`。这不是 `AngelscriptRuntime` 对 `AngelscriptTest` UE 模块的直接依赖——Settings 类本身位于 Runtime——而是 Runtime-owned Coverage 能力被名为 Test Settings 的配置类控制，形成配置所有权耦合。 |
| I2 | **`AngelscriptDocs` 在 runtime 模块** | `Core/AngelscriptDocs.cpp` 795 行的 doc generator 实现位于 runtime 模块；产生 `DocumentationStats.csv`（H1）。Doc 生成是开发期/编辑期工具职责，但被打包进 cooked runtime。 |
| I3 | **`UnversionedPropertySerializationTest.cpp` 在 Core/** | `Core/UnversionedPropertySerializationTest.cpp` 16 KB 的 Runtime 序列化自检辅助代码 + `UnversionedPropertySerialization.cpp` 1029 行（UE 内部序列化的 reimplementation/校验路径）位于 `Core/` 而非 `Testing/`；与 `#define UE_ENABLE_UNVERSIONED_PROPERTY_TEST WITH_EDITORONLY_DATA` 强相关。它不是 `AngelscriptTest` C++ 单元测试文件，但其 Runtime 编译条件和自检入口仍需单独记录。 |
| I4 | **`AngelscriptEngine` friend 关系反而克制** | grep `friend (class\|struct) FAngelscriptEngine` 仅 4 次跨 3 文件（`AngelscriptBinds.h`、`AngelscriptEngine.h` 自身、`AngelscriptEngineSubsystem.h`）— 这是相对正面的信号，god class 的耦合主要靠 §B2 的全局静态访问而非 friend 网，为后续重构留下空间。 |

### J. Header 卫生 / 构建模式

| 编号 | 问题 | 证据 |
|------|------|------|
| J1 | **`Start/EndAngelscriptHeaders.h` bracketing 跨 55 文件** | `Core/StartAngelscriptHeaders.h` 与 `EndAngelscriptHeaders.h` 是 `#pragma warning(push/disable: 4191/pop)` 的 bracket header；grep 显示在 runtime 模块内 110 次出现跨 **55 文件**（每文件成对）。这是隐式的"AS 头需要警告抑制"的项目级公约，但 AGENTS.md / Build.md / 任何 guide 均未文档化；新代码贡献者必须靠模仿现有 .cpp 来发现这一约束。 |
| J2 | **`Public/` 名实不符（已在 E3，重申其单点暴露面）** | `Public/UHT/NativeModuleFunctionBindingBridge.h` 是 runtime 唯一真正的"公共"头，定义 POD 三元组（`FAngelscriptNativeModuleFunctionBinding` / `FAngelscriptNativeModuleFunctionBindingView` / `FAngelscriptNativeModuleFunctionBindingCallFrame`），明确标注"Higher bits are reserved and require a layout-version bump before use"。除此之外整个 Runtime 公共表面靠 `ANGELSCRIPTRUNTIME_API` 宏挂在 `Core/` 内部头上。 |
| J3 | **`Core/` 顶层杂项头未分组** | `Core/` 顶层包含 `AngelscriptInclude.h` / `AngelscriptSort.h` / `AngelscriptSharedPtr.h` / `Helper_Reification.h` / `FunctionCallers.h` / `FCpuProfilerTraceScoped.h` / `StartAngelscriptHeaders.h` / `EndAngelscriptHeaders.h` 等 8+ 工具头与 50 个核心 .h/.cpp 平铺；无 `Core/Util/` 或 `Core/Internal/` 子目录。 |

### K. Core 内嵌的子模块（Compilation/、Commandlets/）

| 编号 | 问题 | 证据 |
|------|------|------|
| K1 | **`Core/Compilation/` 仅 2 文件却独立子目录** | `Core/Compilation/AngelscriptCompilationContext.cpp/.h` + `AngelscriptCompilationEvents.cpp/.h` — 4 文件构成"编译上下文"子模块，但 `AngelscriptCompilationContext.h:4` 直接 include `AngelscriptEngine.h`（即 §A 中 1647 行的 god 头），`ECompileType`/`ECompileResult` 枚举仍定义在 Engine.h 中。子目录在物理上分了，逻辑上仍未脱离 god engine。 |
| K2 | **`Core/Commandlets/` 在公共 include 路径** | `Core/Commandlets/` 包含 `AngelscriptAllScriptRootsCommandlet.*` + `AngelscriptTestCommandlet.*` 共 4 文件；`AngelscriptRuntime.Build.cs:20-21` 把 `Core/Commandlets/` 同时加入 `PublicIncludePaths` 与 `PrivateIncludePaths` — runtime 公开了 commandlet 头给所有依赖方。 |
| K3 | **221 cpp vs AGENTS.md 209** | 实际 `find -name "*.cpp"` 在 runtime 模块下计 221 文件，AGENTS.md 自陈 209 — 文档与现状漂移 ~6%。 |

## 3. 四个最值得首先动刀的根问题

按"动它能解锁多少其它清理"的逻辑排序（前三项是力学/结构根因，第四项是与时间脆性相关的独立维度）：

1. **§B god engine 与全局访问（B1+B2+B3+B5）**
   `AngelscriptEngine` 1647/6629 行 + 5 个访问入口 + 329 次跨模块全局调用 + 三层 init 重复 + 测试接口嵌入生产类，是几乎所有其它问题的力学根源。这与 `TestArchitectureAudit_20260630.md §3.3` 提到的"测试模块入口 + 全局引擎"是同一根问题的两面。

2. **§A god file 群（5 个 100 KB+ 单文件 + ClassGenerator 5000+ 行 + Preprocessor / DebugServer 单文件）**
   把 §C/§D/§E/§F 的清理都焊死在原模式上 — 任何模块化、子系统拆分都需要先把这些 .cpp 拆开。

3. **§D + §E1 + §E2 + §I1 + §I2 + §H4 模块边界塌陷（Editor 概念渗透 Runtime + AS 测试框架的宿主桥接 + 反向跨模块依赖）**
   `AngelscriptEditorDebugBridge.h`、`UnversionedPropertySerializationTest.*`、Runtime-owned `Testing/` 框架、`Build.cs` editor 公共依赖、`ClassGenerator` 47 处 editor 分支，加上**反向耦合**——`CodeCoverage` 直接读 `UAngelscriptTestSettings`、`AngelscriptDocs` 嵌入 runtime、`Testing/` 下探针注册诊断 CVar，`Dump` 写出 `EditorReloadState.csv` 等 editor 表——共同导致 Runtime 的能力边界表达不清。这里需要拆分的是 owner、bridge、编译条件和配置来源，不是把 AS 测试框架当成 `AngelscriptTest` C++ 单测目录。

4. **§G 配置与硬编码 UE 符号脆性（fragility 是另一个独立维度）**
   `UAngelscriptSettings` 一个 UCLASS 承担 21+ 关注点；`DebuggerBlacklistAutomaticFunctionEvaluationWithoutWorldContext` 默认值硬编码 4 个 `AActor.*` 函数名；`AngelscriptSkipBinds.cpp` 18 行硬编码 7 个 UE 5 类型/函数名 — 这是与 §1-§3 力学不同的另一类问题：UE 升级时静默腐烂。`AngelscriptForkStrategy.md` 谈到了 ThirdParty fork 的版本管理，但配置层的 UE 符号绑定没有相同纪律。

## 4. 与现有文档的关系

- 与 `Documents/Guides/TechnicalDebtInventory.md`：本盘点 §B2（329 sites/57 files）与 TDI §5（325/57）数字对账成立，补充了 god class 的代码尺寸数据；TDI §17 的 import gap 在本盘点 §A 中以 `AngelscriptPreprocessor.cpp:758,3555` 行号定位，并由 §G4 进一步揭示 import 行为是**配置驱动的静默忽略**，不仅是"未实现"。
- 与 `Documents/Guides/AngelscriptForkStrategy.md`：本盘点 §F 显示 fork 策略缺乏源码级 patch 追踪机制，与 strategy 文档自陈的"selective 2.38 backport"之间有可见落差；§G2/§G3 进一步暴露**配置层与 SkipBinds 的 UE 符号绑定缺乏与 ThirdParty 同等的版本纪律**。
- 与 `Documents/Guides/BindGapAuditMatrix.md`：本盘点 §C 关注 Bind 体量与命名一致性，与 BindGapAudit 关注"哪些函数还没绑"互补；§G3 中的 `AngelscriptSkipBinds.cpp` 是 BindGap 的反面（"哪些函数被显式跳过"）。
- 与 `Documents/Guides/TestArchitectureAudit_20260630.md`：本盘点 §B 是测试盘点 §3.3（运行模型）的根因侧；测试模块的引擎污染链直接来自本盘点的 god engine。**§I1 的反向耦合（CodeCoverage→TestSettings）也对测试盘点的 §C 模块依赖部分形成补充证据**。
- 与 `AGENTS.md`：本盘点 §E5 指出 `Subsystem/` 顶层与 `Core/` 内 Subsystem 的命名重叠；§K3 指出 cpp 数量已从 209 漂移到 221；§J1 的 `Start/EndAngelscriptHeaders.h` bracketing 是项目级未文档化的公约。

## 5. 下一步可选项

不强制顺序，留给后续 OpenSpec 立项或路线图阶段决策：

- 针对 §3.1（god engine 拆分 + 全局访问点收敛）起草 OpenSpec change proposal，把 5 个访问入口 + ContextStack + EngineScope 的语义关系先冻结成 spec；§I4 的克制 friend 关系是有利信号。
- 把 §A 的 god file 表与 §K3 的 cpp 数量漂移纳入 `TechnicalDebtInventory.md`，作为后续 refactor 的稳定锚点。
- 围绕 §3.3 评估"editor concept 从 runtime 抽离"的可行性 — `AngelscriptEditorDebugBridge`、`AngelscriptDocs`、Dump 中的 `EditorReloadState/EditorMenuExtensions` 是最小入口集合。
- ThirdParty fork 引入统一 patch tag 约定（§F1）— 这件事独立于其它清理，可单独推进。
- 继续收口 Runtime-owned `Testing/` 的 UE Automation bridge、`WITH_DEV_AUTOMATION_TESTS` 探针和配置依赖；不把 AS 测试框架迁移到 `AngelscriptTest`。同时收缩 §I1 的反向依赖（CodeCoverage 应自带配置而非直接读 TestSettings）。
- 将 `UAngelscriptSettings` 拆为按层（语言层 / 绑定层 / 编辑器层 / 调试器层）的多个配置 UCLASS（§G1），并把硬编码 UE 符号（§G2、§G3）迁移到 ini 默认或加 `WITH_*` 守卫。
- 把 `Start/EndAngelscriptHeaders.h` bracketing 公约（§J1，55 文件）写入 `Build.md` 或新建 `RuntimeHeaderConventions.md`，避免新贡献者靠模仿摸索。
- 对 Dump 的 34 张 CSV 表（§H1）做一次范围收敛：editor-concept 表是否从 runtime/Dump 移到 editor 模块；按子系统拆分为多个 dump provider 而非一个写出全部。

## 6. 修订记录

- 2026/06/30 第一轮：基于直接 Read/Grep/Glob 调查（agent 限流 fallback）创建初版，覆盖 §A–§F 六个维度。
- 2026/06/30 第二轮：补充 §G–§K 五个新维度（配置硬编码、可观测面、跨模块隐式耦合、Header 卫生、Core 内嵌子模块），更新 §3 三个根问题为四项（新增配置脆性根问题），更新 §4 与 §5 的索引。
