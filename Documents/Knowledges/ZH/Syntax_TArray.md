# Syntax_TArray — `TArray<T>` 动态数组实现原理

> **所属前缀**: Syntax_（容器类型族）
> **关注层面**: 语法机制与实现原理（非用户使用指南）
> **关键源码**:
> `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_TArray.cpp`
> · `Binds/Bind_TArray.h`
> · `Binds/Bind_TArray_Functions.h`
> · `Binds/Bind_TArray_Structs.h`
> · `ThirdParty/angelscript/source/as_compiler.cpp`（`opFor*` 展开）
> · `Containers/ScriptArray.h`（UE 自带的非模板桥接对象）
> **关联文档**:
> `Documents/Knowledges/ZH/Syntax_UPROPERTY.md` §`FProperty` 创建链路（`FArrayProperty.Inner` 共享同一套 `CreateProperty`）
> · `Documents/Knowledges/ZH/Type_BindSystem.md`（`FAngelscriptType` / `FAngelscriptTypeUsage` 类型系统）
> · `Documents/Knowledges/ZH/Syntax_TMap.md` / `Syntax_TSet.md`（兄弟容器，共享 GenericContainer 优化路径）

---

## 概览：单类型的"双重身份"

`TArray<T>` 在当前插件里同时承担三种角色，这三者**共享同一个 `FScriptArray` 内存布局**，靠 `FAngelscriptArrayType` 与 `FArrayOperations` 在不同入口上做胶合：

```text
[角色 A] AS 脚本中的 "值类型容器"
    形如:   TArray<int> Numbers;   Numbers.Add(42);
    内存:   栈上 / UScriptStruct 字段中的 FScriptArray (3 个指针: Data + ArrayNum + ArrayMax)
    来源:   Bind_TArray.cpp 末尾 ValueClass<FScriptArray>("TArray<class T>")

[角色 B] UE 反射系统中的 "FArrayProperty 字段"
    形如:   UPROPERTY() TArray<int32> Numbers;  // .as 与 C++ 共用
    内存:   UObject/UStruct 内的 TArray<T>, 通过 FArrayProperty.Inner 描述元素类型
    桥接:   FAngelscriptArrayType::CreateProperty / MatchesProperty / EmitReferenceInfo

[角色 C] StaticJIT 的 "模板特化路径"
    入口:   SCRIPT_NATIVE_TEMPLATED_CALL_*  +  Bind_TArray_Functions.h 的 *_Template<T>
    意义:   对已知元素类型 T 的 hot path, 走原生 TArray<T> 实现而非 FArrayOperations 通路
```

三者之间的关键洞察：

```text
FScriptArray 与 TArray<T> 二进制兼容
  -> sizeof(FScriptArray) == sizeof(TArray<T>) == 3 个指针/计数槽
  -> 通过 reinterpret_cast<TArray<T>*>(&FScriptArray) 即可拿到原生数组视图
  -> StaticJIT 利用这一点把通用 FArrayOperations 调用直接降级为 TArray<T> 的内联调用
```

### 4 阶段管线总览

```text
预处理器层 (Preprocessor)         AS 编译器层 (ThirdParty/angelscript)
============================       ====================================
不感知 TArray:                       看到普通模板类型: TArray<T>
   把 .as 源码原样交给编译器           - 模板模板参数实例化 (asCObjectType)
                                     - TemplateCallback 校验 Subtype
        |                            | (调用 ValidateArrayOperations 创建 FArrayOperations
        |                            |  并挂到 asCObjectType::plainUserData)
        |                            |
        |                            v
        |                          编译方法调用 -> 字节码
        |
        |     for (auto Item : Arr) 的展开 (as_compiler.cpp:5665)
        |       -> 改写为 Arr.opForBegin / opForEnd / opForNext / opForValue
        |
        v
运行时层 (Runtime, Bind_TArray.cpp)
====================================
[1] FAngelscriptArrayType
    - 实现 FAngelscriptType 接口 (CreateProperty/CopyValue/Construct/Destruct/...)
    - 让 TArray<T> 既能作为脚本变量, 也能映射到 UE FArrayProperty
    - 提供 GC Schema (StructArray / ReferenceArray)

[2] FArrayOperations
    - 通用元素操作集 (Add/Remove/Insert/Sort/...)
    - 关键: 元素的 Construct/Destruct/Copy/Compare 通过 FAngelscriptTypeUsage 多态分派
    - 元素类型相关的 size / alignment / copy-trivial 信息缓存在 plainUserData

[3] FArrayIterator + opFor* 桥
    - C++ 端: FArrayIterator { FScriptArray* Array; uint32 Stride; uint32 Index; bool bCanProceed; }
    - AS 端: TArrayIterator<T> / TArrayConstIterator<T>
    - opForBegin / opForEnd / opForNext / opForValue 让 AS 的 for 语法可遍历
    - AS_ITERATOR_DEBUGGING 全局表防御 "迭代中改写"

[4] StaticJIT 直通 (可选)
    - SCRIPT_NATIVE_TEMPLATED_CALL_* 宏在 StaticJITBinds.h 展开为 BindXxx
    - PrecompiledData / 字节码识别已知元素类型 -> 生成原生 TArray<T> 调用
    - 关闭 JIT 时宏退化为空, 全部回退到 FArrayOperations 通用路径
```

### 核心特性速览

| 特性 | 语法 | 实现策略 |
|------|------|---------|
| **声明** | `TArray<int> Numbers;` | `ValueClass<FScriptArray>` + `RegisterDefaultArrayType` |
| **下标** | `Numbers[0]` | `T& opIndex(int)` + 越界 `Throw` |
| **赋值** | `A = B;` | `OpAssign` 按元素 `CopyValue` / Memcpy 兜底 |
| **比较** | `A == B` | `OpEquals` 按元素 `IsValueEqual`，元素无 `opEquals` 时抛错 |
| **追加** | `Add` / `Append` / `AddUnique` / `Insert` | `FArrayOperations` 系列 + 别名检测 |
| **删除** | `Remove` / `RemoveAt` / `RemoveSwap` / 等 6 种 | 调 `IsValueEqual` + `Remove` 内置 + Swap 优化 |
| **范围 for** | `for (auto V : Arr)` | `opForBegin/End/Next/Value/Key` 五件套展开 |
| **手工迭代** | `TArrayIterator<T> It = Arr.Iterator()` | `FArrayIterator` 值类型 + `Proceed/CanProceed` |
| **排序** | `Arr.Sort(true)` | `Algo::Sort` + 元素 `opCmp` 反射查找 |
| **GC** | `TArray<UObject>` 自动追踪 | `EmitReferenceInfo` 生成 `ReferenceArray/StructArray` Schema |
| **嵌套禁止** | `TArray<TArray<int>>` ✗ | `CanBeTemplateSubType()` 返回 `false` 拦截 |
| **FProperty 桥接** | `UPROPERTY() TArray<int>` | `CreateProperty` 创建 `FArrayProperty` + `Inner` 递归 |

---

## 一、绑定入口：`ValueClass<FScriptArray>` 与模板类型登记

**源码所在**: `Bind_TArray.cpp:1381` 的 `Bind_TArray` 全局静态绑定块。

### 1.1 类型注册框架

```cpp
AS_FORCE_LINK const FAngelscriptBinds::FBind Bind_TArray(FAngelscriptBinds::EOrder::Early, []
{
    FBindFlags Flags;
    Flags.bTemplate = true;                                  // 声明这是 AS 模板类型
    Flags.TemplateType = "<T>";
    Flags.ExtraFlags = asOBJ_TEMPLATE_SUBTYPE_COVARIANT;     // 允许子类型协变 (TArray<USub> 可赋值给 TArray<UBase>)

    auto TArray_ = FAngelscriptBinds::ValueClass<FScriptArray>("TArray<class T>", Flags);
    TArray_.Constructor("void f()", FUNC_TRIVIAL(FArrayOperations::Construct));
    FAngelscriptType::SetArrayTemplateTypeInfo(TArray_.GetTypeInfo());
    FAngelscriptEngine::Get().Engine->RegisterDefaultArrayType("TArray<T>");
    ...
});
```

四个关键调用各司其职：

