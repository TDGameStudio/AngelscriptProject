# 地图级 PIE 测试扩展方案

## Context

当前项目有两套测试驱动方式：

1. **内存 World 测试**（主流，插件内）：通过 `FAngelscriptTestWorld` / `FActorTestSpawner` 在内存中创建 UWorld，无需地图文件，覆盖 429 个 .cpp 测试。
2. **地图 PIE 测试**（少量，两处实现）：加载真实 .umap，启动 PIE 会话，可测试完整编辑器→运行时流程。

**现有地图测试：**
- **插件侧**（`Plugins/Angelscript/Source/AngelscriptRuntime/Testing/IntegrationTest.cpp`）：Hazelight 原有的 IntegrationTest 框架，加载地图 + PIE_Client 模式 + 网络仿真 + LatentAutomationCommand。按设计需要 AS 脚本中声明 `IntegrationTest_*` 函数 + 配套 .umap。
- **项目侧**（`Source/AngelscriptProjectTest/Tests/BlueprintSubclassBeginPlayDiagnosticTest.cpp`）：使用 UE 标准 `FEditorLoadMap` → `FStartPIECommand` → `FFunctionLatentCommand` → `FEndPlayMapCommand` 流程，加载 `/Game/Test/ActorTestMap`。

**当前 Content 测试资产：**
```
Content/Test/ActorTestMap.umap          ← 唯一测试地图
Content/Test/BP_AExampleActorType.uasset ← 蓝图子类
```

**问题**：
- 插件侧的 IntegrationTest 框架本身属于插件可复用基础设施，但**使用它的具体测试和测试地图应放在项目侧**（`Source/AngelscriptProjectTest/` + `Content/Test/`），因为它们依赖项目 Content 资产。
- 目前只有 1 张测试地图、1 个地图级测试，覆盖极为有限。
- 大量需要真实 World/GameMode/PlayerController/物理/碰撞/网络同步的测试场景无法用内存 World 覆盖。

---

## 测试架构说明

### 两种地图测试模式

#### 模式 A：UE 标准 PIE 命令（推荐用于项目侧测试）

```cpp
// 文件位置: Source/AngelscriptProjectTest/Tests/XXX.cpp
// 使用 UE 内置 Latent Automation Command

bool RunTest(const FString& Parameters)
{
    // 1. 加载地图到编辑器
    ADD_LATENT_AUTOMATION_COMMAND(FEditorLoadMap(TEXT("/Game/Test/MyTestMap")));
    ADD_LATENT_AUTOMATION_COMMAND(FWaitLatentCommand(1.0f));

    // 2. 启动 PIE
    ADD_LATENT_AUTOMATION_COMMAND(FStartPIECommand(false));
    ADD_LATENT_AUTOMATION_COMMAND(FWaitLatentCommand(2.0f));

    // 3. 在 PIE World 中检查
    ADD_LATENT_AUTOMATION_COMMAND(FFunctionLatentCommand([this]() -> bool
    {
        UWorld* PIEWorld = nullptr;
        for (const FWorldContext& Ctx : GEngine->GetWorldContexts())
        {
            if (Ctx.WorldType == EWorldType::PIE && Ctx.World())
            {
                PIEWorld = Ctx.World();
                break;
            }
        }
        // ... 验证逻辑 ...
        return true;
    }));

    // 4. 结束 PIE
    ADD_LATENT_AUTOMATION_COMMAND(FEndPlayMapCommand());
    return true;
}
```

**优点**：简单直接，不依赖插件 IntegrationTest 框架，标准 UE 模式。
**适用**：蓝图子类验证、地图预设场景验证、编辑器集成测试。

#### 模式 B：插件 IntegrationTest 框架（适用于 AS 脚本集成测试）

```
// 在 AngelscriptTestSettings 中配置:
//   IntegrationTestMapRoot = "/Game/Test/"
//   IntegrationTestNamingConvention = "Test/*"

// AS 脚本中声明:
void IntegrationTest_MyScenario(FIntegrationTest& T)
{
    // 自动加载 /Game/Test/MyScenario_IntegrationTest.umap
    // 自动启动 PIE_Client 模式
    // 可使用 T.AddLatentAutomationCommand()
}
```

**优点**：AS 原生、支持 Client/Server 多 World、内置网络仿真。
**适用**：网络同步测试、多 World 场景、AS 脚本全流程。

### 文件位置原则

