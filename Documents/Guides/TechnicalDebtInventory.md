# Angelscript 技术债实时盘点

> 快照提交：`bf99c93`（2026-04-23 更新）
>
> 目的：保留 Angelscript 插件技术债的 live inventory、历史验证快照与当前 debt owner 入口，避免后续执行阶段重复从零扫描。
>
> 当前 debt routing 主入口：`Documents/Plans/Plan_TechnicalDebtRefresh.md`

## 1. 已编目基线 vs 实时扫描

- `Documents/Guides/TestCatalog.md` 仍以 `275/275 PASS` 作为**已编目基线**，它表示"已经整理进目录文档并完成一轮 closeout 的基线"，不是当前 live suite 的总数。
- 当前源码对 `IMPLEMENT_SIMPLE_AUTOMATION_TEST`、`IMPLEMENT_COMPLEX_AUTOMATION_TEST`、`IMPLEMENT_CUSTOM_SIMPLE_AUTOMATION_TEST`、`BEGIN_DEFINE_SPEC`、`DEFINE_SPEC` 的实时扫描命中 **417+** 处定义，覆盖 **429** 个测试 `.cpp` 文件（AngelscriptTest 387 + AngelscriptEditor/Tests 32 + AngelscriptRuntime/Tests 10）；这表示的是源码中自动化入口定义规模，也不等于当前 full-suite 执行总数。
- 仅剩 **2 个 Disabled 测试**（均为 `#ue57-headless` 已知限制）：`TestEngineHelperTests.cpp:106`（TryGetRunningProductionDebuggerEngine headless 下返回 null）、`SourceNavigationTests.cpp:125`（Property navigation metadata headless 下未填充）。
- 因此这里至少存在三套需要并存维护的数字：**文档化基线**（275/275）、**源码实时定义规模**（417+ 定义 / 429 文件）、**最新 full-suite 结果**（需实际运行确认）。后续整理时不得再把其中任意一组当作另外两组的直接替代。

### 当前测试债 owner 口径

- **零覆盖 / 弱覆盖**：优先由 `Documents/Plans/Plan_TestCoverageExpansion.md` 承接。
- **StaticJIT 专项零覆盖**：优先由 `Documents/Plans/Plan_StaticJITUnitTests.md` 承接，而不是继续挂在泛化测试 backlog 中。
- **测试层级 / 目录 / 命名规范化**：优先由 `Documents/Plans/Plan_TestSystemNormalization.md` 与 `Documents/Plans/Plan_TestModuleStandardization.md` 承接。
- **当前应通过但未通过的已知失败**：优先由 `Documents/Plans/Plan_KnownTestFailureFixes.md` 承接。
- **negative tests（当前明确不支持、作为能力边界证据存在）**：保留在相应测试主题中作为能力边界证据，不应和 zero/weak coverage 或 known failures 混写。
- **总分流 / owner 解释**：以 `Documents/Plans/Plan_TechnicalDebtRefresh.md` 为准。

### 当前 live inventory 热点

- `Plugins/Angelscript/Source/AngelscriptTest/Core/AngelscriptEngineParityTests.cpp`：14 处
- `Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptTestEngineHelperTests.cpp`：11 处
- `Plugins/Angelscript/Source/AngelscriptTest/Angelscript/AngelscriptTypeTests.cpp`：11 处
- `Plugins/Angelscript/Source/AngelscriptTest/Angelscript/AngelscriptExecutionTests.cpp`：9 处
- `Plugins/Angelscript/Source/AngelscriptTest/Compiler/AngelscriptCompilerPipelineTests.cpp`：8 处

## 2. 测试 helper 命名现状

### 当前入口定义位置

