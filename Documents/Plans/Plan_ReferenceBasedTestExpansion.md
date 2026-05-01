# AngelScript 功能测试扩展方案

## Context

通过分析 `Reference/myas` 中的 It Takes Two Script（5,356 .as 文件）和 Split Fiction Script（15,741 .as 文件），与当前项目已有测试（429 test .cpp, 28 example .as）进行对比，整理出以下值得补充的功能测试。

> **注意**：参考项目使用了 Hazelight 自定义框架（Haze Capability System、HazeActor、CrumbSync 等），下方仅提取**通用 UE 模式**，排除 Hazelight 专有框架。

---

## 1. DefaultComponent 与组件层级附着

**现状**：当前测试覆盖了基础 DefaultComponent 声明和单层 Attach，但缺少多层嵌套、Socket 附着、default 属性设置。

**参考来源**：It Takes Two / Split Fiction 中几乎所有 Actor 都使用多层 DefaultComponent 链。

### 测试用例

#### 1.1 多层组件嵌套（3层+）

```cpp
// Test: Angelscript.TestModule.Functional.Component.MultiLevelHierarchy
// 验证 3 层以上 DefaultComponent Attach 链是否正确构建

const char* Script = R"(
    class AMultiLevelActor : AActor
    {
        UPROPERTY(DefaultComponent, RootComponent)
        USceneComponent Root;

        UPROPERTY(DefaultComponent, Attach = Root)
        USceneComponent MiddleLayer;

        UPROPERTY(DefaultComponent, Attach = MiddleLayer)
        UStaticMeshComponent LeafMesh;

        UPROPERTY(DefaultComponent, Attach = LeafMesh)
        UPointLightComponent DeepLight;
    }
)";

// 验证:
// 1. Root 是 RootComponent
// 2. MiddleLayer.GetAttachParent() == Root
// 3. LeafMesh.GetAttachParent() == MiddleLayer
// 4. DeepLight.GetAttachParent() == LeafMesh
// 5. Root.GetNumChildrenComponents() == 1
```

#### 1.2 Socket 附着

```cpp
// Test: Angelscript.TestModule.Functional.Component.SocketAttachment
// 验证 AttachSocket 指定骨骼 socket 附着

const char* Script = R"(
    class ASocketActor : AActor
    {
        UPROPERTY(DefaultComponent, RootComponent)
        USceneComponent Root;

        UPROPERTY(DefaultComponent, Attach = Root)
        USkeletalMeshComponent CharMesh;

        UPROPERTY(DefaultComponent, Attach = CharMesh, AttachSocket = "hand_r")
        UStaticMeshComponent WeaponMesh;
    }
)";

// 验证:
// 1. WeaponMesh.GetAttachSocketName() == "hand_r"
// 2. WeaponMesh.GetAttachParent() == CharMesh
```

#### 1.3 default 关键字设置组件属性

```cpp
// Test: Angelscript.TestModule.Functional.Component.DefaultPropertyOverride
// 验证 default 关键字可以在类声明中覆盖组件默认值

const char* Script = R"(
    class ADefaultPropActor : AActor
    {
        UPROPERTY(DefaultComponent, RootComponent)
        USphereComponent Sphere;

        UPROPERTY(DefaultComponent, Attach = Sphere)
        UStaticMeshComponent Mesh;

        default Sphere.SphereRadius = 128.0;
        default Mesh.bHiddenInGame = true;
        default Mesh.CastShadow = false;
    }
)";

// 验证:
// 1. CDO->Sphere->SphereRadius == 128.0f
// 2. CDO->Mesh->bHiddenInGame == true
// 3. CDO->Mesh->CastShadow == false
```

---

## 2. 构造脚本（ConstructionScript）

**现状**：当前无 ConstructionScript 相关测试。参考项目大量使用 `#if EDITOR` 块中的 ConstructionScript 做 Editor 时组件动态创建和属性初始化。

### 测试用例

#### 2.1 基础 ConstructionScript 执行

```cpp
// Test: Angelscript.TestModule.Functional.Actor.ConstructionScriptBasic
// 验证 ConstructionScript BlueprintOverride 在 Editor 中被调用

const char* Script = R"(
    class AConstructionActor : AActor
    {
        UPROPERTY(EditAnywhere)
        int32 TileCount = 3;

        UPROPERTY()
        int32 ConstructionCallCount = 0;

        UFUNCTION(BlueprintOverride)
        void ConstructionScript()
        {
            ConstructionCallCount += 1;
        }
    }
)";

// 验证:
// 1. Spawn 后 ConstructionCallCount >= 1
// 2. 修改 TileCount 后 ConstructionScript 被重新调用
```

#### 2.2 ConstructionScript 中动态创建组件

```cpp
// Test: Angelscript.TestModule.Functional.Actor.ConstructionScriptDynamicComponents

const char* Script = R"(
    class ADynamicTileActor : AActor
    {
        UPROPERTY(DefaultComponent, RootComponent)
        USceneComponent Root;

        UPROPERTY(EditAnywhere, meta = (ClampMin = "1", ClampMax = "10"))
        int32 TileCount = 3;

        UFUNCTION(BlueprintOverride)
        void ConstructionScript()
        {
            // 动态创建 TileCount 个子组件
            for (int i = 0; i < TileCount; i++)
            {
                // 使用 NewObject 或 CreateDefaultSubobject 模式
            }
        }
    }
)";

// 验证:
// 1. TileCount=3 → 3 个子组件
// 2. TileCount 改为 5 → 5 个子组件
```

---

## 3. Property 元数据（Meta Specifiers）

**现状**：当前测试覆盖了基础 UPROPERTY 声明，但缺少 Meta 标签相关功能验证。参考项目大量使用 EditCondition、ClampMin/Max、MakeEditWidget 等。

### 测试用例

#### 3.1 EditCondition 条件显示

```cpp
// Test: Angelscript.TestModule.Functional.Property.EditCondition
// 验证 EditCondition meta 标签正确生成到 UProperty metadata

const char* Script = R"(
    class AConditionalActor : AActor
    {
        UPROPERTY(EditAnywhere)
        bool bUseCustomSpeed = false;

        UPROPERTY(EditAnywhere, meta = (EditCondition = "bUseCustomSpeed"))
        float CustomSpeed = 100.0;

        UPROPERTY(EditAnywhere, meta = (EditCondition = "bUseCustomSpeed", EditConditionHides))
        float HiddenWhenDisabled = 50.0;

        UPROPERTY(EditAnywhere, meta = (InlineEditConditionToggle))
        bool bEnableGravity = true;

        UPROPERTY(EditAnywhere, meta = (EditCondition = "bEnableGravity"))
        float GravityScale = 1.0;
    }
)";

// 验证:
// 1. CustomSpeed 的 FProperty 有 "EditCondition" metadata == "bUseCustomSpeed"
// 2. HiddenWhenDisabled 有 "EditConditionHides" metadata
// 3. bEnableGravity 有 "InlineEditConditionToggle" metadata
```

#### 3.2 ClampMin/ClampMax 数值约束

```cpp
// Test: Angelscript.TestModule.Functional.Property.ClampMinMax

const char* Script = R"(
    class AClampedActor : AActor
    {
        UPROPERTY(EditAnywhere, meta = (ClampMin = "0.0", ClampMax = "100.0"))
        float HealthPercent = 50.0;

        UPROPERTY(EditAnywhere, meta = (ClampMin = "0", ClampMax = "1000", UIMin = "0", UIMax = "500"))
        int32 MaxAmmo = 100;
    }
)";

// 验证:
// 1. HealthPercent 的 metadata 包含 ClampMin="0.0" ClampMax="100.0"
// 2. MaxAmmo 的 metadata 包含 UIMin="0" UIMax="500"
```

