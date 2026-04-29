# `delegate` / `event` 关键字实现原理

> 本文记录 AngelScript 插件中 `delegate` / `event` 关键字的完整实现：从源码字符到运行时调用的全链路。
>
> 兄弟章节：`Syntax_UFUNCTION.md`（共享 BlueprintEvent 包装机制）、`Syntax_DefaultStatement.md`（共享对象构造时序）。

---

## 概览

AS 的 `delegate` / `event` **不是 AS 引擎原生关键字**，而是预处理器层面的"代码展开"——把 `delegate void FMyDelegate(int x)` 展开为一个普通的 AS `struct`，内含 `_Inner` 字段（指向 UE 原生委托）和 `Execute / Broadcast / BindUFunction` 等成员方法。

```text
预处理器层 (Preprocessor)              AS 编译器层 (ThirdParty/angelscript)
============================           ====================================
扫描 delegate / event -> 产出           只看到普通的 struct 声明
FDelegateDesc, 加入 File.Delegates      asCObjectType<DelegateName> 注册
v                                       v
ProcessDelegates                        AS 类型系统识别为值类型
代码展开为 struct + 成员方法
v
File.GeneratedCode 追加生成代码
        |
        v
类型注册层 (Bind_Delegates.cpp)        运行时调用层 (Bind_BlueprintEvent.cpp)
============================           ====================================
DeclareDelegate / DeclareMulticast     AS 调用 .Execute(args) / .Broadcast(args)
- FAngelscriptType::Register              -> CallDelegateEvent<TIsMulti, TErrUnbound>
   (FScriptDelegateType /                -> CurrentCall().PushArgument(...)
    FMulticastScriptDelegateType /       -> Call.ExecuteDelegate(_Inner)
    FScriptSparseDelegateType)              -> Delegate.ProcessDelegate<UObject>(Buffer)
- FAngelscriptBinds::ValueClass            -> UFunction::Invoke -> 目标 UFUNCTION 执行
   (Constructor / Destructor / Assign)
DeclareDelegateOperations
- IsBound / Clear / GetUObject /
  GetFunctionName / BindUFunction
```

**核心数据载体**：

- **`FAngelscriptDelegateDesc`**（`Core/AngelscriptEngine.h:1231`）—— 编译期描述符
- **`FBlueprintEventSignature`**（`Bind_BlueprintEvent.cpp:492`）—— 运行期调用签名（作为 AS 函数 userData）
- **`FScriptCall`**（`Bind_BlueprintEvent.cpp:90`，alignas(64)）—— 64 字节对齐的参数打包器，全局热备池复用
- **`FDelegateOps`**（`Bind_Delegates.cpp:49`）—— 仅含 `SignatureFunction`，签名兼容性检查载体

**三种委托类型对照**：

| 类型 | AS 关键字 | UE 底层类型 | AS 类型描述器 | 特点 |
|------|----------|-----------|--------------|------|
| 单播 | `delegate` | `FScriptDelegate` | `FScriptDelegateType` | 只绑一个，`Execute` 抛异常 / `ExecuteIfBound` 静默 |
| 多播 | `event` | `FMulticastScriptDelegate` | `FMulticastScriptDelegateType` | 可绑多个，`Broadcast` 遍历调用 |
| 稀疏 | `event` (UE 标记) | `FSparseDelegate` (8B 句柄) | `FScriptSparseDelegateType` | 内存稀疏，用时才分配；不可作参数/返回值 |

---

## 一、预处理器代码展开：`ProcessDelegates`

**源码所在**：`Plugins/Angelscript/Source/AngelscriptRuntime/Preprocessor/AngelscriptPreprocessor.cpp:620` `ProcessDelegates`。

### 1.1 主流程

```cpp
void FAngelscriptPreprocessor::ProcessDelegates(FFile& File)
{
    for (FDelegateDesc& Delegate : File.Delegates)
    {
        // [Step 1] 反向扫描提取委托名（从 '(' 位置向前扫到非标识符字符）
        int32 NameEnd   = Delegate.BracketPos;
        int32 NameStart = NameEnd - 1;
        while (IsIdentifierChar(Chunk.Content[NameStart]))
            NameStart--;
        FString DelegateName = Chunk.Content.Mid(NameStart+1, NameEnd-NameStart-1);

        // [Step 2] 创建编译期描述符并注册到模块
        auto Desc = MakeShared<FAngelscriptDelegateDesc>();
        Desc->LineNumber   = Delegate.FileLineNumber;
        Desc->DelegateName = DelegateName;
        Desc->bIsMulticast = Delegate.bIsMulticast;   // delegate -> false, event -> true
        File.Module->Delegates.Add(Desc);

        // [Step 3] 生成 struct 壳体 + _Inner 成员
        FString GeneratedCode;
        GeneratedCode += FString::Printf(TEXT("struct %s {"), *DelegateName);
        if (Delegate.bIsMulticast)
            GeneratedCode += TEXT("_FMulticastScriptDelegate _Inner;");
        else
            GeneratedCode += TEXT("_FScriptDelegate _Inner;");

        // [Step 4] 生成基础构造/拷贝/赋值（__generated 标记由 C++ 桥接生成）
        GeneratedCode += FString::Printf(
            TEXT("%s() __generated no_discard {}"), *DelegateName);
        GeneratedCode += FString::Printf(
            TEXT("%s(const %s& Other) __generated no_discard { this = Other; }"),
            *DelegateName, *DelegateName);
        GeneratedCode += FString::Printf(
            TEXT("%s& opAssign(const %s& Other) __generated { _Inner = Other._Inner; return this; }"),
            *DelegateName, *DelegateName);

        // [Step 5] 提取参数列表 + 返回类型
        FString Arguments  = ExtractArgumentList(...);
        FString ReturnType = ExtractReturnType(...);
        ReturnType.RemoveFromStart(TEXT("delegate"));
        ReturnType.RemoveFromStart(TEXT("event"));

        // [Step 6] 为每个参数生成 __Evt_PushArgument[Ref] 调用
        FString PushArgumentCode;
        for (each Arg)
        {
            const bool bIsRef    = ArgumentTypes[i].Contains("&");
            const bool bIsConstRef = ArgumentTypes[i].Contains("const ");
            if (bIsRef && !bIsConstRef)
                // 可变引用 -> PushArgumentRef (调用后回写 out 参数)
                PushArgumentCode += __Evt_PushArgumentRef<Suffix>(ArgName);
            else
                // 值或 const 引用 -> 普通 PushArgument
                PushArgumentCode += __Evt_PushArgument<Suffix>(ArgName);
        }

        // [Step 7] 单播 / 多播 分别生成调用方法 (详见 §1.2 / §1.3)
        if (Delegate.bIsMulticast)  /* 生成 Broadcast / AddUFunction / Unbind / UnbindObject */;
        else                        /* 生成 Execute / ExecuteIfBound / BindUFunction / 快捷构造 */;

        // [Step 8] 公共方法
        GeneratedCode += TEXT("bool IsBound() const __generated { return _Inner.IsBound(); }");
        GeneratedCode += TEXT("void Clear() __generated { _Inner.Clear(); }");
        GeneratedCode += TEXT("};");

        // [Step 9] 生成代码追加, 原始 delegate/event 声明用空白覆盖（保持行号一致）
        File.GeneratedCode.Add(GeneratedCode);
        ReplaceWithBlank(Chunk, Delegate.StartPosInChunk, Delegate.EndPosInChunk+1);
    }
}
```

### 1.2 单播 `delegate` 生成的方法集

