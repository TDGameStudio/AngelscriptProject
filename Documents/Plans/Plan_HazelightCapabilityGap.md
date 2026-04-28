# 当前插件相对 Hazelight 功能差距盘点计划

## 背景与目标

### 背景

当前仓库的主目标是把 `Plugins/Angelscript` 整理为可复用、可验证、可维护的 Unreal Angelscript 插件；对照基线则是 `AgentConfig.ini` 中 `References.HazelightAngelscriptEngineRoot` 指向的 Hazelight Angelscript 引擎版实现。

当前插件已经具备较完整的运行时、编辑器与测试骨架，例如：

- `Plugins/Angelscript/Source/AngelscriptRuntime/` 已包含预处理器、类生成、绑定系统、StaticJIT、DebugServer、CodeCoverage、Commandlet 与测试框架。
- `Plugins/Angelscript/Source/AngelscriptEditor/` 已包含 Content Browser 数据源、菜单扩展、Source Navigation、BlueprintMixinLibrary、ScriptEditorSubsystem。
- `Plugins/Angelscript/Source/AngelscriptTest/` 已形成较完整的场景测试、绑定测试、内部测试与示例测试。

Hazelight 基线则不仅有插件模块，还包含明确的引擎侧改造、脚本示例目录、VS Code 工作流和更完整的生产化工具链入口：

- `HazelightAngelscriptEngineRoot/Engine/Plugins/Angelscript/Source/AngelscriptCode`
- `HazelightAngelscriptEngineRoot/Engine/Plugins/Angelscript/Source/AngelscriptEditor`
- `HazelightAngelscriptEngineRoot/Engine/Plugins/Angelscript/Source/AngelscriptLoader`
- `HazelightAngelscriptEngineRoot/Engine/Plugins/AngelscriptGAS`
- `HazelightAngelscriptEngineRoot/Engine/Plugins/AngelscriptEnhancedInput`
- `HazelightAngelscriptEngineRoot/Script-Examples`

### 目标

本文只做 **功能差距盘点**，用于后续 P3 / P6「UEAS2 能力对齐」阶段拆分工作。

约束如下：

- 只记录 **问题、差距、证据、影响范围**。
- **不在本文提供解决方案、实现路径或技术设计。**
- 明确区分 **引擎侧能力差距**、**插件侧能力差距**、**测试/工作流差距**。
- 明确标记 **不应再被误判为差距** 的项目，避免重复开题。

## 范围与边界

- 对比对象：当前 `Plugins/Angelscript` 与 `References.HazelightAngelscriptEngineRoot` 指向仓库中的 Angelscript 相关核心能力。
- 纳入范围：运行时能力、引擎/插件边界、子系统支持、网络复制与 RPC、编辑器工具链、调试工作流、测试与验证入口、脚本示例与上手路径。
- 排除范围：`EmmsUI` 之类的外围生态插件；AngelScript 上游语言本体；与当前插件主线无关的宿主项目逻辑。
- 对比口径：如果某项能力只在 Hazelight 的 **引擎补丁** 中成立，则应归类为"引擎侧差距"，不能直接视为普通插件缺口。

## 当前事实状态快照

### 当前插件快照

- 模块结构：`AngelscriptRuntime`、`AngelscriptEditor`、`AngelscriptLoader`、`AngelscriptTest`
- 关键能力：预处理器、类生成、绑定系统、StaticJIT、DebugServer、CodeCoverage、`AngelscriptTestCommandlet`、`AngelscriptAllScriptRootsCommandlet`
- 编辑器入口：`ScriptEditorMenuExtension`、`ScriptAssetMenuExtension`、`ScriptActorMenuExtension`、`ScriptEditorSubsystem`
- 验证入口：`Plugins/Angelscript/Source/AngelscriptRuntime/Testing/` 与 `Plugins/Angelscript/Source/AngelscriptTest/`

### Hazelight 基线快照

- 模块结构：`AngelscriptCode`、`AngelscriptEditor`、`AngelscriptLoader`
- 扩展插件：`AngelscriptGAS`、`AngelscriptEnhancedInput`
- 核心配套：`Script-Examples/`、VS Code 调试/导航工作流、引擎侧 UHT / CoreUObject / Editor 改造、FakeNetDriver、CodeCoverage、Commandlet

## 对比结论总览

