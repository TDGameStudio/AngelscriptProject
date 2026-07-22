# Type_BindSystem — Bind 系统与 Native 绑定

> **所属前缀**: Type_（类型系统与生成链路族）
> **关注层面**: 站在"插件如何把 C++ 类型 / 函数 / 全局变量 / 枚举注入到 AngelScript 引擎"的视角看 `FAngelscriptBinds` + `FBind` 这一套静态初始化框架——`Bind_*.cpp` 顶部那行 `static FBind Bind_X(EOrder::Foo, []{...})` 在做什么、`EOrder` 怎么排序、`CallBinds` 在生命周期的哪个点回放、125 份手写 `Bind_*.cpp` 与 UHT 生成的 `AS_FunctionBinding_*.cpp` 怎么形成"自动表 + 手写表 + 反射兜底"三层模型。本文不重复"`asITypeInfo` 与 `UClass` 的双向映射"（那是 `Type_Core` 的职责），不重复"UHT 生成器内部的 C# 实现"（那是 `Arch_UHTToolchain`），也不重复"反射 fallback 的 Generic Trampoline 怎么打栈帧"（那是 `Type_FunctionCaller`）；本文聚焦的是把这三件事粘起来的**注册框架**
> **关键源码**:
> `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptBinds.h` (~715 行，`FAngelscriptBinds` / `FBind` / `EOrder` / `FNamespace` / `FEnumBind` 公开 API)
> · `Core/AngelscriptBinds.cpp` (~894 行，`RegisterBinds` / `CallBinds` / `OnBind` / `BindMethod` / `BindGlobalFunction` 实现)
> · `Core/AngelscriptSkipBinds.cpp` (~19 行，`Bind_Skip` 黑名单注册示例)
> · `Core/AngelscriptEngine.cpp::BindScriptTypes` (~2141 行起，`CallBinds` 唯一调用点)
> · `Binds/Bind_*.cpp`（125 份手写绑定，本文以 8 份代表样本展开）
> · `Binds/Bind_BlueprintCallable.cpp` (~403 行，Layer C 反射兜底入口)
> · `Binds/BlueprintCallableReflectiveFallback.cpp` (~1500+ 行，`EvaluateReflectionFallback` / `BindBlueprintCallableReflectionFallback` 主体)
> · `Binds/Bind_BlueprintType.cpp` `Bind_Defaults` 块（~762 行起，Layer A/B/C 触发点：`Late+100`）
> · `Plugins/Angelscript/Intermediate/Build/.../AS_FunctionBinding_<Module>.gen.cpp`（UHT Runtime-linked 产物示例，每模块一个源文件）
> **关联文档**:
> `Documents/Knowledges/ZH/Type_Core.md` — `FAngelscriptType` 数据库（`FBind` 注册的类型对象最终落到这里）
> · `Documents/Knowledges/ZH/Type_ClassGeneration.md` — `UASClass` 生成（消费 `ClassFunctionBindings` 反查 native UFunction）
> · `Documents/Knowledges/ZH/Type_BaseClass.md` — `BindUClass` 把 UClass 注册成 AS 引用类型的入口
> · `Documents/Knowledges/ZH/Type_FunctionCaller.md` — `ASAutoCaller` 与反射 fallback 的调用约定细节
> · `Documents/Knowledges/ZH/Arch_UHTToolchain.md` — UHT C# 工具链如何在构建期写出 `AS_FunctionBinding_*.cpp`
> · `Documents/Knowledges/ZH/Arch_RuntimeLifecycle.md` — `BindScriptTypes` 在 `Initialize_AnyThread` 中的位置
> · `Documents/Knowledges/ZH/AS_TypeRegistration.md` — AS 内核 `RegisterObjectType` / `RegisterObjectMethod` 实现细节

---

## 概览

本文聚焦一个核心问题：**当一份 `Bind_FVector.cpp` 在文件顶部写下 `static FBind Bind_FVector(EOrder::Early, []{...})`，这一行代码在 .dll 加载、引擎初始化、`CallBinds` 回放、AS 内核 `RegisterObjectType` 之间是怎样的因果链？125 份 `Bind_*.cpp` 与 UHT 生成的约 30 份 `AS_FunctionBinding_*.cpp` 又如何在同一个 `EOrder::Late+100` 阶段通过同一棵 `ClassFunctionBindings` 把"自动绑定 → 手写绑定 → 反射兜底"三层叠成一个最终的 AS 类型表？**

```text
================================================================================
  Bind 系统全景：static initializer → 全局队列 → CallBinds 回放 → 三层叠加
================================================================================

[构建期 / 链接期]                                     [全局静态对象空间]
                                                      ┌──────────────────────┐
Bind_FVector.cpp:                                     │                       │
  AS_FORCE_LINK const                                 │  static TArray<       │
  FBind Bind_FVector(EOrder::Early, []{               │    FBindFunction      │
    ValueClass<FVector>("FVector")                    │  > BindArray;         │
      .Constructor(...)                               │                       │
      .Method(...)                                    │  ★ 链接器把每条       │
      .Property(...)                                  │  AS_FORCE_LINK 标记的 │
  });        │                                        │  全局对象编入 .data   │
             │ FBind ctor:                            │  段，构造时 push 进   │
             ▼ RegisterBinds(name, order, fn)         │  BindArray            │
                                                      └──────────────┬────────┘
[运行期 / FAngelscriptEngine::Initialize]                            │
                                                                     │
   PreInitialize_GameThread()  → asCreateScriptEngine                │
                                                                     │
   InitializeWithoutInitialCompile / Initialize_AnyThread:           │
       Engine->SetEngineProperty(...)                                │
       AllRootPaths = DiscoverScriptRoots(...)                       │
       FAngelscriptBindDatabase::Get().Load(...)  // cooked          │
       MakeUnique<FAngelscriptBindState>()                           │
                  ▼                                                  │
       BindScriptTypes()                                             │
           ├─ FAngelscriptBinds::CallBinds(DisabledBindNames)        │
           │     │                                                   │
           │     │ Sort(BindArray) by BindOrder ──────────────────────┘
           │     │
           │     ▼ for each bind in sorted order:
           │       Bind.Function();
           │           ▼  这个 lambda 触达 RegisterObjectType /
           │              RegisterObjectMethod /
           │              RegisterGlobalFunction / RegisterEnum / ...
           ▼
       三层叠加（按 EOrder）：
         Layer A (Early ~ Normal):  原生类型 / 容器 / 数学结构
                                    手写：FVector / FString / TArray<T> / TMap<K,V> / 枚举骨架
         Layer B (Late-1 ~ Late):   UClass 反射类型Runtime-linked
                                    手写：AActor / UObject / UWorld / UActorComponent ...
                                    UHT 生成：AS_FunctionBinding_*.cpp（类成员 + 全局函数表）
         Layer C (Late+100):        Bind_Defaults
                                    遍历 BindDatabase 全部 UClass，依次：
                                      bHasDirectNativePointer == true → Runtime-linked
                                      bHasDirectNativePointer == false → 反射 fallback
                                      Late+150: 子系统 Get() 静态访问器

   GameThreadTLD->primaryContext = CreateContext()
   InitialCompile()                              ★ 此时 Bind 已全部完成
```

后续章节按"FBind 解剖 → EOrder 排序 → 全局队列实现 → CallBinds 在生命周期的位置 → 125 份 Bind_*.cpp 的分类 → 三层 fallback 模型 → 撰写约定 → 错误回流 → 与 Type_Core 和 Arch_UHTToolchain 的边界"的顺序展开。

---

## 一、`FBind`：被链接器推动的 static initializer

### 1.1 一行代码的全部含义