#### 3.3 MakeEditWidget 可视化编辑

```cpp
// Test: Angelscript.TestModule.Functional.Property.MakeEditWidget

const char* Script = R"(
    class AEditWidgetActor : AActor
    {
        UPROPERTY(EditAnywhere, meta = (MakeEditWidget))
        FVector TargetLocation = FVector::ZeroVector;

        UPROPERTY(EditAnywhere, meta = (MakeEditWidget))
        TArray<FVector> PatrolPoints;
    }
)";

// 验证:
// 1. TargetLocation 的 metadata 包含 "MakeEditWidget"
// 2. PatrolPoints 的 metadata 包含 "MakeEditWidget"
```

---

## 4. Mixin 函数（扩展方法）

**现状**：当前测试有 FunctionLibrary 相关测试，但缺少 AS 层 mixin 语法的功能测试。参考项目中 mixin 广泛用于给 Actor/Component 添加辅助方法。

### 测试用例

#### 4.1 基础 Mixin 定义与调用

```cpp
// Test: Angelscript.TestModule.Functional.Functions.MixinBasic
// 验证全局 mixin 函数可作为类型的方法调用

const char* Script = R"(
    // Mixin 定义 - 第一个参数是扩展目标类型
    float GetHealthPercent(AActor Self)
    {
        // 简化示例
        return 0.75;
    }

    bool IsNearby(AActor Self, AActor Other, float Threshold = 500.0)
    {
        FVector Diff = Self.GetActorLocation() - Other.GetActorLocation();
        return Diff.Size() <= Threshold;
    }

    class AMixinTestActor : AActor
    {
        UFUNCTION(BlueprintOverride)
        void BeginPlay()
        {
            // 作为方法调用 mixin
            float Pct = GetHealthPercent();  // Self 被隐式传入
        }
    }
)";

// 验证:
// 1. mixin 编译通过
// 2. 方法调用语法 Self.MixinFunc() 正确转换
// 3. 默认参数 Threshold 生效
```

#### 4.2 Mixin 与 const 引用

```cpp
// Test: Angelscript.TestModule.Functional.Functions.MixinConstRef

const char* Script = R"(
    bool IsValid(const FVector& in Self)
    {
        return !Self.IsNearlyZero();
    }

    class AMixinConstTestActor : AActor
    {
        UFUNCTION(BlueprintOverride)
        void BeginPlay()
        {
            FVector V = FVector(1.0, 0.0, 0.0);
            bool bResult = V.IsValid();  // mixin 调用
        }
    }
)";

// 验证: mixin 可用于值类型的 const 引用
```

---

## 5. Property Getter 语法（property 关键字）

**现状**：当前无 property 关键字相关测试。参考项目使用 `property` 关键字实现计算属性。

### 测试用例

#### 5.1 基础 Property Getter

```cpp
// Test: Angelscript.TestModule.Functional.Property.GetterSyntax

const char* Script = R"(
    class APropertyGetterActor : AActor
    {
        UPROPERTY()
        float MaxHealth = 100.0;

        UPROPERTY()
        float CurrentHealth = 75.0;

        // property 关键字使函数可作为属性访问（无括号）
        float GetHealthPercent() const property
        {
            return CurrentHealth / MaxHealth;
        }

        USceneComponent GetRoot() property
        {
            return RootComponent;
        }

        UFUNCTION(BlueprintOverride)
        void BeginPlay()
        {
            float Pct = HealthPercent;  // 无括号调用
        }
    }
)";

// 验证:
// 1. property 关键字编译通过
// 2. HealthPercent 可作为属性读取（无括号）
// 3. const property 标记正确
```

---

## 6. 字符串插值与格式化

**现状**：当前有字符串基础测试，但缺少 f-string 插值和 n"" FName 字面量的综合测试。

### 测试用例

#### 6.1 F-String 插值

```cpp
// Test: Angelscript.TestModule.Functional.Types.FStringInterpolation

const char* Script = R"(
    class AStringTestActor : AActor
    {
        UFUNCTION(BlueprintOverride)
        void BeginPlay()
        {
            FString Name = "Player";
            int Score = 100;
            float Time = 12.5;

            FString Msg1 = f"Hello {Name}!";
            FString Msg2 = f"{Name} scored {Score} in {Time}s";
            FString Msg3 = f"Nested: {f\"inner {Score}\"}";

            // 验证结果
            ensure(Msg1 == "Hello Player!");
            ensure(Msg2 == "Player scored 100 in 12.5s");
        }
    }
)";
```

#### 6.2 FName 字面量语法

```cpp
// Test: Angelscript.TestModule.Functional.Types.FNameLiteral

const char* Script = R"(
    class AFNameTestActor : AActor
    {
        UFUNCTION(BlueprintOverride)
        void BeginPlay()
        {
            FName Tag1 = n"MyTag";
            FName Tag2 = n"Another_Tag";

            // n"" 语法和 FName() 构造应等价
            ensure(Tag1 == FName("MyTag"));

            // 用于 Timer / Event 绑定
            System::SetTimer(this, n"OnTimerTick", 1.0, false);
        }

        UFUNCTION()
        void OnTimerTick() { }
    }
)";
```

---

## 7. 枚举（Enum）高级用法

**现状**：当前有枚举基础声明测试，但缺少枚举作为 UPROPERTY / switch-case 完整流程。

### 测试用例

#### 7.1 脚本枚举全流程

```cpp
// Test: Angelscript.TestModule.Functional.Types.EnumFullLifecycle

const char* Script = R"(
    enum ECharacterState
    {
        Idle,
        Running,
        Jumping,
        Falling
    }

    class AEnumActor : AActor
    {
        UPROPERTY(EditAnywhere, BlueprintReadWrite)
        ECharacterState CurrentState = ECharacterState::Idle;

        UPROPERTY()
        int32 StateChangeCount = 0;

        void SetState(ECharacterState NewState)
        {
            if (CurrentState != NewState)
            {
                CurrentState = NewState;
                StateChangeCount += 1;
            }
        }

        FString GetStateName()
        {
            switch (CurrentState)
            {
                case ECharacterState::Idle:     return "Idle";
                case ECharacterState::Running:  return "Running";
                case ECharacterState::Jumping:  return "Jumping";
                case ECharacterState::Falling:  return "Falling";
            }
            return "Unknown";
        }
    }
)";

// 验证:
// 1. 枚举在 ClassGenerator 中生成正确的 UEnum
// 2. UPROPERTY(EditAnywhere) 枚举可在 Editor 下拉选择
// 3. switch-case 正确分发
// 4. 枚举比较运算符正确
// 5. 默认值 ECharacterState::Idle 正确
```

---

## 8. 结构体（Struct）高级用法

**现状**：基础 struct 测试已有，缺少嵌套 struct、struct 作为 UPROPERTY、struct 内含容器等。

### 测试用例

#### 8.1 嵌套结构体

```cpp
// Test: Angelscript.TestModule.Functional.Types.NestedStruct

const char* Script = R"(
    struct FInnerData
    {
        UPROPERTY()
        float Value = 0.0;

        UPROPERTY()
        FString Label;
    }

    struct FOuterData
    {
        UPROPERTY()
        FInnerData Primary;

        UPROPERTY()
        TArray<FInnerData> SecondaryList;

        UPROPERTY()
        int32 Count = 0;
    }

    class ANestedStructActor : AActor
    {
        UPROPERTY(EditAnywhere)
        FOuterData Config;

        UFUNCTION(BlueprintOverride)
        void BeginPlay()
        {
            Config.Primary.Value = 42.0;
            Config.Primary.Label = "Main";

            FInnerData Extra;
            Extra.Value = 10.0;
            Extra.Label = "Extra";
            Config.SecondaryList.Add(Extra);
            Config.Count = Config.SecondaryList.Num();
        }
    }
)";

// 验证:
// 1. 嵌套 struct 编译正确
// 2. struct 内 TArray 可操作
// 3. 值赋值和读取正确
// 4. Config.Count 在 BeginPlay 后 == 1
```

