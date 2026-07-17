# RT_GlobalState — 全局状态治理

> **所属前缀**: RT_（运行时子系统族）
> **关注层面**: 全局/进程级状态的盘点、读写规则、隔离策略与 Test 复位协议（不重写 `Arch_RuntimeLifecycle.md` 的三层架构总览，也不重写 `Type_BindSystem.md` 的 `FBind` 单例细节，专注 "插件中"哪些是全局、为什么是全局、谁来清"这件事）
> **关键源码**:
> `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.h` (~46 KB，`FAngelscriptEngine` / `FAngelscriptEngineContextStack` / `FAngelscriptEngineScope` / `FAngelscriptGameThreadScopeWorldContext`)
> · `AngelscriptRuntime/Core/AngelscriptEngine.cpp` (~3000+ 行，`GAngelscriptEngineContextStack` / `GAmbientWorldContext` / `AssignWorldContext` / `TryGetCurrentEngine`)
> · `AngelscriptRuntime/Core/AngelscriptRuntimeModule.cpp` (~109 行，`bInitializeAngelscriptCalled` / `OwnedPrimaryEngine`)
> · `AngelscriptRuntime/Core/AngelscriptSubsystem.cpp`（生产 Subsystem 的 ambient-engine 采用与 owned-engine 生命周期）
> · `AngelscriptRuntime/Core/AngelscriptGameInstanceSubsystem.cpp` (~120 行，`ActiveTickOwners`)
> · `AngelscriptRuntime/Core/AngelscriptBinds.h` / `.cpp`（`GetBindArray` Meyers' singleton、`FAngelscriptBindState` per-engine）
> · `AngelscriptRuntime/ClassGenerator/ASClass.cpp` (~3000+ 行，`GIsInAngelscriptThreadSafeFunction` / `GIsAngelscriptWorldContextAvailable` thread_local，`UASClass::OverrideConstructingObject`)
> · `AngelscriptTest/Shared/AngelscriptTestUtilities.h` (~1094 行，`FScopedTestWorldContextScope` / `AcquireCleanSharedCloneEngine` / `DestroySharedTestEngine` 复位协议)
> · `Documents/Guides/GlobalStateContainmentMatrix.md` — 全局状态分类基线
> **关联文档**:
> `Documents/Knowledges/ZH/Arch_RuntimeLifecycle.md` — 三层架构总览（本文沿用其骨架，不重复）
> · `Documents/Knowledges/ZH/RT_HotReload.md` — HotReload 与 ContextStack 的复用边界
> · `Documents/Knowledges/ZH/RT_StateDump.md` — Dump 的 27 张表分别对应哪一类全局状态
> · `Documents/Knowledges/ZH/Type_BindSystem.md` — 全局 `FBind` 队列的进程级单例语义
> · `Documents/Knowledges/ZH/AS_ScriptEngine.md` — `asCThreadManager` / TLS 的内核侧来源
> · `Documents/Guides/GlobalStateContainmentMatrix.md` — `P5.1` / `P5.2` containment 决策基线

---

## 概览

本文聚焦一个核心问题：**`Plugins/Angelscript` 当前到底有哪些"超出单个 `FAngelscriptEngine` 实例的"全局状态？它们的读、写、清三件事各自由谁负责？多 Engine 并存（Editor 主引擎 + PIE / Test 多个 Engine）时如何保证不窜流？Test 场景每个 Spec 起来前要做什么样的"复位仪式"？**

`Arch_RuntimeLifecycle.md` 已经给了三层架构骨架——**重对象 `FAngelscriptEngine` / 编排者 Subsystem / 进程级 ContextStack**。本文沿用同一张骨架，但角度反过来：不再问"谁来 new Engine"，而是问"被 new 出来之外，**还有什么**进程级的盒子在那躺着，谁能动它"。

```text
                AngelscriptProject 全局状态地图（按粒度排列）
                ============================================

    ┌─────────────────────────────────────────────────────────────────┐
    │  Level 0 — 进程单例（procedural / static, 与 Engine 实例无关）  │
    │  · FAngelscriptBinds::GetBindArray() Meyers singleton  ← Type_  │
    │  · GAngelscriptRecompileAvoidance / GAngelscriptLineReentry     │
    │  · FAngelscriptEngine::GameThreadTLD / bStaticJITTranspiled...  │
    │  · GAngelscriptPackageRefCount / GAngelscriptAssetsPackageRefCount│
    │  · LogCategory(Angelscript) / 各种 NAME_ static FName            │
    └─────────────────────────────────────────────────────────────────┘
                                  │
    ┌─────────────────────────────┴───────────────────────────────────┐
    │  Level 1 — 进程"当前指针" (mutated by RAII Scope)               │
    │  · static TArray<FAngelscriptEngine*> GAngelscriptEngineContextStack│
    │  · static UObject* GAmbientWorldContext (volatile)              │
    │  · UAngelscriptGameInstanceSubsystem::ActiveTickOwners (int)    │
    │  · FAngelscriptRuntimeModule::bInitializeAngelscriptCalled      │
    └─────────────────────────────────────────────────────────────────┘
                                  │
    ┌─────────────────────────────┴───────────────────────────────────┐
    │  Level 2 — Thread-local（asCThreadManager / 插件 TLS）          │
    │  · thread_local FAngelscriptContextPool GAngelscriptContextPool │
    │  · thread_local bool GIsInAngelscriptThreadSafeFunction         │
    │  · thread_local bool GIsAngelscriptWorldContextAvailable        │
    │  · thread_local UObject* GASDefaultConstructorOuter             │
    │  · asCThreadManager::tldMap (来自 AS 内核，详见 AS_ScriptEngine)│
    └─────────────────────────────────────────────────────────────────┘
                                  │
    ┌─────────────────────────────┴───────────────────────────────────┐
    │  Level 3 — Engine 实例字段（per-instance, 不是全局）           │
    │  · FAngelscriptEngine::WorldContextObject  ← UPROPERTY()       │
    │  · FAngelscriptEngine::BindState (TUniquePtr)                  │
    │  · FAngelscriptEngine::TypeDatabase / BindDatabase / ...       │
    │  · FAngelscriptEngine::StaticNames / StaticNamesByIndex        │
    └─────────────────────────────────────────────────────────────────┘
```

四个层级回答四个不同问题：

- **Level 0**：链接器/进程加载就存在，与 `FAngelscriptEngine` 无关。多 Engine 并存时这些是**共享**的——典型例子是 `FBind` 全局队列。
- **Level 1**：进程级，但通过 RAII Scope 在每次"切换当前 Engine / 当前 World"时被推入/弹出。这是本文的重点。
- **Level 2**：跨线程独立。每条线程一份 `FAngelscriptContextPool`，与 AS 内核的 `asCThreadManager` 配对。
- **Level 3**：明确属于某个 `FAngelscriptEngine` 实例，多实例并存时各占一份。本文章只用以反衬"什么不该全局"。

后续章节按 Level 0 → Level 1 → Level 2 → 多 Engine 隔离 → Test 复位协议 → 调试与设计原则 的顺序展开。

---

## 一、Level 0：进程单例与"共享底座"

这一层的状态在 `IMPLEMENT_MODULE` 之前就已经被链接器初始化或在第一次访问时被 Meyers' singleton 创建。它们**与 `FAngelscriptEngine` 实例无关**——同一进程里 100 个 Engine 共享同一份。

### 1.1 全局 `FBind` 注册队列

