# Angelscript Engine Extension 与 Hook 速查

> 范围：截至 2026-07-06，当前 `Plugins/Angelscript` 已存在的扩展点和 hook 点。
> 本文优先记录当前实现；仍在 OpenSpec 中规划、尚未落地的迁移会单独标注。

## 目标

当前 AS 插件的扩展性不是单一入口，而是几层不同性质的扩展边界：

- `IAngelscriptExtension`：推荐用于“随某个 `FAngelscriptEngine` 生命周期 attach/detach 的长期服务”。
- `FAngelscriptEngine` 自有 delegate hooks：暴露编译、热重载、调试、资源、类生成等 per-engine 事件。
- UE Editor 扩展点：接入 `DirectoryWatcher`、`UToolMenus`、Source Navigation、Content Browser、Commandlet、对象保存等编辑器系统。
- 观察/导出 hooks：用于诊断、dump、编译事件记录，不把 Runtime 私有状态交给外部模块。
- 测试 hook：只服务自动化测试，不能当生产扩展 API 使用。

## 总体分层

```text
UE process
|
+-- UE module lifecycle
|   |
|   +-- AngelscriptRuntime.StartupModule()
|   |   +-- registers FAngelscriptCrashSnapshotExtension
|   |   `-- registers FAngelscriptCodeCoverageExtension
|   |
|   +-- AngelscriptEditor.StartupModule()
|       +-- registers UE editor hooks
|       +-- registers editor-owned AS engine extensions
|       `-- registers dump/debug/menu bridges
|
+-- UE subsystem lifecycle
|   |
|   `-- UAngelscriptEngineSubsystem
|       +-- owns or resolves primary FAngelscriptEngine
|       +-- initializes / ticks / shuts down the engine
|       `-- suppresses fallback ownership when game-instance owner exists
|
+-- FAngelscriptEngine lifetime
    |
    +-- Initialize()
    |   +-- PreInitialize_GameThread()
    |   +-- Initialize_AnyThread()
    |   +-- PostInitialize_GameThread()
    |   `-- FAngelscriptEngineExtensionRegistry.AttachEngine()
    |
    +-- Runtime work
    |   +-- compile hooks
    |   +-- class generation hooks
    |   +-- reload hooks
    |   +-- debug hooks
    |   `-- source provider / bind / NativeModuleFunctionAddress hooks
    |
    `-- Shutdown()
        `-- FAngelscriptEngineExtensionRegistry.DetachEngine()
```

## Engine Extension Registry

核心生命周期 API：

- `IAngelscriptExtension`
- `FAngelscriptEngineExtensionRegistry`
- `OnEngineAttached(FAngelscriptEngine& Engine)`
- `OnEngineDetached(FAngelscriptEngine& Engine)`

源码位置：

- `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngineExtensionRegistry.h`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngineExtensionRegistry.cpp`

当前行为：

- `RegisterExtension()` 保存一个 `TSharedRef<IAngelscriptExtension>`。
- 注册时如果已经存在 current engine，会立即调用该 extension 的 `OnEngineAttached()`。
- `AttachEngine()` 会先在锁内复制当前 extension 列表，再在锁外逐个调用 `OnEngineAttached()`。
- `DetachEngine()` 同样先复制列表，再在锁外逐个调用 `OnEngineDetached()`。
- `ReplayCurrentEngine()` 会把当前 engine replay 给所有已注册 extension。
- `DetachCurrentEngine()` 是 `ReplayCurrentEngine()` 的显式反向操作。
- `UnregisterExtension()` 只从注册表移除 extension；如果需要确定性解绑，应该依赖 engine shutdown 或自行安排 detach。

### Attach 流程

```text
extension module startup
|
|  FAngelscriptEngineExtensionRegistry::Get().RegisterExtension(Ext)
|        |
|        +-- no current engine
|        |   `-- stored only; attaches later
|        |
|        `-- current engine exists
|            `-- Ext.OnEngineAttached(CurrentEngine)
|
engine Initialize() / InitializeWithoutInitialCompile()
|
`-- FAngelscriptEngineExtensionRegistry::Get().AttachEngine(Engine)
    |
    +-- ExtA.OnEngineAttached(Engine)
    +-- ExtB.OnEngineAttached(Engine)
    `-- ExtN.OnEngineAttached(Engine)
```