| 能力域 | Hazelight 基线 | 当前插件 | 结论 |
| --- | --- | --- | --- |
| 引擎侧扩展点（UHT / CoreUObject / Blueprint 编译链） | 明确存在于 `HazelightAngelscriptEngineRoot/Engine/Source/...` | 当前仓库目标是插件化整理，未形成同等级引擎侧能力基线 | **明显差距** |
| Script Subsystem 闭环完整性 | `UScriptWorldSubsystem` / `UScriptGameInstanceSubsystem` / `UScriptLocalPlayerSubsystem` / `UScriptEngineSubsystem` / `UScriptEditorSubsystem` 都在基线能力面中 | 当前插件已有全部基类入口；`WorldSubsystem` / `GameInstanceSubsystem` 已通过 `Plan_FunctionalGapClosure.md` Phase 2 修复编译路径并转为正例测试（2026-04-22）；`LocalPlayer` / `Engine` 仅见基类、缺少场景验证 | **已闭环（World/GameInstance）；LocalPlayer/Engine 待验证** |
| 全局变量 / Console Variable 对齐 | Hazelight 基线在 `Bind_Console.h/.cpp` 中把 `FConsoleVariable` 做成脚本可用值类型，支持 `int`/`float`/`bool`/`FString` 四种构造与对应 `Get*`/`Set*`；同时继续依赖 AngelScript 原生 global variable 与 `BindGlobalVariable` | 当前插件已具备 `RegisterGlobalProperty`、`FAngelscriptBinds::BindGlobalVariable`、`ASSDK.GlobalVar.*`、`Misc.GlobalVar`、`Misc.Namespace`、`GameplayTag`/`CollisionProfile`/`CollisionQueryParams`，并已补上 `FConsoleVariable` 的 `bool`/`FString` 表面及 `Bindings.GlobalVariableCompat`、`Bindings.ConsoleVariable*` 专项回归；剩余差距主要收敛到 `FConsoleCommand` 与更完整的控制台工作流/文档可见性 | **部分对齐（已显著收敛）** |
| 网络复制与 RPC 验证闭环 | 基线文档与本地仓库明确列出 NetServer / NetClient / NetMulticast / NetValidate / RepNotify / 条件复制 | 当前插件已通过 `Plan_FunctionalGapClosure.md` Phase 3 建立 `Networking/` 专题测试目录（2026-04-22），覆盖 Server/Client/NetMulticast/WithValidation/Unreliable 编译正例和 FUNC_Net* 标志验证；属性复制测试已由 `ASClassReplicationTests` 和 `PropertyReplicationConditionTests` 覆盖；Push Model 仍依赖引擎侧 | **已闭环（标准 RPC + 属性复制）；Push Model 属引擎侧差距** |
| VS Code / LSP / 调试工作流 | 基线含 DebugServer、SourceNavigation、Workspace/菜单入口、DAP 风格消息协议 | 当前插件已具备 DebugServer 协议、Diagnostics/CallStack/Variables/GoToDefinition 消息类型、SourceNavigation 测试基础和 VS Code workspace/source-link 设置；仍缺同等级使用文档与完整工作流入口 | **部分对齐** |
| 独立脚本示例与上手资产 | `HazelightAngelscriptEngineRoot/Script-Examples` 下有 26 个 `.as` 示例 | 当前仓库没有插件内可直接复用的 `.as` 示例目录；仅有测试内联源码与 `Reference/` 上游样例 | **明显差距** |
| GAS / EnhancedInput 工程拆分 | 基线以独立插件维护 `AngelscriptGAS`、`AngelscriptEnhancedInput` | 当前插件把相关支持直接并入主运行时依赖 | **结构差异** |
| Loader / 启动收口模块 | 基线使用独立 `AngelscriptLoader` 模块承接运行时/编辑器装载 | 当前插件已新增 `AngelscriptLoader`，由 Loader 调用 `FAngelscriptRuntimeModule::InitializeAngelscript()` 承接编辑器/Commandlet 启动初始化，Runtime 模块保留核心 API 与 fallback ticker | **已对齐启动边界** |
| CodeCoverage / Commandlet | 基线具备 `CodeCoverage/`、`AngelscriptTestCommandlet`、`AngelscriptAllScriptRootsCommandlet` | 当前插件同样具备 `Source/AngelscriptRuntime/CodeCoverage/` 与两个 Commandlet | **不列为差距** |
| 菜单扩展 / Content Browser / ScriptEditorSubsystem | 基线具备 | 当前插件也具备对应模块与公共头文件 | **不列为差距** |
| `UINTERFACE` / 接口场景 | Hazelight 公共文档把 Unreal Interface 列为限制项 | 当前插件已有 `AngelscriptInterfaceDeclare/Implement/Cast/Advanced` 场景测试 | **反向差异（当前插件已超出）** |