| 调用 | 作用 |
|------|------|
| `Flags.bTemplate = true` + `TemplateType = "<T>"` | 告诉 AS：**这是单参模板类**，而不是普通值类型 |
| `asOBJ_TEMPLATE_SUBTYPE_COVARIANT` | 启用**子类型协变**：`TArray<UPlayer>` 可隐式视作 `TArray<UActor>` 的子类型 |
| `SetArrayTemplateTypeInfo(...)` | 把 `TArray` 的 `asITypeInfo` 缓存到 `FAngelscriptType` 静态表，供 `Type_BindSystem` 反向查找 |
| `RegisterDefaultArrayType("TArray<T>")` | 让 AS 的 `array<T>`、字面量 `{...}` 等内建语法**默认实例化为 `TArray<T>`** 而非 vanilla `array<T>` |

### 1.2 排序时机：`EOrder::Early`

`Bind_TArray` 走 `EOrder::Early` 而不是默认顺序。原因：

- 大量普通绑定（`Bind_AActor.cpp` 等）在方法签名里直接用 `TArray<...>`；
- AS 编译这些签名时需要 `TArray<T>` 模板已注册；
- 因此 `TArray` 必须在所有 UE 绑定之前完成注册。

`TMap` / `TSet` / `TOptional` 等其他容器同样走 `EOrder::Early`。

### 1.3 `TemplateCallback` —— 元素类型校验

```cpp
TArray_.TemplateCallback("bool f(int&in Type, int&out ErrorMessage)",
[](asITypeInfo* TemplateType, asCString* ErrorMessage) -> bool
{
    // Allow generic template subtypes (T 还是抽象 T 时直接放行)
    if (TemplateType->GetSubType(0) && (TemplateType->GetSubType(0)->GetFlags() & asOBJ_TEMPLATE_SUBTYPE) != 0)
        return true;

    return ValidateArrayOperations(TemplateType, ErrorMessage) != nullptr;
});
```

`TemplateCallback` 在每次 AS 编译器**首次实例化**一个 `TArray<具体类型>` 时被调用一次，作为"是否允许这个实例化"的守门员：

```text
TArray<int>     -> ValidateArrayOperations 创建 FArrayOperations -> 通过
TArray<UActor>  -> ValidateArrayOperations 创建 FArrayOperations -> 通过
TArray<TArray<int>>
  -> ValidateArrayOperations 内 Type.CanBeTemplateSubType() 返回 false
  -> ErrorMessage = "Containers cannot be nested in other containers"
  -> 编译期报错
```

`FAngelscriptArrayType::CanBeTemplateSubType()` 显式 `return false;` —— 这正是嵌套容器被拦截的根因。

---

## 二、`FArrayOperations` —— 元素类型相关的操作缓存

**源码所在**: `Bind_TArray_Functions.h:17-44`、`Bind_TArray.cpp:1769-1830`（`ValidateArrayOperations`）。

### 2.1 数据结构

```cpp
struct ANGELSCRIPTRUNTIME_API FArrayOperations
{
    int32 NumBytesPerElement;           // 元素字节数 (sizeof T)
    int32 Alignment;                    // 元素对齐 (alignof T)
    bool bValid = false;
    FAngelscriptTypeUsage Type;         // 元素类型描述符 (含 Construct/Copy/Destruct/Compare 调度)
    asCScriptFunction* CompareFunction; // 元素 opCmp 方法 (用于 Sort)

    bool bNeedConstruct;                // 元素构造非平凡
    bool bNeedDestruct;                 // 元素析构非平凡
    bool bNeedCopy;                     // 元素拷贝非平凡 (POD vs non-POD)
    bool bIsObjectPointer;              // 元素是 UObject* 指针

    // 给定元素索引, 计算地址
    FORCEINLINE void* Get(FScriptArray& Arr, int32 Index)
    {
        return (void*)((SIZE_T)Arr.GetData() + (((SIZE_T)Index) * ((SIZE_T)NumBytesPerElement)));
    }

    // 从 asCObjectType 的 userdata 槽取出 (TemplateCallback 阶段挂上去)
    FORCEINLINE static FArrayOperations* GetArrayOperations(asCObjectType* Meta)
    {
        return (FArrayOperations*)Meta->plainUserData;
    }
};
```

### 2.2 `ValidateArrayOperations` —— 一次构造、终生复用

```cpp
FArrayOperations* ValidateArrayOperations(asITypeInfo* TemplateType, asCString* ErrorMessage)
{
    FArrayOperations* Ops = (FArrayOperations*)TemplateType->GetUserData();
    if (Ops != nullptr)
        return Ops->bValid ? Ops : nullptr;             // 已存在 -> 复用

    int32 SubTypeId = TemplateType->GetSubTypeId(0);
    auto Type = FAngelscriptTypeUsage::FromTypeId(SubTypeId);

    if (!Type.CanBeTemplateSubType())                  // [拦截] 嵌套容器
        { *ErrorMessage = "Containers cannot be nested in other containers"; return nullptr; }

    Ops = new FArrayOperations();
    TemplateType->SetUserData(Ops);                    // 挂到 plainUserData

    if (!Type.IsValid()) { *ErrorMessage = "Subtype could not be found"; return nullptr; }
    if (!(Type.CanConstruct() && Type.CanDestruct() && Type.CanCopy()))
        { *ErrorMessage = "Subtype cannot be constructed or copied"; return nullptr; }

    Ops->NumBytesPerElement = Type.GetValueSize();
    Ops->Alignment          = Type.GetValueAlignment();
    Ops->Type               = Type;
    Ops->bNeedConstruct     = Type.NeedConstruct();
    Ops->bIsObjectPointer   = Type.IsObjectPointer();
    Ops->bNeedDestruct      = Type.NeedDestruct();
    Ops->bNeedCopy          = Type.NeedCopy();
    Ops->bValid             = Ops->NumBytesPerElement > 0;

    if (asITypeInfo* SubType = TemplateType->GetSubType())
    {
        Ops->CompareFunction = GetCompareFunction((asCTypeInfo*)SubType, Type.IsObjectPointer());
        if (Ops->CompareFunction != nullptr)
            Ops->CompareFunction->isInUse = true;       // 防止 GC 把 opCmp 释放
    }
    return Ops;
}
```

关键设计：

- **只构造一次**：`FArrayOperations` 与 `asITypeInfo` 一对一，被永久挂在 `userData` 槽，所有后续 `Add/Remove/Sort` 都能 O(1) 取回。
- **元素类型契约**：`CanConstruct/CanDestruct/CanCopy` 三个能力**必须全部为真**，否则该 `TArray<T>` 实例化失败。
- **可选 `opCmp`**：用于 `Sort()`。元素没有 `opCmp` 时仍可使用数组，只是排序在运行时报错。

### 2.3 三个关键 bool 字段的意义

| 字段 | 意义 | 走的路径 |
|------|------|----------|
| `bNeedCopy = false`（POD）| 元素是 `int32`、`FVector` 等 trivially-copyable 类型 | `Add/Append` 走 `FMemory::Memcpy`，跳过 `CopyValue` 调用循环 |
| `bNeedConstruct = false` | 元素构造平凡 | `Add` 后跳过 `ConstructValue`（已被新分配内存自带的零初始化覆盖） |
| `bNeedDestruct = false` | 元素析构平凡 | `Empty/Reset/RemoveAt` 跳过 `DestructValue` 循环 |

这三个 bool 让**最常见的 `TArray<int>` / `TArray<FVector>` 走纯 memcpy 路径**——在 hot path 上直接达到原生 `TArray<T>` 性能。

---

## 三、`FAngelscriptArrayType` —— UE 反射系统桥接

**源码所在**: `Bind_TArray.cpp:74-517`。

### 3.1 接口职责映射

`FAngelscriptArrayType` 实现 `FAngelscriptType` 抽象基类，把 `TArray<T>` 接进 UE 反射体系：

