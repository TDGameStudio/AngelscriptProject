## Context

现有 `PostProcessLiteralAssets` 用 regex 把 `asset Name of Type` 改写成模块全局 UObject 缓存、`Get{Name}()`、`__CreateLiteralAsset` 和 `__Init_{Name}`，随后把 Getter加入 `PostInitFunctions`，因此对象在模块初始化阶段被强制创建。Runtime 还维护共享 `/Script/AngelscriptAssets` package、RootSet 引用和 literal reload delegate；Editor 则把某些 literal 对象回写成脚本文本。

UE Dynamic Asset 是另一种模型：`FPrimaryAssetId + optional FSoftObjectPath + FAssetBundleData` 只登记逻辑记录，资源必须经 `LoadPrimaryAsset(s)` 异步加载。当前插件已经绑定 `FPrimaryAssetId`、`FAssetBundleData`、`UAssetManager::LoadPrimaryAsset(s)` 和 `UnloadPrimaryAsset(s)`，因此新的声明 API 应当复用这条路径，而不是再造对象缓存。

本机 UE 5.8 源码确认 `AddDynamicAsset` 只在 Bundle 非空时添加/更新 record，空 Bundle 对已有 ID 会移除 cached bundle 和 asset record；Type 也不能同时是 dynamic 和 disk-scanned。这个版本敏感事实必须由 backend contract tests 锁定，不能只靠注释假设。完整证据与已解决问题见 `research.md`。

## Goals / Non-Goals

**Goals:**

- 让 `asset Name of PrimaryAssetType` 明确对应 `Type:Name` Dynamic Asset，而不是 UObject 或磁盘资产。
- 把描述验证、Dynamic Asset 登记和 Bundle 异步加载分成三个阶段，并确保前两者都不隐式同步加载资源。
- 让常见调用直接使用 `Name::LoadAsync()`；同时保留 `Name::GetId()` 供查询、组合及与现有 AssetManager API 互操作。
- 在多个 Angelscript Engine 共享同一 `UAssetManager` 时安全协调 ID、描述与模块 owner。
- 在非 PIE reload 中提供可回滚更新，在 PIE 中保持整个 Asset 声明 last-good。
- 机械删除旧 literal UObject bridge，并给出无歧义 Singleton 迁移。

**Non-Goals:**

- 不创建、导入、保存或修改 Content Browser `.uasset`；Editor asset authoring 仍是独立未来能力。
- 不新增同步 `Load`、隐式对象转换、自动 Cook 收集或任意文件/网络加载。
- 不在首期返回 `FStreamableHandle`、提供 owner-isolated load handle、细粒度 Loading 状态 API，或复制第二套 AssetManager 状态机。
- 不让 Standalone 模拟 `UAssetManager`、UObject、Cook 或资源 streaming。
- 不提供 `UASSET` 宏，也不允许 `asset` body 执行任意脚本副作用。

## Decisions

### 1. `asset` 是无宏的 Primary Asset 声明

Canonical syntax：

```angelscript
asset WeaponCatalog of GameplayCatalog
{
    AssetPath = FSoftObjectPath("/Game/Data/DA_WeaponCatalog.DA_WeaponCatalog");
    Bundles.AddBundleAsset(n"Client", FTopLevelAssetPath("/Game/Weapons/SK_Rifle.SK_Rifle"));
    Bundles.AddBundleAsset(n"Server", FTopLevelAssetPath("/Game/Data/DT_WeaponStats.DT_WeaponStats"));
}
```

`GameplayCatalog` 是 opaque `FPrimaryAssetType` token，不是 UClass。名称精确得到 `GameplayCatalog:WeaponCatalog`。声明可处于 namespace，但 namespace/module 不改变 Primary Asset ID；它们只参与 source owner 和生成 API 的符号解析。

不增加 `UASSET`，因为声明不生成反射 UObject 类型，也没有需要 UHT 风格 metadata 的第二语义层。详细 grammar/allowlist/生成签名见 `attachments/syntax-and-api.md`。