## 分阶段执行计划

### Phase 1：引擎侧能力边界差距

> 目标：先把"哪些能力本质上依赖 Hazelight 引擎分支"固定下来，避免把引擎补丁误写成普通插件待办。

- [ ] **P1.1** 固定引擎补丁能力差距边界
  - 问题：Hazelight 基线在 `HazelightAngelscriptEngineRoot/Engine/Source/Programs/Shared/EpicGames.UHT/`、`CoreUObject`、`Engine`、`Editor` 范围内存在 Angelscript 相关集成点，而当前仓库的工作目标是把能力收敛到 `Plugins/Angelscript`。
  - 证据：`HazelightAngelscriptEngineRoot/Engine/Source/Programs/Shared/EpicGames.UHT/Types/UhtProperty.cs`、`HazelightAngelscriptEngineRoot/Engine/Source/Runtime/CoreUObject/Public/UObject/Class.h`、`HazelightAngelscriptEngineRoot/Engine/Source/Editor/Kismet/Private/BlueprintCompilationManager.cpp` 等路径被本地基线扫描命中。
  - 影响：当前插件对齐 Hazelight 时，凡是依赖 UHT、反射生成、Blueprint 编译或引擎对象生命周期改造的能力，都不能简单当成"插件内缺一个类/函数"。
- [ ] **P1.1** 📦 Git 提交：`[P3] Docs: capture Hazelight engine-side gap boundary`

- [ ] **P1.2** 固定工程拆分差异，不再把结构差异误写成功能缺口
  - 问题：Hazelight 基线采用 `AngelscriptCode` + `AngelscriptEditor` + `AngelscriptLoader`，并额外拆出 `AngelscriptGAS`、`AngelscriptEnhancedInput`；当前插件已采用 `AngelscriptRuntime` + `AngelscriptEditor` + `AngelscriptLoader` + `AngelscriptTest`，但 GAS / EnhancedInput 仍作为主插件依赖。
  - 证据：`HazelightAngelscriptEngineRoot/Engine/Plugins/Angelscript/Angelscript.uplugin`、`HazelightAngelscriptEngineRoot/Engine/Plugins/AngelscriptGAS/AngelscriptGAS.uplugin`、`HazelightAngelscriptEngineRoot/Engine/Plugins/AngelscriptEnhancedInput/AngelscriptEnhancedInput.uplugin`、`HazelightAngelscriptEngineRoot/Engine/Plugins/Angelscript/Source/AngelscriptLoader/AngelscriptLoader.Build.cs`；对照当前 `Plugins/Angelscript/Angelscript.uplugin`、`Plugins/Angelscript/Source/AngelscriptLoader/`、`Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptRuntimeModule.cpp`。
  - 影响：Loader 启动边界已不再是差距；后续 backlog 仍需要区分"功能未到位"和"GAS / EnhancedInput 边界未拆开"两类问题，否则任务颗粒度会持续漂移。
- [ ] **P1.2** 📦 Git 提交：`[P3] Docs: record module-boundary delta against UEAS2`

### Phase 2：运行时能力缺口

> 目标：识别当前插件在脚本运行时能力面上，哪些项相对 Hazelight 仍处于"接口在、能力没闭环"或"能力只见底座、不见验证"的状态。

- [ ] **P2.1** 固定 Script Subsystem 差距
  - 问题：当前插件已经存在 `ScriptWorldSubsystem.h`、`ScriptGameInstanceSubsystem.h`、`ScriptLocalPlayerSubsystem.h`、`ScriptEngineSubsystem.h`，但各子系统的可用状态并不一致，当前证据只足以证明"部分类型未闭环、部分类型未验证"。
  - 证据：`Plugins/Angelscript/Source/AngelscriptRuntime/BaseClasses/ScriptWorldSubsystem.h`、`ScriptGameInstanceSubsystem.h`、`ScriptLocalPlayerSubsystem.h`、`ScriptEngineSubsystem.h`；同时 `Plugins/Angelscript/Source/AngelscriptTest/Subsystem/AngelscriptSubsystemScenarioTests.cpp` 明确把 `UScriptWorldSubsystem` / `UScriptGameInstanceSubsystem` 的编译失败视为当前分支的预期行为。
  - 证据补充：`Plugins/Angelscript/Source/AngelscriptTest/` 下未找到 `ScriptLocalPlayerSubsystem` 或 `ScriptEngineSubsystem` 对应场景验证。
  - 影响：当前插件虽然已经暴露了子系统基类入口，但至少在 World / GameInstance 子系统上，功能仍不能按 Hazelight 基线方式稳定使用；LocalPlayer / Engine 子系统目前只能归为"待补验证"，不能直接写成已缺失的功能面。