每个 `Bind_*.cpp` 的"主入口"都是文件作用域内一个**全局 const 对象**。下面这一行是 `Bind_FVector.cpp` 的真实写法：

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Binds/Bind_FVector.cpp
// 性质: 文件作用域全局变量。链接器把它放入 .data 段，
//       C++ 程序启动阶段构造，构造副作用是把 lambda 入队
// ============================================================================
AS_FORCE_LINK const FAngelscriptBinds::FBind Bind_FVector(FAngelscriptBinds::EOrder::Early, []
{
    FBindFlags Flags;
    Flags.bPOD = true;
    Flags.ExtraFlags |= asOBJ_BASICMATHTYPE;

    auto FVector_ = FAngelscriptBinds::ValueClass<FVector>("FVector", Flags);   // ★ 触发 RegisterObjectType
    FVector_.Constructor("void f(float64 X, float64 Y, float64 Z)", [](FVector* A, double X, double Y, double Z) {
        new(A) FVector(X, Y, Z);
    });
    FVector_.Property("float64 X", &FVector::X);
    FVector_.Method("FVector opAdd(const FVector& Other) const",
        METHODPR_TRIVIAL(FVector, FVector, operator+, (const FVector&) const));
    // ...
});
```

这一行做了三件事：

| 阶段 | 时机 | 行为 |
|------|------|------|
| 编译期 | 链接器解析 | `AS_FORCE_LINK` 在 GCC/Clang 展开为 `[[gnu::used, gnu::retain]]`；MSVC 上是空宏 + `AS_FORCE_LINK`-标记的对象在编译单元被 `AddInitializerToObjFile()` 拉住，避免 dead-strip |
| 进程加载 | DLL 载入 / 静态构造 | 全局对象 `Bind_FVector` 构造，调用 `FBind(EOrder::Early, lambda, __builtin_FILE())` 构造函数 |
| 构造副作用 | `RegisterBinds(name, order, fn)` | 把 `<BindName, BindOrder, lambda>` 三元组 `Add` 到全局 `TArray<FBindFunction>& BindArray` |

**lambda 体本身在此刻尚未执行**——它只是被存进了一个静态数组等待回放。AS 引擎此时甚至还不存在。

### 1.2 `FBind` 构造函数：为什么有 6 个重载

`AngelscriptBinds.h` 中 `FBind` 暴露 6 个重载，覆盖"是否提供 BindName"× "BindOrder 类型"两轴：

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Core/AngelscriptBinds.h
// 类型: FAngelscriptBinds::FBind
// ============================================================================
struct ANGELSCRIPTRUNTIME_API FBind
{
    FBind(FName BindName, int32 BindOrder, TFunction<void()> Function);
    FBind(FName BindName, EOrder BindOrder, TFunction<void()> Function);
    FBind(FName BindName,                  TFunction<void()> Function);  // BindOrder = 0
    FBind(int32 BindOrder, TFunction<void()> Function, const ANSICHAR* CallerFile = __builtin_FILE());
    FBind(EOrder BindOrder, TFunction<void()> Function, const ANSICHAR* CallerFile = __builtin_FILE());
    FBind(                  TFunction<void()> Function, const ANSICHAR* CallerFile = __builtin_FILE());
};
```

**关键设计**：未提供 `BindName` 的三个重载会用 `__builtin_FILE()` 推断 BindName（去路径只留文件名 stem）。这让 `Bind_FString.cpp` 顶部写 `FBind Bind_FString(EOrder::Early, []{...})` 时，`BindName` 自动得到 `FName("Bind_FString")`。这个 `BindName` 后续会被两个机制消费：

- `UAngelscriptSettings::DisabledBindNames`：开发者可以在 `.ini` 中按 stem 名禁用某条 bind
- `WITH_DEV_AUTOMATION_TESTS` 下的 `FAngelscriptBindExecutionObservation`：观测每条 bind 的执行情况

同名 stem 自动加 `#1` `#2` 后缀（见 `MakeBindNameFromCallerFile` 实现），所以 `Bind_FString.cpp` 同时拥有 `Bind_FString`（Early 阶段）和 `Bind_FString_Conversion`（Late+10 阶段）两条 bind 时不会冲突——但它们如果都不显式命名而依赖 stem 推断、且都来自同一个 .cpp，就会被加后缀。

### 1.3 `AS_FORCE_LINK`：为什么需要它

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Core/AngelscriptBinds.h
// 角色: 跨编译器的"防 dead-strip"标记
// ============================================================================
#ifndef AS_FORCE_LINK
#if defined(__GNUC__) || defined(__clang__)
#define AS_FORCE_LINK [[gnu::used, gnu::retain]]   // ★ 链接器即使发现没人引用也保留
#else
#define AS_FORCE_LINK                              // MSVC 下走 .uplugin 的 AdditionalCompilerArguments
#endif
#endif
```

没有这个标记，链接器在 LTO / `/OPT:REF` 等优化下会判定"这个全局对象没人 read，可以扔掉"——结果就是 lambda 永远不会进 `BindArray`，AS 引擎初始化时整套 `Bind_FVector` 像不存在一样，脚本里 `FVector(1,2,3)` 编译期报 `Type 'FVector' is not declared`。

MSVC 没有等价 attribute，`Plugins/Angelscript/Source/AngelscriptRuntime/AngelscriptRuntime.Build.cs` 用 `bRequiresAdditionalLinkerInput` / 全文件 `/INCLUDE` 拉住，效果相同。

---

## 二、`EOrder`：三阶段 + 自由偏移的优先级数轴

### 2.1 公开的三个枚举值

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Core/AngelscriptBinds.h
// 类型: FAngelscriptBinds::EOrder
// ============================================================================
enum class EOrder : int32
{
    Early  = -100,
    Normal = 0,
    Late   = 100,
};
```

整个枚举只有 3 个值。但实际 `Bind_*.cpp` 中频繁出现 `(int32)EOrder::Late + 100`、`(int32)EOrder::Early + 1`、`(int32)EOrder::Late - 1`、`(int32)EOrder::Late + 150`——**这是有意为之**：枚举只锚定三个"阶段中点"，之间的相对偏移完全靠 `int32` 算术表达。

### 2.2 实际取值分布（来自全仓 grep）

```text
EOrder::Early-2        — 极少（占位最早期）
EOrder::Early          — Bind_Primitives, Bind_FVector, Bind_FString, Bind_TArray, Bind_TSubclassOf_Declaration ...
EOrder::Early + 1      — Bind_FName（依赖 FString 已存在）
EOrder::Normal         — 默认隐式（很多没显式给 order 的）
EOrder::Late - 10      — Bind_TSubclassOf, Bind_TObjectPtr, Bind_TWeakObjectPtr 主体
EOrder::Late - 1       — Bind_AActor_Base, Bind_UObject_Base, Bind_UClass_Base, Bind_UFunction_Base, Bind_ConsoleVariables
EOrder::Late           — Bind_Delegates, Bind_FRotator_Interaction, Bind_Skip
EOrder::Late + 10      — Bind_FString_Conversion, Bind_FVector_Conversion, Bind_FRotator_Conversion
EOrder::Late + 100     — Bind_Defaults（★ Layer C 触发点：BlueprintCallable + 反射 fallback）
EOrder::Late + 150     — Bind_Subsystems（依赖所有 UClass 已绑定）
```

### 2.3 各阶段的语义解释

| 阶段范围 | 角色 | 不可越级原因 |
|---------|------|------------|
| `Early` ~ `Early+10` | **基础类型层**：`int` / `float` / `bool` / `FString` / `FName` / `FVector` / `FRotator` / `FTransform` 等数学结构、`TArray<T>` / `TMap<K,V>` / `TSet<T>` / `TOptional<T>` 容器骨架 | Layer B 与 Layer C 中所有方法签名都需要这些类型已在 AS 引擎中存在 |
| `Normal` | **手写工具方法 / FunctionLibrary mixin** | 通常依赖 Early 已就位，但还不依赖 UClass 反射类型 |
| `Late-10` | **智能指针族**：`TSubclassOf<T>` / `TObjectPtr<T>` / `TWeakObjectPtr<T>` 完整实现 | 这些模板需要 `BlueprintType_Declarations` (Early) 已经把对应 UClass 的"类型壳"声明好 |
| `Late-1` | **核心反射类型 base 方法**：`AActor` / `UObject` / `UClass` / `UFunction` 这一批"无可争议的 C++ 基类"的手写方法绑定 | 需要它们的 UClass 已在 Layer A 通过 `BlueprintType_Declarations` 调用 `BindUClass` 注册成 AS 引用类型 |
| `Late` | **委托与 enum 收尾、SkipBinds 黑名单写入** | 需要所有手写类型已就位以便建立委托回调签名 |
| `Late+10` | **跨类型转换运算符**（`FString` ↔ 各种数字/向量；`FVector` ↔ `FVector3f` 等） | 需要源、目标类型双方都已注册 |
| `Late+100` | **`Bind_Defaults` 总收口**：把 `FAngelscriptBindDatabase` 中所有 UClass 的 `Methods` / `Properties` 全部按"Runtime-linked → 反射兜底"两路批量注册 | 必须发生在所有手写 bind 完成之后，才能在反射阶段正确做"是否已存在等价签名"的去重 |
| `Late+150` | **跨类型批量发现**（如 `Bind_Subsystems` 用 `TObjectRange<UClass>` 给所有 `USubsystem` 子类追加 `Get()`） | 需要所有 UClass 名字已经在 AS 引擎中可查（AS_TypeRegistration 完成） |

### 2.4 `Bind_FName` 必须 `Early+1` 的具体理由

`FName` 提供了 `FName(const FString& Other)` 构造函数：

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Binds/Bind_FName.cpp
// 注册阶段: EOrder::Early + 1
// ============================================================================
FName_.Constructor("void f(const FString& Other)", [](FName* Address, const FString& Other) {
    new(Address) FName(*Other);
});
```

签名里出现 `const FString&`——AS 引擎在 `RegisterObjectBehaviour(asBEHAVE_CONSTRUCT, "void f(const FString& Other)", ...)` 这一刻必须能解析 `FString` 这个名字。如果 `Bind_FName` 与 `Bind_FString` 都标 `EOrder::Early`，排序后两者顺序未定义（`Sort` 在等值时不保证稳定）；为了**显式表达"我在 FString 之后"**，写成 `Early + 1` 是最简洁的解法。

---

## 三、全局注册队列：`BindArray` 与排序

### 3.1 队列实现：一个文件作用域 static `TArray`

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Core/AngelscriptBinds.cpp
// 角色: Bind 系统的"中央邮箱"
// ============================================================================
struct FBindFunction
{
    FName BindName;
    int32 BindOrder;
    TFunction<void()> Function;

    bool operator<(const FBindFunction& Other) const
    {
        return BindOrder < Other.BindOrder;
    }
};

static TArray<FBindFunction>& GetBindArray()
{
    static TArray<FBindFunction> BindArray;   // ★ Meyers' singleton, 进程级唯一
    return BindArray;
}
```