### 2. Builder 在候选验证期变成标准化纯数据

Parser 对 body 使用 allowlist，不执行任意 AngelScript：可设置一次可选 `AssetPath`，并通过固定 `Bundles` mutation surface 添加 compile-time-known Bundle name 和 top-level asset paths。禁止函数调用、UObject/World/Singleton 访问、控制流、加载和全局状态读取。

标准化步骤：验证 PrimaryAssetId；canonicalize AssetPath；按 Bundle name 排序；每个 Bundle 的 path 排序去重；拒绝 `None` Bundle、无效/非 top-level path；至少保留一个 Bundle asset path；生成 descriptor fingerprint。这样 source 顺序和重复 Add 不导致虚假 reload/conflict。

### 3. 每个声明生成直接可用的 namespace API

生成 surface：

```angelscript
FPrimaryAssetId WeaponCatalog::GetId();

void WeaponCatalog::LoadAsync(
    int32 Priority = 0,
    UObject OptionalCallbackObject = nullptr,
    FName OptionalFinishedCallbackFunctionName = NAME_None,
    FName OptionalCanceledCallbackFunctionName = NAME_None);

void WeaponCatalog::LoadAsync(
    const TArray<FName>& LoadBundles,
    int32 Priority = 0,
    UObject OptionalCallbackObject = nullptr,
    FName OptionalFinishedCallbackFunctionName = NAME_None,
    FName OptionalCanceledCallbackFunctionName = NAME_None);

int WeaponCatalog::Unload();
```

`GetId()` 不是创建前置步骤：`LoadAsync` 内部会确保延迟登记，然后直接委托现有异步 wrapper。`GetId()` 保留是因为大量 AssetManager、bundle-state、日志/保存和跨系统 API 接受 `FPrimaryAssetId`；调用它只登记元数据，不加载 Bundle UObject。默认 `LoadAsync` 使用标准化描述中全部 Bundle 名；overload 使用调用方子集。

### 4. Materialization 由首次 GetId/LoadAsync 触发

编译、module activation、State Dump 和定义查询只产生 Engine-local `FAngelscriptDynamicAssetDesc`。第一次 `GetId` 或 `LoadAsync` 调用 Registry 的 EnsureMaterialized；成功调用一次 backend `AddDynamicAsset` 并增加 owner。失败时抛出 script exception、记录 last error、保持 Unmaterialized，后续调用可以重试。

`Unload` 在从未 materialize 时返回 0 且不登记。已 materialize 时它只调用 `UAssetManager::UnloadPrimaryAsset(Id)`，返回受影响 handle 数；descriptor owner 和 Dynamic Asset record 保留到最后一个 owner/module 退出。

### 5. Engine-local Registry 与共享 backend 分层

每个 `FAngelscriptEngine` 拥有 `FAngelscriptDynamicAssetRegistry`，以 source owner token 跟踪本 Engine 的描述和 materialized ownership。`FAngelscriptEngineDependencies` 注入 `IAngelscriptDynamicAssetBackend`：生产 backend 由 Engine subsystem 生命周期拥有并协调真实共享 `UAssetManager`；单元测试注入内存 backend，避免操作真实全局 AssetManager。

共享 backend 以 PrimaryAssetId 保存 normalized fingerprint、完整描述、owner token set 与 origin。已知 AS owner 请求相同 ID+相同描述时共享；不同描述拒绝并保持原 record。disk-scanned Type 或预先存在但非本 coordinator 所有的 ID 默认拒绝，防止 `AddDynamicAsset` 静默覆盖外部记录。

### 6. 至少一个 Bundle path 是登记契约，不是风格建议

当前 UE `AddDynamicAsset` 对 BundleData.Num()==0 的已有 ID 执行删除，对新 ID 不会增加 record。因此仅 AssetPath、空 Bundle 的声明不是可注册 Dynamic Asset，必须在候选验证期拒绝。删除最后一个 AS owner 时，backend 正是利用同 ID+空 Bundle 的引擎行为移除 record；这个行为要由当前支持 UE 版本的 integration test 验证。