- `Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptTestUtilities.h:30`：`FScopedGlobalEngineOverride`
- `Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptTestUtilities.h:47`：`TryGetRunningProductionEngine()`
- `Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptTestUtilities.h:61`：`CreateIsolatedFullEngine()`
- `Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptTestUtilities.h:70`：`CreateIsolatedCloneEngine()`
- `Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptTestUtilities.h:77`：`GetOrCreateSharedCloneEngine()`
- `Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptTestUtilities.h:88`：`ResetSharedCloneEngine()`
- `Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptTestUtilities.h:100`：`AcquireCleanSharedCloneEngine()`
- `Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptTestUtilities.h:107`：`AcquireCleanSharedCloneEngineAndOverrideGlobal()`
- `Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptTestUtilities.h:115`：`RequireRunningProductionEngine()`

### 迁移结论

- 旧 helper 兼容别名已从 `Shared/AngelscriptTestUtilities.h` 删除。
- `Plugins/Angelscript/Source/AngelscriptTest/` 下的 helper 调用点已完成向显式命名迁移；后续不再把 `Initialized` / `Shared` / `Production` 的混合语义保留为并行入口。

## 3. 已关闭的构建与运行时债务

- `Plugins/Angelscript/Source/AngelscriptRuntime/AngelscriptRuntime.Build.cs`：`OptimizeCode = CodeOptimization.Never` 已收口为仅 `Debug` / `DebugGame` 生效的配置感知策略。
- `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptType.h`：`FBox` / `FBoxSphereBounds` 的旧入口审计锚点已被显式 provider 路径替代，不再保留"无条件特化 + WILL-EDIT"作为开放债务。
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_BlueprintEvent.cpp`：`ExecutePreamble()` / `ExecuteEvent()` / delegate / multicast delegate 入口均已补齐签名校验。
- `Plugins/Angelscript/Source/AngelscriptRuntime/Debugging/AngelscriptDebugServer.cpp`：data breakpoint 共享状态已改为 snapshot/atomic containment；剩余 `FAngelscriptEngine::Get()` 仅用于 line-callback 状态刷新，不再作为本计划里的开放性并发 TODO。
- `Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/StaticJITHeader.cpp`：异常路径对象生命周期已完成本计划范围内的收口，不再保留开放性销毁 TODO。

## 4. 弃用 API 与警告压制结论

- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_string.h`：`FCrc::Strihash_DEPRECATED` 已替换为保语义的大小写无关 CRC 实现。
- `Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/StaticJITHeader.h`：文件级 `PRAGMA_DISABLE_DEPRECATION_WARNINGS` 已移除。
- Phase 2 验证时对 `Plugins/Angelscript/Source/AngelscriptRuntime/` 的 `_DEPRECATED` 与 `PRAGMA_DISABLE_DEPRECATION_WARNINGS` 定向扫描均为 **0 命中**。

## 5. 全局状态依赖盘点

- 对 `FAngelscriptEngine::Get()` 与 `CurrentWorldContext` 的实时扫描在 `Plugins/Angelscript/Source/` 下共命中 **325** 处，覆盖 **57** 个文件。
- 当前热点文件：
  - `Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator/AngelscriptClassGenerator.cpp`：81 处
  - `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptBinds.cpp`：32 处
  - `Plugins/Angelscript/Source/AngelscriptRuntime/Debugging/AngelscriptDebugServer.cpp`：23 处
  - `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.cpp`：19 处
  - `Plugins/Angelscript/Source/AngelscriptRuntime/Preprocessor/AngelscriptPreprocessor.cpp`：12 处
  - `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_AActor.cpp`：12 处
- 结合代码位置可先分三类：
  - **编译 / 类生成路径**：`ClassGenerator/AngelscriptClassGenerator.cpp`、`ClassGenerator/ASClass.cpp`、`Core/AngelscriptBinds.cpp`
  - **世界上下文绑定路径**：`Binds/Bind_SystemTimers.cpp`、`Binds/Bind_UUserWidget.cpp`、`Core/AngelscriptGameInstanceSubsystem.cpp`
  - **测试 / 调试辅助路径**：`Debugging/AngelscriptDebugServer.cpp`、`Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptTestUtilities.h`、`Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptTestEngineHelperTests.cpp`

## 6. Bind 审计候选清单

