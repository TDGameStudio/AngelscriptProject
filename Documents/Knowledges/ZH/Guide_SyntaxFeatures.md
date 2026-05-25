# Guide_SyntaxFeatures — AngelScript 语法特色速览

> **所属前缀**: Guide_（实践指南族）
> **适用读者**: 已熟悉 UE C++ 或 Blueprint，准备开始写 `.as` 脚本的开发者
> **前置知识**: 看完 `Documents/Knowledges/ZH/Guide_QuickStart.md` 的 16 个案例
> **关联 Knowledges**:
> `Documents/Knowledges/ZH/Guide_QuickStart.md` —— 环境搭建与第一个脚本
> · `Documents/Knowledges/ZH/Syntax_UPROPERTY.md` —— UPROPERTY 修饰符的完整实现原理
> · `Documents/Knowledges/ZH/Syntax_UFUNCTION.md` —— UFUNCTION 修饰符与 Meta 直通清单
> · `Documents/Knowledges/ZH/Syntax_DefaultStatement.md` —— `default` 语句两条独立路径
> · `Documents/Knowledges/ZH/Syntax_DefaultComponent.md` —— DefaultComponent / Attach / RootComponent
> · `Documents/Knowledges/ZH/Syntax_DelegateEvent.md` —— delegate / event 多播机制
> · `Documents/Knowledges/ZH/Syntax_AccessSpecifiers.md` —— access 自定义授权轴
> · `Documents/Knowledges/ZH/Syntax_Mixin.md` —— mixin 关键字与 ScriptMixin 元数据
> · `Documents/Knowledges/ZH/Syntax_FString.md` —— f-string 编译期展开
> · `Documents/Knowledges/ZH/Syntax_TArray.md` / `Syntax_TMap.md` / `Syntax_TSet.md` / `Syntax_TOptional.md` / `Syntax_TSubclassOf.md` / `Syntax_TSoftObjectPtr.md` / `Syntax_FInstancedStruct.md` —— 容器与包装类型
> · `Documents/Knowledges/ZH/AS_LanguageSyntax.md` —— Token / AST / EBNF 速查

---

## 概览

本文聚焦一个核心问题：**已经会写 UE C++ 的人，要怎么把脑子里的 C++ 心智模型平移到 `.as` 里？哪些写法是 1:1 的、哪些是新增糖、哪些是 C++ 里有但 AS 里没有的？**

`Guide_QuickStart.md` 已经给了 16 个能直接 copy-paste 跑起来的案例；本文不再重复那些场景，而是横切地把 AS 的"语法特色"梳理一遍——你打开 VS Code 之前就该建立的心智模型。

```text
                        AS 与 C++ 的对照速览

       场景                  C++                       AS
       ----------            ---------------------     ----------------------
   ┌── 内存语义           裸指针 / 智能指针        值（栈 / 内嵌）+ handle (@)
   │                                                  + 由 GC 自动回收
   │
   ├── 反射注册            UCLASS / UFUNCTION /      class : AActor 自动反射
   │                       UPROPERTY 宏              UFUNCTION() / UPROPERTY()
   │                       + UHT 生成器              修饰符（直接写、无生成器）
   │
   ├── 默认值              构造函数 / Initializer   default 语句（声明式）
   │                       List
   │
   ├── 组件                CreateDefaultSubobject    UPROPERTY(DefaultComponent)
   │                       + ObjectInitializer       自动创建 + Attach
   │
   ├── 委托                DECLARE_DYNAMIC_*_DELEGATE delegate / event 关键字
   │                                                  自动展开为 struct
   │
   ├── 字符串拼接          FString::Printf(...)      f"{var :spec}"
   │
   ├── 容器                TArray / TMap / TSet /    同名，使用方式 99% 相同
   │                       TSubclassOf 等
   │
   ├── 模板                自定义 template<>          ✗ 不支持用户自定义模板
   │                                                  （只能用引擎内置 TArray 等）
   │
   ├── 多继承              支持                       ✗ 仅单继承（与 UE UClass 一致）
   │
   └── 热重载              Live Coding（受限）       原生支持，保存即生效
```

后续按 **内存语义 / 反射修饰符 / default / 组件 / 委托 / 容器 / 字符串 / 高级糖 / 与 C++ 差异速查 / 入门误区** 的顺序展开。

---

## 一、内存语义：值 vs handle

AS 没有"裸指针"——所有变量要么是**值**（栈上 / 类内嵌），要么是**句柄**（handle，写作 `@`）。这是与 C++ 的第一条心智差异。

### 1.1 UObject 默认就是 handle

凡是继承自 `UObject` 的类型（`AActor` / `UActorComponent` / `UWidget` / 自定义 `class : AActor`），AS 编译器**默认按 handle 处理**——你写 `AActor Player;` 实际拿到的是一个引用槽，不会在栈上构造一个 Actor。