### Detach 流程

```text
engine Shutdown()
|
`-- FAngelscriptEngineExtensionRegistry::Get().DetachEngine(Engine)
    |
    +-- ExtA.OnEngineDetached(Engine)
    +-- ExtB.OnEngineDetached(Engine)
    `-- ExtN.OnEngineDetached(Engine)
```

### 当前已落地的 extension

| Extension | Owner | Hook 点 | 作用 |
|---|---|---|---|
| `FAngelscriptCrashSnapshotExtension` | `AngelscriptRuntime/Dump` | `OnEngineAttached()`、`OnEngineDetached()`、`FCoreDelegates::OnHandleSystemError` | 按 active `FAngelscriptEngine` 实例计数管理全局 crash handler；首个 engine attach 时注册崩溃快照 handler，最后一个 engine detach 或 module unload 时注销，快照 JSON 格式保持不变。 |
| `FAngelscriptCodeCoverageExtension` | `AngelscriptRuntime/Extension/CodeCoverage` | `OnEngineAttached()`、`OnEngineDetached()`、`FAngelscriptCodeCoverageExtension::GetForEngine()`、AS line callback | 按 `FAngelscriptEngine` 实例管理覆盖率对象，编译后映射可执行行，脚本行回调记录命中，并在停止 recording 时只导出 `coverage_summary.json` 供外部工具展示。 |
| `FClassReloadHelperExtension` | `AngelscriptEditor/HotReload` | `GetOnStructReload()`、`GetOnClassReload()`、`GetOnDelegateReload()`、`GetOnLiteralAssetReload()`、`GetOnEnumChanged()`、`GetOnEnumCreated()`、`GetOnFullReload()`、`GetOnPostReload()` | 记录 AS 热重载后的类/结构/枚举/委托/资源替换状态，并刷新 Blueprint / ClassViewer / ComponentRegistry 等编辑器系统。 |
| `FScriptEditorMenuPostReloadExtension` | `AngelscriptEditor/EditorMenuExtensions` | `GetOnPostReload()` | full reload 后重新注册脚本定义的编辑器菜单扩展。 |

### 已规划但未落地的 extension

| OpenSpec | 计划 extension | 当前状态 |
|---|---|---|
| `refactor-as-execution-context` | service/extension migration rule | 记录长期 hook 订阅者应通过 `IAngelscriptExtension` 或等价 engine-owned service 边界 attach/detach。 |

## Engine-Owned Hooks

`FAngelscriptEngine` 自己持有主要 Runtime hook delegate。这些 hook 是 per-engine 状态，不再是全局静态状态。

源码位置：

- `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.h`

推荐订阅模式：

```text
long-lived subscriber
|
+-- implement IAngelscriptExtension
|   |
|   +-- OnEngineAttached(Engine)
|   |   `-- add delegate handlers and store FDelegateHandle values
|   |
|   `-- OnEngineDetached(Engine)
|       `-- remove stored FDelegateHandle values from that same Engine
|
`-- register through FAngelscriptEngineExtensionRegistry
```

短生命周期测试可以直接 bind delegate。生产代码里长期订阅 hook 时，不建议写 `FAngelscriptEngine::Get().GetOnXxx().Add...`，因为这会隐藏 engine 实例和解绑责任。

### Hook 分组

