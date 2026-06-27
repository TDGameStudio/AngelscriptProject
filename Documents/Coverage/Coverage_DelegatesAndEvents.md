# AngelScript 委托和事件全覆盖矩阵

> 本文覆盖 AngelScript 中 **委托（Delegate）和事件系统**的所有用法。
> 包括单播委托、多播委托、动态委托、事件绑定等。

## 对应测试文件

| 用法分组 | 测试文件 | 状态 |
|---------|---------|------|
| 单播委托 | `AngelscriptTest/Coverage/AngelscriptCoverageDelegateTests.cpp` | ✅ 已完成 |
| 多播委托 | `AngelscriptTest/Coverage/AngelscriptCoverageMulticastDelegateTests.cpp` | ✅ 已完成 |
| 动态委托 | `AngelscriptTest/Coverage/AngelscriptCoverageDynamicDelegateTests.cpp` | ✅ 已完成 |
| 事件系统 | `AngelscriptTest/Coverage/AngelscriptCoverageEventTests.cpp` | ✅ 已完成 |

✅ 委托和事件系统全覆盖完成

## 图例

- `✅ 已覆盖` ｜ `🟡 部分覆盖` ｜ `⬜ 待写` ｜ `🚫 不适用/不支持`

---

## 子矩阵 1：单播委托（FDelegate）

### 1.1 单播委托声明

| 声明形式 | 写法示例 | 状态 | 说明 |
|---------|---------|------|------|
| DECLARE_DELEGATE | `DECLARE_DELEGATE(FMyDelegate)` | ✅ | 无参数 |
| 带参数 | `DECLARE_DELEGATE_OneParam(FMyDelegate, int)` | ✅ | 1 个参数 |
| 多参数 | `DECLARE_DELEGATE_TwoParams(FMyDelegate, int, FString)` | ✅ | 2 个参数 |
| 带返回值 | `DECLARE_DELEGATE_RetVal(bool, FMyDelegate)` | ✅ | 返回值 |
| 返回值+参数 | `DECLARE_DELEGATE_RetVal_OneParam(bool, FMyDelegate, int)` | ✅ | |

### 1.2 单播委托绑定

| 绑定方式 | 写法 | 状态 | 说明 |
|---------|------|------|------|
| 绑定成员方法 | `Delegate.BindUFunction(this, n"MethodName")` | ✅ | UFUNCTION |
| 绑定 Lambda | `Delegate.BindLambda([](){ ... })` | ✅ | AS Lambda |
| 绑定全局函数 | `Delegate.BindStatic(&GlobalFunc)` | 🚫 | AS 无静态概念 |
| 解绑 | `Delegate.Unbind()` | ✅ | |
| 检查绑定 | `if (Delegate.IsBound())` | ✅ | |

### 1.3 单播委托执行

| 操作 | 写法 | 状态 | 说明 |
|------|------|------|------|
| 执行 | `Delegate.Execute()` | ✅ | 必须已绑定 |
| 安全执行 | `Delegate.ExecuteIfBound()` | ✅ | 未绑定不执行 |
| 带参数执行 | `Delegate.Execute(Param1, Param2)` | ✅ | |
| 获取返回值 | `bool Result = Delegate.Execute();` | ✅ | |

---

## 子矩阵 2：多播委托（FMulticastDelegate）

### 2.1 多播委托声明

| 声明形式 | 写法示例 | 状态 | 说明 |
|---------|---------|------|------|
| DECLARE_MULTICAST_DELEGATE | `DECLARE_MULTICAST_DELEGATE(FMyMulticast)` | ✅ | 无参数 |
| 带参数 | `DECLARE_MULTICAST_DELEGATE_OneParam(FMyMulticast, int)` | ✅ | 1 个参数 |
| 多参数 | `DECLARE_MULTICAST_DELEGATE_TwoParams(FMyMulticast, int, FString)` | ✅ | 2 个参数 |

> 多播委托**不支持返回值**（多个监听器返回什么？）

### 2.2 多播委托绑定

| 绑定方式 | 写法 | 状态 | 说明 |
|---------|------|------|------|
| 添加监听器 | `Multicast.AddUFunction(this, n"MethodName")` | ✅ | |
| 添加 Lambda | `Multicast.AddLambda([](){ ... })` | ✅ | |
| 移除监听器 | `Multicast.Remove(Handle)` | ✅ | 需保存句柄 |
| 移除所有 | `Multicast.Clear()` | ✅ | |
| 检查绑定 | `if (Multicast.IsBound())` | ✅ | 是否有监听器 |

### 2.3 多播委托执行

