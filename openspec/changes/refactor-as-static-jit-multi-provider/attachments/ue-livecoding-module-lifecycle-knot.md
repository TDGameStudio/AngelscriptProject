# UE Live Coding 与模块加载/卸载机制（Knot 源码核对）

## 目的与结论

本文记录 2026-08-13 通过 Knot 的 UE5-main 代码知识库
`d890d83194b04c8aad24d0e904cdb762`，并用本机 UE 5.8 源码交叉核对后的结论。
它回答两个容易混淆的问题：

1. Live Coding patch 是否等价于 `FModuleManager` 卸载并重载目标 UE 模块；
2. StaticJIT 的 Provider 身份交接、代码镜像保活和路由刷新分别应该放在哪一层。

核心结论是：**Live Coding 不通过 `FModuleManager::UnloadModule()` 重载目标模块。**
基础 UE 模块继续处于已加载状态；Live++ 了解这些已加载模块、编译并装入额外 patch
镜像、重映射函数，再由 UE 的 Live Coding reload/reinstancing 流程完成对象侧收尾。
普通 UE 模块生命周期和 Live++ patch 镜像生命周期是两套相关但不同的机制。

## Knot 与本机源码证据

### 1. Editor 在 Live Coding 与旧 Hot Reload 之间二选一

Knot 命中：

- `Engine/Source/Editor/LevelEditor/Private/LevelEditorActions.cpp`
  `FLevelEditorActionCallbacks::RecompileGameCode_Clicked`；
- `LiveCoding_StartSession_Clicked`、`LiveCoding_ToggleEnabled`。

源码行为：启用 Live Coding 时，Editor 调用
`ILiveCodingModule::EnableForSession(true)` 和 `Compile()` 并直接返回；只有不走该分支时
才调用旧 `IHotReloadInterface::DoHotReloadFromEditor()`。UE 还明确拒绝在已有 Hot Reload
模块的会话中再启用 Live Coding，要求关闭 Editor、从 IDE 构建后重启。

因此本变更的 `FAngelscriptJITRefreshService` 适配 `ILiveCodingModule` 是正确边界；它不应
再叠加旧 Hot Reload 模块重载流程。

### 2. 普通 `FModuleManager` 加载顺序

本机 UE 5.8：
`Engine/Source/Runtime/Core/Private/Modules/ModuleManager.cpp:981` 附近的
`FModuleManager::LoadModuleWithFailureReason`。

关键顺序：

```text
查找已加载 ModuleInfo；已就绪则直接返回
  -> 必要时登记模块并加载 DLL/取得 initializer
  -> 创建 IModuleInterface
  -> ProcessLoadedObjectsCallback
  -> StartupModule()
  -> 记录 LoadOrder
  -> bIsReady = true
  -> OnModulesChanged(ModuleLoaded)
```

Live Coding 订阅这个 `OnModulesChanged`，但该事件表示“UE ModuleManager 已经完成一次普通
模块加载”，不是 Live Coding 自己用它来重新加载 patch 目标模块。

### 3. 普通 `FModuleManager` 卸载顺序

本机 UE 5.8：
`ModuleManager.cpp:1317` 附近的 `FModuleManager::UnloadModule`。

关键顺序：

```text
bIsReady = false
  -> IModuleInterface::ShutdownModule()
  -> 销毁模块接口对象
  -> 非 monolithic 且 !bIsShutdown 且 bAllowUnloadCode
       -> InternalFreeLibrary()，实际卸载 DLL 代码
  -> 非 shutdown 时广播 OnModulesChanged(ModuleUnloaded)
```

两个安全细节非常重要：

- Engine shutdown 时 UE 故意不实际卸载 DLL，而是把代码留在进程里，降低其他模块的
  析构或虚函数仍调用这段代码的风险，最后由操作系统在进程退出时回收；
- `AbandonModule()` 会调用 `ShutdownModule()` 并销毁模块接口、广播逻辑卸载，但不执行
  DLL `FreeLibrary`。