- 本轮计划中的首批候选文件仍然是：
  - `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_TOptional.cpp`
  - `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UStruct.cpp`
  - `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_BlueprintType.cpp`
  - `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_AActor.cpp`
  - `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_USceneComponent.cpp`
  - `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_Delegates.cpp`
  - `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FHitResult.cpp`
  - `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FMath.cpp`
  - `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FVector2f.cpp`
- 其中已明确存在的本地逻辑缺口锚点：`Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_BlueprintType.cpp:156`，`CPF_TObjectPtr` 判断仍处于注释状态。
- 当前执行环境已配置 `AgentConfig.ini` 的 `References.HazelightAngelscriptEngineRoot`，因此 `P0.4` 可直接进入参考源对照，而不需要先补本地引用路径。
- 需要额外注意：`Documents/Plans/Plan_AS238NonLambdaPort.md` 与 `Documents/Plans/Plan_HazelightBindModuleMigration.md` 已创建并在 `BindGapAuditMatrix.md` 中承接对应 high-risk / cross-theme 事项；本节后续只需维护矩阵与 sibling plan 的去向一致性。

## 7. 宿主工程边界快照

- `Source/AngelscriptProject/AngelscriptProject.Build.cs` 已移除 `InputCore` / `EnhancedInput`，宿主模块当前只保留 `Core`、`CoreUObject`、`Engine` 三个公开依赖。
- 结论：`P5.3` 已完成宿主工程最小化边界收口；若后续再新增依赖，应先证明其属于宿主验证职责而不是插件逻辑回流。

## 8. 后续执行建议

- `P6.2` 关闭时，确保 `Plan_TechnicalDebt.md` 的引用表已显式包含 `Documents/Guides/GlobalStateContainmentMatrix.md` 与 `Documents/Plans/Plan_FullDeGlobalization.md`。
- `P6.3` 若再次执行最终 `Automation RunTests Angelscript.TestModule`，不应再假设"仍固定保留 4 个已知失败项"；当前口径应以最新日志为准，重新核对 full-suite 是否仍然全绿，或是否出现新的顺序相关污染。
- 最终结果摘要应同时回写计划、测试目录基线说明与本盘点文档，保持"已编目基线 / 实时扫描规模 / full-suite 最新状态"三者口径一致。

## 9. Phase 1 验证快照

- 编辑器目标构建验证：`AngelscriptProjectEditor Win64 Development` 在当前 `technical-debt-plan` worktree 中可成功构建。
- 本地前置说明：此前构建链路曾引用 `Plugins/Angelscript/Intermediate/Build/as_callfunc_x64_msvc_asm.lib` 作为本地中间产物前置；该残留依赖已在后续 `CallfuncDeadCodeCleanup` 中移除，当前构建不再要求预先生成该 `.lib`。
- `P1.3` 目标测试验证：
  - `Angelscript.TestModule.Delegate.UnicastSignatureMismatch`：PASS
  - `Angelscript.TestModule.Delegate.MulticastSignatureMismatch`：PASS
- `Automation RunTests Angelscript.TestModule` 全量回归结果：**未全绿**，但当前失败项均未直接指向 `P1.1`~`P1.5` 改动面。

### 当前 full-suite 失败项（2026-04-03）

- `Angelscript.TestModule.Angelscript.NativeScriptHotReload.Phase2A`
  - 失败摘要：`Expected 'Phase2A should load source from Script/Tests/Test_Enums.as' to be true.`
  - 归因判断：更像测试输入文件缺失 / 路径基线问题，未触及本轮 `Binds`、`StaticJIT`、`DebugServer` 修复面。
- `Angelscript.TestModule.Angelscript.NativeScriptHotReload.Phase2B`
  - 失败摘要：`Expected 'Phase2B should load source from Script/Tests/Test_GameplayTags.as' to be true.`
  - 归因判断：同样更像 hot-reload 测试资产路径问题，未触及本轮 `P1` 改动面。