| 分组 | Hook | 作用 |
|---|---|---|
| 编译生命周期 | `GetPreCompile()`、`GetPostCompile()`、`GetOnInitialCompileFinished()` | 粗粒度观察一次编译 run 的开始、结束和初始编译完成。 |
| 类生成 | `GetClassAnalyze()`、`GetPreGenerateClasses()`、`GetPostCompileClassCollection()` | 在类分析、生成前、生成后观察或追加检查。 |
| 热重载 | `GetOnClassReload()`、`GetOnStructReload()`、`GetOnDelegateReload()`、`GetOnEnumCreated()`、`GetOnEnumChanged()`、`GetOnLiteralAssetReload()`、`GetOnFullReload()`、`GetOnPostReload()` | Editor 热重载、Blueprint 刷新、资源替换和 reload 诊断。 |
| 调试支持 | `GetDebugCheckBreakOptions()`、`GetDebugBreakFilters()`、`GetDebugObjectSuffix()` | DebugServer / Editor 对断点、过滤器、对象显示后缀的定制。 |
| Runtime 对象支持 | `GetDynamicSpawnLevel()`、`GetComponentCreated()` | Spawn level 和 component 创建时机接入。 |
| 资源创建 | `GetOnLiteralAssetCreated()`、`GetPostLiteralAssetSetup()` | 观察脚本 literal asset 创建与初始化。 |

### 编译 hook 触发示意

```text
FAngelscriptEngine::CompileModules()
|
+-- FAngelscriptCompilationEvents::Broadcast(CompileBegin)
+-- Engine.GetPreCompile().Broadcast()
|
+-- preprocess / parse / generate types / generate functions / compile code
|   |
|   `-- FAngelscriptCompilationEvents::Broadcast(phase events)
|
+-- Engine.GetPreGenerateClasses().Broadcast(CompiledModules)
+-- class generator handoff
+-- Engine.GetPostCompile().Broadcast()
`-- FAngelscriptCompilationEvents::Broadcast(CompileEnd)
```

## Compilation Event Bus

`FAngelscriptCompilationEvents` 是进程级观察总线，用于结构化编译和预处理事件。

源码位置：

- `Plugins/Angelscript/Source/AngelscriptRuntime/Core/Compilation/AngelscriptCompilationEvents.h`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Core/Compilation/AngelscriptCompilationEvents.cpp`

事件类型：

- `CompileBegin`
- `CompileEnd`
- `PreprocessProcessChunks`
- `PreprocessPostProcessCode`
- `CompileModuleAssembly`
- `CompileModuleParse`
- `CompileModuleGenerateTypes`
- `CompileModuleGenerateFunctions`
- `CompileModuleLayout`
- `CompileModuleCompileCode`
- `CompileModuleGlobals`
- `CompileClassGenerationHandoff`

适用场景：需要结构化诊断、统计、timeline、测试观察，而不是直接修改 engine 状态。

```text
listener
|
+-- FAngelscriptCompilationEvents::RegisterListener(lambda)
|       |
|       `-- receives FAngelscriptCompilationEvent
|           +-- Phase
|           +-- CompileType / CompileResult
|           +-- ModuleNames / FileNames
|           +-- counts and thread info
|           `-- PreprocessorSummary
|
`-- FAngelscriptCompilationEvents::UnregisterListener(Handle)
```

## Source Provider 扩展点

Engine 通过 `FAngelscriptEngineDependencies` 接受可注入的 source provider。

源码位置：

- `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptSourceProvider.h`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.h`

关键 API：

- `IAngelscriptSourceProvider::FindSources()`
- `IAngelscriptSourceProvider::LoadSourceText()`
- `IAngelscriptSourceProvider::QuerySourceState()`
- `FAngelscriptDiskSourceProvider`
- `FAngelscriptEngineDependencies::SourceProvider`

```text
FAngelscriptEngineDependencies
|
`-- SourceProvider
    |
    +-- FindSources(script roots, skip dev, skip editor)
    +-- LoadSourceText(source)
    `-- QuerySourceState(source)