| 操作 | 写法 | 状态 | 说明 |
|------|------|------|------|
| 广播 | `Multicast.Broadcast()` | ✅ | 调用所有监听器 |
| 带参数广播 | `Multicast.Broadcast(Param1, Param2)` | ✅ | |

### 2.4 多播委托句柄

| 操作 | 写法 | 状态 | 说明 |
|------|------|------|------|
| 保存句柄 | `FDelegateHandle Handle = Multicast.AddUFunction(...)` | ✅ | |
| 按句柄移除 | `Multicast.Remove(Handle)` | ✅ | |
| 句柄有效性 | `if (Handle.IsValid())` | ✅ | |

---

## 子矩阵 3：动态委托（Dynamic Delegate）

### 3.1 动态单播委托

| 声明形式 | 写法示例 | 状态 | 说明 |
|---------|---------|------|------|
| DECLARE_DYNAMIC_DELEGATE | `DECLARE_DYNAMIC_DELEGATE(FMyDynamicDelegate)` | ⬜ | BP 可用 |
| 带参数 | `DECLARE_DYNAMIC_DELEGATE_OneParam(FMyDelegate, int, Param)` | ⬜ | 参数需命名 |
| 带返回值 | `DECLARE_DYNAMIC_DELEGATE_RetVal(bool, FMyDelegate)` | ⬜ | |

### 3.2 动态多播委托

| 声明形式 | 写法示例 | 状态 | 说明 |
|---------|---------|------|------|
| DECLARE_DYNAMIC_MULTICAST_DELEGATE | `DECLARE_DYNAMIC_MULTICAST_DELEGATE(FMyEvent)` | ⬜ | 事件常用 |
| 带参数 | `DECLARE_DYNAMIC_MULTICAST_DELEGATE_OneParam(FMyEvent, int, Value)` | ⬜ | |

### 3.3 动态委托绑定

| 绑定方式 | 写法 | 状态 | 说明 |
|---------|------|------|------|
| BindDynamic | `Delegate.BindDynamic(this, &ClassName::MethodName)` | ⬜ | UFUNCTION 宏 |
| AddDynamic | `Multicast.AddDynamic(this, &ClassName::MethodName)` | ⬜ | 多播版本 |
| RemoveDynamic | `Multicast.RemoveDynamic(this, &ClassName::MethodName)` | ⬜ | |
| 序列化支持 | 自动序列化 | ⬜ | 可保存到资源 |

### 3.4 动态委托 vs 普通委托

| 特性 | 普通委托 | 动态委托 | 推荐 |
|------|---------|---------|------|
| 性能 | ✅ 快 | ❌ 慢 | 普通 |
| BP 支持 | ❌ 不支持 | ✅ 支持 | 动态（BP 互操作） |
| 序列化 | ❌ 不支持 | ✅ 支持 | 动态（保存） |
| 编译期检查 | ✅ 强 | ❌ 弱 | 普通 |

---

## 子矩阵 4：事件（Event）

### 4.1 事件声明

| 声明方式 | 写法 | 状态 | 说明 |
|---------|------|------|------|
| UPROPERTY Event | `UPROPERTY() FMyMulticastDelegate OnMyEvent;` | ⬜ | 暴露给 BP |
| BlueprintAssignable | `UPROPERTY(BlueprintAssignable) FMyEvent OnClicked;` | ⬜ | BP 可绑定 |
| BlueprintCallable | `UPROPERTY(BlueprintCallable) FMyEvent OnTriggered;` | ⬜ | BP 可调用 |

### 4.2 常见事件模式

| 事件类型 | 写法示例 | 状态 | 用途 |
|---------|---------|------|------|
| 生命周期事件 | `OnBeginPlay` / `OnEndPlay` | ⬜ | Actor 生命周期 |
| 输入事件 | `OnClicked` / `OnPressed` / `OnReleased` | ⬜ | 用户输入 |
| 碰撞事件 | `OnHit` / `OnBeginOverlap` / `OnEndOverlap` | ⬜ | 物理碰撞 |
| 状态 ✅ | 游戏逻辑 |
| 网络事件 | `OnRepNotify` | ⬜ | 属性复制 |

### 4.3 事件绑定和触发

| 操作 | 写法 | 状态 | 说明 |
|------|------|------|------|
| 绑定事件 | `OnMyEvent.AddDynamic(this, &ClassName::Handler)` | ⬜ | |
| 解绑事件 | `OnMyEvent.RemoveDynamic(this, &ClassName::Handler)` | ⬜ | |
| 触发事件 | `OnMyEvent.Broadcast(Params)` | ⬜ | |
| BP 绑定 | 在 BP 中拖拽事件节点 | ⬜ | 编辑器操作 |

---