- `Angelscript.TestModule.Editor.SourceNavigation.Functions`
  - 失败摘要：`Unable to open script file .../Saved/Automation/Automation/RuntimeFunctionNavigationTest.as`，随后 `Generated function navigation class should exist` 断言失败。
  - 归因判断：属于 editor/source-navigation 测试文件生成或清理路径问题，与 `BlueprintEvent`、`DebugServer`、`StaticJIT` 修复面无直接交集。
- `Angelscript.TestModule.ScriptExamples.Actor`
  - 失败摘要：`Cannot declare class AExampleActorType in module ScriptExamples.Example_Actor. A class with this name already exists in module Example_Actor.`
  - 归因判断：属于 script example 模块命名 / 清理冲突，未触及本轮 `P1` 改动面。

## 10. Phase 2 验证快照

- 显式弃用扫描结果：对 `Plugins/Angelscript/Source/AngelscriptRuntime/` 的 `_DEPRECATED` 与 `PRAGMA_DISABLE_DEPRECATION_WARNINGS` 定向扫描结果均为 **0 命中**。
- `P2` 目标测试验证：
  - `Angelscript.TestModule.Angelscript.Upgrade.CStringHash`：PASS
  - `Angelscript.TestModule.Internals.Restore.EmptyStreamFails`：PASS
  - `Angelscript.TestModule.Internals.Restore.TruncatedStreamFails`：PASS
- `Automation RunTests Angelscript.TestModule` 全量回归结果：**仍未全绿**，但当前保留失败项与 `P2.1`~`P2.4` 的弃用 API / Restore 测试改动不直接相关。

### Phase 2 完成后的 full-suite 保留失败项（2026-04-03）

- `Angelscript.TestModule.Angelscript.NativeScriptHotReload.Phase2A`
  - 失败摘要：`Expected 'Phase2A should load source from Script/Tests/Test_Enums.as' to be true.`
  - 归因判断：hot-reload 测试输入文件路径/存在性问题，未触及本轮 `P2` 改动面。
- `Angelscript.TestModule.Angelscript.NativeScriptHotReload.Phase2B`
  - 失败摘要：`Expected 'Phase2B should load source from Script/Tests/Test_GameplayTags.as' to be true.`
  - 归因判断：同样属于 hot-reload 测试输入文件路径问题，未触及本轮 `P2` 改动面。
- `Angelscript.TestModule.Editor.SourceNavigation.Functions`
  - 失败摘要：`Unable to open script file .../Saved/Automation/Automation/RuntimeFunctionNavigationTest.as`，随后 `Generated function navigation class should exist` 断言失败。
  - 归因判断：editor/source-navigation 测试文件生成或清理路径问题，未触及 `P2` 的 ThirdParty hash / StaticJIT 警告压制 / Restore 负向覆盖改动面。
- `Angelscript.TestModule.ScriptExamples.Actor`
  - 失败摘要：`Cannot declare class AExampleActorType in module ScriptExamples.Example_Actor. A class with this name already exists in module Example_Actor.`
  - 归因判断：script example 模块命名或清理冲突，未触及本轮 `P2` 改动面。

## 11. Phase 3 验证快照

- helper 命名迁移结果：`Plugins/Angelscript/Source/AngelscriptTest/` 下旧 helper 名称定向 grep 结果为 **0 命中**。
- `P3.1` / `P3.2` focused regression：
  - `Angelscript.TestModule.Shared.EngineHelper`：PASS
  - `Angelscript.TestModule.Internals.Restore.*`：PASS
- `P3.3` 主题化集成 focused regression：`Actor`、`BlueprintChild`、`Component`、`Delegate`、`GC`、`HotReload`、`Inheritance`、`Interface`、`WorldSubsystem`、`ClassGenerator`：PASS（已知旧失败项未增加）。
- `P3.4` 行为 / Bindings / FileSystem / Editor / ScriptExamples focused regression：helper 改名未新增失败；仍保留与此前一致的 4 个已知失败项。
- `Automation RunTests Angelscript.TestModule` 全量回归结果：**仍未全绿**，失败项与 Phase 2 结束时一致，没有新增 helper 命名迁移相关失败。