```

适用场景：

- 测试里注入虚拟脚本来源。
- 未来支持非磁盘脚本来源。
- 生成式或缓存式 source pipeline。

不适用场景：

- Editor 热重载 UI 行为。热重载仍由 DirectoryWatcher 收集文件变化，再交给 engine reload 队列。

## Additional Compile Checks

`FAngelscriptAdditionalCompileChecks` 是类生成阶段的校验扩展点。

源码位置：

- `Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator/AngelscriptAdditionalCompileChecks.h`

API：

- `ScriptCompileAdditionalChecks(ModuleDesc, ClassDesc)`
- `PostReloadAdditionalChecks(bFullReload, ModuleDesc, ClassDesc)`

`FAngelscriptEngine` 用 `AdditionalCompileChecks` 按 `UClass*` 保存这些检查。只有当校验天然绑定到某个 generated class 边界时才适合使用它。一般编译观察应使用 `FAngelscriptCompilationEvents`；长期服务应使用 `IAngelscriptExtension`。

## State Dump 扩展点

`FAngelscriptStateDump::OnDumpExtensions` 允许其他模块在 Runtime dump 流程中添加自己的表，而不让 Runtime include Editor 或其他模块。

源码位置：

- `Plugins/Angelscript/Source/AngelscriptRuntime/Dump/AngelscriptStateDump.h`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Dump/AngelscriptStateDump.cpp`
- `Plugins/Angelscript/Source/AngelscriptEditor/Dump/AngelscriptEditorStateDump.cpp`

```text
FAngelscriptStateDump::DumpAll(Engine, OutputDir)
|
+-- dump runtime tables
+-- dump diagnostics / binds / JIT / debug / coverage tables
+-- OnDumpExtensions.Broadcast(ResolvedOutputDir)
|   |
|   `-- editor module writes editor-specific CSV files
|
`-- dump summary
```

这是诊断扩展的推荐样板：Runtime 只提供窄 callback；扩展模块用公开 API 写自己的输出。

## Native Module Function Binding Hook

目标模块函数地址绑定使用 Unreal `IModularFeatures`，不是 `IAngelscriptExtension`。

源码位置：

- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_NativeModuleFunctionBinding.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/FunctionBinding/NativeModuleFunctionBindingBridge.h`
- `Plugins/Angelscript/Source/AngelscriptUHTTool/AngelscriptFunctionBindingCodeGenerator.cs`

Runtime 订阅点：

- `IModularFeatures::Get().OnModularFeatureRegistered()`
- `FAngelscriptNativeModuleFunctionBindingBridge::FeatureName()`
- `FCoreDelegates::OnPreExit`

生成模块侧：

- UHT emit `NativeModuleFunctionAddress` shard。
- shard 注册一个 modular feature，携带 POD function bindings 和 thunk 指针。
- Runtime 验证 feature 后，把可用 function binding 注入 AS bind 表。

```text
UHT generated native-module-function-address shard
|
`-- IModularFeatures.RegisterModularFeature(AngelscriptNativeModuleFunctionBinding)
    |
    `-- Runtime OnModularFeatureRegistered
        |
        +-- validate layout version
        +-- resolve target UClass / UFunction data
        +-- bind generic AS trampoline
        `-- GAngelscriptNativeModuleFunctionBindingGenericThunk()
            `-- generated thunk invokes native function
```

这个 hook 对 ABI 很敏感。修改 `FAngelscriptNativeModuleFunctionBinding` 或 `FAngelscriptNativeModuleFunctionBindingView` 布局时，必须同步更新 `native-module-function-binding-layout-version.txt`、runtime bridge header、UHT emit 和测试。

## Bind Registration Hook

手写绑定和生成绑定都通过 `FAngelscriptBinds::FBind` 按 `EOrder` 排序注册。

常见形态：

```text
static / AS_FORCE_LINK FAngelscriptBinds::FBind Bind_X(
    FName(TEXT("Bind_X")),
    Order,
    []()
    {
        // Register AS types / functions / properties.
    });
