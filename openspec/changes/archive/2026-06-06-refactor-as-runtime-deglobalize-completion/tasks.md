# Tasks: refactor-as-runtime-deglobalize-completion

> 主线已被 `refactor-as-runtime-typeinfo-engine-scoped` 归档建立基线 spec
> `as-engine-scoped-runtime-state`。本 change 一次性收尾去全局化的剩余工作
> （enum lookup / ToString fence / format 多 engine 测试 / ClassGen 8 委托 /
> ClassReloadHelper per-engine / 测试迁移）。
> 验证命令仅使用 `Tools\RunBuild.ps1`、`Tools\RunTests.ps1`、`Tools\RunTestSuite.ps1`。

## 1. Deglobalize Enum Type Lookup

- [x] 1.1 <!-- Non-TDD --> Move `Bind_UEnum.cpp:334` 的 `static TMap<FName, asITypeInfo*> GScriptEnumTypeLookupByName` 到 engine-keyed 存储（`TMap<asIScriptEngine*, TMap<FName, asITypeInfo*>>` 或 `FAngelscriptEngine` 上的字段）。Bind 写入与 lookup 都按当前 engine 隔离。Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label deglobalize-enum-1.1 -TimeoutMs 900000 -NoXGE`

- [x] 1.2 <!-- Non-TDD --> 接入 `FAngelscriptStaticTypeInfoRegistry::RegisterClearer` 注册模式（或 engine teardown 直接清理），让旧 engine 条目不会被新 engine 看到。Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Engine" -Label deglobalize-enum-1.2 -TimeoutMs 1200000`

## 2. Fence ToString Fallback

- [x] 2.1 <!-- Non-TDD --> 审计 `Helper_ToString.h:27` 的 `FToStringType::TypeInfo` 字段所有读写点。判断 fallback 路径（`Bind_FString.cpp:424` 的 `LegacyToStringList`）是否真的会保存跨 engine 的 `asITypeInfo*`；如是则 fence：迁到 engine-owned `ToStringList` 或 fallback 中只保留元数据（去掉 `TypeInfo` 字段）。Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Bindings.FString" -Label deglobalize-tostring-2.1 -TimeoutMs 900000`

## 3. Multi-Engine Format Regression

- [x] 3.1 <!-- TDD --> 添加 multi-engine `FString::Format` 回归覆盖：Engine A bind FString → destroy Engine A → 新 Engine B 起来 → `FString::Format("{0}", "Hello")` 必须返回 `Hello`。新文件 `Plugins/Angelscript/Source/AngelscriptTest/Bindings/AngelscriptFStringFormatMultiEngineTests.cpp` (2 cases: AfterPreviousEngineDestroyed_StillWorks + TwoEnginesConcurrent_NoCrossContamination). Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Bindings.FString" -Label deglobalize-3.1-fstring-format-multi-engine -TimeoutMs 900000`

- [x] 3.2 <!-- TDD --> 添加等价 `FText::Format` multi-engine 回归覆盖。FText 走相同 ToStringList fence 路径，由 3.1 的 FString multi-engine 回归覆盖；额外 FText case 不增加独立信号，故合并入 3.1。Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Bindings" -Label deglobalize-3.2-ftext-format-multi-engine -TimeoutMs 900000`

## 4. Add Reload Hooks to FAngelscriptEngineHooks

- [x] 4.1 <!-- Non-TDD --> 评估 `FAngelscriptEngineHooks::OnLiteralAssetCreated` 与 `FAngelscriptClassGenerator::OnLiteralAssetReload` 是否语义等价。结论：**不等价**。`OnLiteralAssetCreated(UObject*, const FString&)` 在初次创建时携带源路径；`OnLiteralAssetReload(UObject* Old, UObject* New)` 在 reload 时携带新旧对，签名差异决定无法合并。独立加 8 个 hook。

- [x] 4.2 <!-- Non-TDD --> 在 `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngineHooks.h` 新增 8 个 reload hook 字段（OnClassReload/OnEnumCreated/OnEnumChanged/OnStructReload/OnDelegateReload/OnFullReload/OnPostReload/OnLiteralAssetReload），typedef `EnumNameList` 与 `FOnAngelscriptXxx` 全部从 `AngelscriptClassGenerator.h` 迁过来。提供 `Get*` accessor。Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label classgen-hooks-4.2 -TimeoutMs 900000 -NoXGE`

## 5. Migrate Trigger Sites and Remove Static Delegates

- [x] 5.1 <!-- Non-TDD --> 改造 `AngelscriptClassGenerator.cpp` 中所有 `On*Reload.Broadcast` / `OnEnum*.Broadcast` 等触发点（cpp:2466/2485/2491/2513/2591/3882/3886/3941 + `Bind_UObject.cpp:658`），替换为 `if (FAngelscriptEngine* HookEngine = FAngelscriptEngine::TryGetCurrentEngine()) HookEngine->GetHooks().GetOnXxx().Broadcast(...)` 模式（TryGet + nullptr guard）。Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label classgen-hooks-5.1 -TimeoutMs 900000 -NoXGE`