| 类型 | 位置 | 理由 |
|------|------|------|
| 测试地图 (.umap) | `Content/Test/` | 项目 Content 资产 |
| 蓝图资产 (.uasset) | `Content/Test/` | 项目 Content 资产 |
| 项目级 C++ 测试 | `Source/AngelscriptProjectTest/Tests/` | 依赖项目 Content，不应进入插件 |
| 插件测试框架基础设施 | `Plugins/Angelscript/.../Testing/` | 可复用框架，不含具体测试 |
| 插件内 C++ 测试（内存 World） | `Plugins/Angelscript/.../AngelscriptTest/` | 不依赖 Content |

---

## 测试地图规划

### 需要创建的测试地图

| 地图名 | 内容路径 | 用途 | 预置内容 |
|--------|----------|------|----------|
| `ActorTestMap` | `/Game/Test/ActorTestMap` | Actor 生命周期 & 蓝图子类 | ✅ 已存在。BP_AExampleActorType 实例 |
| `ComponentHierarchyMap` | `/Game/Test/ComponentHierarchyMap` | 组件层级 & 附着 | 多层 DefaultComponent Actor，Socket 附着 Actor |
| `OverlapCollisionMap` | `/Game/Test/OverlapCollisionMap` | 碰撞 & Overlap 事件 | 触发区域 Actor + 可移动 Pawn |
| `WidgetTestMap` | `/Game/Test/WidgetTestMap` | UMG Widget 系统 | HUD 蓝图 + PlayerController |
| `SpawnTestMap` | `/Game/Test/SpawnTestMap` | 运行时 Spawn & 销毁 | Spawner Actor + 空旷场地 |
| `PhysicsTestMap` | `/Game/Test/PhysicsTestMap` | 物理模拟 & 碰撞响应 | 地板 + 物理 Actor + 触发器 |
| `TimerEventMap` | `/Game/Test/TimerEventMap` | Timer & 事件委托 | Timer Actor + 事件监听 Actor |
| `GameModeTestMap` | `/Game/Test/GameModeTestMap` | GameMode & PlayerController | 自定义 GameMode + 出生点 |
| `SubsystemTestMap` | `/Game/Test/SubsystemTestMap` | WorldSubsystem 运行时行为 | 简单空间 |
| `NetworkTestMap` | `/Game/Test/NetworkTestMap` | 网络同步 & RPC | 可复制 Actor + PlayerStart ×2 |
| `AITestMap` | `/Game/Test/AITestMap` | AI & BT 节点 | NavMesh + AI Controller + Pawn |
| `ConstructionScriptMap` | `/Game/Test/ConstructionScriptMap` | ConstructionScript 验证 | 使用 ConstructionScript 的 Actor |
| `MultiPIETestMap` | `/Game/Test/MultiPIETestMap` | 多客户端测试 | 多 PlayerStart + 可复制 Actor |

---

## 具体测试用例

### 1. Actor 地图级生命周期

**地图**: `ActorTestMap`（已存在）
**文件**: `Source/AngelscriptProjectTest/Tests/ActorMapLifecycleTests.cpp`

#### 1.1 蓝图子类 BeginPlay 传播

```cpp
// Test: AngelscriptProject.Map.Actor.BlueprintSubclassBeginPlay
// 验证: 蓝图子类的 AS 父类 BeginPlay 是否正确执行
// 地图预置: BP_AExampleActorType 实例放置在地图中

bool RunTest(const FString& Parameters)
{
    ADD_LATENT_AUTOMATION_COMMAND(FEditorLoadMap(TEXT("/Game/Test/ActorTestMap")));
    ADD_LATENT_AUTOMATION_COMMAND(FWaitLatentCommand(1.0f));
    ADD_LATENT_AUTOMATION_COMMAND(FStartPIECommand(false));
    ADD_LATENT_AUTOMATION_COMMAND(FWaitLatentCommand(2.0f));
    ADD_LATENT_AUTOMATION_COMMAND(FFunctionLatentCommand([this]() -> bool
    {
        UWorld* PIEWorld = FindPIEWorld();
        if (!PIEWorld) { AddError(TEXT("PIE World not found")); return true; }

        UClass* ScriptClass = FindFirstObject<UClass>(TEXT("AExampleActorType"));
        if (!ScriptClass) { AddError(TEXT("Script class not compiled")); return true; }

        int32 ScriptActorCount = 0;
        for (TActorIterator<AActor> It(PIEWorld); It; ++It)
        {
            if (It->GetClass()->IsChildOf(ScriptClass))
            {
                ScriptActorCount++;
                // 验证 BeginPlay 已执行
                TestTrue(TEXT("Actor should have begun play"), It->HasActorBegunPlay());

                // 读取脚本属性验证 BeginPlay 中的赋值
                FIntProperty* Prop = FindFProperty<FIntProperty>(
                    It->GetClass(), TEXT("ExampleValue"));
                if (Prop)
                {
                    int32 Val = Prop->GetPropertyValue_InContainer(*It);
                    // 验证脚本 BeginPlay 中的赋值生效
                    AddInfo(FString::Printf(TEXT("ExampleValue = %d"), Val));
                }
            }
        }
        TestTrue(TEXT("Should find at least one script actor in map"),
                 ScriptActorCount > 0);
        return true;
    }));
    ADD_LATENT_AUTOMATION_COMMAND(FEndPlayMapCommand());
    return true;
}
```