| 接口 | 实现 | 作用 |
|------|------|------|
| `GetAngelscriptTypeName` | 返回 `"TArray"` | 给 dump / 错误信息用 |
| `CanCreateProperty` | 检查 `Usage.SubTypes.Num() == 1` 且子类型可建 property | 决定该 `TArray<T>` 能否进入反射 |
| `CreateProperty` | `new FArrayProperty` + `Inner = SubType.CreateProperty(...)` | UPROPERTY 字段创建 |
| `MatchesProperty` | 检查目标是 `FArrayProperty` 且 `Inner` 类型匹配 | 反射调用参数匹配 |
| `HasReferences` / `EmitReferenceInfo` | 委托给元素类型 | GC 引用追踪 |
| `CanCopy/NeedCopy/CopyValue` | 按元素类型分派；POD 走 memcpy | 值赋值 / 函数返回 |
| `CanConstruct/ConstructValue` | placement-new `FScriptArray()` | 字段初始化 |
| `CanDestruct/DestructValue` | 元素析构后 `~FScriptArray()` | 字段销毁 |
| `GetValueSize/Alignment` | 返回 `sizeof(FScriptArray) / alignof(FScriptArray)` | 类生成阶段确定栈/字段布局 |
| `SetArgument/GetReturnValue` | 用 `StepCompiledIn<FArrayProperty>` 在函数调用栈上构造/接管 | 与 UFunction 互调 |
| `CanCompare/IsValueEqual` | 委托给元素类型 | `==` 运算符 |
| `CreateDebugValue/GetDebuggerScope/GetDebuggerMember` | 暴露 `[i]` / `Num` 给调试器 | DAP 协议变量面板 |
| `GetCppForm` | 输出 `TArray<<元素 CppType>>` | StaticJIT 生成器/Codegen 用的 C++ 字符串 |
| `IsParamForcedOutParam` | `return true` | `TArray` 参数永远走"输出参数"语义 |
| `CanBeTemplateSubType` | `return false` | **禁止嵌套容器**（见 §1.3） |

### 3.2 `IsParamForcedOutParam = true` 的含义

```cpp
bool IsParamForcedOutParam() const override { return true; }
```

这条规则导致：

- 函数参数 `TArray<int> Arr` 在 AS 端等同于 `TArray<int>& out Arr`；
- 永远不会发生**整数组按值传递**（昂贵）；
- 但允许函数通过参数返回数组（无需引用语法糖）。

这是性能与易用性的折中——保留"看起来像值"的语法，但运行时强制走引用。

### 3.3 GC Schema：`EmitReferenceInfo`

```cpp
void FAngelscriptArrayType::EmitReferenceInfo(const FAngelscriptTypeUsage& Usage, FGCReferenceParams& Params) const
{
    int32 ElementSize = Usage.SubTypes[0].Type->GetValueSize(Usage.SubTypes[0]);
    UE::GC::FSchemaBuilder InnerSchema(ElementSize);

    if (Usage.SubTypes[0].Type->IsObjectPointer())
    {
        // TArray<UObject*> -> EMemberType::ReferenceArray
        Params.Schema->Add(UE::GC::DeclareMember(Params.Names.Top(), Params.AtOffset,
            UE::GC::EMemberType::ReferenceArray, InnerSchema.Build()));
    }
    else
    {
        // TArray<FStructWithObjectRefs> -> 递归构造 InnerSchema -> StructArray
        FGCReferenceParams InnerParams = Params;
        InnerParams.Schema = &InnerSchema;
        InnerParams.AtOffset = 0;
        Usage.SubTypes[0].EmitReferenceInfo(InnerParams);
        Params.Schema->Add(UE::GC::DeclareMember(Params.Names.Top(), Params.AtOffset,
            UE::GC::EMemberType::StructArray, InnerSchema.Build()));
    }
}
```

两条互斥分支正好对应 UE 5 GC `FSchemaBuilder` 的两种数组成员语义：

| 元素 | Schema 类型 | 含义 |
|------|------------|------|
| `UObject*` 指针 | `ReferenceArray` | GC 直接遍历每个槽，`MarkAsReachable` |
| 含引用的 struct | `StructArray` + 内嵌 sub-Schema | GC 进入每个元素，按 sub-Schema 继续遍历 |
| 纯 POD (`int32`、`FVector` 等) | `HasReferences` 返回 false → 不调 `EmitReferenceInfo` | GC 完全跳过 |

---

## 四、关键操作实现剖析

### 4.1 `Add` —— 写时构造 + 别名检测

```cpp
void FArrayOperations::Add(FScriptArray& Arr, asCObjectType* Meta, void* Value)
{
#if AS_ITERATOR_DEBUGGING
    if (!CheckArrayIteratorDebug(Arr)) return;            // 防御: 迭代中改写
#endif

    auto* Ops = GetArrayOperations(Meta);

    // 别名检测: 防止 Arr.Add(Arr[0]) 这类 reallocate 后悬空引用
    if (!CheckArrayValueDoesNotAliasStorage(Arr, Value, Ops,
            "Cannot Add an element from the same array by reference. Copy it to a temporary first."))
        return;

#if AS_REFERENCE_DEBUGGING
    InvalidateReferencesToArray(Arr, Ops);                // 让所有指向旧 buffer 的 ASRef 失效
#endif

    int32 AddIndex = Arr.Add(1, Ops->NumBytesPerElement, Ops->Alignment);
    void* DestinationAddr = Ops->Get(Arr, AddIndex);
    if (Ops->bNeedConstruct)
        Ops->Type.ConstructValue(DestinationAddr);

    if (Ops->bNeedCopy)
        Ops->Type.CopyValue(Value, DestinationAddr);
    else
        FMemory::Memcpy(DestinationAddr, Value, Ops->NumBytesPerElement);
}
```

三个独立保护层：

1. **迭代守卫** (`AS_ITERATOR_DEBUGGING`): 全局表 `GArraysBeingIterated` 记录正在被 `for` 循环遍历的数组指针，写操作触发 `Throw`。
2. **别名守卫** (`CheckArrayValueDoesNotAliasStorage`): 校验 `Value` 地址不在 `[Arr.GetData(), Arr.GetData() + AllocatedSize)` 区间。`Arr.Add(Arr[0])` 这类用法会先扩容（旧地址失效）再拷贝（拷贝悬空指针）—— 必须在调用前显式拷贝到临时变量。
3. **引用失效** (`AS_REFERENCE_DEBUGGING`): 调试构建里把所有指向当前 buffer 的 AS reference 标记为无效，下次解引用时报错。

### 4.2 `OpAssign` —— 三段式自适应

```cpp
FScriptArray& FArrayOperations::OpAssign(FScriptArray& Dst, asCObjectType* Meta, FScriptArray& Src)
{
    auto* Ops = GetArrayOperations(Meta);
    int32 ElementSize = Ops->NumBytesPerElement;
    int32 SourceNum = Src.Num();
    int32 DestNum   = Dst.Num();

    if (!Ops->bNeedCopy)
    {
        // [Path A] 完全 POD: 直接 memcpy
        if (SourceNum > DestNum) Dst.Add   (SourceNum - DestNum, ElementSize, Ops->Alignment);
        else if (DestNum > SourceNum) Dst.Remove(SourceNum, DestNum - SourceNum, ElementSize, Ops->Alignment);
        FMemory::Memcpy(Dst.GetData(), Src.GetData(), SourceNum * ElementSize);
        return Dst;
    }

    // [Path B] 非 POD: 三段处理
    if (SourceNum > DestNum)
    {
        Dst.Add(SourceNum - DestNum, ElementSize, Ops->Alignment);
        if (Ops->bNeedConstruct)
            for (int32 i = DestNum; i < SourceNum; ++i)               // 新增槽 -> 构造
                Ops->Type.ConstructValue(Ops->Get(Dst, i));
    }
    else if (DestNum > SourceNum)
    {
        if (Ops->bNeedDestruct)
            for (int32 i = SourceNum; i < DestNum; ++i)               // 多余槽 -> 析构
                Ops->Type.DestructValue(Ops->Get(Dst, i));
        Dst.Remove(SourceNum, DestNum - SourceNum, ElementSize, Ops->Alignment);
    }

    for (int32 i = 0; i < SourceNum; ++i)                              // 公共区 -> 拷贝
        Ops->Type.CopyValue(Ops->Get(Src, i), Ops->Get(Dst, i));
    return Dst;
}
```

关键点：