`Type_BindSystem.md` 已经把这件事讲完，简言之：

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Core/AngelscriptBinds.cpp
// 函数: GetBindArray（Meyers' singleton，进程级唯一）
// ============================================================================
static TArray<FBindFunction>& GetBindArray()
{
    static TArray<FBindFunction> BindArray;   // ★ 进程级唯一
    return BindArray;
}

void FAngelscriptBinds::RegisterBinds(FName BindName, int32 BindOrder, TFunction<void()> Function)
{
    GetBindArray().Add({ ... });
}
```

`Bind_*.cpp` 的 121 个文件顶部 `AS_FORCE_LINK const FAngelscriptBinds::FBind Bind_FVector(...)` 在 DLL 加载时注册到这张数组。**全局只读**：每个 `FAngelscriptEngine::Initialize()` 进入 `BindScriptTypes()` 时都会重放整张数组（按 `EOrder` 升序），但写操作只发生在静态构造期。

**多 Engine 并存的语义**：
- Engine A 与 Engine B 都会调 `CallBinds(...)`，两份各自跑一遍同一组 `FBindFunction::Function`。
- `Function` 内部用 `FAngelscriptEngine::TryGetCurrentEngine()` 拿到"当前正在 init 的引擎"，因此能把绑定结果（types、global functions、global properties）写到正确的引擎实例。

### 1.2 引擎全局 CVar 与重入哨兵

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Core/AngelscriptEngine.cpp
// 节选自: 文件顶部静态变量
// ============================================================================
static bool   GAngelscriptLineReentry = false;
static int32  GAngelscriptRecompileAvoidance = 1;
static FAutoConsoleVariableRef CVar_AngelscriptRecompileAvoidance(
    TEXT("angelscript.UseRecompileAvoidance"),
    GAngelscriptRecompileAvoidance, TEXT(""));
```

- `GAngelscriptLineReentry`：line callback 重入门票（防止断点逻辑无限递归触发自己）。设计上**不应**多 Engine 同时进入 line callback——Tick 让位机制已经保证这一点。
- `GAngelscriptRecompileAvoidance`：通过控制台 CVar 暴露的进程级开关。多 Engine 共享 CVar 是 UE 的设计，并非问题。

### 1.3 `FAngelscriptEngine` 的几个 `static` 字段

`FAngelscriptEngine` 这个 USTRUCT 看上去像实例，但暴露了一些**类静态**字段：

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Core/AngelscriptEngine.h
// 节选自: FAngelscriptEngine 类静态成员
// ============================================================================
static class asCThreadLocalData* GameThreadTLD;     // ★ AS VM 的 game-thread TLS 桥
static bool bStaticJITTranspiledCodeLoaded;         // 进程层"是否已加载 transpiled JIT 代码"
```

`GameThreadTLD` 是 AS 内核 `asCThreadManager::GetLocalData()` 的"主线程指针缓存"，让游戏线程不必每次都查 TLS map。`bStaticJITTranspiledCodeLoaded` 反映的是当前进程的二进制是否加载了 transpiled JIT 代码——同一进程只能加载一次。

`GlobalStateContainmentMatrix.md` §6 把它们归为 "Process state，暂保留为静态状态" 类。

### 1.4 包引用计数

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Core/AngelscriptEngine.cpp:88-90
// 角色: /Script/Angelscript 与 /Script/AngelscriptAssets 的进程级引用计数
// ============================================================================
static int32 GAngelscriptPackageRefCount = 0;
static int32 GAngelscriptAssetsPackageRefCount = 0;
```

- 多 Engine 各自 `AcquireProcessPackages()` / `ReleaseProcessPackages()` 时只是给计数+/-1，**进程级别**的两个 `UPackage` 单例直到最后一个 Engine 析构才会 `RemoveFromRoot`。
- 这是 "在 PIE 创建第二个 Engine 时不要重复 root 同一个 Package" 的修复痕迹。

### 1.5 日志类别与 NAME 缓存

```cpp
// 节选自: AngelscriptEngine.cpp 顶部
DEFINE_LOG_CATEGORY(Angelscript);
static FName NAME_ReplicatedUsing("ReplicatedUsing");
static FName NAME_BlueprintSetter("BlueprintSetter");
static FName NAME_BlueprintGetter("BlueprintGetter");
```

`DEFINE_LOG_CATEGORY` 创建的 `Angelscript` log category 是进程单例。`static FName NAME_*` 是冷启 FName 缓存，等价于 "lazy" 的 `FName` 池。它们都是只读的，多 Engine 直接共享。

---

## 二、Level 1：ContextStack 与 Ambient World——本文的核心

`Arch_RuntimeLifecycle.md` §一里画了三层架构图，第三层就是 `FAngelscriptEngineContextStack`。本文从"全局状态治理"角度把这一层放大看：**它是一个进程级 `TArray<FAngelscriptEngine*>`，但所有的写都必须通过 RAII Scope 类做对偶 push/pop**。

### 2.1 `GAngelscriptEngineContextStack`：唯一的"当前 Engine"队列

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Core/AngelscriptEngine.cpp:86
// 角色: 进程级"当前正在使用的 Engine 栈"
// ============================================================================
static TArray<FAngelscriptEngine*> GAngelscriptEngineContextStack;
```

它是**真正意义上的全局变量**。但 `FAngelscriptEngineContextStack` 这个公共封装只暴露 4 个静态方法：

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Core/AngelscriptEngine.h:633-644
// 类型: FAngelscriptEngineContextStack
// 角色: 全局栈的"门面"——读、推、弹、空检查
// ============================================================================
struct ANGELSCRIPTRUNTIME_API FAngelscriptEngineContextStack
{
    static void Push(FAngelscriptEngine* Engine);
    static void Pop(FAngelscriptEngine* Engine);
    static FAngelscriptEngine* Peek();
    static bool IsEmpty();

#if WITH_DEV_AUTOMATION_TESTS
    static TArray<FAngelscriptEngine*> SnapshotAndClear();      // ★ 测试专用：暂存全栈
    static void RestoreSnapshot(TArray<FAngelscriptEngine*>&&); // ★ 测试专用：还原
#endif
};
```

