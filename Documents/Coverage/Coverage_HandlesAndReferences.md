# AngelScript 句柄和引用全覆盖矩阵

> 本文覆盖 AngelScript 中 **UE 对象引用系统**的所有用法。
> 包括 UObject handle、TWeakObjectPtr、TSoftObjectPtr、TSubclassOf 等。

## 对应测试文件

| 用法分组 | 测试文件 | 状态 |
|---------|---------|------|
| UObject Handle | `AngelscriptTest/Coverage/AngelscriptCoverageHandleTests.cpp` | ✅ 已完成 |
| 弱引用 (TWeakObjectPtr) + 类引用 (TSubclassOf) | `AngelscriptTest/Coverage/AngelscriptCoverageWeakReferenceTests.cpp` | ✅ 已完成 |
| 软引用 | `AngelscriptTest/Coverage/AngelscriptCoverageSoftReferenceTests.cpp` | ✅ 已完成 |
| GC 和生命周期 | `AngelscriptTest/Coverage/AngelscriptCoverageGCTests.cpp` | ✅ 已完成 |

✅ 所有核心引用类型已覆盖（Handle、WeakObjectPtr、TSubclassOf、SoftObjectPtr、SoftClassPtr）

## 图例

- `✅ 已覆盖 ✅ 待写` ｜ `🚫 不适用/不支持`

---

## 子矩阵 1：UObject Handle（基础引用）

### 1.1 Handle 基础

| 特性 | 写法 | 状态 | 说明 |
|------|------|------|------|
| 声明 | `AActor MyActor;` | ✅ | 默认为 null |
| null 赋值 | `MyActor = nullptr;` | ✅ | |
| null 检查 | `if (MyActor == nullptr)` | ✅ | |
| IsValid 检查 | `if (IsValid(MyActor))` | ✅ | 检查 null 和 PendingKill |
| 赋值 | `MyActor = OtherActor;` | ✅ | 引用赋值 |
| 比较 | `==` / `!=` | ✅ | 指针比较 |

### 1.2 Handle 类型覆盖

| UObject 类型 | 状态 | 典型用途 |
|-------------|------|---------|
| `AActor` | ✅ | 场景对象引用 |
| `APawn` | ✅ | 可控制对象 |
| `APlayerController` | ✅ | 玩家控制器 |
| `UActorComponent` | ✅ | 组件引用 |
| `UObject` | ⬜ | 通用对象 |
| `UClass` | ✅ | 类对象 |

### 1.3 Handle 作为成员

| 场景 | 写法 | 状态 | 说明 |
|------|------|------|------|
| UPROPERTY 成员 | `UPROPERTY() AActor Target;` | ✅ | 强引用 |
| EditAnywhere | `UPROPERTY(EditAnywhere) AActor Target;` | ✅ | 编辑器可设置 |
| BlueprintReadWrite | `UPROPERTY(BlueprintReadWrite) AActor Target;` | ✅ | BP 可访问 |
| Category | `UPROPERTY(Category="Refs") AActor Target;` | ✅ | 分类 |

### 1.4 Handle 操作

| 操作 | 写法 | 状态 | 说明 |
|------|------|------|------|
| 获取类 | `MyActor.GetClass()` | ✅ | 返回 UClass |
| 获取名称 | `MyActor.GetName()` | ✅ | |
| Cast 转换 | `Cast<APawn>(MyActor)` | ✅ | 向下转型 |
| 销毁对象 | `MyActor.DestroyActor()` | ⬜ | Actor 销毁 |
| 创建对象 | `NewObject<UMyObject>(Outer)` | ⬜ | |
| Spawn Actor | `SpawnActor<AActor>(Class, Transform)` | ✅ | |

---

## 子矩阵 2：TObjectPtr（智能指针）

### 2.1 TObjectPtr 基础