#### 8.2 结构体作为函数参数和返回值

```cpp
// Test: Angelscript.TestModule.Functional.Types.StructParamReturn

const char* Script = R"(
    struct FDamageInfo
    {
        UPROPERTY()
        float Amount = 0.0;

        UPROPERTY()
        bool bIsCritical = false;

        UPROPERTY()
        FVector HitLocation;
    }

    class ADamageActor : AActor
    {
        FDamageInfo CalculateDamage(float BaseDamage, FVector Location)
        {
            FDamageInfo Result;
            Result.Amount = BaseDamage * 1.5;
            Result.bIsCritical = BaseDamage > 50.0;
            Result.HitLocation = Location;
            return Result;
        }

        void ApplyDamage(const FDamageInfo& Info)
        {
            // 使用 Info.Amount, Info.bIsCritical 等
        }
    }
)";

// 验证:
// 1. struct 可作为返回值
// 2. struct 可作为 const 引用参数
// 3. 返回值各字段正确
```

---

## 9. Timer 系统完整测试

**现状**：当前 Example 中有 Timer 示例，但缺少 C++ 自动化测试验证运行时行为。

### 测试用例

#### 9.1 Timer 触发与取消

```cpp
// Test: Angelscript.TestModule.Functional.Actor.TimerFireAndCancel

const char* Script = R"(
    class ATimerActor : AActor
    {
        UPROPERTY()
        int32 TickCount = 0;

        UPROPERTY()
        bool bTimerFired = false;

        FTimerHandle LoopHandle;
        FTimerHandle OneShotHandle;

        UFUNCTION(BlueprintOverride)
        void BeginPlay()
        {
            // 循环 Timer
            LoopHandle = System::SetTimer(this, n"OnLoop", 0.1, true);

            // 单次 Timer
            OneShotHandle = System::SetTimer(this, n"OnOneShot", 0.5, false);
        }

        UFUNCTION()
        void OnLoop()
        {
            TickCount += 1;
            if (TickCount >= 5)
            {
                System::ClearAndInvalidateTimerHandle(LoopHandle);
            }
        }

        UFUNCTION()
        void OnOneShot()
        {
            bTimerFired = true;
        }
    }
)";

// 验证 (tick world 1 秒后):
// 1. TickCount == 5 (循环 5 次后自我停止)
// 2. bTimerFired == true (单次 Timer 触发)
// 3. LoopHandle 已失效
```

#### 9.2 Timer 暂停与恢复

```cpp
// Test: Angelscript.TestModule.Functional.Actor.TimerPauseResume

const char* Script = R"(
    class ATimerPauseActor : AActor
    {
        UPROPERTY()
        int32 Counter = 0;
        FTimerHandle Handle;

        UFUNCTION(BlueprintOverride)
        void BeginPlay()
        {
            Handle = System::SetTimer(this, n"Increment", 0.1, true);
        }

        UFUNCTION()
        void Increment() { Counter += 1; }

        void PauseTimer() { System::PauseTimerHandle(Handle); }
        void ResumeTimer() { System::UnPauseTimerHandle(Handle); }
        bool IsTimerPaused() { return System::IsTimerPausedHandle(Handle); }
    }
)";

// 验证:
// 1. Tick 0.35s → Counter ~3
// 2. PauseTimer() → IsTimerPaused() == true
// 3. Tick 0.5s → Counter 不变
// 4. ResumeTimer() → Tick 0.3s → Counter 增加
```

---

## 10. 事件/委托高级模式

**现状**：基础 delegate/event 已测试。缺少带参数广播、多绑定、解绑等完整流程。

### 测试用例

#### 10.1 带参数的 Event 广播

```cpp
// Test: Angelscript.TestModule.Functional.Delegate.EventBroadcastWithParams

const char* Script = R"(
    event void FOnDamageTaken(float Damage, bool bIsCritical, FVector HitLocation);

    class ADamageReceiver : AActor
    {
        UPROPERTY()
        FOnDamageTaken OnDamageTaken;

        UPROPERTY()
        float LastDamage = 0.0;

        UPROPERTY()
        bool bWasCritical = false;

        UFUNCTION(BlueprintOverride)
        void BeginPlay()
        {
            OnDamageTaken.AddUFunction(this, n"HandleDamage");
        }

        UFUNCTION()
        void HandleDamage(float Damage, bool bIsCritical, FVector HitLocation)
        {
            LastDamage = Damage;
            bWasCritical = bIsCritical;
        }

        void TakeDamage(float Amount)
        {
            OnDamageTaken.Broadcast(Amount, Amount > 50.0, GetActorLocation());
        }
    }
)";

// 验证:
// 1. TakeDamage(30) → LastDamage==30, bWasCritical==false
// 2. TakeDamage(80) → LastDamage==80, bWasCritical==true
```

#### 10.2 多监听者 Event

```cpp
// Test: Angelscript.TestModule.Functional.Delegate.MultipleListeners

const char* Script = R"(
    event void FOnScored(int32 Points);

    class AScoreManager : AActor
    {
        UPROPERTY()
        FOnScored OnScored;

        void Score(int32 Points)
        {
            OnScored.Broadcast(Points);
        }
    }

    class AScoreListener : AActor
    {
        UPROPERTY()
        int32 TotalReceived = 0;

        void ListenTo(AScoreManager Manager)
        {
            Manager.OnScored.AddUFunction(this, n"OnScore");
        }

        UFUNCTION()
        void OnScore(int32 Points)
        {
            TotalReceived += Points;
        }
    }
)";

// 验证:
// 1. 2 个 Listener 绑定同一 Manager
// 2. Manager.Score(10) → 两个 Listener 的 TotalReceived 都 == 10
// 3. 销毁一个 Listener → Manager.Score(5) → 存活 Listener == 15
```

#### 10.3 Delegate 返回值

```cpp
// Test: Angelscript.TestModule.Functional.Delegate.ReturnValue

const char* Script = R"(
    delegate bool FCanInteract(AActor Instigator);

    class AInteractable : AActor
    {
        UPROPERTY()
        FCanInteract CanInteractCheck;

        bool TryInteract(AActor Who)
        {
            if (CanInteractCheck.IsBound())
                return CanInteractCheck.Execute(Who);
            return true;  // 默认可交互
        }
    }
)";

// 验证:
// 1. 未绑定时 TryInteract() 返回 true
// 2. 绑定返回 false 的函数后 TryInteract() 返回 false
```

---

## 11. Actor 生成（SpawnActor）

**现状**：当前测试中 Spawn 用于内部测试辅助，但无针对 SpawnActor 语法本身的测试。

### 测试用例

#### 11.1 基础 SpawnActor 参数

```cpp
// Test: Angelscript.TestModule.Functional.Actor.SpawnActorPatterns

const char* Script = R"(
    class AProjectile : AActor
    {
        UPROPERTY()
        float Speed = 1000.0;
    }

    class ASpawner : AActor
    {
        UPROPERTY(EditAnywhere)
        TSubclassOf<AProjectile> ProjectileClass;

        UFUNCTION(BlueprintOverride)
        void BeginPlay()
        {
            // 带位置和旋转的 Spawn
            AActor Spawned = SpawnActor(
                AProjectile,
                GetActorLocation() + FVector(100, 0, 0),
                FRotator(0, 90, 0)
            );

            // 使用命名参数
            AActor Spawned2 = SpawnActor(
                AProjectile,
                Location = GetActorLocation(),
                Rotation = FRotator::ZeroRotator
            );
        }
    }
)";

// 验证:
// 1. Spawned 位置正确 (偏移 100)
// 2. Spawned 旋转正确 (Yaw 90)
// 3. Spawned 是 AProjectile 类型
```