**关键：`Push` 与 `Pop` 都是栈语义并且要求成对调用**。`Pop` 会 `ensureAlwaysMsgf` 检查"这次 pop 的对象是不是栈顶"：

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Core/AngelscriptEngine.cpp:448-460
// 函数: FAngelscriptEngineContextStack::Pop
// ============================================================================
void FAngelscriptEngineContextStack::Pop(FAngelscriptEngine* Engine)
{
    if (Engine == nullptr || GAngelscriptEngineContextStack.Num() == 0)
        return;

    // ★ 栈乱序时立刻 ensure，定位到错配的调用点
    ensureAlwaysMsgf(GAngelscriptEngineContextStack.Last() == Engine,
        TEXT("Angelscript engine context stack pop order mismatch."));
    if (GAngelscriptEngineContextStack.Last() == Engine)
    {
        GAngelscriptEngineContextStack.Pop();
    }
}
```

读入口 `Peek()` 暴露给所有业务代码：

```cpp
// 文件: AngelscriptEngine.cpp:708-724
FAngelscriptEngine* FAngelscriptEngine::TryGetCurrentEngine()
{
    if (FAngelscriptEngine* ScopedEngine = FAngelscriptEngineContextStack::Peek())
        return ScopedEngine;
    // 栈为空时，再看 GameInstance 兜底
    if (UAngelscriptGameInstanceSubsystem* Subsystem = UAngelscriptGameInstanceSubsystem::GetCurrent())
    {
        if (FAngelscriptEngine* AttachedEngine = Subsystem->GetEngine())
            return AttachedEngine;
    }
    return nullptr;
}
```

**两层兜底**：
1. 栈顶（推荐路径，所有 Scope 都走这里）。
2. 当前 GameInstance 持有的 Engine（处理"PIE 内部 BP 调用 AS 时根本没人 Push"的情形——见 §2.4）。

### 2.2 `FAngelscriptEngineScope`：唯一允许直接动栈的 RAII

绝大多数 Push/Pop 应当通过 `FAngelscriptEngineScope` 完成，原因是它把 ContextStack 与 Ambient World 这两件事打包成"成对操作"：

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Core/AngelscriptEngine.h:646-663
// 类型: FAngelscriptEngineScope
// 角色: 进入 Engine 上下文的 RAII 卫兵
// ============================================================================
struct ANGELSCRIPTRUNTIME_API FAngelscriptEngineScope
{
    explicit FAngelscriptEngineScope(FAngelscriptEngine& InEngine, UObject* InWorldContext = nullptr);
    ~FAngelscriptEngineScope();

    FAngelscriptEngineScope(const FAngelscriptEngineScope&) = delete;
    FAngelscriptEngineScope& operator=(const FAngelscriptEngineScope&) = delete;
    FAngelscriptEngineScope(FAngelscriptEngineScope&& Other) noexcept;
    FAngelscriptEngineScope& operator=(FAngelscriptEngineScope&& Other) noexcept;

private:
    void Reset();
    FAngelscriptEngine* Engine = nullptr;
    UObject* PreviousWorldContext = nullptr;
    UObject* PreviousEngineWorldContext = nullptr;
    bool bChangedWorldContext = false;
};
```

构造与 `Reset` 实现：

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Core/AngelscriptEngine.cpp:486-561
// 函数: FAngelscriptEngineScope ctor / Reset
// ============================================================================
FAngelscriptEngineScope::FAngelscriptEngineScope(FAngelscriptEngine& InEngine, UObject* InWorldContext)
    : Engine(&InEngine)
{
    PreviousEngineWorldContext = InEngine.WorldContextObject;     // ① 备份 Engine 实例字段
    FAngelscriptEngineContextStack::Push(Engine);                 // ② 推栈
    if (InWorldContext != nullptr) {
        PreviousWorldContext = GAmbientWorldContext;              // ③ 备份 ambient world
        FAngelscriptEngine::AssignWorldContext(InWorldContext);   //    并切换
        bChangedWorldContext = true;
    } else {
        SyncAmbientWorldContextFromCurrentEngine();               // ★ 跟着新栈顶 Engine 同步 ambient
    }
}

void FAngelscriptEngineScope::Reset()
{
    if (Engine == nullptr) return;

    if (bChangedWorldContext)
        Engine->WorldContextObject = PreviousEngineWorldContext;  // 还原 Engine 实例字段

    FAngelscriptEngineContextStack::Pop(Engine);                  // ★ 弹栈
    SyncAmbientWorldContextFromCurrentEngine();                   // ★ 重新同步 ambient
    Engine = nullptr;
    /* ... 清理状态字段 ... */
}
```

**两个不变量**：
- 构造与析构都同步一次 ambient world 与栈顶 engine（`SyncAmbientWorldContextFromCurrentEngine`）。
- move 构造/赋值会把"是否改了 world"等标志一并转移，保证只有一份析构会真正 `Pop`。

`Initialize()` 自身就用一份 Scope 把"正在初始化的 this"压进去：

```cpp
// 文件: AngelscriptEngine.cpp:809-811
void FAngelscriptEngine::Initialize()
{
    FAngelscriptEngineScope ScopedInitializingEngine(*this);
    PreInitialize_GameThread();
    /* ... */
}
```

——这意味着 `BindScriptTypes()` / `InitialCompile()` 内部任何 `TryGetCurrentEngine()` 都能找到自己。

### 2.3 `GAmbientWorldContext`：游戏线程的"当前世界"

`Ambient World` 是 Hazelight 引入的概念：**所有 AS 业务代码默认拿到的 `WorldContextObject` 是这个全局变量**，而不是从某个调用者参数传进来。

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Core/AngelscriptEngine.cpp:208,370-403
// 节选自: GAmbientWorldContext 与同步函数
// ============================================================================
static UObject* GAmbientWorldContext = nullptr;

static void SetAmbientWorldContext(UObject* NewWorldContext)
{
    if (NewWorldContext != nullptr && !NewWorldContext->IsValidLowLevelFast(false))
        NewWorldContext = nullptr;

    *(UObject* volatile*)&GAmbientWorldContext = NewWorldContext;   // ★ volatile store
    check(FAngelscriptEngine::CanUseGameThreadData());

#if WITH_EDITOR
    extern ANGELSCRIPTRUNTIME_API void SetAngelscriptWorldContextAvailable(bool bAvailable);
    SetAngelscriptWorldContextAvailable(
        (NewWorldContext != nullptr)
        && !NewWorldContext->HasAnyFlags(RF_ArchetypeObject | RF_ClassDefaultObject)
        && (NewWorldContext->GetWorld() != nullptr));
#endif
}

static void SyncAmbientWorldContextFromCurrentEngine()
{
    if (FAngelscriptEngine* CurrentEngine = FAngelscriptEngine::TryGetCurrentEngine())
        SetAmbientWorldContext(CurrentEngine->GetCurrentWorldContextObject());
    else
        SetAmbientWorldContext(nullptr);
}

UObject* FAngelscriptEngine::GetAmbientWorldContext() { return GAmbientWorldContext; }
```

写入路径只有一条 —— `AssignWorldContext`：

```cpp
// 文件: AngelscriptEngine.cpp:736-744
void FAngelscriptEngine::AssignWorldContext(UObject* NewWorldContext)
{
    if (FAngelscriptEngine* CurrentEngine = TryGetCurrentEngine())
        CurrentEngine->WorldContextObject = NewWorldContext;
    SetAmbientWorldContext(NewWorldContext);
}
```

**两份镜像**：当前 Engine 的 `WorldContextObject` 字段（per-instance）+ `GAmbientWorldContext`（process-wide）。这是 Editor / PIE 切换时的关键：Editor 主引擎可能仍持有 Editor 主世界的指针，而 PIE 期间 `GAmbientWorldContext` 被推到 PIE 世界。`FAngelscriptEngineScope` 析构时调 `SyncAmbientWorldContextFromCurrentEngine`，把 ambient 还原到栈顶引擎的 World，避免 PIE 退出后还指向已 GC 的 PIE world。

### 2.4 `FAngelscriptGameThreadScopeWorldContext`：纯切 World 不切 Engine 的 RAII

很多 bind 实现需要"在调一个原生函数前临时把 World 设为 Self->GetWorld()"，但**不需要切 Engine**。这时候用：

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Core/AngelscriptEngine.h:721-735
// 类型: FAngelscriptGameThreadScopeWorldContext
// 角色: 仅切换 ambient world 的轻量 RAII，常用于 Bind_SystemTimers 等
// ============================================================================
struct FAngelscriptGameThreadScopeWorldContext
{
    FAngelscriptGameThreadScopeWorldContext(UObject* WorldContext)
    {
        PreviousWorldContext = FAngelscriptEngine::GetAmbientWorldContext();
        FAngelscriptEngine::AssignWorldContext(WorldContext);
    }