**关键性质**：

- 这是一个**进程级**全局——并不属于任何 `FAngelscriptEngine` 实例。换句话说，PIE 多 `FAngelscriptEngine` 共享同一份 BindArray
- 但 `FAngelscriptBindState`（`ClassFunctionBindings` / `RuntimeClassDB` / `SkipBinds` 等）是**引擎级**——每个 `FAngelscriptEngine` 实例独占一份
- 这种"注册队列共享、回放结果各自"的二分意味着同样的 lambda 在每个引擎的 `BindScriptTypes` 中都会被原样回放一次

### 3.2 注册函数的两个入口

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Core/AngelscriptBinds.cpp
// 函数: RegisterBinds（两个重载）
// ============================================================================
void FAngelscriptBinds::RegisterBinds(FName BindName, int32 BindOrder, TFunction<void()> Function)
{
    GetBindArray().Add({
        BindName.IsNone() ? MakeUnnamedBindName() : BindName,
        BindOrder,
        MoveTemp(Function)
    });
}

void FAngelscriptBinds::RegisterBinds(int32 BindOrder, TFunction<void()> Function, const ANSICHAR* CallerFile)
{
    GetBindArray().Add({
        MakeBindNameFromCallerFile(CallerFile),    // ★ 从 __builtin_FILE() 推 stem
        BindOrder,
        MoveTemp(Function)
    });
}
```

`MakeBindNameFromCallerFile` 的 stem 推断算法（同名递增）：

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Core/AngelscriptBinds.cpp
// 函数: MakeBindNameFromCallerFile
// 性质: 静态局部 TMap 维护"已见过的 stem -> 计数"
// ============================================================================
static FName MakeBindNameFromCallerFile(const ANSICHAR* CallerFile)
{
    if (CallerFile == nullptr || *CallerFile == '\0')
        return MakeUnnamedBindName();

    const FString FullPath = ANSI_TO_TCHAR(CallerFile);
    const FString Stem = FPaths::GetBaseFilename(FullPath);   // "Bind_FString"
    if (Stem.IsEmpty())
        return MakeUnnamedBindName();

    static TMap<FName, int32> StemDuplicateCounter;
    const FName StemName(*Stem);
    int32& Count = StemDuplicateCounter.FindOrAdd(StemName);
    if (Count == 0) { ++Count; return StemName; }            // 第一份原名
    const FName UniqueName(*FString::Printf(TEXT("%s#%d"), *Stem, Count));
    ++Count;
    return UniqueName;                                        // "Bind_FString#1"
}
```

### 3.3 排序：每次 `CallBinds` 都重排一次

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Core/AngelscriptBinds.cpp
// 函数: GetSortedBindArray
// ============================================================================
static TArray<FBindFunction> GetSortedBindArray()
{
    TArray<FBindFunction> SortedBinds = GetBindArray();   // ★ 拷贝一份再排序
    SortedBinds.Sort();                                   // 用 operator< 按 BindOrder
    return SortedBinds;
}
```

返回拷贝而不是直接对原数组 `Sort` 是有意的：

- 注册阶段（链接器 + DLL 加载）只关心"加进队列"，不在乎顺序
- `CallBinds` 阶段才需要稳定有序——但每个引擎实例都要按同一份顺序回放，所以排序结果不能持久写回原数组（虽然结果应当一致，但避免共享状态被并发修改）
- `GetBindInfoList` / `GetAllRegisteredBindNames` 这些查询接口也用 `GetSortedBindArray`，结果对外稳定

**排序稳定性**：`TArray::Sort` 不是稳定排序——如果两个 bind 的 `BindOrder` 完全相同，相对顺序未定义。这就是为什么 `Bind_FName` 显式 `Early+1` 而不是 `Early`：如果两者都 `Early`，相对顺序由链接器决定，跨平台不可预测。

---

## 四、`CallBinds`：在生命周期的哪一刻、从哪个调用点

### 4.1 唯一调用点：`FAngelscriptEngine::BindScriptTypes`

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Core/AngelscriptEngine.cpp
// 函数: FAngelscriptEngine::BindScriptTypes
// 性质: Bind 系统对外的唯一回放入口；被 Initialize_AnyThread / InitializeWithoutInitialCompile 调用
// ============================================================================
void FAngelscriptEngine::BindScriptTypes()
{
    AS_PERF_SCOPE_STARTUP_BIND_SCRIPT_TYPES();
    LLM_SCOPE_BYTAG(Angelscript);
    MALLOCLEAK_SCOPED_CONTEXT(TEXT("Angelscript/BindScriptTypes"));

    #if WITH_DEV_AUTOMATION_TESTS
    FAngelscriptBindExecutionObservation::BeginBindScriptTypesTiming();
    FAngelscriptEnumTableBaselineProbe::Reset();
    #endif

    FAngelscriptBinds::CallBinds(CollectDisabledBindNames());        // ★ 回放全部 lambda

    #if WITH_DEV_AUTOMATION_TESTS
    FAngelscriptBindExecutionObservation::EndBindScriptTypesTiming();
    FAngelscriptEnumTableBaselineProbe::MaybeAutoDump();
    #endif
}
```

`CollectDisabledBindNames()` 把 `UAngelscriptSettings::DisabledBindNames` 与 `RuntimeConfig.DisabledBindNames` 合成一个 `TSet<FName>`，传给 `CallBinds` 跳过对应 lambda。

### 4.2 `CallBinds` 主回放循环

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Core/AngelscriptBinds.cpp
// 函数: FAngelscriptBinds::CallBinds
// ============================================================================
void FAngelscriptBinds::CallBinds(const TSet<FName>& DisabledBindNames)
{
    AS_PERF_SCOPE_BINDS_CALL_BINDS();
    LLM_SCOPE_BYTAG(Angelscript);
    MALLOCLEAK_SCOPED_CONTEXT(TEXT("Angelscript/CallBinds"));

    #if WITH_DEV_AUTOMATION_TESTS
    FAngelscriptBindExecutionObservation::BeginObservationPass(DisabledBindNames);
    #endif

    for (const FBindFunction& Bind : GetSortedBindArray())          // ★ 排序拷贝
    {
        if (DisabledBindNames.Contains(Bind.BindName))
        {
            UE_LOG(Angelscript, Log, TEXT("Skipping bind '%s'"), *Bind.BindName.ToString());
            continue;
        }

        #if MALLOC_LEAKDETECTION
        const FString BindLeakContext = FString::Printf(TEXT("Angelscript/Bind/%s"), *Bind.BindName.ToString());
        MALLOCLEAK_SCOPED_CONTEXT(*BindLeakContext);
        #endif

        #if WITH_DEV_AUTOMATION_TESTS
        FAngelscriptBindExecutionObservation::RecordExecutedBind(Bind.BindName);
        {
            FAngelscriptEnumTableBaselineBindScope BindScope(Bind.BindName, Bind.BindOrder);
            Bind.Function();                                         // ★ 回放 lambda
        }
        #else
        Bind.Function();                                             // ★ 回放 lambda
        #endif
    }

    #if WITH_DEV_AUTOMATION_TESTS
    FAngelscriptBindExecutionObservation::EndObservationPass();
    #endif
}
```

每条 lambda 执行时，里面的 `FAngelscriptBinds::ValueClass(...)` / `.Method(...)` / `.Property(...)` 会即时调用 `FAngelscriptEngine::Get().Engine->RegisterObjectType(...)` 等 AS 内核 API——**也就是说 AS 引擎此刻必须已经 `asCreateScriptEngine` 完成**。

### 4.3 在 `Initialize_AnyThread` 中的位置

```text
FAngelscriptEngine::Initialize
   │
   ├─ PreInitialize_GameThread()
   │     ├─ Engine = asCreateScriptEngine()              ← AS 引擎对象创建
   │     └─ ...
   │
   ├─ Initialize_AnyThread()  (可能在工作线程)
   │     ├─ Engine->SetEngineProperty(...)               ← 引擎属性配置
   │     ├─ AllRootPaths = DiscoverScriptRoots(...)      ← 发现 ScriptRoot 路径
   │     ├─ FAngelscriptBindDatabase::Get().Load(...)    ← cooked 时反序列化
   │     ├─ FModuleManager::LoadModule(BindModules)      ← 加载手动声明的 Bind Modules
   │     ├─ TypeDatabase / BindState / ToStringList /
   │     │  BindDatabase / BlueprintEventSignatureRegistry MakeUnique
   │     ├─ BindScriptTypes()                            ← ★ 本文焦点：CallBinds 在这里
   │     ├─ ReserveStaticNames(7000)
   │     ├─ GameThreadTLD->primaryContext = CreateContext()
   │     ├─ InitialCompile()                              ← .as 文件预处理 → 编译 → ClassGenerator
   │     └─ ...
   │
   └─ PostInitialize_GameThread()
         └─ FAngelscriptEngineExtensionRegistry::Get().AttachEngine(*this)
