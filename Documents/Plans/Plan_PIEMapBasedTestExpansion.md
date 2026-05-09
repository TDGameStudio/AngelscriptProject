# 项目侧 PIE 地图测试扩展计划

> **范围**：梳理当前项目对"打开地图 → PIE → 校验"测试模式的实现现状，参考 UnLua TestSuite 与 UE 引擎自带的 `FPlayMapInPIEBase` 模式，给出**项目侧**（`Source/AngelscriptProjectTest/`）应补充的地图驱动测试用例与配套地图资源；同时纠正"插件中实装具体地图测试"的位置错误（**插件应只提供框架**，**项目侧**承载具体地图与业务测试）。

---

## 1. 现状盘点

### 1.1 已有地图资源

| 路径 | 用途 | 当前覆盖度 |
|------|------|-----------|
| `Content/Test/ActorTestMap.umap` | 容纳 `BP_AExampleActorType` 实例的最小测试关卡 | 仅 1 个测试在用 |
| `Content/Test/BP_AExampleActorType.uasset` | 继承自 AS 类 `AExampleActorType` 的蓝图 | 验证 BP 子类继承 AS 类的 BeginPlay 流程 |

### 1.2 当前打开地图的测试

| 测试 | 路径 | 模式 |
|------|------|------|
| `FBlueprintSubclassBeginPlayDiagnosticTest`（`AngelscriptProject.Diagnostic.BlueprintSubclass.BeginPlayFromMap`） | `Source/AngelscriptProjectTest/Tests/BlueprintSubclassBeginPlayDiagnosticTest.cpp` | `FEditorLoadMap` → `FStartPIECommand(false)` → 在 PIE world 中遍历 actor → `FEndPlayMapCommand` |

**结论**：项目侧只有 **1 个**真实使用 `Content/Test/ActorTestMap.umap` 的测试，其他用例仍以"内存编译 AS 字符串 + 不打开地图"的纯单元/集成形式存在。

### 1.3 插件侧"地图测试框架"现状（需保留 / 需规范化）

`Plugins/Angelscript/Source/AngelscriptRuntime/Testing/IntegrationTest.cpp` 实装了一套通用框架，由 AS 端通过命名约定 `IntegrationTest_FuncName` 注册，对应自动加载 `{IntegrationTestMapRoot}/FuncName_IntegrationTest.umap`。

| 组件 | 位置 | 性质 |
|------|------|-----|
| 集成测试聚合 `Angelscript.IntegrationTests` (Complex) | 插件 `IntegrationTest.cpp` | **框架，应保留在插件** |
| `FAngelscriptIntegrationTest` C++ 桥 + AS `FIntegrationTest` 绑定 | 同上 | **框架，应保留在插件** |
| Multi-PIE / NetMode 配置（`PlayInSettings->SetPlayNetMode(EPlayNetMode::PIE_Client)`） | 同上 `ConfigureEditorForTest()` | **框架，保留** |
| `ATestTerminator` 复制信号、`ULatentAutomationCommand` 基类 | 插件 `Testing/` 子目录 | **框架，保留** |
| 由 AS 业务侧编写的具体测试函数（`IntegrationTest_*`） | 期望由 `Script/IntegrationTests/` 提供 | **当前空缺**：项目无任何 `.as` 注册 |
| 具体的 `_IntegrationTest.umap` 资源 | 期望落在 `Content/IntegrationTests/` 或 `IntegrationTestMapRoot` 配置目录 | **当前空缺** |

> **要点**：插件中的 IntegrationTest 框架本身不需要搬迁；**真正"放错位置"的部分仅是『项目业务地图 + 业务 .as 测试函数』在当前仓库里完全缺失，且没有指向项目 Content 的配置**。

### 1.4 配置缺口

`UAngelscriptTestSettings::IntegrationTestMapRoot` 在仓库内**未配置**（`Config/` 目录搜索无命中）。这意味着即使将来用 AS 写出 `IntegrationTest_FuncName` 函数，框架也找不到匹配地图。

---

## 2. 与 UnLua TestSuite 与 UE `FPlayMapInPIEBase` 的对照

### 2.1 UnLua（Tencent）的成熟实践要点

| 模式 | 关键代码 | 借鉴价值 |
|------|---------|---------|
| **InstantTest 直接 LoadMap**（不开 PIE） | `UnLuaTestCommon.cpp:80-94`：`LoadPackage` + `GEngine->LoadMap(*WorldContext, ...)` | 比 PIE 启动快 5–10x，适合"加载-检查-销毁"快速场景 |
| **AutomationOpenMap（标准 PIE）** | `UnLuaTestCommon.cpp:93` | 与编辑器交互一致，但启动开销高 |
| **独立 GameInstance** | `UnLuaTestCommon.cpp:65-67`：`NewObject<UGameInstance>(GEngine); InitializeStandalone()` | 完全隔离，可测 GameInstance 子系统生命周期 |
| **按 Issue 分地图回归** | `Plugins/UnLuaTestSuite/Content/Tests/Regression/IssueXXX/` 30+ 个独立地图 | 一旦修复一个 BUG 就建一张地图作为回归样本 |
| **地图切换测试** | `Issue295Test.cpp`：`OpenMap(Map1)` → 操作 → `OpenMap(Map2)` → 操作 | 检查跨地图 GC、UMG 销毁、对象生命周期 |
| **多地图轮询** | `Issue343/Map1+Map2+Map3.umap` | 验证连续切换不泄漏 |
| **`FRequestPlaySessionParams` 自定义启动** | `TestCommands.cpp:104-123`：`SetPlayNumberOfClients(N)` + `bLaunchSeparateServer` | 多客户端配置入口 |

### 2.2 UE 引擎 `FPlayMapInPIEBase`（参考实现）

- 路径：`Engine/Plugins/Tests/EditorTests/Source/EditorTests/Private/UnrealEd/PlayMapInPIETests.cpp`
- 模式：通过 `IAssetRegistry` 枚举 `/Game/` 下所有 `UWorld` 资产，每张地图自动生成一个测试条目
- 配置开关：`UAutomationTestSettings::bUseAllProjectMapsToPlayInPIE`
- 控制台命令：`Automate.OpenMap <MapPath>`
- 通用兜底：`FLoadAllTextureLatentCommand` + `FWaitForShadersToFinishCompiling`

### 2.3 Hazelight ITT/SF（前两轮已分析）

虽然未直接提供"按地图组织的 C++ Automation 测试"模板，但其 `Cake/Vino/Peanuts` 分层与"每张关卡有独立 LevelScript"的思路启示我们：**业务级测试地图应按场景分类**，而非全部塞进单一 `Content/Test/`。

---

## 3. 设计原则（落地约定）

### 3.1 边界

| 层级 | 职责 | 文件位置 |
|------|------|---------|
| **插件侧（保留）** | 提供 `Angelscript.IntegrationTests` 框架、`ATestTerminator`、`ULatentAutomationCommand` 基类、AS 端 `FIntegrationTest` 绑定、PIE/网络模拟设置 | `Plugins/Angelscript/Source/AngelscriptRuntime/Testing/` |
| **项目侧 C++（本计划新增）** | 写 `IMPLEMENT_SIMPLE/COMPLEX_AUTOMATION_TEST` 的"打开地图 → 校验"测试，命名空间统一 `AngelscriptProject.MapTests.*` | `Source/AngelscriptProjectTest/Tests/MapTests/` |
| **项目侧地图资源（本计划新增）** | 关卡资产，按场景目录分组 | `Content/Test/<Scenario>/` |
| **项目侧 AS 业务测试函数（本计划新增）** | `IntegrationTest_FuncName(FIntegrationTest)` | `Script/IntegrationTests/` |

### 3.2 命名规范

| 类型 | Automation 路径 | 地图路径示例 |
|------|----------------|-------------|
| C++ Diagnostic | `AngelscriptProject.Diagnostic.<Theme>.<Case>` | `/Game/Test/Diagnostic/<Theme>Map` |
| C++ MapTest | `AngelscriptProject.MapTests.<Theme>.<Case>` | `/Game/Test/MapTests/<Theme>/<Case>Map` |
| C++ NetMapTest | `AngelscriptProject.NetMapTests.<Theme>.<Case>` | `/Game/Test/NetMapTests/<Theme>/<Case>Map` |
| AS Integration | `Angelscript.IntegrationTests.<Module>.IntegrationTest_<Func>` | `/Game/IntegrationTests/<Func>_IntegrationTest.umap` |

### 3.3 测试模板

每个地图测试**必须**遵循以下骨架（来自 `BlueprintSubclassBeginPlayDiagnosticTest.cpp` 经验）：

```cpp
ADD_LATENT_AUTOMATION_COMMAND(FEditorLoadMap(MapObjectPath));
ADD_LATENT_AUTOMATION_COMMAND(FWaitLatentCommand(1.0f));
ADD_LATENT_AUTOMATION_COMMAND(FStartPIECommand(/*bSimulate=*/false));
ADD_LATENT_AUTOMATION_COMMAND(FWaitLatentCommand(3.0f));
ADD_LATENT_AUTOMATION_COMMAND(FFunctionLatentCommand([this]() -> bool {
    // —— 校验段：拿 PIE world、迭代 actor、断言 ——
    return true;
}));
ADD_LATENT_AUTOMATION_COMMAND(FEndPlayMapCommand());
ADD_LATENT_AUTOMATION_COMMAND(FWaitLatentCommand(1.0f));
```

并在校验段：
1. 通过 `GEditor->GetPIEWorldContext()` 优先拿 PIE world，回退到遍历 `GEngine->GetWorldContexts()`
2. 失败时使用 `AddError`/`AddWarning`/`AddInfo`，配合 RegEx 化错误消息
3. 关键 actor / class / property 缺失时 graceful 退出（`return true`），让框架记录错误而非 hang

---

## 4. 待补充的项目侧地图测试（按主题）

下述每一项 = **新地图资源 + 新 C++ Automation 测试**。地图复杂度尽量保持最小（< 10 actor），仅放置触发该主题所需的对象。

### 4.1 [P0] AS 类继承链 / Blueprint 子类行为

| # | 测试 | 地图 | 验证点 |
|---|------|------|--------|
| 1 | `MapTests.Inheritance.ASClassDirectlyPlaced` | `Content/Test/MapTests/Inheritance/ASClassDirectMap.umap` | AS 类 `AExampleActorType` 直接放入关卡（不经 BP）→ BeginPlay 触发，default 字段值正确 |
| 2 | `MapTests.Inheritance.BlueprintEmptyOverridesScript` | `Content/Test/MapTests/Inheritance/BPEmptyOverrideMap.umap` | BP 子类有空 ReceiveBeginPlay → 复现"BP 空覆盖"陷阱，断言 warning 出现 |
| 3 | `MapTests.Inheritance.BlueprintCallsSuperBeginPlay` | `Content/Test/MapTests/Inheritance/BPCallSuperMap.umap` | BP 子类 ReceiveBeginPlay 显式 Super → 父类 AS BeginPlay 也执行 |
| 4 | `MapTests.Inheritance.MultiLevelBPInheritance` | `Content/Test/MapTests/Inheritance/MultiLevelBPMap.umap` | AS → BP1 → BP2 三层继承，BeginPlay/构造顺序断言 |

### 4.2 [P0] DefaultComponent / 组件层级

| # | 测试 | 地图 | 验证点 |
|---|------|------|--------|
| 5 | `MapTests.Components.SpawnedAtRuntime` | `Content/Test/MapTests/Components/SpawnedRuntimeMap.umap` | 关卡内 SpawnActor AS 类 → DefaultComponent 全部按声明创建，Attach 链完整 |
| 6 | `MapTests.Components.PlacedInLevel` | `Content/Test/MapTests/Components/PlacedInLevelMap.umap` | AS 类直接放置 → 编辑器序列化的 component 树与 default 块声明一致 |
| 7 | `MapTests.Components.BPOverridesDefault` | `Content/Test/MapTests/Components/BPOverrideDefaultMap.umap` | BP 子类调整 default 组件属性（如 SphereRadius） → PIE 实例采用 BP 值 |

### 4.3 [P0] 网络复制（标准 UE Replication，非 Hazelight Crumb）

> 需 PIE 多客户端：通过 C++ 测试动态修改 `ULevelEditorPlaySettings::SetPlayNumberOfClients(2)` + `SetPlayNetMode(PIE_ListenServer)`。框架已有逻辑见 `IntegrationTest.cpp:312-314`。

| # | 测试 | 地图 | 验证点 |
|---|------|------|--------|
| 8 | `NetMapTests.Replication.PropertyReplicates` | `Content/Test/NetMapTests/PropertyRepMap.umap` | 服务端 spawn `AExampleReplicatedActor`，改 `Score` → 客户端读到同值 |
| 9 | `NetMapTests.Replication.RepNotifyTriggersOnClient` | `Content/Test/NetMapTests/RepNotifyMap.umap` | 服务端改 `Health` → 客户端 `OnRep_Health` 被调用 |
| 10 | `NetMapTests.RPC.ServerRPCFromClient` | `Content/Test/NetMapTests/ServerRPCMap.umap` | 客户端调 `ServerRequestAttack` → 服务端 `DamageDealt += 10` |
| 11 | `NetMapTests.RPC.ClientRPCFromServer` | 同上复用 | 服务端调 `ClientConfirmHit` → 仅 owning client 收到 |
| 12 | `NetMapTests.RPC.MulticastReachesAll` | 同上复用 | 服务端 `MulticastPlayHitEffect` → 服务端 + 所有客户端均收到 |
| 13 | `NetMapTests.RPC.WithValidationRejectsInvalid` | 同上复用 | 客户端用非法 ItemId 调 `ServerValidatedUseItem` → 连接被踢/RPC 不执行 |

> 复用 `Script/Examples/Extended/Example_NetworkReplication.as` 中的 `AExampleReplicatedActor` / `AExampleRPCActor`，地图直接放置即可。

### 4.4 [P1] 子系统 / GameInstance 生命周期