```cpp
// 带返回值版本（当前项目特有：Hazelight 没区分 bHaveReturn）
if (bHaveReturn)
{
    GeneratedReturn += FString::Printf(TEXT(" %s __ReturnValue%s;"),
        *ReturnType, *GetReturnInit(ReturnType));   // 局部变量预声明
    GeneratedBody += __Evt_PushArgumentRef<Suffix>(__ReturnValue);  // 返回值作 out 参数
}

GeneratedBody += __Evt_ExecuteDelegate(_Inner);
if (bHaveReturn) GeneratedBody += "return __ReturnValue;";

// Execute: 未绑定时抛异常
ReturnType Execute(Args...) const allow_discard __generated {
    [GeneratedReturn]
    if (!_Inner.IsBound()) {
        Throw("Executing unbound delegate.");
        return [__ReturnValue 或 nothing];
    }
    [PushArgumentCode]
    [PushArgumentRef(__ReturnValue) 若有返回值]
    __Evt_ExecuteDelegate(_Inner);
    return __ReturnValue;  // 若有返回值
}

// ExecuteIfBound: 未绑定时静默返回
ReturnType ExecuteIfBound(Args...) const allow_discard __generated {
    [GeneratedReturn]
    if (!_Inner.IsBound()) { return [__ReturnValue 或 nothing]; }
    [PushArgumentCode]
    [PushArgumentRef(__ReturnValue) 若有返回值]
    __Evt_ExecuteDelegate(_Inner);
    return __ReturnValue;
}

// 绑定与查询
void BindUFunction(UObject Object, const FName& BindFunctionName) __generated {
    _Inner.BindUFunction(Object, BindFunctionName, __DelegateSignature(this));
}
UObject GetUObject() const property __generated { return _Inner.GetUObject(); }
FName GetFunctionName() const property __generated { return _Inner.GetFunctionName(); }

// 快捷构造（一步绑定）
FMyDelegate(UObject Object, const FName& BindFunctionName) __generated no_discard {
    _Inner.BindUFunction(Object, BindFunctionName, __DelegateSignature(this));
}
```

### 1.3 多播 `event` 生成的方法集

```cpp
ReturnType Broadcast(Args...) const __generated {
    if (!_Inner.IsBound()) return;
    [PushArgumentCode]
    __Evt_ExecuteDelegate(_Inner);
}

void AddUFunction(const UObject Object, const FName& FunctionName) __generated {
    _Inner.AddUFunction(Object, FunctionName, __DelegateSignature(this));
}
void Unbind(UObject Object, const FName& FunctionName) __generated {
    _Inner.Unbind(Object, FunctionName);
}
void UnbindObject(UObject Object) __generated {
    _Inner.UnbindObject(Object);
}
```

> **注意**：多播 `event` 不生成 `Execute`，只有 `Broadcast`；单播 `delegate` 不生成 `Broadcast`。`__DelegateSignature(this)` 是预处理器特有的内置函数，由 `Bind_Delegates.cpp:1428` 注册为全局 `__DelegateSignature(?& Delegate) -> UDelegateFunction`，运行时返回**该委托类型的签名 UFunction**。

### 1.4 PushArgument Suffix 决策

`GetPushArgumentSuffix(TypeStr)` 决定生成调用 `__Evt_PushArgument<Suffix>(...)` 中的 `<Suffix>`。这些 `__Evt_PushArgument*` 函数由 `Bind_BlueprintEvent.cpp` 注册为全局函数，每个对应一种参数类型分类（`UObject* / FName / int / float / 任意值类型 / 引用 ...`）。详见 `Bind_BlueprintEvent.cpp` `BindPushArgumentForType`。

### 1.5 `__generated` 标记

所有生成的方法都带 `__generated` 修饰符。这是 AS 内核的一个 trait（见 `as_tokendef.h`），表示"此函数没有 AS 字节码实现，由 C++ 桥接提供"。AS 编译器看到 `__generated` 函数会跳过函数体校验，等待 C++ 端在 `Bind_Delegates.cpp` 的 `DeclareDelegateOperations` 中真正绑定实现。

---

## 二、核心数据结构

### 2.1 `FAngelscriptDelegateDesc` —— 编译期描述符

**源码所在**：`Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.h:1231`。

```cpp
struct FAngelscriptDelegateDesc
{
    /* 委托名（脚本里写的，如 "FMyDelegate"） */
    FString DelegateName;

    /* delegate -> false, event -> true */
    bool bIsMulticast = false;

    /* 签名描述（由 C++ 端在 BoundDelegateFunctions 注册时回填） */
    TSharedPtr<FAngelscriptFunctionDesc> Signature;

    /* 生成的 UDelegateFunction（由类生成器在 DoFullReload 时填充） */
    UDelegateFunction* Function = nullptr;

    /* AS 内部 asITypeInfo（由 AS 编译完成后回填） */
    asITypeInfo* ScriptType = nullptr;

    /* 行号，用于错误诊断 */
    int32 LineNumber = 1;
};
```

> 注：当前项目**没有** `bIsSparse` 字段。稀疏委托是 UE 端 `USparseDelegateFunction` 类型决定的，AS 端不区分 `delegate/event` 关键字层面（稀疏委托只能在 C++ 端用 `DECLARE_SPARSE_DELEGATE_*` 声明）。

### 2.2 `FBlueprintEventSignature` —— 运行期调用签名

**源码所在**：`Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_BlueprintEvent.cpp:492`。

```cpp
#define AS_EVENT_MAX_ARGS 16
#define AS_EVENT_MAX_SIZE 1024

struct FBlueprintEventSignature
{
    FAngelscriptTypeUsage ReturnType;
    FAngelscriptTypeUsage Arguments[AS_EVENT_MAX_ARGS];   // 最多 16 个参数
    FAngelscriptTypeUsage MixinType;                       // (*) 当前项目特有: Mixin 第一参类型
    int32                 ArgCount = 0;
    int32                 OutReferences[AS_EVENT_MAX_ARGS]; // (*) 当前项目特有: out 参数索引列表
    int32                 OutCount = 0;
    FName                 FunctionName;
    UObject*              StaticObject = nullptr;          // (*) 当前项目特有: 静态调用时的固定 Object
    bool                  bInitReturn  = false;            // 返回值是否需构造（非 POD）
    bool                  bZeroReturnPtr = false;          // 返回值是指针时是否清零
    UFunction*            UnrealFunction = nullptr;
};
```

> 当前项目相对参考文档**多了 4 个字段**（`MixinType / OutReferences / OutCount / StaticObject`），用于支持 Mixin 调用、out 参数显式追踪、静态对象调用三种额外场景。这些是 Hazelight 没有的扩展能力。

### 2.3 `FScriptCall` —— 64 字节对齐的参数打包器

**源码所在**：`Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_BlueprintEvent.cpp:90`。

```cpp
struct alignas(64) FScriptCall   // (*) alignas(64): 独占 CPU cache line
{
    struct FArgumentInBuffer
    {
        FAngelscriptTypeUsage Type;        // 类型描述
        SIZE_T Offset;                     // 在 ArgumentBuffer 中的起始偏移
        void*  Reference;                  // 引用参数原始地址（调用后回写 out 用）
    };

    uint8             ArgumentBuffer[AS_EVENT_MAX_SIZE];  // 1024 B 连续参数内存
    FArgumentInBuffer ArgumentTypes[AS_EVENT_MAX_ARGS];   // 16 个参数元数据
    int32             ArgumentIndex   = 0;                // 已推参数数
    SIZE_T            ArgumentOffset  = 0;                // 当前写位置（含对齐 padding）

    template<bool TCheckErrors = true, bool TCopyInitialValue = true>
    SCRIPTCALL_INLINE void PushArgument(FAngelscriptTypeUsage& Type, void* ValueRef);

    SCRIPTCALL_INLINE void ExecutePreamble();              // 标记为执行中（不可再 Push）
    SCRIPTCALL_INLINE void ExecuteCleanup();                // 回写 out + 析构 + 入热备池

    SCRIPTCALL_INLINE void ExecuteDelegate(FScriptDelegate&);
    SCRIPTCALL_INLINE void ExecuteMulticastDelegate(FMulticastScriptDelegate&);
    SCRIPTCALL_INLINE void ExecuteEvent(UObject*, FName);   // BlueprintEvent 专用
};

// 全局热备池
static FScriptCall* GCurrentCall = nullptr;   // 当前正在 push 参数的实例
static FScriptCall* GStoredCall  = nullptr;   // 上次用完后暂存的备用实例（复用避免 malloc）
```

> **限制**：单次调用参数总字节数不能超 `AS_EVENT_MAX_SIZE=1024`，参数个数不能超 `AS_EVENT_MAX_ARGS=16`。
> 超限会触发 `check` 断言（`TCheckErrors=true` 时）或导致越界写。

### 2.4 `FDelegateOps` —— 签名校验载体

**源码所在**：`Bind_Delegates.cpp:49`。

```cpp
struct FDelegateOps
{
    UDelegateFunction* SignatureFunction;   // 仅一个字段：签名函数
};
```

只用作 AS 函数的 `userdata`，让运行时 `BindUFunction` 能取到原始签名做兼容性校验。

### 2.5 三种 AS 类型描述器

**源码所在**：`Bind_Delegates.cpp:57 / 633 / 1125`。