    ~FAngelscriptGameThreadScopeWorldContext()
    {
        FAngelscriptEngine::AssignWorldContext(PreviousWorldContext);   // ★ 严格还原
    }
private:
    UObject* PreviousWorldContext;
};
```

`Tick` 末尾的防御断言要求 ambient 在每帧末必须为 null：

```cpp
// 文件: AngelscriptEngine.cpp:3148
UE_CLOG(GAmbientWorldContext != nullptr, Angelscript, Fatal,
    TEXT("Angelscript world context was improperly restored after use!"));
```

——这意味着任何"外部业务代码"都必须通过 RAII Scope 临时切换 world，绝不能裸 `AssignWorldContext(World)` 而不还原。`Bind_SystemTimers.cpp` 与 `Bind_UUserWidget.cpp` 是合法用法，详见 `GlobalStateContainmentMatrix.md` §2。

### 2.5 `bInitializeAngelscriptCalled` 与 `OwnedPrimaryEngine`

最后一个 Level 1 全局是 `FAngelscriptRuntimeModule` 上的两个 static：

```cpp
// 文件: AngelscriptRuntime/Core/AngelscriptRuntimeModule.cpp:8-13
bool FAngelscriptRuntimeModule::bInitializeAngelscriptCalled = false;
TUniquePtr<FAngelscriptEngine> FAngelscriptRuntimeModule::OwnedPrimaryEngine;
#if WITH_DEV_AUTOMATION_TESTS
TFunction<FAngelscriptEngine*()> FAngelscriptRuntimeModule::InitializeOverrideForTesting;
FAngelscriptEngine* FAngelscriptRuntimeModule::InitializedOverrideEngineForTesting = nullptr;
#endif
```

- `bInitializeAngelscriptCalled` 是"统一入口幂等哨兵"，多次 `InitializeAngelscript()` 调用直接返回（详见 `Arch_RuntimeLifecycle.md` §2.1）。
- `OwnedPrimaryEngine` 仅在 Headless / 极早期场景作为兜底所有者持有 Engine。Editor / Game 路径下它**始终为空**——所有权在 Subsystem 那边的嵌入式 USTRUCT 字段。
- `InitializeOverrideForTesting` / `InitializedOverrideEngineForTesting` 是 Test 注入点（详见 §五）。

---

## 三、Level 2：Thread-local 状态

AS VM 是单线程模型，但 UE 是多线程引擎。"线程本地"这层把"哪些数据可以多线程独立持有"正确隔离。

### 3.1 `GAngelscriptContextPool`：每线程一份的执行上下文池

```cpp
// 文件: AngelscriptRuntime/Core/AngelscriptEngine.h:672
extern thread_local FAngelscriptContextPool GAngelscriptContextPool;

// 文件: AngelscriptRuntime/Core/AngelscriptEngine.h:665-670
struct FAngelscriptContextPool
{
    TArray<asCContext*> FreeContexts;
    ~FAngelscriptContextPool();
};
```

`FAngelscriptPooledContextBase` 在分配 `asCContext` 时优先从当前线程的 `FreeContexts` 弹一个；线程销毁时整池释放。`FAngelscriptEngine::Shutdown` 会同步清空当前线程的 free list 中属于该 Engine 的部分（`ReleaseContextsForScriptEngine`）。

### 3.2 `GAngelscriptStack`：线程的调试栈快照

```cpp
// 文件: AngelscriptRuntime/Core/AngelscriptEngine.h:673
extern FAngelscriptEngine::FAngelscriptDebugStack* GAngelscriptStack;
```

它**没**带 `thread_local`——这是历史选择，意味着同一时刻只有一个线程在维护 AS 调试栈。`PreInitialize_GameThread` 中安装 `asSetGameThread*Callbacks`，由 AS VM 在线程切换时主动同步这个指针。后续 stack-pop callback 也用它做"AS 函数返回时弹掉调试帧"。

### 3.3 编辑器线程安全标记

`ClassGenerator/ASClass.cpp` 顶部声明了两个**真正的** `thread_local`：

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/ClassGenerator/ASClass.cpp:39-47
// 角色: 编辑器侧线程安全状态查询（仅 WITH_EDITOR）
// ============================================================================
#if WITH_EDITOR
thread_local bool GIsInAngelscriptThreadSafeFunction = false;
thread_local bool GIsAngelscriptWorldContextAvailable = false;

ANGELSCRIPTRUNTIME_API void SetAngelscriptWorldContextAvailable(bool bAvailable)
{
    GIsAngelscriptWorldContextAvailable = bAvailable;
}
#endif
```

`SetAmbientWorldContext` 在每次写 `GAmbientWorldContext` 时同步更新 `GIsAngelscriptWorldContextAvailable`——这样 `default` 语句在异步加载线程上跑时，可以快速判断"现在能不能拿 World"，无需访问 GAmbientWorldContext 本身。

### 3.4 `UASClass::OverrideConstructingObject` 与默认构造 outer

```cpp
// 文件: AngelscriptRuntime/ClassGenerator/ASClass.cpp:37
UObject* UASClass::OverrideConstructingObject = nullptr;

// 文件: AngelscriptRuntime/ClassGenerator/ASClass.cpp:1011
static thread_local UObject* GASDefaultConstructorOuter = nullptr;
```

`OverrideConstructingObject` 严格意义上是 "类静态" 而非 thread_local，但用法是"把对象 push 进去 → 在 default 语句结束后 pop 出来"，配合 `CurrentObjectInitializers` 这个 `TArray<FObjectInitializer>` 栈，处理 AS 的 `default Component = ...` 构造时机。

`GASDefaultConstructorOuter` 是真线程局部，在每条 game-thread 默认构造时记下"当前的 outer"，给 `default` 语句体提供闭包。

---

## 四、多 Engine 实例并存：隔离边界

到目前为止盘点的全局状态可以分成两类：**进程共享**（Level 0、Level 2 部分）与 **per-instance**（Level 3）。多 Engine 并存的隔离规则可以概括为一张表。

### 4.1 隔离矩阵

| 状态 | 范畴 | Editor 主 Engine + PIE Engine | Test 多 Engine |
|------|------|-------------------------------|----------------|
| `GAngelscriptEngineContextStack` | Level 1 | 同一栈，按生命周期串行 push | 每个 Test 走一次 SnapshotAndClear/Restore |
| `GAmbientWorldContext` | Level 1 | 跟随栈顶 Engine 自动同步 | 每个 Test 用 `FScopedTestWorldContextScope` |
| `ActiveTickOwners` | Level 1 | PIE 启停时 ++/-- | Test 中通常 == 0（无 GameInstance） |
| `GetBindArray()` | Level 0 | 共享只读 | 共享只读 |
| `FAngelscriptEngine::GameThreadTLD` | Level 0 | 共享（指向同一 AS thread manager 槽） | 共享 |
| `FAngelscriptEngine::WorldContextObject` | Level 3 | 各占一份 | 各占一份 |
| `FAngelscriptEngine::BindState` | Level 3 | 各占一份 | 各占一份 |
| `FAngelscriptEngine::TypeDatabase` | Level 3 | 各占一份 | 各占一份 |
| `FAngelscriptEngine::StaticNames` | Level 3 | 各占一份 | 各占一份 |
| `GLegacyStaticNames` | Level 0 (legacy) | 仅 fallback 使用 | 仅 fallback 使用 |