| 特性 | 写法 | 状态 | 说明 |
|------|------|------|------|
| 声明 | `TObjectPtr<AActor> MyActor;` | ⬜ | UE5 引入 |
| 与 Handle 对比 | 路由验证 | ⬜ | 额外安全检查 |
| 隐式转换 | `AActor RawPtr = MyActor;` | ⬜ | 自动转换 |

---

## 子矩阵 3：TWeakObjectPtr（弱引用）

### 3.1 弱引用基础

| 特性 | 写法 | 状态 | 说明 |
|------|------|------|------|
| 声明 | `TWeakObjectPtr<AActor> WeakActor;` | ✅ | 不阻止 GC |
| 赋值 | `WeakActor = MyActor;` | ✅ | 从强引用赋值 |
| 检查有效性 | `if (WeakActor.IsValid())` | ✅ | 对象是否存活 |
| 获取对象 | `AActor Ptr = WeakActor.Get();` | ✅ | 可能为 null |
| null 检查 | `if (WeakActor == nullptr)` | ⬜ | |
| 重置 | `WeakActor.Reset();` | ✅ | 清空引用 |

### 3.2 弱引用用法场景

| 场景 | 状态 | 说明 |
|------|------|------|
| 观察者模式 | ✅ | 不持有所有权 |
| 缓存引用 | ✅ | 对象可能被销毁 |
| 避免循环引用 | ⬜ | A 引用 B，B 弱引用 A |
| UPROPERTY 成员 | ✅ | `UPROPERTY() TWeakObjectPtr<AActor>` |

### 3.3 弱引用失效验证

| 测试场景 | 状态 | 验证点 |
|---------|------|--------|
| 对象销毁后 | ✅ | IsValid() 返回 false |
| Get() 返回 null | ✅ | 销毁后获取 |
| 重新赋值 | ⬜ | 指向新对象 |

---

## 子矩阵 4：TSoftObjectPtr（软引用）

### 4.1 软引用基础

| 特性 | 写法 | 状态 | 说明 |
|------|------|------|------|
| 声明 | `TSoftObjectPtr<AActor> SoftActor;` | ✅ | 资源路径引用 |
| 赋值 | `SoftActor = MyActor;` | ✅ | 记录路径 |
| 检查有效性 | `if (SoftActor.IsValid())` | ✅ | |
| 同步加载 | `AActor Ptr = SoftActor.LoadSynchronous();` | ✅ | 阻塞加载 |
| 异步加载 | （需要 StreamableManager） | ⬜ | |
| 获取路径 | `SoftActor.ToSoftObjectPath()` | ✅ | FSoftObjectPath |
| 是否 null | `if (SoftActor.IsNull())` | ✅ | |
| 是否挂起 | `if (SoftActor.IsPending())` | ⬜ | 加载中 |

### 4.2 软引用用法场景

| 场景 | 状态 | 说明 |
|------|------|------|
| 延迟加载 | ✅ | 不立即加载到内存 |
| 跨关卡引用 | ⬜ | 引用其他关卡的对象 |
| 资源管理 | ⬜ | 按需加载资源 |
| UPROPERTY 成员 | ✅ | `UPROPERTY() TSoftObjectPtr<UTexture>` |

### 4.3 软引用路径

| 操作 | 写法 | 状态 | 说明 |
|------|------|------|------|
| 从路径构造 | `TSoftObjectPtr(FSoftObjectPath("/Game/..."))` | ⬜ | |
| 获取字符串路径 | `SoftActor.ToString()` | ✅ | |
| 路径比较 | `SoftActor1 == SoftActor2` | ✅ | 路径相等 |

---

## 子矩阵 5：TSoftClassPtr（软类引用）

### 5.1 软类引用基础

| 特性 | 写法 | 状态 | 说明 |
|------|------|------|------|
| 声明 | `TSoftClassPtr<AActor> SoftClass;` | ✅ | 类路径引用 |
| 赋值 | `SoftClass = AActor::StaticClass();` | ✅ | |
| 同步加载 | `UClass Class = SoftClass.LoadSynchronous();` | ✅ | |
| 获取路径 | `SoftClass.ToSoftObjectPath()` | ✅ | |