## 子矩阵 5：Lambda 表达式

### 5.1 Lambda 基础

| 特性 | 写法 | 状态 | 说明 |
|------|------|------|------|
| 无捕获 Lambda | `[]() { ... }` | ⬜ | |
| 捕获 this | `[this]() { ... }` | ⬜ | 访问成员 |
| 捕获变量 | `[X]() { ... }` | ⬜ | 按值捕获 |
| 捕获引用 | `[&X]() { ... }` | ⬜ | 按引用捕获 |
| 捕获所有 | `[=]() { ... }` / `[&]() { ... }` | ⬜ | 按值/引用捕获所有 |
| 带参数 | `[](int X) { ... }` | ⬜ | |
| 带返回值 | `[]() -> int { return 1; }` | ⬜ | |

### 5.2 Lambda 绑定到委托

| 场景 | 写法 | 状态 | 说明 |
|------|------|------|------|
| 单播委托 Lambda | `Delegate.BindLambda([](){ ... })` | ⬜ | |
| 多播委托 Lambda | `Multicast.AddLambda([](){ ... })` | ⬜ | |
| 定时器 Lambda | `SetTimer(Handle, [this](){ ... }, 1.0f, false)` | ⬜ | |

### 5.3 Lambda 生命周期

| 场景 | 状态 | 注意事项 |
|------|------|---------|
| 捕获 this | ⬜ | this 可能被销毁 |
| 捕获 UObject | ⬜ | 对象可能被 GC |
| 弱引用捕获 | ⬜ | 使用 TWeakObjectPtr |

---

## 子矩阵 6：委托签名

### 6.1 参数数量

| 签名 | 宏 | 状态 |
|------|------|------|
| 无参数 | `DECLARE_DELEGATE(F)` | ⬜ |
| 1 参数 | `DECLARE_DELEGATE_OneParam(F, T1)` | ⬜ |
| 2 参数 | `DECLARE_DELEGATE_TwoParams(F, T1, T2)` | ⬜ |
| 3 参数 | `DECLARE_DELEGATE_ThreeParams(F, T1, T2, T3)` | ⬜ |
| 4+ 参数 | `DECLARE_DELEGATE_FourParams(...)` 等 | ⬜ |

### 6.2 参数类型覆盖

| 参数类型 | 状态 | 说明 |
|---------|------|------|
| 基础类型（int/float/bool） | ⬜ | |
| 字符串（FString/FName） | ⬜ | |
| 结构体（FVector） | ⬜ | 按值传递 |
| 结构体引用（const FVector&） | ⬜ | 引用传递 |
| UObject 引用（AActor） | ⬜ | Handle |
| 枚举 | ⬜ | |

### 6.3 返回值类型覆盖

| 返回值类型 | 状态 | 说明 |
|----------|------|------|
| void | ⬜ | 无返回值 |
| bool | ⬜ | 常用于验证 |
| int/float | ⬜ | 数值 |
| FString | ⬜ | 字符串 |
| 结构体 | ⬜ | 复杂类型 |

---

## 子矩阵 7：委托使用场景

### 7.1 观察者模式

| 场景 | 写法 | 状态 | 说明 |
|------|------|------|------|
| UI 按钮点击 | `Button.OnClicked.AddDynamic(...)` | ⬜ | |
| 生命周期监听 | `Actor.OnEndPlay.AddDynamic(...)` | ⬜ | |
| 属性变化通知 | `OnHealthChanged.Broadcast(NewHealth)` | ⬜ | |

### 7.2 回调模式

| 场景 | 写法 | 状态 | 说明 |
|------|------|------|------|
| 异步加载完成 | `LoadAssetAsync(Path, OnLoaded)` | ⬜ | |
| HTTP 请求回调 | `HttpRequest.OnProcessRequestComplete.BindLambda(...)` | ⬜ | |
| 定时器回调 | `SetTimer(Handle, Callback, Time, Loop)` | ⬜ | |

### 7.3 系统解耦

| 场景 | 状态 | 说明 |
|------|------|------|
| 游戏事件总线 | ⬜ | 全局事件分发 |
| 模块间通信 | ⬜ | 避免硬依赖 |
| UI 与逻辑分离 | ⬜ | 通过委托通信 |

---

## 子矩阵 8：委托作为成员和参数

### 8.1 作为 UPROPERTY

| 形式 | 写法 | 状态 | 说明 |
|------|------|------|------|
| 普通委托成员 | `UPROPERTY() FMyDelegate OnAction;` | ⬜ | 不暴露给 BP |
| BlueprintAssignable | `UPROPERTY(BlueprintAssignable) FMyEvent OnTrigger;` | ⬜ | BP 可绑定 |
| BlueprintCallable | `UPROPERTY(BlueprintCallable) FMyEvent OnCall;` | ⬜ | BP 可调用 |