| # | 测试 | 地图 | 验证点 |
|---|------|------|--------|
| 14 | `MapTests.Subsystem.WorldSubsystemInitOrder` | `Content/Test/MapTests/Subsystem/WorldSubsystemMap.umap` | PIE 启动 → AS 实现的 `UScriptWorldSubsystem` 子类 `Initialize` 调用顺序与 BeginPlay 关系断言 |
| 15 | `MapTests.Subsystem.GameInstanceSubsystemPersistsAcrossMap` | 两张地图 `GIMapA.umap` + `GIMapB.umap` | A 加载 → 写 GI 子系统状态 → 切到 B → 状态保留 |
| 16 | `MapTests.Subsystem.WorldSubsystemDestroyOnMapEnd` | `Content/Test/MapTests/Subsystem/WorldSubsystemMap.umap` | 结束 PIE → `Deinitialize` 触发，无内存泄漏 |

> 复用 `Script/Examples/Extended/Example_SubsystemLifecycle.as`。

### 4.5 [P1] HotReload 在 PIE 中的影响

| # | 测试 | 地图 | 验证点 |
|---|------|------|--------|
| 17 | `MapTests.HotReload.ScriptChangeReinstancesPlacedActors` | `Content/Test/MapTests/HotReload/PlacedActorMap.umap` | PIE 中触发 AS 文件改动 → 已放置的 actor 自动 reinstance，新字段值生效 |
| 18 | `MapTests.HotReload.SpawnedActorPreservesIdentity` | 同上 | reload 前 spawn 的 actor，reload 后仍可访问且引用一致 |

### 4.6 [P1] 地图切换 / 多地图回归（借鉴 UnLua Issue295/Issue343）

| # | 测试 | 地图 | 验证点 |
|---|------|------|--------|
| 19 | `MapTests.MapTransition.UMGSurvivesMapSwitch` | `MapA.umap` + `MapB.umap` | A 创建 UMG → 切到 B → 不崩溃；脱离 World 的 widget 正确 GC |
| 20 | `MapTests.MapTransition.SeamlessTravelGameInstanceState` | 同上 | 通过 `ServerTravel` 切图，GI 子系统 / PlayerState 状态保留 |
| 21 | `MapTests.MapTransition.RepeatedSwitchNoLeak` | A → B → A → B 循环 4 次 | 每次切换后 actor 数量稳定，无 AS class 重复注册 |

### 4.7 [P2] 增强输入 / 玩家控制（在 PIE 真实 PlayerController 下）

| # | 测试 | 地图 | 验证点 |
|---|------|------|--------|
| 22 | `MapTests.Input.EnhancedInputTriggersASCallback` | `Content/Test/MapTests/Input/EIMap.umap` | 模拟按键注入 → AS Pawn 收到 InputAction 回调 |
| 23 | `MapTests.Input.PlayerControllerScriptOverrides` | 同上 | AS 派生的 PlayerController 类被 PIE 实例化，BeginPlay 正确 |

### 4.8 [P2] UMG 在 PIE 视口中的真实渲染

| # | 测试 | 地图 | 验证点 |
|---|------|------|--------|
| 24 | `MapTests.UMG.AddToViewportFromBeginPlay` | `Content/Test/MapTests/UMG/AddToViewportMap.umap` | AS 类在 BeginPlay 中 `WidgetClass.AddToViewport()` → `GameViewport->GetActiveTopLevelWidgets()` 含该 widget |
| 25 | `MapTests.UMG.RemoveFromParentOnEndPlay` | 同上 | EndPlay → widget 自动 RemoveFromParent，无悬挂引用 |

### 4.9 [P2] Overlap / 碰撞事件

| # | 测试 | 地图 | 验证点 |
|---|------|------|--------|
| 26 | `MapTests.Overlap.ActorBeginEndOverlap` | `Content/Test/MapTests/Overlap/OverlapMap.umap` | 两 actor 预放置 + tick 触发位移 → `ActorBeginOverlap` / `ActorEndOverlap` 各调用一次 |
| 27 | `MapTests.Overlap.ComponentOverlapEvents` | 同上 | `OnComponentBeginOverlap` 多播事件正确触发 |

### 4.10 [P3] 全项目地图烟雾测试（仿 `FPlayMapInPIEBase`）

| # | 测试 | 地图 | 验证点 |
|---|------|------|--------|
| 28 | `MapTests.Smoke.AllProjectMapsLoadInPIE` (Complex) | 枚举 `/Game/` 下所有 `.umap` | 每张地图 PIE 启动 5s 不崩溃、无 Error 级日志、AS 模块正常加载 |

> 实现：参考 `FPlayMapInPIEBase` 通过 `IAssetRegistry` 枚举 + `GetTests()` 输出测试列表；可加 ini 开关 `bRunAngelscriptSmokeOnAllMaps`。

---

## 5. AS 端 IntegrationTest 业务测试（迁移 / 新增）

> 利用插件已有的 `IntegrationTest_FuncName` 框架，把"AS 内部断言"放进真实 PIE 世界。

### 5.1 启用前提（一次性配置）

1. **DefaultEngine.ini 或专用 DefaultAngelscriptTest.ini** 增加：
   ```ini
   [/Script/AngelscriptRuntime.AngelscriptTestSettings]
   IntegrationTestMapRoot=/Game/IntegrationTests/
   IntegrationTestNamingConvention=*IntegrationTests*
   ```
2. 创建 `Script/IntegrationTests/` 模块目录（命名匹配 wildcard）
3. 创建 `Content/IntegrationTests/` 资源目录

### 5.2 推荐 AS 业务测试（每个对应一张 `_IntegrationTest.umap`）

| # | AS 函数 | 地图 | 验证点 |
|---|---------|------|--------|
| 29 | `IntegrationTest_BasicSpawn(FIntegrationTest& T)` | `BasicSpawn_IntegrationTest.umap` | T.Assert spawn 后 actor 不为空 |
| 30 | `IntegrationTest_TimerFiresInPIE(FIntegrationTest& T)` | `TimerFires_IntegrationTest.umap` | 用 `T.AddLatentAutomationCommand` 等待 3s，断言 timer 计数 |
| 31 | `IntegrationTest_OverlapBetweenPlacedActors(FIntegrationTest& T)` | `Overlap_IntegrationTest.umap` | 两个预放置 actor 通过 tick 推动，断言 OnOverlap 触发 |
| 32 | `IntegrationTest_DelegateBroadcastInPIE(FIntegrationTest& T)` | `Delegate_IntegrationTest.umap` | 关卡内事件总线 actor 广播 → 多个监听器收到 |
| 33 | `ComplexIntegrationTest_AllCharacterPawns(FIntegrationTest& T)` + `ComplexIntegrationTest_AllCharacterPawnsGetTests()` | `CharacterPawns_IntegrationTest.umap` | Complex 测试遍历每种 AS Pawn 派生类，分别 spawn + 断言 |

### 5.3 网络型 IntegrationTest（多 PIE 客户端）

> 框架已支持：`Bind_AngelscriptIntegrationTesting` 中 `LatentCommand.RunsOnClient()` 的客户端执行器路径。

| # | AS 函数 | 验证点 |
|---|---------|--------|
| 34 | `IntegrationTest_PropertyRepInPIE(FIntegrationTest& T)` | server-spawn → client 端通过 `RunsOnClient` 命令断言 |
| 35 | `IntegrationTest_ServerRPCAccepted(FIntegrationTest& T)` | client 调用 server RPC → server 侧 `T.Assert` 状态变化 |

---

## 6. 配套基础设施补强

### 6.1 框架补充（插件侧最小改动，可选）

1. **暴露 PIE 配置 helper**（避免每个测试重复写 `GEditor->GetPIEWorldContext()`）：在 `Plugins/Angelscript/Source/AngelscriptRuntime/Testing/` 新增 `AngelscriptPIETestHelpers.h/.cpp`：
   ```cpp
   namespace AngelscriptPIETestHelpers
   {
       UWorld* GetPIEWorldOrFallback();
       template <typename T> T* FindFirstActorInPIE(UClass* Filter = nullptr);
       FAutomationTestBase* CurrentTest();
       void ConfigureForMultiClient(int32 NumClients, EPlayNetMode NetMode);
       void RestorePlaySettings();
   }
   ```

2. **导出 `FStartMultiClientPIECommand`** 简化 step：内部封装 `RequestPlaySession` + 等待 N 个 PIE world ready。

### 6.2 项目侧脚手架

```
Source/AngelscriptProjectTest/
├── AngelscriptProjectTest.Build.cs       (新增 EditorTests 依赖以使用 FPlayMapInPIEBase 工具)
├── Tests/
│   ├── BlueprintSubclassBeginPlayDiagnosticTest.cpp   (现有)
│   ├── MapTests/
│   │   ├── Inheritance/
│   │   │   ├── ASClassDirectlyPlacedTest.cpp
│   │   │   ├── BlueprintEmptyOverridesScriptTest.cpp
│   │   │   └── ... (4.1 全部)
│   │   ├── Components/
│   │   ├── Subsystem/
│   │   ├── HotReload/
│   │   ├── MapTransition/
│   │   ├── Input/
│   │   ├── UMG/
│   │   ├── Overlap/
│   │   └── Smoke/
│   │       └── AllProjectMapsSmokeTest.cpp     (Complex, 仿 FPlayMapInPIEBase)
│   └── NetMapTests/
│       └── Replication/
│           ├── PropertyRepMapTest.cpp
│           ├── RepNotifyMapTest.cpp
│           └── RPCMapTest.cpp
```

```
Content/Test/
├── ActorTestMap.umap                     (现有，保留)
├── BP_AExampleActorType.uasset           (现有，保留)
├── MapTests/
│   ├── Inheritance/   *.umap
│   ├── Components/    *.umap
│   ├── Subsystem/     *.umap + GIMapA / GIMapB
│   ├── HotReload/     *.umap
│   ├── MapTransition/ MapA / MapB
│   ├── Input/         *.umap
│   ├── UMG/           *.umap
│   └── Overlap/       *.umap
└── NetMapTests/
    ├── PropertyRepMap.umap
    ├── RepNotifyMap.umap
    └── ServerRPCMap.umap
```

```
Script/IntegrationTests/                  (新建)
├── BasicSpawnIntegrationTests.as
├── TimerIntegrationTests.as
├── OverlapIntegrationTests.as
├── DelegateIntegrationTests.as
├── CharacterPawnsIntegrationTests.as
└── Network/
    ├── PropertyRepIntegrationTests.as
    └── ServerRPCIntegrationTests.as
```

```
Content/IntegrationTests/                 (新建，配 IntegrationTestMapRoot)
├── BasicSpawn_IntegrationTest.umap
├── TimerFires_IntegrationTest.umap
├── Overlap_IntegrationTest.umap
├── Delegate_IntegrationTest.umap
└── CharacterPawns_IntegrationTest.umap
```

---

## 7. 执行优先级与产出预期

| P | 主题 | 测试数 | 新增地图 | 估计工时 |
|---|------|-------|---------|---------|
| **P0** | 4.1 继承链 | 4 | 4 | 2d（含地图制作） |
| **P0** | 4.2 DefaultComponent | 3 | 3 | 1.5d |
| **P0** | 4.3 网络复制 | 6 | 3（共享） | 3d |
| **P1** | 4.4 Subsystem 生命周期 | 3 | 3 | 1.5d |
| **P1** | 4.5 HotReload PIE 联动 | 2 | 1 | 2d（reload 触发链复杂） |
| **P1** | 4.6 地图切换 | 3 | 4 | 2d |
| **P2** | 4.7 输入 | 2 | 1 | 1d |
| **P2** | 4.8 UMG 视口 | 2 | 1 | 1d |
| **P2** | 4.9 Overlap | 2 | 1 | 0.5d |
| **P3** | 4.10 全项目烟雾 | 1 (Complex) | 0 | 1d |
| — | §5 AS IntegrationTest | 7 | 7 | 3d（含配置 + 框架联调） |
| — | §6.1 框架 helper | — | — | 0.5d |

**合计：约 35 个测试 + 25+ 张地图 + 7 个 AS 业务函数；估计 19 人日**。

---

## 8. 验收标准

1. **Headless 命令行可执行**：所有新测试在 `Tools\RunTests.ps1 -TestPrefix "AngelscriptProject.MapTests."` 与 `-TestPrefix "AngelscriptProject.NetMapTests."` 下全部通过
2. **PIE Cleanup**：每个测试结束后 `GetTestWorld()` 返回 nullptr，无 PIE world 泄漏
3. **AS IntegrationTest**：`Tools\RunTests.ps1 -TestPrefix "Angelscript.IntegrationTests."` 至少 7 个用例上跑通，地图加载 ≤ 5s
4. **多客户端**：网络型测试在 `PIE_Client` 模式下 server + 1 client 都能完成断言
5. **报告产出**：`Tools\GetAutomationReportSummary.ps1` 在 CI 中能列出所有 MapTests 主题
6. **文档同步**：本计划纳入 `Documents/Plans/Plan_StatusPriorityRoadmap.md` 的 P1 段落

---

## 9. 风险与注意事项

| 风险 | 缓解 |
|------|-----|
| PIE 启动慢导致 CI 时长爆炸 | (1) 提供 `bSkipPIEHeavyTests` 命令行开关；(2) 优先用 UnLua 的 InstantTest 模式（直接 `LoadMap` 不开 PIE）做能跑就行的烟雾；(3) PIE 测试单独打包到 `pie-suite` 标签，与 `unit-suite` 分流水线 |
| Headless 模式下网络模拟超时 | 框架已 disable `bIsNetworkEmulationEnabled`（`IntegrationTest.cpp:323`），新增 NetMapTests 必须显式设 `bEnableNetworkEmulation = false` |
| 地图被 BP 编译错误污染 | 地图 commit 前必须执行 `Tools\RunBuild.ps1`；CI 加 `BPCompileCheck` step |
| `IntegrationTestMapRoot` 配置写错导致框架找不到地图 | 在 `AngelscriptProjectTest` 模块的 `StartupModule()` 中加运行时校验（路径存在 + 至少一张匹配地图），失败 ensure |
| BP 子类 ReceiveBeginPlay 空覆盖（已知陷阱） | 4.1 #2 用例正是为此而设；编写时确认其他用例不踩坑 |
| 多客户端 PIE 在 windowed mode 下窗口堆叠 | `IntegrationTest.cpp:303-305` 已强制 CenterNewWindow + width/height = 0；新测试沿用 |