### 5.2 软类引用用法

| 场景 | 状态 | 说明 |
|------|------|------|
| 延迟加载类 | ✅ | 不立即加载类定义 |
| 配置类引用 | ⬜ | 配置文件中指定类 |
| UPROPERTY 成员 | ✅ | `UPROPERTY() TSoftClassPtr<AActor>` |

---

## 子矩阵 6：TSubclassOf（类引用）

### 6.1 TSubclassOf 基础

| 特性 | 写法 | 状态 | 说明 |
|------|------|------|------|
| 声明 | `TSubclassOf<AActor> ActorClass;` | ✅ | 类型安全的类引用 |
| 赋值 | `ActorClass = AMyActor::StaticClass();` | ✅ | |
| 获取 UClass | `UClass Class = ActorClass.Get();` | ✅ | |
| null 检查 | `if (ActorClass == nullptr)` | ✅ | |
| 比较 | `ActorClass1 == ActorClass2` | ✅ | |

### 6.2 TSubclassOf 用法场景

| 场景 | 写法 | 状态 | 说明 |
|------|------|------|------|
| UPROPERTY 成员 | `UPROPERTY() TSubclassOf<AActor> ActorClass;` | ✅ | 编辑器类选择器 |
| EditDefaultsOnly | `UPROPERTY(EditDefaultsOnly) TSubclassOf<AActor>` | ✅ | |
| Spawn 参数 | `SpawnActor<AActor>(ActorClass, ...)` | ✅ | |
| 类型检查 | `if (ActorClass->IsChildOf(AActor::StaticClass()))` | ✅ | |
| 创建实例 | `AActor Obj = NewObject<AActor>(Outer, ActorClass);` | ⬜ | |

### 6.3 TSubclassOf vs UClass

| 特性 | TSubclassOf<T> | UClass* | 推荐 |
|------|---------------|---------|------|
| 类型安全 | ✅ 编译期检查 | ❌ 运行期检查 | TSubclassOf |
| 编辑器支持 | ✅ 过滤显示 | ❌ 显示所有类 | TSubclassOf |
| 使用便利 | ✅ 自动转换 | ❌ 需要 Cast | TSubclassOf |

---

## 子矩阵 7：TScriptInterface（接口引用）

### 7.1 接口引用基础

| 特性 | 写法 | 状态 | 说明 |
|------|------|------|------|
| 声明 | `TScriptInterface<IMyInterface> IntfRef;` | ⬜ | |
| 赋值 | `IntfRef = MyObject;` | ⬜ | 对象必须实现接口 |
| 获取对象 | `UObject Obj = IntfRef.GetObject();` | ⬜ | |
| 获取接口 | `IMyInterface Intf = IntfRef.GetInterface();` | ⬜ | |
| null 检查 | `if (IntfRef == nullptr)` | ⬜ | |

### 7.2 接口引用用法

| 场景 | 状态 | 说明 |
|------|------|------|
| UPROPERTY 成员 | ⬜ | `UPROPERTY() TScriptInterface<I>` |
| 容器元素 | ⬜ | `TArray<TScriptInterface<I>>` |
| 多态调用 | ⬜ | 通过接口调用方法 |

---

## 子矩阵 8：引用类型对比

### 8.1 强度对比

| 引用类型 | GC 保护 | 内存开销 | 典型用途 |
|---------|---------|---------|---------|
| UObject Handle | ✅ 强引用 | 小 | 所有权持有 |
| TObjectPtr | ✅ 强引用 | 小 | UE5 推荐 |
| TWeakObjectPtr | ❌ 弱引用 | 中 | 观察者、缓存 |
| TSoftObjectPtr | ❌ 软引用 | 大 | 跨关卡、延迟加载 |
| TSubclassOf | ✅ 类引用 | 小 | 类型安全的类引用 |
| TSoftClassPtr | ❌ 软类引用 | 大 | 延迟加载类 |