```cpp
// 单播
struct FScriptDelegateType : TAngelscriptCppType<FScriptDelegate>
{
    FString             Name;
    UDelegateFunction*  Function;     // 签名函数

    FProperty* CreateProperty(...) override
    {
        // 生成 FDelegateProperty 并绑定 SignatureFunction（保证类型安全）
        auto* Prop = new FDelegateProperty(Outer, PropertyName, RF_Public);
        Prop->SignatureFunction = GetSignature(Usage);
        return Prop;
    }

    void SetArgument(...) override
    {
        // 区分引用/值传递：
        // - 引用: StepCompiledInRef -> Context->SetArgAddress
        // - 值:   StepCompiledIn -> Context->SetArgObject
    }

    FString GetDebuggerValue(...) override;     // 调试器显示
    void GenerateNativeForm(...) override;      // Static JIT 代码生成
};

// 多播
struct FMulticastScriptDelegateType : TAngelscriptCppType<FMulticastScriptDelegate>
{ /* 与 FScriptDelegateType 几乎对称，但 CreateProperty 生成 FMulticastInlineDelegateProperty */ };

// 稀疏（继承 FAngelscriptType 而非 TAngelscriptCppType<...>，因为 FSparseDelegate 不能作参/返）
struct FScriptSparseDelegateType : public FAngelscriptType
{
    /* CreateProperty 生成 FMulticastSparseDelegateProperty
       禁止作为参数/返回值（在 SetArgument 中报错）*/
};
```

---

## 三、类型注册：`DeclareDelegate` 三层结构

委托类型注册分三个独立函数，分别处理三种委托类型：

### 3.1 单播注册：`DeclareDelegate`

```cpp
void DeclareDelegate(UDelegateFunction* Function)
{
    FString Decl = CreateAngelscriptNameForDelegate(Function);   // "FMyDelegate"

    // [Step 1] 注册到 BindDatabase 供代码生成与持久化
    FAngelscriptBindDatabase::Get().BoundDelegateFunctions.Add(Function);

    // [Step 2] 注册 AS 类型描述器
    FAngelscriptType::Register(MakeShared<FScriptDelegateType>(Decl, Function));

    // [Step 3] 在 AS 引擎里声明为值类型 + 注册基础生命周期
    auto Delegate_ = FAngelscriptBinds::ValueClass<FScriptDelegate>(Decl, BindFlags);
    Delegate_.Constructor("void f()",
        FUNC_TRIVIAL(FAngelscriptDelegateOperations::Construct));
    Delegate_.Destructor("void f()",
        FUNC_TRIVIAL(FAngelscriptDelegateOperations::Destruct));
    Delegate_.Constructor("void f(const FMyDelegate& Other)",
        FUNC_TRIVIAL(FAngelscriptDelegateOperations::CopyConstruct));
    Delegate_.Method("FMyDelegate& opAssign(const FMyDelegate& Other)",
        FUNC_TRIVIAL(FAngelscriptDelegateOperations::Assign));
}
```

### 3.2 多播注册：`DeclareMulticastDelegate`

与单播对称，差异：

```cpp
FAngelscriptType::Register(MakeShared<FMulticastScriptDelegateType>(Decl, Function));
auto Delegate_ = FAngelscriptBinds::ValueClass<FMulticastScriptDelegate>(Decl, FBindFlags());
// Constructor / Destructor / Copy / Assign 用 FAngelscriptMulticastDelegateOperations::* 替换
```

### 3.3 稀疏注册：`DeclareSparseDelegate`

```cpp
void DeclareSparseDelegate(USparseDelegateFunction* Function)
{
    FAngelscriptType::Register(MakeShared<FScriptSparseDelegateType>(Decl, Function));
    // 不调用 ValueClass<...>: 稀疏委托不可作参数/返回值
    // 仅在 DeclareSparseDelegateOperations 中注册操作方法
}
```

### 3.4 操作方法注册：`DeclareDelegateOperations`

```cpp
void DeclareDelegateOperations(UDelegateFunction* Function)
{
    FDelegateOps* Ops = new FDelegateOps;
    Ops->SignatureFunction = Function;     // 签名载体, 附在 AS 函数 userdata

    auto Delegate_ = FAngelscriptBinds::ExistingClass(CreateAngelscriptNameForDelegate(Function));

    // 基础查询方法（trivial: JIT 优化）
    Delegate_.Method("bool IsBound() const",
        FUNC_TRIVIAL(FAngelscriptDelegateOperations::IsBound));
    Delegate_.Method("UObject GetUObject() const",
        FUNC_TRIVIAL(FAngelscriptDelegateOperations::GetUObject));
    Delegate_.Method("FName GetFunctionName() const",
        FUNC_TRIVIAL(FAngelscriptDelegateOperations::GetFunctionName));
    Delegate_.Method("void Clear()",
        FUNC_TRIVIAL(FAngelscriptDelegateOperations::Clear));

    // 快捷构造: FMyDelegate(obj, n"Func")
    Delegate_.Constructor("void f(UObject Object, const FName& FunctionName)",
        FUNC(FAngelscriptDelegateOperations::ConstructFromFunction), Ops);
    FAngelscriptBinds::PreviousBindPassScriptFunctionAsFirstParam();

    // 绑定方法（携带 Ops 用于签名校验）
    Delegate_.Method("void BindUFunction(UObject Object, const FName& FunctionName)",
        FUNC(FAngelscriptDelegateOperations::BindUFunction), Ops);
    FAngelscriptBinds::PreviousBindPassScriptFunctionAsFirstParam();
    // (*) PreviousBindPassScriptFunctionAsFirstParam: 让 AS 引擎自动把 asCScriptFunction*
    //     作为第一参数注入, 这样 BindUFunction 能从 userdata 取出 FDelegateOps

    // Execute / ExecuteIfBound 注册（详见 §四）
    BindDelegateEvent(Delegate_, Function, /*bIsMulticast=*/false, /*bIsSparse=*/false);
}
```

### 3.5 当前项目特有的 `_Signature` 变体

当前项目相对参考文档**额外提供**了 `_Signature` 后缀版本，让脚本可以**显式传入**签名 UDelegateFunction（而不是从 userdata 取）：

```cpp
// Bind_Delegates.cpp:536
void FAngelscriptDelegateOperations::BindUFunction_Signature(
    FScriptDelegate* Delegate, UObject* InObject, const FName& InFunctionName,
    UDelegateFunction* Signature)
{
    // 与 BindUFunction 相同的逻辑, 但 Signature 来自显式参数而非 userdata
    // 用途: 让生成的 struct 内部方法不依赖 userdata 传递, 更便于热重载
}

// Bind_Delegates.cpp:1428
FAngelscriptBinds::BindGlobalFunction(
    "UDelegateFunction __DelegateSignature(?& Delegate)",
    FUNC_TRIVIAL(FAngelscriptDelegateOperations::GetDelegateSignature));
```

预处理器生成的代码中，`BindUFunction(Object, Name)` 内部实际调用 `_Inner.BindUFunction(Object, Name, __DelegateSignature(this))`——这就是为什么 §1.2/§1.3 中 `_Inner.BindUFunction` 总带第三参 `__DelegateSignature(this)`。

---

## 四、`BindDelegateEvent` —— Execute/Broadcast 注册

**源码所在**：`Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_BlueprintEvent.cpp` `BindDelegateEvent`。

### 4.1 主流程

