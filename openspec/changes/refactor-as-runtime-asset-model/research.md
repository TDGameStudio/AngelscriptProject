# UE runtime Dynamic Asset research

日期：2026-08-12
状态：本 change 的已确认设计输入；待实现行为以 `specs/` 为规范，以 `design.md`/attachments 为实现约束。

## 1. 三种概念必须分离

| AngelScript concept | UE backing | 创建 UObject | 创建磁盘 `.uasset` | Intended use |
| --- | --- | --- | --- | --- |
| `singleton` sibling | Engine-owned runtime Registry + legal UObject construction | yes | no | 默认或具名运行时对象 |
| `asset` in this change | `UAssetManager::AddDynamicAsset` | no | no | PrimaryAssetId、soft path、Bundle 与按需 streaming |
| future Editor asset authoring | `IAssetTools` + `UFactory` + package save | yes | yes | Content Browser 持久资产 |

因此 `asset` 不再创建 `UDataAsset`、Curve、Actor、Component 或其他 UObject。磁盘 `UDataAsset`/`UPrimaryDataAsset` 可以是 `AssetPath` 或 Bundle 引用的既有 Cookable 资源，但不是声明自身的 backing object。

## 2. 当前插件事实

当前 Runtime `Preprocessor/AngelscriptPreprocessor.cpp::PostProcessLiteralAssets`：

- 用 regex 匹配 `asset Name of Type`；
- 生成模块全局 `__Asset_Name`、`GetName()`、`__CreateLiteralAsset`、`__Init_Name`；
- 把 `GetName` 加入 `FAngelscriptModuleDesc::PostInitFunctions`，所以并非延迟创建；
- 依赖 `FAngelscriptEngine::AssetsPackage`、literal creation/setup/reload delegates 和 RootSet package。

现有 AssetManager bindings 已经提供：

- `FPrimaryAssetId`/`FPrimaryAssetType` constructors and parsing；
- `FAssetBundleData::AddBundleAsset(s)`、`SetBundleAssets` 等值类型操作；
- `UAssetManager.LoadPrimaryAsset(s)` 的异步 callback adapter；
- `UAssetManager.UnloadPrimaryAsset(s)` 返回受影响 handle 数。

新生成 API 应复用这些实现，不复制另一套 callback/streaming 状态机。

## 3. UE 5.8 source evidence

本机 `AgentConfig.ini` 指向 `C:\Program Files\Epic Games\UE_5.8`。2026-08-12 检查 `Engine/Source/Runtime/Engine/Private/AssetManager.cpp:1743-1797` 的 `UAssetManager::AddDynamicAsset`，确认：

1. invalid `FPrimaryAssetId` returns false；
2. non-null AssetPath 必须是 asset path；
3. 新 Type 被标记 `bIsDynamicAsset=true`；已有 disk-scanned/non-dynamic Type 被拒绝；
4. BundleData 非空才 `FindOrAddAsset` 并缓存 Bundle；
5. BundleData 为空且 old data 存在时，移除 cached bundle 和 asset record；
6. 不同 path 会输出 replacement warning，而不是为调用方自动做 owner conflict protection。

直接结论：

- v1 声明必须至少含一个有效 Bundle path；仅 AssetPath 不构成可持久登记的 record。
- 最后 owner 删除可以使用同 ID+空 Bundle，但必须有跨支持 UE 版本的 contract test。
- AS backend 必须在调用前自己检查 fingerprint/owner，不能依赖 `AddDynamicAsset` 防止覆盖。
- PrimaryAssetType 不能与项目 disk scan rule 复用。

## 4. Register is not Load

`AddDynamicAsset` 保存 ID、optional soft path 和 Bundle soft path metadata；它不加载这些路径指向的 UObject、纹理 mip、mesh 或音频。实际加载由 `LoadPrimaryAsset(s)` 或 bundle-state API 发起，并由 Streamable Manager 异步完成。

因此状态必须区分：

1. source definition exists；
2. descriptor has been materialized into AssetManager；
3. AssetManager currently has load handles/resources for the ID。

本 change 只直接拥有 1/2；第 3 层继续使用 UE AssetManager 语义。先前研究中“新增 Registered/Loading/Loaded/Failed/Released 全套脚本状态 API”的想法已明确取消为 v1 非目标，避免复制不完整的 AssetManager 状态机。

## 5. Why keep GetId if direct LoadAsync exists

调用方不必先 Get ID。`Name::LoadAsync(...)` 自己 EnsureMaterialized 并开始异步加载，是文档首选路径。

仍保留 `Name::GetId()`，因为 `FPrimaryAssetId` 是 UE 现有 API 的互操作键：日志/保存、AssetManager 查询、批量加载、bundle-state 调整和跨系统消息都可能只需要 ID。GetId 的准确语义是“确保轻量 Dynamic Asset record 已登记并返回 ID”，不是“创建/加载资产对象”。

## 6. Cook and packaged-runtime constraints

Dynamic Asset record 可以在运行时描述 Bundle，但不会使路径自动进入 cook。Shipping 中只有已经被项目 AssetManager rules、Primary Asset labels、显式 cook directories 或其他 cook references 收集的资源才可加载。

本 change 的 builder 做路径形状验证，Editor/test 可以选择做存在性/cookability 诊断，但 packaged runtime 不能尝试创建、导入、下载或同步读取缺失资源。

## 7. Resolved design questions

| Former question | Resolution |
| --- | --- |
| syntax TBD | fixed as `asset Name of PrimaryAssetType { AssetPath=...; Bundles...; }` |
| need `UASSET`? | no; `asset` is the declaration keyword |
| eager or lazy registration? | lazy on first `GetId` or `LoadAsync` |
| must callers GetId before load? | no; direct generated `LoadAsync` is canonical |
| load all or selected Bundle? | provide both overloads; no-argument bundle choice means all declared names |
| sync load? | forbidden in packaged runtime surface |
| empty Bundle? | invalid declaration because current engine interprets it as remove/no-add |
| module unload? | release owner; last owner unloads ID then removes record |
| same ID across Engines? | same normalized descriptor shares; conflicts reject |
| old UObject literal? | immediate compile diagnostic to sibling named Singleton syntax |
| PIE body-only descriptor edit? | all Asset-related changes reject and queue |