- **POD 快路径**与**非 POD 三段路径**共享同一段 `Add/Remove` 调用，但 POD 跳过 `ConstructValue/CopyValue` 循环。
- 三段（构造新增 / 析构多余 / 拷贝公共）顺序固定：先调整长度、再补齐元素生命周期、最后内容覆盖。
- 注意 **不是 move 语义**——`OpAssign` 永远拷贝；要 move 必须显式调 `MoveAssignFrom(...)`（§4.5）。

### 4.3 删除家族：6 个变体

| 方法 | 行为 | 复杂度 | 内部实现 |
|------|------|--------|----------|
| `RemoveAt(i)` | 按索引删除，保持顺序 | O(N)（后段 memcpy）| `Arr.Remove(Index, 1, ...)` |
| `RemoveAtSwap(i)` | 按索引删除，与末尾换位 | O(1) | `Memcpy(Get(Arr,i), Get(Arr, last))` + `Arr.Remove(last, 1)` |
| `Remove(value)` | 删除**所有**等于 `value` 的元素，保持顺序 | O(N²) 最坏 | 反向遍历 + `IsValueEqual` + `Arr.Remove(i, 1)` |
| `RemoveSingle(value)` | 删除**第一个**等于 `value` 的元素，保持顺序 | O(N) | 正向遍历首匹配 + `Arr.Remove(i, 1)` |
| `RemoveSwap(value)` | 删除所有等值，与末尾换位 | O(N)（每次匹配 O(1)）| 正向遍历 + `Memcpy` + `Arr.Remove(last, 1)` |
| `RemoveSingleSwap(value)` | 删除第一个等值，与末尾换位 | O(N) 最坏 | 正向遍历首匹配 + `Memcpy` + `Arr.Remove(last, 1)` |

**全部按值删除变体**（后四个）都先校验 `Ops->Type.CanCompare()`，若元素类型缺 `opEquals` 直接 `Throw`。

### 4.4 `Sort` —— 双路径排序

```cpp
void FArrayOperations::Sort(FScriptArray& Arr, asCObjectType* Meta, bool bDescendingOrder)
{
    auto* Ops = GetArrayOperations(Meta);
    const int32 Size = Ops->NumBytesPerElement;

    if (Ops->CompareFunction != nullptr)
    {
        // [Path A] 元素有 opCmp -> AS 调用版本
        FScriptArraySorter<> Sorter(Ops, bDescendingOrder);
        if (Ops->bIsObjectPointer)
            AngelscriptSort::QuickSort<...DynamicCompareFunction_ObjectPointer>(...);
        else
            AngelscriptSort::QuickSort<...DynamicCompareFunction_NonObjectPointer>(...);
        return;
    }

    if (!Ops->Type.IsOrdered())
    {
        // [Path B] 元素无 opCmp 也无内置 ordering -> 抛错
        const FString Error = FString::Format(
            TEXT("Array element type not sortable. To sort TArray<{0}>, int opCmp({1}) const needs to be implemented."),
            { ... });
        FAngelscriptEngine::Throw(TCHAR_TO_ANSI(*Error));
        return;
    }

    // [Path C] 元素有内置 ordering (int/float/FString) -> 按 size 选模板特化
    if      (Size == 1)  FScriptArraySorter<1>::Sort(Ops, Arr, bDescendingOrder);
    else if (Size == 2)  FScriptArraySorter<2>::Sort(Ops, Arr, bDescendingOrder);
    else if (Size == 4)  FScriptArraySorter<4>::Sort(Ops, Arr, bDescendingOrder);
    else if (Size == 8)  FScriptArraySorter<8>::Sort(Ops, Arr, bDescendingOrder);
    else if (Size == 12) FScriptArraySorter<12>::Sort(Ops, Arr, bDescendingOrder);
    else if (Size == 16) FScriptArraySorter<16>::Sort(Ops, Arr, bDescendingOrder);
    else                 FAngelscriptEngine::Throw("Array element is too large to sort.");
}
```

三层兜底：

1. **AS `opCmp` 优先**：脚本类型自定义比较（含 UObject 指针的 null 安全处理）。
2. **AS 内置可排序类型**：`int`、`float`、`FString` 等通过 `FAngelscriptType::CompareOrder` 直接 memcpy-friendly 排序，按 1/2/4/8/12/16 字节模板特化（覆盖所有常见基础类型 + `FVector` / `FQuat` 等）。
3. **不能排序的类型**：抛出**人类可读**的 AS 错误，告诉用户应该实现什么签名。

> 注意 `Size == 12 / 16` 特化：恰好对应 `FVector(3 × float)` 与 `FQuat / FVector4(4 × float)`，让游戏开发最常用的数学类型排序也走原生路径。

### 4.5 别名 / 自交互防御一览

| 场景 | 防御位置 | 报错语句 |
|------|---------|----------|
| `Arr.Add(Arr[i])`（同源添加）| `Add` 入口 `CheckArrayValueDoesNotAliasStorage` | `"Cannot Add an element from the same array by reference. Copy it to a temporary first."` |
| `Arr.Insert(Arr[i], 0)` | `Insert` 入口同样校验 | 同上 |
| `Arr.MoveAssignFrom(Arr)` | `MoveAssignFrom` 比较 `&Arr == &Other` | `"Cannot move assign an array into itself."` |
| `Arr.Copy(Arr, ...)` | `Copy` 比较 `&SourceArray == &Arr` | `"Cannot copy an array into itself."` |
| 越界 `Arr[i]` / `RemoveAt(i)` / `Insert(.., i)` | 各方法入口 `IsValidIndex` | `"Array index out of bounds."` |
| `Sort` 元素无序 | `Sort` 入口 `IsOrdered` 检查 | `"Array element type not sortable. To sort TArray<X>, int opCmp(...) needs to be implemented."` |
| `Remove(value)` 元素无 `opEquals` | `Remove*` 入口 `CanCompare` | `"Cannot Remove, array element type cannot be compared for equality"` |
| 迭代中改写（仅 `AS_ITERATOR_DEBUGGING` build）| 各写操作入口 `CheckArrayIteratorDebug` | `"TArray is being modified during for loop iteration"` |

---

## 五、`for` 范围循环：`opForBegin/End/Next/Value/Key` 五件套

**源码所在**:
- AS 编译器展开：`ThirdParty/angelscript/source/as_compiler.cpp:5665-5673`
- C++ 端绑定：`Bind_TArray.cpp:1536-1580`

### 5.1 编译器侧的展开

AS 编译器把 `for (auto Item : Arr) { ... }` **预先生成等价的 C 风格 for**：

```text
源码:
    for (auto Item : Arr) { Process(Item); }

编译器在前端改写为:
    int __it = Arr.opForBegin();
    while (!Arr.opForEnd(__it))
    {
        auto Item = Arr.opForValue(__it);     // 取值 (& 风格根据 const 决定)
        Process(Item);
        Arr.opForNext(__it);
    }
```

> 关键洞察：AS **不需要** STL/UE 风格的 `begin()/end()` 迭代器对象——只要容器实现五个方法即可。这套契约**通用**于 `TArray`/`TMap`/`TSet`/`TOptional` 全部容器，靠每个容器的 `opForKey` 决定键语义（数组 = 索引，Map = key 拷贝，Set = element）。

### 5.2 `TArray` 的五件套实现

```cpp
// 起点: 数组非空时返回 0, 否则 -1 表示"立刻结束"
TArray_.Method("int opForBegin()",       [](FScriptArray& A) -> int32 { return A.Num() > 0 ? 0 : -1; });
TArray_.Method("int opForBegin() const", [](FScriptArray& A) -> int32 { return A.Num() > 0 ? 0 : -1; });

// 终点: Iterator == -1 时停止
TArray_.Method("bool opForEnd(const int Iterator) const",
    [](FScriptArray&, int32 It) -> bool { return It == -1; });

// 步进: 自增, 越界自动转为 -1
TArray_.Method("void opForNext(int&inout Iterator)", [](FScriptArray& A, int32& It)
{
    if (It == -1) return;
    const int32 Next = It + 1;
    It = Next < A.Num() ? Next : -1;
});

// 取值: 用 FArrayOperations 取真实地址 (按引用传给循环体)
TArray_.Method("T& opForValue(const int Iterator)", [](FScriptArray& A, asCObjectType* Meta, int32 It) -> void*
{
    auto* Ops = FArrayOperations::GetArrayOperations(Meta);
    if (!A.IsValidIndex(It)) { FAngelscriptEngine::Throw("Iterator out of bounds."); return nullptr; }
    return Ops->Get(A, It);
});
TArray_.Method("const T& opForValue(const int Iterator) const", ...);   // const 重载

// 键: 直接返回索引
TArray_.Method("int opForKey(const int Iterator) const",
    [](FScriptArray&, int32 It) -> int32 { return It; });
```