---

## 10. 与已有 Plan 的关系

| 关联 Plan | 关系 |
|----------|------|
| `Plan_NetworkReplicationTests.md` | §4.3 / §5.3 是其在"PIE 真实多客户端"场景的落地补充 |
| `Plan_ReferenceBasedTestExpansion.md`（第一轮 28 主题） | 第一轮主要是"内存编译 AS 字符串"测试，本计划覆盖"真实地图 PIE"维度，互补 |
| `Plan_ReferenceBasedTestExpansion_Round2.md`（15 主题） | 同上 |
| `Plan_HazelightCapabilityGap.md` | 不相关（Capability 系统未引入） |
| `Plan_DisabledTestReenablement.md` | §4.10 全项目烟雾测试可发现额外被 Disabled 的地图相关测试 |

---

## 附录 A：测试参考代码片段

### A.1 多客户端 PIE 启动（在 C++ Automation 中）

```cpp
// 在 RunTest 开头：
ULevelEditorPlaySettings* PlaySettings = GetMutableDefault<ULevelEditorPlaySettings>();
EPlayNetMode OldMode;
PlaySettings->GetPlayNetMode(OldMode);
int32 OldClients = PlaySettings->GetPlayNumberOfClients();

PlaySettings->SetPlayNetMode(EPlayNetMode::PIE_ListenServer);
PlaySettings->SetPlayNumberOfClients(2);
PlaySettings->bLaunchSeparateServer = false;

// 在测试结束的 LatentCommand 内恢复：
ADD_LATENT_AUTOMATION_COMMAND(FFunctionLatentCommand([OldMode, OldClients]() -> bool {
    auto* P = GetMutableDefault<ULevelEditorPlaySettings>();
    P->SetPlayNetMode(OldMode);
    P->SetPlayNumberOfClients(OldClients);
    return true;
}));
```

### A.2 跨地图迭代（Issue295 模式）

```cpp
ADD_LATENT_AUTOMATION_COMMAND(FEditorLoadMap(MapA));
ADD_LATENT_AUTOMATION_COMMAND(FStartPIECommand(false));
ADD_LATENT_AUTOMATION_COMMAND(FWaitLatentCommand(2.0f));
ADD_LATENT_AUTOMATION_COMMAND(FFunctionLatentCommand(/* 在 A 中操作 */));
ADD_LATENT_AUTOMATION_COMMAND(FEndPlayMapCommand());
ADD_LATENT_AUTOMATION_COMMAND(FWaitLatentCommand(1.0f));

ADD_LATENT_AUTOMATION_COMMAND(FEditorLoadMap(MapB));
ADD_LATENT_AUTOMATION_COMMAND(FStartPIECommand(false));
ADD_LATENT_AUTOMATION_COMMAND(FWaitLatentCommand(2.0f));
ADD_LATENT_AUTOMATION_COMMAND(FFunctionLatentCommand(/* 在 B 中校验 */));
ADD_LATENT_AUTOMATION_COMMAND(FEndPlayMapCommand());
```

### A.3 InstantTest 模式（不开 PIE，仅 LoadMap）

借鉴 UnLua `UnLuaTestCommon.cpp:80-94`，适合"加载就检查"的快速场景：

```cpp
const auto OldWorld = GWorld;
const FURL URL(*MapName);
FString Error;
LoadPackage(nullptr, *URL.Map, LOAD_None);
FTaskGraphInterface::Get().ProcessThreadUntilIdle(ENamedThreads::GameThread);
GEngine->LoadMap(*WorldContext, URL, nullptr, Error);
GWorld = OldWorld;
// 现在 WorldContext->World() 即新地图 Game world，可直接遍历断言
```

---

# 附录 B：PIE 测试变体扩展矩阵（举一反三）

> **目的**：把 §4 / §5 的 35 个"主干"用例按 **6 大 PIE 专属变体轴**横向铺开，从单点验证扩展到完整网格。
>
> **6 大变体轴**（针对 PIE 场景定制，与 Round2 的语法变体不同）：
> 1. **正例（Positive）** —— 主干流程跑通
> 2. **网络拓扑（NetTopology）** —— Standalone / ListenServer / DedicatedServer / 1+1 / 1+2 / 1+4 客户端
> 3. **清理与泄漏（Cleanup）** —— EndPIE 后无 actor 残留、无 world 泄漏、无 GC 引用悬挂
> 4. **时序与容错（Timing）** —— 加载/启动/RPC 时序的容错与超时
> 5. **错误恢复（Recovery）** —— 地图加载失败、BP 编译错误、AS reload 失败、连接丢失场景
> 6. **跨场景交互（CrossInteraction）** —— PIE × HotReload × 地图切换 × 子系统 × GC 的组合

> **不要求**每主题在每轴都铺；下表 `★` 必补 / `☆` 可选。

## B.0 变体覆盖矩阵总览

| # | 主题 | 主干 | 正例追加 | 网络拓扑 | 清理 | 时序 | 错误恢复 | 跨场景 | 主题小计 |
|---|------|-----|---------|---------|------|------|---------|--------|---------|
| 4.1 | 继承链 / BP 子类 | 4 | ★3 | — | ★2 | ★1 | ★2 | ★3 | **15** |
| 4.2 | DefaultComponent | 3 | ★3 | ☆1 | ★2 | — | ★1 | ★3 | **13** |
| 4.3 | 网络复制 | 6 | ★3 | ★4 | ★2 | ★3 | ★2 | ★2 | **22** |
| 4.4 | Subsystem 生命周期 | 3 | ★2 | ★2 | ★3 | ★1 | ★1 | ★3 | **15** |
| 4.5 | HotReload PIE | 2 | ★2 | ☆1 | ★2 | ★2 | ★3 | ★3 | **15** |
| 4.6 | 地图切换 | 3 | ★3 | ★2 | ★3 | ★2 | ★2 | ★2 | **17** |
| 4.7 | 增强输入 | 2 | ★2 | ★1 | ★1 | ★1 | ★1 | ★2 | **10** |
| 4.8 | UMG 视口 | 2 | ★2 | ☆1 | ★3 | ★1 | ★1 | ★2 | **12** |
| 4.9 | Overlap | 2 | ★2 | ★1 | ★1 | ★2 | ★1 | ★2 | **11** |
| 4.10 | 全项目烟雾 | 1 | ★2 | ★1 | ★2 | ★2 | ★2 | — | **10** |
| 5.2 | AS 业务 IntegrationTest | 5 | ★3 | ★2 | ★2 | ★2 | ★2 | ★2 | **18** |
| 5.3 | 网络型 IntegrationTest | 2 | ★2 | ★4 | ★2 | ★2 | ★2 | ★1 | **15** |
| **总计** | — | **35** | **30** | **19** | **25** | **19** | **20** | **25** | **173** |

> **35 → 173**（×4.9 倍）。每条变体都对应 **1 个测试方法**（多数复用现有地图，极少需新增）。

---

## B.1 主题 4.1：继承链 / BP 子类（15 用例）

### 正例追加
| ID | Test | 内容 |
|----|------|------|
| 4.1.5 | `MapTests.Inheritance.ASGrandparentBPParentBPChild` | AS → BP → BP 三层；中间层覆盖 BeginPlay 不调 Super → 顶层不执行 |
| 4.1.6 | `MapTests.Inheritance.ASClassWithBPInterface` | AS 类实现 BP 定义的 Interface → InterfaceCall 命中 AS 实现 |
| 4.1.7 | `MapTests.Inheritance.ChildClassDefaultOverridesParentDefault` | BP 子类 default 字段覆盖 AS 父类 default → CDO 与实例都用 BP 值 |

### 清理
| ID | Test | 内容 |
|----|------|------|
| 4.1.C1 | `MapTests.Inheritance.EndPIE_AllScriptActorsGCed` | EndPIE 后 5 帧内所有 AS actor 进入 PendingKill 且最终被 GC（FReferenceChainSearch 无强引用） |
| 4.1.C2 | `MapTests.Inheritance.PlacedASActor_NoEditorWorldSideEffect` | PIE 修改 AS 实例字段 → EndPIE 后回到 editor world，editor 实例字段未被污染 |

### 时序
| ID | Test | 内容 |
|----|------|------|
| 4.1.T1 | `MapTests.Inheritance.BeginPlayCalledExactlyOnce` | 用计数器验证 BP 子类 + AS 父类 BeginPlay 总执行次数 = 1（不是 2，也不是 0） |

### 错误恢复
| ID | Test | 内容 |
|----|------|------|
| 4.1.R1 | `MapTests.Inheritance.MissingASClass_BPFallsBack` | 移除 AS 父类后 PIE 启动 → BP 子类降级到 AActor 或报错可定位 |
| 4.1.R2 | `MapTests.Inheritance.BPCompileError_DoesNotCrashPIE` | BP 蓝图含编译错误 → PIE 启动给出明确诊断而非崩溃 |

### 跨场景
| ID | Test | 内容 |
|----|------|------|
| 4.1.X1 | `MapTests.Inheritance.HotReloadASParent_BPChildPicksNewMembers` | PIE 中 reload 父 AS 类（新增字段）→ 已放置 BP 子类实例自动重 instance，新字段可访问 |
| 4.1.X2 | `MapTests.Inheritance.MapTransition_InheritanceChainStable` | A → B 切图后 inheritance 链未被破坏（BP 子类仍指向同一 AS 父类） |
| 4.1.X3 | `MapTests.Inheritance.ReplicatedASParentBPChildOnClient` | 服务端 spawn AS-父 + BP-子组合 → 客户端镜像类型正确 |

---

## B.2 主题 4.2：DefaultComponent（13 用例）

### 正例追加
| ID | Test | 内容 |
|----|------|------|
| 4.2.4 | `MapTests.Components.AttachSocketAtSpawn` | 带 `AttachSocket=hand_r` 的子组件，SpawnActor 后 socket 名正确读出 |
| 4.2.5 | `MapTests.Components.OverrideComponentInBP` | BP 用 OverrideComponent 替换 AS 父类某 default 组件类型 → spawn 后是 BP 指定类 |
| 4.2.6 | `MapTests.Components.ShowOnActor_EditorVisibility` | `ShowOnActor` 标记的组件在 actor details 面板可见（编辑器侧） |

### 网络拓扑（可选）
| ID | Test | 内容 |
|----|------|------|
| 4.2.NT1 ☆ | `MapTests.Components.ReplicatedComponentExistsOnClient` | 标 Replicated 的 default component 在 client 上也存在 |

### 清理
| ID | Test | 内容 |
|----|------|------|
| 4.2.C1 | `MapTests.Components.EndPIE_NoComponentLeak` | EndPIE 后所有 default 组件被 destroy，无 PendingKill 残留 |
| 4.2.C2 | `MapTests.Components.RespawnActor_FreshComponents` | destroy + 同一帧 spawn → 新组件实例（地址不同），属性回到 CDO 默认 |

### 错误恢复
| ID | Test | 内容 |
|----|------|------|
| 4.2.R1 | `MapTests.Components.InvalidAttachParent_PIEStartsWithError` | 故意打破 attach 链 → PIE 启动报清晰错误，不卡死 |

### 跨场景
| ID | Test | 内容 |
|----|------|------|
| 4.2.X1 | `MapTests.Components.HotReload_AddNewDefaultComponent` | reload 给 AS 类加新 default 组件 → 已放置 actor 在下一帧获得新组件 |
| 4.2.X2 | `MapTests.Components.MapTransition_PreservedConfig` | 跨地图同类 actor 的组件配置一致 |
| 4.2.X3 | `MapTests.Components.WithBPVisualOnly_TickEnabled` | BP 子类标 default 组件 `bAutoActivate=false` → PIE 中确实未 tick |

---

## B.3 主题 4.3：网络复制（22 用例）

### 正例追加
| ID | Test | 内容 |
|----|------|------|
| 4.3.7 | `NetMapTests.Replication.RepCondition_OwnerOnly` | 设 `COND_OwnerOnly` → 仅 owning client 收到 |
| 4.3.8 | `NetMapTests.Replication.RepArray_TArrayElementSync` | 服务端改 TArray<int> → 客户端整数组 sync（含 push/pop） |
| 4.3.9 | `NetMapTests.Replication.SubobjectReplication` | 标 `bReplicateUsingRegisteredSubObjectList` 的子对象同步 |

### 网络拓扑
| ID | Test | 内容 |
|----|------|------|
| 4.3.NT1 | `NetMapTests.Replication.ListenServer_2Clients` | listen server + 2 client → 改 Score → 两 client 都收到 |
| 4.3.NT2 | `NetMapTests.Replication.DedicatedServer_2Clients` | `bLaunchSeparateServer=true` → 同上行为 |
| 4.3.NT3 | `NetMapTests.Replication.LateJoiningClient_GetsCurrentState` | 第 2 client 后接入 → 立即收到当前 Score 值 |
| 4.3.NT4 | `NetMapTests.Replication.ClientDisconnect_ServerCleansUp` | 1 client 断开 → server 端 PlayerController 清理；其他 client 不受影响 |

### 清理
| ID | Test | 内容 |
|----|------|------|
| 4.3.C1 | `NetMapTests.Replication.EndPIE_AllConnectionsClosed` | EndPIE 后 NetDriver 断开，无 socket 泄漏 |
| 4.3.C2 | `NetMapTests.Replication.ServerActorDestroyed_RemovedOnClient` | server 调 Destroy → client 1 帧后 actor 消失 |