#### 1.2 地图预置 Actor 属性覆盖

```cpp
// Test: AngelscriptProject.Map.Actor.MapPlacedPropertyOverride
// 验证: 编辑器中修改的 AS Actor 属性在 PIE 中正确保留
// 地图预置: AExampleActorType 实例，EditAnywhere 属性手动改为非默认值

// 步骤:
// 1. FEditorLoadMap → FStartPIECommand
// 2. 遍历 PIE World 找到目标 Actor
// 3. 验证编辑器修改的属性值（非默认值）在 PIE 中保留
// 4. FEndPlayMapCommand

// 验证:
// 1. 编辑器中设定的 UPROPERTY 值在 PIE 运行后保持
// 2. default 关键字设置的组件属性正确继承
```

#### 1.3 地图中多个 AS Actor 独立状态

```cpp
// Test: AngelscriptProject.Map.Actor.MultipleInstancesIndependentState
// 验证: 地图中放置多个同类 AS Actor 实例，各自状态独立
// 地图预置: 3 个 AExampleActorType 实例，不同位置

// 步骤:
// 1. 加载地图 → 启动 PIE
// 2. 找到所有同类 Actor
// 3. Tick 数帧（等待 Timer/Tick 执行）
// 4. 验证每个实例的计数器独立递增
// 5. 验证位置各不相同

// 验证:
// 1. 找到 3 个实例
// 2. 每个实例 TickCount 独立
// 3. 位置与地图预设一致
```

---

### 2. 组件层级（地图验证）

**地图**: `ComponentHierarchyMap`（新建）
**文件**: `Source/AngelscriptProjectTest/Tests/ComponentHierarchyMapTests.cpp`

#### 2.1 多层 DefaultComponent 运行时验证

```cpp
// Test: AngelscriptProject.Map.Component.MultiLevelHierarchyRuntime
// 验证: 地图中的多层 DefaultComponent 链在 PIE 运行时正确

// AS 脚本 (Script/Test/TestHierarchyActor.as):
// class ATestHierarchyActor : AActor
// {
//     UPROPERTY(DefaultComponent, RootComponent)
//     USceneComponent Root;
//
//     UPROPERTY(DefaultComponent, Attach = Root)
//     USceneComponent Level1;
//
//     UPROPERTY(DefaultComponent, Attach = Level1)
//     UStaticMeshComponent Level2Mesh;
//
//     UPROPERTY(DefaultComponent, Attach = Level2Mesh)
//     UPointLightComponent Level3Light;
//
//     UPROPERTY()
//     bool bHierarchyValid = false;
//
//     UFUNCTION(BlueprintOverride)
//     void BeginPlay()
//     {
//         // 运行时自检层级
//         bHierarchyValid =
//             Level1.GetAttachParent() == Root &&
//             Level2Mesh.GetAttachParent() == Level1 &&
//             Level3Light.GetAttachParent() == Level2Mesh;
//     }
// }

// 地图预置: ATestHierarchyActor 放在地图中

// PIE 验证:
// 1. bHierarchyValid == true
// 2. 各组件 GetAttachParent() 链完整
// 3. Root 是 RootComponent
```

#### 2.2 组件 default 属性在 PIE 中生效

```cpp
// Test: AngelscriptProject.Map.Component.DefaultPropertyInPIE
// 验证: default 关键字设置的组件属性在 PIE 运行时正确

// AS 脚本:
// class ADefaultPropTestActor : AActor
// {
//     UPROPERTY(DefaultComponent, RootComponent)
//     USphereComponent Sphere;
//     default Sphere.SphereRadius = 256.0;
//
//     UPROPERTY()
//     float RuntimeSphereRadius = 0.0;
//
//     UFUNCTION(BlueprintOverride)
//     void BeginPlay()
//     {
//         RuntimeSphereRadius = Sphere.SphereRadius;
//     }
// }

// PIE 验证:
// RuntimeSphereRadius == 256.0（而非默认的 32.0）
```

---

### 3. Overlap & 碰撞事件

**地图**: `OverlapCollisionMap`（新建）
**文件**: `Source/AngelscriptProjectTest/Tests/OverlapCollisionMapTests.cpp`