#### 11.2 延迟生成（Deferred Spawn）

```cpp
// Test: Angelscript.TestModule.Functional.Actor.DeferredSpawn

const char* Script = R"(
    class ADeferredActor : AActor
    {
        UPROPERTY()
        bool bBeginPlayCalled = false;

        UFUNCTION(BlueprintOverride)
        void BeginPlay()
        {
            bBeginPlayCalled = true;
        }
    }

    class ADeferredSpawner : AActor
    {
        UFUNCTION(BlueprintOverride)
        void BeginPlay()
        {
            auto Spawned = SpawnActor(ADeferredActor, bDeferredSpawn = true);
            // Spawned 此时 BeginPlay 尚未被调用
            // ensure(Spawned.bBeginPlayCalled == false);

            // 完成生成
            FinishSpawningActor(Spawned);
            // ensure(Spawned.bBeginPlayCalled == true);
        }
    }
)";
```

#### 11.3 TSubclassOf 类引用生成

```cpp
// Test: Angelscript.TestModule.Functional.Actor.SpawnFromClassRef

const char* Script = R"(
    class ABaseEnemy : AActor
    {
        UPROPERTY()
        int32 Level = 1;
    }

    class AEnemySpawner : AActor
    {
        UPROPERTY(EditAnywhere)
        TSubclassOf<ABaseEnemy> EnemyClass;

        UPROPERTY(EditAnywhere)
        int32 SpawnCount = 3;

        TArray<ABaseEnemy> SpawnedEnemies;

        void SpawnWave()
        {
            for (int i = 0; i < SpawnCount; i++)
            {
                ABaseEnemy Enemy = Cast<ABaseEnemy>(
                    SpawnActor(EnemyClass, GetActorLocation() + FVector(i * 200, 0, 0))
                );
                if (Enemy != nullptr)
                {
                    Enemy.Level = i + 1;
                    SpawnedEnemies.Add(Enemy);
                }
            }
        }
    }
)";

// 验证:
// 1. SpawnedEnemies.Num() == SpawnCount
// 2. 每个 Enemy 的 Level 正确递增
// 3. Cast<ABaseEnemy> 返回非 null
```

---

## 12. UMG Widget 系统

**现状**：当前有 UUserWidget 绑定但缺少脚本创建 Widget、BindWidget、Widget 事件绑定等测试。

### 测试用例

#### 12.1 脚本 Widget 类定义

```cpp
// Test: Angelscript.TestModule.Functional.Widget.ScriptWidgetClass

const char* Script = R"(
    class UMyHudWidget : UUserWidget
    {
        UPROPERTY()
        float DisplayValue = 0.0;

        UPROPERTY()
        bool bIsVisible = true;

        UFUNCTION(BlueprintOverride)
        void Construct()
        {
            // Widget 初始化
            bIsVisible = true;
        }

        UFUNCTION(BlueprintOverride)
        void Tick(FGeometry MyGeometry, float DeltaTime)
        {
            DisplayValue += DeltaTime;
        }
    }
)";

// 验证:
// 1. UMyHudWidget 类正确生成（继承 UUserWidget）
// 2. Construct override 正确绑定
// 3. Tick override 正确绑定
// 4. UPROPERTY 正确注册
```

#### 12.2 BindWidget 自动绑定

```cpp
// Test: Angelscript.TestModule.Functional.Widget.BindWidget

const char* Script = R"(
    class UScoreWidget : UUserWidget
    {
        UPROPERTY(BindWidget)
        UTextBlock ScoreText;

        UPROPERTY(BindWidget)
        UProgressBar HealthBar;

        UPROPERTY(BindWidgetOptional)
        UButton RestartButton;

        void UpdateScore(int32 Score)
        {
            if (ScoreText != nullptr)
                ScoreText.SetText(FText::FromString(f"Score: {Score}"));
        }

        void UpdateHealth(float Percent)
        {
            if (HealthBar != nullptr)
                HealthBar.SetPercent(Percent);
        }
    }
)";

// 验证:
// 1. BindWidget metadata 正确生成
// 2. BindWidgetOptional metadata 正确生成
// 3. ScoreText / HealthBar 属性类型正确
```

---

## 13. Overlap 与碰撞事件

**现状**：当前有碰撞相关 Bind 测试，但缺少脚本中 Overlap 事件完整流程。

### 测试用例

#### 13.1 Actor Overlap 事件

```cpp
// Test: Angelscript.TestModule.Functional.Actor.OverlapEvents

const char* Script = R"(
    class AOverlapActor : AActor
    {
        UPROPERTY(DefaultComponent, RootComponent)
        UBoxComponent Box;

        UPROPERTY()
        int32 OverlapBeginCount = 0;

        UPROPERTY()
        int32 OverlapEndCount = 0;

        UFUNCTION(BlueprintOverride)
        void BeginPlay()
        {
            Box.SetGenerateOverlapEvents(true);
        }

        UFUNCTION(BlueprintOverride)
        void ActorBeginOverlap(AActor OtherActor)
        {
            OverlapBeginCount += 1;
        }

        UFUNCTION(BlueprintOverride)
        void ActorEndOverlap(AActor OtherActor)
        {
            OverlapEndCount += 1;
        }
    }
)";

// 验证:
// 1. 另一个 Actor 进入 Box 范围 → OverlapBeginCount++
// 2. 离开 → OverlapEndCount++
```

#### 13.2 Component Overlap 事件绑定

```cpp
// Test: Angelscript.TestModule.Functional.Actor.ComponentOverlapBinding

const char* Script = R"(
    class AZoneActor : AActor
    {
        UPROPERTY(DefaultComponent, RootComponent)
        UBoxComponent DamageZone;

        UPROPERTY()
        TArray<AActor> ActorsInZone;

        UFUNCTION(BlueprintOverride)
        void BeginPlay()
        {
            DamageZone.OnComponentBeginOverlap.AddUFunction(this, n"OnZoneEnter");
            DamageZone.OnComponentEndOverlap.AddUFunction(this, n"OnZoneExit");
        }

        UFUNCTION()
        void OnZoneEnter(UPrimitiveComponent OverlapComp, AActor OtherActor,
            UPrimitiveComponent OtherComp, int OtherBodyIndex,
            bool bFromSweep, const FHitResult& SweepResult)
        {
            ActorsInZone.Add(OtherActor);
        }

        UFUNCTION()
        void OnZoneExit(UPrimitiveComponent OverlapComp, AActor OtherActor,
            UPrimitiveComponent OtherComp, int OtherBodyIndex)
        {
            ActorsInZone.Remove(OtherActor);
        }
    }
)";

// 验证:
// 1. OnComponentBeginOverlap 绑定签名正确编译
// 2. OnComponentEndOverlap 绑定签名正确编译
// 3. 多参数委托签名匹配正确
```

---

## 14. Behavior Tree 脚本节点

**现状**：当前无 BT 相关脚本测试。参考项目使用 AS 编写 BT Task / Service / Decorator。

### 测试用例

#### 14.1 BT Task 脚本定义

```cpp
// Test: Angelscript.TestModule.Functional.AI.BTTaskScript

const char* Script = R"(
    class UBTTask_ScriptMoveToTarget : UBTTask_BlueprintBase
    {
        UPROPERTY(EditAnywhere)
        float AcceptanceRadius = 100.0;

        UFUNCTION(BlueprintOverride)
        EBTNodeResult ExecuteAI(AAIController OwnerController, APawn ControlledPawn)
        {
            if (ControlledPawn == nullptr)
                return EBTNodeResult::Failed;

            return EBTNodeResult::InProgress;
        }

        UFUNCTION(BlueprintOverride)
        EBTNodeResult AbortAI(AAIController OwnerController, APawn ControlledPawn)
        {
            return EBTNodeResult::Aborted;
        }

        UFUNCTION(BlueprintOverride)
        FString GetNodeName() const
        {
            return "Script Move To Target";
        }
    }
)";

// 验证:
// 1. UBTTask_BlueprintBase 子类编译通过
// 2. ExecuteAI / AbortAI override 正确注册
// 3. GetNodeName 返回正确字符串
// 4. EditAnywhere 属性可编辑
```