```

这是 bind phase 扩展面，适合把 C++ 类型、函数和属性暴露给 AS。不要用它持有长期 engine reload hook 订阅；长期订阅应该走 `IAngelscriptExtension`。

## Editor / UE Hook 点

`AngelscriptEditor` 主要通过 UE 编辑器扩展 API 接入。大部分注册发生在 `FAngelscriptEditorModule::StartupModule()`。

源码位置：

- `Plugins/Angelscript/Source/AngelscriptEditor/Core/AngelscriptEditorModule.cpp`
- `Plugins/Angelscript/Source/AngelscriptEditor/HotReload/`
- `Plugins/Angelscript/Source/AngelscriptEditor/SourceNavigation/`
- `Plugins/Angelscript/Source/AngelscriptEditor/EditorMenuExtensions/`
- `Plugins/Angelscript/Source/AngelscriptEditor/ContentBrowser/`
- `Plugins/Angelscript/Source/AngelscriptEditor/BlueprintImpact/`
- `Plugins/Angelscript/Source/AngelscriptEditor/CodeGen/`

| Hook | Owner | 作用 |
|---|---|---|
| `FCoreDelegates::GetOnPostEngineInit()` | Editor module | 延迟需要 engine/editor 系统就绪的工作。 |
| `IDirectoryWatcher::RegisterDirectoryChangedCallback_Handle()` | Editor hot reload | 监听 script roots 并排队 reload 候选。 |
| `FCoreUObjectDelegates::OnObjectPreSave` | Editor module | 接入 script literal asset 保存逻辑。 |
| `UToolMenus::RegisterStartupCallback()` / `UToolMenus::ExtendMenu()` | Editor module / menu extensions | 注册插件菜单命令和脚本定义菜单项。 |
| `FSourceCodeNavigation::AddNavigationHandler()` | Source navigation | 把 AS 生成的反射对象导航回 `.as` 文件位置。 |
| `UContentBrowserDataSource` registration path | Content browser | 让 `.as` 文件出现在 Content Browser。 |
| `UCommandlet` entry points | BlueprintImpact / LearningTrace | 命令行执行编辑器工具。 |
| `FAngelscriptEditorDebugBridge` delegates | Runtime-to-editor bridge | 让 Runtime/debug 路径请求 Editor 列资源或创建 Blueprint，避免 Runtime 直接依赖 Editor。 |

### Editor hook 流程

```text
AngelscriptEditor.StartupModule()
|
+-- register lightweight callbacks only
|   |
|   +-- OnPostEngineInit -> OnEngineInitDone()
|   +-- DirectoryWatcher callbacks
|   +-- OnObjectPreSave
|   +-- UToolMenus startup callback
|   +-- SourceCodeNavigation handler
|   +-- Debug bridge lambdas
|   `-- StateDump extension
|
`-- later, when UE/editor systems fire callbacks
    |
    +-- queue reload files
    +-- register content browser data source
    +-- build menus
    +-- open source locations
    `-- write editor dump tables
```

## Script-Level 扩展点

这些是用户/脚本侧扩展机制，不是 C++ engine hook：

- `UScriptEditorMenuExtension`：脚本定义 Editor 菜单项，通过反射函数和菜单元数据挂到 UE 菜单。
- 脚本继承 Unreal 类和 subsystem：通过生成 `UClass` / subsystem 类型扩展运行时行为。
- Function Library / Mixin 绑定：`FunctionLibraries/` 和 bind/default reflection 把 helper 暴露成 AS namespace 或 mixin。
- Script tests：当前仍以全局函数测试入口为主；`refactor-as-script-test-suite-runner` 计划迁移到 class-based suite。

## Test-Only Hooks

代码里仍有若干 `ForTesting`、`Set...Override`、`TestAccess` hook。这些只服务自动化测试，不是生产扩展 API。`UAngelscriptSubsystem` 已移除测试专用接口；Subsystem 测试使用 Test 模块持有的 engine scope。

典型例子：