### 时序
| ID | Test | 内容 |
|----|------|------|
| 4.3.T1 | `NetMapTests.Replication.RepNotifyTimingWithinNFrames` | server 改值 → client OnRep_X 在 ≤ N 帧内触发（N 由 net update freq 决定） |
| 4.3.T2 | `NetMapTests.Replication.RPCArrivesInOrder_ReliableQueue` | server 连发 5 个 reliable RPC → client 顺序接收 |
| 4.3.T3 | `NetMapTests.Replication.UnreliableMaybeDropped_Tolerant` | unreliable RPC 100 次 → client 收到 ≥ X%（不强求全收到） |

### 错误恢复
| ID | Test | 内容 |
|----|------|------|
| 4.3.R1 | `NetMapTests.Replication.RPCWithValidation_InvalidParamKicksClient` | client 调 server RPC 提供非法参数 → server `_Validate` 返回 false → client 被踢且 server log 记录原因 |
| 4.3.R2 | `NetMapTests.Replication.NoBReplicates_RPCFailsCleanly` | actor 未设 `bReplicates` 调 RPC → 静默 noop 或明确警告 |

### 跨场景
| ID | Test | 内容 |
|----|------|------|
| 4.3.X1 | `NetMapTests.Replication.HotReloadDuringPIE_RepStateRebuilt` | reload AS 类 → 已 spawn 的 replicated actor 需保持复制状态有效（或 graceful 降级） |
| 4.3.X2 | `NetMapTests.Replication.SeamlessTravel_PreservesOwnership` | server travel 后 PlayerController.Owner 链路不丢 |

---

## B.4 主题 4.4：Subsystem 生命周期（15 用例）

### 正例追加
| ID | Test | 内容 |
|----|------|------|
| 4.4.4 | `MapTests.Subsystem.MultipleWorldSubsystems_InitOrder` | 多个 AS UScriptWorldSubsystem 子类 → init 按 ShouldCreateSubsystem 顺序 |
| 4.4.5 | `MapTests.Subsystem.LocalPlayerSubsystem_PerLocalPlayer` | 2 local player → 子系统实例 = 2 个 |

### 网络拓扑
| ID | Test | 内容 |
|----|------|------|
| 4.4.NT1 | `MapTests.Subsystem.WorldSubsystemPerPIEWorld` | listen server + 2 client → 4 个 world，4 个 WorldSubsystem 实例 |
| 4.4.NT2 | `MapTests.Subsystem.GameInstanceSubsystemSharedAcrossPIEWindows` | 同进程 PIE 多窗口 → 是否共享 GI subsystem？语义记录 |

### 清理
| ID | Test | 内容 |
|----|------|------|
| 4.4.C1 | `MapTests.Subsystem.Deinitialize_CalledOnEndPIE` | EndPIE 后 Deinitialize 调用次数 = Initialize 次数 |
| 4.4.C2 | `MapTests.Subsystem.NoSubsystemLeak_AfterMultiplePIEs` | 5 次启停 PIE → subsystem 实例总数稳定不增长 |
| 4.4.C3 | `MapTests.Subsystem.SubsystemRefHeldByActor_GCedAfterEndPIE` | actor 持子系统指针 → EndPIE 后子系统能 GC |

### 时序
| ID | Test | 内容 |
|----|------|------|
| 4.4.T1 | `MapTests.Subsystem.InitializeBeforeAnyActorBeginPlay` | Initialize 在所有 actor BeginPlay 之前完成 |

### 错误恢复
| ID | Test | 内容 |
|----|------|------|
| 4.4.R1 | `MapTests.Subsystem.InitializeThrows_PIEStartsWithError` | Initialize 内 throw → PIE 给出诊断，subsystem 标记不可用 |

### 跨场景
| ID | Test | 内容 |
|----|------|------|
| 4.4.X1 | `MapTests.Subsystem.HotReloadSubsystemClass_ReinitInPIE` | reload subsystem 类 → 已存在实例迁移到新类型 |
| 4.4.X2 | `MapTests.Subsystem.MapTransition_GISubsystemStateRetained` | A → B 切图后 GI subsystem 字段值保留 |
| 4.4.X3 | `MapTests.Subsystem.WorldSubsystemRecreatedAcrossMaps` | 切图后 WorldSubsystem 是新实例（旧的已 Deinitialize） |

---

## B.5 主题 4.5：HotReload × PIE（15 用例）

### 正例追加
| ID | Test | 内容 |
|----|------|------|
| 4.5.3 | `MapTests.HotReload.AddNewMethodVisibleAtRuntime` | reload 后通过反射可调用新方法 |
| 4.5.4 | `MapTests.HotReload.RemoveMethodOldRefsCleared` | reload 删除方法 → BP 中悬挂引用安全清理 |

### 清理
| ID | Test | 内容 |
|----|------|------|
| 4.5.C1 | `MapTests.HotReload.OldClassObject_GCedAfterReinstance` | reinstance 后旧 UClass 不再持引用，能 GC |
| 4.5.C2 | `MapTests.HotReload.NoDoubleBeginPlay` | reinstance 期间 BeginPlay 不被重复调用 |

### 时序
| ID | Test | 内容 |
|----|------|------|
| 4.5.T1 | `MapTests.HotReload.ReinstanceWithinNFrames` | 文件改动到 actor reinstance 完成 ≤ N 帧 |
| 4.5.T2 | `MapTests.HotReload.PendingTimer_SurvivesReload` | reload 前设的 timer 在 reload 后仍按时触发 |

### 错误恢复
| ID | Test | 内容 |
|----|------|------|
| 4.5.R1 | `MapTests.HotReload.SyntaxError_KeepsOldVersion` | reload 时遇语法错 → 旧版本继续运行不崩溃 |
| 4.5.R2 | `MapTests.HotReload.IncompatibleFieldChange_DiagnosedNotCrashed` | 改字段类型导致序列化不兼容 → 给出明确 warning，actor 字段重置到 default |
| 4.5.R3 | `MapTests.HotReload.RecoverFromBadReload_NextSaveSucceeds` | 一次 reload 失败后下次成功 reload 能正常生效 |

### 跨场景
| ID | Test | 内容 |
|----|------|------|
| 4.5.X1 | `MapTests.HotReload.WithReplicationInPIE` | reload + multi-client PIE → server/client 同时 reinstance，复制链不断 |
| 4.5.X2 | `MapTests.HotReload.WithMapTransition_ReloadDuringTransition` | 切图过程中 reload → 不冻结，新地图加载后状态一致 |
| 4.5.X3 | `MapTests.HotReload.WithSubsystemReinit` | reload subsystem → 关联 actor 引用自动指向新实例 |

---

## B.6 主题 4.6：地图切换（17 用例）

### 正例追加
| ID | Test | 内容 |
|----|------|------|
| 4.6.4 | `MapTests.MapTransition.ClientTravel_OptionsPassed` | `ClientTravel(URL?Option=v)` → 新关卡读到 option |
| 4.6.5 | `MapTests.MapTransition.OpenLevel_ConsoleCommand` | console `open MapB` → 切换成功 |
| 4.6.6 | `MapTests.MapTransition.NonSeamlessTravel_DefaultBehavior` | `bUseSeamlessTravel=false` → 通过 transition map 中转，actor 全 destroy |

### 网络拓扑
| ID | Test | 内容 |
|----|------|------|
| 4.6.NT1 | `MapTests.MapTransition.ServerTravel_ClientsFollow` | listen server + 2 client → server travel → 两 client 自动跟随 |
| 4.6.NT2 | `MapTests.MapTransition.ClientLagOnTravel_NoCrash` | client 加载 B 慢于 server 5 秒 → 不 timeout 不崩溃 |

### 清理
| ID | Test | 内容 |
|----|------|------|
| 4.6.C1 | `MapTests.MapTransition.OldWorldGCed_AfterTransition` | 切到 B 后 A 的 UWorld 在 N 秒内 GC 掉 |
| 4.6.C2 | `MapTests.MapTransition.PlacedActorRefsCleared` | A 中 actor ref 在 B 中应是 null（非 dangling） |
| 4.6.C3 | `MapTests.MapTransition.UMGRemovedFromViewport` | A 中 AddToViewport 的 widget → 切到 B 后自动 remove |

### 时序
| ID | Test | 内容 |
|----|------|------|
| 4.6.T1 | `MapTests.MapTransition.TransitionLatency_BoundedByTimeout` | 切图整体耗时 ≤ X 秒（CI baseline） |
| 4.6.T2 | `MapTests.MapTransition.PostLoginCalledAfterMapReady` | 切图后 PostLogin 在新地图 BeginPlay 前后顺序定义化 |

### 错误恢复
| ID | Test | 内容 |
|----|------|------|
| 4.6.R1 | `MapTests.MapTransition.NonexistentMap_GracefulFail` | OpenLevel 不存在的地图 → 错误日志 + 留在原地图 |
| 4.6.R2 | `MapTests.MapTransition.TransitionFailureMidway_RecoverToFallback` | 切图中失败 → 回退到 default map 或留在 transition map，不黑屏 |

### 跨场景
| ID | Test | 内容 |
|----|------|------|
| 4.6.X1 | `MapTests.MapTransition.WithSubsystemPersistence` | GI subsystem 状态在切图前后一致 |
| 4.6.X2 | `MapTests.MapTransition.WithHotReload_ReloadBeforeTravel` | reload 后立刻 travel → 新地图用新版 AS 类 |

---

## B.7 主题 4.7：增强输入（10 用例）

### 正例追加
| ID | Test | 内容 |
|----|------|------|
| 4.7.3 | `MapTests.Input.MultipleMappingContexts_StackingOrder` | 同时挂 2 个 InputMappingContext → 优先级按 priority 决定 |
| 4.7.4 | `MapTests.Input.AxisActionWithModifier_ScaledOutput` | axis input 经 Scalar modifier → AS 端读到 scaled 值 |

### 网络拓扑
| ID | Test | 内容 |
|----|------|------|
| 4.7.NT1 | `MapTests.Input.LocalPlayerInputOnly_NoServerSideTrigger` | 客户端按键 → 只有 owning player 的 controller 收到 |

### 清理
| ID | Test | 内容 |
|----|------|------|
| 4.7.C1 | `MapTests.Input.RemoveMappingContextOnEndPlay_NoDanglingBindings` | EndPlay 后 input mapping 清理，下次 PIE 不重复触发 |

### 时序
| ID | Test | 内容 |
|----|------|------|
| 4.7.T1 | `MapTests.Input.PressedReleasedDeltaWithinFrame` | 同帧 pressed + released → AS 端正确处理两个 callback |

### 错误恢复
| ID | Test | 内容 |
|----|------|------|
| 4.7.R1 | `MapTests.Input.MissingInputAction_GracefulNoOp` | 引用了不存在的 InputAction → log warn 不崩溃 |

### 跨场景
| ID | Test | 内容 |
|----|------|------|
| 4.7.X1 | `MapTests.Input.HotReloadASController_KeepsBindings` | reload PlayerController AS 类 → 输入绑定自动恢复 |
| 4.7.X2 | `MapTests.Input.MapTransition_RebindOnNewLevel` | 切图后输入仍生效（重新挂 mapping context） |

---

## B.8 主题 4.8：UMG 视口（12 用例）

### 正例追加
| ID | Test | 内容 |
|----|------|------|
| 4.8.3 | `MapTests.UMG.ZOrderRespected` | 多 widget 同时 AddToViewport，z-order 与 add 顺序一致 |
| 4.8.4 | `MapTests.UMG.NamedSlotInsertion` | NamedSlot widget 内插入子 widget → BeginPlay 后可见 |

### 网络拓扑（可选）
| ID | Test | 内容 |
|----|------|------|
| 4.8.NT1 ☆ | `MapTests.UMG.DedicatedServerSkipsWidget` | 在专用服务器世界 BeginPlay 中 AddToViewport → 静默跳过/明确 warn |

### 清理
| ID | Test | 内容 |
|----|------|------|
| 4.8.C1 | `MapTests.UMG.EndPIE_AllWidgetsRemovedFromViewport` | EndPIE 后 GameViewport 内 widget 数 = 0 |
| 4.8.C2 | `MapTests.UMG.WidgetGCedAfterRemoveFromParent` | RemoveFromParent 后 N 帧 widget 进入 GC |
| 4.8.C3 | `MapTests.UMG.ConstructDestructPair` | Construct 与 Destruct 调用次数严格 1:1 |

### 时序
| ID | Test | 内容 |
|----|------|------|
| 4.8.T1 | `MapTests.UMG.AsyncCreateWidget_AvailableNextFrame` | `Async` AddToViewport → 下一帧可见 |

### 错误恢复
| ID | Test | 内容 |
|----|------|------|
| 4.8.R1 | `MapTests.UMG.NullWidgetClass_NoCrash` | WidgetClass=nullptr 调 AddToViewport → 报 warn 不崩溃 |

### 跨场景
| ID | Test | 内容 |
|----|------|------|
| 4.8.X1 | `MapTests.UMG.SurvivesMapSwitch_RemovedAutomatically` | A 中 widget 切到 B 后自动 remove |
| 4.8.X2 | `MapTests.UMG.HotReloadWidgetClass_NoCrashInPIE` | reload UserWidget 类 → 已 add 的实例安全更新或重建 |

---

## B.9 主题 4.9：Overlap（11 用例）

### 正例追加
| ID | Test | 内容 |
|----|------|------|
| 4.9.3 | `MapTests.Overlap.SweepBeginOverlap_HitNormalProvided` | 通过 SetActorLocation+sweep 触发 → 入参 FHitResult 含 Normal |
| 4.9.4 | `MapTests.Overlap.OverlapWithMultipleComponents` | 单 actor 多组件分别 overlap → 每组件触发各自事件 |

### 网络拓扑
| ID | Test | 内容 |
|----|------|------|
| 4.9.NT1 | `MapTests.Overlap.ServerAuthoritative_ClientReceivesEffect` | server 检测 overlap → 通过 RPC/replicated event 让 client 看到结果 |