#### 3.1 Actor 进入/离开触发区域

```cpp
// Test: AngelscriptProject.Map.Overlap.ActorEnterExitTrigger
// 验证: AS Actor 的 ActorBeginOverlap/ActorEndOverlap 在 PIE 碰撞时触发

// 地图预置:
// - ATriggerZoneActor (AS): 带 UBoxComponent, 记录 OverlapCount
// - AMovablePawn (AS 或蓝图): 可移动到触发区域内外

// 测试流程:
// 1. 加载地图 → PIE
// 2. 等待 BeginPlay（1-2秒）
// 3. 通过 SetActorLocation 移动 Pawn 进入 Box
// 4. 等待物理帧（0.5秒）
// 5. 读取 OverlapBeginCount — 应为 1
// 6. 移动 Pawn 离开 Box
// 7. 等待物理帧
// 8. 读取 OverlapEndCount — 应为 1

ADD_LATENT_AUTOMATION_COMMAND(FFunctionLatentCommand([this]() -> bool
{
    UWorld* PIEWorld = FindPIEWorld();

    // 找到 TriggerZone
    AActor* TriggerZone = FindActorOfClass(PIEWorld, TEXT("ATriggerZoneActor"));
    AActor* MovablePawn = FindActorOfClass(PIEWorld, TEXT("AMovablePawn"));

    if (!TriggerZone || !MovablePawn)
    {
        AddError(TEXT("Missing test actors in map"));
        return true;
    }

    // 将 Pawn 移到 TriggerZone 中心
    MovablePawn->SetActorLocation(TriggerZone->GetActorLocation());
    return true;
}));
// 等待物理处理
ADD_LATENT_AUTOMATION_COMMAND(FWaitLatentCommand(0.5f));
ADD_LATENT_AUTOMATION_COMMAND(FFunctionLatentCommand([this]() -> bool
{
    // 读取 OverlapBeginCount
    // 验证 == 1
    return true;
}));
```

#### 3.2 组件级 Overlap 委托

```cpp
// Test: AngelscriptProject.Map.Overlap.ComponentDelegateOverlap
// 验证: OnComponentBeginOverlap.AddUFunction 在真实碰撞中触发

// 地图预置:
// - ADamageZoneActor (AS): BoxComponent + OnComponentBeginOverlap 绑定
//   BeginPlay 中: Box.OnComponentBeginOverlap.AddUFunction(this, n"OnEnter")
// - 测试用可移动 Actor

// PIE 验证:
// 移动 Actor 进入 Box → OnEnter 被调用 → EnteredActors.Num() >= 1
```

---

### 4. 物理模拟

**地图**: `PhysicsTestMap`（新建）
**文件**: `Source/AngelscriptProjectTest/Tests/PhysicsMapTests.cpp`

#### 4.1 物理 Actor 自由落体

```cpp
// Test: AngelscriptProject.Map.Physics.FreeFall
// 验证: AS Actor 的物理组件在 PIE 中正确模拟重力

// 地图预置:
// - APhysicsTestActor (AS): StaticMeshComponent + SimulatePhysics
//   初始位置: Z=500
// - 地板 Actor: Z=0

// PIE 验证 (3秒后):
// 1. APhysicsTestActor 的 Z 坐标 < 初始 500
// 2. Z 坐标 > 0（落在地板上）
// 3. Velocity.Z 接近 0（已停稳）
```

#### 4.2 射线检测

```cpp
// Test: AngelscriptProject.Map.Physics.LineTrace
// 验证: AS 脚本中的 LineTrace 在 PIE 真实物理场景中工作

// 地图预置:
// - ALineTraceActor (AS): BeginPlay 中向下发射线
// - 地板 StaticMesh (有碰撞)

// AS 脚本:
// UFUNCTION(BlueprintOverride)
// void BeginPlay()
// {
//     FHitResult Hit;
//     bool bHit = System::LineTraceSingle(
//         GetActorLocation(),
//         GetActorLocation() - FVector(0, 0, 10000),
//         ETraceTypeQuery::TraceTypeQuery1,
//         false, TArray<AActor>(), EDrawDebugTrace::None, Hit, true
//     );
//     bTraceHit = bHit;
//     TraceHitDistance = Hit.Distance;
// }

// PIE 验证:
// bTraceHit == true
// TraceHitDistance > 0 且合理
```

---

### 5. GameMode & PlayerController

**地图**: `GameModeTestMap`（新建）
**文件**: `Source/AngelscriptProjectTest/Tests/GameModeMapTests.cpp`