```angelscript
// 这两行在语义上等价：都是"持有 AActor 的引用"
AActor   Player;     // 隐式 handle
AActor@  PlayerH;    // 显式 handle，用 @ 标注

// 显式 nullptr 检查
if (Player == nullptr) return;

// 取/赋值就是修改引用，不会复制 Actor 本身
Player = NewActor;
```

**经验法则**：UObject 类型 = 引用语义；不要试图"复制一个 Actor"——你只能引用同一个 Actor。

### 1.2 USTRUCT 与值类型按值语义

`FVector` / `FRotator` / `FTransform` / `FHitResult` / 自定义 `struct` 都是**值类型**，赋值时会拷贝整个结构。

```angelscript
FVector A(1.0, 2.0, 3.0);
FVector B = A;       // B 是新副本
B.X = 99.0;          // A 不受影响
check(A.X == 1.0);
```

容器（`TArray<T>` / `TMap<K, V>` / `TSet<T>` / `TOptional<T>`）也是值类型——赋值会复制整个容器。

### 1.3 函数参数的引用修饰符

值类型如果想避免拷贝、或者要写回调用方变量，需要显式标注引用方向：

```angelscript
// 输入 const 引用（推荐用于大结构体只读传参）
void DoSomething(const FVector&in Position) { }

// 输出引用（在函数内赋值，调用方拿到结果）
void GetSpawnLocation(FVector&out OutLocation)
{
    OutLocation = FVector(0.0, 0.0, 100.0);
}

// 双向引用（输入又输出）
void Mutate(FVector&inout InOut) { InOut.Z += 10.0; }
```

`UFUNCTION()` 的 `&out` 参数会在 Blueprint 节点上变成**右侧输出引脚**——这是 AS 暴露多返回值给蓝图的主要方式。

### 1.4 GC 自动回收

AS 没有 `delete`、没有 `Reset()` 析构，UObject 的生命周期完全交给 UE GC + AS 自身的引用计数 GC（`asCGarbageCollector`）。脚本类对 UObject 字段的强引用会自动登记到 GC schema，不需要手写。

```angelscript
class UInventory : UObject
{
    UPROPERTY()
    TArray<UItem> Items;          // 强引用 -> 阻止 GC
    TArray<UItem> ScratchPad;     // 无 UPROPERTY，但 AS 也会登记
}
```

唯一要注意的是**手动断开循环引用**——AS 自带循环引用 GC，但偶尔你会希望立刻让某个 actor 死掉：用 `Actor.DestroyActor()` 或 `Object.MarkAsGarbage()`。详细机制见 `Documents/Knowledges/ZH/AS_GarbageCollector.md`。

---

## 二、UPROPERTY / UFUNCTION 常用 50%

`UPROPERTY()` / `UFUNCTION()` 在 AS 里**不是 C++ 宏**，而是预处理器层识别的修饰符。完整 specifier 列表请去 `Syntax_UPROPERTY.md` / `Syntax_UFUNCTION.md` 查；本节只列日常 80% 场景里会用到的几个。

### 2.1 `UPROPERTY()` 高频 specifier

```angelscript
class APlayerStats : AActor
{
    // 编辑器中实例可编辑、Blueprint 可读写
    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Stats")
    float MaxHealth = 100.0;

    // 只读属性 -> 蓝图能读、节点中无 set pin
    UPROPERTY(BlueprintReadOnly, Category = "Stats")
    float CurrentHealth = 100.0;

    // 网络复制
    UPROPERTY(Replicated)
    int Score = 0;

    // 复制并触发 OnRep_Health 回调
    UPROPERTY(ReplicatedUsing = OnRep_Health)
    float ReplicatedHealth = 100.0;

    // 隐藏：编辑器面板看不见，但脚本/蓝图能用
    UPROPERTY(NotEditable, BlueprintReadOnly)
    bool bInternalFlag = false;

    // 编辑器只读（看得到、改不了）
    UPROPERTY(EditConst, BlueprintReadWrite)
    FName PlayerTag = n"Player";

    // 编辑期可编辑，运行期常量（用于配置默认值）
    UPROPERTY(EditDefaultsOnly, Category = "Config")
    float StartingMoney = 50.0;

    // Meta 直通（任意 UE 元数据均可写在 meta = (...) 里）
    UPROPERTY(EditAnywhere, meta = (ClampMin = "0.0", ClampMax = "1.0"))
    float Probability = 0.5;
}
```

**最常见的 6 个**：`EditAnywhere`（编辑器实例可编辑）/ `BlueprintReadWrite`（蓝图读写）/ `BlueprintReadOnly`（蓝图只读）/ `Replicated`（网络复制）/ `Category`（编辑器分组）/ `meta = (...)`（任意 UE 元数据）。

完整列表（`bInstanced` / `Transient` / `SaveGame` / `Interp` / `EditFixedSize` / `EditInline` / `Config` 等 30+ 项 + 70+ Meta key）见 `Syntax_UPROPERTY.md`。

### 2.2 `UFUNCTION()` 高频 specifier

