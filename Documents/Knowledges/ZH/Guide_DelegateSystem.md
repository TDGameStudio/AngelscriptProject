# Guide_DelegateSystem — 单播 / 多播委托声明与使用（脚本作者视角）

> **所属前缀**: Guide_（实践指南族）
> **适用读者**: 在 `.as` 里写游戏逻辑的脚本作者——你想声明事件、订阅 / 解绑、广播；想知道 C++ 的 `DECLARE_DYNAMIC_*_DELEGATE` 在脚本里长什么样；想知道脚本声明的 `event` 怎么被蓝图绑定。
> **前置知识**: 看完 `Documents/Knowledges/ZH/Guide_QuickStart.md` 案例 7「委托与事件」；了解 `UFUNCTION()` / `UPROPERTY()` 基础修饰符。
> **关联 Knowledges**:
> `Documents/Knowledges/ZH/Guide_QuickStart.md` — 入门级 delegate / event 案例
> · `Documents/Knowledges/ZH/Guide_SyntaxFeatures.md` — §五 `delegate` / `event` 速览
> · `Documents/Knowledges/ZH/Guide_ClassBinding.md` — §七 C++ 端如何暴露 Delegate 给脚本
> · `Documents/Knowledges/ZH/Syntax_DelegateEvent.md` — 实现原理（预处理器代码展开 / 运行时调用链）
> · `Documents/Knowledges/ZH/Type_BindSystem.md` — Bind_Delegates.cpp 在三层 Bind 模型中的位置
> **外部参考**:
> [UE Dynamic Delegates 官方文档](https://docs.unrealengine.com/5.0/en-US/dynamic-delegates-in-unreal-engine/)

---

## 概览

本文聚焦一个核心问题：**我想在 `.as` 里声明事件、订阅、广播，要怎么写？以及脚本里的 `delegate` / `event` 跟 UE 的 `DECLARE_DYNAMIC_*_DELEGATE` 是什么关系？**

UE C++ 暴露事件接口时要写一长串模板宏：

```cpp
DECLARE_DYNAMIC_DELEGATE_OneParam(FOnHit, AActor*, HitActor);
DECLARE_DYNAMIC_MULTICAST_DELEGATE_TwoParams(FOnGameOver, AActor*, Winner, int32, Score);
```

AS 把这一族宏压缩成两个关键字：

```angelscript
delegate void FOnHit(AActor HitActor);                       // 单播
event    void FOnGameOver(AActor Winner, int32 Score);        // 多播
```

然后用一致的 `BindUFunction / AddUFunction / Execute / Broadcast / Clear` API 操作。本文不讲实现原理（那是 `Syntax_DelegateEvent.md` 的活），只回答**作为脚本作者应该怎么写、怎么调、怎么调试**。

```text
+-------------------------------------------------------------------+
|         脚本作者的委托决策树                                        |
+-------------------------------------------------------------------+

  需要回调?  No -> 直接函数调用
            Yes
              |
              +- 一对一 + 可能带返回值 + 不需蓝图绑    -> delegate (单播)
              |     .Execute() 抛异常 / .ExecuteIfBound() 静默
              |
              +- 一对多 + 蓝图也想绑 + 不需返回值      -> event (多播)
                    UPROPERTY() + .Broadcast()

后续章节按 一/二/.../十 顺序展开:
  一、AS 关键字与 UE 宏对应     六、订阅 C++ 声明的 Delegate
  二、最小可运行案例             七、参数传递: 值 / 引用 / UObject*
  三、单播 delegate              八、生命周期与解绑陷阱
  四、多播 event                 九、性能与 hot-fire 注意点
  五、与 Blueprint 互操作        十、调试: 没触发的诊断流程
```

---

## 一、AS 的两个关键字与 UE 宏的对应

### 1.1 一行对照

| AS 关键字 | 等价的 UE 宏 | 绑定数 | 触发方法 |
|----------|-------------|-------|---------|
| `delegate void F...(...)` | `DECLARE_DYNAMIC_DELEGATE[_*Params]` | 至多一个 | `Execute()` / `ExecuteIfBound()` |
| `event void F...(...)` | `DECLARE_DYNAMIC_MULTICAST_DELEGATE[_*Params]` | 任意多个 | `Broadcast()` |

> **AS 不支持非 dynamic delegate**：UE C++ 还有 `DECLARE_DELEGATE` / `DECLARE_MULTICAST_DELEGATE`（非反射、不可序列化、不可蓝图绑定）。脚本侧只能用 dynamic 系列——你写的 `delegate / event` 关键字**默认就是 dynamic delegate**，无需也无法切换。这意味着：

- 脚本声明的委托总是带 UE 反射 `UDelegateFunction*`，蓝图能看见
- 脚本声明的委托可以序列化（持久化保存绑定）
- 但单次 Broadcast 比 raw multicast 慢（要走 ProcessEvent）

如果你看到 C++ 同事写了一个 `DECLARE_MULTICAST_DELEGATE_OneParam`（无 DYNAMIC），脚本**绑不上、看不见**——必须改成 `DECLARE_DYNAMIC_MULTICAST_DELEGATE_OneParam` 才能被 AS 端使用。

### 1.2 BlueprintAssignable / BlueprintCallable 的语义

C++ 端给 `UPROPERTY` 加 `BlueprintAssignable` 蓝图才能 `Bind Event`，加 `BlueprintCallable` 才能调 Broadcast 节点。AS 端**不需要这两个修饰符**——只要把 `event` 字段标 `UPROPERTY()`，蓝图就能 Bind / Add / Remove / 主动 Broadcast：

```angelscript
class APlayerActor : AActor
{
    // 等价 C++ 的 UPROPERTY(BlueprintAssignable, BlueprintCallable, Category="Events")
    UPROPERTY(Category = "Events")
    FOnGameOver OnGameOver;
}
```

### 1.3 单播 vs 多播 vs Sparse 的脚本支持矩阵

| C++ 宏 | UE 类型 | 脚本可声明？ | 脚本可订阅 / 触发？ | 脚本可作 UPROPERTY？ |
|--------|--------|-------------|------------------|------------------|
| `DECLARE_DYNAMIC_DELEGATE_*` | `FScriptDelegate` | ✅ `delegate` 关键字 | ✅ | ✅ |
| `DECLARE_DYNAMIC_MULTICAST_DELEGATE_*` | `FMulticastScriptDelegate` | ✅ `event` 关键字 | ✅ | ✅ |
| `DECLARE_DYNAMIC_*_SPARSE_DELEGATE_*` | `FSparseDelegate` (8B 句柄) | ❌（仅 C++ 声明） | ✅ | ✅ |
| `DECLARE_DELEGATE` / `DECLARE_MULTICAST_DELEGATE`（非 dynamic） | 非反射 | ❌ | ❌ | ❌ |

> **Sparse delegate**：稀疏委托是 UE 内存优化方案（未绑定时不占空间）。脚本端不能声明，但能消费 C++ 暴露的 sparse 字段——使用方式与普通 `event` 完全一致，唯一限制是不能作为函数参数 / 返回值传递。

---

## 二、最小可运行案例

来自项目自带 `Script/Examples/Core/Example_Delegates.as`（节选）：

```angelscript
// 文件顶层声明（不能写在 class / 函数体内）
delegate void FExampleDelegate(UObject Object, float Value);
event    void FExampleEvent(UObject Object, float Value);

UFUNCTION()
void ExecuteExampleDelegate(FExampleDelegate InDelegate)
{
    if (!InDelegate.IsBound()) { Log("Unbound."); return; }
    InDelegate.Execute(nullptr, 5.4);                       // 抛异常版本
    InDelegate.ExecuteIfBound(nullptr, 1.0);                // 静默版本
}

class AExampleEventActor : AActor
{
    UPROPERTY(Category = "Example Events")
    FExampleEvent ExampleEvent;                             // event 作 UPROPERTY -> 蓝图可绑

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        ExampleEvent.Broadcast(nullptr, 100.0);             // Broadcast 永不抛错, 零监听者也安全
    }

    UFUNCTION()
    void ExampleFunction(UObject InObject, float InValue) { Log("ExampleFunction: " + InValue); }

    UFUNCTION()
    void BindExampleDelegates()
    {
        ExampleEvent.AddUFunction(this, n"ExampleFunction");        // 多播订阅
        ExampleEvent.Broadcast(nullptr, 12.5);

        FExampleDelegate Local;
        Local.BindUFunction(this, n"ExampleFunction");              // 单播订阅
        ExecuteExampleDelegate(Local);                              // 单播可作函数参数 (多播不行)
    }
};
```

**三个观察**：

1. `delegate / event` 必须写在**文件顶层**（不能嵌套在 class / 函数内）。
2. `n"ExampleFunction"` 是编译期 `FName` 字面量，比运行时 `FName("...")` 构造快——绑定路径里**永远用 `n""` 前缀**。
3. 被 `Bind / Add` 的目标函数**必须是 `UFUNCTION()`**——AS 普通成员函数（无 `UFUNCTION`）没注册到 UE 反射，绑定时会报 `"function not found"`。

---

## 三、单播 `delegate` 完整玩法

### 3.1 声明

```angelscript
delegate void FOnReady();                                        // 无参，无返回值
delegate void FOnDamage(int32 Amount, AActor Instigator, FVector HitLocation);  // 多参
delegate bool FCanInteract(int32 Querier);                       // 带返回值
delegate void FOnHealthChanged(int32 NewHealth, const FString& Label);  // const 引用 (零拷贝)
```

**约束**：必须文件级唯一；以分号结尾，不能带 `{ }`；不能嵌套在 class / 函数内。约定 `F` 前缀（不强制，但项目代码风格统一遵守）。

### 3.2 单播的四种 API

```angelscript
class APickup : AActor
{
    UPROPERTY()
    FOnReady OnReady;

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        OnReady.BindUFunction(this, n"HandleReady");        // 绑定
        if (OnReady.IsBound())                              // 查询
        {
            UObject Target = OnReady.GetUObject();
            FName  TargetFn = OnReady.GetFunctionName();
        }
        OnReady.Execute();                                  // 触发: 未绑定 -> 抛 "Executing unbound delegate."
        OnReady.ExecuteIfBound();                           // 触发: 未绑定 -> 静默 return
        OnReady.Clear();                                    // 解绑 (单播只能整体清空)
    }

    UFUNCTION()
    void HandleReady() { Print("Ready!"); }
}
```

### 3.3 单播作为函数参数 + 带返回值

单播是值类型（背后是 `FScriptDelegate`），可以按值传递；返回类型直接跟随声明：

```angelscript
delegate void FOnDone(int Result);
delegate bool FCanInteract(int32 Querier);

UFUNCTION()
void RunAsync(FOnDone OnComplete)
{
    OnComplete.ExecuteIfBound(42);                          // 异步结束时回调
}

class AActorPicker : AActor
{
    UPROPERTY()
    FCanInteract InteractRule;

    UFUNCTION()
    bool TryInteract(int32 PlayerId)
    {
        if (!InteractRule.IsBound())
            return true;                                    // 默认允许
        return InteractRule.Execute(PlayerId);              // 抛异常版本; ExecuteIfBound 未绑定则返回类型默认值
    }
}
```

> 单播按值传是**完全安全**的：`FScriptDelegate` 内部只持有 `TWeakObjectPtr<UObject> + FName`，不会拷贝大对象。但**多播 `event` 不能这样按值传**——见 §4.2。
>
> **多播不支持带返回值**——多个监听者每人返回一个值，UE 没办法决定保留谁的，编译期直接报错。需要"投票表决"语义请用单播或自己写迭代。

### 3.4 快捷构造

预处理器为 `delegate` 额外生成了"一步绑定"的构造函数（多播 `event` 没有，因为多播是累积语义）：

```angelscript
// FOnReady(this, n"HandleReady") = 默认构造 + BindUFunction
FOnReady Quick(this, n"HandleReady");

// 直接传给函数
RunAsync(FOnDone(this, n"OnAsyncDone"));
```

---

## 四、多播 `event` 完整玩法

### 4.1 声明

```angelscript
event void FOnTick();
event void FOnHealthChanged(float NewHealth);
event void FOnGameEvent(FString EventName, int32 Data, bool bImportant);

// 多播不支持返回值！下行编译期报错：
// event int FOnVoteResult();    // ❌ ScriptCompileError
```

### 4.2 关键差异：多播不能作函数参数

```angelscript
event void FOnDamaged(int32 Damage);

UFUNCTION()
void Subscribe(FOnDamaged InEvent)         // ❌ 编译期报错: events cannot be passed as arguments
{
    InEvent.AddUFunction(...);
}
```

**为什么**：多播底层 `FMulticastScriptDelegate` 持有 `TArray<FScriptDelegate>` 调用列表，按值传会复制订阅表，得到的是"快照"——之后再加监听者的话原 event 看不到，Broadcast 路径会割裂，造成的 bug 极难诊断。引擎设计上直接禁止。

**正确做法**：把多播作为 `UPROPERTY` 暴露在持有者上，订阅者通过持有者访问：

```angelscript
class APlayerHealth : UActorComponent
{
    UPROPERTY(Category = "Events")
    FOnDamaged OnDamaged;
}

class AHUD : AActor
{
    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        APlayerHealth Health = ...;
        // ✅ 通过持有者间接订阅
        Health.OnDamaged.AddUFunction(this, n"HandleHUDDamaged");
    }
}
```

### 4.3 多播的六种 API

```angelscript
class AScoreManager : AActor
{
    UPROPERTY(Category = "Events")
    FOnScoreChanged OnScore;

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        OnScore.AddUFunction(this, n"HandleA");         // 订阅 (内部 AddUnique, 同 obj+name 不重复)
        OnScore.AddUFunction(this, n"HandleB");
        OnScore.AddUFunction(SomeOtherActor, n"HandleC");

        OnScore.Broadcast(100);                         // 触发 (永不抛错, 零监听者也安全)

        bool bHasListener = OnScore.IsBound();          // 查询
        OnScore.Unbind(this, n"HandleA");               // 按 (Object + FName) 精确解绑
        OnScore.UnbindObject(this);                     // 按 Object 解绑该对象的所有订阅
        OnScore.Clear();                                // 全部清空
    }
}
```

> **小心 AddUFunction 不去重的语义**：同一对(Object, FName)反复 `AddUFunction` 不会重复触发；但**不同 FName 指向同一对象**会按字面计入两条订阅。

### 4.4 配合 BlueprintOverride 在派生蓝图中订阅

`event UPROPERTY` 默认带 BlueprintAssignable 语义，蓝图直接可见。蓝图侧持有 `AGameRules` 引用 → 拖出引脚 `Bind Event to OnGameOver` → 创建 Custom Event 连入。蓝图绑的事件和脚本 `AddUFunction` 绑的事件**共享一个调用列表**，一次 `Broadcast` 全部触发。

---

## 五、与 Blueprint 互操作

### 5.1 脚本声明的 event 蓝图能看见

```angelscript
class AArena : AActor
{
    UPROPERTY(Category = "Match")
    FOnGameStart OnGameStart;                       // 蓝图自动可见 (UPROPERTY 即获 BlueprintAssignable)

    UFUNCTION()
    void StartMatch() { OnGameStart.Broadcast(); }  // 蓝图绑的 Custom Event 也会触发
}
```

蓝图侧使用 AS 类作为父类后，`UPROPERTY` event 字段自动出现在右侧 Details 面板，可拖出 `Bind Event to OnGameStart` 节点。蓝图绑的事件和脚本 `AddUFunction` 绑的事件**共享一个调用列表**——一次 `Broadcast` 全部触发。

蓝图的 `Event Dispatcher` 反过来也是普通 multicast delegate property，脚本拿到对象引用后照常 `AddUFunction` 即可。

### 5.2 BlueprintAssignable / BlueprintCallable 语义对照

| 修饰符 | C++ 必需？ | AS 必需？ | 含义 |
|--------|----------|----------|------|
| `BlueprintAssignable` | 是（否则蓝图看不见） | **不需要**（`UPROPERTY()` 即获得） | 蓝图能 Bind / Add / Remove |
| `BlueprintCallable` | 是（否则蓝图不能调 Broadcast） | **不需要**（默认允许） | 蓝图能调 Broadcast 节点 |
| `Category="..."` | 推荐（细分蓝图节点分组） | 推荐 | 蓝图右侧 Details 分组显示 |

---

## 六、订阅 C++ 声明的 Delegate

### 6.1 标准路径：BindUFunction / AddUFunction

C++ 端声明 dynamic delegate 后（详见 `Guide_ClassBinding.md` §七），脚本侧**直接可见**——`Bind_Delegates.cpp` 在引擎启动时遍历所有 `UDelegateFunction*` 自动注册：

```cpp
// 文件: YourGame/Public/MyEvents.h
DECLARE_DYNAMIC_MULTICAST_DELEGATE_TwoParams(FMyOnGameOver, AActor*, Winner, int32, FinalScore);

UCLASS()
class YOURGAME_API AMyArena : public AActor
{
    GENERATED_BODY()
public:
    UPROPERTY(BlueprintAssignable, Category = "Events")
    FMyOnGameOver OnGameOver;
};
```

```angelscript
class AMyArenaController : AActor
{
    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        AMyArena Arena = Cast<AMyArena>(GetOwner());
        if (Arena != nullptr)
            Arena.OnGameOver.AddUFunction(this, n"HandleGameOver");
    }

    UFUNCTION()
    void HandleGameOver(AActor Winner, int32 FinalScore)
    {
        Print(f"Game over! Winner={Winner.Name} Score={FinalScore}");
    }
}
```

### 6.2 脚本里没有 `BindUObject` / `BindLambda`

UE C++ raw delegate 的 `BindUObject` / `BindLambda` / `BindRaw` **在脚本里都不存在**——dynamic delegate 的本质就是 `(WeakObjectPtr, FName)`，脚本能给的就只有这俩；AS 也不支持 lambda 或成员函数指针语法。脚本端只有一种绑定方式：

```angelscript
SomeDelegate.BindUFunction(Object, n"FunctionName");   // 目标必须是 UFUNCTION()
```

**绕过 lambda 捕获的办法**：把"捕获变量"改写成 class 字段，再绑命名 UFUNCTION：

```angelscript
class ALevelLogic : AActor
{
    int CapturedItemId = 0;     // 替代 lambda 捕获

    UFUNCTION()
    void OnItemPickedUp() { Print(f"Picked up item {CapturedItemId}"); }

    UFUNCTION()
    void TriggerPickup(int ItemId, FOnPickup Cb)
    {
        CapturedItemId = ItemId;
        Cb.BindUFunction(this, n"OnItemPickedUp");
        Cb.Execute();
    }
}
```

### 6.3 等价对照速查

| C++ raw delegate API | AS 等价 |
|---------------------|--------|
| `MyDelegate.BindUObject(Obj, &Class::Fn)` | `MyDelegate.BindUFunction(Obj, n"Fn")` （Fn 必须 UFUNCTION） |
| `MyDelegate.BindUFunction(Obj, "Fn")` | 同上（**首选 `n""` 编译期 FName**） |
| `MyDelegate.BindLambda([](...){...})` | ❌ 不支持，写 UFUNCTION 包装函数 |
| `MyDelegate.BindRaw(...)` | ❌ 不支持 |
| `MyDelegate.AddDynamic(this, &Class::Fn)` | `MyDelegate.AddUFunction(this, n"Fn")` |
| `MyDelegate.RemoveDynamic(this, &Class::Fn)` | `MyDelegate.Unbind(this, n"Fn")` |
| `MyDelegate.RemoveAll(this)` | `MyDelegate.UnbindObject(this)` |
| `MyDelegate.Clear()` | `MyDelegate.Clear()` |
| `MyDelegate.Execute(args)` | `MyDelegate.Execute(args)` |
| `MyDelegate.ExecuteIfBound(args)` | `MyDelegate.ExecuteIfBound(args)` |
| `MyDelegate.Broadcast(args)` | `MyDelegate.Broadcast(args)` |
| `MyDelegate.IsBound()` | `MyDelegate.IsBound()` |

---

## 七、参数传递：值 / 引用 / UObject*

### 7.1 三种参数风格

```angelscript
event void FOnUpdate(
    int32 Counter,                  // [a] 值类型: 拷贝传入
    const FString& Tag,             // [b] const 引用: 零拷贝, 不可改 (大对象首选)
    AActor Instigator,              // [c] UObject*: 引擎对象指针 (用前判 nullptr / IsValid)
    FVector& OutImpact);            // [d] 可变引用 (out): 监听者可回写
```

> **out 参数回写**：引擎对**非 const 引用参数**有特殊处理——调用结束后会 `CopyValue` 回写到调用者的原始变量。多播 event 的 out 参数**只保留最后一个监听者的写入值**（按订阅顺序覆盖），与 UE 蓝图 multicast 节点语义一致。

### 7.2 UObject 引用的"延迟死亡"

监听者函数被调用时，参数里的 `AActor / UObject` 可能已经被 `DestroyActor` / GC 标记为待销毁——**永远在使用前判 null + IsValid**：

```angelscript
UFUNCTION()
void HandleHit(AActor Instigator, float Damage)
{
    if (Instigator == nullptr || !IsValid(Instigator))
        return;
    Print(f"Hit by {Instigator.Name}");
}
```

### 7.3 限制

- **单次调用最多 16 参数**（引擎硬限制 `AS_EVENT_MAX_ARGS=16`）
- **参数总字节数 ≤ 1024**（`AS_EVENT_MAX_SIZE=1024`，超限直接 `check` 断言）
- **不能传 sparse delegate / multicast event 作参数**（编译期报错）

实践中超过 4-5 个参数就该考虑用 struct 打包：

```angelscript
struct FBigEventPayload { int32 A; FString B; FVector C; AActor D; };
event void FOnBigEvent(const FBigEventPayload& Payload);
```

---

## 八、生命周期与解绑陷阱

### 8.1 弱引用机制：监听者销毁不会引发崩溃

dynamic delegate 内部用 `TWeakObjectPtr<UObject>`——监听者 Actor 被 `DestroyActor` 后，`Broadcast` 触发到该项时**自动跳过**，不会崩溃，但订阅项还残留在调用列表里直到下次 Broadcast 自然清理。

### 8.2 显式解绑的最佳实践

虽然弱引用兜底，**仍强烈推荐显式解绑**——避免列表碎片化、防止偶发 race。标准模式是 `BeginPlay` 订阅、`EndPlay` 解绑：

```angelscript
class AListener : AActor
{
    AScoreManager Subject;

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        Subject = ...;
        Subject.OnScore.AddUFunction(this, n"HandleScore");
    }

    UFUNCTION(BlueprintOverride)
    void EndPlay(EEndPlayReason Reason)
    {
        if (Subject != nullptr)
            Subject.OnScore.UnbindObject(this);     // ★ 显式解绑, 不要等弱指针失效
    }

    UFUNCTION()
    void HandleScore(int32 NewScore) { /* ... */ }
}
```

> dynamic delegate 用弱指针**不会**引起 GC 死锁——这是 AS 不需要 `WeakBindLambda` 的根本原因。但**不要自己再开一份 `TArray<AActor>` 强引用列表存监听者**，会卡 GC。

### 8.3 热重载下的绑定保持

脚本热重载（保存 .as → 立即生效）会重新编译 AS 类，但**已绑定的回调通过 (UObject + FName) 维系**——只要目标函数名 `HandleScore` 还在，绑定继续有效。

但有两类变更会导致绑定失效：

| 变更 | 影响 | 处理 |
|-----|------|-----|
| 改 `delegate / event` 签名（参数类型 / 数量 / 返回值） | 已绑定项**签名校验失败**，下次触发抛 `"Specified function is not compatible with delegate function."` | 重启 PIE / 重新订阅 |
| 改回调函数名（`HandleScore` -> `HandleScoreV2`） | 弱引用 + FName 配对失效，调用列表里残留死项 | 解绑后重新绑定 |
| 改 `delegate` ↔ `event`（单播变多播） | 全量重载，蓝图引用通过 `FArchiveReplaceObjectRef` 自动迁移；脚本侧需重新初始化 | 触发蓝图重编译 |

---

## 九、性能与 hot-fire 注意点

### 9.1 性能基线（参考量级）

`Broadcast` 一次的开销大致由两部分组成：参数 push（`PushArgument` × N，POD 约 50ns/参数，非 POD 含 `FString` 约 200ns/参数）+ 调用列表遍历（每个监听者一次 `UFunction::Invoke`，脚本目标 ~500ns / C++ 目标 ~200ns）。零订阅者时只走 `IsBound` 短路，开销 < 50ns，可放心放在 Tick 里。

### 9.2 hot-fire 场景的优化清单

如果 `Tick` 里频繁 `Broadcast`：

1. **大 struct 用 const 引用而非值传**：`event void FOnHit(const FHitResult& Hit)`，不要 `event void FOnHit(FHitResult Hit)`（每次拷贝 ~200B）。
2. **避免每帧重新订阅 / 解绑**：把订阅放 `BeginPlay`，解绑放 `EndPlay`。`AddUFunction` 走 `AddUnique` 比对，列表越长越慢。
3. **不要在 Broadcast 里再 Broadcast**：嵌套调用会断言失败（引擎用单一 `FScriptCall` 实例服务所有委托调用）。如果监听者必须触发另一个 event，用 `System::SetTimer(0)` 推到下一帧。
4. **超过 16 参数 / 1024 字节用 struct 打包**：除了硬限制，每个参数 push 都有 `Align + ConstructValue + CopyValue` 开销。

### 9.3 单播 vs 多播的选型

| 场景 | 推荐 | 理由 |
|-----|------|------|
| 异步操作完成回调（一对一） | `delegate` 单播 | 语义匹配，还能带返回值 |
| 状态变化通知（一对多 / 蓝图也想绑） | `event` 多播 + `UPROPERTY()` | 多个订阅者，蓝图节点要求多播 |
| 投票 / 表决（多人决策） | 自己写迭代 | 多播不带返回值，需手动收集 |
| 一次性 fire-and-forget | 直接函数调用 | 不需要 delegate |

---

## 十、调试：委托没触发的诊断流程

> "我 Broadcast 了，但订阅者没收到回调"——按下面顺序排查。

```text
[Step 1] 订阅是否真的发生了?
    Print(f"IsBound after subscribe = {OnEvent.IsBound()}")
    -> false: 走 [Step 2]
    -> true:  走 [Step 3]

[Step 2] 订阅没发生的常见原因
    a) 目标函数缺 UFUNCTION() 修饰  ->  控制台报 "Function X not found"
    b) FName 拼错                  ->  n"" 大小写敏感, 用 IDE 自动补全
    c) 目标对象是 null              ->  Bind 前先判 nullptr
    d) 签名不兼容                   ->  Broadcast 时报 "Signature mismatch"

[Step 3] 订阅成功但回调没触发?
    a) 订阅者已 Destroy            ->  weak 指针失效, 但弱引用机制不会崩, 只是没回调
    b) 订阅 / 触发的不是同一对象     ->  对比 self / broadcaster 的 Hash
    c) 监听者抛异常                 ->  查 Output Log "Angelscript exception"
    d) Broadcast 早于订阅时机       ->  Broadcast 推迟到 BeginPlay 或更晚

[Step 4] 都正常但还是没回调?
    用 VS Code AS 扩展在 HandleX 下断点, 触发后看是否进断点
```

### 10.1 常见错误信息对照

| 控制台输出 | 含义 | 修法 |
|-----------|------|------|
| `Executing unbound delegate.` | 单播未绑定就 `Execute` | 改 `ExecuteIfBound` 或先 `IsBound()` 检查 |
| `Null object passed to BindUFunction.` | `BindUFunction(null, ...)` | 调用前判 nullptr |
| `Function 'X' not found on object.` | 目标对象上找不到该 UFUNCTION | 检查函数名拼写 + 是否带 UFUNCTION 修饰 |
| `Specified function is not compatible with delegate function.` | 签名不匹配 | 对比 delegate 声明和实现的参数列表 |
| `events cannot be passed as arguments` | 把 event 类型作函数参数 | 改为通过持有者间接订阅（见 §4.2） |

---

## 附录 A：API 完整速查

### A.1 单播 `delegate` API

```text
struct FMyDelegate（预处理器自动生成）
==========================================================
默认构造               FMyDelegate()
拷贝构造               FMyDelegate(const FMyDelegate& Other)
快捷构造（一步绑定）    FMyDelegate(UObject Object, const FName& FunctionName)
赋值                   FMyDelegate& opAssign(const FMyDelegate& Other)
执行（未绑定抛异常）    Ret Execute(Args...) const allow_discard
执行（未绑定静默）      Ret ExecuteIfBound(Args...) const allow_discard
绑定                   void BindUFunction(UObject Object, const FName& FunctionName)
取目标对象             UObject GetUObject() const property
取目标函数名           FName GetFunctionName() const property
查询                   bool IsBound() const
解绑                   void Clear()
```

### A.2 多播 `event` API

```text
struct FMyEvent（预处理器自动生成）
==========================================================
默认构造               FMyEvent()
拷贝构造               FMyEvent(const FMyEvent& Other)
赋值                   FMyEvent& opAssign(const FMyEvent& Other)
广播                   void Broadcast(Args...) const
添加                   void AddUFunction(const UObject Object, const FName& FunctionName)
按名解绑               void Unbind(UObject Object, const FName& FunctionName)
按对象解绑全部         void UnbindObject(UObject Object)
查询                   bool IsBound() const
解绑全部               void Clear()
```

### A.3 关键限制

| 项 | 限制 |
|----|------|
| 单次调用最大参数数 | 16 |
| 单次调用参数总字节 | 1024 字节 |
| 调用线程 | 仅游戏线程（违反会 check 断言） |
| 嵌套调用 | 不允许（Broadcast 内不能再 Broadcast） |
| 多播 event 作函数参数 | ❌ 编译期报错 |
| 多播 event 带返回值 | ❌ 编译期报错 |
| sparse delegate 作函数参数 / 返回值 | ❌ 编译期报错 |

---

## 附录 B：决策树 — 我应该用哪种委托？

```text
Q1. 我需要在脚本里定义一个事件接口吗?
    No  -> 直接函数调用就够了, 不需要 delegate
    Yes -> Q2

Q2. 这个事件接口的订阅者会有几个?
    0~1 -> 用 delegate (单播), 调用方 Execute / ExecuteIfBound
    1~多 -> 用 event (多播), 调用方 Broadcast

Q3. 事件需要带返回值吗?
    需要 -> 必须用 delegate (event 不支持带返回值)
    不需要 -> 单 / 多播都可

Q4. 蓝图也想绑这个事件吗?
    想绑 -> event 必须作 UPROPERTY()
              delegate 也作 UPROPERTY()但只能一个绑定者
    不想 -> 局部变量也行, 用完即销

Q5. 事件触发频率有多高?
    >100 次 / 帧 -> 考虑改成直接函数调用
                   或先聚合一帧的数据再 Broadcast 一次
    <60 次 / 帧 -> Broadcast 开销可以忽略, 放心用

Q6. 我能改 C++ 端吗?
    能 -> 用 DECLARE_DYNAMIC_MULTICAST_DELEGATE 暴露, 脚本自动可见
    不能 -> 看 C++ 那边是不是 dynamic
              是 dynamic -> 脚本能用
              非 dynamic -> 脚本看不见, 提需求让 C++ 加包装
```

---

## 小结

- **两个关键字搞定大部分场景**：`delegate` = 单播（`DECLARE_DYNAMIC_DELEGATE`），`event` = 多播（`DECLARE_DYNAMIC_MULTICAST_DELEGATE`），声明语法跟函数签名一样写。
- **作 `UPROPERTY()` 即获得 BlueprintAssignable 语义**——AS 端不需要 `BlueprintAssignable / BlueprintCallable` 修饰符，蓝图自动可绑。
- **绑定只有一种方式：`BindUFunction(obj, n"FName")`**——脚本里没有 `BindUObject / BindLambda / BindRaw`，目标必须是 `UFUNCTION()`，FName 用 `n""` 编译期字面量。
- **多播不能作函数参数，也不能带返回值**——按值传会割裂订阅表，多个返回值无法表决。需要传"事件接口"时把它作为持有者上的 `UPROPERTY` 暴露。
- **生命周期靠弱引用兜底，但请显式解绑**——监听者销毁不会崩，但残留订阅项会拖慢调用链。`EndPlay` 里 `UnbindObject(this)` 是最佳实践。
- **超过 4-5 个参数请用 struct 打包**——硬限制是 16 参数 / 1024 字节，但远在到极限前可读性已经崩坏。

---

## 关联文档

- 实现原理：`Documents/Knowledges/ZH/Syntax_DelegateEvent.md`（预处理器代码展开 / `FScriptCall` 参数缓冲 / 三层 Bind 注册 / 热重载策略）
- 同族指南：`Documents/Knowledges/ZH/Guide_QuickStart.md`（案例 7 委托与事件）
- 同族指南：`Documents/Knowledges/ZH/Guide_SyntaxFeatures.md`（§五 `delegate` / `event` 速览）
- C++ 暴露视角：`Documents/Knowledges/ZH/Guide_ClassBinding.md`（§七 暴露 Delegate）
- 维护者深入：`Documents/Knowledges/ZH/Type_BindSystem.md`（`Bind_Delegates.cpp` 三层模型定位）
- 实战示例：`Script/Examples/Core/Example_Delegates.as`