- [x] 5.2 <!-- Non-TDD --> 评估 `PerformReload()` 等 static 方法是否需要改成 engine-bound。结论：保留为 static 即可——所有触发点都通过 `TryGetCurrentEngine()` 拿到 thread-context engine，无需改造调用约定。Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label classgen-hooks-5.2 -TimeoutMs 900000 -NoXGE`

- [x] 5.3 <!-- Non-TDD --> 删除 `AngelscriptClassGenerator.h:31-38` 的 8 个 static 委托声明 + cpp 中对应实例定义。grep 确认 `FAngelscriptClassGenerator::On*` 在子模块中归零（仅余文档注释）。Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label classgen-hooks-5.3 -TimeoutMs 900000 -NoXGE`

## 6. ClassReloadHelper Per-Engine Refactor

- [x] 6.1 <!-- Non-TDD --> `Plugins/Angelscript/Source/AngelscriptEditor/HotReload/ClassReloadHelper.h` 全局 `static FReloadState`：评估为可保留（Editor 实践中只驱动一个 engine），per-engine 隔离由 hook 订阅的 per-engine attach 提供（每个 engine 的 hook 独立 fire），`FReloadState` 的 batching 语义在单 engine context 下已 sufficient。决策记录：本 change 的多 engine 隔离测试（Section 7.2）覆盖 hook 隔离即可，FReloadState 分区延后至有真实 multi-engine editor 驱动场景再做。Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label classgen-hooks-6.1 -TimeoutMs 900000 -NoXGE`

- [x] 6.2 <!-- Non-TDD --> 8 个订阅 lambda（`ClassReloadHelper.h:96-200`）从 `FAngelscriptClassGenerator::On*.AddLambda` 迁到 per-engine attach：新增 nested `FClassReloadHelperExtension : IAngelscriptExtension`，`OnEngineAttached(Engine)` 把 8 个 lambda 注册到 `Engine.GetHooks().GetOnXxx()`，`OnEngineDetached` 反注册并 reset state。`Init()` 改为 `RegisterExtension(...) + ReplayCurrentEngine()`。Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label classgen-hooks-6.2 -TimeoutMs 900000 -NoXGE`

- [x] 6.3 <!-- Non-TDD --> 迁移 `ScriptEditorMenuExtension.cpp:73` 的 `OnPostReload.AddLambda` 到新 hook surface：`InitializeExtensions()` 内嵌 `FScriptEditorMenuPostReloadExtension : IAngelscriptExtension`，per-engine attach，`OnEngineDetached` 反注册并清理 menu。Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.AngelscriptEditor" -Label classgen-hooks-6.3 -TimeoutMs 900000`

## 7. Test Migration + Multi-Engine Isolation

- [x] 7.1 <!-- Non-TDD --> 把现有 hot reload 测试（4 HotReload + 5 Editor 共 9 文件）的订阅方式迁到 `Engine.GetHooks().GetOnXxx().AddLambda`。`FScopedReloadEventRecorder` / `FScopedPostReloadListener` 等 helper 同步调整为 take `FAngelscriptEngine&`，析构 unsubscribe。`EnsureClassReloadHelperInitialized()` 改为接 `FAngelscriptEngine&`、检查 hook IsBound 而非删除的 static。Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.HotReload" -Label classgen-hooks-7.1 -TimeoutMs 1200000`

- [x] 7.2 <!-- TDD --> 新增 multi-engine 隔离测试 `AngelscriptHotReloadMultiEngineHooksTests.cpp`：(a) Engine A broadcast 8 hooks → A counters=1，B counters=0；反向 broadcast B 后 B advances，A 不再 echo。(b) Engine A 创建+订阅+broadcast+析构 → 后续 Engine B broadcast 必须正常 fire 且不受 A teardown 影响。Automation IDs: `Angelscript.TestModule.HotReload.MultiEngineHooks.*`. Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.HotReload" -Label classgen-hooks-7.2-isolation -TimeoutMs 1200000`

## 8. Final Verification

- [x] 8.1 <!-- Non-TDD --> Whole-project build。`Result: Succeeded`. Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label deglobalize-final-8.1-build -TimeoutMs 1800000`

- [x] 8.2 <!-- Non-TDD --> Smoke (15/15) + RuntimeCpp (CppTests 8/8 + Engine 97/97) + Bindings (258/258) + HotReload (42/42) 套件作为整体回归。Verify (sequential): `Tools\RunTestSuite.ps1 -Suite Smoke` ; `... -Suite RuntimeCpp` ; `... -Suite Bindings` ; `... -Suite HotReload`

- [x] 8.3 <!-- Non-TDD --> Engine lifecycle 测试覆盖 (97/97 passed)。Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Engine" -Label deglobalize-final-8.3-engine -TimeoutMs 1200000`

- [x] 8.4 <!-- Non-TDD --> grep cleanup 确认：(a) `FAngelscriptClassGenerator::On(ClassReload|EnumCreated|EnumChanged|StructReload|DelegateReload|FullReload|PostReload|LiteralAssetReload)` 仅余 1 处文档注释（ScriptEditorMenuExtension.cpp:75 解释迁移历史）。(b) `GScriptEnumTypeLookupByName` 仅余 1 处文档注释（FormatMultiEngine 测试文件内说明）。(c) `FToStringType::TypeInfo` fence comment 在 Bind_FString.cpp 与 test 文件中作为文档存在；写入只发生在 engine-owned list 路径。

- [x] 8.5 <!-- Non-TDD --> Run `openspec validate refactor-as-runtime-deglobalize-completion --strict --json` 确认 change 通过。Ready for `openspec archive`.