### 4.2 Editor 主 Engine 与 PIE Engine 的关系

绝大多数生产部署里 **PIE 不创建新 Engine**——`UAngelscriptGameInstanceSubsystem::Initialize` 优先 adopt 已有 Engine：

```cpp
// 文件: AngelscriptRuntime/Core/AngelscriptGameInstanceSubsystem.cpp:12-30
void UAngelscriptGameInstanceSubsystem::Initialize(FSubsystemCollectionBase& Collection)
{
    Super::Initialize(Collection);
    bInitialized = true;
    PrimaryEngine = FAngelscriptEngine::TryGetCurrentEngine();   // ★ adopt 已有的
    if (PrimaryEngine == nullptr) {
        PrimaryEngine = &OwnedEngine;
        FAngelscriptEngineContextStack::Push(PrimaryEngine);
        OwnedEngine.Initialize();
        bOwnsPrimaryEngine = true;
    }
    if (PrimaryEngine != nullptr)
        ++ActiveTickOwners;        // ★ 让位计数
}
```

——也就是说 PIE 期间是"同一个 Engine + Tick 让位 + ambient world 切换到 PIE world"。**没有"两个独立 Engine"的隔离问题**。

让位机制由 `EngineSubsystem::Tick` 实现：

```cpp
// 文件: AngelscriptEngineSubsystem.cpp:61-72
void UAngelscriptEngineSubsystem::Tick(float DeltaTime)
{
    if (PrimaryEngine == nullptr || UAngelscriptGameInstanceSubsystem::HasAnyTickOwner())
        return;                  // ★ 让位：PIE 期间 EngineSubsystem 闭嘴
    if (PrimaryEngine->ShouldTick())
        PrimaryEngine->Tick(DeltaTime);
}
```

详见 `Arch_RuntimeLifecycle.md` §三。

### 4.3 Test 中的"真·多 Engine"

只有 Test 场景会出现真正的多 Engine 并存，典型情况：

- `AcquireCleanSharedCloneEngine()` 提供一个被多次 reset 复用的"shared engine"。
- `CreateIsolatedFullEngine()` / `AcquireTransientFullTestEngine()` 每个 Spec 起来时新建一个 isolated engine。
- 同一个 Test 进程内可能有 N 个 `FAngelscriptEngineScope` 嵌套、`SnapshotAndClear` 暂存全栈。

这些都靠 ContextStack 是真"栈"来做嵌套隔离——栈顶就是当前活跃 Engine，下面的 frame 不会被破坏（除非测试故意调 `SnapshotAndClear` 抹掉）。

---

## 五、Test 场景下的 reset 协议

Test 是全局状态最容易出问题的地方：上一个 Spec 留下来的 ambient world、ContextStack 残余 frame、被 root 但忘了 unroot 的 UASClass 都会让下一个 Spec 假阳性或 crash。`AngelscriptTestUtilities.h` 把这些清理仪式都封装好了。

### 5.1 三种 Engine 模式

```cpp
// 文件: AngelscriptTest/Shared/AngelscriptTestUtilities.h:1009-1014
enum class ETestEngineMode : uint8
{
    SharedClone,        // 共享 engine，每个 Spec 自动 reset modules
    IsolatedFull,       // 每个 Spec 一个全新 Full engine
    ProductionLike,     // 优先用真 production engine，否则建 Full engine
};
```

`FAngelscriptTestFixture` 在构造时按模式选择 engine 来源，析构时清理。最常用的 `SharedClone` 模式背后就是 `AcquireCleanSharedCloneEngine()`：

```cpp
// 文件: AngelscriptTest/Shared/AngelscriptTestUtilities.h:584-591
inline FAngelscriptEngine& AcquireCleanSharedCloneEngine()
{
    FAngelscriptEngine& Engine = GetOrCreateSharedCloneEngine();
    UE_LOG(Angelscript, Verbose, TEXT("[TestEngine] AcquireClean: resetting shared engine %p"),
        &Engine);
    ResetSharedCloneEngine(Engine);                            // ★ 调 FAngelscriptTestEngine::ResetModules
    return Engine;
}
```

`ResetModules` 把上一个 Spec 编译进来的 module 全部丢弃；shared engine 实例本身保留，避免每个 Spec 都重跑 144+ Bind。

### 5.2 复位"Shared + Stray Global"：双重清理

如果之前的 Spec 创建过 Full engine 但没正确 destroy（典型是 crash 或断言中断），shared 与 stray 两者都要清：

```cpp
// 文件: AngelscriptTest/Shared/AngelscriptTestUtilities.h:629-639
inline void DestroySharedAndStrayGlobalTestEngine()
{
    DestroySharedTestEngine();                  // 清 shared
    DestroyStrayLegacyGlobalTestEngine();       // 清 stray（仅当无 GameInstance）
}

inline FAngelscriptEngine& AcquireFreshSharedCloneEngine()
{
    DestroySharedAndStrayGlobalTestEngine();
    return AcquireCleanSharedCloneEngine();
}
```

`DestroyStrayLegacyGlobalTestEngine` 用 `UAngelscriptGameInstanceSubsystem::HasAnyTickOwner()` 判断"现在是否真的没在跑生产 engine"——避免误删 PIE 中正在用的 engine：

```cpp
// 文件: AngelscriptTest/Shared/AngelscriptTestUtilities.h:616-627
inline void DestroyStrayLegacyGlobalTestEngine()
{
    if (!UAngelscriptGameInstanceSubsystem::HasAnyTickOwner())
    {
        if (FAngelscriptEngine* GlobalEngine = FAngelscriptTestEngineScopeAccess::GetGlobalEngine())
            ResetSharedCloneEngine(*GlobalEngine);
        FAngelscriptTestEngineScopeAccess::DestroyGlobalEngine();
    }
}
```

### 5.3 World context 隔离：`FScopedTestWorldContextScope`

```cpp
// 文件: AngelscriptTest/Shared/AngelscriptTestUtilities.h:101-113
struct FScopedTestWorldContextScope
{
    explicit FScopedTestWorldContextScope(UObject* WorldContextObject)
    {
        if (WorldContextObject != nullptr)
            Scope = MakeUnique<FAngelscriptGameThreadScopeWorldContext>(WorldContextObject);
    }

private:
    TUniquePtr<FAngelscriptGameThreadScopeWorldContext> Scope;
};
```

——直接复用 §2.4 的轻量 RAII，但允许 `nullptr` 入参（这样 Test 写 `FScopedTestWorldContextScope WorldContext(MaybeNullObject)` 不必前置 if）。

### 5.4 ContextStack snapshot：`SnapshotAndClear` / `RestoreSnapshot`

最激进的"环境干净"动作是把 ContextStack 全栈暂存到本地变量：

```cpp
// 文件: AngelscriptRuntime/Core/AngelscriptEngine.cpp:472-484
#if WITH_DEV_AUTOMATION_TESTS
TArray<FAngelscriptEngine*> FAngelscriptEngineContextStack::SnapshotAndClear()
{
    TArray<FAngelscriptEngine*> Saved = MoveTemp(GAngelscriptEngineContextStack);
    GAngelscriptEngineContextStack.Empty();
    return Saved;
}

void FAngelscriptEngineContextStack::RestoreSnapshot(TArray<FAngelscriptEngine*>&& SavedStack)
{
    GAngelscriptEngineContextStack = MoveTemp(SavedStack);
}
#endif
```