### 清理
| ID | Test | 内容 |
|----|------|------|
| 4.9.C1 | `MapTests.Overlap.ActorDestroyedDuringOverlap_EndOverlapStillFires` | overlap 中一方 destroy → 另一方收到 EndOverlap |

### 时序
| ID | Test | 内容 |
|----|------|------|
| 4.9.T1 | `MapTests.Overlap.SimultaneousBeginOverlap_DispatchOrder` | 两 actor 同帧 overlap → BeginOverlap 在 Tick 末尾按确定顺序 |
| 4.9.T2 | `MapTests.Overlap.NoOverlapEventsBeforeBeginPlay` | actor BeginPlay 前不应收 overlap 事件 |

### 错误恢复
| ID | Test | 内容 |
|----|------|------|
| 4.9.R1 | `MapTests.Overlap.OverlappingActorClassChanged_GracefulRebind` | overlap 中的 actor 类型 reinstance → 无重复 BeginOverlap |

### 跨场景
| ID | Test | 内容 |
|----|------|------|
| 4.9.X1 | `MapTests.Overlap.WithReplication_ServerOnlyDecision` | overlap 决策只在 server 跑，client 不重复触发逻辑 |
| 4.9.X2 | `MapTests.Overlap.MapTransition_NoLeakedSubscription` | 切图后 overlap 委托不残留 |

---

## B.10 主题 4.10：全项目地图烟雾（10 用例）

### 正例追加
| ID | Test | 内容 |
|----|------|------|
| 4.10.2 | `MapTests.Smoke.FilterByTag_Smoke` | 仅扫带 tag `auto-smoke` 的地图 |
| 4.10.3 | `MapTests.Smoke.SkipDeveloperFolders` | `/Game/Developers/*` 跳过 |

### 网络拓扑
| ID | Test | 内容 |
|----|------|------|
| 4.10.NT1 | `MapTests.Smoke.AllMapsListenServerLoad` | 全地图在 listen server 下烟雾测试 |

### 清理
| ID | Test | 内容 |
|----|------|------|
| 4.10.C1 | `MapTests.Smoke.NoLeakAfterAllMaps` | 全部跑完后 UWorld 实例数回到 baseline |
| 4.10.C2 | `MapTests.Smoke.ASModuleStableAfterAllMaps` | AngelScript module 数 / 注册类数稳定 |

### 时序
| ID | Test | 内容 |
|----|------|------|
| 4.10.T1 | `MapTests.Smoke.PerMapBudget_5Seconds` | 每张地图 PIE 启动 ≤ 5s（超时跳到下一张并标 fail） |
| 4.10.T2 | `MapTests.Smoke.TotalSuiteBudget_NMinutes` | 套件总耗时 ≤ N 分钟（CI 阈值） |

### 错误恢复
| ID | Test | 内容 |
|----|------|------|
| 4.10.R1 | `MapTests.Smoke.MapWithBPCompileError_RecordedNotCrashed` | 含错误的地图 → 标 fail 后继续下一张，不中断套件 |
| 4.10.R2 | `MapTests.Smoke.ASModuleNotInitialized_SkipWithReason` | AS 未初始化 → 跳过 + log "AS not ready" |

---

## B.11 主题 5.2：AS 业务 IntegrationTest（18 用例）

### 正例追加
| ID | Test | 内容 |
|----|------|------|
| 5.2.6 | `IntegrationTest_NestedSpawn` | spawn 后再 spawn 子对象，断言层级 |
| 5.2.7 | `IntegrationTest_TimerWithLatentCommand` | `T.AddLatentAutomationCommand` + timer 联动 |
| 5.2.8 | `IntegrationTest_AsyncWaitForCondition` | 自定义 latent command 等待条件成立 |

### 网络拓扑
| ID | Test | 内容 |
|----|------|------|
| 5.2.NT1 | `IntegrationTest_StandaloneOnly_RunInStandalone` | netmode 标记仅 standalone 时跑 |
| 5.2.NT2 | `IntegrationTest_DedicatedServerScenario` | 配置专用服务器场景下执行 |

### 清理
| ID | Test | 内容 |
|----|------|------|
| 5.2.C1 | `IntegrationTest_TerminatorDestroyedTriggersCleanup` | TestTerminator destroy → cleanup chain 正确 |
| 5.2.C2 | `IntegrationTest_LatentCommandsAllForgotten` | 测试结束后 ULatentAutomationCommand 全部脱离 root |

### 时序
| ID | Test | 内容 |
|----|------|------|
| 5.2.T1 | `IntegrationTest_LatentCommandTimeoutHonored` | 单 latent command 超过 15s → 报错而非 hang |
| 5.2.T2 | `IntegrationTest_FpsCounterReportable` | 测试期间 fps 报告含在日志 |

### 错误恢复
| ID | Test | 内容 |
|----|------|------|
| 5.2.R1 | `IntegrationTest_AssertFails_StopsRemainingCommands` | T.Assert 失败后后续 latent command 跳过 |
| 5.2.R2 | `IntegrationTest_ExpectedErrorMatched_CountsAsPass` | T.AddExpectedError 与运行时实际 error 匹配 → 不计 fail |

### 跨场景
| ID | Test | 内容 |
|----|------|------|
| 5.2.X1 | `IntegrationTest_RunAfterHotReload_StillWorks` | reload 后再跑 IntegrationTest 不需重启编辑器 |
| 5.2.X2 | `IntegrationTest_EditorMapRestoredAfterSuite` | 跑完一组 IntegrationTest 后 editor 自动回到原 map（PushEditorMap/PopEditorMap） |

---

## B.12 主题 5.3：网络型 IntegrationTest（15 用例）

### 正例追加
| ID | Test | 内容 |
|----|------|------|
| 5.3.3 | `IntegrationTest_RunsOnClient_StateMachineCovered` | EClientLatentCommandState 全状态走完 |
| 5.3.4 | `IntegrationTest_ClientExecutorReplication` | ALatentAutomationCommandClientExecutor spawn + owner 设置正确 |

### 网络拓扑
| ID | Test | 内容 |
|----|------|------|
| 5.3.NT1 | `IntegrationTest_PIE_Client_1Server_1Client` | 默认配置 |
| 5.3.NT2 | `IntegrationTest_PIE_ListenServer_2Clients` | listen server + 2 client |
| 5.3.NT3 | `IntegrationTest_PIE_DedicatedServer_2Clients` | dedicated server + 2 client |
| 5.3.NT4 | `IntegrationTest_PIE_LateConnect_AfterServerReady` | client 后连，断言能拿到 server 当前状态 |

### 清理
| ID | Test | 内容 |
|----|------|------|
| 5.3.C1 | `IntegrationTest_AllPIEWorldsCleaned` | 测试结束后 PIE worlds 全部销毁 |
| 5.3.C2 | `IntegrationTest_ClientExecutorDestroyedOnDone` | ClientExecutor 进入 DONE 状态后 destroy |

### 时序
| ID | Test | 内容 |
|----|------|------|
| 5.3.T1 | `IntegrationTest_ServerSuccessBeforeClientSuccess` | server 先返回 true → 等待 client 成功才推进 |
| 5.3.T2 | `IntegrationTest_TimeoutInClientStillCallsAfter` | client 超时 → 仍执行 After()/cleanup |

### 错误恢复
| ID | Test | 内容 |
|----|------|------|
| 5.3.R1 | `IntegrationTest_ClientCrashedDuringTest_FrameworkRecovers` | 模拟 client 端错误 → 框架记录 fail 不影响下一测试 |
| 5.3.R2 | `IntegrationTest_NetEmulationDisabledByDefault` | 框架强制 disable 网络模拟，避免超时 |

### 跨场景
| ID | Test | 内容 |
|----|------|------|
| 5.3.X1 | `IntegrationTest_WithCrossMapServerTravel` | 网络型 IntegrationTest 中 server travel → 客户端跟随，断言顺利完成 |

---

# 附录 C：交付波次（按变体维度）

将 173 个用例分 **5 波**交付，每波约 1 sprint：

| 波次 | 内容 | 用例数 | 重点 |
|------|------|------|------|
| **W1（基线）** | 全部 35 主干 + 30 正例追加 | **65** | 跑通主流程；对应原计划 §4 / §5 全主题 |
| **W2（清理 + 时序）** | 25 清理 + 19 时序 | **44** | 阻断 PIE 泄漏；CI 时长可控 |
| **W3（错误恢复）** | 20 错误恢复 | **20** | 健壮性，CI 不被一张坏地图整体卡死 |
| **W4（网络拓扑）** | 19 网络拓扑 | **19** | 真正联机覆盖 |
| **W5（跨场景）** | 25 跨场景 | **25** | HotReload × 切图 × Subsystem × GC 组合验证 |

> 强烈建议 **W1 + W2 必须在同一 sprint 完成**，否则 PIE 泄漏会污染后续测试结果。

---

# 附录 D：PIE 测试通用变体 Checklist（可复用）

> 下次新增任何"打开地图"测试，以下 checklist 应过一遍：

```
[正例]
  □ 主流程 happy path
  □ 与已有 actor / class 组合（DirectPlace / Spawn / BPSubclass）
  □ 默认参数 vs 显式参数

[网络拓扑]
  □ Standalone 是否还能跑？
  □ ListenServer 1+1 客户端
  □ ListenServer 1+2 客户端
  □ DedicatedServer 1+2 客户端
  □ 客户端晚加入是否拿到当前状态？
  □ 客户端中途断开是否影响其他人？

[清理 / 泄漏]
  □ EndPIE 后 GetTestWorld() == nullptr
  □ 测试期 spawn 的 actor 全部 GC
  □ AddToViewport 的 widget 全 RemoveFromParent
  □ delegate / event 监听全部 unbind
  □ FReferenceChainSearch 检查关键对象无强引用残留
  □ 多次 PIE 启停后实例数稳定

[时序 / 容错]
  □ 主回调在 N 帧内触发（baseline 内）
  □ Reliable RPC 严格顺序
  □ Unreliable RPC 容许丢包
  □ Latent command 超时 ≤ 15s
  □ 加载耗时不超过 5s budget

[错误恢复]
  □ 不存在的地图 / 蓝图错误 → graceful fail
  □ AS reload 失败 → 旧版本继续可用
  □ RPC 校验失败 → log + 踢人，不崩溃
  □ 关键对象 destroy 期间事件触发安全
  □ 一张坏地图不阻塞套件下一张

[跨场景交互]
  □ × HotReload
  □ × MapTransition (Server/Client Travel, Seamless/Non-seamless)
  □ × Subsystem (World/GI/LP/Engine)
  □ × Replication
  □ × GC 时机
  □ × Editor undo/redo（如适用）
```

---

# 附录 E：补充变体维度（PIE 专属，新增 4 轴）

> 附录 B 的 6 轴已覆盖核心 PIE 行为。本附录追加 **4 个 PIE 测试独有但常被忽视**的轴，把测试网格从 173 → 230+ 细化。

## E.0 新增 4 轴速览

| 新轴 | 验证什么 | 适用主题 |
|------|---------|---------|
| **E.1 性能 baseline / 退化阈值** | 启动时间、tick 开销、内存占用对比基线 | 全主题（高频路径） |
| **E.2 平台差异（Windows / Linux / Headless / NullRHI）** | NullRHI、Linux dedicated server、headless commandlet 行为差异 | 4.3 / 4.10 / 5.3 |
| **E.3 数据采集与可观测性** | TemporalLog / Insights / 自定义 marker / 截图对比 | 4.8 / 4.9 / 4.10 |
| **E.4 录制 / 回放 / 重放** | demo recording、Replay subsystem 在 PIE 中的可用性 | 4.3 / 4.6 |

## E.1 性能 baseline 用例（11 用例）

| ID | Test | 内容 | 阈值建议 |
|----|------|------|---------|
| E.1.P1 | `MapTests.Perf.PIEStart_BaselineMap_5s` | 最小空地图 PIE 启动 | ≤ 5s（含 AS 编译） |
| E.1.P2 | `MapTests.Perf.PIEStart_AllExampleClassesPlaced` | 放置所有 Example AS 类的地图 | ≤ 8s |
| E.1.P3 | `MapTests.Perf.HotReload_SingleClassChange` | reload 单类耗时 | ≤ 2s |
| E.1.P4 | `MapTests.Perf.HotReload_AllScripts` | 全量 reload | ≤ 15s |
| E.1.P5 | `MapTests.Perf.MapTransition_AB` | 切图整体耗时 | ≤ 4s |
| E.1.P6 | `MapTests.Perf.SpawnActor_Bulk1000` | spawn 1000 AS actor | ≤ 200ms / 总计 |
| E.1.P7 | `MapTests.Perf.Tick_OneThousandASActors` | 1000 AS actor 同时 tick | < 5ms / 帧 |
| E.1.P8 | `MapTests.Perf.RPC_RoundTripLatency` | server → client → server reliable RPC | ≤ 50ms（无网络模拟） |
| E.1.P9 | `MapTests.Perf.PIEEndCleanup_Time` | EndPIE 清理耗时 | ≤ 1s |
| E.1.P10 | `MapTests.Perf.Memory_DeltaAfter5PIEs` | 5 次启停 PIE 后 memory delta | ≤ 50MB |
| E.1.P11 | `MapTests.Perf.AllSmoke_TotalBudget` | §4.10 全套件总耗时 | ≤ 10min |

> **执行模式**：所有 P 用例失败=warning（非 fail），写入 `Saved/AutomationReports/perf-baseline-{date}.csv`，CI 趋势监控。

## E.2 平台差异用例（8 用例）