- [ ] **P2.1** 📦 Git 提交：`[P6] Docs: document subsystem parity gaps`

- [ ] **P2.2** 固定网络复制与 RPC 差距
  - 问题：Hazelight 基线把 `NetServer`、`NetClient`、`NetMulticast`、`NetValidate`、`RepNotify`、条件复制、`ReplicationPushModel` 和 FakeNetDriver 都纳入了完整能力面；当前插件虽然具备大部分标准 UE RPC / replication 底座，但公开能力边界、push-model 链路与验证闭环证据明显更薄。
  - 证据：Hazelight 基线可直接命中 `HazelightAngelscriptEngineRoot/Engine/Plugins/Angelscript/Source/AngelscriptCode/Private/Preprocessor/AngelscriptPreprocessor.cpp` 中的 `NetMulticast` / `Client` / `Server` / `ReplicatedUsing` / `ReplicationPushModel` 解析、`.../ClassGenerator/AngelscriptClassGenerator.cpp` 中的 `FUNC_Net*` / `CPF_RepNotify` / push-model property 登记、`.../ClassGenerator/ASClass.cpp` 中的 `REPNOTIFY_OnChanged` + push-model replication list，以及 `.../Testing/Network/FakeNetDriver.cpp` 与公开 `networking-features.md` 文档。当前插件可直接命中 `Plugins/Angelscript/Source/AngelscriptRuntime/Preprocessor/AngelscriptPreprocessor.cpp`、`.../ClassGenerator/AngelscriptClassGenerator.cpp`、`.../StaticJIT/PrecompiledData.*`、`.../Testing/Network/FakeNetDriver.cpp`、`Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptComponent.cpp` 中的 `_Validate` 调用路径，以及 `Plugins/Angelscript/Source/AngelscriptTest/Examples/AngelscriptScriptExampleActorTest.cpp`、`AngelscriptScriptExampleMovingObjectTest.cpp` 中的 `default bReplicates = true`。
  - 影响：当前插件更像"标准 UE RPC / replication 元数据路径基本存在，但 push-model 对齐、专题测试、示例与文档证据不足"，因此这里应优先被视为验证闭环差距 + 一条可确认的 push-model 功能差距，而不是直接断言功能不存在。
- [ ] **P2.2** 📦 Git 提交：`[P6] Docs: record networking and replication gaps`

- [ ] **P2.3** 固定脚本示例与上手资产差距
  - 问题：Hazelight 基线在 `HazelightAngelscriptEngineRoot/Script-Examples/` 下提供了 Actor、Struct、PropertySpecifiers、Delegates、FormatString、GAS、EnhancedInput、EditorMenuExtensions 等 26 个 `.as` 示例；当前仓库没有插件内可直接复用的脚本示例目录。
  - 证据：本仓库 `**/*.as` 搜索结果仅命中 `Reference/angelscript-v2.38.0` 下的上游示例，未命中 `Plugins/Angelscript`、`Script/` 或 `Documents/` 下的插件级示例脚本。
  - 影响：当前插件在"可学习、可迁移、可作为宿主工程最小示例"这条线上，明显弱于 Hazelight 基线。
- [ ] **P2.3** 📦 Git 提交：`[P6] Docs: capture example-script gap`