### 8.2 作为函数参数

| 形式 | 写法 | 状态 | 说明 |
|------|------|------|------|
| 委托参数 | `void F(FMyDelegate Callback)` | ⬜ | 回调函数 |
| const 引用 | `void F(const FMyDelegate&in Callback)` | ⬜ | 避免拷贝 |

---

## 子矩阵 9：常见委托类型实例

### 9.1 UE 内建委托

| 委托名 | 所属类 | 状态 | 用途 |
|-------|--------|------|------|
| `OnActorBeginOverlap` | AActor | ⬜ | Actor 重叠 |
| `OnActorHit` | AActor | ⬜ | Actor 碰撞 |
| `OnComponentHit` | UPrimitiveComponent | ⬜ | 组件碰撞 |
| `OnComponentBeginOverlap` | UPrimitiveComponent | ⬜ | 组件重叠 |
| `OnClicked` | UButton | ⬜ | 按钮点击 |
| `OnPressed` / `OnReleased` | UButton | ⬜ | 按钮按下/释放 |
| `OnValueChanged` | USlider | ⬜ | 滑块值变化 |
| `OnTextChanged` | UEditableText | ⬜ | 文本变化 |
| `OnHealthChanged` | 自定义 | ⬜ | 生命值变化 |

### 9.2 自定义委托示例

```angelscript
// 声明委托
DECLARE_DYNAMIC_MULTICAST_DELEGATE_TwoParams(
    FOnScoreChanged, 
    int, OldScore, 
    int, NewScore
);

// 使用委托
UCLASS()
class AMyActor : AActor
{
    UPROPERTY(BlueprintAssignable)
    FOnScoreChanged OnScoreChanged;
    
    void ChangeScore(int NewScore)
    {
        int OldScore = Score;
        Score = NewScore;
        OnScoreChanged.Broadcast(OldScore, NewScore);
    }
}
```

---

## 计划测试方法清单

### AngelscriptCoverageDelegateTests.cpp（单播）

| 方法 | 覆盖内容 |
|------|---------|
| `DelegateBasics` | 声明/绑定/执行/IsBound |
| `DelegateParameters` | 各种参数类型 |
| `DelegateReturnValue` | 返回值 |
| `DelegateUnbind` | 解绑 |
| `DelegateLambda` | Lambda 绑定 |

### AngelscriptCoverageMulticastDelegateTests.cpp

| 方法 | 覆盖内容 |
|------|---------|
| `MulticastBasics` | Add/Remove/Broadcast |
| `MulticastMultipleListeners` | 多个监听器 |
| `MulticastHandle` | FDelegateHandle 管理 |
| `MulticastClear` | 清空所有监听器 |
| `MulticastLambda` | Lambda 监听器 |

### AngelscriptCoverageDynamicDelegateTests.cpp

| 方法 | 覆盖内容 |
|------|---------|
| `DynamicDelegateBasics` | BindDynamic/AddDynamic |
| `DynamicDelegateParameters` | 参数命名 |
| `DynamicDelegateBlueprintAssignable` | BP 可绑定 |
| `DynamicDelegateSerialization` | 序列化支持 |

### AngelscriptCoverageEventTests.cpp

| 方法 | 覆盖内容 |
|------|---------|
| `EventBindAndTrigger` | 绑定和触发事件 |
| `EventMultipleHandlers` | 多个事件处理器 |
| `EventLifecycle` | 生命周期事件 |
| `EventCollision` | 碰撞事件 |
| `EventUI` | UI 事件 |
| `EventCustom` | 自定义事件 |

---

## 待补充清单（按优先级）

### 🔴 高优先级

1. **单播委托基础**（绑定/执行/解绑）
2. **多播委托基础**（Add/Remove/Broadcast）
3. **事件绑定和触发**（生命周期/碰撞/UI）

### 🟡 中优先级

4. **动态委托**（BindDynamic/AddDynamic/序列化）
5. **Lambda 绑定**（捕获/生命周期）
6. **委托参数和返回值**（各种类型）

### 🟢 低优先级

7. **委托句柄管理**（FDelegateHandle）
8. **复杂事件模式**（事件总线）

---

## 总结

委托和事件是 **UE 事件驱动架构的核心**：
- UI 交互 → 按钮点击委托
- 游戏逻辑 → 生命周期事件
- 系统解耦 → 观察者模式
- 异步操作 → 回调委托

**估计工作量**：4 个测试文件，约 20-25 个测试方法
**优先级**：🔴🔴 高（事件系统基础）






