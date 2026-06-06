# refactor-as-runtime-deglobalize-completion

## Why

`refactor-as-runtime-typeinfo-engine-scoped` 已经把 TypeInfo + Legacy fallback +
ContextPool 三块去全局化工作归档为基线 spec `as-engine-scoped-runtime-state`。
本 change 一次性收尾去全局化主线剩下的所有进程级状态：

**Runtime 层（`as-engine-scoped-runtime-state` 增量）：**

- `Bind_UEnum.cpp:334` 的 `static TMap<FName, asITypeInfo*> GScriptEnumTypeLookupByName`
  仍是 process-wide。多 engine 场景下，前一个 engine bind 的 enum TypeInfo
  会留在表里，后续 engine 查同名 enum 拿到错误 engine 的 `asITypeInfo*`。
- `Bind_FString.cpp:424` 的 `static TArray<FToStringType> LegacyToStringList`
  主路径已迁，但 `FToStringType::TypeInfo`（`Helper_ToString.h:27`）字段仍可能
  在 fallback 路径中暴露跨 engine `asITypeInfo*`，需要 fence。
- 现有 `FString::Format` / `FText::Format` 测试只覆盖单 engine 场景，缺少
  "前 engine populate → destroy → 新 engine 再 format" 的多 engine 回归覆盖。

**Editor / Runtime 层（`as-engine-owned-hooks` 增量）：**

- `AngelscriptClassGenerator.h:31-38` 暴露 8 个 process-wide 静态委托
  （`OnClassReload` / `OnEnumCreated` / `OnEnumChanged` / `OnStructReload` /
  `OnDelegateReload` / `OnFullReload` / `OnPostReload` / `OnLiteralAssetReload`），
  与已归档基线 `as-engine-owned-hooks` 处理过的 compile-lifecycle hooks 性质
  完全相同（multicast、按 engine 生命周期触发）。但因为 process-wide，多 engine
  下会出现：
  - Editor `ClassReloadHelper.h` 维护**全局 `static FReloadState`**：所有 8 个
    委托共写，Engine A 会处理 Engine B 添加的类。
  - `OnPostReload` 触发全局 menu extension 重置 / `FBlueprintActionDatabase` /
    `FComponentTypeRegistry::InvalidateClass` —— 两个 engine 互相覆盖。

挂在 `FAngelscriptClassGenerator` 成员上不是去全局化方案——`ClassGenerator` 是
工作类（执行 class 生成动作的算子），不是 engine 实例化生命周期的载体。
正确位置是 `FAngelscriptEngine::Hooks`（`FAngelscriptEngineHooks` 容器），
对仗已基线的 compile-lifecycle hooks。

最后做完整 build + suite 验证，作为整条去全局化主线的 final verification。

## What Changes

### Runtime deglobalization

- 把 `GScriptEnumTypeLookupByName` 改成 engine-keyed，并接入
  `FAngelscriptStaticTypeInfoRegistry` 注册的 ClearForEngine 通道。
- Fence `FToStringType::TypeInfo` fallback 路径：优先迁到 engine-owned
  `ToStringList`；保留 fallback 时只允许元数据。
- 新增 multi-engine `FString::Format` / `FText::Format` 回归测试。

### ClassGen 委托迁到 FAngelscriptEngineHooks

- 在 `FAngelscriptEngineHooks` 中新增 reload hook 字段（7 或 8 个，取决于
  `OnLiteralAssetReload` 是否能合并入已有 `OnLiteralAssetCreated`）。
- 删除 `FAngelscriptClassGenerator` 上 8 个 static 委托。所有触发点改用
  `FAngelscriptEngine::Get().GetHooks().GetOnXxx().Broadcast(...)`。
- 评估并改造 `PerformReload()` 等 static 方法的调用约定，使其能携带 engine
  上下文。

### ClassReloadHelper per-engine 重构

- Editor `ClassReloadHelper.h` 全局 `static FReloadState` → per-engine
  存储。
- 所有 Editor 订阅方（~10 处 AddLambda / AddRaw）从
  `FAngelscriptClassGenerator::OnXxx.AddLambda(...)` 迁到
  `FAngelscriptEngine::Get().GetHooks().GetOnXxx().AddLambda(...)`，并通过
  `as-engine-extension-registry` 的 attach/replay 机制按 engine 挂载。

### Test migration + 隔离覆盖

- 现有 hot reload 测试订阅方式迁到新 hook surface。
- 新增 multi-engine 隔离测试：Engine A reload 时 Engine B 的订阅 lambda
  不被触发。

### Final verification

- whole-project build + Smoke / RuntimeCpp / Bindings / HotReload / Engine
  套件全过。

## Capabilities

### New Capabilities

- None.

### Modified Capabilities

- **as-engine-scoped-runtime-state**: 增量三条 requirement —— enum lookup
  engine-keyed、ToString fallback fence、format multi-engine 验收链路。
- **as-engine-owned-hooks**: 增量两条 requirement —— ClassGen 不再持有 process-wide
  reload 委托、Editor reload state per-engine。

## Impact

- **AngelscriptRuntime**: `Binds/Bind_UEnum.cpp`、`Binds/Bind_FString.cpp`、
  `Binds/Helper_ToString.h`、`Core/AngelscriptEngineHooks.h`、
  `ClassGenerator/AngelscriptClassGenerator.h/cpp`、`Binds/Bind_UObject.cpp`。
- **AngelscriptEditor**: `ClassReloadHelper.h/cpp`、`ScriptEditorMenuExtension.cpp`
  及其他订阅方。
- **AngelscriptTest**: `Bindings/AngelscriptFStringBindingsTests.cpp`（multi-engine
  format）；`HotReload/Angelscript*HotReload*Tests.cpp`（订阅方式迁移 + 隔离
  测试）。
- **Build / test workflow**: 仅使用 `Tools\RunBuild.ps1`、`Tools\RunTests.ps1`、
  `Tools\RunTestSuite.ps1`。