```angelscript
class AWeapon : AActor
{
    // 默认就是"蓝图可调用"
    UFUNCTION()
    void Fire() { }

    // 纯函数：无副作用，蓝图节点无 exec pin，必须有返回值
    UFUNCTION(BlueprintPure)
    float GetAmmoPercent() { return CurrentAmmo / float(MaxAmmo); }

    // 蓝图可重写的事件（带默认实现）
    UFUNCTION(BlueprintEvent)
    void OnFired() { Print("Default fire VFX"); }

    // 重写 C++ / 父类的 BlueprintNativeEvent / BlueprintImplementableEvent
    UFUNCTION(BlueprintOverride)
    void BeginPlay() { /* 重写父类 BeginPlay */ }

    // 仅脚本/C++ 可调用，蓝图看不到（适合内部辅助）
    UFUNCTION(NotBlueprintCallable)
    void InternalReload() { }

    // 编辑器中显示成 Details 面板上的按钮
    UFUNCTION(CallInEditor, Category = "Tools")
    void RebuildPreview() { }

    // 网络 RPC：客户端调用 → 服务器执行
    UFUNCTION(Server, Reliable)
    void ServerFire() { }
}
```

**最常见的 5 个**：`BlueprintEvent`（声明可重写事件）/ `BlueprintOverride`（重写父类事件）/ `BlueprintPure`（纯函数）/ `Server` / `Client` / `NetMulticast`（RPC）/ `Category`（蓝图节点分组）。

完整列表（`BlueprintCosmetic` / `BlueprintAuthorityOnly` / `WithValidation` / `Exec` / `BlueprintGetter` / `BlueprintSetter` 等）与 C++ 头文件侧 Meta（`ScriptName` / `ScriptTrivial` / `ScriptMixin` / `WorldContext` / `DeterminesOutputType`）见 `Syntax_UFUNCTION.md`。

### 2.3 注释 = ToolTip

预处理器会把紧贴函数 / 属性上方的 `/** ... */` 注释挂为 UE 的 `ToolTip` 元数据，蓝图节点悬停时直接显示：

```angelscript
class AMyActor : AActor
{
    /** 玩家初始化时的最大血量上限 */
    UPROPERTY(EditAnywhere, Category = "Stats")
    float MaxHealth = 100.0;

    /**
     * 治疗指定数量。负数会被钳制为 0。
     * @param Amount  治疗量
     * @return        实际生效的治疗量
     */
    UFUNCTION(BlueprintCallable)
    float Heal(float Amount) { return 0.0; }
}
```

---

## 三、`default` 语句：声明式默认值

`default` 是 AS 写起来最舒服的语法糖之一——把 C++ 里通常塞在构造函数 / `ObjectInitializer` / `BeginPlay` 里的初始化代码，平铺成一行行声明语句。

### 3.1 覆盖父类属性

```angelscript
class ANetworkedEnemy : AActor
{
    // 等价于 C++ 构造函数中: bReplicates = true; bAlwaysRelevant = true;
    default bReplicates       = true;
    default bAlwaysRelevant   = true;
    default NetUpdateFrequency = 30.0;

    // 也可以调方法（见 §3.3）
    default Tags.Add(n"Enemy");
    default SetCanBeDamaged(true);
}
```

### 3.2 子类覆盖父类脚本属性

```angelscript
class APickupBase : AActor
{
    UPROPERTY() int Value = 10;
    UPROPERTY() FString DisplayName = "Generic";
}

class AGoldPickup : APickupBase
{
    default Value = 100;
    default DisplayName = "Gold Coin";
}

class ASilverPickup : APickupBase
{
    default Value = 50;
    default DisplayName = "Silver Coin";
}
```

### 3.3 `default` 可以调方法 / 数组操作

```angelscript
class AAuraActor : AActor
{
    UPROPERTY(DefaultComponent, RootComponent)
    USphereComponent Sphere;

    // 等价于构造函数里：Sphere->SetSphereRadius(500.f);
    default Sphere.SetSphereRadius(500.0);
    default Sphere.SetCollisionEnabled(ECollisionEnabled::QueryOnly);

    // 数组也支持
    default Tags.Add(n"Aura");
    default Tags.Add(n"Radial");
}
```

### 3.4 关键约束

- **`default` 只能写在类体顶层**，不在任何函数内。
- **不能写在 `struct` 里**——只允许 `class`。
- **执行时机**：对象构造期（在 `BeginPlay` 之前），由 AS 自动生成的 `__InitDefaults()` 函数集中执行。
- **不要在 default 里 `new` UObject**——用 `DefaultComponent` 修饰符（见 §四）。

完整原理（预处理器 → `__InitDefaults` 函数 → 构造时序）见 `Syntax_DefaultStatement.md`。

---

## 四、`DefaultComponent`：声明即创建

C++ 里写组件要 `CreateDefaultSubobject<T>(...)` + `RootComponent = ...` + `SetupAttachment(...)`，三步都不能漏。AS 把这些塞进 4 个 specifier 里，写起来像声明字段一样：