### 8.2 选择指南

| 需求 | 推荐类型 | 原因 |
|------|---------|------|
| 持有对象所有权 | UObject Handle | 防止 GC |
| 观察对象但不持有 | TWeakObjectPtr | 不阻止 GC |
| 跨关卡引用 | TSoftObjectPtr | 路径引用 |
| 延迟加载资源 | TSoftObjectPtr | 按需加载 |
| 类型选择器 | TSubclassOf | 类型安全 |
| 接口多态 | TScriptInterface | 接口引用 |

---

## 子矩阵 9：GC（垃圾回收）

### 9.1 GC 基础概念

| 概念 | 状态 | 说明 |
|------|------|------|
| 可达性分析 | ⬜ | 从根对象开始遍历 |
| 根对象 | ⬜ | UPROPERTY、全局引用 |
| 标记-清除 | ⬜ | GC 算法 |
| 引用计数 | ❌ | UE 不使用引用计数 |

### 9.2 GC 相关操作

| 操作 | 写法 | 状态 | 说明 |
|------|------|------|------|
| 创建对象 | `NewObject<UMyObject>(Outer)` | ⬜ | 需要 Outer |
| 标记 UPROPERTY | `UPROPERTY()` | ✅ | 防止 GC |
| AddReferencedObjects | C++ 方法 | 🚫 | AS 不需要 |
| ForceGarbageCollection | 测试用 | ✅ | 强制 GC |

### 9.3 GC 测试场景

| 场景 | 状态 | 验证点 |
|------|------|--------|
| 无引用对象被回收 | ✅ | 弱引用失效 |
| UPROPERTY 保护对象 | ✅ | 对象存活 |
| 容器内对象保护 | ✅ | TArray<UObject> |
| 跨帧持有 | ✅ | 多帧后对象仍存活 |
| 循环引用 | ⬜ | A->B, B->A 能否回收 |

---

## 子矩阵 10：引用在不同场景的用法

### 10.1 作为 UPROPERTY

| 引用类型 | 状态 | 验证点 |
|---------|------|--------|
| `UPROPERTY() AActor Target;` | ✅ | 强引用 |
| `UPROPERTY() TWeakObjectPtr<AActor> Target;` | ✅ | 弱引用 |
| `UPROPERTY() TSoftObjectPtr<AActor> Target;` | ✅ | 软引用 |
| `UPROPERTY() TSubclassOf<AActor> ActorClass;` | ✅ | 类引用 |

### 10.2 作为函数参数

| 参数形式 | 写法 | 状态 | 说明 |
|---------|------|------|------|
| 值传递 | `void F(AActor Obj)` | ✅ | 引用语义 |
| 输出参数 | `void F(AActor&out Obj)` | ✅ | |
| TSubclassOf 参数 | `void F(TSubclassOf<AActor> Class)` | ⬜ | |

### 10.3 作为容器元素

| 容器 | 状态 | 说明 |
|------|------|------|
| `TArray<AActor>` | ✅ | 强引用数组 |
| `TArray<TWeakObjectPtr<AActor>>` | ⬜ | 弱引用数组 |
| `TMap<int, AActor>` | ✅ | 值为强引用 |
| `TSet<AActor>` | ⬜ | 指针哈希 |

---

## 计划测试方法清单

### AngelscriptCoverageHandleTests.cpp ✅

| 方法 | 覆盖内容 | 状态 |
|------|---------|------|
| `HandleBasics` | 声明/赋值/null 检查/IsValid | ✅ |
| `HandleComparison` | ==/!= 比较 | ✅ |
| `HandleCast` | Cast<T> 向下转型 | ✅ |
| `HandleAsProperty` | UPROPERTY 成员 | ✅ |
| `HandleAsParameter` | 函数参数/返回值 | ✅ |
| `HandleInContainers` | TArray/TMap/TSet | ✅ |
| `HandleOperations` | GetClass/GetName/IsA | ✅ |