### 7. Load/Unload 复用 UAssetManager 语义

两个 `LoadAsync` overload 复用 `FAngelscriptUAssetManagerBinds` 当前 callback adapter 和 `LoadPrimaryAsset`。首期返回 `void`，不引入新的 handle wrapper。默认 overload 传入全部声明 Bundle；subset overload 原样传入调用方选择。

`Unload()` 是 PrimaryAssetId 级 AssetManager 操作，可能释放其他调用方对同一 ID 发起并由 AssetManager 跟踪的 load handle；它不是 source owner release，也不减少 Dynamic Asset record 的 owner refcount。需要调用方隔离的 handle 生命周期属于未来 API，不在本 change 中伪装实现。

声明、GetId、Dump 和 unload-never-materialized 都不加载资源。LoadAsync 也只走异步 streaming。路径是否被 Cook 是项目 packaging 配置责任；运行时缺失按现有 AssetManager callback/logging 失败，不尝试同步文件加载或动态 Cook。

### 8. Non-PIE reload 是 descriptor/backend 事务

- 未 materialize 且 ID 不变：直接替换 Engine-local normalized descriptor，无 backend call。
- materialized、ID 不变、描述相同：保持 record/owner，不调用 AddDynamicAsset。
- materialized、ID 不变、描述变化：只有当没有其他 owner 仍要求旧 fingerprint 时才可尝试 backend update；失败则恢复旧 record 与 last-good module/descriptor。
- ID 变化：提交时释放旧 owner；若为最后一个 owner则 Unload 后删除旧 record；安装新 definition 为 Unmaterialized，绝不自动登记新 ID。
- 另一个 Engine/module 仍拥有旧描述时，本 owner 的冲突更新拒绝并回滚，而不是强迫其他 owner 接受新定义。

Descriptor update 不隐式重新加载或卸载当前已加载资源；已有 AssetManager handle 遵循 UE 自己的生命周期，后续 LoadAsync 使用新 Bundle 描述。模块最后 owner 退出时才统一 Unload/remove。

### 9. PIE 对 Asset-related 变化全拒绝

PIE 中 Asset ID、AssetPath、Bundle 内容/顺序语义、builder、生成 API 或 descriptor hash 的任何变化都在 module swap 前拒绝并排队。活动 module、descriptor、backend fingerprint、record 和加载状态均不变。仅与所有 Asset descriptor 无依赖的普通函数体仍可 soft reload。

### 10. Literal UObject asset 立即迁移到 Singleton

当 `of` 后 token 解析为 UClass，或 body 出现旧式 UObject property 初始化时，编译器不得把它当作 PrimaryAssetType。诊断包含完整示例：

```angelscript
USINGLETON(Global)
singleton DefaultConfig of UGameConfig
{
    Init
    {
        Profile = n"Default";
    }
}
```

迁移后自动 Getter 是 `DefaultConfig::Get()`；不是旧的 `GetDefaultConfig()`。需要 World-owned UObject 时改用 `USINGLETON(World)`。旧 `__CreateLiteralAsset`、AssetsPackage、PostInit、Editor save-back 和 literal reload delegate 在同一次实现中删除，避免双语义共存。

### 11. Observability 与 offline contract 只描述，不加载

State Dump 分别输出 definition 与 materialized backend owner 状态，至少包含 Engine、module/namespace/name、PrimaryAssetId、normalized AssetPath、bundle/path counts、fingerprint、materialized、backend refcount、last error。Dump 不调用 EnsureMaterialized。

Offline bundle保存 normalized descriptor和生成 API signatures。Standalone UE-validation 可以编译/分析调用，但所有 GetId/LoadAsync/Unload runtime entry 都是明确不可执行的 UE trap；native-runtime 不模拟 AssetManager。

## Implementation File Map