```angelscript
class AVehicle : AActor
{
    // 自动创建一个根 SceneComponent
    UPROPERTY(DefaultComponent, RootComponent)
    USceneComponent RootScene;

    // 自动创建并附着到 RootScene
    UPROPERTY(DefaultComponent, Attach = RootScene)
    UStaticMeshComponent Body;

    // 附着到 Body 的指定 socket
    UPROPERTY(DefaultComponent, Attach = Body, AttachSocket = "GunMount")
    UStaticMeshComponent Cannon;

    // 没 Attach 的 ActorComponent 也会自动创建
    UPROPERTY(DefaultComponent)
    UFloatingPawnMovement Movement;

    // 配合 default 设属性
    default Body.SetCollisionProfileName(n"Vehicle");
    default Cannon.SetRelativeLocation(FVector(50.0, 0.0, 0.0));
}
```

**4 个 specifier**：

| Specifier | 作用 |
|-----------|------|
| `DefaultComponent` | 声明此字段在 Actor 构造时自动创建组件实例 |
| `RootComponent` | 把这个组件设为 Actor 的根 |
| `Attach = Other` | 构造完成后自动附着到指定字段 |
| `AttachSocket = "Sock"` | 附着到指定 socket（要求 Attach 目标支持 socket） |

更多变体（`OverrideComponent` / `ShowOnActor`）与底层链路见 `Syntax_DefaultComponent.md`。

---

## 五、`delegate` / `event`：声明式委托

UE C++ 写多播委托要 `DECLARE_DYNAMIC_MULTICAST_DELEGATE_*` 一长串模板宏；AS 用两个关键字把它说清楚：

```angelscript
// 单播委托：等价于 DECLARE_DYNAMIC_DELEGATE_TwoParams(F..., UObject*, float)
delegate void FOnHit(UObject Source, float Damage);

// 多播事件：等价于 DECLARE_DYNAMIC_MULTICAST_DELEGATE_OneParam(F..., AActor*)
event void FOnGameOver(AActor Winner);

class APlayerActor : AActor
{
    // 暴露 event 作 UPROPERTY → 蓝图可绑定
    UPROPERTY(Category = "Events")
    FOnGameOver OnGameOver;

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        // 绑自身：n"Name" 是编译期 FName 字面量，省掉运行时 FName 构造
        OnGameOver.AddUFunction(this, n"HandleGameOver");
    }

    // 被绑回调必须是 UFUNCTION
    UFUNCTION()
    void HandleGameOver(AActor Winner)
    {
        Print(f"Winner = {Winner.Name}");
    }

    UFUNCTION()
    void TriggerGameOver()
    {
        // 多播：永远不会因为没绑而报错，无须先 IsBound 检查
        OnGameOver.Broadcast(this);
    }
}
```

**两个核心区别**：

| 关键字 | 绑定数 | 触发方法 |
|--------|--------|----------|
| `delegate` | 至多一个（单播） | `Execute(args)` 抛异常 / `ExecuteIfBound(args)` 静默 |
| `event` | 任意多个（多播） | `Broadcast(args)` |

**绑定 / 解绑** 都用 `BindUFunction(this, n"Func")` / `AddUFunction(this, n"Func")` / `Unbind()` / `RemoveAll(this)` / `Clear()`。被绑函数必须是 `UFUNCTION()`。详细底层（预处理器展开 + AS struct + UFunction 绑定路径）见 `Syntax_DelegateEvent.md`。

---

## 六、`access` 自定义授权

AS fork 在 `public/protected/private` 之外多加了一根可见性轴——`access`，能精确白名单"哪一组类 / 函数 / 命名空间能访问该字段"。常用于实现"仅 Capability Component 能修改这个属性"这类 Hazelight 风格的封装。

```angelscript
class UHealthCapability : UActorComponent { }

class APlayerActor : AActor
{
    // 声明一条 access 规则：起点 private，再放行 UHealthCapability
    access HealthAccess = private, UHealthCapability;

    // 应用规则到属性：除了本类、UHealthCapability 都看不见
    access:HealthAccess
    float CurrentHealth = 100.0;

    // 通配 + readonly 修饰：所有类都能读，但只有规则白名单里的能写
    access ReadAnyWriteOwn = private, UHealthCapability, * (readonly);

    access:ReadAnyWriteOwn
    int LastDamage = 0;

    // 全部类都能读，但只能在 default 块 / ConstructionScript 里编辑
    access EditOnlyInDefaults = private, * (editdefaults, readonly);

    UPROPERTY(EditDefaultsOnly, BlueprintReadOnly, Category = "Tuning")
    access:EditOnlyInDefaults
    bool bDebugTraceEnabled = false;
}
```

**access 修饰符**：

- `(readonly)` —— 仅允许读 / 调 const 方法
- `(editdefaults)` —— 仅允许在 `default` / `ConstructionScript` 中写
- `(inherited)` —— 白名单里的类的派生类也享受同样授权
- `*` —— 通配所有类，必须配合 `(readonly)` 或 `(editdefaults)` 使用