#### 5.1 AS GameMode 初始化

```cpp
// Test: AngelscriptProject.Map.GameMode.ScriptGameModeInit
// 验证: AS 定义的 GameMode 在 PIE 中被正确使用

// AS 脚本:
// class ATestGameMode : AGameModeBase
// {
//     UPROPERTY()
//     bool bGameModeInitialized = false;
//
//     UPROPERTY()
//     int32 PlayerLoginCount = 0;
//
//     UFUNCTION(BlueprintOverride)
//     void InitGame(FString MapName, FString Options, FString& ErrorMessage)
//     {
//         Super::InitGame(MapName, Options, ErrorMessage);
//         bGameModeInitialized = true;
//     }
//
//     UFUNCTION(BlueprintOverride)
//     void PostLogin(APlayerController NewPlayer)
//     {
//         Super::PostLogin(NewPlayer);
//         PlayerLoginCount += 1;
//     }
// }

// 地图 World Settings: GameMode Override = ATestGameMode

// PIE 验证:
// 1. PIEWorld->GetAuthGameMode() 是 ATestGameMode 类型
// 2. bGameModeInitialized == true
// 3. PlayerLoginCount >= 1
```

#### 5.2 AS PlayerController 输入绑定

```cpp
// Test: AngelscriptProject.Map.GameMode.ScriptPlayerControllerSpawn
// 验证: AS 自定义 PlayerController 在 PIE 中被 GameMode 正确生成

// AS 脚本:
// class ATestPlayerController : APlayerController
// {
//     UPROPERTY()
//     bool bControllerReady = false;
//
//     UFUNCTION(BlueprintOverride)
//     void BeginPlay()
//     {
//         Super::BeginPlay();
//         bControllerReady = true;
//     }
// }

// 地图 World Settings: PlayerController Class = ATestPlayerController

// PIE 验证:
// 1. PIEWorld->GetFirstPlayerController() 是 ATestPlayerController 类型
// 2. bControllerReady == true
```

---

### 6. Timer & 事件在 PIE 中的行为

**地图**: `TimerEventMap`（新建）
**文件**: `Source/AngelscriptProjectTest/Tests/TimerEventMapTests.cpp`

#### 6.1 Timer 在 PIE 真实时间中触发

```cpp
// Test: AngelscriptProject.Map.Timer.PIETimerFiring
// 验证: System::SetTimer 在 PIE 真实时间推进下正确触发

// AS 脚本:
// class ATimerTestActor : AActor
// {
//     UPROPERTY()
//     int32 TimerFireCount = 0;
//
//     UFUNCTION(BlueprintOverride)
//     void BeginPlay()
//     {
//         System::SetTimer(this, n"OnTick", 0.5, true);
//     }
//
//     UFUNCTION()
//     void OnTick() { TimerFireCount += 1; }
// }

// 地图预置: ATimerTestActor 实例

// PIE 验证 (等待 3 秒后):
// TimerFireCount >= 5（0.5s 间隔，3 秒至少 5 次）
```

#### 6.2 Event 广播跨 Actor

```cpp
// Test: AngelscriptProject.Map.Timer.EventBroadcastCrossActor
// 验证: AS Event Broadcast 在 PIE 中跨 Actor 正确传递

// AS 脚本:
// event void FOnScored(int32 Points);
//
// class AScoreEmitter : AActor
// {
//     UPROPERTY()
//     FOnScored OnScored;
//     // BeginPlay 中延迟 1 秒后 Broadcast
// }
//
// class AScoreReceiver : AActor
// {
//     UPROPERTY()
//     int32 ReceivedScore = 0;
//     // BeginPlay 中查找 AScoreEmitter 并绑定 OnScored
// }

// 地图预置: 1 个 AScoreEmitter + 2 个 AScoreReceiver

// PIE 验证 (2 秒后):
// 两个 Receiver 的 ReceivedScore 都 > 0
```

---

### 7. ConstructionScript 验证

**地图**: `ConstructionScriptMap`（新建）
**文件**: `Source/AngelscriptProjectTest/Tests/ConstructionScriptMapTests.cpp`

#### 7.1 ConstructionScript 在地图加载时执行

```cpp
// Test: AngelscriptProject.Map.Construction.RunOnMapLoad
// 验证: AS ConstructionScript 在地图加载时（编辑器放置）已执行

// AS 脚本:
// class AConstructionTestActor : AActor
// {
//     UPROPERTY(EditAnywhere)
//     int32 TileCount = 4;
//
//     UPROPERTY()
//     int32 ConstructionRunCount = 0;
//
//     UFUNCTION(BlueprintOverride)
//     void ConstructionScript()
//     {
//         ConstructionRunCount += 1;
//     }
// }

// 地图预置: AConstructionTestActor 实例，TileCount 改为 6

// PIE 验证:
// 1. ConstructionRunCount >= 1（编辑器放置时已执行）
// 2. TileCount == 6（编辑器覆盖值保留）
```

