# AngelScript 插件快速入门

> **所属前缀**: Guide_
> **适用引擎**: UE 5.7
> **前置条件**: 已编译通过的引擎 + Angelscript 插件

---

## AngelScript 是什么

AngelScript 是一门轻量级脚本语言，由 [Hazelight](http://hazelight.se)（《双人成行》《分裂小说》开发商）集成到 Unreal Engine 中。它让你可以像写 C++ 一样写游戏逻辑，但不用等编译、不用重启编辑器——**保存即生效**。

核心优势：

- **即时热重载** — 保存 `.as` 文件后，编辑器立即反映变更，无需重启
- **熟悉的语法** — 与 UE C++ 高度相似，对 UE 程序员几乎零学习成本
- **Blueprint 互操作** — 脚本类可以被 Blueprint 继承、调用、重写事件
- **调试支持** — VS Code 扩展提供断点、调用栈、变量检查

---

## 环境准备

### 引擎与插件

本项目使用 UE 5.7 源码版本，Angelscript 插件位于 `Plugins/Angelscript/`。

插件在 `Angelscript.uplugin` 中设置了 `EnabledByDefault: true`，不需要在 `.uproject` 中手动启用。

插件包含三个模块：

```
Angelscript.uplugin
├── AngelscriptRuntime       // 运行时核心（Runtime, PostDefault）
├── AngelscriptEditor        // 编辑器支持（Editor, PostDefault）
└── AngelscriptTest          // 测试模块（Editor, PostDefault）
```

### VS Code 扩展（推荐）

安装 [Unreal Angelscript](https://marketplace.visualstudio.com/items?itemName=Hazelight.unreal-angelscript) VS Code 扩展，获得：

- 代码自动补全与错误诊断
- 符号重命名与查找引用
- 语义高亮
- 断点调试

安装后，在编辑器中可以通过 `Tools → Open Angelscript workspace` 快速在 VS Code 中打开 `Script/` 目录。

### 构建项目

首次编译请参考 `Documents/Guides/Build.md`。标准构建入口：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label agent-build -TimeoutMs 180000
```

---

## 项目结构速览

```
AngelscriptProject/
├── Script/                            // AS 脚本根目录（引擎自动扫描）
│   ├── Game/Example_Actor.as          // Actor 快速示例
│   ├── Examples/                      // 分类示例集合
│   │   ├── Core/                      //   基础语法与 UE 模式（20 个）
│   │   ├── EnhancedInput/             //   UE5 增强输入（3 个）
│   │   └── Extended/                  //   扩展能力（5 个）
│   └── Tests/                         // AS 测试脚本
├── Plugins/Angelscript/               // 插件源码
├── Source/AngelscriptProject/         // 宿主项目 C++ 模块（最小化）
└── Config/                            // UE 配置
```

**关键约定**：所有 `.as` 文件放在 `Script/` 目录下，引擎启动时自动发现并编译。无需手动注册。

---

## 案例 1：Hello Actor — 第一个脚本

在 `Script/` 下新建 `HelloActor.as`：

```angelscript
class AHelloActor : AActor
{
    UPROPERTY()
    float CountdownDuration = 5.0;

    float CurrentTimer = 0.0;
    bool bCountdownActive = false;

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        CurrentTimer = CountdownDuration;
        bCountdownActive = true;
        Print("HelloActor: countdown started!");
    }

    UFUNCTION(BlueprintOverride)
    void Tick(float DeltaSeconds)
    {
        if (bCountdownActive)
        {
            CurrentTimer -= DeltaSeconds;
            if (CurrentTimer <= 0.0)
            {
                Print("HelloActor: countdown finished!");
                bCountdownActive = false;
            }
        }
    }
};
```

**试一试：**

1. 保存文件，切换到编辑器，脚本自动编译
2. `Place Actors` 面板搜索 "Hello Actor"，拖入关卡
3. 点击 Play，5 秒后屏幕显示 "HelloActor: countdown finished!"
4. 在 Details 面板修改 `CountdownDuration`——它是 `UPROPERTY()`，编辑器直接可编辑

---

## 案例 2：可移动物体 — Tick 驱动与 default 关键字

```angelscript
class AMovingPlatform : AActor
{
    UPROPERTY(DefaultComponent, RootComponent)
    USceneComponent SceneRoot;

    UPROPERTY(DefaultComponent, Attach = SceneRoot)
    UStaticMeshComponent Mesh;

    UPROPERTY()
    float Speed = 200.0;

    UPROPERTY()
    float Distance = 300.0;

    // default 覆盖父类属性的默认值，等价于 C++ 构造函数中的赋值
    default bReplicates = true;

    FVector StartLocation;
    float Direction = 1.0;

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        StartLocation = ActorLocation;
    }

    UFUNCTION(BlueprintOverride)
    void Tick(float DeltaSeconds)
    {
        FVector Offset = FVector(Speed * Direction * DeltaSeconds, 0.0, 0.0);
        AddActorWorldOffset(Offset);

        float Traveled = (ActorLocation - StartLocation).Size();
        if (Traveled >= Distance)
            Direction *= -1.0;
    }
};
```

**要点：**

- `DefaultComponent` + `RootComponent` — 自动创建组件并设为根
- `Attach = SceneRoot` — 声明组件层级关系
- `default bReplicates = true` — 等价于 C++ 构造函数中的 `bReplicates = true`

---

## 案例 3：自定义 Component — 可复用行为模块

Component 是 UE 中实现行为复用的核心单元。用 AngelScript 可以快速编写自定义 Component，挂载到任意 Actor 上：

### ActorComponent — 纯逻辑组件

```angelscript
// 旋转组件：挂载到任何 Actor 上自动旋转
class UAutoRotateComponent : UActorComponent
{
    UPROPERTY(Category = "Rotation")
    float DegreesPerSecond = 90.0;