`access` 的运行时开销为零（编译期检查），不影响字节码。详细原理与跨模块语义见 `Syntax_AccessSpecifiers.md`。

---

## 七、`mixin`：非侵入式扩展方法

`mixin` 让你在不改父类源码的前提下给某个类型添加方法（类似 C# 扩展方法 / Kotlin 扩展函数）。第一个参数是"被扩展的类型"，调用时写成成员方法形式：

```angelscript
// 给 AActor 加一个方法
mixin void SnapToFloor(AActor Self, float Distance = 1000.0)
{
    FHitResult Hit;
    FVector Start = Self.ActorLocation;
    FVector End   = Start - FVector(0.0, 0.0, Distance);

    if (System::LineTraceSingle(Start, End, ETraceTypeQuery::Visibility, false, TArray<AActor>(), EDrawDebugTrace::None, Hit, true))
    {
        Self.SetActorLocation(Hit.ImpactPoint);
    }
}

// 给 FVector 加一个方法
mixin float DistanceTo2D(const FVector& Self, const FVector& Other)
{
    FVector Delta = Other - Self;
    return Math::Sqrt(Delta.X*Delta.X + Delta.Y*Delta.Y);
}

void DemoMixin()
{
    AActor Player;
    Player.SnapToFloor();              // 调用 mixin（非全局函数语法）
    Player.SnapToFloor(2000.0);        // 默认参数也支持

    FVector A(1.0, 0.0, 0.0);
    FVector B(4.0, 0.0, 5.0);
    float D = A.DistanceTo2D(B);       // = 3.0
}
```

**关键约束**：

- **第一个参数即调用者**——值 / 引用 / handle 都可以。
- **必须以方法语法调用** `Self.Method(...)`，不能写成 `Method(Self, ...)`。
- **AS fork 砍掉了 `mixin class`**——只支持 `mixin function`（与 UE UClass 单根继承模型对齐）。
- 跨模块时：调用方需要 `import` 定义 mixin 的模块。

C++ 头文件侧的 `UCLASS(meta=(ScriptMixin="AActor"))` 是另一条独立路径——同名概念，但实现完全分开。详细对照见 `Syntax_Mixin.md` 与 `Guide_ScriptMixin.md`（待写）。

---

## 八、f-string：现代化字符串拼接

AS 的 f-string 灵感来自 Python f-string + Rust `format!`，**编译期**展开为 `FString` 链式 `Append`，运行时零开销解析格式串：

```angelscript
UFUNCTION()
void FStringDemo()
{
    int Coins = 1573;
    float HP = 78.456;
    FVector Pos(100.0, 50.0, 25.0);
    FString Name = "Hero";

    // 基础插值
    Print(f"Hello {Name}, position = {Pos}");

    // 精度控制
    Print(f"HP: {HP :.1f}");                 // "HP: 78.5"

    // 自描述（debug 友好，自动打印变量名 + 值）
    Print(f"{HP =}");                         // "HP = 78.456"
    Print(f"{HP =:.0f}");                     // "HP = 78"

    // 整数进制
    Print(f"{Coins :d}");                     // "1573"
    Print(f"{Coins :#x}");                    // "0x625"
    Print(f"{Coins :,}");                     // "1,573"  (千分位)
    Print(f"{Coins :08d}");                   // "00001573"
    Print(f"{Coins :b}");                     // "11000100101"

    // 对齐
    Print(f"{Name :>10}");                    // "      Hero"
    Print(f"{Name :_<10}");                   // "Hero______"
    Print(f"{Name :^10}");                    // "   Hero   "

    // 枚举
    Print(f"{ESlateVisibility::Collapsed}");      // "ESlateVisibility::Collapsed (1)"
    Print(f"{ESlateVisibility::Collapsed :n}");   // "Collapsed"
}
```

f-string 完整格式说明符（`type / fill / align / sign / # / 0 / width / precision / specifier`）与扩展规则见 `Syntax_FString.md`。

---

## 九、容器与包装类型一览

AS 把 UE 的容器与智能指针都暴露成同名类型，用法 99% 与 C++ 一致；这一节给一张速查表 + 各一个最小示例，详细 API 与边界各自的 `Syntax_*.md` 里。

### 9.1 速查表