```cpp
void BindDelegateEvent(FAngelscriptBinds& Delegate_, UFunction* Function,
                       bool bIsMulticast, bool bIsSparse)
{
    // [Step 1] 遍历 UFunction 参数 -> 转 FAngelscriptTypeUsage
    TArray<FAngelscriptTypeUsage> ArgumentTypes;
    TArray<FString>               ArgumentNames;
    FAngelscriptTypeUsage         ReturnType;

    for (TFieldIterator<FProperty> It(Function); It && (It->PropertyFlags & CPF_Parm); ++It)
    {
        FAngelscriptTypeUsage Type = FAngelscriptTypeUsage::FromProperty(*It);
        if (It->PropertyFlags & CPF_ReturnParm)
            ReturnType = Type;
        else
        {
            ArgumentTypes.Add(Type);
            ArgumentNames.Add(Property->GetName());
            // const 引用参数追加 "in " 前缀, 标记为 inref
            if ((PropFlags & CPF_OutParm) && (PropFlags & CPF_ConstParm))
                ArgumentNames.Last() = "in " + ArgumentNames.Last();
        }
    }

    // [Step 2] 长度校验（防御 16 参数限制）
    if (ArgumentTypes.Num() > AS_EVENT_MAX_ARGS) { /* 报错并跳过 */ }

    // [Step 3] 构建 FBlueprintEventSignature（运行期调用所需的全部信息）
    auto* Sig = new FBlueprintEventSignature;
    Sig->UnrealFunction = Function;
    Sig->FunctionName   = Function->GetFName();
    Sig->ArgCount       = ArgumentTypes.Num();
    Sig->ReturnType     = ReturnType;
    for (int32 i = 0; i < Sig->ArgCount; ++i)
        Sig->Arguments[i] = ArgumentTypes[i];

    // 返回值初始化策略
    if (Sig->ReturnType.IsValid())
    {
        Sig->bInitReturn   = ReturnType.CanConstruct() && ReturnType.NeedConstruct();
        Sig->bZeroReturnPtr = !Sig->bInitReturn && ReturnType.Type->IsObjectPointer();
    }

    // [Step 4] 按委托类型注册不同的 GenericMethod
    if (bIsSparse)
    {
        Delegate_.GenericMethod(BuildBroadcastDecl(...), &CallSparseDelegate, Sig);
    }
    else if (bIsMulticast)
    {
        // 多播 Broadcast: TIsMulticast=true, TErrorIfUnbound=false
        Delegate_.GenericMethod(BuildBroadcastDecl(...),
            &CallDelegateEvent<true, false>, Sig);
    }
    else
    {
        // 单播 Execute: TErrorIfUnbound=true (未绑定时抛异常)
        Delegate_.GenericMethod(BuildExecuteDecl(...) + " allow_discard",
            &CallDelegateEvent<false, true>, Sig);
        // 单播 ExecuteIfBound: TErrorIfUnbound=false (静默)
        Delegate_.GenericMethod(BuildExecuteDecl(...) + " allow_discard",
            &CallDelegateEvent<false, false>, Sig);
    }
}
```

### 4.2 `Sig` 作为 userdata 的语义

```text
asCScriptFunction (Execute / Broadcast) ──userdata──> FBlueprintEventSignature*
                                                      ├─ ReturnType / Arguments[N] / ArgCount
                                                      ├─ bInitReturn / bZeroReturnPtr
                                                      ├─ FunctionName / UnrealFunction
                                                      └─ MixinType / OutReferences[N] / OutCount /
                                                         StaticObject  (当前项目扩展字段)
```

运行期 `CallDelegateEvent` 通过 `Generic->GetFunction()->GetUserData()` 取出此结构，无需重新解析 UFunction。

### 4.3 双布尔模板参数

```cpp
template<bool TIsMulticast, bool TErrorIfUnbound>
void CallDelegateEvent(asIScriptGeneric* InGeneric);
```

| `TIsMulticast` | `TErrorIfUnbound` | 用途 | 委托方法 |
|----------------|-------------------|------|---------|
| `false` | `true` | 单播 Execute | `delegate.Execute(...)` |
| `false` | `false` | 单播 ExecuteIfBound | `delegate.ExecuteIfBound(...)` |
| `true` | `false` | 多播 Broadcast | `event.Broadcast(...)` |
| `true` | `true` | 不存在 | — |

模板特化让编译器为每种调用生成最优代码（消除运行时 if 分支）。

---

## 五、运行时调用链：`CallDelegateEvent`

**源码所在**：`Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_BlueprintEvent.cpp:656`。

```cpp
template<bool TIsMulticast, bool TErrorIfUnbound>
void CallDelegateEvent(asIScriptGeneric* InGeneric)
{
    asCGeneric* Generic = static_cast<asCGeneric*>(InGeneric);

    // [Step 1] 取出签名信息
    auto* Function = (asCScriptFunction*)Generic->GetFunction();
    auto* Sig      = (FBlueprintEventSignature*)Function->GetUserData();

    // [Step 2] 取出委托对象（this 指针）
    void* Object = Generic->GetObject();

    // [Step 3] 绑定检查
    if (!TIsMulticast)
    {
        FScriptDelegate& ScriptDelegate = *(FScriptDelegate*)Object;
        if (!ScriptDelegate.IsBound())
        {
            if (TErrorIfUnbound)
                FAngelscriptManager::Throw("Executing unbound delegate.");
            return;
        }
    }
    else
    {
        FMulticastScriptDelegate& ScriptDelegate = *(FMulticastScriptDelegate*)Object;
        if (!ScriptDelegate.IsBound()) return;     // 多播未绑定时静默
    }

    // [Step 4] 取得当前帧 FScriptCall, 推入参数
    FScriptCall& Call = CurrentCall();
    for (int32 Arg = 0; Arg < Sig->ArgCount; ++Arg)
        Call.PushArgument<false>(Sig->Arguments[Arg], Generic->GetAddressOfArg(Arg));

    // [Step 5] 处理返回值内存
    if (Sig->ReturnType.IsValid())
    {
        void* ReturnPtr = Generic->GetAddressOfReturnLocation();
        if (Sig->bInitReturn)
            Sig->ReturnType.ConstructValue(ReturnPtr);   // 非 POD 原地构造
        else if (Sig->bZeroReturnPtr)
            *(void**)ReturnPtr = nullptr;                // 指针清零
        Call.PushArgument<false, false>(Sig->ReturnType, &ReturnPtr); // 返回值作隐式 out
    }

    // [Step 6] 实际执行
    if (!TIsMulticast)
    {
        FScriptDelegate& ScriptDelegate = *(FScriptDelegate*)Object;
        Call.ExecuteDelegate(ScriptDelegate);
    }
    else
    {
        FMulticastScriptDelegate& ScriptDelegate = *(FMulticastScriptDelegate*)Object;
        Call.ExecuteMulticastDelegate(ScriptDelegate);
    }
}
```

### 5.1 `FScriptCall::ExecuteDelegate` 三种执行路径

```cpp
SCRIPTCALL_INLINE void ExecuteDelegate(FScriptDelegate& Delegate)
{
    ExecutePreamble();                                       // 切换状态: 不可再 Push
    Delegate.ProcessDelegate<UObject>(&ArgumentBuffer[0]);   // UE 原生委托触发
    ExecuteCleanup();                                        // 回写 out + 析构 + 入热备池
}

SCRIPTCALL_INLINE void ExecuteMulticastDelegate(FMulticastScriptDelegate& Delegate)
{
    ExecutePreamble();
    Delegate.ProcessMulticastDelegate<UObject>(&ArgumentBuffer[0]);  // 遍历 InvocationList
    ExecuteCleanup();
}

SCRIPTCALL_INLINE void ExecuteEvent(UObject* Object, FName EventName)
{
    UFunction* Function = Object->FindFunctionChecked(EventName);
    ExecutePreamble();
    Object->ProcessEvent(Function, &ArgumentBuffer[0]);      // BlueprintEvent 直接触发
    ExecuteCleanup();
}
```

三条路径**共享同一份 `ArgumentBuffer` 布局**——这是为什么 `FScriptCall` 能统一服务委托调用、多播触发、`BlueprintEvent` 直接派发三种场景。

### 5.2 `PushArgument` 内存对齐与 out 参数追踪

```cpp
template<bool TCheckErrors = true, bool TCopyInitialValue = true>
SCRIPTCALL_INLINE void PushArgument(FAngelscriptTypeUsage& Type, void* ValueRef)
{
    // [a] 对齐: 按类型对齐要求填 padding（如 float -> 4B 对齐, double -> 8B 对齐）
    ArgumentOffset = Align(ArgumentOffset, Type.GetValueAlignment());

    // [b] 长度防御
    if ((TCheckErrors || DO_CHECK) && ArgumentIndex >= AS_EVENT_MAX_ARGS) { check(0); }
    if ((TCheckErrors || DO_CHECK) && ArgumentOffset + Type.GetValueSize() >= AS_EVENT_MAX_SIZE) { check(0); }

    // [c] 在 buffer 中原地构造
    void* StoredPtr = &ArgumentBuffer[ArgumentOffset];
    Type.ConstructValue(StoredPtr);

    if (Type.bIsReference)
    {
        void* OrigValueRef = *(void**)ValueRef;       // 解引用获取真实指针
        if (TCopyInitialValue)
            Type.CopyValue(OrigValueRef, StoredPtr);  // 拷贝初值
        ArgumentTypes[ArgumentIndex].Reference = OrigValueRef;  // 记录 -> 用于 out 回写
    }
    else
    {
        if (TCopyInitialValue)
            Type.CopyValue(ValueRef, StoredPtr);
    }

    ArgumentTypes[ArgumentIndex].Type   = Type;
    ArgumentTypes[ArgumentIndex].Offset = ArgumentOffset;

    ArgumentOffset += Type.GetValueSize();
    ArgumentIndex  += 1;
}
```