| Area | Planned files | Responsibility |
| --- | --- | --- |
| Syntax/legacy removal | `AngelscriptRuntime/Preprocessor/AngelscriptPreprocessor.h/.cpp` | replace `PostProcessLiteralAssets`, pure builder parser, generated APIs, migration diagnostics |
| Descriptors/archive | `AngelscriptRuntime/Core/AngelscriptEngine.h`, `StaticJIT/PrecompiledData.h/.cpp` | normalized descriptor, hash and archive/offline round trip |
| Registry/backend | new `Core/AngelscriptDynamicAssetRegistry.h/.cpp`, `AngelscriptEngine.h/.cpp` | per-engine owners, lazy state, injected backend, shutdown/reload transaction |
| AssetManager bridge | `Binds/Bind_UAssetManager.h/.cpp`, `Bind_UAssetManager_Functions.cpp` | reusable callback adapter and generated GetId/LoadAsync/Unload routes |
| Legacy Runtime cleanup | `Binds/Bind_UObject.cpp`, `Bind_UObject_Functions.cpp`, `Core/AngelscriptEngine.h/.cpp` | delete literal creation hooks, AssetsPackage and RootSet ownership |
| Legacy Editor cleanup | `AngelscriptEditor/Core/AngelscriptEditorModule.h/.cpp`, `HotReload/ClassReloadHelper.h` | delete literal save-back and literal replacement delegate hookup |
| Observability | `Dump/AngelscriptStateDump.h/.cpp`, offline exporter/schema | read-only definition/materialization rows |
| Tests | files enumerated in `attachments/test-plan.md` | parser, backend, async API, reload/PIE, dump and standalone coverage |

## Risks / Trade-offs

- [空 Bundle 在引擎中意味着删除] → builder 要求至少一个有效 Bundle path；跨支持版本运行 backend deletion contract test。
- [多个 Engine 共享 UAssetManager] → injected shared coordinator 维护完整 descriptor fingerprint 和 owner set；不让 Engine-local map 直接互相覆盖。
- [同 ID 外部 Dynamic Asset 被静默替换] → 未被 coordinator 拥有的现存 record 默认冲突拒绝。
- [生成 Unload 被误认为删除声明] → API/docs/dump 明确区分 load state、materialized record 和 source owner 三层状态。
- [GetId 被误认为必须先调用] → 所有示例优先展示直接 `LoadAsync`；GetId 作为互操作/查询 API保留。
- [Bundle path 未 Cook] → 文档和测试区分“描述有效”与“packaged resource 可达”；不提供危险同步 fallback。
- [reload 时另一个 owner 仍使用旧描述] → 冲突更新拒绝并保持 last-good，而不是修改共享 record。
- [移除 literal Editor hook 影响曲线回写工作流] → 在迁移清单中明确列出被删除测试/入口，并把持久化 asset authoring 留给独立 Editor-only proposal。

## Migration Plan

1. 先加入 Dynamic Asset descriptor/parser/API 失败测试和内存 backend，证明无 PostInit/同步 load。
2. 接入生产 `UAssetManager` backend、共享 owner/refcount、async bridge 和 unload。
3. 接入 non-PIE transaction、PIE queue、Dump/offline contract。
4. 将现有 literal fixtures 分类：逻辑 Dynamic Asset 改用新 body；运行时 UObject 改用兄弟 `singleton`；Editor 持久资产工作流移出本语法。
5. 一次性删除 `PostProcessLiteralAssets` 旧 lowering、`__CreateLiteralAsset`、AssetsPackage/RootSet、literal delegates、Editor save-back 与对应旧测试。
6. 分别运行本 change 和 Singleton sibling 的 focused validation，再运行合并回归；两个 change 可以共同实现，但分别 strict validate/归档。

Rollback 必须恢复完整旧 literal pipeline 和 tests，或完整回退新 Dynamic Asset surface；不得让 `asset` 同时按 body 内容在 UObject 与 PrimaryAssetId 之间隐式切换。

## Open Questions

None. Syntax, generated APIs, lazy boundary, Bundle minimum, shared ownership, unload semantics and reload/PIE policy are fixed by this record.