| 类型 | 用途 | 关键方法 / 操作 | 详细 |
|------|------|-----------------|------|
| `TArray<T>` | 动态数组 | `Add` / `Remove` / `RemoveAt` / `[]` / `Num()` / range-for / `Contains` / `FindIndex` / `Sort` | `Syntax_TArray.md` |
| `TMap<K, V>` | 哈希字典 | `Add` / `Remove` / `[]`（throws） / `Find(Key, OutVal)` / `FindOrAdd` / `Contains` / `Num()` | `Syntax_TMap.md` |
| `TSet<T>` | 哈希集合 | `Add` / `Remove` / `Contains` / `Num()` / range-for / `Intersect` / `Union` | `Syntax_TSet.md` |
| `TOptional<T>` | 可空值 | `Set(v)` / `IsSet()` / `GetValue()` / `Get(Fallback)` / `Reset()` | `Syntax_TOptional.md` |
| `TSubclassOf<T>` | 类型安全的 `UClass*` | 只允许赋值为 `T` 的子类，否则抛 AS 异常 + 重置为 `nullptr` | `Syntax_TSubclassOf.md` |
| `TWeakObjectPtr<T>` | UObject 弱引用 | `Get()` / `IsValid()` / `Reset()` | （见 `Syntax_TSoftObjectPtr.md` 同族对照） |
| `TSoftObjectPtr<T>` | 软引用资源 | `Get()` / `LoadSynchronous()` / `IsPending()` / `IsValid()` | `Syntax_TSoftObjectPtr.md` |
| `TSoftClassPtr<T>` | 软引用类 | 同 `TSoftObjectPtr` | `Syntax_TSoftObjectPtr.md` |
| `FInstancedStruct` | 类型擦除 USTRUCT | `InitializeAs<T>()` / `Get<T>()` / `GetMutable<T>()` / `Reset()` | `Syntax_FInstancedStruct.md` |

### 9.2 示例

```angelscript
UFUNCTION()
void ContainerCheatSheet()
{
    // ── TArray ──
    TArray<FString> Names;
    Names.Add("Alice");
    Names.Add("Bob");
    if (Names.Contains("Alice"))
        Names.Remove("Alice");
    for (FString N : Names)
        Log(f"Name: {N}");

    // ── TMap ──
    TMap<FString, int> Scores;
    Scores.Add("Bob", 85);
    int Out;
    if (Scores.Find("Bob", Out))
        Log(f"Bob = {Out}");

    // ── TSet ──
    TSet<int> Ids;
    Ids.Add(1); Ids.Add(2); Ids.Add(1);     // 去重 -> 2 个
    check(Ids.Num() == 2);

    // ── TOptional ──
    TOptional<int> Maybe;
    check(!Maybe.IsSet());
    Maybe.Set(42);
    check(Maybe.GetValue() == 42);
    Maybe.Reset();

    // ── TSubclassOf ──
    TSubclassOf<AActor> ClassRef = AActor::StaticClass();
    // ClassRef = UStaticMesh::StaticClass();   // ★ 抛异常 + 重置为 nullptr

    // ── TSoftObjectPtr ──
    TSoftObjectPtr<UTexture2D> SoftIcon;
    if (!SoftIcon.IsValid() && !SoftIcon.IsPending())
    {
        UTexture2D Loaded = SoftIcon.LoadSynchronous();
    }

    // ── FInstancedStruct ──
    FInstancedStruct Boxed;
    FExampleStruct Data;
    Data.ExampleNumber = 99.0;
    Boxed.InitializeAs(Data);
}
```

---

## 十、与 C++ 的差异速查表

下表汇总"在 C++ 里能写、在 AS 里不能 / 不必这样写"的高频差异——动笔前过一眼能避免大量低级困惑：

| 维度 | C++ | AngelScript | 备注 |
|------|-----|------------|------|
| **裸指针** | `T*` 全家桶 | ✗ 不存在 | 改用值 + handle (`@`) + GC |
| **指针算术** | `++p` / `p[i]` | ✗ 不支持 | `TArray<T>` 的 `[]` 是边界检查的 |
| **多继承** | `class C : A, B` | ✗ 仅单继承 | 与 UE UClass 一致；可实现多个 interface |
| **用户自定义模板** | `template<typename T> class Foo` | ✗ 不支持 | 只能用引擎已注册的 TArray / TMap / TSet / TOptional / TSubclassOf |
| **预处理宏** | `#define`、`#ifdef` | ✗（仅 `#include` / `#if EDITOR`） | 用 `class final` / `BlueprintEvent` / mixin 等替代 |
| **构造函数** | `AFoo::AFoo() { ... }` | ✗ 用 `default` 语句 + `BeginPlay` | 不要写自定义构造函数体 |
| **析构函数** | `~AFoo() { ... }` | ✗ 用 `EndPlay(EEndPlayReason)` | 资源清理走 EndPlay |
| **`new` / `delete`** | 手动 | ✗ 用 `NewObject<T>()` / `SpawnActor<T>()` + GC | 不要试图"释放" |
| **friend** | `friend class Bar` | ✗ 用 `access` | `access X = private, Bar` |
| **`enum class`** | UE 推荐 | ✓ 用 `enum` 即可（默认强类型） | 不需要写 `class` |
| **`namespace`** | 支持 | ✓ scoped namespace | `namespace Math { ... }` |
| **`const` 成员函数** | `void f() const` | ✓ 同样语法 | 推荐尽量加 `const` |
| **运算符重载** | `operator+` | ✓ `opAdd` / `opEquals` / `opCmp` 等 | 命名 AS 风格 |
| **`auto`** | 类型推导 | ✓ 同样支持 | 在 range-for / 容器迭代时常用 |
| **lambda** | `[](){}` | ✓ `function(...) { ... }` | 见 `AS_LanguageSyntax.md` |
| **Live Coding 热重载** | C++ 受限 | ✓ 一等公民，保存即生效 | 函数体改 = 软重载；签名改 = 全量重载 |