    UPROPERTY(Category = "Rotation")
    FRotator RotationAxis = FRotator(0.0, 1.0, 0.0);

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        // ActorComponent 默认不 Tick，需要手动开启
        SetComponentTickEnabled(true);
    }

    UFUNCTION(BlueprintOverride)
    void Tick(float DeltaTime)
    {
        AActor Owner = GetOwner();
        if (Owner == nullptr) return;

        FRotator DeltaRot = RotationAxis * DegreesPerSecond * DeltaTime;
        Owner.AddActorWorldRotation(DeltaRot);
    }
};
```

### SceneComponent — 带 Transform 的组件

```angelscript
// 浮动效果组件：让挂载点上下浮动
class UFloatingComponent : USceneComponent
{
    UPROPERTY(Category = "Float")
    float Amplitude = 50.0;

    UPROPERTY(Category = "Float")
    float Frequency = 1.0;

    FVector InitialRelativeLocation;
    float TimeAccumulator = 0.0;

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        InitialRelativeLocation = RelativeLocation;
    }

    UFUNCTION(BlueprintOverride)
    void Tick(float DeltaTime)
    {
        TimeAccumulator += DeltaTime;
        float Offset = Math::Sin(TimeAccumulator * Frequency * 2.0 * 3.14159) * Amplitude;

        FVector NewLocation = InitialRelativeLocation;
        NewLocation.Z += Offset;
        SetRelativeLocation(NewLocation);
    }
};
```

### 在 Actor 中使用自定义 Component

```angelscript
class AFloatingCube : AActor
{
    UPROPERTY(DefaultComponent, RootComponent)
    USceneComponent SceneRoot;

    UPROPERTY(DefaultComponent, Attach = SceneRoot)
    UStaticMeshComponent Mesh;

    // 挂载自定义的浮动组件
    UPROPERTY(DefaultComponent, Attach = SceneRoot)
    UFloatingComponent FloatingEffect;