---

### 8. Subsystem 运行时行为

**地图**: `SubsystemTestMap`（新建）
**文件**: `Source/AngelscriptProjectTest/Tests/SubsystemMapTests.cpp`

#### 8.1 WorldSubsystem 在 PIE 中的生命周期

```cpp
// Test: AngelscriptProject.Map.Subsystem.WorldSubsystemInPIE
// 验证: AS WorldSubsystem 在 PIE 启动/关闭时 Initialize/Deinitialize 正确调用

// AS 脚本:
// class UTestWorldSubsystem : UScriptWorldSubsystem
// {
//     UPROPERTY()
//     bool bInitialized = false;
//
//     UFUNCTION(BlueprintOverride)
//     void Initialize(USubsystemCollectionBase Collection)
//     {
//         bInitialized = true;
//     }
// }

// PIE 验证:
// 1. 在 PIE World 上 GetSubsystem<UTestWorldSubsystem>() 非 null
// 2. bInitialized == true
```

#### 8.2 脚本 Actor 访问 WorldSubsystem

```cpp
// Test: AngelscriptProject.Map.Subsystem.ActorAccessSubsystem
// 验证: AS Actor 在 BeginPlay 中能正确获取并使用 WorldSubsystem

// AS 脚本:
// class ASubsystemUserActor : AActor
// {
//     UPROPERTY()
//     int32 SubsystemValue = -1;
//
//     UFUNCTION(BlueprintOverride)
//     void BeginPlay()
//     {
//         auto Sub = UTestWorldSubsystem::Get(this);
//         if (Sub != nullptr)
//             SubsystemValue = Sub.SomeValue;
//     }
// }

// PIE 验证:
// SubsystemValue != -1（成功从 Subsystem 读取）
```

---

### 9. 网络 / 多 PIE 测试

**地图**: `NetworkTestMap` / `MultiPIETestMap`（新建）
**文件**: `Source/AngelscriptProjectTest/Tests/NetworkMapTests.cpp`

#### 9.1 属性复制验证

```cpp
// Test: AngelscriptProject.Map.Network.PropertyReplication
// 验证: UPROPERTY(Replicated) 在 Client-Server PIE 中正确同步

// 需要使用插件 IntegrationTest 框架（PIE_Client 模式自带 Server + Client）

// AS 脚本:
// class AReplicatedActor : AActor
// {
//     UPROPERTY(Replicated)
//     int32 SyncedValue = 0;
//
//     default bReplicates = true;
//
//     UFUNCTION(BlueprintOverride)
//     void BeginPlay()
//     {
//         if (HasAuthority())
//             SyncedValue = 42;
//     }
// }

// 地图预置: AReplicatedActor 实例

// PIE 验证:
// Server World: SyncedValue == 42
// Client World: SyncedValue == 42（复制成功）
```

#### 9.2 RPC 调用验证

```cpp
// Test: AngelscriptProject.Map.Network.RPCExecution
// 验证: Server/Client/NetMulticast RPC 在 PIE 中正确路由

// AS 脚本:
// class ARPCTestActor : AActor
// {
//     UPROPERTY(Replicated)
//     int32 ServerCallCount = 0;
//
//     UPROPERTY(Replicated)
//     int32 ClientCallCount = 0;
//
//     default bReplicates = true;
//
//     UFUNCTION(Server)
//     void ServerDoSomething()
//     {
//         ServerCallCount += 1;
//     }
//
//     UFUNCTION(Client)
//     void ClientNotify()
//     {
//         ClientCallCount += 1;
//     }
// }

// PIE 验证:
// Client 调用 ServerDoSomething() → Server 的 ServerCallCount == 1
// Server 调用 ClientNotify() → Client 的 ClientCallCount == 1
```

#### 9.3 多客户端测试（Multi-PIE）

```cpp
// Test: AngelscriptProject.Map.Network.MultiClient
// 验证: 多个 PIE 客户端能正确接收复制

// 需要配置: NumClients = 2

// PIE 验证:
// 1. Server World 有 2 个 PlayerController
// 2. 两个 Client World 各有自己的 PlayerController
// 3. Replicated Actor 在所有 World 中状态一致

// 实现: 通过 ULevelEditorPlaySettings 设置 PlayNumberOfClients = 2
ULevelEditorPlaySettings* Settings = GetMutableDefault<ULevelEditorPlaySettings>();
Settings->SetPlayNumberOfClients(2);
Settings->SetPlayNetMode(EPlayNetMode::PIE_Client);
// ... FStartPIECommand ...
// 然后遍历所有 PIE WorldContext 验证
```