这说明 UE 自己也区分“逻辑模块下线”和“物理代码取消映射”。StaticJIT 的退休模型应
遵循同一原则。

### 4. Live Coding 如何获知普通 UE 模块

Knot 命中与本机 UE 5.8：

- `LiveCodingModule.cpp` / `FLiveCodingModule::OnModulesChanged`；
- `FLiveCodingModule::OnDllLoaded`、`OnDllUnloaded`；
- `FLiveCodingModule::UpdateModules`；
- LiveCodingServer 的 `EnableRequiredModules`。

`OnModulesChanged(ModuleLoaded)` 只安排下一次 `UpdateModules()`。Windows loader
notification 也会把普通 UE DLL 的路径记入 `ModuleChanges`。`UpdateModules()` 将路径分成
preload 与 lazy-load 两类，然后调用 `LppEnableModulesEx()`，把**已经由 UE/OS 加载的模块**
告知 Live++，使它可以为这些模块准备补丁和地址空间。

它没有调用：

- `FModuleManager::UnloadModule(Target)`；
- `FModuleManager::LoadModule(Target)`；
- 目标模块的 `ShutdownModule()` / `StartupModule()` 对。

`IsUEDll()` 还会通过 `IsPatchDll()` 主动忽略 `.patch_N.*` 镜像，避免把 patch 自身再次
当作一个普通 UE 模块配置给 Live++。

### 5. Live Coding 编译与 patch/reinstancing 顺序

本机 UE 5.8 `LiveCodingModule.cpp`：

- `FLiveCodingModule::Compile`（约 698 行）；
- `AttemptSyncLivePatching`（约 750 行之后）；
- `BeginReload`（约 1525 行）；
- `LiveCodingBeginPatch` / `LiveCodingPreCompile` / `LiveCodingPostCompile`
  （约 1661 行）。

主要顺序是：

```text
Compile()
  -> 拒绝重入
  -> EnableForSession / 确认 Live++ 已启动
  -> UpdateModules(false)
  -> LppTriggerRecompile()
  -> 在 Tick/同步点接收编译与 patch 状态

LiveCodingPreCompile / LiveCodingBeginPatch
  -> BeginReload(EActiveReloadType::LiveCoding)

patch 已装入
  -> ProcessNewlyLoadedUObjects()
  -> Reload::Finalize(false)，按配置 reinstance
  -> ReloadCompleteDelegate
  -> GC 旧 UObject
  -> 第二同步点（若需要）
  -> LiveCodingReload delayed auto-register
  -> OnPatchCompleteDelegate
  -> Reload.Reset() / EndReload()
  -> 报告 Success、NoChanges、Cancelled 或 Failure
```

Knot 也命中了 `FNullReload`：构造时调用
`BeginReload(EActiveReloadType::LiveCoding, *this)`，析构时调用 `EndReload()`。本机
`ModuleManager.cpp:2217-2230` 证明 `BeginReload/EndReload` 只设置全局 active reload 类型和
接口，它本身不是 `FModuleManager::UnloadModule/LoadModule`。

### 6. patch 镜像的物理生命周期

Live++ 负责产生、装入和应用 patch。真实 `r9` 中目标输出是类似
`UnrealEditor-AngelscriptJIT.patch_0.exe` 的 PE 镜像，而基础
`UnrealEditor-AngelscriptJIT.dll` 没有经历普通 UE 模块 Shutdown/Startup。

因此只看 `OwnerModuleName=AngelscriptJIT` 或 `ModuleManager.GetModuleFilename()` 不足以
确定入口函数实际位于哪个镜像；新入口可能在 patch PE 中。`FPlatformStackWalk` 的模块
签名列表也不保证包含所有 Live++ patch 镜像。Windows loader 的
`GetModuleHandleEx(FROM_ADDRESS)` 才是当前入口地址到已加载 PE 镜像的权威查询。