### 5.3 用法对照

```angelscript
// 普通遍历 (取值)
for (auto Value : Numbers)
    Print(f"{Value}");

// 同时拿索引和值 (key, value 形式)
for (auto Index, Value : Numbers)
    Print(f"[{Index}] {Value}");

// const 遍历 (Numbers 是 const TArray&)
for (auto Value : ConstNumbers)        // 自动选 const 重载
    Print(f"{Value}");
```

### 5.4 与 `TArrayIterator<T>` 的关系

除了 for 循环，还可以**显式**拿迭代器（`Bind_TArray.cpp:1349-1380, 1606-1640`）：

```angelscript
TArrayIterator<int> It = Numbers.Iterator();
while (It.CanProceed)
{
    int Value = It.Proceed();   // 返回当前值并步进
    Print(f"{Value}");
}
```

C++ 端 `FArrayIterator` 是值类型（`{ FScriptArray*; uint32 Stride; uint32 Index; bool bCanProceed }`），其 `Proceed()` 同时承担"取当前值 + 步进"两个职责。这个手工接口主要用在**需要早退/跳跃**的场景；对一般遍历 `for` 写法更紧凑。

### 5.5 迭代守卫 `AS_ITERATOR_DEBUGGING`

```cpp
#if AS_ITERATOR_DEBUGGING
thread_local static TArray<void*, TInlineAllocator<16>> GArraysBeingIterated;
#endif
```

每次 `FArrayIterator` 创建/拷贝/销毁时 `Add/Remove(Array)`；每次 `Add/Insert/Remove*/Empty/Sort/...` 入口 `Contains` 检查 → 命中即抛错 `"TArray is being modified during for loop iteration"`。

注意：

- 该机制仅在**调试构建**启用（`AS_ITERATOR_DEBUGGING` 宏）；
- 用 `TInlineAllocator<16>` 避免分配热点；
- 是 `thread_local`，避免跨线程误报。

---

## 六、StaticJIT 直通：模板化 hot-path

**源码所在**:
- 宏定义：`StaticJIT/StaticJITBinds.h:76-78, 101-106`
- 模板版函数：`Bind_TArray_Functions.h:64-447`（`*_Template<T>`）

### 6.1 宏的双面孔

```cpp
// StaticJIT 启用时:
#define SCRIPT_NATIVE_TARRAY_INDEX(Binds)             FScriptFunctionNativeForm::BindTArrayIndex(Binds)
#define SCRIPT_NATIVE_TARRAY_ITERATOR_CREATE(Binds)   FScriptFunctionNativeForm::BindTArrayIteratorCreate(Binds)
#define SCRIPT_NATIVE_TARRAY_ITERATOR_PROCEED(Binds)  FScriptFunctionNativeForm::BindTArrayIteratorProceed(Binds)
#define SCRIPT_NATIVE_TEMPLATED_CALL(Binds, Name, Trivial)               ...
#define SCRIPT_NATIVE_TEMPLATED_CALL_NEEDSCOPY(Binds, Name, Trivial)     ...
#define SCRIPT_NATIVE_TEMPLATED_CALL_NEEDSCOMPARE(Binds, Name, Trivial)  ...
#define SCRIPT_NATIVE_TEMPLATED_CALL_NEEDSCOPY_NEEDSCOMPARE(Binds, Name, Trivial) ...

// StaticJIT 关闭时: 全部退化为空宏
#define SCRIPT_NATIVE_TARRAY_INDEX(Binds)
...
#define SCRIPT_NATIVE_TEMPLATED_CALL_NEEDSCOPY_NEEDSCOMPARE(Binds, Name, Trivial)
```

设计含义：

- 关闭 JIT 时，`Bind_TArray.cpp` 中所有 `SCRIPT_NATIVE_*` 宏调用**蒸发**，所有方法走通用 `FArrayOperations` 通路（功能不变，性能略低）。
- 开启 JIT 时，宏注册"已知元素类型→原生 `TArray<T>` 调用"的映射表。

### 6.2 模板版函数对应表

`Bind_TArray_Functions.h` 提供 `*_Template<T>` 系列，**接受 `TArray<T>` 引用**而不是 `FScriptArray + asCObjectType`：

| 通用函数 | 模板版 | 说明 |
|---------|-------|------|
| `OpAssign(FScriptArray&, asCObjectType*, FScriptArray&)` | `OpAssign_Template<T>(TArray<T>&, FScriptArray&)` | `Dst = *(TArray<T>*)&Src` 直接调用 UE 内置 |
| `Add(FScriptArray&, asCObjectType*, void*)` | `Add_Template<T>(TArray<T>&, void*)` | `Arr.Add(*(T*)Value)` |
| `Insert/Remove/RemoveAt/...` | `*_Template<T>` 版本 | 全部直转原生 `TArray<T>` 方法 |
| `OpIndex(FScriptArray&, asCObjectType*, int32)` | `OpIndex_Template_Unchecked<T>(TArray<T>&, int32)` | 跳过 `IsValidIndex` 检查（JIT 已在外面校验） |
| `Iterator_Proceed(FArrayIterator*)` | `Iterator_Proceed_Template_Unchecked<T>(FArrayIterator*, uint32)` | `sizeof(T)` 替代运行时 `Stride` 字段 |

**核心利好**：模板版本在编译期就确定了元素 size、构造/析构是否平凡，编译器可以内联 + 向量化。

### 6.3 `StaticJIT` 的协同流程

```text
[预编译阶段]
  字节码扫描 -> 发现 TArray<int>::Add(...)
                  |
                  v
  PrecompiledData 记录: 此调用点应该用 Add_Template<int> 替换
                  |
                  v
[运行时 JIT 阶段]
  模块加载完毕后, JIT 把字节码中"通用 FArrayOperations 调用"
  替换为预记录的 *_Template<T> 直接调用
                  |
                  v
[执行]
  hot path 上 TArray<int>::Add 等同于 C++ 内联调用, 零虚函数开销
```

详细机制见 `Documents/Knowledges/ZH/RT_StaticJIT.md`。

---

## 七、与 UE 反射的双向桥接

### 7.1 `.as` -> `FArrayProperty`（`UPROPERTY` 字段）

```text
Script:
    UCLASS()
    class AMyActor : AActor
    {
        UPROPERTY(EditAnywhere)
        TArray<int> Numbers;
    };
            |
            | ClassGenerator 阶段
            v
   FAngelscriptArrayType::CreateProperty
            |
            v
    FArrayProperty {
        Outer = MyActor 的 UClass
        Inner = FIntProperty                  // 由 SubType.CreateProperty 创建
        Offset = 计算得到的字段偏移
    }
            |
            v
   反射体系认得这个 UPROPERTY, 编辑器面板 / 序列化 / 蓝图都能看到
```

`Bind_TArray.cpp:115-125`:

```cpp
FProperty* FAngelscriptArrayType::CreateProperty(const FAngelscriptTypeUsage& Usage, const FPropertyParams& Params) const
{
    auto* ArrayProp = new FArrayProperty(Params.Outer, Params.PropertyName, RF_Public);

    FPropertyParams InnerParams = Params;
    InnerParams.Outer        = ArrayProp;
    InnerParams.PropertyName = *(Params.PropertyName.ToString() + TEXT("_Inner"));   // UE 约定: 元素 property 名加 "_Inner" 后缀
    ArrayProp->Inner = Usage.SubTypes[0].CreateProperty(InnerParams);

    return ArrayProp;
}
```

### 7.2 C++ `TArray<T>` 字段 -> `.as` 可见

反向链路由 `RegisterTypeFinder` 完成（`Bind_TArray.cpp:1588-1601`）：