典型用法（`TryGetRunningProductionDebuggerEngine` 的实现）：

```cpp
// 文件: AngelscriptTest/Shared/AngelscriptTestUtilities.h:225-243（节选）
#if WITH_DEV_AUTOMATION_TESTS
TArray<FAngelscriptEngine*> SavedStack = FAngelscriptEngineContextStack::SnapshotAndClear();
FAngelscriptEngine* MatchingEngine = nullptr;
for (int32 Index = SavedStack.Num() - 1; Index >= 0; --Index) {
    FAngelscriptEngine* Candidate = SavedStack[Index];
    if (Candidate != nullptr && Candidate->DebugServer != nullptr) {
        MatchingEngine = Candidate;
        break;
    }
}
FAngelscriptEngineContextStack::RestoreSnapshot(MoveTemp(SavedStack));   // ★ 必还原
return MatchingEngine;
#endif
```

**契约**：每一次 `SnapshotAndClear` 必须配一次 `RestoreSnapshot`，否则后续 Test 会拿不到 engine。该 API 仅 `WITH_DEV_AUTOMATION_TESTS` 启用，正式构建里编不过去。

### 5.5 Bootstrap 测试边界：Module hook 与 Subsystem scope

如果想测"`InitializeAngelscript` 路由本身"而不真跑完整 Bind，`FAngelscriptRuntimeModule` 仍保留模块级注入点：

```cpp
// 文件: AngelscriptRuntime/Core/AngelscriptRuntimeModule.cpp:87-107
#if WITH_DEV_AUTOMATION_TESTS
void FAngelscriptRuntimeModule::SetInitializeOverrideForTesting(TFunction<FAngelscriptEngine*()> InOverride);
void FAngelscriptRuntimeModule::ResetInitializeStateForTesting();
#endif

```

`UAngelscriptSubsystem` 不再暴露 `WITH_DEV_AUTOMATION_TESTS` 状态。Subsystem 测试通过真实生产 Subsystem 或 CQTest fixture 自己创建的 `FAngelscriptEngineScope` 验证行为；测试 engine 不会被 TestModule 保存到启动期，也不会改变生产 Subsystem 的启动顺序。

`ResetInitializeStateForTesting`：

```cpp
// 文件: AngelscriptRuntimeModule.cpp:92-107
void FAngelscriptRuntimeModule::ResetInitializeStateForTesting()
{
    if (InitializedOverrideEngineForTesting != nullptr) {
        FAngelscriptEngineContextStack::Pop(InitializedOverrideEngineForTesting);
        InitializedOverrideEngineForTesting = nullptr;
    }
    if (OwnedPrimaryEngine.IsValid()) {
        FAngelscriptEngineContextStack::Pop(OwnedPrimaryEngine.Get());
        OwnedPrimaryEngine.Reset();
    }
    bInitializeAngelscriptCalled = false;        // ★ 重置幂等哨兵
    InitializeOverrideForTesting = nullptr;
}
```

这是"把 module-级哨兵 + ContextStack 残余 + override engine 一起清掉"的标准复位仪式。

### 5.6 Test 复位顺序总结

```text
                Test 复位仪式（Spec 起来前 / 结束后）
                ====================================
    Spec 起来前：
        1. AcquireFreshSharedCloneEngine()          // 双重清理
              · DestroySharedTestEngine()
                    └─ ResetModules + Reset scope + Reset storage
              · DestroyStrayLegacyGlobalTestEngine()
                    └─ 仅 !HasAnyTickOwner() 时
              · AcquireCleanSharedCloneEngine()
                    └─ ResetModules
        2. FAngelscriptEngineScope EngineScope(*Engine);
        3. （可选）FScopedTestWorldContextScope WorldContext(WorldObject);

    Spec 结束后（RAII 自动逆序）：
        ~FScopedTestWorldContextScope    // ambient world 还原
        ~FAngelscriptEngineScope         // ContextStack pop + ambient sync
        // shared engine 留着给下一个 Spec
```

`FAngelscriptTestFixture` 把上述全部包起来，Test 编写者只需 `FAngelscriptTestFixture Fixture(*this);` 一行。

---

## 六、Cooked vs Editor：哪些全局只在 Editor 存在

不同 build target 下"全局状态地图"略有差别：

| 状态 | Cooked | Editor | Headless Test | 说明 |
|------|--------|--------|---------------|------|
| `GAngelscriptEngineContextStack` | 存在 | 存在 | 存在 | 进程级，与 build 无关 |
| `GAmbientWorldContext` | 存在 | 存在 | 存在 | 进程级 |
| `GIsAngelscriptWorldContextAvailable` | 否 | 存在（thread_local） | 存在 | `WITH_EDITOR` only |
| `GIsInAngelscriptThreadSafeFunction` | 否 | 存在（thread_local） | 存在 | `WITH_EDITOR` only |
| `UAngelscriptEngineSubsystem` | 否 | 存在 | 存在 | 仅 `GIsEditor \|\| IsRunningCommandlet` |
| `UAngelscriptGameInstanceSubsystem` | 存在（PIE/Game） | 存在（PIE） | 通常不存在 | 仅当有 GameInstance |
| `OwnedPrimaryEngine` (Module) | 通常不用 | 通常不用 | **常用** | Headless 兜底 |
| `bScriptDevelopmentMode` | false | true | true | 决定 HotReload 与 DebugServer 是否启用 |
| `DebugServer` | 视配置 | 视配置 | 视配置 | 仅 `bScriptDevelopmentMode && !bIsCookedGame` |
| `HotReloadCheckerThread` | 否 | 否（Editor 走 DirectoryWatcher） | 是 | 详见 `RT_HotReload.md` |
| `*ForTesting` 注入点 | 不编译 | 编译 | 编译 | `WITH_DEV_AUTOMATION_TESTS` |

**含义**：
- Cooked 构建里很多 "全局"会被 `WITH_EDITOR` / `WITH_DEV_AUTOMATION_TESTS` 编译条件直接消除，地图变得最简洁——只剩 Level 0 的 BindArray、ContextStack、Ambient World 这条骨架。
- Editor 多了一层"world context 是否可用"的查询缓存（`GIsAngelscriptWorldContextAvailable`），用以让 `default` 语句在异步加载线程上能廉价判断。
- Headless Test 里 `OwnedPrimaryEngine` 是真正的所有者；`UAngelscriptEngineSubsystem` 由于 `GIsEditor && !IsRunningCommandlet` 失败而不创建。

---

## 七、与 HotReload / StateDump / BindSystem 的边界

### 7.1 HotReload 是否清空 ContextStack

**不会**。`RT_HotReload.md` 里讲过，HotReload 在 Editor 主引擎的 Tick 内同步运行：

- 进入 `CheckForHotReload(SoftReloadOnly | FullReload)` 时已经处于 `FAngelscriptEngineScope` 之下（`Tick` 是被 Subsystem 调用的，但 Subsystem 在 Tick 入口前没有显式 push——Tick 内部依赖 `TryGetCurrentEngine()` 走 GameInstance 兜底）。
- HotReload 期间会 push/pop 一些 module-级 scope（`AS_PERF_SCOPE_HOTRELOAD_*`），但**不动 ContextStack 顶层 frame**。
- HotReload 结束后 `WorldContextObject` 与 `GAmbientWorldContext` 维持原样。