```

**两条关键时序线**：

1. **`BindScriptTypes` 在 `InitialCompile` 之前** —— 这意味着 `.as` 编译期看到的 AS 引擎已经是完整类型表。`Bind_*.cpp` 没有"延迟绑定"概念，错过了 `CallBinds` 这一刻就再也没有第二次机会
2. **`AllRootPaths` 在 `BindScriptTypes` 之前发现** —— 但只是路径列表，`.as` 文件文本此时还没读。这与"`Bind_BlueprintType_Declarations` 在 Early 阶段读 `FAngelscriptBindDatabase` 给 UClass 注册类型壳"是相容的：BindDatabase 早于 `BindScriptTypes` 通过 `Load(Binds.Cache)` 就位

### 4.4 `ResetBindState`：重启而非重注册

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Core/AngelscriptBinds.cpp
// 函数: FAngelscriptBinds::ResetBindState
// ============================================================================
void FAngelscriptBinds::ResetBindState()
{
    GetBindState() = FAngelscriptBindState();   // ★ 整片置空，但 BindArray 不动
}
```

注意这里清空的是**引擎级** `FAngelscriptBindState`（即 `ClassFunctionBindings` / `SkipBinds` 等），**不是** `BindArray`。换句话说，引擎销毁重建时——

- 进程级 `BindArray`：保持原样，不变
- 引擎级 `BindState`：归零
- AS 引擎：重新 `asCreateScriptEngine`
- `CallBinds`：再回放一次 BindArray，注册到新的 AS 引擎

这就是为什么 PIE / 测试隔离场景下能反复 init/destroy 引擎——只要 `BindArray` 是稳定的，每次 `CallBinds` 的结果都应该一致。

---

## 五、125 份 `Bind_*.cpp`：分类与代表样本

### 5.1 实际数量：125（仓库统计）

`Plugins/Angelscript/Source/AngelscriptRuntime/Binds/` 下 `*.cpp` 文件 **125 份**（不含 `.h` 与 `BlueprintCallableReflectiveFallback.cpp` / `BlueprintEventSignatureRegistry.cpp` 这些"辅助实现"型 .cpp，但口语上"125 份 Bind_*.cpp"是包含全部主入口的）。`AGENTS.md` 中提到的"121 份"是写入文档时的快照。本文以 125 为准。

### 5.2 按职责分类

| 类别 | 代表文件 | 数量级 | 阶段倾向 | 注册接口 |
|------|---------|--------|----------|----------|
| **基础类型** | `Bind_Primitives.cpp` (int/float/bool/uint8...)、`Bind_FString.cpp`、`Bind_FName.cpp`、`Bind_FText.cpp` | 4–6 | `Early` | `FAngelscriptType::Register` + `ValueClass` |
| **数学结构** | `Bind_FVector.cpp`、`Bind_FRotator.cpp`、`Bind_FTransform.cpp`、`Bind_FQuat.cpp`、`Bind_FMatrix.cpp`（实际是各 Hit/Box/Sphere/Plane/Color/LinearColor/Guid/Date/Time/IntPoint/IntVector 等） | 30+ | `Early` 主体 + `Late+10` 跨类型转换 | `ValueClass<T>` + `Constructor/Method/Property` |
| **容器模板** | `Bind_TArray.cpp`、`Bind_TMap.cpp`、`Bind_TSet.cpp`、`Bind_TOptional.cpp` | 4 | `Early` | `ValueClass<FScriptArray>` + `bTemplate=true` |
| **智能指针** | `Bind_TSubclassOf.h/cpp`（实际在 `Bind_BlueprintType.cpp`）、`Bind_TWeakObjectPtr`、`Bind_TObjectPtr`（同上）、`Bind_TSoftObjectPtr.cpp` | 4 | `Early` 声明壳 + `Late-10` 实现 | `ReferenceClass` + 命名约定 `T@` 句柄 |
| **UClass 反射类型骨架** | `Bind_UObject.cpp`、`Bind_UClass`（同上）、`Bind_AActor.cpp`、`Bind_USceneComponent.cpp`、`Bind_UActorComponent.cpp`、`Bind_APlayerController.cpp` | 4–8 | `Late-1` | `ExistingClass(...)` + `.Method(METHOD_TRIVIAL(...))` |
| **GAS / 输入 / 物理 / Net 等专题** | `Bind_FHitResult.cpp`、`Bind_FCollisionShape.cpp`、`Bind_UEnhancedInputComponent.cpp`、`Bind_UInputMappingContext.cpp` | 数十 | `Late-1` ~ `Late` | 同上 |
| **全局函数库** | `Bind_FMath.cpp`、`Bind_FPaths.cpp`、`Bind_FApp.cpp`、`Bind_FPlatformMisc.cpp`、`Bind_FCommandLine.cpp` | 10+ | `Normal` ~ `Late` | `FNamespace ns(...)` + `BindGlobalFunction` |
| **委托与多播** | `Bind_Delegates.cpp`（声明与展开）、`Bind_FAngelscriptDelegateWithPayload.cpp` | 2 | `Early`（声明）+ `Late`（实现） | `BindGlobalGenericFunction` + `Helper_FunctionSignature` |
| **mixin 函数库** | `Bind_FunctionLibraryMixins.cpp`、`Bind_AssetManagerScriptMixins.cpp`、`Bind_InputComponentScriptMixins.cpp` | 3–5 | `Late+10` | `Method(name, lambda)` 把全局函数变成成员调用 |
| **批量发现型** | `Bind_Subsystems.cpp`、`Bind_BlueprintType.cpp` (`Bind_Defaults`) | 2 | `Late+100` ~ `Late+150` | `TObjectRange<UClass>` 遍历 + `BindUClass` / `BindBlueprintCallable` |
| **黑名单 / 配置** | `AngelscriptSkipBinds.cpp`（在 `Core/`，不在 `Binds/`）、`Bind_Deprecations.cpp`、`Bind_ConfigEnums.cpp` | 3 | `Late` | `AddSkipEntry` / `AddSkipClass` |
| **预处理友好辅助** | `Bind_BlueprintTypePrep.h`（无 cpp 主入口）、`Bind_Helpers.h` | n/a | n/a | 仅头文件辅助 |

### 5.3 三种主要 ValueClass / ReferenceClass / ExistingClass 用法

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Core/AngelscriptBinds.h / .cpp
// 函数: FAngelscriptBinds::ValueClass / ReferenceClass / ExistingClass
// ============================================================================
template<typename T>
static FAngelscriptBinds ValueClass(FBindString Name, FBindFlags Flags)   // ★ FVector/FString/FRotator/...
{
    if (Flags.Alignment == -1) Flags.Alignment = alignof(T);
    Flags.ExtraFlags |= asGetTypeTraits<T>();
    return ValueClass(Name, Flags, sizeof(T));
}

static FAngelscriptBinds ReferenceClass(FBindString Name, UClass* UnrealClass)  // ★ AActor/UObject/...
{
    auto Binds = FAngelscriptBinds(Name, asOBJ_REF | asOBJ_NOCOUNT | asOBJ_IMPLICIT_HANDLE, 0);
    ((asCObjectType*)Binds.ScriptType)->size = UnrealClass->GetStructureSize();
    Binds.ScriptType->alignment = UnrealClass->GetMinAlignment();
    return Binds;
}