```cpp
FAngelscriptType::RegisterTypeFinder([ArrayType](FProperty* Property, FAngelscriptTypeUsage& Usage) -> bool
{
    FArrayProperty* ArrayProp = CastField<FArrayProperty>(Property);
    if (ArrayProp == nullptr) return false;

    FAngelscriptTypeUsage InnerUsage = FAngelscriptTypeUsage::FromProperty(ArrayProp->Inner);
    if (!InnerUsage.IsValid()) return false;

    Usage.Type = ArrayType;
    Usage.SubTypes.Add(InnerUsage);                                                  // 递归恢复元素类型
    return true;
});
```

意义：当一个 C++ 类暴露 `UPROPERTY() TArray<FVector> Path;` 给 AS 时：

1. UHT 工具链识别 `FArrayProperty.Inner = FStructProperty(FVector)`；
2. `RegisterTypeFinder` 递归构造 `FAngelscriptTypeUsage{ Type=ArrayType, SubTypes=[StructType(FVector)] }`；
3. AS 端可写 `MyClass.Path.Add(FVector(1, 2, 3));` 直接操作。

---

## 八、调试器集成

**源码所在**: `Bind_TArray.cpp:309-493`。

### 8.1 三种调试值实现

| 类型 | 实现 | 作用 |
|------|------|------|
| `TNativeDebugArray<T>` | `TArray<T>* Value` | 原生 `TArray` 字段（C++ 类的 UPROPERTY） |
| `FGenericDebugArray` | `FScriptArray* Value + ElementSize` | AS 脚本类的 `TArray<T>` 字段（无具体 T） |
| `TNativeDebugArrayPtr<T>` / `FGenericDebugArrayPtr` | 引用版（多一层指针） | 函数局部变量、参数等以引用持有的 `TArray` |

`CreateDebugValue` 通过 `ReifyDebugValueTemplate` 在编译期决定：**已知 reify 类型** → `TNativeDebugArray<T>`；**未知/泛型** → `FGenericDebugArray`。

### 8.2 调试器面板展示

```cpp
// GetDebuggerValue: 顶层显示
//   "Empty"  (Num == 0)
//   "Num = 5"

// GetDebuggerScope: 展开后子节点
//   [0]   <元素值>
//   [1]   <元素值>
//   ...
//   Num   5

// GetDebuggerMember: 查询单个子节点
//   "[2]" -> 解析索引 -> 返回元素 DebuggerValue
//   "Num" -> 返回 LexToString(Array.Num())
```

这套实现让 VS Code DAP 调试器可以**像 C++ 那样展开 `TArray`**，包括索引方式访问 `Arr[2]`、查看长度、查看每个元素的子结构（递归走每个元素 `SubType.GetDebuggerValue`）。

详见 `Documents/Knowledges/ZH/RT_Debugger.md`。

---

## 九、关键限制与边缘案例

### 9.1 嵌套容器禁止

```angelscript
TArray<TArray<int>> Nested;          // ✗ 编译期报错
TMap<int, TArray<int>> Map;          // ✗ 编译期报错
```

来源：`FAngelscriptArrayType::CanBeTemplateSubType()` 返回 `false`，所有容器（TArray/TMap/TSet/TOptional）的 `TemplateCallback` 都会调 `CanBeTemplateSubType()` 校验子类型。

**变通**：用 `UStruct` 包一层。

```angelscript
struct FRow { TArray<int> Cells; }
TArray<FRow> Grid;                   // ✓ 通过 (struct 不是容器)
```

### 9.2 元素类型必须可构造/析构/拷贝

```angelscript
TArray<UMyAbstractClass> Abstract;   // ✗ 抽象类不能构造
```

`ValidateArrayOperations` 中 `Type.CanConstruct() && Type.CanDestruct() && Type.CanCopy()` 三条全须满足。

### 9.3 `Sort` 要求元素 `opCmp` 或可排序

```angelscript
struct FCustomItem { int Priority; }   // 没有 opCmp
TArray<FCustomItem> Items;
Items.Sort();                           // ✗ 运行时 Throw
```

修复（`Bind_TArray.cpp:1318-1325` 错误信息直接告诉你怎么写）：

```angelscript
struct FCustomItem
{
    int Priority;
    int opCmp(const FCustomItem& Other) const { return Priority - Other.Priority; }
}
```

### 9.4 `Remove(value)` 要求元素 `opEquals`

类似 `Sort`，按值删除/查找系列方法 (`Remove`、`RemoveSingle`、`RemoveSwap`、`RemoveSingleSwap`、`AddUnique`、`FindIndex`、`Contains`) 都需要 `opEquals`。

### 9.5 别名调用必须先拷贝到临时

```angelscript
// ✗ 触发 "Cannot Add an element from the same array by reference"
Numbers.Add(Numbers[0]);

// ✓ 显式临时
int Temp = Numbers[0];
Numbers.Add(Temp);
```

**为什么不允许？** `Numbers.Add(Numbers[0])` 先 `Add` 触发扩容，旧 buffer 被释放，再用悬空指针 `Numbers[0]` 拷入会读到野内存。`CheckArrayValueDoesNotAliasStorage` 在调用前就拦截。

### 9.6 迭代时改写（仅调试构建报错）

```angelscript
for (auto V : Numbers)
{
    Numbers.Add(V * 2);              // ✗ 调试构建抛错; 发布构建静默 UB
}
```

`AS_ITERATOR_DEBUGGING` 编译标志控制；发布构建为零开销，不报错——**用户责任**。

### 9.7 函数参数永远是 out 引用

```angelscript
void Mutate(TArray<int> Arr)         // 实际等价于 TArray<int>& out Arr
{
    Arr.Add(99);                     // 调用者的数组也会被改！
}
```

源自 `IsParamForcedOutParam() = true`。要传值需要主动拷贝：

```angelscript
void Mutate(const TArray<int>& In)
{
    TArray<int> Local = In;          // 显式拷贝
    Local.Add(99);                   // 不影响调用者
}
```

---

## 十、完整链路 ASCII 全景

下图以 `TArray<int> Numbers; Numbers.Add(42); for (auto V : Numbers) { Print(f"{V}"); }` 为例：

```text
============================================================================
  TArray<int> 完整生命周期 (注册 -> 实例化 -> 操作 -> 遍历 -> 析构)
============================================================================

[启动: AS Engine 初始化]
   FAngelscriptBinds 系统按 EOrder::Early 调用 Bind_TArray:
     - ValueClass<FScriptArray>("TArray<class T>")
     - SetArrayTemplateTypeInfo(typeinfo)
     - RegisterDefaultArrayType("TArray<T>")
     - 注册 30+ 方法 (Add/Remove/Sort/opIndex/opForBegin/...)
     - 注册 FAngelscriptArrayType (UE 反射桥)
     - 注册 TArrayIterator<class T> + TArrayConstIterator<class T>
        |
        v
[AS 编译期: 第一次见 TArray<int>]
   asCBuilder 实例化 TArray<int> 模板:
     - 调用 TemplateCallback(TArray<int>, &errMsg)
     - ValidateArrayOperations(...) 创建 FArrayOperations:
         NumBytesPerElement = 4
         Alignment          = 4
         Type               = FAngelscriptTypeUsage{int}
         bNeedConstruct/Destruct/Copy = false  (POD)
         CompareFunction    = nullptr (int 走内置 ordering)
     - SetUserData(Ops) 挂到 asCObjectType::plainUserData
        |
        v
[AS 编译期: for 循环改写]
   编译器看到 for (auto V : Numbers) { ... }
     -> 改写为 int __it = Numbers.opForBegin();
                while (!Numbers.opForEnd(__it)) {
                    auto V = Numbers.opForValue(__it);
                    Print(f"{V}");
                    Numbers.opForNext(__it);
                }
        |
        v
[AS 运行期: TArray<int> Numbers]
   栈上分配 sizeof(FScriptArray) = 24 字节
   FAngelscriptArrayType::ConstructValue 调用 placement-new FScriptArray()
     -> Numbers = { Data=nullptr, ArrayNum=0, ArrayMax=0 }
        |
        v
[AS 运行期: Numbers.Add(42)]
   FArrayOperations::Add(Numbers, asCObjectType*, &42):
     [a] CheckArrayIteratorDebug -> 通过 (无活动迭代器)
     [b] CheckArrayValueDoesNotAliasStorage -> 通过 (Value 不在 Numbers buffer 内)
     [c] AddIndex = Numbers.Add(1, 4, 4) -> 0
         (FScriptArray 内部分配 buffer, ArrayNum=1, ArrayMax=4)
     [d] DestinationAddr = Ops->Get(Numbers, 0) = buffer + 0
     [e] bNeedConstruct = false -> 跳过 ConstructValue
     [f] bNeedCopy      = false -> Memcpy(buffer, &42, 4)
   返回:
     Numbers = { Data=0xABC, ArrayNum=1, ArrayMax=4, *Data = 42 }
        |
        v
[AS 运行期: for 循环遍历]
   __it = Numbers.opForBegin() = 0  (Num > 0)
   while (!Numbers.opForEnd(0))     // 0 != -1, 继续
   {
       V = Numbers.opForValue(0)     // 取 Ops->Get(Numbers, 0) = 42
       Print(f"42")
       Numbers.opForNext(__it)       // __it = (1 < 1) ? 1 : -1 = -1
   }
   while (!Numbers.opForEnd(-1))    // -1 == -1, 退出
        |
        v
[AS 运行期: Numbers 离开作用域]
   FAngelscriptArrayType::DestructValue:
     - bNeedDestruct = false -> 跳过元素析构循环
     - Numbers.~FScriptArray() -> 释放 buffer (Free Data)
        |
        v
[AS Engine 关闭]
   asITypeInfo 释放时同步 delete FArrayOperations* (userdata)
   FAngelscriptArrayType::~ 静态对象析构
```