### Phase 3 完成后的 full-suite 保留失败项（2026-04-03）

- `Angelscript.TestModule.Angelscript.NativeScriptHotReload.Phase2A`
  - 失败摘要：`Expected 'Phase2A should load source from Script/Tests/Test_Enums.as' to be true.`
  - 归因判断：hot-reload 测试输入文件路径/存在性问题，helper 命名迁移未触及该路径。
- `Angelscript.TestModule.Angelscript.NativeScriptHotReload.Phase2B`
  - 失败摘要：`Expected 'Phase2B should load source from Script/Tests/Test_GameplayTags.as' to be true.`
  - 归因判断：同样属于 hot-reload 测试输入文件路径问题，helper 命名迁移未触及该路径。
- `Angelscript.TestModule.Editor.SourceNavigation.Functions`
  - 失败摘要：`Unable to open script file .../Saved/Automation/Automation/RuntimeFunctionNavigationTest.as`，随后 `Generated function navigation class should exist` 断言失败。
  - 归因判断：editor/source-navigation 测试文件生成或清理路径问题，helper 命名迁移未触及该路径。
- `Angelscript.TestModule.ScriptExamples.Actor`
  - 失败摘要：`Cannot declare class AExampleActorType in module ScriptExamples.Example_Actor. A class with this name already exists in module Example_Actor.`
  - 归因判断：script example 模块命名或清理冲突，helper 命名迁移未触及该路径。

## 12. Phase 4 验证快照

- `P4.2` 低风险 bind 收口已落地的主项：
  - `Bind_FVector2f.cpp`：补齐 `ToDirectionAndLength`
  - `Bind_FMath.cpp`：补齐 `LinePlaneIntersection(const FVector&, const FVector&, const FPlane&)`
  - `Bind_USceneComponent.cpp`：补齐 `SetComponentVelocity`、`GetComponentVelocity`、`FScopedMovementUpdate`
  - `Bind_Delegates.cpp`：补齐本地可承载的 no-discard metadata 标记
- `P4.2` / `P4.4` focused regression：
  - `Angelscript.TestModule.Bindings.MathExtendedCompat`：PASS
  - `Angelscript.TestModule.Bindings.NativeComponentMethods`：PASS
  - `Angelscript.TestModule.Delegate.Multicast`：PASS
  - `Angelscript.TestModule.Delegate.MulticastSignatureMismatch`：PASS
  - `Angelscript.TestModule.Delegate.Unicast`：PASS
  - `Angelscript.TestModule.Delegate.UnicastSignatureMismatch`：PASS
- `BindGapAuditMatrix.md` 已把超出主计划 low-risk 范围的项分流到 `Plan_AS238NonLambdaPort.md` 与 `Plan_HazelightBindModuleMigration.md`。

## 13. Phase 5 验证快照

- `P5.1` 分类结果已沉淀到 `Documents/Guides/GlobalStateContainmentMatrix.md`。
- `P5.2` 已完成的低风险 containment：
  - `Debugging/AngelscriptDebugServer.cpp` 不再在本文件里散用 `FAngelscriptEngine::Get()`；owner engine 通过构造时注入，异常处理路径使用单点 active debug server 入口。
  - `ShouldBreakOnActiveSide()` 通过 owner engine 实例方法读取当前 world context，而不是直接触碰静态入口。
- `P5.3` 宿主工程最小化结果：
  - `Source/AngelscriptProject/AngelscriptProject.Build.cs` 已移除模板残留的 `InputCore` / `EnhancedInput` 公开依赖。
  - 当前宿主模块只保留 `Core`、`CoreUObject`、`Engine` 三个公开依赖，且构建通过。
- `P5.5` focused regression：
  - `Angelscript.TestModule.ClassGenerator.EmptyModuleSetup`：PASS
  - `Angelscript.TestModule.Shared.EngineHelper.*`：PASS
  - `Angelscript.TestModule.WorldSubsystem.*`：PASS