---

## 十一、入门常见误区

下列错误模式在新手脚本里频繁出现——动笔前过一眼能省一堆调试时间：

### 11.1 把 UObject 当值来"复制"

```angelscript
// ✗ 错误期望
AActor Original = SpawnActor(...);
AActor Copy = Original;       // ★ 这只是引用同一个 Actor，不是复制
Copy.SetActorLocation(...);   // 也修改了 Original

// ✓ 正确做法：要新对象就 SpawnActor / NewObject
AActor Another = SpawnActor(MyClass, Original.ActorLocation);
```

### 11.2 在 `default` 里写运行时表达式

```angelscript
class AMyActor : AActor
{
    UPROPERTY() FVector StartPos;

    // ✗ 不行：default 在构造期执行，此时 ActorLocation 还没初始化
    default StartPos = ActorLocation;

    // ✓ 改去 BeginPlay
    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        StartPos = ActorLocation;
    }
}
```

### 11.3 给 `struct` 里的字段加 `default`

```angelscript
struct FConfig
{
    int Count = 5;          // ✓ 字段初始化 OK

    // ✗ 错误：default 仅 class 可用
    // default Count = 10;
}
```

### 11.4 期望委托回调函数能不带 `UFUNCTION()`

```angelscript
class AActor1 : AActor
{
    UPROPERTY() FOnFire OnFire;

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        // ✗ 失败：HandleFire 不是 UFUNCTION，无法被 AddUFunction 找到
        OnFire.AddUFunction(this, n"HandleFire");
    }

    void HandleFire() { }            // ★ 缺 UFUNCTION()

    // ✓ 正确：所有被 AddUFunction / BindUFunction 绑定的函数都必须是 UFUNCTION
    // UFUNCTION()
    // void HandleFire() { }
}
```

### 11.5 `n"FName"` 写成 `"FName"`

```angelscript
// ✗ 运行时构造 FName，多次调用会重复哈希
OnFire.AddUFunction(this, FName("HandleFire"));

// ✓ n"..." 是编译期 FName 字面量，零运行时开销
OnFire.AddUFunction(this, n"HandleFire");
```

### 11.6 误以为 `[]` 在 TMap 里像 C++ 那样会自动插入

```angelscript
TMap<FString, int> Scores;

// ✗ TMap 的 [] 在键不存在时**抛异常**（不是默认插入）
int x = Scores["MissingKey"];     // throws

// ✓ 用 Find 或 FindOrAdd
int Out;
if (Scores.Find("MissingKey", Out)) { /* ... */ }

int& Slot = Scores.FindOrAdd("MissingKey");      // 不存在则插入 0
Slot = 99;
```

### 11.7 修改 struct 字段后忘了重启编辑器

加了 `UPROPERTY()`、改了字段类型、加了字段 = **结构变更** → 需要全量重载，PIE 中不会即时生效（结构变更必须退出 PIE 再保存）。函数体修改才是软重载。详细决策表见 `Syntax_UFUNCTION.md` §10、`Syntax_UPROPERTY.md` §十二。

### 11.8 想用 `template<>` 写自定义模板类

AS 只允许使用引擎已注册的模板（`TArray` / `TMap` / `TSet` / `TOptional` / `TSubclassOf` / `TWeakObjectPtr` / `TSoftObjectPtr` / `TSoftClassPtr`）。**不能用户自定义新模板**。如果遇到"想要泛型容器"的需求，要么换具体类型、要么用 `FInstancedStruct` 装载任意 USTRUCT。

---

## 附录 A：常用语法速查