| ID | Test | 内容 |
|----|------|------|
| E.2.X1 | `MapTests.Platform.NullRHI_NoRenderingDependentTests` | NullRHI 模式自动 skip rendering 依赖测试，不 false-fail |
| E.2.X2 | `MapTests.Platform.NullRHI_LogicTestsStillPass` | 非 rendering 测试在 NullRHI 下结果与有 RHI 一致 |
| E.2.X3 | `MapTests.Platform.HeadlessCommandlet_PIEUnavailable_GracefulSkip` | commandlet 模式下 PIE 测试自动 skip + log 原因 |
| E.2.X4 | `MapTests.Platform.LinuxDedicatedServer_NetMapTestsPass` | Linux 专服上跑 NetMapTests 与 Windows 一致 |
| E.2.X5 | `MapTests.Platform.WindowSize_HeadlessCenterEnforced` | headless 时 NewWindowWidth/Height=0 + CenterNewWindow=true 生效 |
| E.2.X6 | `MapTests.Platform.NoSavePersistentLayouts_InHeadless` | NullRHI 下 `SetCanSavePersistentLayouts(false)` 生效 |
| E.2.X7 | `MapTests.Platform.AS_ModuleLoad_AllPlatforms` | AS 模块在三平台都成功初始化 |
| E.2.X8 | `MapTests.Platform.PathSeparator_AllPlatforms` | 测试地图路径在 `/` vs `\` 处理一致 |

## E.3 数据采集与可观测性（10 用例）

| ID | Test | 内容 |
|----|------|------|
| E.3.O1 | `MapTests.Observability.TemporalLogCapturedPerActor` | TEMPORAL_LOG 在 PIE 期间产生条目，可被 dump |
| E.3.O2 | `MapTests.Observability.UnrealInsightsMarkers` | 关键路径打 `TRACE_CPUPROFILER_EVENT_SCOPE` → Insights 可见 |
| E.3.O3 | `MapTests.Observability.AutomationLogContainsExpectedKeys` | 日志含 `[ScriptClass]`/`[Actor]`/`[Summary]` 关键字（仿现有 Diagnostic Test 风格） |
| E.3.O4 | `MapTests.Observability.ScreenshotComparison_Frame60` | 启动 60 帧后截图与 baseline 对比（容差 ≤ 1%） |
| E.3.O5 | `MapTests.Observability.GameViewportRenderedAtLeastOneFrame` | 非 NullRHI 时至少 render 1 frame |
| E.3.O6 | `MapTests.Observability.MemoryDumpOnFailure` | 测试失败时自动 dump memory snapshot |
| E.3.O7 | `MapTests.Observability.GCLogsCapturedInTest` | GC 触发时长写入测试 metadata |
| E.3.O8 | `MapTests.Observability.NetworkInsightsReplayable` | `-NetTrace=1` 启动 → trace 文件可由 Networking Insights 打开 |
| E.3.O9 | `MapTests.Observability.AddInfoMessagesAreParseable` | `AddInfo` 输出可被 `GetAutomationReportSummary.ps1` 提取 |
| E.3.O10 | `MapTests.Observability.AngelscriptStateDump_OnTestStart` | 测试启动时调用 `as.DumpEngineState` 留存现场 |

## E.4 录制 / 回放 / 重放（6 用例）

| ID | Test | 内容 |
|----|------|------|
| E.4.R1 | `MapTests.Replay.RecordPIESession_GeneratesDemo` | PIE 中 `demo.rec MyDemo` → 产出 `.demo` 文件 |
| E.4.R2 | `MapTests.Replay.PlaybackDemo_ASActorsRehydrate` | 回放 demo → AS actor 状态正确还原 |
| E.4.R3 | `MapTests.Replay.RPCReplayedDeterministically` | demo 中 RPC 在回放时重新触发 |
| E.4.R4 | `MapTests.Replay.SeekDemoToTime_StateAccurate` | seek 到 t=5s → 状态等同实时跑到 5s |
| E.4.R5 | `MapTests.Replay.HotReloadDuringRecord_RecoverableOnPlayback` | 录制中途 reload → 回放给出明确提示，不崩溃 |
| E.4.R6 | `MapTests.Replay.MultiplayerReplay_ServerOnly` | listen server 录制 → 回放为单机视角 |

> 总计追加：**11 + 8 + 10 + 6 = 35 用例**，总数 **173 → 208**。

---

# 附录 F：薄弱主题密度补齐

附录 B 中部分主题（4.2 / 4.7 / 4.9 / 4.10）变体密度偏低。这里按高密度主题（22 用例）的 70% = **15 用例**为目标补齐。

## F.1 4.2 DefaultComponent 补齐至 18（+5）

| ID | Test | 内容 |
|----|------|------|
| 4.2.E1 | `MapTests.Components.NestedDefaultComponent_5Levels` | 5 层 attach 链 spawn 后位置/旋转链路正确 |
| 4.2.E2 | `MapTests.Components.SocketAttach_BoneTransformPropagates` | skeletal mesh socket 上的子组件，骨骼动画时 world transform 正确 |
| 4.2.E3 | `MapTests.Components.RuntimeAddComponent_PostSpawn` | spawn 后 AddComponent → 非 default，但 BeginPlay 行为一致 |
| 4.2.E4 | `MapTests.Components.DefaultPropertyOverride_DeepStruct` | `default Comp.NestedStruct.Field = X` 深层赋值生效 |
| 4.2.E5 | `MapTests.Components.ConstructionScriptModifiesComponent` | ConstructionScript 内调 SetSphereRadius → editor 可见 + PIE 一致 |

## F.2 4.7 增强输入 补齐至 15（+5）

| ID | Test | 内容 |
|----|------|------|
| 4.7.E1 | `MapTests.Input.GamepadStickAxisToCallback` | 手柄左摇杆模拟输入 → AS 端读到 -1..1 |
| 4.7.E2 | `MapTests.Input.MouseDelta_PerFrameSampling` | 鼠标 delta 在 tick 中采样不丢失 |
| 4.7.E3 | `MapTests.Input.ChordedActionTrigger` | A+B 同时按 → ChordedAction 触发 |
| 4.7.E4 | `MapTests.Input.MultiplePlayerControllers_PerPlayerInput` | split-screen 2 player → 输入分别路由 |
| 4.7.E5 | `MapTests.Input.UMGFocusConsumes_ActionNotForwarded` | UMG 抢焦后 InputAction 不传给 PlayerController |

## F.3 4.9 Overlap 补齐至 15（+4）

| ID | Test | 内容 |
|----|------|------|
| 4.9.E1 | `MapTests.Overlap.PhysicsTriggerVolume_BeginEndPair` | UTriggerVolume 严格 1:1 begin/end |
| 4.9.E2 | `MapTests.Overlap.IgnoredActor_NoOverlapEvent` | `MoveIgnoreActorAdd` 后不触发 overlap |
| 4.9.E3 | `MapTests.Overlap.OverlapWithCharacterCapsule` | 与 Character 胶囊体 overlap → 触发标准事件 |
| 4.9.E4 | `MapTests.Overlap.DormantActorWakesOnOverlap` | dormant actor 被 overlap 唤醒 |

## F.4 4.10 全项目烟雾 补齐至 15（+5）

| ID | Test | 内容 |
|----|------|------|
| 4.10.E1 | `MapTests.Smoke.ParallelMapBatch_NoSharedState` | 同一 batch 内多张地图按顺序跑（不真并行）→ 状态隔离 |
| 4.10.E2 | `MapTests.Smoke.LargeWorldMaps_MemoryWatermark` | World Partition 地图 → 内存水位不超阈值 |
| 4.10.E3 | `MapTests.Smoke.SpecificMapWithASActors_ASModuleLoaded` | 含 AS actor 的地图 → AS module 必须 ready，否则 fail |
| 4.10.E4 | `MapTests.Smoke.MapTagsFilterPositive_OnlyTaggedRun` | 命令行 `-MapTags=auto-smoke` → 仅跑标签匹配的 |
| 4.10.E5 | `MapTests.Smoke.MapBlackList_RespectedFromIni` | ini 配置黑名单地图 → 不参与套件 |

> F 总计 **+19 用例**，全文 208 → **227**。

---

# 附录 G：测试代码骨架（可直接 Copy）

## G.1 单地图标准模板

```cpp
// Source/AngelscriptProjectTest/Tests/MapTests/Inheritance/ASClassDirectlyPlacedTest.cpp
#include "Misc/AutomationTest.h"
#include "Tests/AutomationCommon.h"
#include "Tests/AutomationEditorCommon.h"
#include "Editor.h"
#include "EngineUtils.h"

#if WITH_DEV_AUTOMATION_TESTS

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
    FASClassDirectlyPlacedTest,
    "AngelscriptProject.MapTests.Inheritance.ASClassDirectlyPlaced",
    EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FASClassDirectlyPlacedTest::RunTest(const FString& Parameters)
{
    const FString MapPath = TEXT("/Game/Test/MapTests/Inheritance/ASClassDirectMap");

    ADD_LATENT_AUTOMATION_COMMAND(FEditorLoadMap(MapPath));
    ADD_LATENT_AUTOMATION_COMMAND(FWaitLatentCommand(1.0f));
    ADD_LATENT_AUTOMATION_COMMAND(FStartPIECommand(/*bSimulate=*/false));
    ADD_LATENT_AUTOMATION_COMMAND(FWaitLatentCommand(3.0f));

    ADD_LATENT_AUTOMATION_COMMAND(FFunctionLatentCommand([this]() -> bool
    {
        UWorld* World = nullptr;
        if (GEditor && GEditor->GetPIEWorldContext())
            World = GEditor->GetPIEWorldContext()->World();
        if (!World)
        {
            AddError(TEXT("PIE world not found"));
            return true;
        }

        UClass* TargetClass = FindFirstObject<UClass>(TEXT("AExampleActorType"));
        if (!TargetClass)
        {
            AddError(TEXT("AExampleActorType not registered"));
            return true;
        }

        int32 Count = 0;
        for (TActorIterator<AActor> It(World); It; ++It)
        {
            if (It->GetClass() == TargetClass)
            {
                ++Count;
                TestTrue(TEXT("BeginPlay called"), It->HasActorBegunPlay());
            }
        }
        TestTrue(TEXT("At least 1 placed instance"), Count > 0);
        return true;
    }));

    ADD_LATENT_AUTOMATION_COMMAND(FEndPlayMapCommand());
    ADD_LATENT_AUTOMATION_COMMAND(FWaitLatentCommand(1.0f));
    return true;
}