- `FAngelscriptRuntimeModule::SetInitializeOverrideForTesting()`
- `FAngelscriptEditorModuleTestAccess::SetDirectoryWatcherResolver()`
- `AngelscriptSourceNavigation::SetOpenLocationOverrideForTesting()`
- `FAngelscriptEditorMenuExtensionTestAccess::*`
- `FAngelscriptClassReNativeRuntimeLinkeds::SetCoreReNativeRuntimeLinkedTargetIniOverrideForTesting()`

生产扩展设计不应依赖这些符号。

## 如何选择扩展点

```text
Need to own state for each FAngelscriptEngine?
|
+-- yes --> IAngelscriptExtension
|
`-- no
    |
    +-- need compile/preprocess telemetry?
    |   `-- FAngelscriptCompilationEvents
    |
    +-- need to observe or react to class/reload/debug events?
    |   `-- engine-owned delegate hooks, preferably via IAngelscriptExtension
    |
    +-- need custom script source storage?
    |   `-- IAngelscriptSourceProvider through FAngelscriptEngineDependencies
    |
    +-- need to add diagnostic dump files?
    |   `-- FAngelscriptStateDump::OnDumpExtensions
    |
    +-- need to expose native C++ functions/types to AS?
    |   `-- FAngelscriptBinds::FBind / Bind_*.cpp
    |
    +-- need generated NativeRuntimeLinked native bindings from another module?
    |   `-- UHT generated function table / IModularFeatures NativeModuleFunctionAddress feature
    |
    +-- need editor UI/tooling integration?
        `-- UE editor hooks: UToolMenus, SourceCodeNavigation, DirectoryWatcher,
            ContentBrowser, Commandlet
```

## 当前扩展性状态

- Extension registry 已支持 late registration 和 current engine replay。
- 当前最完整的 engine extension 样板是 `FClassReloadHelperExtension`。
- `FScriptEditorMenuPostReloadExtension` 是单 hook attach/detach 的轻量样板。
- Runtime 诊断服务中，Code coverage 已通过 `FAngelscriptCodeCoverageExtension` 迁入 runtime extension；Crash snapshot 已通过 `FAngelscriptCrashSnapshotExtension` 迁入 runtime extension，并保留进程级 crash handler / JSON 输出格式。
- `FAngelscriptEngine` hook delegate 已经是 per-engine；新长期订阅者不应再假设 process-wide static delegate。
- 旧代码里仍有不少直接 global engine 访问；`refactor-as-execution-context` 记录了向显式 context / service 边界迁移的方向。

## 速查表

| Surface | 生命周期 | 适合做什么 | 不适合做什么 |
|---|---|---|---|
| `IAngelscriptExtension` | Engine attach/detach | per-engine 长期服务、长期 hook 订阅 | 一次性绑定注册。 |
| `FAngelscriptEngine` delegates | 单个 engine 实例 | 编译、热重载、调试、资源事件订阅 | 无解绑计划的长期订阅。 |
| `FAngelscriptCompilationEvents` | 进程级观察总线 | 结构化 telemetry、诊断、测试观察 | 修改 engine 状态。 |
| `IAngelscriptSourceProvider` | Engine dependency | 替换脚本来源、测试注入、虚拟 source | Editor 热重载 UI 行为。 |
| `FAngelscriptStateDump::OnDumpExtensions` | Dump 调用期间 | 增加额外 CSV dump 表 | 读取 Runtime 私有状态。 |
| `FAngelscriptBinds::FBind` | Bind phase | 暴露 AS 类型、函数、属性 | Runtime 生命周期订阅。 |
| `IModularFeatures` NativeModuleFunctionAddress bind | Module feature lifetime | 跨模块生成 NativeRuntimeLinked bind | 未版本化的 ABI 改动。 |
| UE editor hooks | Editor module lifetime | 菜单、导航、Content Browser、文件监听 | Runtime-only 代码依赖 Editor。 |
| `ForTesting` / `TestAccess` hooks | 自动化测试期间 | 可控测试注入 | 生产扩展 API。 |