### AngelscriptCoverageWeakReferenceTests.cpp ✅

| 方法 | 覆盖内容 | 状态 |
|------|---------|------|
| `WeakObjectPtrBasics` | 声明/赋值/IsValid/Get/Reset | ✅ |
| `WeakObjectPtrInvalidation` | 对象销毁后失效 | ✅ |
| `WeakObjectPtrAsProperty` | UPROPERTY 弱引用 | ✅ |
| `TSubclassOfBasics` | 声明/赋值/Get/null 检查/比较 | ✅ |
| `TSubclassOfAsProperty` | UPROPERTY 类选择器 | ✅ |
| `TSubclassOfSpawn` | SpawnActor 参数 | ✅ |
| `TSubclassOfTypeCheck` | IsChildOf 检查 | ✅ |

### AngelscriptCoverageSoftReferenceTests.cpp ✅

| 方法 | 覆盖内容 | 状态 |
|------|---------|------|
| `SoftObjectPtrBasics` | 声明/赋值/Get/LoadSynchronous | ✅ |
| `SoftObjectPtrNullChecks` | IsNull/IsValid 检查 | ✅ |
| `SoftObjectPtrPath` | ToSoftObjectPath/ToString | ✅ |
| `SoftObjectPtrAsProperty` | UPROPERTY 软引用 | ✅ |
| `SoftObjectPtrInContainers` | TArray/TMap 容器 | ✅ |
| `SoftClassPtrBasics` | 声明/赋值/LoadSynchronous/Get | ✅ |
| `SoftClassPtrPath` | ToString/ToSoftObjectPath | ✅ |
| `SoftClassPtrAsProperty` | UPROPERTY 软类引用 | ✅ |

### AngelscriptCoverageGCTests.cpp ✅

| 方法 | 覆盖内容 | 状态 |
|------|---------|------|
| `GCBasicReclaim` | 无引用对象被回收 | ✅ |
| `GCUPropertyProtection` | UPROPERTY 保护 | ✅ |
| `GCWeakPtrInvalidation` | 弱引用在 GC 后失效 | ✅ |
| `GCContainerProtection` | TArray<UObject> 保护 | ✅ |
| `GCCrossFrameHold` | 跨帧持有 | ✅ |
| `GCLocalVariableNoProtection` | 局部变量不保护 | ✅ |
| `GCCollectionMethods` | CollectGarbage/ForceGarbageCollection | ✅ |
| `GCIsValidCheck` | IsValid() 检查有效性 | ✅ |

---

## 待补充清单（按优先级）

### 🔴 高优先级

1. ~~**UObject Handle 基础**（声明/null 检查/Cast/IsValid）~~ ✅ 已完成
2. ~~**TWeakObjectPtr**（弱引用和失效验证）~~ ✅ 已完成
3. ~~**TSubclassOf**（类引用和 Spawn）~~ ✅ 已完成

### 🟡 中优先级

4. ~~**TSoftObjectPtr**（软引用和延迟加载）~~ ✅ 已完成
5. **TScriptInterface**（接口引用）⬜ 待完成
6. ~~**GC 基础验证**（对象保护和回收）~~ ✅ 已完成

### 🟢 低优先级

7. ~~**TSoftClassPtr**（软类引用）~~ ✅ 已完成
8. **GC 高级场景**（循环引用、跨帧）⬜ 待完成

---

## 总结

句柄和引用是 **UE 对象系统的核心**，正确使用引用类型直接影响：
- 内存管理（GC 是否回收）
- 性能（加载时机）
- 稳定性（空指针崩溃）
- 跨关卡引用

**估计工作量**：4 个测试文件，约 25-30 个测试方法
**优先级**：🔴🔴🔴 极高（对象系统基础）