- [ ] **P2.4** 固定全局变量 / Console Variable 对齐边界
  - 问题：当前插件的"global variable / cvar"能力仍容易被整体误判为缺失；实际上原生 AngelScript global variable、`RegisterGlobalProperty` / `BindGlobalVariable` 以及 `FConsoleVariable` 最小脚本表面都已存在，真实剩余差距已经收敛到更窄的控制台工作流层。
  - 独立计划已拆分为 `Documents/Plans/Plan_GlobalVariableAndCVarParity.md`；本条在总计划中只保留 parity 摘要与导航入口，具体执行与补测继续在独立计划里推进。
  - Hazelight 侧证据：`HazelightAngelscriptEngineRoot/Engine/Plugins/Angelscript/Source/AngelscriptCode/Public/AngelscriptBinds/Bind_Console.h` 与 `.../Private/Binds/Bind_Console.cpp` 显式提供 `FConsoleVariable` 的 `int`/`float`/`bool`/`FString` 构造，以及 `GetBool` / `GetFloat` / `GetInt` / `GetString`、`SetBool` / `SetFloat` / `SetInt` / `SetString`；同目录继续提供 `FConsoleCommand`。
  - 当前插件侧证据：`Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_Console.h` / `Bind_Console.cpp`、`Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptBinds.h` / `AngelscriptBinds.cpp`、`Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/AngelscriptNativeRegistrationTests.cpp`、`AngelscriptNativeCompileTests.cpp`、`AngelscriptASSDKGlobalVarTests.cpp`、`Plugins/Angelscript/Source/AngelscriptTest/Angelscript/AngelscriptMiscTests.cpp`、`Plugins/Angelscript/Source/AngelscriptTest/Core/AngelscriptEngineParityTests.cpp`、`Plugins/Angelscript/Source/AngelscriptTest/Bindings/AngelscriptConsoleBindingsTests.cpp`、`AngelscriptGlobalBindingsTests.cpp`。
  - 影响：后续 parity/backlog 必须拆成两类：一类是"global variable 本体并未缺失，且插件绑定层已有最小行为回归"；另一类是"Hazelight 风格 console workflow 仍未完全闭环"，重点落在 `FConsoleCommand`、控制台命令触发链路和对应文档/工作流，而不是再重复开"全局变量完全缺失"的假问题。
- [ ] **P2.4** 📦 Git 提交：`[P6] Docs: capture global-variable and cvar parity gaps`

### Phase 3：工具链与工作流差距

> 目标：把当前插件在编辑器、IDE、调试、验证工作流上的缺口从"已有底座"里分离出来，避免重复对已对齐模块立项。

- [ ] **P3.1** 固定 VS Code / LSP / 调试工作流差距
  - 问题：Hazelight 基线已经形成以 VS Code 为中心的开发工作流，包含 DebugServer 协议、Workspace 路径、Source Navigation 与菜单入口；当前插件虽然已经保留了大部分调试协议和 Source Navigation 基础，但还看不到对等的开发工作流闭环。
  - 证据：Hazelight 基线扫描命中 `HazelightAngelscriptEngineRoot/Engine/Plugins/Angelscript/Source/AngelscriptCode/Private/Debugging/AngelscriptDebugServer.h`、`HazelightAngelscriptEngineRoot/Engine/Plugins/Angelscript/Source/AngelscriptEditor/SourceNavigation/AngelscriptSourceCodeNavigation.cpp`、`HazelightAngelscriptEngineRoot/Engine/Plugins/Angelscript/Source/AngelscriptCode/Public/AngelscriptSettings.h`；当前插件可直接命中 `Plugins/Angelscript/Source/AngelscriptRuntime/Debugging/AngelscriptDebugServer.h` 中的 `Diagnostics`、`RequestCallStack`、`RequestVariables`、`GoToDefinition`、`AssetDatabase` 等消息类型，以及 `Plugins/Angelscript/Source/AngelscriptTest/Editor/AngelscriptSourceNavigationTests.cpp` 中的源码导航测试，但未见 VS Code Workspace/菜单入口或相应使用文档。
  - 影响：当前插件并非缺少调试协议本体，而是缺少与 Hazelight 相当的 IDE 工作流收口和显式入口，容易导致"协议在、流程不成体系"的错觉。
- [ ] **P3.1** 📦 Git 提交：`[P6] Docs: document IDE workflow gaps`

- [ ] **P3.2** 固定调试/验证可见性差距
  - 问题：Hazelight 基线把 Diagnostics、Breakpoints、CallStack、Variables、Evaluate、GoToDefinition、AssetDatabase、CodeCoverage HTML 报告和 Commandlet 等全部纳入显式工作流；当前插件虽然已经拥有对应的调试协议、`CodeCoverage/` 与 Commandlet，但这些能力的文档化、样例化和使用可见性仍明显偏弱。
  - 证据：当前插件已有 `Plugins/Angelscript/Source/AngelscriptRuntime/Debugging/AngelscriptDebugServer.h`、`Plugins/Angelscript/Source/AngelscriptRuntime/CodeCoverage/`、`Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTestCommandlet.cpp`、`Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptAllScriptRootsCommandlet.cpp`，但项目级 `Documents/Guides/Test.md`、顶层 `Script/` 目录和插件级示例材料并没有形成与 Hazelight 官方文档/示例目录同等级的能力入口。
  - 影响：这不是"能力完全没有"，而是"能力存在但很难被稳定发现、验证和复用"，会直接影响后续对齐优先级判断。
