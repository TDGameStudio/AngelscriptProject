# UE runtime dynamic-asset research

日期：2026-08-11  
状态：已确认的设计输入；不是实施方案或最终 API 规格。

## 结论

UE 中“运行时创建一个 UObject”与“运行时定义一个 Dynamic Asset”是两个不同模型，必须由 AngelScript 的不同语法承担。

| AngelScript 概念 | UE backing model | 创建 UObject | 磁盘 `.uasset` | 核心用途 |
| --- | --- | --- | --- | --- |
| `singleton` | `NewObject` + AS runtime registry | 是 | 否 | 一份具名、脚本托管的运行时 UObject |
| `asset` | `UAssetManager::AddDynamicAsset` | 否 | 否 | 定义 Primary Asset ID、软引用和 Bundle，按需加载既有 Cookable 资产 |
| future Editor-only asset authoring | `IAssetTools` + `UFactory` + package save | 是 | 是 | 在 `/Game` 创建、登记并保存真实 Content Browser 资产 |

因此 `asset` 不得用于创建任意 UObject、`UDataAsset`、`UCurveFloat`、Actor、Component 或导入型内容资产本体；它只定义逻辑上的 runtime asset record。若要创建实际 UObject，使用 `singleton`（首期）或后续显式的 transient/prototype API。

## UE 官方 API 事实

### `UAssetManager::AddDynamicAsset`

签名：

```cpp
bool AddDynamicAsset(
    const FPrimaryAssetId& PrimaryAssetId,
    const FSoftObjectPath& AssetPath,
    const FAssetBundleData& BundleData);
```

- UE 文档定义 Dynamic Asset 为“runtime-specified asset”，没有 on-disk representation，因而没有 `FAssetData`；但可以有 path 与 bundle state。
- `PrimaryAssetId` 必须有效；代表对象路径可为空，若非空必须是顶层 asset path。
- Bundle 只保存对既有资产的软路径，不能使一个未 Cook 的资源在 Shipping runtime 中出现。
- 引擎源码将新 Dynamic Asset Type 标记为 `bIsDynamicAsset = true`，并拒绝让同一个 Primary Asset Type 同时作为动态类型和扫描磁盘资产类型。因此 AS Dynamic Asset Type 必须使用专属、不会与项目扫描规则冲突的命名空间。

### 延迟加载与内存模型

- 调用 `AddDynamicAsset` 会创建或更新 Asset Manager 中的轻量登记数据：Primary Asset ID、可选 `FSoftObjectPath`、Dynamic Asset Type 记录以及 Bundle 名称到软路径的映射。它会占用这些元数据/路径容器的内存，但**不会加载** Bundle 指向的 UObject、`.uasset`、纹理 mip、网格或音频数据。
- `AssetPath` 是可选的代表对象软路径；非空不意味着该对象已经载入。Lyra 的 `ULyraGameplayCueManager::RefreshGameplayCuePrimaryAsset` 传递空代表路径、只注册 Bundle，证明 Dynamic Asset 可以纯粹作为运行时资源集合。
- 实际资源加载必须通过 `UAssetManager::LoadPrimaryAsset` / `LoadPrimaryAssets` 或 bundle-state 改变 API 触发。这些调用使用 Streamable Manager 异步加载所请求 Bundle 的既有 Cookable 路径，返回 `FStreamableHandle`。
- 只要对应 `FStreamableHandle` 保持 active，加载的资源将留在内存；卸载/释放 Handle 后，在没有其他强引用时资源可以被释放。Dynamic Asset 的登记记录可继续保留，以便之后重新加载不同 Bundle。
- 因而注册大量 `asset` 定义并不等于预加载全部资源；首期设计必须让 `asset` 的“已登记”与“Bundle 已加载”状态可区分，并禁止同步隐式加载。

Knot 对 UE `ue5-main` 的源码检索确认了 `UAssetManager::AddDynamicAsset` 的上述实现，并找到 Lyra 的 `ULyraGameplayCueManager::RefreshGameplayCuePrimaryAsset`：它收集 `FSoftObjectPath`，填充 `FAssetBundleData`，再注册一个无代表对象路径的 Dynamic Asset。这是可借鉴的生产模式。

### `NewObject`

- `NewObject` 创建的是内存 UObject；其 Outer 决定所有权/生命周期。
- 没有 Outer 时对象进入 transient package；它不自动保存、不会生成 Content Browser 资产、也不会成为 Asset Registry 的磁盘条目。
- 现有 literal `asset` 正是此模式，只是将 Outer 固定到 `/Script/AngelscriptAssets` 并以 RootSet 保活；这部分迁移至 `singleton`。

### Editor 持久资产

- `IAssetTools::CreateAsset` / `CreateAssetAsync` 需要 asset name、package path、asset class 和 `UFactory`。
- `UFactory::FactoryCreateNew` 负责创建目标对象；实际文件资产还需要 package 保存、Asset Registry、dirty state、事务和错误处理。
- 因其 Editor 模块依赖和持久化/Cook 约束，此能力不得作为 packaged runtime `asset` 的隐式副作用。

## 设计约束与待定点

1. `singleton` 的首期 Outer、GC 保活策略和 Hot Reload 替换规则待 design.md 定义；不应默认沿用所有 `RF_MarkAsRootSet` 行为。
2. `asset` 的语法待定，但必须能无歧义地表达 Primary Asset ID、可选代表路径和多个 Bundle 的软路径。
3. 首期 `asset` 只允许引用已经 Cook 的路径；Cook 可达性/验证、无效路径诊断以及 Asset Manager 不可用时的失败模式必须成为测试场景。
4. 现有 `asset Name of UClass { ... }` 是破坏性迁移：需要明确保留期、诊断和自动/文档迁移路径，不能在无提示下解释为新的 Dynamic Asset。
5. `UDataAsset` / `UPrimaryDataAsset` 可作为 `asset` Bundle 所引用的既有磁盘资产，但不是 `asset` 声明自身的 runtime backing class。
6. `asset` 的语言/API 设计必须提供 Registered、Loading、Loaded、Failed、Released 等可观察状态，按 Bundle 显式异步加载；不得因声明、查询或读取元数据而隐式同步加载资产。