    // 挂载自定义的旋转组件
    UPROPERTY(DefaultComponent)
    UAutoRotateComponent AutoRotate;
};
```

**要点：**

- `UActorComponent` — 纯逻辑，无 Transform，通过 `GetOwner()` 访问所属 Actor
- `USceneComponent` — 有 Transform，可挂载子组件，参与场景层级
- `DefaultComponent` 在 Actor 中声明即自动创建，编辑器中可见可编辑
- Component 的 `BeginPlay` / `Tick` 同样用 `BlueprintOverride` 重写

---

## 案例 4：default 语句 — 覆盖默认值

`default` 关键字等价于 C++ 构造函数中的赋值，用来设置父类属性和子对象的默认值。这是声明式配置，不需要写任何函数体。

### 覆盖父类属性

```angelscript
class ANetworkedEnemy : AActor
{
    // 覆盖 AActor 父类的属性默认值
    default bReplicates = true;
    default bAlwaysRelevant = true;

    // 可以调用方法（如 TArray.Add）
    default Tags.Add(n"Enemy");
    default Tags.Add(n"Targetable");
};
```

### 配置 DefaultComponent 的属性

`default` 可以直接设置组件的属性，无需在 BeginPlay 中赋值：

```angelscript
class AShieldedCharacter : AActor
{
    UPROPERTY(DefaultComponent, RootComponent)
    USceneComponent SceneRoot;

    UPROPERTY(DefaultComponent)
    USkeletalMeshComponent CharacterMesh;

    UPROPERTY(DefaultComponent)
    UStaticMeshComponent ShieldMesh;

    // 通过 default 配置组件属性
    default CharacterMesh.RelativeLocation = FVector(0.0, 0.0, -90.0);
    default CharacterMesh.RelativeRotation = FRotator(0.0, -90.0, 0.0);

    // 隐藏护盾 Mesh，只在受伤时显示
    default ShieldMesh.bHiddenInGame = true;
    // 调用方法也可以
    default ShieldMesh.SetCollisionEnabled(ECollisionEnabled::NoCollision);
};
```

### 子类覆盖父类脚本属性

```angelscript
class APickupBase : AActor
{
    UPROPERTY(Category = "Pickup")
    int PickupValue = 10;

    UPROPERTY(Category = "Pickup")
    FString PickupName = "Generic";
};

class AGoldPickup : APickupBase
{
    // 子类中用 default 覆盖父类脚本定义的属性
    default PickupValue = 100;
    default PickupName = "Gold Coin";
};

class ASilverPickup : APickupBase
{
    default PickupValue = 50;
    default PickupName = "Silver Coin";
};
```

### 配置 AI 行为树节点

```angelscript
class UBTTask_PatrolToPoint : UBTTask_BlueprintBase
{
    // 在编辑器行为树中显示的节点名称
    default NodeName = "Patrol To Point";

    UPROPERTY(Category = "Patrol")
    float AcceptanceRadius = 100.0;

    UFUNCTION(BlueprintOverride)
    void ExecuteAI(AAIController Controller, APawn Pawn)
    {
        Print(f"Patrolling with radius {AcceptanceRadius}");
    }
};
```

**要点：**

- `default 属性 = 值` — 覆盖父类或自身声明的 UPROPERTY 默认值
- `default 组件.属性 = 值` — 设置 DefaultComponent 的属性
- `default 组件.方法(参数)` — 在构造时调用组件方法
- `default 数组.Add(值)` — 向容器属性追加元素
- `default` 是声明式的，不在任何函数内，在类体顶层书写

---

## 案例 5：重叠检测 — 事件绑定

### Actor 级别重叠

```angelscript
class APickupItem : AActor
{
    UPROPERTY(DefaultComponent, RootComponent)
    USphereComponent CollisionSphere;