#### 14.2 BT Decorator 脚本定义

```cpp
// Test: Angelscript.TestModule.Functional.AI.BTDecoratorScript

const char* Script = R"(
    class UBTDecorator_ScriptRangeCheck : UBTDecorator_BlueprintBase
    {
        UPROPERTY(EditAnywhere)
        float MaxRange = 1000.0;

        UFUNCTION(BlueprintOverride)
        bool PerformConditionCheckAI(AAIController OwnerController, APawn ControlledPawn)
        {
            if (ControlledPawn == nullptr)
                return false;

            return true;  // 简化 - 实际检查距离
        }
    }
)";
```

#### 14.3 BT Service 脚本定义

```cpp
// Test: Angelscript.TestModule.Functional.AI.BTServiceScript

const char* Script = R"(
    class UBTService_ScriptUpdateTarget : UBTService_BlueprintBase
    {
        UPROPERTY()
        int32 TickCount = 0;

        UFUNCTION(BlueprintOverride)
        void TickAI(AAIController OwnerController, APawn ControlledPawn, float DeltaSeconds)
        {
            TickCount += 1;
        }
    }
)";
```

---

## 15. DataAsset 脚本定义

**现状**：无 DataAsset 脚本定义相关测试。参考项目用 AS 定义 UDataAsset 子类作为配置表。

### 测试用例

#### 15.1 基础 DataAsset 类

```cpp
// Test: Angelscript.TestModule.Functional.Types.ScriptDataAsset

const char* Script = R"(
    class UWeaponData : UDataAsset
    {
        UPROPERTY(EditAnywhere)
        FString WeaponName;

        UPROPERTY(EditAnywhere, meta = (ClampMin = "0"))
        float BaseDamage = 10.0;

        UPROPERTY(EditAnywhere)
        float FireRate = 0.5;

        UPROPERTY(EditAnywhere)
        int32 MaxAmmo = 30;

        UPROPERTY(EditAnywhere)
        TArray<FName> AllowedAttachments;
    }

    class AWeaponActor : AActor
    {
        UPROPERTY(EditAnywhere)
        UWeaponData WeaponConfig;

        UFUNCTION(BlueprintOverride)
        void BeginPlay()
        {
            if (WeaponConfig != nullptr)
            {
                // 使用 DataAsset 数据
                float Damage = WeaponConfig.BaseDamage;
            }
        }
    }
)";

// 验证:
// 1. UWeaponData 继承 UDataAsset 编译通过
// 2. 所有 UPROPERTY 正确注册
// 3. AWeaponActor 可引用 UWeaponData 类型属性
```

---

## 16. Subsystem 脚本继承

**现状**：当前有 Subsystem 测试但以编译验证为主，缺少运行时生命周期行为验证。

### 测试用例

#### 16.1 WorldSubsystem 生命周期

```cpp
// Test: Angelscript.TestModule.Functional.Subsystem.WorldSubsystemLifecycle

const char* Script = R"(
    class UScoreSubsystem : UScriptWorldSubsystem
    {
        UPROPERTY()
        int32 TotalScore = 0;

        UPROPERTY()
        bool bInitialized = false;

        UFUNCTION(BlueprintOverride)
        void Initialize(USubsystemCollectionBase Collection)
        {
            bInitialized = true;
            TotalScore = 0;
        }

        UFUNCTION(BlueprintOverride)
        void Deinitialize()
        {
            bInitialized = false;
        }

        void AddScore(int32 Points)
        {
            TotalScore += Points;
        }
    }
)";

// 验证:
// 1. World 创建后 bInitialized == true
// 2. AddScore(10) → TotalScore == 10
// 3. World 销毁后 Deinitialize 被调用
```

#### 16.2 GameInstanceSubsystem 跨关卡持久

```cpp
// Test: Angelscript.TestModule.Functional.Subsystem.GameInstancePersistence

const char* Script = R"(
    class USaveSubsystem : UScriptGameInstanceSubsystem
    {
        UPROPERTY()
        int32 PersistentValue = 0;

        UFUNCTION(BlueprintOverride)
        void Initialize(USubsystemCollectionBase Collection)
        {
            PersistentValue = 42;
        }

        void Increment()
        {
            PersistentValue += 1;
        }
    }
)";

// 验证:
// 1. 首次 Initialize → PersistentValue == 42
// 2. Increment() → PersistentValue == 43
// 3. 跨 World 切换后值仍在
```

---

## 17. GameplayTag 使用

**现状**：有 GameplayTag binding 但缺少脚本中综合使用模式。

### 测试用例

#### 17.1 GameplayTag 声明与比较

```cpp
// Test: Angelscript.TestModule.Functional.Types.GameplayTagUsage

const char* Script = R"(
    class ATaggedActor : AActor
    {
        UPROPERTY(EditAnywhere)
        FGameplayTag MainTag;

        UPROPERTY(EditAnywhere)
        FGameplayTagContainer OwnedTags;

        bool HasTag(FGameplayTag Tag)
        {
            return OwnedTags.HasTag(Tag);
        }

        bool HasAnyTag(FGameplayTagContainer Tags)
        {
            return OwnedTags.HasAny(Tags);
        }

        void AddTag(FGameplayTag Tag)
        {
            OwnedTags.AddTag(Tag);
        }

        void RemoveTag(FGameplayTag Tag)
        {
            OwnedTags.RemoveTag(Tag);
        }
    }
)";

// 验证:
// 1. FGameplayTag 和 FGameplayTagContainer UPROPERTY 正确
// 2. HasTag / HasAny / AddTag / RemoveTag 方法可调用
// 3. 标签匹配逻辑正确
```

---

## 18. 命名空间与常量组织

**现状**：当前有 namespace 基础测试，缺少 namespace 内常量 + FName 字面量模式。

### 测试用例

#### 18.1 命名空间常量

```cpp
// Test: Angelscript.TestModule.Functional.Misc.NamespaceConstants

const char* Script = R"(
    namespace GameTags
    {
        const FName Player = n"Player";
        const FName Enemy = n"Enemy";
        const FName Projectile = n"Projectile";
        const float DefaultSpeed = 600.0;
    }

    namespace DamageTypes
    {
        const FName Physical = n"Physical";
        const FName Fire = n"Fire";
        const FName Ice = n"Ice";
    }

    class ATagUser : AActor
    {
        UFUNCTION(BlueprintOverride)
        void BeginPlay()
        {
            FName MyTag = GameTags::Player;
            float Speed = GameTags::DefaultSpeed;
            FName DmgType = DamageTypes::Fire;
        }
    }
)";

// 验证:
// 1. namespace 内 const 声明编译通过
// 2. 跨文件 namespace 访问正确
// 3. 混合类型（FName, float）正确
```

---

## 19. 编辑器条件编译（#if EDITOR）

**现状**：Preprocessor 测试覆盖了 #if/#endif，但缺少 #if EDITOR 特定场景。

### 测试用例

#### 19.1 EDITOR 条件编译