### 5.3 `ExecuteCleanup` —— 回写 + 热备池

```cpp
SCRIPTCALL_INLINE void ExecuteCleanup()
{
    // [Step 1] 逐参数处理: 非 const 引用 -> 回写到 AS 调用方原始地址
    for (int32 i = 0; i < ArgumentIndex; ++i)
    {
        void* StoredPtr = &ArgumentBuffer[ArgumentTypes[i].Offset];
        if (ArgumentTypes[i].Type.bIsReference && !ArgumentTypes[i].Type.bIsConst)
            ArgumentTypes[i].Type.CopyValue(StoredPtr, ArgumentTypes[i].Reference);
        ArgumentTypes[i].Type.DestructValue(StoredPtr);     // 析构（含非 POD 类型）
    }
    ResetNonArgumentVariables();

    // [Step 2] 热备池管理
    if (GStoredCall == nullptr)
        GStoredCall = this;                  // 入热备
    else
    {
        this->~FScriptCall();
        FMemory::Free(this);                 // 多余的释放
    }
}
```

### 5.4 `CurrentCall` —— 懒分配 + 热备复用

```cpp
SCRIPTCALL_INLINE FScriptCall& CurrentCall()
{
    if (GCurrentCall == nullptr)
    {
        if (GStoredCall != nullptr)
        {
            GCurrentCall = GStoredCall;      // 复用热备 (0 分配开销)
            GStoredCall  = nullptr;
        }
        else
        {
            // alignas(64): 独占 cache line 防止 false sharing
            GCurrentCall = (FScriptCall*)FMemory::Malloc(sizeof(FScriptCall),
                                                        alignof(FScriptCall));
            new(GCurrentCall) FScriptCall();
        }
    }
    return *GCurrentCall;
}
```

> **线程模型**：所有委托调用都隐式假设在游戏线程（`ExecutePreamble` 中 `check(IsInGameThread())`）。多线程场景下需调用方自己同步。

---

## 六、`BindUFunction` —— 绑定与签名兼容性校验

**源码所在**：`Bind_Delegates.cpp:508`（单播） / `:1037`（多播）。

### 6.1 单播绑定流程

```cpp
void FAngelscriptDelegateOperations::BindUFunction(
    FScriptDelegate*    Delegate,
    asCScriptFunction*  Function,        // 由 PreviousBindPassScriptFunctionAsFirstParam 注入
    UObject*            InObject,
    const FName&        InFunctionName)
{
    // [Step 1] 空指针检查
    if (InObject == nullptr)
    {
        FAngelscriptManager::Throw("Null object passed to BindUFunction.");
        return;
    }

    // [Step 2] 在目标对象上查找函数 (必须是 UFUNCTION)
    UFunction* CallFunction = InObject->FindFunction(InFunctionName);
    if (CallFunction == nullptr) { /* 报错 */ return; }

    // [Step 3] 取出 Ops, 拿到原始签名
    FDelegateOps* Ops = (FDelegateOps*)Function->userdata;

    // [Step 4] 签名兼容性校验
    if (!CheckAngelscriptDelegateCompatibility(Ops->SignatureFunction, CallFunction))
    {
        FAngelscriptManager::Throw("Specified function is not compatible with delegate function.");
        return;
    }

    // [Step 5] 校验通过, 绑定
    Delegate->BindUFunction(InObject, InFunctionName);
}
```

### 6.2 多播绑定差异

```cpp
void FAngelscriptMulticastDelegateOperations::AddUFunction(...)
{
    // [Step 1-4 与单播相同]
    // [Step 5] 创建临时单播再 AddUnique（防重复绑定）
    FScriptDelegate InnerDelegate;
    InnerDelegate.BindUFunction(InObject, InFunctionName);
    Delegate->AddUnique(InnerDelegate);
}
```

### 6.3 `CheckAngelscriptDelegateCompatibility` —— 签名兼容性

**源码所在**：`Bind_Delegates.cpp` `CheckAngelscriptDelegateCompatibility`。

逻辑镜像 UE 的 `UFunction::IsSignatureCompatibleWith`，但有 AS 特有放宽：

```cpp
bool CheckAngelscriptDelegateCompatibility(UFunction* Signature, UFunction* CheckFunction)
{
    if (Signature == CheckFunction) return true;

    const uint64 IgnoreFlags = UFunction::GetDefaultIgnoredSignatureCompatibilityFlags();

    TFieldIterator<FProperty> IteratorA(Signature);
    TFieldIterator<FProperty> IteratorB(CheckFunction);

    while (IteratorA && (IteratorA->PropertyFlags & CPF_Parm))
    {
        if (IteratorB && (IteratorB->PropertyFlags & CPF_Parm))
        {
            FProperty* PropA = *IteratorA;
            FProperty* PropB = *IteratorB;
            uint64 PropertyMash = PropA->PropertyFlags ^ PropB->PropertyFlags;

            // (*) AS 特殊放宽:
            // 签名是 CPF_OutParm, 实现是 CPF_ReferenceParm -> 视为兼容（忽略 ReferenceParm 差异）
            // 这让 AS 的引用参数能绑定到 C++ 的 out 参数
            if ((PropA->PropertyFlags & CPF_OutParm) && (PropB->PropertyFlags & CPF_ReferenceParm))
                PropertyMash &= ~CPF_ReferenceParm;

            if (!CheckAngelscriptPropertyCompatibility(PropA, PropB)
                || ((PropertyMash & ~IgnoreFlags) != 0))
                return false;
        }
        else return false;            // B 参数比 A 少
        ++IteratorA; ++IteratorB;
    }

    return !(IteratorB && (IteratorB->PropertyFlags & CPF_Parm));   // B 不能多参
}
```

`CheckAngelscriptPropertyCompatibility` 的额外放宽：**相同字节数的枚举视为兼容**（如 `EHitResult` 与 `int8` 可互相绑定）。

---

## 七、稀疏委托特殊机制

**源码所在**：`Bind_Delegates.cpp:1125` `FScriptSparseDelegateType` + `DeclareSparseDelegateOperations`。

### 7.1 设计目的

稀疏委托（`USparseDelegateFunction` + `FSparseDelegate`）是 UE 5+ 引入的内存优化方案：

```cpp
// FSparseDelegate 本身只是 8 字节句柄, 不内嵌真实数据
struct FSparseDelegate { uint8 bIsBound : 1; };

// 真实委托数据存在全局 FSparseDelegateStorage
// 仅当首次绑定时才分配, 未绑定的稀疏委托零内存开销
```

适用场景：Actor / Component 上有大量"很少绑定"的事件委托，避免每个实例都为每个事件预留内存。

### 7.2 关键限制

```cpp
struct FScriptSparseDelegateType : public FAngelscriptType   // (*) 不继承 TAngelscriptCppType<...>
{
    // 不可作参数 / 返回值: SetArgument / GetReturnValue 触发 ScriptCompileError
    // 仅可作字段 + 调用 Broadcast / AddUFunction / Unbind / Clear / IsBound
};
```

### 7.3 `Clear` 特殊实现

稀疏委托的 `Clear` 不能直接调用 `FSparseDelegate::Clear()`，必须通过 `FSparseDelegateStorage` 解析出真实 Owner：

```cpp
Delegate_.Method("void Clear()", [](FSparseDelegate* Delegate, asCScriptFunction* Function)
{
    FDelegateOps* Ops = (FDelegateOps*)Function->userdata;
    USparseDelegateFunction* SparseFunc = CastChecked<USparseDelegateFunction>(Ops->SignatureFunction);

    // 从全局稀疏存储中查找真实 Owner
    UObject* OwningObject = FSparseDelegateStorage::ResolveSparseOwner(
        *Delegate,
        SparseFunc->OwningClassName,
        SparseFunc->DelegateName);

    Delegate->__Internal_Clear(OwningObject, SparseFunc->DelegateName);
}, Ops);
```

### 7.4 `Broadcast` 走 `CallSparseDelegate`

```cpp
BindDelegateEvent(Delegate_, Function, /*bIsMulticast=*/true, /*bIsSparse=*/true);
//                                                              ^^^^^^^^^^^^^^^
// 走 &CallSparseDelegate (而非 &CallDelegateEvent<true, false>)
```