## 对 StaticJIT 方案的落点

| 责任 | 正确位置 | 原因 |
|---|---|---|
| 编译当前 AS、生成 owned C++、判断源文件集合、请求/等待 Live Coding、验证 expected generation | `AngelscriptEditor/StaticJIT/AngelscriptJITRefreshService.*` | 只在 Editor 存在，直接依赖 `ILiveCodingModule`；Runtime 和 Shipping 不应依赖 Live Coding |
| 严格一个 AS 模块/目标 Profile 一个 `.jit.cpp`，以及 Provider selector/accessor | 生成器与项目/TestJIT carrier | 它们只描述代码和不可变身份，不承担全局装卸策略 |
| ProviderId/generation 校验、对象 owner 交接、Catalog 复制与退休 | `AngelscriptRuntime/StaticJIT/AngelscriptJITProviderRegistry.*` | Provider C++ 地址会被 Live Coding 改变；稳定身份与并发退休是所有宿主共有的 Runtime 规则 |
| 按入口地址固定基础 DLL 或 patch PE；旧 Binding/快照最后释放时再释放 lease | `FAngelscriptJITProviderLifetime`，由 Registry Catalog 持有 | lease 必须由不会随生成代码一起被替换的 Runtime 代码创建和销毁，并与实际读者生命周期绑定 |
| 内容不匹配先回 VM，新 Provider 发布后再恢复 Native | Engine-local Router/Binding publication | AS 当前编译代始终是权威；patch/注册失败不得继续执行旧 Native |
| 普通模块 Startup/Shutdown、DLL 主 handle | UE `FModuleManager` | 插件不复制或绕过 Engine 的模块管理 |

### 为什么 owner 交接不放在 Editor refresh

Editor refresh 知道“这次请求期望哪个 generation”，但它不是 Registry 并发与冲突规则的
唯一入口。Modular Feature 到达、普通动态模块重载和测试 Provider 也会经过 Registry。
如果只在 Editor 里篡改 owner 指针，其他入口会继续出现不同语义。

当前规则是：仅当 `ProviderId + ProviderName + OwnerModuleName` 都相同，才允许新的 C++
owner 地址接管同一稳定 Provider identity；真正不同的 Provider 抢同一个 ProviderId 仍返回
`ProviderIdConflict`。旧 owner 后续退注册不会删除已经交给新 owner 的 Catalog。

### 为什么代码镜像 lease 不放在生成 Provider/DLL

把卸载策略写进生成 DLL 有两个问题：

1. 负责释放的析构代码本身可能位于正要释放的镜像；
2. 生成代码不知道哪些 Registry snapshot、Binding 或正在执行的线程仍持有旧入口。

Runtime Catalog 的共享 lease 能表达正确顺序：

```text
新 Snapshot 不再选择旧 Provider
  -> 新 Binding 发布
  -> 旧 Snapshot/Binding/执行 lease 逐步释放
  -> 最后一个 Runtime lease 析构
  -> 释放该具体基础 DLL/patch PE 的额外 loader reference
```

## 当前实现与验证结论

- Editor refresh 没有调用目标模块 `UnloadModule/LoadModule`；
- Windows lifetime acquisition 已改为按每个 VM/Raw/Parms 入口地址查询并固定真实 PE；
- 相同稳定 Provider identity 支持 Live Coding owner handoff，真实冲突仍拒绝；
- `r9` 在同一个 Editor 中完成 `Vm/ContentMismatch -> Native/Exact`，Registry publication
  `2 -> 3`，新 entry 引用 `7/7`，严格 Inspector exit `0`；
- AS 源码、生成 C++、DLL 和 manifest 已恢复正常基线并 Verify。

详细 RED/GREEN 和真实进程路径见 `real-editor-livecoding-smoke.md`。本文是实现边界和 UE
机制研究附件；规范性行为仍由 `design.md`、capability specs 和 `tasks.md` 定义。