    UFUNCTION(BlueprintOverride)
    void ActorBeginOverlap(AActor OtherActor)
    {
        Print(f"Picked up by: {OtherActor.Name}");
        DestroyActor();
    }
};
```

### Component 级别重叠

当需要更精细的碰撞信息时，绑定 Component 事件：

```angelscript
class ATriggerZone : AActor
{
    UPROPERTY(DefaultComponent, RootComponent)
    UBoxComponent TriggerBox;

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        // 绑定 Component 的 OnBeginOverlap 事件
        TriggerBox.OnComponentBeginOverlap.AddUFunction(this, n"OnEnterZone");
        TriggerBox.OnComponentEndOverlap.AddUFunction(this, n"OnLeaveZone");
    }

    UFUNCTION()
    void OnEnterZone(
        UPrimitiveComponent OverlappedComponent, AActor OtherActor,
        UPrimitiveComponent OtherComp, int OtherBodyIndex,
        bool bFromSweep, const FHitResult&in Hit)
    {
        Print(f"{OtherActor.Name} entered the trigger zone");
    }

    UFUNCTION()
    void OnLeaveZone(
        UPrimitiveComponent OverlappedComponent, AActor OtherActor,
        UPrimitiveComponent OtherComp, int OtherBodyIndex)
    {
        Print(f"{OtherActor.Name} left the trigger zone");
    }
};
```

**要点：**

- Actor 级别用 `BlueprintOverride` 直接重写 `ActorBeginOverlap`
- Component 级别通过 `AddUFunction` 绑定，被绑定的函数必须是 `UFUNCTION()`
- `n"FuncName"` 是编译期 `FName` 字面量，性能优于运行时构造

---

## 案例 6：定时器 — 延迟与循环

```angelscript
class ASpawner : AActor
{
    UPROPERTY()
    float SpawnInterval = 2.0;

    FTimerHandle SpawnTimerHandle;

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        // 设置循环定时器，每 SpawnInterval 秒触发一次
        SpawnTimerHandle = System::SetTimer(
            this, n"OnSpawnTimer", SpawnInterval, bLooping = true
        );
    }

    UFUNCTION()
    void OnSpawnTimer()
    {
        Print(f"Spawner triggered at {System::GetGameTimeInSeconds() :.1f}s");
        // 在此处放置实际的生成逻辑
    }

    // 外部可调用：暂停/恢复生成
    UFUNCTION()
    void ToggleSpawning()
    {
        if (System::IsTimerPausedHandle(SpawnTimerHandle))
            System::UnPauseTimerHandle(SpawnTimerHandle);
        else
            System::PauseTimerHandle(SpawnTimerHandle);
    }

    UFUNCTION(BlueprintOverride)
    void EndPlay(EEndPlayReason Reason)
    {
        System::ClearAndInvalidateTimerHandle(SpawnTimerHandle);
    }
};
```

**要点：**

- `System::SetTimer` 返回 `FTimerHandle`，可用于暂停/恢复/取消
- 定时器回调函数必须是 `UFUNCTION()`
- 同一函数只能有一个定时器，重复设置会覆盖前一个

---

## 案例 7：委托与事件 — 自定义回调

```angelscript
// 单播委托（等价于 DECLARE_DYNAMIC_DELEGATE）
delegate void FOnScoreChanged(int NewScore);

// 多播事件（等价于 DECLARE_DYNAMIC_MULTICAST_DELEGATE）
event void FOnGameOver(AActor Winner);

class AScoreManager : AActor
{
    // 事件作为 UPROPERTY 暴露给 Blueprint
    UPROPERTY(Category = "Events")
    FOnGameOver OnGameOver;

    int CurrentScore = 0;

    UFUNCTION()
    void AddScore(int Amount)
    {
        CurrentScore += Amount;
        Print(f"Score: {CurrentScore}");

        if (CurrentScore >= 100)
        {
            // Broadcast 调用所有绑定的监听者
            OnGameOver.Broadcast(this);
        }
    }

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        // 绑定自身的函数到事件
        OnGameOver.AddUFunction(this, n"HandleGameOver");
    }

    UFUNCTION()
    void HandleGameOver(AActor Winner)
    {
        Print(f"Game Over! Winner: {Winner.Name}");
    }
};
```

**要点：**

- `delegate` = 单播（只能绑定一个），用 `BindUFunction` / `Execute`
- `event` = 多播（可绑定多个），用 `AddUFunction` / `Broadcast`
- `Broadcast` 即使没有绑定也不会报错，无需先检查 `IsBound`
- 作为 `UPROPERTY()` 的 event 可以在 Blueprint 中被绑定

---

## 案例 8：自定义结构体

```angelscript
struct FWeaponData
{
    UPROPERTY()
    FString Name = "Pistol";