```cpp
// Test: Angelscript.TestModule.Functional.Preprocessor.EditorConditional

const char* Script = R"(
    class AEditorConditionalActor : AActor
    {
        UPROPERTY()
        int32 RuntimeValue = 0;

        #if EDITOR
        UPROPERTY(EditAnywhere)
        bool bEditorOnlyFlag = false;

        UFUNCTION(CallInEditor)
        void EditorOnlyAction()
        {
            // 仅 Editor 可用
        }
        #endif

        UFUNCTION(BlueprintOverride)
        void BeginPlay()
        {
            RuntimeValue = 1;

            #if EDITOR
            if (bEditorOnlyFlag)
                RuntimeValue = 2;
            #endif
        }
    }
)";

// 验证:
// 1. Editor 构建时 bEditorOnlyFlag 属性存在
// 2. 打包构建时 bEditorOnlyFlag 属性不存在
// 3. #if EDITOR 块内代码条件编译正确
```

---

## 20. AnimNotify 脚本定义

**现状**：无 AnimNotify 脚本定义测试。参考项目大量使用 AS 定义自定义 AnimNotify。

### 测试用例

#### 20.1 AnimNotify 基础

```cpp
// Test: Angelscript.TestModule.Functional.Animation.AnimNotifyScript

const char* Script = R"(
    class UAnimNotify_ScriptEffect : UAnimNotify
    {
        UPROPERTY(EditAnywhere)
        FName EffectTag = n"Default";

        UFUNCTION(BlueprintOverride)
        bool Notify(USkeletalMeshComponent MeshComp, UAnimSequenceBase Animation,
            const FAnimNotifyEventReference& EventReference)
        {
            // 触发效果逻辑
            return true;
        }

        UFUNCTION(BlueprintOverride)
        FString GetNotifyName() const
        {
            return f"Script Effect: {EffectTag}";
        }
    }
)";

// 验证:
// 1. UAnimNotify 子类编译通过
// 2. Notify override 签名正确
// 3. GetNotifyName 返回自定义名称
```

#### 20.2 AnimNotifyState（时间段通知）

```cpp
// Test: Angelscript.TestModule.Functional.Animation.AnimNotifyStateScript

const char* Script = R"(
    class UAnimNotifyState_ScriptTrail : UAnimNotifyState
    {
        UPROPERTY(EditAnywhere)
        float TrailWidth = 10.0;

        UFUNCTION(BlueprintOverride)
        bool NotifyBegin(USkeletalMeshComponent MeshComp, UAnimSequenceBase Animation,
            float TotalDuration, const FAnimNotifyEventReference& EventReference)
        {
            return true;
        }

        UFUNCTION(BlueprintOverride)
        bool NotifyTick(USkeletalMeshComponent MeshComp, UAnimSequenceBase Animation,
            float FrameDeltaTime, const FAnimNotifyEventReference& EventReference)
        {
            return true;
        }

        UFUNCTION(BlueprintOverride)
        bool NotifyEnd(USkeletalMeshComponent MeshComp, UAnimSequenceBase Animation,
            const FAnimNotifyEventReference& EventReference)
        {
            return true;
        }
    }
)";

// 验证:
// 1. NotifyBegin / NotifyTick / NotifyEnd 三个 override 编译正确
// 2. TotalDuration 参数在 NotifyBegin 中可用
```

---

## 21. GAS（Gameplay Ability System）集成

**现状**：有 Bind_*.cpp 但零测试、零脚本示例。参考项目在 Plugin 中有完整 GAS 示例。

### 测试用例

#### 21.1 AttributeSet 脚本定义

```cpp
// Test: Angelscript.TestModule.Functional.GAS.ScriptAttributeSet

const char* Script = R"(
    class UCharacterAttributes : UAngelscriptAttributeSet
    {
        UPROPERTY(BlueprintReadOnly, ReplicatedUsing = OnRep_ReplicationTrampoline)
        FAngelscriptGameplayAttributeData Health;

        UPROPERTY(BlueprintReadOnly, ReplicatedUsing = OnRep_ReplicationTrampoline)
        FAngelscriptGameplayAttributeData MaxHealth;

        UPROPERTY(BlueprintReadOnly)
        FAngelscriptGameplayAttributeData AttackPower;

        UFUNCTION()
        void OnRep_ReplicationTrampoline(FAngelscriptGameplayAttributeData& OldData)
        {
            OnRep_Attribute(OldData);
        }
    }
)";

// 验证:
// 1. UAngelscriptAttributeSet 子类编译通过
// 2. FAngelscriptGameplayAttributeData 属性正确注册
// 3. ReplicatedUsing 回调正确连接
```

#### 21.2 GAS Character 基础

```cpp
// Test: Angelscript.TestModule.Functional.GAS.GASCharacterBasic

const char* Script = R"(
    class AGASTestCharacter : AAngelscriptGASCharacter
    {
        UFUNCTION(BlueprintOverride)
        void BeginPlay()
        {
            Super::BeginPlay();
            // 注册 AttributeSet
            AbilitySystem.RegisterAttributeSet(UCharacterAttributes::StaticClass());
        }
    }
)";

// 验证:
// 1. AAngelscriptGASCharacter 子类编译通过
// 2. AbilitySystem 组件可访问
// 3. RegisterAttributeSet 调用不崩溃
```

---

## 22. 材质参数动态修改

**现状**：参考项目大量使用运行时材质参数修改，当前无相关测试。

### 测试用例

#### 22.1 动态材质实例

```cpp
// Test: Angelscript.TestModule.Functional.Rendering.DynamicMaterial

const char* Script = R"(
    class AMaterialActor : AActor
    {
        UPROPERTY(DefaultComponent, RootComponent)
        UStaticMeshComponent Mesh;

        UPROPERTY()
        UMaterialInstanceDynamic DynMaterial;

        UFUNCTION(BlueprintOverride)
        void BeginPlay()
        {
            DynMaterial = Mesh.CreateDynamicMaterialInstance(0);
            if (DynMaterial != nullptr)
            {
                DynMaterial.SetScalarParameterValue(n"Opacity", 0.5);
                DynMaterial.SetVectorParameterValue(n"Color", FLinearColor(1, 0, 0, 1));
            }
        }
    }
)";

// 验证:
// 1. CreateDynamicMaterialInstance 返回非 null
// 2. SetScalarParameterValue 编译通过
// 3. SetVectorParameterValue 编译通过
```

---

## 23. Spline 组件使用

**现状**：参考项目频繁使用 Spline 做路径和轨道，当前无相关测试。

### 测试用例

#### 23.1 Spline 路径采样

```cpp
// Test: Angelscript.TestModule.Functional.Component.SplineUsage

const char* Script = R"(
    class ASplineFollower : AActor
    {
        UPROPERTY(DefaultComponent, RootComponent)
        USceneComponent Root;

        UPROPERTY(DefaultComponent)
        USplineComponent Spline;

        UPROPERTY()
        float CurrentDistance = 0.0;

        UFUNCTION(BlueprintOverride)
        void Tick(float DeltaTime)
        {
            CurrentDistance += 100.0 * DeltaTime;

            float SplineLength = Spline.GetSplineLength();
            if (CurrentDistance > SplineLength)
                CurrentDistance = 0.0;

            FVector Pos = Spline.GetLocationAtDistanceAlongSpline(CurrentDistance, ESplineCoordinateSpace::World);
            FRotator Rot = Spline.GetRotationAtDistanceAlongSpline(CurrentDistance, ESplineCoordinateSpace::World);
        }
    }
)";

// 验证:
// 1. USplineComponent DefaultComponent 编译通过
// 2. GetSplineLength / GetLocationAtDistanceAlongSpline / GetRotationAtDistanceAlongSpline 可调用
```

---

## 24. 增强输入（Enhanced Input）脚本集成

**现状**：有 3 个 Example .as 文件但零自动化测试。

### 测试用例

#### 24.1 Enhanced Input 绑定编译