static FAngelscriptBinds ExistingClass(FBindString Name)                         // ★ Bind_AActor_Base 之类的"补充"
{
    return FAngelscriptBinds(Name);   // ScriptType 留空，方法注册时按名字反查
}
```

**典型搭配**：

- `ReferenceClass` 在 `BindUClass` 内被调用（位于 `Bind_BlueprintType.cpp`），把一个 `UClass*` 注册成 AS 引用类型。这一步在 `Late-1` 之前完成
- `ExistingClass` 用于 `Bind_AActor_Base` / `Bind_UObject_Base` 这种"我只是给一个已经被 `BindUClass` 注册过的 AS 类型补充手写方法"——避免重复注册类型本身，只追加 method/property
- `ValueClass<T>` 用于 POD 数学结构和容器模板——AS 内核会按 `sizeof(T)` 与 `asGetTypeTraits<T>()` 推出的 trait 决定值语义、CDAK 等

### 5.4 `Bind_AActor_Base`：`ExistingClass` 范式

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Binds/Bind_AActor.cpp
// 注册阶段: EOrder::Late - 1
// ============================================================================
AS_FORCE_LINK const FAngelscriptBinds::FBind Bind_AActor_Base((int32)FAngelscriptBinds::EOrder::Late - 1, []
{
    auto AActor_ = FAngelscriptBinds::ExistingClass("AActor");    // ★ 不重复 RegisterObjectType

    AActor_.Method("bool IsActorInitialized() const", METHOD_TRIVIAL(AActor, IsActorInitialized));
    AActor_.Method("bool HasActorBegunPlay() const", METHOD_TRIVIAL(AActor, HasActorBegunPlay));
    AActor_.Method("FVector GetActorLocation() const", METHOD_TRIVIAL(AActor, GetActorLocation));
    AActor_.Method("FRotator GetActorRotation() const", METHOD_TRIVIAL(AActor, GetActorRotation));
    AActor_.Method("FString GetActorNameOrLabel() const", METHOD_TRIVIAL(AActor, GetActorNameOrLabel));
    AActor_.Method("UGameInstance GetGameInstance() const",
        METHODPR_TRIVIAL(UGameInstance*, AActor, GetGameInstance, () const));

    AActor_.Method("void GetComponentsByClass(?& OutComponents) const",
        [](const AActor* Actor, TArray<UActorComponent*>& OutComponents, int TypeId) {
            // ... 使用 ?& 模板技巧让脚本侧写 TArray<UFooComponent>，C++ 端从 TypeId 反查 UClass
        });
    // ...
});
```

`ExistingClass("AActor")` 之所以能找到这个类型，是因为 `Bind_BlueprintType_Declarations`（`EOrder::Early`）已经先一步遍历 `FAngelscriptBindDatabase::Get().Classes` 并对每个 UClass 调用 `BindUClass(Class, TypeName)`——`AActor` 的"AS 引用类型壳"在 Early 阶段就已注册。

### 5.5 `Bind_TArray`：模板类的 `bTemplate=true`

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Binds/Bind_TArray.cpp
// 注册阶段: EOrder::Early
// ============================================================================
AS_FORCE_LINK const FAngelscriptBinds::FBind Bind_TArray(FAngelscriptBinds::EOrder::Early, []
{
    FBindFlags Flags;
    Flags.bTemplate = true;
    Flags.TemplateType = "<T>";                                   // ★ 模板参数命名
    Flags.ExtraFlags = asOBJ_TEMPLATE_SUBTYPE_COVARIANT;

    auto TArray_ = FAngelscriptBinds::ValueClass<FScriptArray>("TArray<class T>", Flags);
    TArray_.Constructor("void f()", FUNC_TRIVIAL(FArrayOperations::Construct));
    FAngelscriptType::SetArrayTemplateTypeInfo(TArray_.GetTypeInfo());
    FAngelscriptEngine::Get().Engine->RegisterDefaultArrayType("TArray<T>");

    TArray_.TemplateCallback("bool f(int&in Type, int&out ErrorMessage)",
        [](asITypeInfo* TemplateType, asCString* ErrorMessage) -> bool {
            // 决定哪些 T 是合法的模板参数（拒绝不可拷贝类型等）
            return ValidateArrayOperations(TemplateType, ErrorMessage) != nullptr;
        });

    TArray_.Method("T& opIndex(int __any_implicit_integer Index)", &FArrayOperations::OpIndex);
    TArray_.Method("void Add(const T&in if_handle_then_const Value)", &FArrayOperations::Add);
    // ...
});
```

`FScriptArray` 是 UE 提供的"泛型数组容器"——AS 侧的 `TArray<T>` 不为每个 T 复制一份内存布局，而是统一走 `FScriptArray` + 一份 `FArrayOperations` 元数据描述元素如何构造/析构/拷贝。`TemplateCallback` 注册的 lambda 在每次 AS 编译期遇到具体 `TArray<FFoo>` 时被调用一次，决定是否允许该实例化。

---

## 六、三层 fallback 模型：UHT / 手写 / 反射

### 6.1 三层概念图

```text
================================================================================
  对一个 UClass 的方法绑定，三条独立但叠加的注册路径
================================================================================

┌─ Layer A：UHT 自动绑定（构建期生成的 AS_FunctionBinding_*.cpp）─────────────┐
│                                                                             │
│ Plugins/Angelscript/Intermediate/Build/.../UHT/AS_FunctionBinding_Engine.gen.cpp│
│ ────────────────────────────────────────────────────────────────────────── │
│ AS_FORCE_LINK const FAngelscriptBinds::FBind                                │
│ Bind_AS_FunctionBinding_Engine(TEXT("UHT.FunctionBinding.Engine"),           │
│     (int32)EOrder::Late + 50, []                                               │
│ {                                                                            │
│     RegisterFunctionBinding(AActor::StaticClass(), "K2_DestroyActor",              │
│         FAngelscriptFunctionBinding{ &AActor::execK2_DestroyActor,                           │
│                     ASAutoCaller::MakeFunctionCaller(...) });               │
│     RegisterFunctionBinding(AActor::StaticClass(), "SetActorLocation",             │
│         FAngelscriptFunctionBinding{ &AActor::execSetActorLocation, ... });                  │
│     // ... 数千条 ERASE_AUTO_*_PTR 宏展开                                    │
│ });                                                                          │
│                                                                             │
│ ★ 注意：这一步只是"灌库"——把 UFunction → 直接函数指针的映射存到             │
│   FAngelscriptBinds::ClassFunctionBindings[UClass*][FuncName]。                     │
│   它本身不调用 AS 引擎的 RegisterObjectMethod！                              │
└──────────────────────────────────────────────────────────────────────────────┘
                                   │
                                   │ 构建期"灌库"完成
                                   │
┌─ Layer B：手写 Bind_*.cpp Runtime-linked（如 Bind_AActor_Base）─────────────────────┐
│                                                                             │
│ AS_FORCE_LINK const FBind Bind_AActor_Base(EOrder::Late - 1, []             │
│ {                                                                            │
│     auto AActor_ = ExistingClass("AActor");                                 │
│     AActor_.Method("FVector GetActorLocation() const",                      │
│         METHOD_TRIVIAL(AActor, GetActorLocation));   // ★ 直接调 AS 引擎    │
│ });                                                                          │
│                                                                             │
│ ★ 手写的方法直接触达 RegisterObjectMethod，不走 ClassFunctionBindings。              │
│ ★ 优势：可以写脚本特化的签名（含 ?& 模板、lambda、自定义参数转换）。         │
│ ★ 代价：每条都要手写。仅用于"无可争议必须手写"的 4–8 个核心 UClass。         │
└──────────────────────────────────────────────────────────────────────────────┘
                                   │
                                   │ 等手写Runtime-linked全部完成
                                   ▼
┌─ Layer C：Bind_Defaults 收口（EOrder::Late + 100）─────────────────────────┐
│                                                                             │
│ AS_FORCE_LINK const FBind Bind_Defaults((int32)EOrder::Late + 100, []       │
│ {                                                                            │
│     for (auto& DBBind : FAngelscriptBindDatabase::Get().Classes)            │
│     {                                                                       │
│         UClass* Class = DBBind.ResolvedClass;                               │
│         auto ClassType = FAngelscriptType::GetByClass(Class);               │
│         for (auto& DBFunc : DBBind.Methods)                                 │
│         {                                                                   │
│             UFunction* Function = Class->FindFunctionByName(*DBFunc.UnrealPath);
│             if (Function->HasAnyFunctionFlags(FUNC_BlueprintEvent | FUNC_NetFuncFlags))
│                 BindBlueprintEvent(ClassType.ToSharedRef(), Function, DBFunc);
│             else                                                             │
│                 BindBlueprintCallable(ClassType.ToSharedRef(), Function, DBFunc);
│         }                                                                   │
│     }                                                                       │
│ });                                                                          │
│                                                                             │
│ BindBlueprintCallable(...)                                                  │
│   ├─ Map = ClassFunctionBindings.Find(OwningClass);                                 │
│   ├─ Entry = Map->Find(Function->GetFName().ToString());                    │
│   ├─ if (Entry == nullptr) return;       ← 没在 UHT 表里登记，跳过           │
│   ├─ if (Entry->FuncPtr.IsBound())                                          │
│   │     → Runtime-linked路径：BindMethodDirect(ASFuncPtr=拷贝自 Entry->FuncPtr,       │
│   │                                  asCALL_THISCALL, Entry->Caller);       │
│   ├─ else                                                                   │
│   │     → 反射兜底：BindBlueprintCallableReflectionFallback(                 │
│   │                  Type, Function, Signature, *Entry);                    │
│   │       构造 FBlueprintCallableReflectiveSignature，注册                  │
│   │       generic 函数走 UFunction::Invoke + FFrame                         │
│   └─ Signature.WriteToDB(DBBind);                                           │
└──────────────────────────────────────────────────────────────────────────────┘
```

### 6.2 三层叠加规则与冲突优先级

| 路径 | 注册早晚 | 优先级（同名时） | 备注 |
|------|---------|----------------|------|
| Layer B（手写Runtime-linked） | `Late-1` 阶段最先到达 AS 引擎 | **优先**：手写Runtime-linked早于 Layer C，AS 引擎层面 `RegisterObjectMethod` 已经写入 | `Bind_AActor_Base.GetActorLocation` 即使 UHT 表里也有 `GetActorLocation`，Layer C 检测到"已存在等价签名"会 skip |
| Layer A（UHT 灌库） | `Late+50` 阶段把 ClassFunctionBindings 填好 | 不直接竞争 | 它只是给 Layer C 提供"有没有直接函数指针"的元数据 |
| Layer C Runtime-linked路径 | `Late+100` | 在 Layer B 之后 | `IsEquivalentScriptSignatureAlreadyBound` 守卫去重 |
| Layer C 反射兜底 | `Late+100` | 仅当 `Entry->FuncPtr.IsBound() == false` 时启用 | 通过 `EvaluateReflectionFallback` 二次过滤（拒绝 `CLASS_Interface` / `CustomThunk` / `> 16 args`） |

### 6.3 反射 fallback 的过滤条件

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Binds/BlueprintCallableReflectiveFallback.cpp
// 函数: EvaluateReflectionFallback
// ============================================================================
EReflectionFallbackResult EvaluateReflectionFallback(const UFunction* Function)
{
    if (Function == nullptr)                                  return NullFunction;
    const UClass* OwningClass = Function->GetOuterUClass();
    if (OwningClass == nullptr)                               return MissingOwningClass;
    if (OwningClass->HasAnyClassFlags(CLASS_Interface))       return InterfaceClass;
    if (Function->HasMetaData(NAME_BlueprintCallableReflectiveFallback_CustomThunk))
                                                              return CustomThunk;
    if (GetNonReturnParameterCount(Function) > BlueprintCallableReflectiveFallbackMaxArgs /* 16 */)
                                                              return TooManyArguments;
    return Success;
}
```