    UPROPERTY()
    float Damage = 25.0;

    UPROPERTY()
    float FireRate = 0.5;

    // 没有 UPROPERTY 的字段对 Blueprint 不可见，但脚本内可用
    int InternalAmmoCount = 12;
};

class AWeaponHolder : AActor
{
    UPROPERTY()
    FWeaponData EquippedWeapon;

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        Print(f"Equipped: {EquippedWeapon.Name}, Damage: {EquippedWeapon.Damage}");
    }

    // C++ 定义的结构体同样可以直接使用
    UPROPERTY()
    FHitResult LastHitResult;
};
```

**要点：**

- `struct` 自动注册到 UE 反射系统
- 修改 struct 的任何字段（不管是否 UPROPERTY）都需要全量重编译
- C++ 侧定义的结构体（如 `FHitResult`）可直接使用

---

## 案例 9：构造脚本 — 编辑器时逻辑

```angelscript
class AProceduralFence : AActor
{
    UPROPERTY(Category = "Fence")
    int NumPosts = 5;

    UPROPERTY(Category = "Fence")
    float Spacing = 200.0;

    UPROPERTY(BlueprintReadOnly, NotEditable, Category = "Fence")
    float TotalLength;

    // ConstructionScript 在编辑器中修改属性时自动运行
    UFUNCTION()
    void ConstructionScript()
    {
        TotalLength = (NumPosts - 1) * Spacing;
        // 可在此动态创建组件、设置 Mesh 等
    }
};
```

**要点：**

- `ConstructionScript` 在编辑器中每次属性变更后自动执行
- 适合计算派生属性、动态创建组件、程序化布局
- `NotEditable` 属性在编辑器中只读，适合展示计算结果

---

## 案例 10：UMG Widget — 脚本化 UI

```angelscript
class UGameHUD : UUserWidget
{
    // BindWidget 自动关联 Widget Blueprint 中同名控件
    UPROPERTY(BindWidget)
    UTextBlock ScoreText;

    UPROPERTY(BindWidget)
    UProgressBar HealthBar;

    int Score = 0;
    float HealthPercent = 1.0;

    UFUNCTION(BlueprintOverride)
    void Construct()
    {
        UpdateDisplay();
    }

    UFUNCTION(BlueprintOverride)
    void Tick(FGeometry MyGeometry, float DeltaTime)
    {
        UpdateDisplay();
    }

    void UpdateDisplay()
    {
        ScoreText.Text = FText::FromString(f"Score: {Score}");
        HealthBar.SetPercent(HealthPercent);
    }

    // 暴露给其他脚本调用
    UFUNCTION()
    void SetScore(int NewScore)
    {
        Score = NewScore;
    }

    UFUNCTION()
    void SetHealth(float Percent)
    {
        HealthPercent = Math::Clamp(Percent, 0.0, 1.0);
    }
};

// 全局函数：将 HUD 添加到玩家视口
UFUNCTION(Category = "UI")
void ShowGameHUD(APlayerController Player, TSubclassOf<UGameHUD> WidgetClass)
{
    UUserWidget Widget = WidgetBlueprint::CreateWidget(WidgetClass, Player);
    Widget.AddToViewport();
}
```

**使用方式：**

1. 在编辑器中创建一个 Widget Blueprint，将 Parent Class 设为 `UGameHUD`
2. 在 Widget Blueprint 中添加名为 `ScoreText`（TextBlock）和 `HealthBar`（ProgressBar）的控件
3. `BindWidget` 会在运行时自动将控件引用绑定到脚本属性

---

## 案例 11：子系统 — 全局管理器

子系统是不需要手动创建的单例，引擎自动管理其生命周期：

```angelscript
// 世界子系统：每个 World 一个实例，关卡切换时销毁重建
UCLASS()
class UScoreSubsystem : UScriptWorldSubsystem
{
    UPROPERTY(BlueprintReadOnly, Category = "Score")
    int TotalScore = 0;