```cpp
// Test: Angelscript.TestModule.Functional.Input.EnhancedInputBinding

const char* Script = R"(
    class AEnhancedInputActor : APawn
    {
        UPROPERTY(EditAnywhere, Category = "Input")
        UInputAction MoveAction;

        UPROPERTY(EditAnywhere, Category = "Input")
        UInputMappingContext DefaultContext;

        UFUNCTION(BlueprintOverride)
        void BeginPlay()
        {
            auto PC = Cast<APlayerController>(GetController());
            if (PC != nullptr)
            {
                auto Subsystem = UEnhancedInputLocalPlayerSubsystem::Get(PC);
                if (Subsystem != nullptr)
                {
                    Subsystem.AddMappingContext(DefaultContext, 0);
                }
            }
        }
    }
)";

// 验证:
// 1. UInputAction / UInputMappingContext 类型属性编译通过
// 2. UEnhancedInputLocalPlayerSubsystem::Get 可调用
// 3. AddMappingContext 签名正确
```

---

## 25. CallInEditor 编辑器按钮

**现状**：当前无 CallInEditor 测试。参考项目大量使用此功能做 Editor 调试按钮。

### 测试用例

#### 25.1 CallInEditor 函数

```cpp
// Test: Angelscript.TestModule.Functional.Functions.CallInEditor

const char* Script = R"(
    class AEditorButtonActor : AActor
    {
        UPROPERTY()
        int32 ExecutionCount = 0;

        UFUNCTION(CallInEditor, BlueprintCallable, Category = "Debug")
        void ResetCounter()
        {
            ExecutionCount = 0;
        }

        UFUNCTION(CallInEditor, Category = "Debug")
        void IncrementCounter()
        {
            ExecutionCount += 1;
        }
    }
)";

// 验证:
// 1. ResetCounter 的 UFunction 有 CallInEditor flag
// 2. IncrementCounter 的 UFunction 有 CallInEditor flag
// 3. Category metadata == "Debug"
```

---

## 26. 访问修饰符（access 关键字）

**现状**：参考项目使用 `access` 和 `access:Type` 限制类成员可见性，当前无测试。

### 测试用例

#### 26.1 Access 修饰符编译

```cpp
// Test: Angelscript.TestModule.Functional.Types.AccessModifiers

const char* Script = R"(
    class ARestrictedActor : AActor
    {
        // 私有属性
        access private float InternalValue = 0.0;

        // 类型限定访问
        access ARestrictedActor float FriendValue = 0.0;

        // 公开属性（默认）
        UPROPERTY()
        float PublicValue = 0.0;

        void SetInternal(float V)
        {
            InternalValue = V;  // 同类内可访问
        }
    }

    class AOtherActor : AActor
    {
        void TryAccess(ARestrictedActor Target)
        {
            float V = Target.PublicValue;       // OK
            // float V2 = Target.InternalValue; // 编译错误
        }
    }
)";

// 验证:
// 1. access private 在同类内可访问
// 2. access private 在外部类编译失败（negative test）
// 3. access ARestrictedActor 仅指定类可访问
```

---

## 27. 异步模式与延迟执行

**现状**：参考项目使用各种延迟执行模式，当前缺少 SetTimerForNextTick 等测试。

### 测试用例

#### 27.1 下一帧执行

```cpp
// Test: Angelscript.TestModule.Functional.Actor.NextTickExecution

const char* Script = R"(
    class ANextTickActor : AActor
    {
        UPROPERTY()
        int32 Phase = 0;

        UFUNCTION(BlueprintOverride)
        void BeginPlay()
        {
            Phase = 1;
            // 下一帧执行
            System::SetTimer(this, n"NextFrame", 0.0, false);
        }

        UFUNCTION()
        void NextFrame()
        {
            Phase = 2;
        }
    }
)";

// 验证:
// 1. BeginPlay 后 Phase == 1
// 2. Tick 一帧后 Phase == 2
```

---

## 28. TMap 高级使用

**现状**：基础 TMap 已测试，缺少 FindOrAdd、复杂类型 Key/Value、迭代等。

### 测试用例

#### 28.1 TMap 完整操作

```cpp
// Test: Angelscript.TestModule.Functional.Types.TMapAdvanced

const char* Script = R"(
    class AMapActor : AActor
    {
        UPROPERTY()
        TMap<FString, int32> Scores;

        UPROPERTY()
        TMap<FName, float> Multipliers;

        void SetupScores()
        {
            Scores.Add("Alice", 100);
            Scores.Add("Bob", 200);
            Scores.Add("Charlie", 150);
        }

        int32 GetScore(FString Name)
        {
            if (Scores.Contains(Name))
                return Scores[Name];
            return 0;
        }

        void IterateAll()
        {
            int32 Total = 0;
            for (auto Entry : Scores)
            {
                Total += Entry.Value;
            }
        }

        int32 GetCount() { return Scores.Num(); }
    }
)";

// 验证:
// 1. Add / Contains / operator[] 正确
// 2. for (auto Entry : Map) 迭代正确
// 3. Num() 返回正确数量
// 4. 多种 Key 类型（FString, FName）可用
```

---

## 输出文件位置

建议输出为: `Documents/Plans/Plan_ReferenceBasedTestExpansion.md`

## 验证方式

所有新测试遵循项目已有模式:
1. 在 `Plugins/Angelscript/Source/AngelscriptTest/Functional/<Theme>/` 下新建对应 .cpp 文件
2. 使用 CQTest 写法（`TEST_CLASS_WITH_FLAGS` + `TEST_METHOD` + `ASTEST_CREATE_ENGINE_FULL` / `ASTEST_CREATE_ENGINE` + `Shared/AngelscriptFunctionalTestUtils.h`）。注：早期版本曾有 `BEGIN_ANGELSCRIPT_TEST` / `END_ANGELSCRIPT_TEST` 宏，已废弃，新增测试一律走 CQTest。
3. 测试前缀: `Angelscript.TestModule.Functional.<Theme>.<TestName>`（与默认 `<Theme>.*` 主题层并存的例外，详见 `Documents/Guides/TestConventions.md` 「例外：Functional 主题层（Round1 gap-fill）」）
4. 每个测试包含: 编译验证 + 反射/CDO/运行时行为验证（如有 world 依赖通过 `FActorTestSpawner` + `BeginPlayActor` + `TickWorld` 推进）
5. 运行: `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Functional." -Label functional-expansion`

## 优先级排序

| 优先级 | 测试领域 | 测试数量 | 理由 |
|--------|---------|---------|------|
| P0 | DefaultComponent 层级 & default 关键字 | 3 | 几乎所有参考代码都使用 |
| P0 | Property Meta (EditCondition/Clamp) | 3 | 编辑器体验核心 |
| P0 | Event/Delegate 高级模式 | 3 | 生产代码核心通信模式 |
| P1 | Struct 高级 (嵌套/参数/返回) | 2 | 数据模型基础 |
| P1 | Enum 全流程 | 1 | 状态机核心 |
| P1 | Timer 运行时行为 | 2 | 游戏逻辑核心 |
| P1 | Actor Spawn 模式 | 3 | 运行时对象管理 |
| P1 | Mixin 函数 | 2 | AS 特色语法 |
| P1 | 字符串插值 & FName 字面量 | 2 | 语言特性 |
| P2 | ConstructionScript | 2 | Editor 工作流 |
| P2 | Overlap 碰撞事件 | 2 | 物理交互 |
| P2 | UMG Widget | 2 | UI 系统 |
| P2 | Namespace 常量 | 1 | 代码组织 |
| P2 | CallInEditor | 1 | 编辑器工具 |
| P2 | #if EDITOR 条件编译 | 1 | 平台适配 |
| P2 | Property Getter 语法 | 1 | AS 特色 |
| P3 | BT 节点脚本 | 3 | AI 系统 |
| P3 | DataAsset 脚本 | 1 | 配置系统 |
| P3 | GAS 集成 | 2 | 能力系统 |
| P3 | AnimNotify 脚本 | 2 | 动画系统 |
| P3 | 材质动态修改 | 1 | 渲染 |
| P3 | Spline 组件 | 1 | 路径系统 |
| P3 | Enhanced Input | 1 | 输入系统 |
| P3 | Access 修饰符 | 1 | 访问控制 |
| P3 | TMap 高级 | 1 | 容器 |
| P3 | 延迟执行 | 1 | 异步模式 |
| P3 | Subsystem 生命周期 | 2 | 全局系统 |