实战意义：UFunction 即使没有直接函数指针、Layer C 也会**至少尝试**给它一个"反射 trampoline"——只要它不是 interface、不是 CustomThunk、参数数量 ≤ 16。这就是为什么蓝图新增的某个 `UFUNCTION(BlueprintCallable)` 通常不需要重新构建 UHT 表也能在 AS 里调用：**反射 fallback 兜住了"UHT 漏网之鱼"**。

但这条兜底走 `UFunction::Invoke` + `FFrame`，性能比Runtime-linked慢约 3–6 倍（典型签名）。所以 UHT 灌库的目标是把热点函数搬到 Layer A，让 Layer C 走"Runtime-linked路径"。

### 6.4 `ShouldSkipBlueprintCallableFunction`：黑名单守卫

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Core/AngelscriptBinds.cpp
// 函数: FAngelscriptBinds::ShouldSkipBlueprintCallableFunction
// ============================================================================
bool FAngelscriptBinds::ShouldSkipBlueprintCallableFunction(const UFunction* Function)
{
    if (Function == nullptr)                                       return true;
    if (!Function->HasAnyFunctionFlags(FUNC_Native))               return true;   // ★ 必须是 native UFunction
    if (Function->HasMetaData("NotInAngelscript"))                 return true;
    if (Function->HasMetaData("BlueprintInternalUseOnly")
        && !Function->HasMetaData("UsableInAngelscript"))          return true;
    if (const UClass* OwningClass = Function->GetOuterUClass())
    {
        if (OwningClass == UActorComponent::StaticClass()
            && Function->GetFName() == "GetOwner")                  return true;   // 与手写 Bind_UActorComponent 冲突
    }
    return false;
}
```

四道闸：必须是 native UFunction、没有 `NotInAngelscript`、没有"BlueprintInternalUseOnly 但缺 UsableInAngelscript"、不是 `UActorComponent::GetOwner`（手写已绑）。

`AngelscriptSkipBinds.cpp` 提供的另一条黑名单走 `AddSkipEntry(ClassName, FunctionName)` 与 `AddSkipClass(ClassName)`，用于排除"硬注册有问题"的 9 条特例：

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Core/AngelscriptSkipBinds.cpp
// 注册阶段: EOrder::Late
// ============================================================================
AS_FORCE_LINK const FAngelscriptBinds::FBind Bind_Skip((int32)FAngelscriptBinds::EOrder::Late, []()
{
    FAngelscriptBinds::AddSkipEntry("StaticMesh",   "GetMinLODForQualityLevels");
    FAngelscriptBinds::AddSkipEntry("StaticMesh",   "SetMinLODForQualityLevels");
    FAngelscriptBinds::AddSkipEntry("SkeletalMesh", "GetMinLODForQualityLevels");
    FAngelscriptBinds::AddSkipClass("ClothingSimulationInteractorNv");
    FAngelscriptBinds::AddSkipClass("NiagaraPreviewGrid");
    // ...
});
```

---

## 七、撰写约定与命名规则

### 7.1 文件命名

新增 `Bind_<TypeName>.cpp` 时遵循以下习惯：

| 形式 | 用途 | 例 |
|------|------|----|
| `Bind_F<StructName>.cpp` | 一个 USTRUCT / 数学结构 / POD 类型一份 | `Bind_FVector.cpp`、`Bind_FHitResult.cpp` |
| `Bind_T<Template>.cpp` | 模板容器 / 智能指针 | `Bind_TArray.cpp`、`Bind_TSoftObjectPtr.cpp` |
| `Bind_U<ClassName>.cpp` / `Bind_A<ActorClass>.cpp` | UCLASS 反射类型一份 | `Bind_UObject.cpp`、`Bind_AActor.cpp`、`Bind_USceneComponent.cpp` |
| `Bind_<ConceptCluster>.cpp` | 跨类型主题集合 | `Bind_Subsystems.cpp`、`Bind_Delegates.cpp`、`Bind_Logging.cpp` |
| `Bind_<Category>Mixins.cpp` | mixin 函数库 | `Bind_FunctionLibraryMixins.cpp`、`Bind_AssetManagerScriptMixins.cpp` |

### 7.2 include 顺序惯例

```cpp
// ============================================================================
// 文件: 推荐 Bind_*.cpp include 模板
// ============================================================================

// 1. 业务 UE 类型头（被绑类型的定义）
#include "Engine/Engine.h"
#include "GameFramework/Actor.h"
#include "Containers/UnrealString.h"

// 2. AS 框架公开头
#include "AngelscriptBinds.h"
#include "AngelscriptEngine.h"
#include "AngelscriptType.h"
#include "AngelscriptDocs.h"

// 3. 本目录内 Helper / 兄弟头
#include "Helper_AngelscriptArguments.h"
#include "Helper_ToString.h"
#include "Binds/Bind_Helpers.h"

// 4. AS 内核私有头（必须用 Start/End 包夹）
#include "StartAngelscriptHeaders.h"
#include "source/as_scriptengine.h"
#include "source/as_objecttype.h"
#include "EndAngelscriptHeaders.h"
```

`StartAngelscriptHeaders.h` / `EndAngelscriptHeaders.h` 临时切换若干警告 + 关 LLM 推断，避免 AS 内核里大量 C 风格转换污染 UE 编译。

### 7.3 注册片段习惯

- **POD 数学结构**：`FBindFlags Flags; Flags.bPOD = true; Flags.ExtraFlags |= asOBJ_BASICMATHTYPE;`
- **模板容器**：`Flags.bTemplate = true; Flags.TemplateType = "<T>";`
- **构造函数注册**后立刻跟一条 `FAngelscriptBinds::SetPreviousBindNoDiscard(true)` 让 `FVector(1,2,3);` 这种丢弃返回值的写法被警告
- **触发 JIT 友好**：`METHOD_TRIVIAL` 与 `FUNC_TRIVIAL` 比 `METHOD` / `FUNC` 多一个 `bTrivial=true` 标记，告诉 StaticJIT "这条调用可以原地内联"
- **运算符**统一走 `opAdd` / `opSub` / `opMul` / `opDiv` / `opEquals` / `opAssign` / `opNeg` / `opIndex` / `opMulAssign` 等 AngelScript 标准运算符名

### 7.4 一条 Bind 的"完整一行"

```cpp
FVector_.Method("FVector opAdd(const FVector& Other) const",
    METHODPR_TRIVIAL(FVector, FVector, operator+, (const FVector&) const));
```

逐项含义：

| 片段 | 含义 |
|------|------|
| `"FVector opAdd(const FVector& Other) const"` | AS 侧签名字符串。返回类型、方法名、参数表、`const` 限定都按 AS 文法书写 |
| `METHODPR_TRIVIAL` | 4-arg 宏：`(返回类型, 类名, 方法名, 参数列表)`，处理函数重载（PR = Pointer-Resolved），自动展开成 `((Ret(Cls::*)Args)&Cls::Name), #Cls, #Name, true` |
| 自动 ASAutoCaller | 由 `Method` 模板推导出 `FunctionCaller`，详见 `Type_FunctionCaller.md` |

---

## 八、错误回流：`CallBinds` 阶段的失败如何被诊断