    UFUNCTION(BlueprintOverride)
    void Initialize()
    {
        TotalScore = 0;
        Log("ScoreSubsystem: Initialized");
    }

    UFUNCTION()
    void AddScore(int Amount)
    {
        TotalScore += Amount;
        Print(f"Total Score: {TotalScore}");
    }
};

// 游戏实例子系统：跨关卡持久存在
UCLASS()
class UPlayerProgressSubsystem : UScriptGameInstanceSubsystem
{
    UPROPERTY(BlueprintReadOnly, Category = "Progress")
    int LevelsCompleted = 0;

    UFUNCTION(BlueprintOverride)
    void Initialize()
    {
        Log(f"PlayerProgress: Initialized, completed levels = {LevelsCompleted}");
    }

    UFUNCTION()
    void CompleteLevel()
    {
        LevelsCompleted += 1;
    }
};
```

**可用子系统基类：**

| 基类 | 生命周期 | 典型用途 |
|------|---------|---------|
| `UScriptWorldSubsystem` | 跟随 World | 关卡计分、怪物管理器 |
| `UScriptGameInstanceSubsystem` | 跟随 GameInstance | 跨关卡存档、成就 |
| `UScriptLocalPlayerSubsystem` | 跟随 LocalPlayer | 本地玩家设置 |
| `UScriptEngineSubsystem` | 引擎生命周期 | 全局工具、编辑器扩展 |

---

## 案例 12：继承与多态

```angelscript
// 基类：定义可被重写的事件接口
class AGameCharacter : AActor
{
    UPROPERTY(Category = "Health")
    float MaxHealth = 100.0;

    UPROPERTY(BlueprintReadOnly, Category = "Health")
    float CurrentHealth = 100.0;

    // BlueprintEvent：子类可重写，Blueprint 也可重写
    UFUNCTION(BlueprintEvent)
    float ApplyDamage(float Amount)
    {
        CurrentHealth = Math::Max(CurrentHealth - Amount, 0.0);
        return CurrentHealth;
    }

    UFUNCTION(BlueprintEvent)
    bool IsAlive()
    {
        return CurrentHealth > 0.0;
    }
};

// 派生类：重写基类行为
class AEnemyCharacter : AGameCharacter
{
    UFUNCTION(BlueprintOverride)
    float ApplyDamage(float Amount)
    {
        // 敌人受到双倍伤害
        CurrentHealth = Math::Max(CurrentHealth - Amount * 2.0, 0.0);
        Print(f"[Enemy] took {Amount * 2.0} damage! HP: {CurrentHealth}");

        if (CurrentHealth <= 0.0)
            Print(f"{GetName()} has been defeated!");

        return CurrentHealth;
    }
};

// 全局函数：多态调用
UFUNCTION()
void DamageTarget(AGameCharacter Target, float Damage)
{
    if (Target == nullptr)
        return;

    Target.ApplyDamage(Damage);   // 自动调用正确的重写版本
    if (!Target.IsAlive())
        Print(f"{Target.GetName()} is dead!");
}
```

**要点：**

- `BlueprintEvent` — 声明可被子类和 Blueprint 重写的虚函数
- `BlueprintOverride` — 在子类中重写父类的 BlueprintEvent
- 脚本内部的普通方法（无 UFUNCTION）也支持继承重写

---

## 案例 13：网络复制与 RPC

```angelscript
class ANetworkPlayer : AActor
{
    default bReplicates = true;

    // Replicated：服务器变更自动同步到客户端
    UPROPERTY(Replicated, Category = "Network")
    int Score = 0;

    // ReplicatedUsing：变更时客户端自动调用回调
    UPROPERTY(ReplicatedUsing = OnRep_Health, Category = "Network")
    float Health = 100.0;

    UFUNCTION()
    void OnRep_Health()
    {
        Print(f"Health synced: {Health}");
        if (Health <= 0.0)
            Print("Player died on client!");
    }

