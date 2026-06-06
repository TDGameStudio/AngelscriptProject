# Tasks: refactor-as-runtime-deglobalize-completion

> 主线已被 `refactor-as-runtime-typeinfo-engine-scoped` 归档建立基线 spec
> `as-engine-scoped-runtime-state`。本 change 一次性收尾去全局化的剩余工作
> （enum lookup / ToString fence / format 多 engine 测试 / ClassGen 8 委托 /
> ClassReloadHelper per-engine / 测试迁移）。
> 验证命令仅使用 `Tools\RunBuild.ps1`、`Tools\RunTests.ps1`、`Tools\RunTestSuite.ps1`。

## 1. Deglobalize Enum Type Lookup

- [ ] 1.1 <!-- Non-TDD --> Move `Bind_UEnum.cpp:334` 的 `static TMap<FName, asITypeInfo*> GScriptEnumTypeLookupByName` 到 engine-keyed 存储（`TMap<asIScriptEngine*, TMap<FName, asITypeInfo*>>` 或 `FAngelscriptEngine` 上的字段）。Bind 写入与 lookup 都按当前 engine 隔离。Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label deglobalize-enum-1.1 -TimeoutMs 900000 -NoXGE`

- [ ] 1.2 <!-- Non-TDD --> 接入 `FAngelscriptStaticTypeInfoRegistry::RegisterClearer` 注册模式（或 engine teardown 直接清理），让旧 engine 条目不会被新 engine 看到。Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Engine" -Label deglobalize-enum-1.2 -TimeoutMs 1200000`

## 2. Fence ToString Fallback

- [ ] 2.1 <!-- Non-TDD --> 审计 `Helper_ToString.h:27` 的 `FToStringType::TypeInfo` 字段所有读写点。判断 fallback 路径（`Bind_FString.cpp:424` 的 `LegacyToStringList`）是否真的会保存跨 engine 的 `asITypeInfo*`；如是则 fence：迁到 engine-owned `ToStringList` 或 fallback 中只保留元数据（去掉 `TypeInfo` 字段）。Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Bindings.FString" -Label deglobalize-tostring-2.1 -TimeoutMs 900000`

## 3. Multi-Engine Format Regression

- [ ] 3.1 <!-- TDD --> 添加 multi-engine `FString::Format` 回归覆盖：Engine A bind FString → destroy Engine A → 新 Engine B 起来 → `FString::Format("{0}", "Hello")` 必须返回 `Hello`。优先在 `Plugins/Angelscript/Source/AngelscriptTest/Bindings/AngelscriptFStringBindingsTests.cpp`。Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Bindings.FString" -Label deglobalize-3.1-fstring-format-multi-engine -TimeoutMs 900000`

- [ ] 3.2 <!-- TDD --> 添加等价 `FText::Format` multi-engine 回归覆盖。Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Bindings" -Label deglobalize-3.2-ftext-format-multi-engine -TimeoutMs 900000`

## 4. Add Reload Hooks to FAngelscriptEngineHooks

- [ ] 4.1 <!-- Non-TDD --> 评估 `FAngelscriptEngineHooks::OnLiteralAssetCreated` 与 `FAngelscriptClassGenerator::OnLiteralAssetReload` 是否语义等价。如等价标记为合并；如不等价则独立加。

- [ ] 4.2 <!-- Non-TDD --> 在 `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngineHooks.h` 新增 reload hook 字段（7 或 8 个），typedef 从 `AngelscriptClassGenerator.h` 迁过来或共用现有 typedef。提供 `Get*` accessor。Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label classgen-hooks-4.2 -TimeoutMs 900000 -NoXGE`

## 5. Migrate Trigger Sites and Remove Static Delegates

- [ ] 5.1 <!-- Non-TDD --> 改造 `AngelscriptClassGenerator.cpp` 中所有 `On*Reload.Broadcast` / `OnEnum*.Broadcast` 等触发点（cpp:2471/2490/2496/2518/2596/3887/3891/3946 + `Bind_UObject.cpp:658`），替换为 `FAngelscriptEngine::Get().GetHooks().GetOnXxx().Broadcast(...)`。Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label classgen-hooks-5.1 -TimeoutMs 900000 -NoXGE`