---

## 十一、与兄弟容器（TMap / TSet / TOptional）的统一

四个容器的实现高度同构：

| 维度 | TArray | TMap | TSet | TOptional |
|------|--------|------|------|-----------|
| 底层桥接对象 | `FScriptArray` | `FScriptMap` | `FScriptSet` | 复用 struct + bool |
| 类型 facade | `FAngelscriptArrayType` | `FAngelscriptMapType` | `FAngelscriptSetType` | `FAngelscriptOptionalType` |
| 操作集 | `FArrayOperations` | `FMapOperations` | `FSetOperations` | `FOptionalOperations` |
| 元素元数据存放 | `asCObjectType::plainUserData` | 同 | 同 | 同 |
| 嵌套支持 | ✗ (`CanBeTemplateSubType=false`) | ✗ | ✗ | ✗ |
| `for` 遍历五件套 | `opForBegin/End/Next/Value/Key` (Key=index) | 同 (Key=键拷贝) | 同 (Key=元素副本) | N/A (不可遍历) |
| 模板侧 hot-path | `*_Template<T>` 系列 | 部分 | 部分 | 部分 |
| 反射桥 | `FArrayProperty` ↔ `FAngelscriptTypeUsage` | `FMapProperty` | `FSetProperty` | `FOptionalProperty` (UE5.5+) |
| 别名/迭代守卫 | `AS_ITERATOR_DEBUGGING + AS_REFERENCE_DEBUGGING` | 同 | 同 | 同 |

`TArray` 是这四者中**最简单也最基础**的一个，理解它的实现可以直接迁移到 `TMap`/`TSet`/`TOptional`，只是元素操作多一些（key 哈希、桶扫描等）。详见各自的 `Syntax_TMap.md` / `Syntax_TSet.md` / `Syntax_TOptional.md`。

---

## 十二、设计哲学

### 12.1 为什么用 `FScriptArray` 而不是 vanilla AS `array<T>`？

vanilla AngelScript 自带 `add_on/scriptarray/scriptarray.h` 提供 `array<T>` 模板容器。当前项目**完全弃用**该 add-on，改用 UE 自带的 `FScriptArray` + 自实现绑定。原因：

```text
+ 优势:
  - 与 UE 反射 100% 兼容: FArrayProperty 直接指向 FScriptArray, 无任何转换
  - 与 UE TArray<T> 二进制兼容: StaticJIT 可以无缝走原生路径
  - GC 集成自然: ReferenceArray / StructArray Schema 无需自实现
  - 统一内存分配器: 走 UE FMemory, 与引擎 stat 系统集成

- 代价:
  - 失去 vanilla AS 的字面量 array 语法 ({1, 2, 3} 默认初始化)
    -> 通过 RegisterDefaultArrayType("TArray<T>") 重新接管
  - C++ 端绑定代码量更大 (要自己实现 30+ 方法)
```

### 12.2 为什么把元素元数据挂在 `asCObjectType::plainUserData`？

替代方案是每次 `Add/Remove` 都查表（`TMap<asITypeInfo*, FArrayOperations*>` 全局表）。当前选择有两个 hot-path 利好：

1. **零分配 + 零查表**：`GetArrayOperations(Meta)` 就是 `Meta->plainUserData` 的指针读，硬件能直接预取。
2. **生命周期天然绑定**：`asITypeInfo` 销毁时通过 user-data 析构回调一并释放 `FArrayOperations`，无需手动管理。

代价：每个 `asITypeInfo` 只能挂一个 user-data 槽，所以同一个类型不能被多个子系统同时占用 `plainUserData`——这在当前项目里不成问题（容器各自实例化独立 `asObjectType`）。

### 12.3 为什么 `IsParamForcedOutParam = true` 而不让用户选择？

按值传递 `TArray` 在脚本里**几乎总是 bug**——既慢（深拷贝）又违反直觉（修改不可见）。强制 out 引用：

- 性能默认正确（不会无意 deep-copy）；
- 调用语法保持简洁（不必到处写 `& out`）；
- 想要值语义只需显式 `TArray<T> Local = In;`，意图明确。

### 12.4 为什么删除有六个变体？

UE C++ `TArray` 本身就有这六个方法（`RemoveAt`/`RemoveAtSwap`/`Remove`/`RemoveSingle`/`RemoveSwap`/`RemoveSingleSwap`），理由：

```text
按位置 vs 按值       -> RemoveAt 系列 vs Remove 系列
保持顺序 vs 与末尾换位 -> 普通版 vs Swap 版
全部匹配 vs 仅首匹配  -> Remove vs RemoveSingle
```

三个维度交叉得到 6 个组合，每个都对应明确的性能/语义权衡。AS 端**完整暴露**让用户可以按需选择最快路径——这与项目"性能默认接近 C++"的目标一致。

### 12.5 为什么 `Sort` 要为 1/2/4/8/12/16 字节单独特化？

```cpp
if      (Size == 1)  FScriptArraySorter<1>::Sort(...);
else if (Size == 4)  FScriptArraySorter<4>::Sort(...);
else if (Size == 12) FScriptArraySorter<12>::Sort(...);
else if (Size == 16) FScriptArraySorter<16>::Sort(...);
```

`FScriptArraySorter<Size>` 内部用 `struct FElement { uint8 Data[Size]; }`，让 `Algo::Sort` 编译期就知道元素大小：

- `Size == 4` → `int32` / `float`，单条 mov 即可拷贝；
- `Size == 12` → `FVector(3 × float)`，三条 mov；
- `Size == 16` → `FQuat` / `FVector4`，一条 SIMD mov。

如果不特化，所有元素拷贝走 `memcpy(elem, elem, Size)`——优化器看不到 Size 是常量，无法向量化。这也是为什么超过 16 字节直接抛错而不是兜底 `memcpy`：再大就拷贝成本压过排序成本，得不偿失。

---

## 十三、关键结论速查