    // Server RPC：客户端调用 → 服务器执行
    UFUNCTION(Server)
    void ServerRequestAttack()
    {
        Score += 10;
        ClientConfirmHit(Score);
    }

    // Client RPC：服务器调用 → 拥有者客户端执行
    UFUNCTION(Client)
    void ClientConfirmHit(int TotalScore)
    {
        Print(f"Hit confirmed! Score: {TotalScore}");
    }

    // NetMulticast RPC：服务器调用 → 所有客户端执行
    UFUNCTION(NetMulticast, Unreliable)
    void MulticastPlayEffect()
    {
        Print("Playing effect on all clients");
    }

    // 带验证的 Server RPC
    UFUNCTION(Server, WithValidation)
    void ServerUseItem(int ItemId)
    {
        Print(f"Server: Item {ItemId} used");
    }

    UFUNCTION()
    bool ServerUseItem_Validate(int ItemId)
    {
        return ItemId > 0 && ItemId < 1000;
    }
};
```

**RPC 速查：**

| 修饰符 | 调用方 | 执行方 | 默认可靠性 |
|--------|--------|--------|-----------|
| `Server` | 客户端 | 服务器 | Reliable |
| `Client` | 服务器 | 拥有者客户端 | Reliable |
| `NetMulticast` | 服务器 | 所有端 | Reliable |
| `Unreliable` | — | — | 不保证到达 |

---

## 案例 14：增强输入 (Enhanced Input)

```angelscript
class APlayerPawn : APawn
{
    // 在编辑器中创建 InputAction 资产后赋值
    UPROPERTY(Category = "Input")
    UInputAction MoveAction;

    UPROPERTY(Category = "Input")
    UInputAction JumpAction;

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        auto EIC = Cast<UEnhancedInputComponent>(GetInputComponent());
        if (EIC == nullptr) return;

        if (MoveAction != nullptr)
        {
            FEnhancedInputActionHandlerDynamicSignature MoveDelegate;
            MoveDelegate.BindUFunction(this, n"OnMove");
            EIC.BindAction(MoveAction, ETriggerEvent::Triggered, MoveDelegate);
        }