### 8.1 失败模式分类

`CallBinds` 阶段的 lambda 体里调用 AS 内核 `RegisterObjectType` / `RegisterObjectMethod` 失败时，AS 内核默认行为是：

- 返回负数错误码（`asERROR` / `asNAME_TAKEN` / `asINVALID_DECLARATION` / ...）
- 同时通过 `LogAngelscriptError`（在 `Initialize_AnyThread` 阶段被 `Engine->SetMessageCallback` 注册）输出到 `LogAngelscript`

### 8.2 `LogAngelscriptError` 是诊断主通道

```text
================================================================================
失败链路：
  Bind_Foo lambda 内部 → AS 内核 RegisterObjectMethod → 失败码 < 0
       │                                                  │
       │                                                  ▼
       │                                            asEngineMessageCallback
       │                                            （在 Initialize_AnyThread
       │                                            注册的 LogAngelscriptError）
       │                                                  │
       │                                                  ▼
       │                                            UE_LOG(Angelscript, Error/Warning, ...)
       │                                                  │
       │ lambda 继续执行（不会 throw）                       │
       │                                                  │
       ▼                                                  ▼
   下一次 .Method(...) / 下一条 bind                  Arch_ErrorDiagnostics §三
```

也就是说**注册失败不会中断 `CallBinds`**——它会继续到下一条。这是有意设计：避免一条 bind 失败拖死整个引擎初始化。代价是失败可能在很久之后（脚本 `.as` 编译期 `Type 'Foo' is not declared`）才显形。

### 8.3 `MALLOC_LEAKDETECTION` 与 `BindLeakContext`

```cpp
#if MALLOC_LEAKDETECTION
const FString BindLeakContext = FString::Printf(TEXT("Angelscript/Bind/%s"), *Bind.BindName.ToString());
MALLOCLEAK_SCOPED_CONTEXT(*BindLeakContext);
#endif
```

每条 bind 的内存分配被 tag 到 `Angelscript/Bind/<BindName>`——内存泄漏报告可以精确定位到"哪一条 bind 泄漏了多少字节"。

### 8.4 `FAngelscriptBindExecutionObservation`（仅 `WITH_DEV_AUTOMATION_TESTS`）

观测层有一对 `BeginObservationPass` / `EndObservationPass`，记录哪些 bind 真正被执行（用于"测试 disabledBindNames 配置是否生效"这类自动化场景）。本文不展开，详见 `Documents/Knowledges/ZH/Test_RuntimeInternal.md`（待写）。

---

## 九、与 `Type_Core` / `Arch_UHTToolchain` 的边界

### 9.1 与 Type_Core 的边界

`Type_Core` 描述 **类型对象本身** —— `FAngelscriptType` 抽象基类、50+ 子类（`FUObjectType` / `FUStructType` / `FEnumType` / `FObjectPtrType` / ...）、`FAngelscriptTypeUsage` 用法快照、`FAngelscriptTypeDatabase` 反查表的字段布局。它解答的问题是"AS 看到的 `FString` 究竟是 `asITypeInfo*` 加上一个 `FAngelscriptType` 子类对象，怎么从 `FString` 这个名字反查到 `UClass*` / `FProperty` 创建器"。

**本文（Type_BindSystem）描述的是把这些类型对象注册进 AS 引擎的过程**：

| Type_Core 关心 | Type_BindSystem 关心 |
|---------------|---------------------|
| `FAngelscriptType::Register(MakeShared<FBoolType>())` 之后类型反查能找到 | 这一行 `Register(...)` 在哪个 `Bind_*.cpp` 里、什么时候被 `CallBinds` 触发 |
| `FStructType` 怎么实现 `CreateProperty` 返回 `FStrProperty*` | `Bind_FString.cpp` 顶部的 `FBind` 用 `EOrder::Early` 触发 `FAngelscriptType::Register(MakeShared<FStringType>())` |
| `FAngelscriptBindDatabase::Classes` 数组的字段定义 | `Bind_BlueprintType.cpp::Bind_Defaults` 怎么遍历这个数组、按 UClass → method → property 调用 `BindBlueprintCallable` / `BindUClass` |

简言之：**Type_Core 是数据结构 + 反查 API；Type_BindSystem 是把这些数据结构填满的注册时序与编排**。

### 9.2 与 Arch_UHTToolchain 的边界

`Arch_UHTToolchain` 站在"构建期 vs 运行期"的边界外侧，描述 `AngelscriptUHTTool` 这个 C# UBT plugin：

- 它读什么作为输入（12+ 个 UE 模块的 UCLASS/UFUNCTION 头）
- 它产出什么（每个 Runtime-linked 模块一个 `AS_FunctionBinding_<Module>.gen.cpp` + `Summary.json` + 4 份 CSV）
- 它怎么被 AngelscriptRuntime 模块消费（编入 .lib，DLL 加载时 `AS_FORCE_LINK` 拉住）

**与本文的关键耦合点**：UHT 生成的 `AS_FunctionBinding_*.cpp` 长这样：

```cpp
// ============================================================================
// 文件: Plugins/Angelscript/Intermediate/Build/.../AS_FunctionBinding_<Module>.gen.cpp
// 节选自: UHT 生成产物（构建期写出，运行期编入 AngelscriptRuntime.dll）
// ============================================================================
AS_FORCE_LINK const FAngelscriptBinds::FBind                                       // ★ 复用本文 §一 同一个 FBind
Bind_AS_FunctionBinding_<Module>(TEXT("UHT.FunctionBinding.<Module>"), (int32)FAngelscriptBinds::EOrder::Late + 50, [] // ★ 复用本文 §二 同一个 EOrder
{
    FAngelscriptBinds::RegisterFunctionBinding(                                            // ★ 复用本文 §五.4 同一份注册接口
        AActor::StaticClass(), TEXT("K2_DestroyActor"),
        FAngelscriptFunctionBinding{
            ERASE_AUTO_OBJ_PTR(&AActor::execK2_DestroyActor),
            ASAutoCaller::MakeFunctionCaller(...)
        });
    // ... 数千条
});
```

也就是说 **UHT 产物里所有跨边界元素都是本文定义的**：`AS_FORCE_LINK`、`FAngelscriptBinds::FBind`、`EOrder::Late+50`、`RegisterFunctionBinding` / `FAngelscriptFunctionBinding`。Arch_UHTToolchain 描述这些元素**怎么从 C# 端写出来**；本文描述这些元素**写出来之后被运行期怎么消费**。

**最容易混淆的一句话**：UHT 生成的 `Bind_FunctionBinding_*` 在 `EOrder::Late + 50` 注册——它**也走 FBind 框架**，没有任何"特殊通道"绕过 `BindArray` 与 `CallBinds`。它只是一份"数量惊人的、机器写的、`Bind_*.cpp`"。区别仅仅在于：

- 手写 `Bind_*.cpp` 的 lambda 体直接调 `RegisterObjectMethod`（Layer B Runtime-linked）
- UHT 的 lambda 体只调 `RegisterFunctionBinding`（灌库），实际注册由 `Bind_Defaults`（Layer C，`Late+100`）按需触发

### 9.3 三方一图

```text
================================================================================
  Type_Core / Type_BindSystem / Arch_UHTToolchain 三方边界
================================================================================

           ┌────────── Type_Core ──────────┐
           │  FAngelscriptType (50+ 子类)  │
           │  FAngelscriptTypeUsage         │
           │  FAngelscriptTypeDatabase     │  ←─ 数据结构 + 反查 API
           │  FAngelscriptBindDatabase     │
           └─────────┬─────────────────────┘
                     │ 数据被填充 / 反查
                     │
           ┌─────────▼─────────────────────┐
           │  Type_BindSystem（本文）       │  ←─ 注册时序与编排
           │  FBind / EOrder / BindArray   │
           │  CallBinds / BindScriptTypes  │
           │  三层 fallback 模型            │
           └─────────┬─────────────────────┘
                     │
                     │ Layer A 灌库由 UHT 产物提供
                     │
           ┌─────────▼─────────────────────┐
           │  Arch_UHTToolchain             │  ←─ 构建期 / 跨进程边界
           │  AngelscriptUHTTool.csproj    │
           │  AS_FunctionBinding_*.cpp（产物）│
           │  Summary.json + 4 份 CSV      │
           └────────────────────────────────┘
```

---

## 附录 A：`FBind` / `EOrder` / 注册接口速查表

### A.1 `FBind` 构造函数速查

| 写法 | 用途 |
|------|------|
| `FBind(EOrder::Early, []{...})` | 最常见。BindName 自动从文件 stem 推断 |
| `FBind((int32)EOrder::Late + 100, []{...})` | 自由偏移。`int32` 显式转换 |
| `FBind(FName("CustomName"), EOrder::Late, []{...})` | 显式 BindName，便于在 `.ini` 中精准 disable |
| `FBind([]{...})` | 等价于 `FBind(EOrder::Normal, ...)`（int32 缺省值 0） |

### A.2 `FAngelscriptBinds` 常用入口