- 当前 containment 仍是"低风险入口收口"，不代表 `ClassGenerator` / `AngelscriptEngine` / `GameInstanceSubsystem` 已完成全量去全局化；这些后续边界已转入 `Documents/Plans/Plan_FullDeGlobalization.md`。

## 14. Phase 6.1 结论快照

- `Bind_UEnum.cpp` 当前未见显式的 enum lookup 性能 TODO、专项哈希缓存结构、或仍需单独验证的优化路径。
- 现有代码主要集中在 `UEnum` 类型适配、属性匹配、默认值转换与 debugger value 构造，不再包含需要单独 benchmark 的"已落地但未验证"性能债务描述。
- 结论：`Bind_UEnum` 的性能债务按 stale 说法退休；后续若再引入真实的枚举查找优化路径，再单独建立可回归的测量任务。

## 15. Phase 6.3 最终回归快照

- 命令解析：通过 `Tools/Diagnostics/powershell/ResolveAgentCommandTemplates.ps1` 读取 `AgentConfig.ini` 并生成 `Tools\RunTests.ps1 -Group <group>` 的完整模板，确认 `ProjectFile` 指向 worktree 根 `AngelscriptProject.uproject`，`Test.DefaultTimeoutMs` 保持 `600000ms`。
- 最终回归执行：在 `technical-debt-plan` worktree 上通过 `Tools\RunTests.ps1` （配合 `-Group` / `-TestPrefix`）重复 `Angelscript.TestModule` 的 automation run，日志同样记录在 `Saved/Logs/AngelscriptProject.log`。
- 失败计数：`Saved/Logs/AngelscriptProject.log` 中 `LogAutomationController: Error: Test Completed. Result={失败}` 共 **4** 处，且 `LogAutomationCommandLine` 以 `**** TEST COMPLETE. EXIT CODE: -1 ****` 收尾，对应这 4 个失败项。
- 最终保留失败项与 Phase 3 记录保持一致，没有新增指向本轮技术债收口改动面的回归：
  - `Angelscript.TestModule.Angelscript.NativeScriptHotReload.Phase2A`
    - 失败摘要：`Expected 'Phase2A should load source from Script/Tests/Test_Enums.as' to be true.`
    - 证据：`Saved/Logs/AngelscriptProject.log:2610`。
  - `Angelscript.TestModule.Angelscript.NativeScriptHotReload.Phase2B`
    - 失败摘要：`Expected 'Phase2B should load source from Script/Tests/Test_GameplayTags.as' to be true.`
    - 证据：`Saved/Logs/AngelscriptProject.log:2617`。
  - `Angelscript.TestModule.Editor.SourceNavigation.Functions`
    - 失败摘要：`Unable to open script file .../Saved/Automation/Automation/RuntimeFunctionNavigationTest.as`，随后 `Generated function navigation class should exist` 断言失败。
    - 证据：`Saved/Logs/AngelscriptProject.log:4784`。
  - `Angelscript.TestModule.ScriptExamples.Actor`
    - 失败摘要：`Cannot declare class AExampleActorType in module ScriptExamples.Example_Actor. A class with this name already exists in module Example_Actor.`
    - 证据：`Saved/Logs/AngelscriptProject.log:7225`。
- 结论：`P6` 最终回归确认本轮技术债关闭工作没有引入新的 full-suite 回归；剩余失败项继续作为独立测试输入 / 路径 / 示例模块冲突问题保留，不回退为本计划中的开放技术债。

## 16. 2026-04-03 补充回归快照

- 编辑器目标构建验证：`AngelscriptProjectEditor Win64 Development` 已重新构建通过。
- 最新全量回归：`Automation RunTests Angelscript.TestModule` 已在当前仓库通过，结果日志见 `Saved/Logs/TestRun_20260403_170014.log`。
- 本轮收口并不是 runtime 去全局化已经完成，而是测试侧隔离进一步收紧：
  - `Shared/AngelscriptTestUtilities.h` 新增 `DestroySharedAndStrayGlobalTestEngine()`，用于同时清理共享测试引擎与"没有 subsystem tick owner 的 stray global engine"。
  - 多个晚段测试入口统一改为本地 `AcquireFresh*Engine()` 模式：先清 shared / stray global，再重新获取 clean shared clone，切断全量跑时从前序残留 global runtime 上 clone 的污染链。
  - `HotReload` / `Delegate` 相关 performance 与 mismatch 用例同步对齐了当前 runtime 的返回值和日志格式，避免把预期漂移误判成真实回归。