`CallSparseDelegate` 内部需要先 `FSparseDelegateStorage::ResolveSparseOwner` 找到真实 `FMulticastScriptDelegate`，再走 `Call.ExecuteMulticastDelegate` 路径。

### 7.5 三种委托对照速览

| 维度 | `FScriptDelegate` | `FMulticastScriptDelegate` | `FSparseDelegate` |
|------|-------------------|---------------------------|-------------------|
| 内存大小 | ~16B (`TWeakObjectPtr<UObject>` + `FName`) | 动态 (`TArray<FScriptDelegate>` InlineAllocator<4>) | 8B 句柄 |
| 调用方法 | `Execute` / `ExecuteIfBound` | `Broadcast` | `Broadcast` |
| 绑定方法 | `BindUFunction` / 快捷构造 | `AddUFunction` / `Unbind` / `UnbindObject` | `AddUFunction` / `Unbind` |
| 可作参数 / 返回值 | 是 | 是 | **否**（编译期报错） |
| 真实数据位置 | 内嵌于持有对象 | 内嵌（`InvocationList`） | `FSparseDelegateStorage` 全局表 |
| 调用入口 | `CallDelegateEvent<false, *>` | `CallDelegateEvent<true, false>` | `CallSparseDelegate` |
| 类型描述器 | `FScriptDelegateType` | `FMulticastScriptDelegateType` | `FScriptSparseDelegateType` |
| 注册函数 | `DeclareDelegate` + `DeclareDelegateOperations` | `DeclareMulticastDelegate` + `DeclareMulticastDelegateOperations` | `DeclareSparseDelegate` + `DeclareSparseDelegateOperations` |

---

## 八、热重载机制

委托类型的热重载比普通类更复杂：**同名委托在重载后是新的 `UDelegateFunction*`**，需要把所有蓝图节点 / 已有委托实例的引用替换掉。

### 8.1 `FDelegateData` 跟踪结构

**源码所在**：`Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator/AngelscriptClassGenerator.h`。

```cpp
struct FDelegateData : public FReloadPropagation
{
    int32 DataIndex;
    TSharedPtr<FAngelscriptDelegateDesc> NewDelegate;  // 重载后的新委托
    TSharedPtr<FAngelscriptDelegateDesc> OldDelegate;  // 重载前的旧委托
    bool bAnalyzed = false;
    TArray<int32> ReloadReqLines;
};
```

### 8.2 决策：软重载 vs 全量重载

| 变化 | 触发的重载 |
|------|-----------|
| 委托签名（参数类型 / 数量 / 返回值）改变 | **全量重载** |
| 委托名相同但 `bIsMulticast` 切换 | **全量重载** |
| 仅元数据变化（如 `LineNumber`）| 软重载 |

### 8.3 全量重载流程

```cpp
void FAngelscriptClassGenerator::DoFullReload(FModuleData& Module, FDelegateData& DelegateData)
{
    // [Step 1] 创建新的 UDelegateFunction (同名但是新实例)
    // [Step 2] 重新调用 DeclareDelegate / DeclareMulticastDelegate / DeclareSparseDelegate
    // [Step 3] 触发 OnDelegateReload 事件
    FAngelscriptClassGenerator::OnDelegateReload.Broadcast(OldDelegate, NewDelegate);
}
```

### 8.4 `FReloadState` 维护映射表

**源码所在**：`AngelscriptEditor/HotReload/ClassReloadHelper.cpp`。

```cpp
struct FReloadState
{
    TMap<UDelegateFunction*, UDelegateFunction*> ReloadDelegates;  // 旧 -> 新
    TSet<UDelegateFunction*>                     NewDelegates;     // 本次新增的
};

// 在 FClassReloadHelper::Init() 中订阅 OnDelegateReload
FAngelscriptClassGenerator::OnDelegateReload.AddLambda(
    [this](TSharedPtr<FAngelscriptDelegateDesc> OldDesc,
           TSharedPtr<FAngelscriptDelegateDesc> NewDesc)
    {
        if (OldDesc->Function != nullptr && NewDesc->Function != nullptr)
            ReloadState.ReloadDelegates.Add(OldDesc->Function, NewDesc->Function);
        if (NewDesc->Function != nullptr)
            ReloadState.NewDelegates.Add(NewDesc->Function);
    }
);
```

### 8.5 蓝图引用替换

`FClassReloadHelper::PerformReinstance` 中通过 `FArchiveReplaceObjectRef` 遍历所有蓝图节点，用 `ReloadDelegates` 映射把所有旧 `UDelegateFunction*` 引用替换为新的——这样蓝图 Pin 类型自动更新，无需用户手动重连节点。

### 8.6 已绑定运行时实例的处理

```text
+-- FScriptDelegate.SignatureFunction = OldUDelegateFunction
|     |
|     v 通过 FArchiveReplaceObjectRef 扫描
|     |
+-- 替换为 NewUDelegateFunction
+-- 已绑定的目标 UObject + FName 不变 (绑定本身用 FName 查找)
+-- 下次调用 Execute / Broadcast 时, FBlueprintEventSignature 已是新版本
```

> **重要边界**：如果热重载导致委托签名改变（参数类型 / 数量改），所有已绑定的 UFunction 会**签名校验失败**，下次调用直接抛 `"Specified function is not compatible with delegate function."`。这是设计选择——参数类型不兼容时静默重新绑定会引入更难诊断的运行时崩溃。

---

## 九、完整 ASCII 架构图

下图以 `delegate void FMyDelegate(int32 Damage)` 为例展示从源码到运行调用的完整链路：