唯一例外是 `FullReload` 触发的"重新执行 InitialCompile"时，`Initialize_AnyThread` 内部会重新创建 `BindState` 等 per-engine 字段——但 `ContextStack` 上的 Engine 指针不变，`GAmbientWorldContext` 也不变。

### 7.2 StateDump 对应的全局状态表

`RT_StateDump.md` §3.2 列了 27 张表。本文盘点的全局状态对应到 Dump 表的关系：

| 全局状态 | 对应 Dump 表 | 说明 |
|---------|------------|------|
| `GAngelscriptEngineContextStack` | `EngineOverview.csv` | `ContextStackDepth` 字段 |
| `GAmbientWorldContext` | `EngineOverview.csv` | `AmbientWorldContext` 字段 |
| `ActiveTickOwners` | `EngineOverview.csv` | `TickOwners` 字段 |
| `GetBindArray()` | `BindRegistrations.csv` | 完整 BindName/BindOrder 表 |
| `FAngelscriptEngine::TypeDatabase` | `RegisteredTypes.csv` | per-engine 反射类型 |
| `FAngelscriptEngine::BindState::BindModuleNames` | `BindModules.csv` | per-engine bind module 列表 |
| `bInitializeAngelscriptCalled` | `EngineOverview.csv` | `InitializeAngelscriptCalled` 字段 |
| `bScriptDevelopmentMode` | `EngineOverview.csv` | 决定 HotReload/DebugServer 列空否 |

**调试技巧**：怀疑全局状态泄漏时，先 `as.DumpEngineState`，对比 `EngineOverview.csv` 的 `ContextStackDepth` 与 `TickOwners`——它们应该对得上当前的部署形态（Editor=1/0、PIE=1/1、Test=1/0、Headless=1/0）。

### 7.3 与 `Type_BindSystem.md` 的边界

- 本文负责"`GetBindArray()` 是 Level 0 进程单例"这件**事实**。
- `Type_BindSystem.md` 负责"`FBind` 单例怎么写、6 个重载、CallBinds 的执行顺序"等**机制**细节。
- `FAngelscriptBindState` 是 per-engine（Level 3），由 `BindState = MakeUnique<FAngelscriptBindState>()` 在 `Initialize_AnyThread` 里创建。多 Engine 各占一份 BindState，不会窜流。

---

## 八、调试与诊断

### 8.1 在 debugger 中查看 ContextStack 顶

`GAngelscriptEngineContextStack` 是 file-static，VS / GDB 加 watch：

```text
AngelscriptEngine.cpp:GAngelscriptEngineContextStack
  Num()  → 当前栈深
  Last() → 当前 Engine 指针
  data[N] → 第 N 层 Engine 指针
```

或者在调试时下 conditional breakpoint 在 `FAngelscriptEngineContextStack::Push` / `Pop`，观察栈高变化：

- Editor 主进程稳态：栈深 = 1（EngineSubsystem 的 OwnedEngine）。
- PIE 期间：栈深 = 1（PIE adopt，没有再 push）。
- Test 中嵌套 Scope：栈深 ≥ 1，每嵌一层 Scope +1。

### 8.2 ambient world 异常诊断

`Tick` 末尾 `UE_CLOG(... Fatal, ...)` 的 crash 通常意味着某段业务代码切了 World 没还原。定位顺序：
1. 把 `LogAngelscript` log level 调到 `VeryVerbose`，看 `[EngineScope] Push/Pop` 的栈深变化。
2. grep 调用 `AssignWorldContext(...)` 的非 RAII 调用点——必须用 `FAngelscriptEngineScope` 或 `FAngelscriptGameThreadScopeWorldContext`。
3. 检查 `Bind_*.cpp` 是否漏调 `SetPreviousBindRequiresWorldContext(true)`（详见 `GlobalStateContainmentMatrix.md` §2）。

### 8.3 Test 残余调试

Test 中的"上一个 Spec 留下垃圾"：
- 跑单个 Spec 加 `-LogCmds="LogAngelscript Verbose"`，查 `[TestEngine] AcquireClean / DestroyShared` 日志是否成对。
- 在 Spec 入口手动调 `AcquireFreshSharedCloneEngine()` 替代 `AcquireCleanSharedCloneEngine()`，把 stray engine 也清掉。
- 如果 GC 残余对象多，可调 `LogSharedEngineDebugState(TEXT("MyTest.Pre"), Engine)` 输出"DetachedASClasses / DetachedASFunctions"等计数。

---

## 九、设计原则：哪些不该全局

`GlobalStateContainmentMatrix.md` 给出"已 containment 候选 / 暂保留 / 优先处理"分类。从全局状态治理角度可以提炼几条原则：

1. **"当前正在用的 X" 永远走 RAII Scope，绝不裸读 / 裸写**
   - 当前 Engine：用 `FAngelscriptEngineScope`，绝不直接 `GAngelscriptEngineContextStack.Add(...)`。
   - 当前 World：用 `FAngelscriptGameThreadScopeWorldContext` 或 `AssignWorldContext` 配对调用。

2. **Per-instance 的状态不要升到 file-static**
   - 反例：早期把 `bGeneratePrecompiledData` 写成 file-static，导致 PIE 期间 StaticJIT 误以为 Editor 状态。修复后挪回 `FAngelscriptEngine` 实例字段（详见 `GlobalStateContainmentMatrix.md` §6）。
   - 正例：`BindState` / `TypeDatabase` 都是 per-engine 的 `TUniquePtr<>`。

3. **"进程一次性"的事情才能走 Meyers' singleton**
   - `GetBindArray()` 是合法的——`FBind` 静态构造期就把绑定登记好，整个进程不会改。
   - 反例（已修复）：早期把"已绑定 FName cache"放到 Meyers' singleton，多 Engine 时新 Engine 拿到的是上一个 Engine 的缓存。

4. **Test 注入点用 `WITH_DEV_AUTOMATION_TESTS` 严格门控**
   - 三层（RuntimeModule / EngineSubsystem / ContextStack）的 `*ForTesting` 都加 `#if WITH_DEV_AUTOMATION_TESTS`，正式构建里编译失败而不是悄悄链接进去。

5. **"哪个进程这一刻能看到 Engine"是路由问题，不是状态问题**
   - `TryGetCurrentEngine()` 的两层兜底（栈顶 → GameInstance）是路由策略；不是某个布尔变量。这意味着你**不能**在 file-static 里 cache `Engine`，必须每次问 `TryGetCurrentEngine()`——否则 PIE / 多 Engine 切换时会拿到陈旧指针。

---

## 附录 A：全局状态速查表