- [ ] **P3.2** 📦 Git 提交：`[P6] Docs: capture workflow visibility gaps`

## 不应再误判为差距的项目

- `CodeCoverage`：当前插件已具备 `Plugins/Angelscript/Source/AngelscriptRuntime/CodeCoverage/AngelscriptCodeCoverage.h/.cpp` 与 `Plugins/Angelscript/Source/AngelscriptRuntime/Tests/AngelscriptCodeCoverageTests.cpp`。
- `Commandlet`：当前插件已具备 `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTestCommandlet.cpp` 与 `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptAllScriptRootsCommandlet.cpp`，不应继续把"命令行测试入口"列为缺失项。
- 编辑器菜单扩展：当前插件已具备 `ScriptEditorMenuExtension.h`、`ScriptAssetMenuExtension.h`、`ScriptActorMenuExtension.h`、`BlueprintMixinLibrary.h`、`EditorSubsystemLibrary.h`。
- `UINTERFACE` 场景：当前插件已有 `AngelscriptInterfaceNativeTests.cpp`、`AngelscriptInterfaceNativeBridgeTests.cpp`、`AngelscriptInterfaceNativeBindingTests.cpp`、`AngelscriptInterfaceNativeLifecycleTests.cpp`、`AngelscriptInterfaceNativeInheritedChildSurfaceTests.cpp`、`AngelscriptInterfaceNativePointerOffsetTests.cpp`，覆盖脚本实现或调用 C++ native UInterface；脚本自声明 `UINTERFACE()` / `interface UIFoo {}` 已废弃，不应恢复为差距项。
- 原生 global variable / `RegisterGlobalProperty` / `BindGlobalVariable` 本体：当前插件已经具备 `Native.Compile.GlobalVariables`、`Native.Register.GlobalProperty`、`Native.ASSDK.GlobalVar.*`、`Angelscript.Misc.GlobalVar`、`Angelscript.Misc.Namespace` 以及 `BindGlobalVariable` 真实调用点，不应再把"全局变量完全没支持"当作能力差距；真实待收口的是插件绑定层集中回归与 Hazelight 风格 `FConsoleVariable` 表面。

## 验收标准

1. 每个差距条目都同时给出 Hazelight 侧与当前插件侧的证据路径。
2. 差距被明确区分为：引擎侧、插件侧、工作流/验证侧。
3. 文档中不包含实现方案、接口设计、迁移步骤或技术路线。
4. `CodeCoverage`、`Commandlet`、菜单扩展、`UINTERFACE` 支持等非差距项被显式剔除，避免误报。
5. 后续 P3 / P6 拆任务时，可以直接按本文的 Phase 和编号挂接，而不需要重新做一轮能力盘点。

## 风险与注意事项

### 风险 1：把引擎侧能力误记为普通插件待办

Hazelight 基线不是"只有插件"，而是"引擎分支 + 插件 + 配套工作流"。如果不先拆清这个边界，后续任务会持续混入无法在当前插件内独立完成的项。

### 风险 2：把"底座存在"误判成"能力已对齐"

当前插件已经具备 DebugServer、CodeCoverage、Commandlet、Subsystem 基类等很多底座；但底座存在并不等于功能已经达到 Hazelight 的公开工作流与验证强度。像 Subsystem、RPC/复制、VS Code 工作流都属于这一类高风险误判区。

### 风险 3：把结构差异误判成功能缺失

`AngelscriptGAS` / `AngelscriptEnhancedInput` 的独立插件拆分更像工程边界问题，而不是单纯的"功能没有"。后续拆 backlog 时必须分开处理。

### 风险 4：把已超出的能力重新列回差距

当前插件的 `UINTERFACE` 场景支持已经形成测试闭环，这一点与 Hazelight 公共文档的限制项不同。后续任何 parity 文档都应先排除此类"反向差异"，避免重复返工。