| 主题 | 结论 |
|------|------|
| **TArray 不是 AS 内核类型** | 完全是 `Bind_TArray.cpp` 注册的模板 ValueClass，底层桥接 UE 自带的 `FScriptArray` |
| **核心入口** | `Bind_TArray.cpp:1381` `AS_FORCE_LINK Bind_TArray` 全局注册块；`Bind_TArray_Functions.h` 提供方法实现与模板特化版本 |
| **三个核心 C++ 抽象** | ① `FAngelscriptArrayType`（接 UE 反射）② `FArrayOperations`（元素操作集）③ `FArrayIterator`（手工迭代器） |
| **元素元数据挂载** | 每个 `TArray<T>` 实例化对应一个 `FArrayOperations`，挂在 `asCObjectType::plainUserData`，由 `ValidateArrayOperations` 在 `TemplateCallback` 阶段构造 |
| **POD 优化** | 元素 `bNeedConstruct/bNeedCopy/bNeedDestruct = false` 时整体走 `FMemory::Memcpy`，达到原生 `TArray<T>` 性能 |
| **嵌套禁止** | `FAngelscriptArrayType::CanBeTemplateSubType() = false`，所有容器子类型必须不是容器；变通：用 struct 包一层 |
| **for 循环展开** | `as_compiler.cpp:5665` 改写为 `opForBegin/End/Next/Value` 五件套；`opForKey` 决定键语义（`TArray` = 索引） |
| **手工迭代** | `FArrayIterator` 值类型 `{Array*, Stride, Index, bCanProceed}`；`Proceed()` 取值兼步进 |
| **6 个删除变体** | `RemoveAt[Swap] / Remove[Single][Swap]` 三维交叉：按位置/按值 × 保序/换位 × 全部/首个 |
| **GC 集成** | `EmitReferenceInfo` 根据元素类型生成 `ReferenceArray`（UObject*）或 `StructArray`（含 ref 的 struct），纯 POD 完全跳过 |
| **UE 反射双向桥** | `CreateProperty` 创建 `FArrayProperty + Inner`；`RegisterTypeFinder` 反向把 `FArrayProperty` 解析回 `FAngelscriptTypeUsage` |
| **StaticJIT 直通** | `SCRIPT_NATIVE_TEMPLATED_CALL_*` 宏在 JIT 启用时把通用 `FArrayOperations` 调用替换为 `*_Template<T>` 原生路径；JIT 关闭时宏退化为空 |
| **参数永远 out** | `IsParamForcedOutParam = true`，`TArray` 函数参数恒为引用语义，无意外 deep-copy |
| **三层防御** | ① 越界 `IsValidIndex` → `Throw`；② 别名 `CheckArrayValueDoesNotAliasStorage` → `Throw`；③ 迭代中改写 `AS_ITERATOR_DEBUGGING` → `Throw` |
| **Sort 双路径** | 元素有 `opCmp` 走 AS 调用版本；元素是内置可序类型按 1/2/4/8/12/16 字节模板特化；都不满足时抛人类可读错误 |
| **关联兄弟容器** | `TMap`/`TSet`/`TOptional` 共享同一套架构（操作集 + facade + plainUserData），仅元素操作语义不同 |

---

## 十四、关联文档

- 实现原理（兄弟章节）：
  - `Documents/Knowledges/ZH/Syntax_TMap.md` —— `TMap<K, V>` 哈希映射（待写）
  - `Documents/Knowledges/ZH/Syntax_TSet.md` —— `TSet<T>` 哈希集合（待写）
  - `Documents/Knowledges/ZH/Syntax_TOptional.md` —— `TOptional<T>` 可选值（待写）
  - `Documents/Knowledges/ZH/Syntax_UPROPERTY.md` —— `FProperty` 创建链路与本文 `CreateProperty` 共用同一框架
- 类型系统：
  - `Documents/Knowledges/ZH/Type_BindSystem.md` —— `FAngelscriptType` / `FAngelscriptTypeUsage` 多态分派
  - `Documents/Knowledges/ZH/Type_Core.md` —— `FAngelscriptType` 接口规约
- 运行时：
  - `Documents/Knowledges/ZH/RT_StaticJIT.md` —— `SCRIPT_NATIVE_TEMPLATED_CALL_*` 与 `PrecompiledData` 详细机制
  - `Documents/Knowledges/ZH/RT_Debugger.md` —— DAP 调试器变量面板协议
- 核心源码：
  - `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_TArray.cpp` —— 主实现
  - `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_TArray_Functions.h` —— `FArrayOperations` 与模板特化
  - `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_TArray.h` / `Bind_TArray_Structs.h` —— `FAngelscriptArrayType` / `FArrayIterator` 头文件
  - `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_compiler.cpp:5665` —— `opFor*` 展开
- 测试覆盖：
  - `Plugins/Angelscript/Source/AngelscriptTest/Bindings/AngelscriptTArrayBindingsTests.cpp` —— `TArray` 绑定入口合同冒烟（自动化测试名 `Angelscript.TestModule.Bindings.Container.TArray`）
  - `Plugins/Angelscript/Source/AngelscriptTest/Bindings/AngelscriptTArraySyntaxCompatBindingsTests.cpp` —— `T[]` / `int[]` 语法兼容入口合同与最小负向边界
  - `Plugins/Angelscript/Source/AngelscriptTest/Coverage/AngelscriptCoverageTArrayAdvancedTests.cpp` —— `TArray` 主体行为覆盖矩阵
  - `Plugins/Angelscript/Source/AngelscriptTest/Coverage/AngelscriptCoverageContainerNestedTests.cpp` —— 嵌套容器边界矩阵
- 示例脚本：
  - `Script/Examples/Core/Example_Array.as` —— 用户向 cookbook（声明、Add、遍历、排序）

---

## 十五、修订记录

| 版本 | 日期 | 内容 |
|------|------|------|
| v1.0 | 2026-04-29 | 首版：基于当前项目实际源码（`Bind_TArray.cpp:1-1830` / `Bind_TArray.h` / `Bind_TArray_Functions.h:1-449` / `Bind_TArray_Structs.h` / `as_compiler.cpp:5665-5673` / `StaticJITBinds.h:76-106`）完整产出。覆盖：① `TArray<T>` 三重身份（脚本值类型 / `FArrayProperty` / StaticJIT 模板路径）+ `FScriptArray` 二进制兼容洞察；② 4 阶段管线总览（绑定注册 → AS 编译期 TemplateCallback → 运行时 FAngelscriptArrayType + FArrayOperations → StaticJIT 直通）；③ `Bind_TArray` `EOrder::Early` 注册时机 + `RegisterDefaultArrayType` + `asOBJ_TEMPLATE_SUBTYPE_COVARIANT` 协变；④ `FArrayOperations` 元素元数据缓存（`NumBytesPerElement`/`bNeedConstruct/Destruct/Copy`/`CompareFunction`）+ `ValidateArrayOperations` 一次构造终生复用；⑤ `FAngelscriptArrayType` 接口职责映射 18 项 + GC `ReferenceArray`/`StructArray` Schema 双分支 + `IsParamForcedOutParam` 设计意图；⑥ 关键操作剖析：`Add` 三层防御（迭代/别名/引用失效）+ `OpAssign` POD vs 非 POD 三段路径 + 6 个删除变体（按位置/值 × 保序/换位 × 全部/首个）+ `Sort` 三层兜底（opCmp / 内置 ordering 1-16 字节特化 / 抛错）+ 别名防御一览表；⑦ `for` 范围循环 `opForBegin/End/Next/Value/Key` 五件套 + 编译器侧改写 + `TArrayIterator<T>` 手工迭代 + `AS_ITERATOR_DEBUGGING` 全局表守卫；⑧ StaticJIT 宏的双面孔（启用 vs 关闭）+ `*_Template<T>` 函数对应表 + 预编译/JIT 协同流程；⑨ UE 反射双向桥（`CreateProperty` 创建 `FArrayProperty + Inner` / `RegisterTypeFinder` 反向解析）；⑩ 调试器集成 3 种 DebugValue 实现（`TNativeDebugArray<T>` / `FGenericDebugArray` / `*Ptr` 引用版）+ 调试器面板 `[i]`/`Num` 子节点协议；⑪ 7 项关键限制（嵌套禁止 / 元素契约 / Sort 与 Remove 元素能力 / 别名 / 迭代中改写 / out 参数语义）；⑫ 完整 ASCII 全景 `TArray<int> + Add(42) + for` 端到端生命周期；⑬ 与 TMap/TSet/TOptional 兄弟容器架构对比；⑭ 5 个设计哲学解析（弃用 vanilla `array<T>` 选 `FScriptArray` / 元数据挂 `plainUserData` / 强制 out 参数 / 6 个删除变体 / Sort 字节大小特化）。本文未引用 Hazelight 参考文档（无 Temp 文档），全程基于当前项目源码事实。所有 ASCII 图遵循纯 ASCII 风格（与 `Syntax_DefaultStatement.md` v1.3 / `Syntax_UPROPERTY.md` v1.3 / `Syntax_FString.md` v1.0 / `Syntax_Mixin.md` 等统一）。 |