```text
============================================================================
  delegate / event 关键字的完整生命周期 (单播 delegate 示例)
============================================================================

[.as 源文件]
    delegate void FMyDelegate(int32 Damage);
    FMyDelegate MyDelegate;
        |
        | [Step 1] Preprocessor 扫描识别 (delegate / event 关键字)
        v
FFile.Delegates += FDelegateDesc { bIsMulticast=false, BracketPos, ChunkIndex, ... }
        |
        | [Step 2] ProcessDelegates 代码展开
        v
File.GeneratedCode 追加:
    struct FMyDelegate {
        _FScriptDelegate _Inner;
        FMyDelegate() __generated no_discard {}
        FMyDelegate(const FMyDelegate& Other) __generated no_discard { this = Other; }
        FMyDelegate& opAssign(...) __generated { _Inner = Other._Inner; return this; }

        void Execute(int32 Damage) const allow_discard __generated {
            if (!_Inner.IsBound()) { Throw("Executing unbound delegate."); return; }
            __Evt_PushArgument<int32>(Damage);
            __Evt_ExecuteDelegate(_Inner);
        }
        void ExecuteIfBound(int32 Damage) const allow_discard __generated {
            if (!_Inner.IsBound()) { return; }
            __Evt_PushArgument<int32>(Damage);
            __Evt_ExecuteDelegate(_Inner);
        }
        void BindUFunction(UObject Object, const FName& BindFunctionName) __generated {
            _Inner.BindUFunction(Object, BindFunctionName, __DelegateSignature(this));
        }
        UObject GetUObject() const property __generated { ... }
        FName GetFunctionName() const property __generated { ... }
        FMyDelegate(UObject Object, const FName& BindFunctionName) __generated no_discard {
            _Inner.BindUFunction(...);    // 快捷构造
        }
        bool IsBound() const __generated { ... }
        void Clear() __generated { ... }
    };
        |
        | + 编译期描述符
        v
FAngelscriptDelegateDesc {
    DelegateName = "FMyDelegate",
    bIsMulticast = false,
    Signature, Function, ScriptType, LineNumber
}
        |
        | [Step 3] AS 编译器编译生成代码
        v
asCObjectType<FMyDelegate>  +  asCScriptFunction(Execute / ExecuteIfBound / ...)
        |
        | [Step 4] 类生成器 DoFullReload 创建 UDelegateFunction
        v
UDelegateFunction "FMyDelegate" (FunctionFlags 含 FUNC_Delegate)
        |
        | [Step 5] DeclareDelegate(UDelegateFunction*) 类型注册
        |
        +-- BoundDelegateFunctions.Add(Function)
        +-- FAngelscriptType::Register(FScriptDelegateType)
        +-- FAngelscriptBinds::ValueClass<FScriptDelegate>
        |     - Constructor / Destructor / CopyConstructor / opAssign (FUNC_TRIVIAL)
        |
        | [Step 6] DeclareDelegateOperations 操作方法注册
        |
        +-- FDelegateOps* Ops = new { SignatureFunction = Function }
        +-- IsBound / GetUObject / GetFunctionName / Clear (FUNC_TRIVIAL)
        +-- ConstructFromFunction(UObject, FName)  + PreviousBindPassScriptFunctionAsFirstParam
        +-- BindUFunction(UObject, FName)          + PreviousBindPassScriptFunctionAsFirstParam
        +-- BindDelegateEvent(false, false)
                |
                +-- new FBlueprintEventSignature {
                |       ReturnType=void, Arguments[0]=int32, ArgCount=1, FunctionName,
                |       UnrealFunction, bInitReturn=false, bZeroReturnPtr=false
                |   }
                +-- Delegate_.GenericMethod("Execute(int32) allow_discard",
                |       &CallDelegateEvent<false, true>, Sig)         <- TErrorIfUnbound=true
                +-- Delegate_.GenericMethod("ExecuteIfBound(int32) allow_discard",
                        &CallDelegateEvent<false, false>, Sig)        <- TErrorIfUnbound=false


============================================================================
  运行时调用链
============================================================================

AS 脚本: MyDelegate.BindUFunction(this, n"OnDamaged");
        |
        v
FAngelscriptDelegateOperations::BindUFunction(Delegate, AsCScriptFunction, this, "OnDamaged")
    +-- this != null  (否则 Throw)
    +-- CallFunction = this->FindFunction("OnDamaged")
    +-- Ops = (FDelegateOps*)Function->userdata
    +-- CheckAngelscriptDelegateCompatibility(Ops->SignatureFunction, CallFunction)
    |     +-- 逐参数比较 type + flags
    |     +-- AS 放宽 1: 签名 OutParm vs 实现 ReferenceParm 视同兼容
    |     +-- AS 放宽 2: 相同字节数枚举互相兼容
    +-- Delegate->BindUFunction(this, "OnDamaged")    <- UE 原生绑定


AS 脚本: MyDelegate.Execute(42);
        |
        v
CallDelegateEvent<false /*Multicast*/, true /*ErrUnbound*/>(asIScriptGeneric*)
    +-- Sig = (FBlueprintEventSignature*)Function->GetUserData()
    +-- Object = Generic->GetObject()  <- FScriptDelegate*
    +-- IsBound() ? -> 否则 Throw("Executing unbound delegate.")
    +-- Call = CurrentCall()                 <- 复用 GStoredCall 或 malloc
    +-- Call.PushArgument<false>(int32, &42)
    |     +-- ArgumentOffset 4B 对齐
    |     +-- ConstructValue + CopyValue
    |     +-- ArgumentTypes[0] = { Type=int32, Offset=0, Reference=null }
    +-- (无返回值 -> 跳过返回值处理)
    +-- Call.ExecuteDelegate(*ScriptDelegate)
          +-- ExecutePreamble
          |     +-- check(GCurrentCall == this)
          |     +-- check(IsInGameThread())
          |     +-- GCurrentCall = nullptr   <- 标记为执行中
          +-- Delegate.ProcessDelegate<UObject>(&ArgumentBuffer[0])
          |     +-- UFunction::Invoke -> 目标 UFUNCTION (OnDamaged) 执行
          +-- ExecuteCleanup
                +-- 逐参数: 引用 && !const -> CopyValue 回写 + DestructValue
                +-- ResetNonArgumentVariables
                +-- GStoredCall == null ? GStoredCall = this : delete   <- 入热备池


============================================================================
  多播 / 稀疏 关键差异
============================================================================

多播 event:
    BindDelegateEvent(true, false)
        Broadcast(...) -> CallDelegateEvent<true, false>
            -> Call.ExecuteMulticastDelegate(*ScriptDelegate)
                -> Delegate.ProcessMulticastDelegate<UObject>(&Buffer)
                    -> 遍历 InvocationList, 逐个 UFunction::Invoke

稀疏 event (USparseDelegateFunction):
    BindDelegateEvent(true, true)
        Broadcast(...) -> CallSparseDelegate
            -> FSparseDelegateStorage::ResolveSparseOwner(...)   <- 全局表查询
                -> Call.ExecuteMulticastDelegate(...)   (同多播路径)
```

---

## 十、修饰符 / API 完整速查表

### 10.1 单播 `delegate` 生成的 API

```text
struct MyDelegate (生成代码)
================================================================
默认构造               MyDelegate()
拷贝构造               MyDelegate(const MyDelegate& Other)
快捷构造（一步绑定）    MyDelegate(UObject Object, const FName& FunctionName)
赋值                   MyDelegate& opAssign(const MyDelegate& Other)
执行（未绑定抛异常）    Ret Execute(Args...) const allow_discard
执行（未绑定静默）      Ret ExecuteIfBound(Args...) const allow_discard
绑定                   void BindUFunction(UObject Object, const FName& FunctionName)
取目标对象             UObject GetUObject() const property
取目标函数名           FName GetFunctionName() const property
查询                   bool IsBound() const
解绑                   void Clear()
```

### 10.2 多播 `event` 生成的 API

```text
struct MyEvent (生成代码)
================================================================
默认构造               MyEvent()
拷贝构造               MyEvent(const MyEvent& Other)
赋值                   MyEvent& opAssign(const MyEvent& Other)
广播                   Ret Broadcast(Args...) const
添加                   void AddUFunction(const UObject Object, const FName& FunctionName)
按名解绑               void Unbind(UObject Object, const FName& FunctionName)
按对象解绑             void UnbindObject(UObject Object)
查询                   bool IsBound() const
解绑全部               void Clear()
```

### 10.3 稀疏 event API

```text
sparse event
================================================================
广播                   Ret Broadcast(Args...) const
添加                   void AddUFunction(const UObject Object, const FName& FunctionName)
按名解绑               void Unbind(UObject Object, const FName& FunctionName)
按对象解绑             void UnbindObject(UObject Object)
查询                   bool IsBound() const
解绑全部               void Clear()
不可作参数 / 返回值     ★ 编译期报错
```

### 10.4 关键限制

| 项 | 限制值 | 来源 |
|----|-------|------|
| 单次调用最大参数数 | **16** | `AS_EVENT_MAX_ARGS` (`Bind_BlueprintEvent.cpp:19`) |
| 单次调用参数总字节 | **1024** | `AS_EVENT_MAX_SIZE` (`Bind_BlueprintEvent.cpp:20`) |
| `FScriptCall` 对齐 | **64 字节**（独占 cache line） | `alignas(64)` |
| 调用线程 | **仅游戏线程** | `ExecutePreamble` 中 `check(IsInGameThread())` |
| 热备池容量 | **1 个备用实例** | `GStoredCall` 单变量 |
| 嵌套调用 | **不允许** | `ExecutePreamble` 中 `check(GCurrentCall == this)` |
| 返回值类型 | 任意（POD / 非 POD / 指针） | `bInitReturn` / `bZeroReturnPtr` 区分处理 |
| out 参数 | 通过 `__Evt_PushArgumentRef*` 标记，调用后自动回写 | 见 §1.2 / §5.4 |

---

## 十一、与 Hazelight 引擎实现的差异

### 11.1 当前项目独有的扩展

| 扩展点 | 当前项目 | Hazelight 参考 |
|--------|---------|--------------|
| `_Signature` 后缀方法族（`BindUFunction_Signature` / `ConstructFromFunction_Signature` / `AddUFunction_Signature`）| ✅ 显式 `UDelegateFunction Signature` 参数 | ❌ 仅 userdata 路径 |
| `__DelegateSignature(?& Delegate)` 全局函数 | ✅ 让生成代码不依赖 userdata | ❌ |
| `_FScriptDelegate` / `_FMulticastScriptDelegate` 内部类型 | ✅ 作为生成 struct 的 `_Inner` 字段 | 直接使用 `FScriptDelegate` 等 UE 类型 |
| `FBlueprintEventSignature` 扩展字段 | `MixinType` / `OutReferences[16]` / `OutCount` / `StaticObject`（4 个） | 只有 `ReturnType / Arguments / ArgCount / FunctionName / UnrealFunction / bInitReturn / bZeroReturnPtr` |
| 单播 `Execute` 带返回值生成 | ✅ 显式生成 `__ReturnValue` 局部变量 + `__Evt_PushArgumentRef` | ❌ 参考文档示例缺此处理 |
| `delegate` / `event` 是否带 `const` 返回值 | ✅ `ExtractReturnType` 处理 `bReturnIsConst` | ❌ |

