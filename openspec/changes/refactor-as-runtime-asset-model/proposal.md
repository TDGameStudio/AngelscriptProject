## Why

当前 `asset Name of UObjectClass { ... }` 实际创建并 Root 一个 transient UObject，却使用了 UE Asset 术语，既不能表达 `FPrimaryAssetId`/Bundle，也容易被误认为会创建 `.uasset`。现在需要把 `asset` 收紧为真正的、延迟登记并可直接异步加载的 `UAssetManager` Dynamic Asset；旧的单对象用途交给兄弟变更 `feature-as-usingleton-keyword`。

## What Changes

- **BREAKING** `asset Name of PrimaryAssetType { ... }` 不再接受 UObject Type，也不创建 UObject；声明身份精确映射为 `FPrimaryAssetId(PrimaryAssetType, Name)`，即 `Type:Name`。
- `asset` 保持小写语言关键字，不新增 `UASSET` 宏。声明块是受限的纯描述 builder，只能设置可选 `AssetPath` 和确定性的 `FAssetBundleData Bundles`；至少需要一个有效 Bundle asset path。
- 编译和模块激活只保存并验证标准化描述，不调用 `AddDynamicAsset`。第一次 `Name::GetId()` 或 `Name::LoadAsync(...)` 才延迟登记；`LoadAsync` 可直接使用，不要求调用方先 Get ID。
- 每个声明自动生成：`FPrimaryAssetId Name::GetId()`、默认加载全部已声明 Bundle 的 `Name::LoadAsync(...)`、显式 Bundle 子集 overload，以及 `int Name::Unload()`。
- `LoadAsync` 复用现有 `UAssetManager` 异步 callback 契约；packaged runtime 不新增同步加载路径。`Unload` 只释放该 Primary Asset ID 的加载状态，不删除登记。
- 每个 `FAngelscriptEngine` 保存自己的定义/owner，生产 backend 对共享 `UAssetManager` 做描述指纹和引用计数协调：相同 ID+相同标准化描述共享，不同描述或磁盘扫描 Type 冲突拒绝。
- 最后一个脚本 owner/module 退出时先释放加载状态，再删除 Dynamic Asset record；未物化的声明退出时没有 AssetManager 副作用。
- 非 PIE reload 对已物化的同 ID 描述做事务式更新/rollback；ID 变化按旧 owner 释放加新定义延迟登记处理。
- PIE 中任何 Asset 声明、builder 或生成 API 描述变化都拒绝并排队，last-good 模块与登记继续工作；完全无关的普通函数体仍可走现有 soft reload。
- 旧 UObject literal asset 立即给出完整迁移示例：`USINGLETON(Global)` + `singleton Name of UObjectType` + `Init { ... }`；不提供兼容开关或无提示重解释。

## Capabilities

### New Capabilities

- `as-runtime-dynamic-asset-model`: 定义 Dynamic Asset 语法、纯 builder、自动 API、延迟登记、异步加载、卸载、共享冲突、模块所有权、热更新、PIE 与旧语法迁移契约。

### Modified Capabilities

- None.

## Impact

- Runtime：`AngelscriptPreprocessor`、`FAngelscriptModuleDesc`/StaticJIT archive、`FAngelscriptEngine`、新的 Dynamic Asset Registry/backend coordinator、现有 `UAssetManager` bind helper 和 State Dump。
- Editor：删除 literal UObject asset 保存/回写 hook 和 literal object replacement 连接；Asset declaration reload 只处理描述符，不创建 Editor 资产。
- Tests：替换 LiteralAsset/PostInit/Editor-save 预期，新增 Preprocessor、Dynamic Asset backend/API、HotReload、PIE、Dump、multi-engine 与 Standalone UE-validation 覆盖。
- Compatibility：不会创建 Content Browser `.uasset`，不会让未 Cook 的路径自动进入 Shipping 包，也不会依赖 Singleton change 的运行时代码才能表示 Dynamic Asset。
- Detailed record：`research.md`、`attachments/syntax-and-api.md`、`attachments/registry-backend-reload.md`、`attachments/test-plan.md`。