| 名称 | 类型 | 范畴 | 文件 | 写者 | 读者 |
|------|------|------|------|------|------|
| `GAngelscriptEngineContextStack` | `TArray<FAngelscriptEngine*>` | Process | `AngelscriptEngine.cpp:86` | `FAngelscriptEngineScope` | `TryGetCurrentEngine` |
| `GAmbientWorldContext` | `UObject*` (volatile) | Process | `AngelscriptEngine.cpp:208` | `AssignWorldContext` / Scope sync | `GetAmbientWorldContext` / Bind |
| `ActiveTickOwners` | `int32` | Process (static class member) | `AngelscriptGameInstanceSubsystem.cpp:8` | GameInstanceSubsystem Init/Deinit | `EngineSubsystem::Tick` 让位 |
| `bInitializeAngelscriptCalled` | `bool` | Process (static module member) | `AngelscriptRuntimeModule.cpp:8` | `InitializeAngelscript` 哨兵 | 同左 |
| `OwnedPrimaryEngine` | `TUniquePtr<FAngelscriptEngine>` | Process | `AngelscriptRuntimeModule.cpp:9` | Headless 兜底创建 | `ShutdownModule` 释放 |
| `GAngelscriptLineReentry` | `bool` | Process | `AngelscriptEngine.cpp:93` | line callback 自旋门票 | line callback 入口 |
| `GAngelscriptRecompileAvoidance` | `int32 (CVar)` | Process | `AngelscriptEngine.cpp:96` | `as.UseRecompileAvoidance` CVar | InitialCompile / HotReload |
| `GAngelscriptPackageRefCount` | `int32` | Process | `AngelscriptEngine.cpp:89` | Acquire/Release Process Packages | 同左 |
| `GAngelscriptStack` | `FAngelscriptDebugStack*` | Process | `AngelscriptEngine.cpp:91` | game-thread callback | line/stack-pop callback |
| `bStaticJITTranspiledCodeLoaded` | `bool` (static class) | Process | `AngelscriptEngine.h:137` | StaticJIT 加载 | StaticJIT bind 路径 |
| `GameThreadTLD` | `asCThreadLocalData*` (static class) | Process bridge | `AngelscriptEngine.h:136` | `PreInitialize_GameThread` | 线程切换桥 |
| `GAngelscriptContextPool` | `FAngelscriptContextPool` | thread_local | `AngelscriptEngine.h:672` | `FAngelscriptPooledContextBase` | 同左 |
| `GIsInAngelscriptThreadSafeFunction` | `bool` | thread_local (Editor) | `ASClass.cpp:40` | thread-safe scope | `CheckGameThreadExecution` |
| `GIsAngelscriptWorldContextAvailable` | `bool` | thread_local (Editor) | `ASClass.cpp:41` | `SetAmbientWorldContext` | `default` 语句执行 |
| `GASDefaultConstructorOuter` | `UObject*` | thread_local | `ASClass.cpp:1011` | default 构造闭包 push | default 构造闭包 read |
| `UASClass::OverrideConstructingObject` | `UObject*` | static class | `ASClass.cpp:37` | 构造期 push | 构造期 read |
| `GetBindArray()` | `TArray<FBindFunction>` | Meyers' singleton | `AngelscriptBinds.cpp:142` | `FBind` 静态构造 | `CallBinds` |

---

## 附录 B：危险信号清单

1. **`Pop` ensure 失败：`Angelscript engine context stack pop order mismatch`**
   - 含义：某个 Scope 的析构没按 LIFO 顺序，可能是把 Scope 存到了 `TUniquePtr<>` 然后被 std 容器 reorder。
   - 排查：grep `MakeUnique<FAngelscriptEngineScope>`，确认其析构顺序是栈式的。

2. **Tick 末尾 Fatal：`Angelscript world context was improperly restored after use!`**
   - 含义：某段代码切了 ambient world 没还原。
   - 排查：grep `AssignWorldContext` / `SetAmbientWorldContext` 的非 RAII 调用点。

3. **`TryGetCurrentEngine() == nullptr` 在业务代码中触发**
   - 错误日志：`[EngineResolve] Get() failed: no engine available. ... Likely missing FAngelscriptEngineScope`。
   - 含义：调用方没用 RAII Scope 而又跳出了 GameInstance 持有 Engine 的窗口期。
   - 排查：在调用前显式 `FAngelscriptEngineScope`，或改用 `TryGetCurrentEngine()` 容忍 nullptr。

4. **PIE 退出后 Editor 主 Engine 的 `WorldContextObject` 仍指向已 GC 的 PIE world**
   - 含义：某段在 PIE 退出 callback 中调了 `Engine->WorldContextObject = ...` 而非走 Scope。
   - 排查：检查 `OnPIEEnded` 与相关回调，**绝不直接写 `Engine->WorldContextObject`**——除非通过 Scope 备份了 `PreviousEngineWorldContext`。

5. **Test 失败"前一个 Spec 注册的 module 还在"**
   - 含义：上一个 Spec 没正确析构 Fixture，shared engine 的 ActiveModules 没 reset。
   - 排查：spec 入口加 `AcquireFreshSharedCloneEngine()` 替代 `AcquireCleanSharedCloneEngine()`；或检查 Fixture 的析构是否被异常吞掉。

6. **多 Engine Test 中 `BindArray` 行为反常**
   - 含义：试图在 Test 中向 `GetBindArray()` 追加新条目（不该这么做——`FBind` 是静态构造期登记）。
   - 排查：用 `FAngelscriptBindDatabase`（per-engine, Level 3）而不是改 `BindArray`（process, Level 0）。

7. **`bInitializeAngelscriptCalled == true` 阻断 Test 二次 Bootstrap**
   - 含义：Test 想模拟"再次 Bootstrap"但哨兵卡住。
   - 解法：调 `FAngelscriptRuntimeModule::ResetInitializeStateForTesting()` 显式复位。

8. **HotReload 后 `GAngelscriptStack` 残留旧 Engine 的调试帧**
   - 含义：HotReload 触发的 Engine `Initialize` 重入与 line callback 抢占。
   - 缓解：`PreInitialize_GameThread` 已经清空 free-context 池，但 `GAngelscriptStack` 是 game-thread 单例——必须保证 HotReload 期间没有正在跑的 AS context（`bWaitingForHotReloadResults` + `bIsHotReloading` 双门控）。

---

## 小结

- **全局状态被分四级看待**：Level 0 进程单例（与 Engine 实例无关）/ Level 1 进程"当前指针"（受 RAII 管控）/ Level 2 thread-local / Level 3 per-instance。读、写、清三件事在每一级都走不同的 API。
- **`GAngelscriptEngineContextStack` 与 `GAmbientWorldContext` 是 Level 1 的两根主梁**，所有"切当前 Engine / 切当前 World"的写操作都必须通过 `FAngelscriptEngineScope` 或 `FAngelscriptGameThreadScopeWorldContext` 这两个 RAII 完成；裸写一律视为 bug。
- **多 Engine 隔离边界两条**：生产部署里 PIE adopt 主 Engine（Tick 让位），Test 中走 `SnapshotAndClear` / `RestoreSnapshot` + `AcquireCleanSharedCloneEngine`。绝大多数 per-engine 状态（BindState / TypeDatabase / WorldContextObject）天然按实例分隔，不会窜流。
- **Test 复位协议是固定仪式**：`AcquireFreshSharedCloneEngine` →`FAngelscriptEngineScope` →（可选）`FScopedTestWorldContextScope`，析构 RAII 自动回收。`*ForTesting` 接口三层都暴露 `Reset...` / `SetOverride...`，仅 `WITH_DEV_AUTOMATION_TESTS` 编译进。
- **Cooked 与 Editor 的全局状态地图差别有限**：核心三件（ContextStack / Ambient World / BindArray）一致；Editor 多了 thread_local 的 world-availability 缓存与 `UAngelscriptEngineSubsystem`；Headless 走 `OwnedPrimaryEngine` 兜底。
- **设计纪律**：per-instance 不升 file-static、当前指针走 RAII、`TryGetCurrentEngine()` 不缓存。`GlobalStateContainmentMatrix.md` 把这套纪律量化为可执行的 containment 候选——本文是它的"概念解释 + 源码索引"配套读物。