        if (JumpAction != nullptr)
        {
            FEnhancedInputActionHandlerDynamicSignature JumpDelegate;
            JumpDelegate.BindUFunction(this, n"OnJump");
            EIC.BindAction(JumpAction, ETriggerEvent::Started, JumpDelegate);
        }
    }

    UFUNCTION()
    void OnMove(FInputActionValue Value, float ElapsedTime,
                FInputActionInstance Instance, UInputAction SourceAction)
    {
        FVector2D Input = Value.GetAxis2D();
        AddMovementInput(FVector(Input.X, Input.Y, 0.0), 1.0);
    }

    UFUNCTION()
    void OnJump(FInputActionValue Value, float ElapsedTime,
                FInputActionInstance Instance, UInputAction SourceAction)
    {
        Print("Jump!", Duration = 3.0);
    }
};
```

**前置条件：** 需要在编辑器中创建 `UInputAction` 和 `UInputMappingContext` 资产。

---

## 案例 15：f-string 格式化

AngelScript 支持类似 Python 的 f-string：

```angelscript
UFUNCTION()
void FormatStringDemo()
{
    float Health = 78.456;
    FVector Position(100.0, 50.0, 25.0);

    // 基础插值
    Print(f"Health: {Health}");

    // 精度控制
    Print(f"Health: {Health :.1f}");              // "Health: 78.5"

    // 调试表达式（自动打印变量名）
    Print(f"{Health =}");                         // "Health = 78.456"
    Print(f"{Health =:.0f}");                     // "Health = 78"

    // 整数格式
    Print(f"Hex: {255 :#x}");                     // "Hex: 0xff"
    Print(f"Binary: {42 :b}");                    // "Binary: 101010"
    Print(f"Padded: {42 :06d}");                  // "Padded: 000042"

    // 对齐
    Print(f"{'Left' :_<20}");                     // "Left________________"
    Print(f"{'Right' :>20}");                     // "               Right"

    // 枚举格式
    Print(f"{ESlateVisibility::Collapsed}");      // "ESlateVisibility::Collapsed (1)"
    Print(f"{ESlateVisibility::Collapsed :n}");   // "Collapsed"

    // 对象嵌入
    Print(f"Position = {Position}");
}
```

---

## 案例 16：TArray 与 TMap 容器

```angelscript
UFUNCTION()
void ContainerDemo()
{
    // ── TArray ──
    TArray<FString> Names;
    Names.Add("Alice");
    Names.Add("Bob");
    Names.Add("Charlie");

    // range-for 遍历
    for (FString Name : Names)
        Log(f"Name: {Name}");

    // 查找与删除
    if (Names.Contains("Bob"))
    {
        int Index = Names.FindIndex("Bob");
        Names.RemoveAt(Index);
    }

    // ── TMap ──
    TMap<FString, int> ScoreBoard;
    ScoreBoard.Add("Alice", 100);
    ScoreBoard.Add("Bob", 85);

    // 查找（返回引用）
    int AliceScore = 0;
    if (ScoreBoard.Find("Alice", AliceScore))
        Log(f"Alice's score: {AliceScore}");

    // FindOrAdd：不存在则插入默认值
    int& CharlieScore = ScoreBoard.FindOrAdd("Charlie");
    CharlieScore = 72;

    // 遍历 key-value
    for (auto Pair : ScoreBoard)
        Log(f"{Pair.Key}: {Pair.Value}");
}
```

---

## 与 Blueprint 互操作

脚本类天然支持作为 Blueprint 的父类：

1. 在 Content Browser 中 `Add → Blueprint Class`
2. 搜索你的脚本类名（如 "HelloActor"）作为 Parent Class
3. 在 Blueprint 中可以：
   - 调用脚本定义的 `UFUNCTION()` 方法
   - 重写 `BlueprintEvent` 事件
   - 读写 `UPROPERTY()` 属性
   - 绑定脚本声明的 `event` 委托

```angelscript
class AScriptableEnemy : AActor
{
    // Blueprint 可调用
    UFUNCTION()
    void TakeDamage(float Amount) { }

    // Blueprint 可重写（有默认实现）
    UFUNCTION(BlueprintEvent)
    void OnDeath()
    {
        Print("Default death behavior");
    }

    // Blueprint 不可调用的内部方法
    void InternalUpdate() { }
};
```

---

## 热重载

AngelScript 的一大杀手级特性是热重载：

- **编辑器中**：保存 `.as` 文件后，所有变更立即生效，无需重启编辑器
- **PIE 运行中**：非结构性变更（函数体修改）可以在 Play 期间即时重载
- **结构性变更**（添加/删除 UPROPERTY、修改类继承）需要退出 PIE 后生效

热重载是核心开发工作流——修改代码 → 保存 → 立刻看到结果，无需等待 C++ 编译。

---

## 示例索引

项目 `Script/Examples/` 目录包含 28+ 个分类示例：

| 分类 | 数量 | 覆盖内容 |
|------|------|---------|
| **Core/** | 20 | Actor、Array、Map、Struct、Enum、Delegates、Functions、FormatString、Math、MixinMethods、Timers、Overlaps、MovingObject、ConstructionScript、CharacterInput、BehaviorTreeNodes、Widget 等 |
| **EnhancedInput/** | 3 | InputAction 绑定（Component / PlayerController / Interface） |
| **Extended/** | 5 | Subsystem 生命周期、Interface 多态、Blueprint 子类化、Network 复制、Console 工作流 |

完整索引见 `Script/Examples/README.md`。

---

## 下一步

- **语法深入** → `Guide_SyntaxFeatures.md`（AS 语法特色速览）
- **C++ 绑定** → `Guide_ClassBinding.md`（如何把 C++ 类暴露给 AS）
- **远程调试** → `Guide_Debugging.md`（VS Code 断点调试）
- **Hazelight 官方文档** → `Reference/Docs-UnrealEngine-Angelscript/content/`（拉取命令：`Tools\PullReference\PullReference.bat hazelightdocs`）