| 接口 | 何时用 | 例 |
|------|--------|----|
| `ValueClass<T>(name, flags)` | POD / 数学结构 / 容器 | `ValueClass<FVector>("FVector", Flags)` |
| `ReferenceClass(name, UClass*)` | UClass 反射类型首次注册 | `BindUClass` 内部使用 |
| `ExistingClass(name)` | 给已注册类型补充方法 | `Bind_AActor_Base` |
| `BindGlobalFunction(sig, fn)` | 全局函数 | `BindGlobalFunction("void Print(const FString&)", &PrintImpl)` |
| `BindGlobalVariable(sig, addr)` | 全局常量 | `BindGlobalVariable("const FName NAME_None", &SCRIPT_NAME_None)` |
| `BindGlobalGenericFunction(sig, fn)` | 反射 trampoline 入口 | 委托与 BlueprintCallable fallback 用 |
| `Enum(name)` | 枚举注册 | `Enum("EMyEnum")["A"] = 1; Enum("EMyEnum")["B"] = 2;` |
| `FNamespace ns(name)` | 给后续注册套命名空间 | `{ FNamespace ns("FMath"); BindGlobalFunction("..."); }` |
| `AddSkipEntry(class, fn)` | 黑名单 | `AddSkipEntry("StaticMesh", "GetMinLODForQualityLevels")` |
| `RegisterFunctionBinding(class, name, FAngelscriptFunctionBinding)` | 灌库（仅 Layer A） | UHT 生成代码使用 |
| `SetPreviousBindNoDiscard(true)` | 禁止丢弃返回值 | 数学构造函数后 |
| `SetPreviousBindIsCallable(false)` | 标记不可在脚本中调用 | 内部辅助函数 |
| `CompileOutInTest(id)` | Test/Shipping 编译时移除 | `assert` 类辅助 |

### A.3 `EOrder` 取值速查

| 取值 | 典型用例 |
|------|---------|
| `EOrder::Early` (-100) | 基础类型 / 数学 / 容器主体 |
| `EOrder::Early + 1` | 依赖 Early 已就位的二级基础类型（如 `FName`） |
| `EOrder::Normal` (0) | 工具方法、不依赖 UClass 的全局函数 |
| `EOrder::Late - 10` | 智能指针完整实现 |
| `EOrder::Late - 1` | 核心 UClass 手写方法（AActor / UObject / ...） |
| `EOrder::Late` (100) | 委托主体、Skip 黑名单写入 |
| `EOrder::Late + 10` | 跨类型转换运算符 |
| `EOrder::Late + 50` | UHT 灌库（机器生成） |
| `EOrder::Late + 100` | `Bind_Defaults` 三层 fallback 收口 |
| `EOrder::Late + 150` | 跨类型批量发现（Subsystems） |

### A.4 类别 → 阶段对照速查

| 我要写的 Bind 是… | 推荐 EOrder |
|-----------------|-------------|
| 一个 POD struct（FXxx） | `Early` |
| 一个全新的容器模板 | `Early` |
| 给一个核心 UClass 加 5–10 条手写方法 | `Late - 1` |
| 一个跨类型转换 | `Late + 10` |
| 一组遍历 UClass 的批量发现逻辑 | `Late + 150` |
| 一个手动黑名单 | `Late` |
| 不确定？ | `Normal`，跑一次看 `Bind.CallBinds` 顺序日志再调 |

---

## 附录 B：常见错误与避坑

1. **忘加 `AS_FORCE_LINK`**：在 GCC/Clang LTO 下 `Bind_Foo` 全局对象被 dead-strip，结果就是脚本里 `Foo` 类型不存在。**所有** `FBind` 全局对象都必须带 `AS_FORCE_LINK`，无一例外。

2. **签名里出现的类型还没绑**：`Bind_FName` 用 `Early+1` 而不是 `Early` 是为了避免与 `Bind_FString` 同 order 后顺序未定义。**同一 EOrder 内顺序不稳定**，跨编译器、跨 link order 都可能变。依赖关系明显时显式 `+1` / `+2` 表达。

3. **`Bind_*.cpp` 内 `static` 与 `EOrder::Normal` 都没指定**：构造时走 `EOrder::Normal=0`、BindName 从 stem 推断。如果同名 stem 多次出现，第二条会被加 `#1` 后缀——`.ini` 中按 stem 名禁用时只命中第一份，第二份漏网。**多段 bind 在同一个 .cpp 时显式给 `FName("...")`**。

4. **在 lambda 里 capture 强引用 UE 对象**：`FBind` lambda 在 DLL 加载就构造，但执行延后到 `CallBinds`——这中间 UE GC 可能尚未启动。Capture `UClass*` 是安全的（class default object 寿命与进程相同），但**绝不要 capture 一个普通 UObject 实例**。

5. **手写 method 与 UHT 表中的同名 UFunction 同时存在**：手写早于 Layer C 注册。`IsEquivalentScriptSignatureAlreadyBound` 会检测"同名同参数列表"并 skip。但如果手写签名做了"故意特化"（比如把 const ref 改成 by-value），AS 引擎层面就会**双绑**——脚本侧调用按 AS 重载决议规则匹配。这通常不是想要的。手写时优先用 `Bind_AActor_Base` 那种"补充未在 UHT 表覆盖的方法"，避免重复。

6. **`ExistingClass(name)` 之前对应类型未注册**：返回的 `FAngelscriptBinds` 对象 `ScriptType == nullptr`，后续 `.Method(...)` 调用会失败。一定要把 `ExistingClass(...)` 放在 `Bind_BlueprintType_Declarations`（`Early`）之后，至少 `Late-1` 阶段再用。

7. **lambda 体内调 `FAngelscriptEngine::Get()` 但还没 `MakeUnique<FAngelscriptBindState>`**：`Initialize_AnyThread` 中 `BindState = MakeUnique<...>()` **在 `BindScriptTypes` 之前**。但如果开发者错把 lambda 提前到 `PreInitialize_GameThread` 触发，可能会撞到 `BindState` 还是空的状态。本框架内不会出现——只要走标准 `FBind` 入口，时序由 `BindScriptTypes` 自然保证。

8. **错把 `RegisterFunctionBinding` 当成"已注册到 AS 引擎"**：它只是把元数据写进 `ClassFunctionBindings`。AS 引擎层面 `RegisterObjectMethod` 由 `Bind_Defaults`（`Late+100`）触发。手写 `RegisterFunctionBinding` 后若 `Bind_Defaults` 跳过该 UClass（例如未在 `BindDatabase.Classes` 中），方法对脚本仍然不可见。

9. **反射 fallback 撞到 16 参数上限**：`BlueprintCallableReflectiveFallbackMaxArgs = 16`。`UFUNCTION` 参数 ≤ 16 才能走 fallback。超过的必须手写或上 UHT Runtime-linked。

10. **修改 `EOrder` 数值后忘了同步 UHT 端**：UHT 生成代码硬编码 `(int32)EOrder::Late + 50`。如果 `EOrder` 枚举值变化，重新构建项目即可——但开发者改了 `EOrder` 头文件后**必须 rebuild 而不是 incremental build**，否则 UHT 产物 .cpp 的常量会与 .h 不一致。

---

## 小结

- **`FBind` 是一个 static initializer 配 `__builtin_FILE()` 自动命名的注册节点**——每个 `Bind_*.cpp` 顶部那一行的全部能力来自这个简单设计。lambda 在构造时入队，在 `BindScriptTypes` 阶段才被回放。

- **`EOrder` 是只有 3 个枚举锚点（`Early=-100` / `Normal=0` / `Late=100`）的 int32 优先级数轴**。实际取值靠 `int32` 偏移自由组合，覆盖"基础类型 → 智能指针 → UClass 手写 → 委托 → 跨类型转换 → UHT 灌库 → Bind_Defaults 收口 → 跨类型批量发现"八层语义。

- **三层 fallback 模型由同一份 `ClassFunctionBindings` 表粘合**：UHT 在 `Late+50` 灌库（Layer A），手写 `Bind_*.cpp` 在 `Late-1` 直接调 AS API（Layer B），`Bind_Defaults` 在 `Late+100` 按 `bHasDirectNativePointer` 切换"Runtime-linked vs 反射兜底"（Layer C）。

- **125 份手写 `Bind_*.cpp` 与 30+ 份 UHT 生成 `AS_FunctionBinding_*.cpp` 走同一套 `FBind` 框架**，没有任何"特殊通道"。区别仅在 lambda 体里调用的是 `RegisterObjectMethod`（手写Runtime-linked）还是 `RegisterFunctionBinding`（UHT 灌库）。

- **本文与 Type_Core 的边界是"数据 vs 注册"，与 Arch_UHTToolchain 的边界是"运行期消费 vs 构建期产出"**。三者共同回答"`UFunction` 与 `asIScriptFunction` 是怎样在 PostDefault 模块加载、引擎初始化、`.as` 脚本编译三个时间点之间被建立起一对一映射"这个核心问题。