---

### 10. SpawnActor 运行时验证

**地图**: `SpawnTestMap`（新建）
**文件**: `Source/AngelscriptProjectTest/Tests/SpawnActorMapTests.cpp`

#### 10.1 运行时 Spawn AS Actor

```cpp
// Test: AngelscriptProject.Map.Spawn.RuntimeSpawnScriptActor
// 验证: PIE 中通过脚本 SpawnActor 创建的 AS Actor 正确初始化

// AS 脚本:
// class ASpawnerActor : AActor
// {
//     UPROPERTY()
//     int32 SpawnedCount = 0;
//
//     UFUNCTION(BlueprintOverride)
//     void BeginPlay()
//     {
//         for (int i = 0; i < 5; i++)
//         {
//             AActor Spawned = SpawnActor(ASpawnedTarget,
//                 GetActorLocation() + FVector(i * 200, 0, 0));
//             if (Spawned != nullptr)
//                 SpawnedCount += 1;
//         }
//     }
// }
//
// class ASpawnedTarget : AActor
// {
//     UPROPERTY()
//     bool bAlive = true;
//
//     UFUNCTION(BlueprintOverride)
//     void BeginPlay() { bAlive = true; }
// }

// PIE 验证 (2 秒后):
// 1. SpawnerActor.SpawnedCount == 5
// 2. PIE World 中有 5 个 ASpawnedTarget 实例
// 3. 所有 ASpawnedTarget.bAlive == true
```

---

### 11. Widget 在 PIE 中的创建

**地图**: `WidgetTestMap`（新建）
**文件**: `Source/AngelscriptProjectTest/Tests/WidgetMapTests.cpp`

#### 11.1 AS Widget 添加到 Viewport

```cpp
// Test: AngelscriptProject.Map.Widget.AddToViewport
// 验证: AS 脚本创建的 UUserWidget 能成功添加到 PIE Viewport

// AS 脚本:
// class AWidgetSpawner : AActor
// {
//     UPROPERTY()
//     bool bWidgetCreated = false;
//
//     UFUNCTION(BlueprintOverride)
//     void BeginPlay()
//     {
//         auto PC = GetWorld().GetFirstPlayerController();
//         if (PC != nullptr)
//         {
//             // 创建 Widget
//             auto Widget = CreateWidget(PC, UTestHudWidget);
//             if (Widget != nullptr)
//             {
//                 Widget.AddToViewport();
//                 bWidgetCreated = true;
//             }
//         }
//     }
// }

// PIE 验证:
// bWidgetCreated == true
```

---

### 12. AI 行为树在 PIE 中运行

**地图**: `AITestMap`（新建，需要 NavMesh）
**文件**: `Source/AngelscriptProjectTest/Tests/AIMapTests.cpp`

#### 12.1 AS BT Task 执行

```cpp
// Test: AngelscriptProject.Map.AI.BTTaskExecution
// 验证: AS 定义的 BT Task 在 PIE 中通过 BehaviorTree 正确执行

// 地图预置:
// - NavMeshBoundsVolume（覆盖测试区域）
// - AAITestPawn: 使用 BehaviorTree，包含 AS 定义的 UBTTask_ScriptTest
// - AIController 蓝图: 运行 BT

// PIE 验证 (3 秒后):
// 1. AI Pawn 存在且有 AIController
// 2. BT Task 的 ExecuteAI 被调用（通过脚本属性 bTaskExecuted == true）
```

---

## 辅助工具函数

建议在 `Source/AngelscriptProjectTest/Tests/` 下创建共享头文件：