```angelscript
// ── 类继承 ──
class AMyActor : AActor                       // Actor
class UMyComponent : UActorComponent          // Component
class AMyChar : ACharacter                    // Character
struct FMyData                                // 值类型
enum EMyState { Idle, Running, Dead }
delegate void FMySingle(int x);
event    void FMyMulti(AActor a);

// ── 修饰符 ──
UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Stats")
UPROPERTY(Replicated)
UPROPERTY(ReplicatedUsing = OnRep_X)
UPROPERTY(DefaultComponent, RootComponent)
UPROPERTY(DefaultComponent, Attach = Root, AttachSocket = "Sock")
UPROPERTY(meta = (ClampMin="0", ClampMax="1"))
UFUNCTION(BlueprintCallable)
UFUNCTION(BlueprintPure)
UFUNCTION(BlueprintEvent)
UFUNCTION(BlueprintOverride)
UFUNCTION(NotBlueprintCallable)
UFUNCTION(CallInEditor)
UFUNCTION(Server, Reliable, WithValidation)

// ── default ──
default bReplicates = true;
default Mesh.SetCollisionProfileName(n"Vehicle");
default Tags.Add(n"MyTag");

// ── access ──
access MyAcc = private, UCmp(readonly), * (editdefaults);
access:MyAcc int Field;

// ── 引用方向 ──
void f(const FVector&in In)    { }    // 只读引用
void g(FVector&out Out)         { }   // 输出
void h(FVector&inout InOut)     { }   // 双向

// ── 委托绑定 ──
OnFire.AddUFunction(this, n"HandleFire");      // event
OnHit .BindUFunction(this, n"HandleHit");      // delegate
OnFire.RemoveAll(this);
OnFire.Broadcast(args);
OnHit .ExecuteIfBound(args);

// ── 容器 ──
TArray<int> A; A.Add(1); A.RemoveAt(0); for (int v : A) {}
TMap<FString,int> M; M.Add("k",1); M.Find("k",Out); M.FindOrAdd("k") = 2;
TSet<int> S; S.Add(1); S.Contains(1);
TOptional<int> O; O.Set(1); O.IsSet(); O.GetValue();
TSubclassOf<AActor> C = AActor::StaticClass();
TSoftObjectPtr<UTexture2D> Soft; Soft.LoadSynchronous();

// ── f-string ──
Print(f"x = {Value :.2f}");
Print(f"{Var =}");                            // 自描述
Print(f"{Coins :,}");                         // 千分位
Print(f"{Enum :n}");                          // 仅枚举名

// ── mixin ──
mixin void Method(AActor Self, FVector Loc) { }
Player.Method(FVector::ZeroVector);
```

---

## 附录 B：下一步去读哪个 Knowledges

| 我想 ... | 该读 |
|---------|------|
| 拿到一个能跑的脚本 | `Guide_QuickStart.md` |
| 弄清楚引擎怎么编译我的 .as | `Guide_RuntimeLifecycle.md`（待写） |
| 把 C++ 类暴露给 AS | `Guide_ClassBinding.md`（待写） |
| 给现有类加扩展方法 | `Guide_ScriptMixin.md`（待写） |
| 委托使用与封装 | `Guide_DelegateSystem.md`（待写） |
| VS Code 断点调试 | `Guide_Debugging.md`（待写） |
| `UPROPERTY()` 完整 specifier 列表 | `Syntax_UPROPERTY.md` |
| `UFUNCTION()` 完整 specifier + C++ 头侧 Meta | `Syntax_UFUNCTION.md` |
| `default` 究竟怎么展开成构造代码 | `Syntax_DefaultStatement.md` |
| f-string 完整格式说明符表 | `Syntax_FString.md` |
| `access` 跨模块语义 / 自定义授权细节 | `Syntax_AccessSpecifiers.md` |
| 容器底层（FScriptArray / FScriptMap） | `Syntax_TArray.md` / `Syntax_TMap.md` / `Syntax_TSet.md` |
| `TSubclassOf` / `TSoftObjectPtr` 等包装类型 | `Syntax_TSubclassOf.md` / `Syntax_TSoftObjectPtr.md` 等 |
| AngelScript 语言完整语法 EBNF | `AS_LanguageSyntax.md` |
| 与 C++/Blueprint 的整体边界 | `Arch_Overview.md`（待写） |

---

## 小结

- **内存语义**：UObject 默认是 handle（`@` 引用）、struct/容器按值拷贝；写引用参数用 `&in / &out / &inout`，让 UFUNCTION 自动暴露成蓝图节点的输入/输出引脚。
- **修饰符**：`UPROPERTY()` 只用 `EditAnywhere / BlueprintReadWrite / BlueprintReadOnly / Replicated / Category / meta` 已能覆盖 80% 场景；`UFUNCTION()` 只用 `BlueprintEvent / BlueprintOverride / BlueprintPure / NotBlueprintCallable / Server|Client|NetMulticast`，更多 specifier 见 `Syntax_*` 文档。
- **声明式糖**：`default` 把 C++ 构造函数压成单行；`DefaultComponent / Attach / RootComponent` 把组件创建+附着压成 specifier 组合；`delegate / event` 把 DECLARE_DYNAMIC_*_DELEGATE 压成两个关键字；`access` 在 `public/protected/private` 之外开了"按调用方"白名单的可见性轴。
- **现代糖**：f-string `f"..."` 编译期展开为 `FString` 链式调用、零运行时开销；`mixin` 给现有类型加扩展方法（第一参 = 调用者）；容器与包装类型与 UE 同名同 API。
- **约束**：无裸指针 / 无指针算术 / 无用户自定义模板 / 无多继承 / 无析构函数（用 `EndPlay`）；`new`/`delete` 全部交给 GC + `NewObject` / `SpawnActor`。
- **下一步**：拿 `Guide_QuickStart.md` 的 16 个案例先 copy 跑通；遇到 specifier 细节翻 `Syntax_*` 系列；遇到 C++ 绑定 / 子系统 / 网络等场景去对应的 `Guide_*` 实践指南。