#endif
```

## G.2 多客户端 PIE 模板

```cpp
// Source/AngelscriptProjectTest/Tests/NetMapTests/Replication/PropertyRepMapTest.cpp
#include "Settings/LevelEditorPlaySettings.h"

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
    FPropertyRepMapTest,
    "AngelscriptProject.NetMapTests.Replication.PropertyReplicates",
    EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FPropertyRepMapTest::RunTest(const FString& Parameters)
{
    auto* Play = GetMutableDefault<ULevelEditorPlaySettings>();
    EPlayNetMode OldMode; Play->GetPlayNetMode(OldMode);
    int32 OldClients = Play->GetPlayNumberOfClients();

    Play->SetPlayNetMode(EPlayNetMode::PIE_ListenServer);
    Play->SetPlayNumberOfClients(2);
    Play->bLaunchSeparateServer = false;

    const FString MapPath = TEXT("/Game/Test/NetMapTests/PropertyRepMap");
    ADD_LATENT_AUTOMATION_COMMAND(FEditorLoadMap(MapPath));
    ADD_LATENT_AUTOMATION_COMMAND(FStartPIECommand(false));
    ADD_LATENT_AUTOMATION_COMMAND(FWaitLatentCommand(5.0f));

    ADD_LATENT_AUTOMATION_COMMAND(FFunctionLatentCommand([this]() -> bool
    {
        UWorld* ServerWorld = nullptr;
        TArray<UWorld*> ClientWorlds;
        for (const FWorldContext& Ctx : GEngine->GetWorldContexts())
        {
            if (Ctx.WorldType != EWorldType::PIE) continue;
            UWorld* W = Ctx.World();
            if (!W) continue;
            if (W->GetNetMode() == NM_ListenServer) ServerWorld = W;
            else if (W->GetNetMode() == NM_Client)  ClientWorlds.Add(W);
        }
        TestNotNull(TEXT("Server world"), ServerWorld);
        TestEqual(TEXT("Client count"), ClientWorlds.Num(), 2);
        // 改 server 端 actor 字段、N 帧后断言 client 同步...
        return true;
    }));

    ADD_LATENT_AUTOMATION_COMMAND(FEndPlayMapCommand());
    ADD_LATENT_AUTOMATION_COMMAND(FWaitLatentCommand(1.0f));
    ADD_LATENT_AUTOMATION_COMMAND(FFunctionLatentCommand([OldMode, OldClients]() -> bool
    {
        auto* P = GetMutableDefault<ULevelEditorPlaySettings>();
        P->SetPlayNetMode(OldMode);
        P->SetPlayNumberOfClients(OldClients);
        return true;
    }));
    return true;
}
```

## G.3 跨地图切换模板

```cpp
IMPLEMENT_SIMPLE_AUTOMATION_TEST(
    FRepeatedMapSwitchNoLeakTest,
    "AngelscriptProject.MapTests.MapTransition.RepeatedSwitchNoLeak",
    EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FRepeatedMapSwitchNoLeakTest::RunTest(const FString& Parameters)
{
    const FString MapA = TEXT("/Game/Test/MapTests/MapTransition/MapA");
    const FString MapB = TEXT("/Game/Test/MapTests/MapTransition/MapB");

    int32 BaselineWorldCount = 0;
    ADD_LATENT_AUTOMATION_COMMAND(FFunctionLatentCommand([&BaselineWorldCount]() -> bool
    {
        BaselineWorldCount = GEngine->GetWorldContexts().Num();
        return true;
    }));

    for (int32 i = 0; i < 4; ++i)
    {
        const FString& Map = (i % 2 == 0) ? MapA : MapB;
        ADD_LATENT_AUTOMATION_COMMAND(FEditorLoadMap(Map));
        ADD_LATENT_AUTOMATION_COMMAND(FStartPIECommand(false));
        ADD_LATENT_AUTOMATION_COMMAND(FWaitLatentCommand(2.0f));
        ADD_LATENT_AUTOMATION_COMMAND(FEndPlayMapCommand());
        ADD_LATENT_AUTOMATION_COMMAND(FWaitLatentCommand(1.5f));
    }

    ADD_LATENT_AUTOMATION_COMMAND(FFunctionLatentCommand([this, &BaselineWorldCount]() -> bool
    {
        CollectGarbage(RF_NoFlags, true);
        int32 NowCount = GEngine->GetWorldContexts().Num();
        TestEqual(TEXT("World count back to baseline"), NowCount, BaselineWorldCount);
        return true;
    }));
    return true;
}
```

## G.4 IntegrationTest AS 函数模板

```angelscript
// Script/IntegrationTests/BasicSpawnIntegrationTests.as

class UBasicSpawnLatentCheck : ULatentAutomationCommand
{
    int FramesWaited = 0;

    UFUNCTION(BlueprintOverride)
    void Before() {}

    UFUNCTION(BlueprintOverride)
    bool Update()
    {
        ++FramesWaited;
        return FramesWaited >= 60;
    }

    UFUNCTION(BlueprintOverride)
    void After()
    {
        FIntegrationTest& T = GetCurrentTest();
        T.AssertGreater(FramesWaited, 59, "Waited at least 60 frames");
    }

    UFUNCTION(BlueprintOverride)
    FString Describe() { return "BasicSpawnLatentCheck"; }
}

void IntegrationTest_BasicSpawn(FIntegrationTest& T)
{
    UWorld World = GetGameWorld();
    AActor Spawned = SpawnActor(AExampleActorType, FVector::ZeroVector);
    T.AssertNotNull(Spawned, "SpawnActor returned non-null");

    UBasicSpawnLatentCheck Check;
    T.AddLatentAutomationCommand(Check, TimeoutSecs = 5.0);
}
```

## G.5 TestSpec helper（可选 — 减少重复代码）

```cpp
// Source/AngelscriptProjectTest/Public/PIEMapTestHelpers.h
namespace AngelscriptProjectMapTest
{
    /** 一站式：load map -> start PIE -> 在 PIE world 执行 lambda -> end PIE */
    template <typename TLambda>
    void RunInPIEMap(FAutomationTestBase& Test, const FString& MapPath, TLambda&& InCheck,
                     float WaitAfterStartSec = 3.0f);

    /** 同上，但配置多客户端 */
    template <typename TLambda>
    void RunInMultiClientPIE(FAutomationTestBase& Test, const FString& MapPath,
                             int32 NumClients, EPlayNetMode NetMode,
                             TLambda&& InCheck);

    /** 帧数等待断言 */
    void TestEqualWithinFrames(FAutomationTestBase& Test, int32 MaxFrames,
                               TFunction<bool()> Predicate);
}
```

> 落地后 G.1 / G.2 / G.3 大部分样板代码可缩到 5 行内。

---

# 附录 H：CI 集成与命令行接入

## H.1 测试套件分组

| 套件标签 | 包含 prefix | 特点 | 估计单次耗时 |
|---------|------------|------|------------|
| `unit-suite` | `Angelscript.TestModule.*`（不开 PIE） | 快速反馈 | 3–5 min |
| `pie-suite` | `AngelscriptProject.MapTests.*` | 单 PIE | 8–15 min |
| `net-suite` | `AngelscriptProject.NetMapTests.*` | 多客户端 PIE | 10–20 min |
| `integration-suite` | `Angelscript.IntegrationTests.*` | AS 业务 | 8–15 min |
| `smoke-suite` | `AngelscriptProject.MapTests.Smoke.*` | 全项目地图扫一遍 | 视地图数 N×5s |
| `perf-suite` | `AngelscriptProject.MapTests.Perf.*` | baseline 收集 | 5–10 min |

## H.2 命令行入口

```powershell
# 单 PIE 套件
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 `
    -TestPrefix "AngelscriptProject.MapTests." `
    -Label pie-suite `
    -TimeoutMs 1200000

# 多客户端 PIE
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 `
    -TestPrefix "AngelscriptProject.NetMapTests." `
    -Label net-suite `
    -ExtraArgs "-NoLoadStartupPackages -NullRHI=0"

# AS IntegrationTests
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 `
    -TestPrefix "Angelscript.IntegrationTests." `
    -Label integration-suite

# 全项目烟雾（编辑 ini 开关 bRunAngelscriptSmokeOnAllMaps=true）
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 `
    -TestPrefix "AngelscriptProject.MapTests.Smoke." `
    -Label smoke-suite

# 性能 baseline（结果输出到 CSV）
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 `
    -TestPrefix "AngelscriptProject.MapTests.Perf." `
    -Label perf-suite `
    -ExtraArgs "-PerfReport=Saved/AutomationReports/perf-baseline.csv"
```

## H.3 流水线建议（CI 拓扑）

```
┌─────────── On PR ───────────┐         ┌────── Nightly ──────┐
│  unit-suite       (5 min)   │ ──┐  ┌─ │  smoke-suite        │
│  pie-suite        (15 min)  │   │  │  │  perf-suite         │
│  net-suite        (20 min)  │ ──┼──┼─ │  integration-suite  │
│                             │   │  │  │  full pie+net 网格   │
└─────────────────────────────┘   ▼  ▼  └─────────────────────┘
                                上传 trend & artifact
```

| 触发 | 套件 | 失败行为 | 报告 |
|------|------|---------|------|
| **PR 提交** | unit + pie + net | block merge | trend per-test |
| **Nightly** | smoke + perf + 全网格 | 通知不 block | 累积 baseline |
| **手工** | 任意单 prefix | 仅记录 | adhoc |

## H.4 报告聚合

复用现有 `Tools\GetAutomationReportSummary.ps1` 输出 markdown，新增字段：

| 字段 | 来源 | 用途 |
|------|------|-----|
| `MapPath` | 测试参数 | 失败地图清单 |
| `PIEStartMs` | `AddInfo` 中 `f"PIEStartMs={n}"` | perf 趋势 |
| `WorldsLeaked` | EndPIE 后 world 数 - baseline | 泄漏检测 |
| `ASModuleHash` | `as.DumpEngineState` 截取 | 模块状态变更 |

## H.5 环境变量与 ini

```ini
; Config/DefaultEngine.ini (新增段)
[/Script/AngelscriptRuntime.AngelscriptTestSettings]
IntegrationTestMapRoot=/Game/IntegrationTests/
IntegrationTestNamingConvention=*IntegrationTests*

[AutomationTestSettings]
bUseAllProjectMapsToPlayInPIE=false   ; 默认关，仅 smoke-suite 显式打开

[AngelscriptProject.MapTests]
bSkipPIEHeavyTests=false
bRunAngelscriptSmokeOnAllMaps=false
PerfReportPath=Saved/AutomationReports/
SmokeMapBlackList=("/Game/Levels/SomeBrokenMap")
SmokeMapTagFilter="auto-smoke"
```

## H.6 回归触发器（Regression）

按 UnLua issue-driven 模式，每修一个 PIE 相关 BUG → 自动落入：

```
Source/AngelscriptProjectTest/Tests/Regression/
├── Issue001_BPSubclassEmptyOverride.cpp
├── Issue002_HotReloadDuringPIECrash.cpp
└── ...
Content/Test/Regression/
├── Issue001/Issue001Map.umap
├── Issue002/Issue002Map.umap
└── ...
```

测试命名：`AngelscriptProject.Regression.Issue<N>.<BugTitle>`，永远保留作为回归网。

---

# 附录 J：测试地图制作 SOP

> **背景**：本计划要新增 25+ 张地图。地图制作是工程量大头，且容易在反复手工搭建中走样。本附录给出**标准化制作流程**，让任意贡献者在 30min 内交付一张合格测试地图。

## J.1 模板地图（Template Map）

**位置**：`Content/Test/_Templates/`

| 模板 | 内容 | 用途 |
|------|------|------|
| `Template_Empty.umap` | DefaultPawn + Sky + Floor 100×100 | 烟雾测试 / 单 actor 验证 |
| `Template_Net.umap` | + GameMode 设 PIE_ListenServer + 2 PlayerStart | 所有 NetMapTests 起点 |
| `Template_Multi.umap` | + 2 SpawnPoint 标记 actor | 跨 actor 交互（overlap、replication） |
| `Template_UMG.umap` | + 极简 GameMode 含 PlayerController.SpawnDefaultViewportClient | UMG 视口测试 |

**强制约束**：
- 每张测试地图 **从模板派生**，不允许从空白创建（避免 GameMode/PlayerStart 缺失导致 PIE 启动失败）
- 文件名必须以测试类名匹配：`<TestName>Map.umap`（便于 grep）
- 大小 ≤ 100KB（仅放断言所需的最小 actor）

## J.2 地图制作 Checklist（≤ 30 min / 张）

```
[准备]
  □ 确定对应测试类名（如 ASClassDirectlyPlacedTest）
  □ 确定要放置的 actor 类型清单（≤ 10 个）
  □ 选定 Template_*.umap

[搭建]
  □ Save As 到 Content/Test/MapTests/<Theme>/<TestName>Map.umap
  □ 删除模板自带的非必需 actor（除 GameMode / PlayerStart / Sky / Floor 外）
  □ 放置目标 actor 到 (0, 0, 100)，按测试需要复制 N 份
  □ 给关键 actor 打 ActorTag（与 C++ 测试中的 FindActorsWithTag 对齐）
  □ World Settings → GameMode 设为对应 GameMode 类（NetMapTests 必须是支持复制的 GameMode）

[验证]
  □ 编辑器手动 PIE 一次，确认 5 秒内启动且无 ERROR 日志
  □ 在 World Outliner 数 actor 数量 = 测试期望
  □ Save & 检查 .umap 大小 ≤ 100KB

[提交]
  □ git add Content/Test/.../*.umap
  □ commit 信息含对应测试类名（便于关联）
  □ 在 PR 描述中贴 PIE 启动截图（首屏）
```

## J.3 程序化生成（可选，针对烟雾测试）

对于 §4.10 / E.1 的"千张地图"批量生成场景，引入 **Editor Utility Widget** 半自动化：

```
Tools/EditorUtility/
└── BP_GenerateTestMapBatch.uasset
    输入：模板路径 + actor 类列表 + 数量
    输出：批量生成 N 张地图到 Content/Test/Generated/
```

> 与 `bRunAngelscriptSmokeOnAllMaps` 配合：生成的地图自动纳入烟雾套件。

## J.4 地图命名 / 路径速查表

| 主题 | 路径前缀 | 示例 |
|------|---------|------|
| 单 PIE 业务 | `Content/Test/MapTests/<Theme>/` | `Inheritance/ASClassDirectMap.umap` |
| 多客户端 | `Content/Test/NetMapTests/` | `PropertyRepMap.umap` |
| AS IntegrationTest | `Content/IntegrationTests/` | `BasicSpawn_IntegrationTest.umap` |
| 回归 | `Content/Test/Regression/Issue<N>/` | `Issue001/Issue001Map.umap` |
| 模板 | `Content/Test/_Templates/` | `Template_Net.umap` |
| 烟雾批量 | `Content/Test/Generated/` | `Auto_<Hash>.umap` |

> **下划线开头目录**（`_Templates`）由 IAssetRegistry 默认排除在烟雾扫描之外，避免模板被误测。

---

# 附录 K：测试质量门禁（Quality Gate）

> **目的**：防止"为达指标而堆砌"的低质量用例进入主干。每个 PR 触达本计划范围必须满足以下门禁。

## K.1 用例级门禁（per-test）

| 门禁项 | 阈值 | 检查方式 |
|--------|------|---------|
| 单测试耗时 | ≤ 15s | Automation Framework 自带 timeout |
| EndPIE 后 GetTestWorld()==nullptr | 必须 | `FCleanupTest::Update` 自动检查 |
| AddInfo / AddWarning / AddError 行数 | ≥ 1 行 info 输出 | grep `AddInfo` 验证 |
| 至少 1 个 TestEqual / TestTrue / TestNotNull | 必须 | grep + AST 检查 |
| 包含 `#if WITH_DEV_AUTOMATION_TESTS` 守卫 | 必须 | grep |
| 测试 ID 命名匹配 `AngelscriptProject\..*` | 必须 | regex |

## K.2 套件级门禁（per-suite）

| 门禁项 | 阈值 | 触发动作 |
|--------|------|---------|
| pie-suite 总耗时 | ≤ 20 min | 超时 → CI fail |
| net-suite 总耗时 | ≤ 25 min | 超时 → CI fail |
| 套件 flake rate（连续 5 次有 ≥ 1 次失败） | < 5% | flake → 自动加 `[FlakyTest]` 标签隔离 |
| 内存 delta（5 次 PIE 后） | ≤ 100MB | 超过 → warning + 触发 perf-suite |
| 全项目烟雾 fail 率 | < 2% | 超过 → block release |

## K.3 PR 模板（自动检查清单）

每个 PR 添加测试时，PR description 必须包含以下勾选清单：

```markdown
### PIE Test PR Checklist
- [ ] 新增地图基于 _Templates/Template_*.umap 派生
- [ ] 地图大小 ≤ 100KB（执行 `git ls-files -s` 验证）
- [ ] 测试在本机 headless 模式下连跑 3 次，全 pass
- [ ] 测试结束后 `GetTestWorld()` 返回 nullptr（断言 / 日志）
- [ ] 至少 1 个 TestEqual/TestTrue/TestNotNull
- [ ] PIE 截图（如适用）已附在 PR description
- [ ] 未引入超过 5s 的 FWaitLatentCommand
- [ ] 命名遵循 `AngelscriptProject.<Suite>.<Theme>.<Case>` 三段式
```

> CI hook 自动验证 1/2/4/5/7/8 项；3、6 项由 reviewer 检查。

## K.4 反模式（直接 reject）

| 反模式 | 为什么不行 | 替代方案 |
|--------|-----------|---------|
| `FWaitLatentCommand(10.0f)` 写死等 10 秒 | 不可扩展、CI 时长爆炸 | 用 `FFunctionLatentCommand` 轮询条件 |
| 测试中改 `GEngine->LoadMap()` 而不走 `FEditorLoadMap` | 绕过 PIE 框架，资源未真正加载 | 用 `AutomationOpenMap` |
| 直接读 `GWorld` 而不是 PIE world | headless 多实例时拿到错的 world | 用 `GEditor->GetPIEWorldContext()->World()` 或 helper |
| 测试间通过全局变量传值 | 顺序敏感，flake 源 | 测试自包含；如需共享数据用 `Test->Param` |
| 写死 actor 数量（如 `TestEqual(7)`）不留余量 | 编辑器自带 actor（DefaultPawn 等）会浮动 | 按 class 过滤后再 count |
| 多 client 测试不还原 PlaySettings | 污染后续测试 | 严格按 G.2 模板还原 |

---

# 附录 L：失败诊断 Runbook

> **目的**：本计划新增大量 PIE 测试，失败模式各异。本附录给出**症状 → 排查步骤**速查表，让 oncall / reviewer 不必每次重新摸索。

## L.1 症状 1：PIE 启动失败（FStartPIECommand 后 world 仍为空）

```
排查步骤：
1. 检查地图是否存在：
   ls Content/Test/<Theme>/<TestName>Map.umap.uasset
2. 在编辑器手动打开该地图 → 手动 PIE 一次确认能跑
3. 检查 World Settings → GameMode → 是否为支持当前 NetMode 的 GameMode
4. 看 Saved/Logs/Angelscript.log 最近 100 行，找 ERROR / Warning
5. 确认 BP 编译无错误：
   .\Tools\RunBuild.ps1 -CheckBPOnly
6. 复盘 PIE 配置：是否前一个测试遗留了 PIE_Client 模式未还原（K.4 反模式）
```

## L.2 症状 2：测试 hang（超过套件时长不返回）

```
排查步骤：
1. 查看 hang 在哪个 LatentCommand：
   grep "Starting to wait for" Saved/Logs/Angelscript.log | tail -5
2. 是否使用了 FWaitLatentCommand(>5s) → 改为轮询 FFunctionLatentCommand
3. 是否 ULatentAutomationCommand::Update() 永远返回 false → 加超时
4. 是否 ATestTerminator 未被销毁 → 检查 IntegrationTest::FExitTest 是否被加入命令队列
5. 多客户端场景：检查 client world 是否真的连上 server
   for ctx in GEngine->GetWorldContexts(): print ctx.WorldType, ctx.World()->GetNetMode()
```

## L.3 症状 3：EndPIE 后 GetTestWorld() != nullptr（泄漏）

```
排查步骤：
1. 哪种 world 残留？检查 WorldType
2. 是否网络模拟未 disable → ULevelEditorPlaySettings::bIsNetworkEmulationEnabled
3. 是否 actor 持有 strong UObject ref 阻止 GC：
   FReferenceChainSearch(LeakedActor, EReferenceChainSearchMode::PrintAllResults)
4. 是否 delegate 未 unbind → grep AddUFunction without RemoveAll
5. 强制 GC 多次后再检查：
   for (int i=0; i<3; ++i) CollectGarbage(RF_NoFlags, true);
```

## L.4 症状 4：测试在 PR 通过但 nightly fail（flake）

```
排查步骤：
1. 是否依赖测试执行顺序？尝试单独跑：
   RunTests.ps1 -TestPrefix "<exact_test_id>"
2. 是否 timing-sensitive？查看是否使用了 FWaitLatentCommand 而非帧计数
3. 是否依赖未保证的 ordering（如 multimap iteration）
4. 检查测试是否使用了 random seed → 固定 seed
5. 加入 [FlakyTest] 标签短暂隔离，开 issue 跟踪根因
```

## L.5 症状 5：Headless 模式 fail 但 Editor 模式 pass

```
排查步骤：
1. 是否使用了 GameViewport 相关 API（NullRHI 下不可用）→ 标 RequireRHI
2. 是否依赖 Slate/UMG 渲染 tick → 同上
3. 是否依赖编辑器特定 Tab/Window → 用 #if WITH_EDITOR + headless 检查
4. 检查 IsRunningCommandlet() 路径分支
5. 强制 NullRHI 跑一次本地复现：
   UE4Editor.exe MyProject -NullRHI -Unattended -ExecCmds="Automation RunTests <test>"
```

## L.6 症状 6：网络复制行为不一致（server 改了 client 没收到）

```
排查步骤：
1. actor->GetIsReplicated() == true？
2. property 标 Replicated？GetLifetimeReplicatedProps 实现了？
3. 等够时间了吗？net update 频率默认 ~10Hz → 等至少 200ms
4. 用 Network Insights 抓包：
   UE4Editor.exe -NetTrace=1 ...
5. 检查 client world 是否真的是 NM_Client（不是被错误标为 server）
6. RPC 是否打了 Owner？只有 Owner 能调 server RPC
```

## L.7 一键调试启动（本地复现 CI 失败）

```powershell
# 完全模拟 CI 环境
$env:UE_AUTOMATION_LOG_LEVEL = "VeryVerbose"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 `
    -TestPrefix "<failing_test_exact_id>" `
    -Label local-repro `
    -ExtraArgs "-NullRHI -Unattended -NoSplash -NoSound" `
    -KeepLogs

# 日志位置
ls Saved/AutomationReports/local-repro-*/
ls Saved/Logs/Angelscript.log
```

---

# 附录 M：滚动里程碑（按月计）

> **目的**：把 5 波交付（附录 C）落到具体的 monthly 节奏，便于 PM/QA/CI 协同排期。

## M.1 总计周期：5 个月（22 周）

| 月份 | 周次 | 主要交付 | 累计用例 | 累计地图 | 关键里程碑 |
|------|------|---------|---------|---------|----------|
| **M1** | W1–W4 | W1：主干 + 正例追加 | 65 | 25 | M1-EOM：主流程跑通，CI pie-suite green |
| **M2** | W5–W8 | W2：清理 + 时序 + 附录 G helper 落地 | 109 | 25 | M2-EOM：泄漏检测全开，单测代码量 ≤ 5 行 |
| **M3** | W9–W12 | W3：错误恢复 + 附录 J 模板地图 + L runbook | 129 | 30 | M3-EOM：第一次 nightly 完整跑通 |
| **M4** | W13–W17 | W4：网络拓扑 + 附录 H CI 拓扑落地 | 148 | 35 | M4-EOM：multi-client 联机测试 stable |
| **M5** | W18–W22 | W5：跨场景 + E.1–E.4 性能/平台/录制 | 227+ | 40+ | M5-EOM：本计划完整收口，转入维护 |

## M.2 每月里程碑细化

### M1（主流程 + 正例）—— 65 用例 / 25 地图

```
W1：环境与脚手架
  □ 创建 _Templates/ 4 张模板地图（J.1）
  □ 落地 §6.1 helper（AngelscriptPIETestHelpers）
  □ 配置 IntegrationTestMapRoot ini（§5.1）
  □ 第一个 Reference 测试用 helper 重写

W2：4.1 继承链 + 4.2 DefaultComponent
  □ 7 主干 + 6 正例追加 → 13 用例 / 7 地图
  □ PR 模板 + K.3 checklist 上线

W3：4.3 网络复制（核心）
  □ 6 主干 + 3 正例追加 → 9 用例 / 3 地图
  □ G.2 多客户端模板落地

W4：4.4 / 4.5 / 4.6 主干
  □ 8 主干 + 7 正例追加 → 15 用例 / 8 地图
  □ M1 完成验收：CI 跑 unit + pie 全绿
```

### M2（清理 + 时序 + 附录 G）—— +44 用例

```
W5：4.7–4.10 主干 + 正例
  □ 7 主干 + 9 正例追加 → 16 用例 / 3 地图
  □ helper RunInPIEMap / RunInMultiClientPIE / TestEqualWithinFrames 全落地

W6：清理（25 用例）
  □ EndPIE 检测、GC 检测、widget 清理、delegate unbind 全覆盖
  □ FCleanupTest 增强：自动 dump leaked objects

W7：时序（19 用例）
  □ 帧数预算、RPC 顺序、超时检测
  □ K.4 反模式 lint 上线（grep + CI hook）

W8：M2 验收 + 文档同步
  □ 单 test 代码量统计（目标 ≤ 5 行业务代码）
  □ 套件总耗时 ≤ 35min（pie + net + integration）
```

### M3（错误恢复 + 模板 + Runbook）—— +20 用例

```
W9：错误恢复 (20)
  □ 坏地图、BP 编译错、reload 失败、RPC 校验失败全验

W10：附录 J 模板地图制作 SOP
  □ 4 张模板地图 commit
  □ Editor Utility 半自动化生成（J.3）

W11：附录 L Runbook + Wiki
  □ 6 类 PIE 失败症状 → 排查步骤
  □ 一键复现脚本（L.7）

W12：M3 验收
  □ 第一次 nightly 完整套件
  □ 故障注入演练：reviewer 按 L.1–L.6 排查
```

### M4（网络拓扑 + CI 拓扑）—— +19 用例

```
W13–W14：4.3 + 5.3 网络拓扑全场景
  □ Standalone / ListenServer / DedicatedServer / 1+1 / 1+2 / 1+4 全跑
  □ 晚加入、断开重连、Linux dedicated server

W15–W16：附录 H CI 拓扑
  □ 6 套件分组上线
  □ PR vs Nightly 流水线分流
  □ 趋势报告 dashboard

W17：M4 验收
  □ 网络型测试 flake rate < 5%
  □ Linux 流水线绿
```

### M5（跨场景 + 性能基线 + 收口）—— +54 用例

```
W18：跨场景交互 (25)
  □ HotReload × MapTransition × Subsystem × Replication × GC 矩阵

W19：E.1 性能 baseline (11)
  □ 11 个 perf 用例 → CSV 写入 baseline
  □ 趋势监控：perf 退化阈值告警

W20：E.2 + E.3 平台 + 可观测性 (18)
  □ NullRHI / Linux / commandlet 三平台跑通
  □ TemporalLog / Insights / Screenshot 全集成

W21：E.4 录制回放 (6) + F 密度补齐 (19)
  □ demo recording / playback
  □ 4 个稀疏主题密度补齐

W22：M5 收口
  □ 227+ 用例全绿 30 次以上
  □ 文档归档：本计划状态 → "已完成" 进入 Plan_StatusPriorityRoadmap.md
  □ 切换到维护模式：仅添加 Regression/Issue<N>
```

## M.3 进度可视化（建议自动生成）

```
Tools/Diagnostics/PIETestProgressReport.ps1
  输入：Documents/Plans/Plan_PIEMapBasedTestExpansion.md
  扫描：所有测试 ID 是否已在 Source/AngelscriptProjectTest/Tests/ 下落地
  输出：Markdown 报告，含进度条、未完成清单、地图清单
  CI：每周自动跑，结果贴到 Wiki 首页
```

示例输出：

```
## PIE Test Coverage Progress (Week 12)

  Total:    227 ████████████████░░░░░░░░░░░░  129/227 (56.8%)
  Maps:     40+ ████████████░░░░░░░░░░░░░░░░  18/40 (45.0%)

  By Theme:
    4.1 Inheritance        ███████████████  15/15 (100%)  ✓
    4.2 Components         ████████████░░░  10/13 (76.9%)
    4.3 Replication        ███████████░░░░  16/22 (72.7%)
    ...

  Last Week +14 cases / +3 maps
```

## M.4 风险预警（按月）

| 月份 | 风险 | 缓解 |
|------|------|-----|
| M1 | 模板地图设计不合理导致 W3+ 全部返工 | M1-W1 一定先做 J.1 模板 + 第一张参考实现 |
| M2 | helper 设计与已有 IntegrationTest 冲突 | 由插件 owner review 后再大批使用 |
| M3 | 错误恢复测试自身可能 flake | 单独 CI job + retry 3 次的容错 |
| M4 | 网络测试 Linux 与 Windows 行为差异 | M3 末做一次 Linux 烟雾验证 |
| M5 | 性能 baseline 需要 1 周稳定数据 | W19 收 baseline 时 freeze 其他改动 |

---





> 当前项目侧只有 1 张测试地图与 1 个地图测试；本计划在不动插件框架的前提下，补充 40+ 张专用测试地图和 **227+ 个** C++/AS 测试用例，覆盖 AS 类继承、Default 组件、网络复制、Subsystem 生命周期、HotReload、地图切换、输入/UMG/Overlap、全项目烟雾、性能、平台、可观测性、录制回放，并打通插件 IntegrationTest 框架在项目侧的"地图 + AS 函数"配对落地。
>
> **文档分层**（从规划 → 落地）：
> - §1–§10：**主干规划**（现状、设计原则、10 主题 35 用例、配套脚手架）
> - **附录 B/C/D**：用 6 个 PIE 变体轴铺开为 173 个细粒度测试 + 5 波交付 + checklist
> - **附录 E/F**：4 个新轴（性能 / 平台 / 可观测性 / 回放）+ 密度补齐 → 总数 **227**
> - **附录 G**：5 段可直接 copy 的代码骨架
> - **附录 H**：CI 套件分组、命令行、流水线拓扑、配置 ini、Regression 目录约定
> - **附录 J**：**地图制作 SOP**（模板地图、30min 单张 checklist、命名规范）
> - **附录 K**：**质量门禁**（用例级/套件级/PR 模板/反模式 6 条）
> - **附录 L**：**失败诊断 Runbook**（6 类症状 → 排查步骤 + 一键本地复现）
> - **附录 M**：**5 个月滚动里程碑**（M1–M5 周级任务 + 自动进度报告 + 风险预警）
>
> **交付可度量**：227+ 用例 / 40+ 地图 / 5 个月 / 5 波 / 6 套件 / 3 平台（Windows/Linux/NullRHI）。单测试业务代码量 ≤ 5 行（借助 helper）；pie-suite 总耗时 ≤ 20min；flake rate < 5%；内存泄漏 ≤ 100MB/5-PIE。