- 这次验证也再次证明一个事实：`GAngelscriptEngine` 仍然存在并参与当前 runtime 解析路径；测试变绿不代表全局状态债务已关闭，只说明现有 helper containment 已足以稳定当前 full-suite。

## 17. 2026-04-04 Engine Isolation 修复后回归快照

- 背景：`Plan_TestEngineIsolation.md` 重构引入了 `FAngelscriptEngineScope` 机制和共享测试引擎 scope 自动管理，同时修复了 `asCScriptEngine::~asCScriptEngine()` 析构循环中的 TOCTOU bug。
- 全量回归：`Automation RunTests Angelscript.TestModule`，443 测试中 **436 通过 / 7 失败 / 0 跳过**，无崩溃。
- 相比 Phase 6.3 的 4 个已知失败，本轮变化：
  - **已修复**：`NativeScriptHotReload.Phase2A`、`Phase2B`、`Editor.SourceNavigation.Functions`、`ScriptExamples.Actor`（这 4 个之前的失败已在中间迭代中修复或不再复现）
  - **新增 7 个已知失败**：均为功能待补齐或测试 expectation 问题，非 crash 或回归

### 已知失败项清单

#### 类别 A：Testing-Full 引擎类型元数据未注册（3 个）

| 测试 | 失败摘要 | 根因 |
|------|----------|------|
| `Engine.LastFullDestroyClearsTypeState` | `should populate type metadata while the full engine is alive` | `CreateTestingFullEngine()` 的 `InitializeForTesting()` 只做最小初始化，不执行完整绑定注册，导致 `FAngelscriptTypeDatabase` 为空 |
| `Engine.FullDestroyAllowsCleanRecreate` | `should populate type metadata during the first epoch` | 同上 |
| `Engine.FullDestroyAllowsAnnotatedRecreate` | `Class ARecreateAnnotatedActorA has an unknown super type AAngelscriptActor` | 同上，缺少 `AAngelscriptActor` 类型注册 |

- **修复方向**：在 `InitializeForTesting()` 中补齐最小 bind replay 或按需注册核心类型元数据。属于 Bind API GAP 范畴。
- **关联计划**：`Plan_HazelightCapabilityGap.md`

#### 类别 B：Restore 序列化错误消息格式不匹配（1 个）

| 测试 | 失败摘要 | 根因 |
|------|----------|------|
| `Internals.Restore.EmptyStreamFails` | 期望 `"Unexpected end of file"`，实际 `"Angelscript: :"` | AS 引擎对空流的错误消息格式与测试 expectation 不一致 |

- **修复方向**：调整测试 expectation 以匹配实际错误消息格式，或在 Restore 路径补充更明确的错误输出。
- **复杂度**：低

#### 类别 C：预处理器 import 功能未完成（3 个）

| 测试 | 失败摘要 | 根因 |
|------|----------|------|
| `Preprocessor.ImportParsing` | `should record the imported module name` / `import statement should be removed` | 预处理器未实现 import 语句解析和移除 |
| `Learning.Runtime.Preprocessor` | `should record the imported module name` / `should strip the import line` | 同上 |
| `Learning.Runtime.FileSystemAndModuleResolution` | `Discovery with editor scripts should find more files than skip-rule discovery` | 文件发现逻辑在测试环境中发现的文件数量不符预期 |

- **修复方向**：补齐预处理器的 import 解析逻辑；FileSystem 测试需要审查测试环境的脚本文件布局。
- **关联计划**：预处理器功能补齐属于 Runtime 能力完善范畴