```cpp
// Source/AngelscriptProjectTest/Tests/MapTestHelpers.h

#pragma once
#include "Engine/World.h"
#include "Engine/Engine.h"
#include "EngineUtils.h"

namespace MapTestHelpers
{
    // 查找 PIE World
    inline UWorld* FindPIEWorld()
    {
        if (GEditor && GEditor->GetPIEWorldContext())
            return GEditor->GetPIEWorldContext()->World();

        for (const FWorldContext& Ctx : GEngine->GetWorldContexts())
        {
            if (Ctx.WorldType == EWorldType::PIE && Ctx.World())
                return Ctx.World();
        }
        return nullptr;
    }

    // 查找所有 PIE World（多客户端场景）
    inline TArray<UWorld*> FindAllPIEWorlds()
    {
        TArray<UWorld*> Worlds;
        for (const FWorldContext& Ctx : GEngine->GetWorldContexts())
        {
            if (Ctx.WorldType == EWorldType::PIE && Ctx.World())
                Worlds.Add(Ctx.World());
        }
        return Worlds;
    }

    // 在 PIE World 中按类名查找 Actor
    inline AActor* FindActorOfScriptClass(UWorld* World, const TCHAR* ClassName)
    {
        UClass* Class = FindFirstObject<UClass>(ClassName, EFindFirstObjectOptions::None);
        if (!Class || !World) return nullptr;

        for (TActorIterator<AActor> It(World); It; ++It)
        {
            if (It->GetClass()->IsChildOf(Class))
                return *It;
        }
        return nullptr;
    }

    // 收集 PIE World 中指定类的所有 Actor
    inline TArray<AActor*> FindAllActorsOfScriptClass(UWorld* World, const TCHAR* ClassName)
    {
        TArray<AActor*> Result;
        UClass* Class = FindFirstObject<UClass>(ClassName, EFindFirstObjectOptions::None);
        if (!Class || !World) return Result;

        for (TActorIterator<AActor> It(World); It; ++It)
        {
            if (It->GetClass()->IsChildOf(Class))
                Result.Add(*It);
        }
        return Result;
    }

    // 读取 AS Actor 的 int32 属性
    inline bool ReadIntProperty(AActor* Actor, const TCHAR* PropName, int32& OutValue)
    {
        FIntProperty* Prop = FindFProperty<FIntProperty>(Actor->GetClass(), PropName);
        if (!Prop) return false;
        OutValue = Prop->GetPropertyValue_InContainer(Actor);
        return true;
    }

    // 读取 AS Actor 的 bool 属性
    inline bool ReadBoolProperty(AActor* Actor, const TCHAR* PropName, bool& OutValue)
    {
        FBoolProperty* Prop = FindFProperty<FBoolProperty>(Actor->GetClass(), PropName);
        if (!Prop) return false;
        OutValue = Prop->GetValuePropertyAddress_InContainer(Actor) != nullptr;
        return true;
    }
}
```

---

## 优先级排序

| 优先级 | 地图 & 测试领域 | 新建地图 | 测试数 | 理由 |
|--------|----------------|---------|--------|------|
| **P0** | Actor 生命周期 (ActorTestMap 已有) | 0 | 3 | 基础验证，地图已存在 |
| **P0** | 组件层级 (ComponentHierarchyMap) | 1 | 2 | DefaultComponent 核心模式 |
| **P0** | GameMode & PlayerController | 1 | 2 | 游戏框架基础 |
| **P1** | Overlap & 碰撞 | 1 | 2 | 物理交互核心 |
| **P1** | Timer & 事件 PIE 行为 | 1 | 2 | 运行时行为验证 |
| **P1** | SpawnActor 运行时 | 1 | 1 | 动态对象管理 |
| **P1** | Subsystem PIE 行为 | 1 | 2 | 全局系统 |
| **P2** | 物理模拟 | 1 | 2 | 物理引擎集成 |
| **P2** | ConstructionScript 地图级 | 1 | 1 | 编辑器工作流 |
| **P2** | Widget PIE | 1 | 1 | UI 系统 |
| **P2** | 网络复制 (Client-Server) | 1 | 2 | 网络同步 |
| **P3** | AI & BT | 1 | 1 | AI 系统 |
| **P3** | 多客户端 Multi-PIE | 1 | 1 | 高级网络 |

**总计**: 约 12 张新测试地图 + 22 个地图级测试用例。

## 验证方式

```powershell
# 运行所有项目级地图测试
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 `
    -TestPrefix "AngelscriptProject.Map." -Label map-tests -TimeoutMs 600000

# 运行特定地图测试
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 `
    -TestPrefix "AngelscriptProject.Map.Actor." -Label map-actor -TimeoutMs 300000
```

## 与现有测试的关系

| 测试层 | 位置 | 依赖 | 用途 |
|--------|------|------|------|
| **C++ 单元测试** | `AngelscriptTest/` (插件) | 无 Content | 语言特性、Bind 接口、编译器 |
| **内存 World 测试** | `AngelscriptTest/Functional/` (插件) | FAngelscriptTestWorld | Actor 生命周期、组件、委托 |
| **地图 PIE 测试** ← **新增** | `AngelscriptProjectTest/Tests/` (项目) | Content/Test/*.umap | 真实运行时、编辑器集成、物理碰撞、网络 |
| **AS 集成测试** | 通过 IntegrationTest 框架 | IntegrationTestMapRoot | AS 脚本全流程、多 World |