**总计: 约 49 个新测试用例，覆盖 28 个功能领域。**

---

## References / Already Covered（Round1 落地后的盘点）

> 截至 Round1 实际落地（2026-05-02），通过盘点 `Plugins/Angelscript/Source/AngelscriptTest/{Functional,Examples,Bindings,Compiler,Preprocessor,Syntax,Subsystem,Learning}/` 后确认本计划 28 节中以下 19 节的能力已被某种形式覆盖，Round1 仅交付真空区 7 个 + 深度补漏 8 个 = 共 15 个新用例。详见 `Documents/Guides/TestCatalog.md` 12.16 节、`c:\Users\scottmei\.cursor\plans\roundone_functional_tests_3a4226fb.plan.md` 的 "已覆盖跳过 (19/28)" 表。

| 本计划 § | Round1 落地决策 | 已覆盖位置 / 落地新增位置 |
|---|---|---|
| §1 多层组件链 | 新增深度补漏 P2-1 | `Functional/Component/AngelscriptComponentMultiLevelHierarchyTests.cpp`（4 层链 GetAttachParent / GetChildrenComponents 全链）；浅覆盖：`Functional/Component/AngelscriptComponentTests.cpp` DeepAttach |
| §2 ConstructionScript | 已覆盖 → 跳过 | `Functional/Actor/AngelscriptActorLifecycleTests.cpp` + `Examples/AngelscriptScriptExampleConstructionScriptTest.cpp` |
| §3 Property Meta（部分）| 新增深度补漏 P2-3 | `Functional/Property/AngelscriptPropertyMetaMatrixTests.cpp`（EditCondition / EditConditionHides / InlineEditConditionToggle / ClampMin/Max / UIMin/Max / MakeEditWidget 全矩阵）；浅覆盖：`Examples/AngelscriptScriptExamplePropertySpecifiersTest.cpp` |
| §4 Property Meta（编辑器）| 已覆盖 → 跳过 | `Functional/Property/AngelscriptPropertyMetaMatrixTests.cpp`（与 §3 合并实现） |
| §5 property getter 语法 | 已覆盖 → 跳过 | `Syntax/AngelscriptSyntaxPropertyAccessorTests.cpp` |
| §6 enum 全流程 | 已覆盖 → 跳过 | `Functional/Types/*` + `Examples/AngelscriptScriptExampleEnumTest.cpp` + Compiler 流水线 |
| §7 Struct 高级 | 已覆盖 → 跳过 | `Examples/AngelscriptScriptExampleStructTest.cpp` + `Bindings/InstancedStruct*` |
| §8 嵌套 struct | 已覆盖 → 跳过 | 同 §7 |
| §9 Timer 编译 | 新增深度补漏 P2-7 | `Functional/Actor/AngelscriptActorTimerRuntimeBehaviorTests.cpp`（Pause/UnPause/Clear 状态机）；编译覆盖：`Examples/AngelscriptScriptExampleTimersTest.cpp` |
| §10 Delegate 高级 | 新增深度补漏 P2-5 | `Functional/Delegate/AngelscriptDelegateBroadcastWithParamsTests.cpp`（多 listener Broadcast + delegate IsBound/Execute）；基础覆盖：`Functional/Delegate/AngelscriptDelegateTests.cpp` |
| §11 Mixin 函数 | 新增深度补漏 P2-4 | `Functional/Functions/AngelscriptFunctionMixinReferenceMatrixTests.cpp`（三种签名 + 默认参数 dispatch） |
| §12 SpawnActor 模式 | 新增深度补漏 P2-6 | `Functional/Actor/AngelscriptActorSpawnPatternsTests.cpp`（位置/命名/deferred+FinishSpawningActor/TSubclassOf+Cast 四种模式） |
| §13 Overlap | 已覆盖 → 跳过 | `Examples/AngelscriptScriptExampleOverlapsTest.cpp` |
| §14 BT 节点 | 已覆盖 → 跳过 | `Examples/AngelscriptScriptExampleBehaviorTreeNodesTest.cpp` |
| §15 DataAsset 脚本 | 新增真空区 P1-1 | `Functional/Types/AngelscriptTypesScriptDataAssetTests.cpp`（UDataAsset 子类编译 + UPROPERTY/CDO + AActor 持引用） |
| §16 Subsystem 生命周期 | 已覆盖 → 跳过 | `Functional/Subsystem/*` + `Angelscript.TestModule.WorldSubsystem.*` |
| §17 GameplayTag | 已覆盖 → 跳过 | `Bindings/AngelscriptGameplayTagBindingsTests.cpp` + `Bindings/AngelscriptGameplayTagContainerBindingsTests.cpp` |
| §18 Namespace 常量 | 已覆盖 → 跳过 | `Functional/Misc/AngelscriptMiscTests.cpp`（Namespace 段） |
| §19 #if EDITOR 条件编译 | 已覆盖 → 跳过 | `Preprocessor/AngelscriptPreprocessorDirectiveTests.cpp` |
| §20 字符串插值 + FName | 新增深度补漏 P2-8 | `Functional/Types/AngelscriptTypesStringInterpolationAndFNameLiteralTests.cpp`（f-string + n-name 运行时等价 + 大小写不敏感） |
| §21 BindWidget UMG | 新增真空区 P1-2 | `Functional/Widget/AngelscriptWidgetBindWidgetTests.cpp`（UTextBlock / UProgressBar / UButton + BindWidget metadata） |
| §22 AnimNotify 脚本 | 新增真空区 P1-3 / P1-4 | `Functional/Animation/AngelscriptAnimationAnimNotifyScriptTests.cpp` + `AngelscriptAnimationAnimNotifyStateScriptTests.cpp` |
| §23 GAS AttributeSet | 新增真空区 P1-6 | `Functional/GAS/AngelscriptGASScriptAttributeSetTests.cpp`（UAngelscriptAttributeSet 子类 + FAngelscriptGameplayAttributeData + OnRep_Attribute 反射） |
| §24 Enhanced Input | 已覆盖 → 跳过 | `Bindings/AngelscriptEnhancedInputBindingsTests.cpp` |
| §25 CallInEditor | 已覆盖 → 跳过 | `Compiler/AngelscriptCompilerPipelineUFunctionSpecifierMatrixTests.cpp` + `Examples/FunctionSpecifiers` |
| §26 access 关键字 | 已覆盖 → 跳过 | `Examples/AngelscriptScriptExampleAccessSpecifiersTest.cpp` |
| §27 异步 / 延迟 | 已覆盖 → 跳过 | `Learning/Runtime/AngelscriptLearningTimerAndLatentTraceTests.cpp` |
| §28 TMap 高级 | 已覆盖 → 跳过 | `Bindings/AngelscriptMapBindingsTests.cpp` + `Examples/AngelscriptScriptExampleMapTest.cpp` |
| §其它（DefaultPropertyOverride / DynamicMaterial / Spline）| 新增 | P2-2 `Functional/Component/AngelscriptComponentDefaultPropertyOverrideTests.cpp`、P1-5 `Functional/Rendering/AngelscriptRenderingDynamicMaterialTests.cpp`、P1-7 `Functional/Component/AngelscriptComponentSplineUsageTests.cpp` |