**设计意图**：当前项目把签名信息从 `Function->userdata` **改为显式参数传递**——`__DelegateSignature(this)` 在生成的 struct 内部通过 AS 类型反射拿到本类型对应的 `UDelegateFunction`，再传给底层 `BindUFunction_Signature`。这样：

1. **热重载更稳健**：userdata 在热重载时可能失效；`__DelegateSignature(this)` 每次重新解析当前 AS 类型对应的最新 `UDelegateFunction*`
2. **更易测试**：可以脱离生成代码直接用 C++ 调用 `BindUFunction_Signature`，便于单元测试

### 11.2 当前项目暂未实现 / 未发现的特性

| 项 | 当前项目 | Hazelight 参考 | 处理决策 |
|---|---------|--------------|---------|
| `FAngelscriptDelegateDesc.bIsSparse` 字段 | ❌ | 参考文档未提及 | 稀疏委托由 UE 端 `USparseDelegateFunction` 类型决定，AS 端 `delegate/event` 关键字层不区分；两边一致，无差异 |

### 11.3 关联文档

完整差异分析风格见 `Documents/Knowledges/ZH/Diff_HazelightDefaultStatement.md` 与 `Diff_HazelightInsightsToBorrow.md`。委托相关的差异（§11.1）目前都是当前项目**领先 Hazelight** 的设计点，无需补足。

---

## 十二、关键结论速查

| 主题 | 结论 |
|------|------|
| **`delegate` / `event` 不是 AS 关键字** | 完全是预处理器层面的代码展开，AS 编译器看到的是普通 `struct` |
| **核心入口** | `AngelscriptPreprocessor.cpp:620` `ProcessDelegates` 主流程；预处理阶段触发于 `Preprocess()` 的 `ProcessDelegates(File)` 循环 |
| **代码展开模式** | `delegate` -> 含 `_FScriptDelegate _Inner` 的 struct + `Execute / ExecuteIfBound / BindUFunction / GetUObject / GetFunctionName / 快捷构造 / IsBound / Clear`；`event` -> 含 `_FMulticastScriptDelegate _Inner` 的 struct + `Broadcast / AddUFunction / Unbind / UnbindObject / IsBound / Clear` |
| **`__generated` 修饰符** | 标记函数无 AS 字节码实现，等待 C++ 端 `Bind_Delegates.cpp` 真正绑定 |
| **`__DelegateSignature(this)` 巧妙设计** | 内部用 `_Inner.BindUFunction(Object, Name, __DelegateSignature(this))`，让签名查找在每次调用时动态完成（热重载友好），不依赖 userdata |
| **核心数据载体** | `FAngelscriptDelegateDesc`（编译期）/ `FBlueprintEventSignature`（运行期 userData）/ `FScriptCall`（参数缓冲）/ `FDelegateOps`（签名校验载体） |
| **`FScriptCall` alignas(64)** | 独占 CPU cache line 防止 false sharing；全局热备池 `GCurrentCall + GStoredCall` 复用一份实例避免频繁 malloc |
| **三种委托类型** | `FScriptDelegateType`（单播） / `FMulticastScriptDelegateType`（多播） / `FScriptSparseDelegateType`（稀疏，不可作参/返） |
| **三层注册** | `DeclareDelegate`（类型）→ `DeclareDelegateOperations`（操作方法）→ `BindDelegateEvent`（Execute / Broadcast） |
| **双布尔模板调用** | `CallDelegateEvent<TIsMulticast, TErrorIfUnbound>` 模板特化消除运行时分支 |
| **签名兼容性放宽** | AS 特殊放宽：① 签名 OutParm vs 实现 ReferenceParm 视同兼容；② 相同字节数枚举互相兼容 |
| **限制** | 单次最多 16 参数，参数总字节数 ≤ 1024 字节，仅游戏线程，不可嵌套调用 |
| **out 参数自动回写** | `Bind_BlueprintEvent.cpp` 提供 `__Evt_PushArgumentRef*` 系列函数；`ExecuteCleanup` 中按 `bIsReference && !bIsConst` 自动 CopyValue 回写 |
| **稀疏委托特殊性** | 内存稀疏（8B 句柄），通过 `FSparseDelegateStorage` 全局表查找真实数据；不可作参/返 |
| **热重载策略** | 签名变化 -> 全量重载 + `OnDelegateReload` 广播；`FReloadState.ReloadDelegates` 维护 旧→新 `UDelegateFunction*` 映射；`FArchiveReplaceObjectRef` 替换所有蓝图节点引用 |
| **当前项目相对 Hazelight 增强** | `_Signature` 后缀方法族 + `__DelegateSignature(this)` 巧妙设计 + `FBlueprintEventSignature` 4 个扩展字段（Mixin / OutReferences / OutCount / StaticObject）+ 带返回值的 `Execute` 完整生成 |
| **错误集中点** | ① 未绑定调用 `Execute` -> `Throw("Executing unbound delegate.")`；② `BindUFunction` 目标 Object null -> 抛异常；③ 签名不兼容 -> 抛 `"Specified function is not compatible..."`；④ 稀疏委托作参/返 -> 编译期 ScriptCompileError；⑤ 单次调用超 16 参或 1024 字节 -> `check` 断言 |

---

## 十三、关联文档

- 实现原理（兄弟章节）：
  - `Documents/Knowledges/ZH/Syntax_UFUNCTION.md` — UFUNCTION 修饰符（`BindDelegateEvent` 复用机制；`BlueprintEvent` 包装函数同源）
  - `Documents/Knowledges/ZH/Syntax_DefaultStatement.md` — `default` 语句（共享对象构造时序）
  - `Documents/Knowledges/ZH/Syntax_UPROPERTY.md` — UPROPERTY 修饰符（共享 `FMacro` 流水线）
- 差异分析：
  - `Documents/Knowledges/ZH/Diff_HazelightDefaultStatement.md` — 架构性差异背景
  - `Documents/Knowledges/ZH/Diff_HazelightInsightsToBorrow.md` — Hazelight 可借鉴设计点全插件汇总
- 架构与运行时（待写）：
  - `Documents/Knowledges/ZH/Type_FunctionCaller.md` — `UASFunction` 函数调用桥
  - `Documents/Knowledges/ZH/RT_HotReload.md` — 热重载链路全景

---

## 十四、修订记录

| 版本 | 日期 | 内容 |
|------|------|------|
| v1.0 | 2026-04-28 | 首版：基于 `Temp/Temp_event/event.md` 五轮迭代分析 + 当前项目实际源码核对完整产出。覆盖：① 预处理器代码展开（`ProcessDelegates` 完整 9 步流程，含单播/多播差异化代码生成）；② 核心数据结构（`FAngelscriptDelegateDesc` / `FBlueprintEventSignature` / `FScriptCall alignas(64)` / `FDelegateOps`）；③ 三种 AS 类型描述器（`FScriptDelegateType` / `FMulticastScriptDelegateType` / `FScriptSparseDelegateType`）；④ 三层注册（`DeclareDelegate` 类型 → `DeclareDelegateOperations` 操作方法 → `BindDelegateEvent` Execute/Broadcast）；⑤ 运行时双布尔模板调用 `CallDelegateEvent<TIsMulticast, TErrorIfUnbound>`；⑥ `BindUFunction` 签名兼容性校验（含 AS 特殊放宽：OutParm/ReferenceParm 视同 + 同字节数枚举兼容）；⑦ 稀疏委托特殊机制（不可作参/返、`FSparseDelegateStorage` 全局表）；⑧ 热重载（`FDelegateData` + `OnDelegateReload` 广播 + `FReloadState.ReloadDelegates` 映射）。已识别并标注当前项目相对 Hazelight 的扩展：① `_Signature` 后缀方法族 + `__DelegateSignature(this)` 巧妙设计（让签名查找不依赖 userdata，热重载更稳健）；② `FBlueprintEventSignature` 4 个扩展字段（`MixinType / OutReferences / OutCount / StaticObject`）；③ 单播 `Execute` 完整支持返回值（`__ReturnValue` 局部变量 + `__Evt_PushArgumentRef`）；④ `delegate/event` 返回值的 `const` 修饰符处理。所有 ASCII 图遵循纯 ASCII 风格（与 `Syntax_DefaultStatement.md` v1.3 / `Syntax_UPROPERTY.md` v1.3 / `Syntax_UFUNCTION.md` v1.1 统一）。 |