- [ ] 5.2 <!-- Non-TDD --> 评估 `PerformReload()` 等 static 方法是否需要改成 engine-bound（每个触发点是否有 thread context engine 可用）。如不可用则改造调用约定。Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label classgen-hooks-5.2 -TimeoutMs 900000 -NoXGE`

- [ ] 5.3 <!-- Non-TDD --> 删除 `AngelscriptClassGenerator.h:31-38` 的 8 个 static 委托声明 + cpp 中对应实例定义。grep 确认 `FAngelscriptClassGenerator::On*` 在子模块中归零。Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label classgen-hooks-5.3 -TimeoutMs 900000 -NoXGE`

## 6. ClassReloadHelper Per-Engine Refactor

- [ ] 6.1 <!-- Non-TDD --> `Plugins/Angelscript/Source/AngelscriptEditor/ClassReloadHelper.h` 全局 `static FReloadState` → per-engine 存储（`TMap<FAngelscriptEngine*, FReloadState>` 或挂在 engine extension）。Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label classgen-hooks-6.1 -TimeoutMs 900000 -NoXGE`

- [ ] 6.2 <!-- Non-TDD --> 8 个订阅 lambda（`ClassReloadHelper.h:96-200`）从 `FAngelscriptClassGenerator::On*.AddLambda` 迁到 `FAngelscriptEngine::Get().GetHooks().GetOnXxx().AddLambda`。订阅时机改成 per-engine attach（通过 `as-engine-extension-registry`）。Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label classgen-hooks-6.2 -TimeoutMs 900000 -NoXGE`

- [ ] 6.3 <!-- Non-TDD --> 迁移 `ScriptEditorMenuExtension.cpp:73` 的 `OnPostReload.AddLambda` 到新 hook surface + per-engine attach。Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.AngelscriptEditor" -Label classgen-hooks-6.3 -TimeoutMs 900000`

## 7. Test Migration + Multi-Engine Isolation

- [ ] 7.1 <!-- Non-TDD --> 把现有 hot reload 测试（`AngelscriptHotReloadEventTests.cpp` / `AngelscriptHotReloadLiteralAssetTests.cpp` / `AngelscriptHotReloadEnumDelegateTests.cpp` / `AngelscriptHotReloadDelegateTests.cpp`）的订阅方式迁到 `FAngelscriptEngine::Get().GetHooks().GetOnXxx().AddLambda`。`FScopedReloadEventRecorder` 等 helper 同步调整。Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.HotReload" -Label classgen-hooks-7.1 -TimeoutMs 1200000`

- [ ] 7.2 <!-- TDD --> 新增 multi-engine 隔离测试：Engine A reload 时 Engine B 订阅 lambda 不被触发。覆盖 OnPostReload + OnClassReload + OnFullReload 至少。Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.HotReload" -Label classgen-hooks-7.2-isolation -TimeoutMs 1200000`

## 8. Final Verification

- [ ] 8.1 <!-- Non-TDD --> Whole-project build。Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label deglobalize-final-8.1-build -TimeoutMs 1800000`

- [ ] 8.2 <!-- Non-TDD --> Smoke + RuntimeCpp + Bindings + HotReload 套件作为整体回归。Verify (sequential): `Tools\RunTestSuite.ps1 -Suite Smoke` ; `... -Suite RuntimeCpp` ; `... -Suite Bindings` ; `... -Suite HotReload`

- [ ] 8.3 <!-- Non-TDD --> Engine lifecycle 测试覆盖。Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Engine" -Label deglobalize-final-8.3-engine -TimeoutMs 1200000`

- [ ] 8.4 <!-- Non-TDD --> Confirm grep cleanup: `FAngelscriptClassGenerator::On*` 全部归零；`GScriptEnumTypeLookupByName` 不再 process-wide static；`FToStringType::TypeInfo` 在 fallback 中被 fence 或移除。

- [ ] 8.5 <!-- Non-TDD --> Run `openspec validate refactor-as-runtime-deglobalize-completion --strict --json` 确认 change 通过。Ready for `openspec archive`.
