# Type_FunctionCaller — 函数调用桥

> **所属前缀**: Type_（类型系统与生成链路族）
> **关注层面**: 站在"AS 字节码 → 宿主 C++ 函数（含 UFunction 反射）这一次过程边界"的视角看 `FunctionCallers.h` 这一组类型擦除工具——`FGenericFuncPtr` / `FAngelscriptFunctionBinding` 怎么在 PE 段保存原始函数指针、`ASAutoCaller::FunctionCaller` 怎么用 C++ 模板把任意 `Ret(Cls::*)(Args...)` 推导成统一的 `(TFunctionPtr, void**, void*)` 三元 trampoline、AS Fork 的 `asCContext::CallFunctionCaller` 怎么取代标准 ABI 桥（`as_callfunc_x64_msvc.cpp` 已被禁用为历史参考）成为 AS 内核唯一的 native 调用入口。本文不重写 AS 内核 16 种 `internalCallConv` 在各平台的汇编桥（那是 `AS_CallingConventions` 的职责，且在本插件中大部分已被 caller 路径绕过），不重写 `Bind_*.cpp` 的注册时序与 `EOrder` 优先级（那是 `Type_BindSystem`），不重写 `UASFunctionNativeThunk` / `ResolveScriptVirtual` 这条"C++ → AS"反向链路（那是 `Type_BaseClass` §六的职责）；本文聚焦的是**正向**链路："AS 脚本写 `Actor.GetActorLocation()` 时如何穿过 calling convention 边界，参数怎么打包、返回值怎么还原"
> **关键源码**:
> `Plugins/Angelscript/Source/AngelscriptRuntime/Core/FunctionCallers.h` (~392 行，`FGenericFuncPtr` / `ASAutoCaller::FunctionCaller` / `ReNativeRuntimeLinked*Caller` 模板族 / `ERASE_*` 宏 / `FAngelscriptFunctionBinding`)
> · `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_context.cpp::CallFunctionCaller` (~5231 行起，唯一 native 调用分发点)
> · `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_callfunc.cpp::CallSystemFunction` (~400 行起，先看 `caller.IsBound()`，未绑定才退回 `CallGeneric`)
> · `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_context.cpp::CallGeneric` (~5166 行起，`asCALL_GENERIC` 的 trampoline)
> · `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptBinds.cpp` (~557–730 行，`BindMethod` / `BindMethodDirect` / `BindGlobalFunction` / `BindExternMethod` / `GenericMethod` 等"6 条调用约定×4 形态"对外接口)
> · `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/BlueprintCallableReflectiveFallback.cpp` (~1100 行，`FBlueprintCallableReflectiveSignature` + `InvokeReflectiveUFunctionFromGenericCallCached` + `FReflectiveParamCache`)
> · `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_BlueprintCallable.cpp` (~403 行，Runtime-linked / 反射兜底两条注册路径)
> · `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_BlueprintEvent.cpp::CallStaticWithSignature` / `CallEventWithSignature` / `CallMixinWithSignature` (~602–640 行)
> · `Plugins/Angelscript/Intermediate/Build/.../UHT/AS_FunctionBinding_*.cpp`（UHT 产物，`ERASE_AUTO_*_PTR` 宏的实际展开样本）
> **关联文档**:
> `Documents/Knowledges/ZH/Type_BindSystem.md` — `FBind` / `EOrder` / 三层 fallback 模型（本文是三层中"调用边界"那一面的特写）
> · `Documents/Knowledges/ZH/Type_BaseClass.md` §六 — `UASFunctionNativeThunk` + `ResolveScriptVirtual`：C++ → AS 的反向桥（与本文方向相反）
> · `Documents/Knowledges/ZH/Type_Core.md` — `FAngelscriptType` 数据库（FunctionCaller 不直接消费，但参数/返回值类型语义在那里定义）
> · `Documents/Knowledges/ZH/AS_CallingConventions.md` — AS 内核 16 种 `internalCallConv` 与平台汇编桥的原貌（被本文 caller 路径绕过的部分）
> · `Documents/Knowledges/ZH/AS_VirtualMachine.md` — `asCContext::Execute` / `CALLSYS` 指令调度
> · `Documents/Knowledges/ZH/Arch_UHTToolchain.md` — UHT 生成 `AS_FunctionBinding_*.cpp` 时如何写出 `ERASE_AUTO_*_PTR` 宏

---

## 概览

本文聚焦一个核心问题：**当 `.as` 写下 `Actor.GetActorLocation()`，AS 字节码停在 `CALLSYS <SysFuncId>` 这一刻，引擎怎么从 AS 解释器栈里把"this 指针 + 0 个参数"打包出来、跳转到 `AActor::GetActorLocation` 这条 thiscall C++ 函数指针的真正机器码、把 `FVector` 返回值原样写回 AS 栈？这条路径在 UE Fork 中已经基本绕过了 `as_callfunc_x64_msvc.asm` 这种平台汇编桥，而是走一条由 `ASAutoCaller::FunctionCaller` 模板生成的、跨平台的 C++ trampoline。本文展开 `FGenericFuncPtr` 类型擦除、`ReNativeRuntimeLinked*Caller<Ret, Cls, Args...>` 模板特化、`asCContext::CallFunctionCaller` 分发，以及反射 fallback 在没有直接函数指针时如何走 `FFrame + UFunction::Invoke` 的另一条岔路。**

```text
================================================================================
  AS → C++ 调用桥全景：从 CALLSYS 字节码到 AActor::GetActorLocation 的 6 段路径
================================================================================

[Stage A: 注册期]               [Stage B: 编译期]            [Stage C: 运行期]
                                                              ┌──────────────────┐
Bind_AActor.cpp:                .as 文件:                     │  AS 字节码:       │
  AActor_.Method(               class AMyActor : AActor {     │   PSF this        │
    "FVector GetActorLocation     void TickActor() {          │   CALLSYS  <id>   │
     () const",                     auto Loc =                │      │            │
    METHOD_TRIVIAL(                   GetActorLocation();     │      ▼            │
      AActor,                       ...                       │  CallSystemFunc   │
      GetActorLocation));         }                           │   ─ id 反查        │
       │                        }                             │      sysFunc      │
       │                                                      │   ─ caller.IsBound│
       ▼                                                      │      ? Yes ─────┐ │
ASAutoCaller::                                                │                 ▼ │
MakeFunctionCaller<                                           │  CallFunctionCaller(descr)
  FVector,AActor>(&...):                                      │   ─ 用 sysFunc 把 AS 栈
   instantiate                                                │     还原成 void*[32]
   ReNativeRuntimeLinkedMethodCaller<                                      │   ─ caller.type = 2 走
     FVector,AActor>                                          │     MethodCaller(method,
   返回 caller.MethodPtr =                                    │                  args, ret)
     &ReNativeRuntimeLinkedMethodCaller<...>                               │   ─ 进入 ReNativeRuntimeLinked模板：
       │                                                      │     ((Cls*)args[0])->*
       ▼                                                      │       method(args[1...])
asCALL_THISCALL                                               │   ─ 返回值通过 placement
RegisterObjectMethod                                          │     new 写入 retAddr
  → sysFunc->func   = method ptr (类型擦除拷贝 25 字节)        │
  → sysFunc->caller = {MethodPtr, type=2}                     │
                                                              └──────────────────┘

后续章节按 [类型擦除存储 → ReNativeRuntimeLinked 模板 → CallFunctionCaller 分发 →
            CallGeneric 兜底 → 反射 fallback 路径 → 调用约定矩阵 →
            UHT/手写/反射对比 → 异常与边界] 的顺序展开。
```

---

## 一、类型擦除：`FGenericFuncPtr` 与 25 字节联合体

### 1.1 为什么要类型擦除

C++ 函数指针在 ABI 层有三种形态：

- 全局函数：`void(*)()`（典型 8 字节）
- 静态成员函数：与全局函数等价
- 普通成员函数指针：**取决于编译器与继承结构**——MSVC 单继承下 8 字节、多继承 16 字节、虚继承 20 字节、未知继承 24 字节；GCC/Clang Itanium ABI 总是 16 字节

AS 引擎想统一存"任何能调到的 C++ 函数"，必须接受最坏情况的 24 字节再加 1 字节 alignment padding。`FunctionCallers.h` 顶部就是这个统一存储：

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Core/FunctionCallers.h
// 类型: FGenericFuncPtr
// 角色: 25 字节联合体 + 1 字节 flag，统一存储任何 C++ 函数 / 方法指针
// ============================================================================
struct FGenericFuncPtr
{
    union
    {
        // The largest known method pointer is 20 bytes (MSVC 64bit),
        // but with 8byte alignment this becomes 24 bytes. So we need
        // to be able to store at least that much.
        struct { FTypeErasedFuncPtr func; char dummy[25 - sizeof(FTypeErasedFuncPtr)]; } f;
        struct { FTypeErasedMethodPtr mthd; char dummy[25 - sizeof(FTypeErasedMethodPtr)]; } m;
        char dummy[25];
    } ptr;
    uint8 flag; // 1 = generic, 2 = global func, 3 = method   ★ 区分 union 三态
};
```

**关键设计**：

- `FTypeErasedFuncPtr` = `void(*)()`，`FTypeErasedMethodPtr` = `void(FUnknownClass::*)()`——这两个类型本身没有任何信息，类型信息已经被擦除
- `flag` 字段是 union 的"discriminator"：`1=generic`（即 `asCALL_GENERIC` 的 `void(*)(asIScriptGeneric*)`）、`2=global func`、`3=method`
- 25 字节是**经验值**：MSVC `class WithMostInheritance` 方法指针最大可达 24 字节（指针 + 偏移 + vtable 索引 + adjustor），加 1 字节 padding 凑 8 字节对齐

### 1.2 `CopyMethodPtr` 与 `FMethodPtrHelper<N>` 特化

由于不同继承结构产生不同尺寸的方法指针，注册期需要 `sizeof(M)` 多大就拷多少字节：

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Core/FunctionCallers.h
// 类型: FMethodPtrHelper<N> 特化族
// ============================================================================
class FDummyClass {};
typedef void (FDummyClass::* FDummyMethodPtr)();
const int DummyMethodPtrSize = sizeof(FDummyMethodPtr);   // ★ 编译期推导基础尺寸

template <int N> struct FMethodPtrHelper {
    template<class M> static FGenericFuncPtr Convert(M Mthd) {
        int ERROR_UnsupportedMethodPtr[N - 100];           // ★ 默认模板：编译期触发负数组错误
        FGenericFuncPtr p; p.Init(0); return p;
    }
};

template <> struct FMethodPtrHelper<DummyMethodPtrSize> {  // 单继承 (8B / 16B)
    template<class M> static FGenericFuncPtr Convert(M Mthd) {
        FGenericFuncPtr p; p.Init(3);                       // flag = 3 表示 method
        p.CopyMethodPtr(&Mthd, DummyMethodPtrSize);
        return p;
    }
};

#if defined(_MSC_VER)
template <> struct FMethodPtrHelper<DummyMethodPtrSize + 1 * sizeof(int)> { /* 多继承 */ };
template <> struct FMethodPtrHelper<DummyMethodPtrSize + 2 * sizeof(int)> { /* 虚继承 */ };
template <> struct FMethodPtrHelper<DummyMethodPtrSize + 3 * sizeof(int)> { /* */ };
template <> struct FMethodPtrHelper<DummyMethodPtrSize + 4 * sizeof(int)> { /* 未知继承 */ };
#endif
```

**编译期保护**：默认模板里那行 `int ERROR_UnsupportedMethodPtr[N - 100];` 是**故意**写成会触发负数组下标错误的——任何不在已枚举尺寸列表中的方法指针，会在编译期就报错而不是等到运行期才崩溃。

`CopyMethodPtr(&Mthd, size)` 就是按这个尺寸做 byte-wise 拷贝到 `union ptr.dummy[]` 里。Note：注册期拷过来的是"原本类型已知的方法指针"按字节复制；调用期通过反向 `union` 把这些字节解释回原本的方法指针类型——只要原本的尺寸 / 调用约定与"调用现场重新声明的 `Ret(Cls::*)(Args...)`"完全一致就安全。

### 1.3 `ERASE_*` 宏家族：四种登记入口

`AS_FunctionBinding_*.cpp`（UHT 产物）和手写 `Bind_*.cpp` 都通过这五个宏向 `RegisterFunctionBinding(Class, Name, FAngelscriptFunctionBinding{...})` 提交记录：

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Core/FunctionCallers.h
// 角色: 把 C++ 端"任意函数 / 方法"包装成 (FGenericFuncPtr, FunctionCaller) 二元组
// ============================================================================
#define ERASE_NO_FUNCTION()       FGenericFuncPtr{}, ASAutoCaller::FunctionCaller{}
#define ERASE_METHOD_PTR(c,m,p,r) FMethodPtrHelper<sizeof(void (c::*)())>::Convert(static_cast<r(c::*)p>(&c::m)), \
                                   ASAutoCaller::MakeFunctionCaller(static_cast<r(c::*)p>(&c::m))
#define ERASE_FUNCTION_PTR(f,p,r) FGenericFuncPtr::Make(reinterpret_cast<FTypeErasedFuncPtr>(size_t(static_cast<r(*)p>(f)))), \
                                   ASAutoCaller::MakeFunctionCaller(static_cast<r(*)p>(f))
#define ERASE_AUTO_METHOD_PTR(c,m) MakeAutoMethodPtr(&c::m), ASAutoCaller::MakeFunctionCaller(&c::m)
#define ERASE_AUTO_FUNCTION_PTR(f) MakeAutoFunctionPtr(&f), ASAutoCaller::MakeFunctionCaller(&f)
```

| 宏 | 何时用 | 关键约束 |
|----|-------|---------|
| `ERASE_NO_FUNCTION` | UHT 已识别为不可绑定（如纯虚 / 已删除）的 UFUNCTION 占位 | `caller.IsBound()` 返回 `false`，会被 `Bind_BlueprintCallable` 走反射 fallback |
| `ERASE_METHOD_PTR(c,m,p,r)` | 重载方法（用 `r(c::*)p` 强制选中具体重载） | UHT 检测到同名重载时使用 |
| `ERASE_FUNCTION_PTR(f,p,r)` | 重载全局/静态函数 | 同上 |
| `ERASE_AUTO_METHOD_PTR(c,m)` | 无重载普通方法（最常见） | 编译器自动推导 |
| `ERASE_AUTO_FUNCTION_PTR(f)` | 无重载全局函数（FunctionLibrary mixin 主入口） | 同上 |

UHT 实际产物中 `ERASE_AUTO_METHOD_PTR` 与 `ERASE_AUTO_FUNCTION_PTR` 占绝大多数，`ERASE_FUNCTION_PTR` 仅出现在 `AngelscriptComponentLibrary::GetComponentQuat` 这种"参数列表不平凡的 mixin 重载"场合。

### 1.4 `FAngelscriptFunctionBinding`：登记到 `ClassFunctionBindings` 的最终形态

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Core/FunctionCallers.h
// 类型: FAngelscriptFunctionBinding
// 角色: ClassFunctionBindings[UClass*][FuncName] 的 value 类型
// ============================================================================
struct FAngelscriptFunctionBinding
{
    FGenericFuncPtr           FunctionPointer;          // ★ 25 字节类型擦除存储
    ASAutoCaller::FunctionCaller FunctionCaller;        // ★ 8+8 字节模板生成的 trampoline
    bool bReflectiveFallbackBound = false;              // 反射 fallback 是否已在 AS 引擎注册
};
```

`FAngelscriptFunctionBinding` 是 `Type_BindSystem` §六中 Layer A（UHT 灌库）的产物。`Bind_Defaults`（Layer C，`Late+100`）在按 UClass 遍历时取出这个 entry：

- 若 `FunctionPointer.IsBound() == true`（意即 `flag != 0`，UHT 找到了真实函数指针）→ 走"Runtime-linked"路径，`memcpy(asSFuncPtr, FunctionPointer, 25)` + `FunctionCaller` 一起注册到 AS 引擎
- 若 `FunctionPointer.IsBound() == false`（即 `ERASE_NO_FUNCTION()` 或 UHT 未生成此项）→ 走"反射 fallback"路径，注册一个 `asCALL_GENERIC` trampoline

---

## 二、`ASAutoCaller::FunctionCaller`：模板生成的统一 trampoline

### 2.1 数据结构：union + type discriminator

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Core/FunctionCallers.h
// 类型: ASAutoCaller::FunctionCaller
// 角色: 与 asFunctionCaller 内存布局完全相同；AS 引擎层做 reinterpret cast
// ============================================================================
namespace ASAutoCaller
{
    using TFunctionPtr = void(*)();
    using TMethodPtr   = void(FFakeObject::*)();

    struct FunctionCaller
    {
        using FunctionCallerPtr = void(*)(TFunctionPtr Method, void** Parameters, void* ReturnValue);
        using MethodCallerPtr   = void(*)(TMethodPtr   Function, void** Parameters, void* ReturnValue);

        union
        {
            MethodCallerPtr MethodPtr;
            FunctionCallerPtr FuncPtr;
        };
        int type;     // 0 = unbound, 1 = function, 2 = method   ★ 与 FGenericFuncPtr.flag 不同维度

        bool IsBound() const { return MethodPtr != nullptr; }
    };
}
```

**`FunctionCaller` 与 `FGenericFuncPtr` 的关系**：

- `FGenericFuncPtr` 存"被调函数本体的机器码地址"——这是 callee
- `FunctionCaller` 存"调用 callee 的 trampoline 函数地址"——这是 caller-of-callee
- 真正运行时的调用是 `caller.FuncPtr(funcptr.func, args[], ret)`：trampoline 接收 callee 与参数包，按编译期已知的签名展开 callee

`type` 与 `FGenericFuncPtr.flag` **维度不同**：`flag` 描述"目标函数是 generic / global / method"，而 `type` 描述"trampoline 自身是 function 形态还是 method 形态"。两者通过 `MakeFunctionCaller` 重载在编译期一次性匹配。

### 2.2 `MakeFunctionCaller`：四个重载的合谋

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Core/FunctionCallers.h
// 函数: ASAutoCaller::MakeFunctionCaller 四重载
// ============================================================================
namespace ASAutoCaller
{
    // 全局函数
    template<typename ReturnType, typename... ParamTypes>
    FunctionCaller MakeFunctionCaller(ReturnType(*FunctionPtr)(ParamTypes...))
    {
        return FunctionCaller::Make(&ReNativeRuntimeLinkedFunctionCaller<ReturnType, ParamTypes...>);
    }

    // 普通成员函数
    template<typename ReturnType, typename... ParamTypes, typename ObjectType>
    FunctionCaller MakeFunctionCaller(ReturnType(ObjectType::* FunctionPtr)(ParamTypes...))
    {
        return FunctionCaller::Make(&ReNativeRuntimeLinkedMethodCaller<ReturnType, ObjectType, ParamTypes...>);
    }

    // const 成员函数（GetActorLocation 等）
    template<typename ReturnType, typename... ParamTypes, typename ObjectType>
    FunctionCaller MakeFunctionCaller(ReturnType(ObjectType::* FunctionPtr)(ParamTypes...) const)
    { return FunctionCaller::Make(&ReNativeRuntimeLinkedMethodCaller<ReturnType, ObjectType, ParamTypes...>); }

    // const& 成员函数（rvalue ref-qualified）
    template<typename ReturnType, typename... ParamTypes, typename ObjectType>
    FunctionCaller MakeFunctionCaller(ReturnType(ObjectType::* FunctionPtr)(ParamTypes...) const&)
    { return FunctionCaller::Make(&ReNativeRuntimeLinkedMethodCaller<ReturnType, ObjectType, ParamTypes...>); }
}
```

**关键观察**：

- `MakeFunctionCaller` 不存储 `FunctionPtr` 本身——它只是利用 `FunctionPtr` 的类型来**实例化** `ReNativeRuntimeLinked*Caller<Ret, Cls, Args...>` 这个模板。返回的 `FunctionCaller::Make(&ReNativeRuntimeLinkedMethodCaller<...>)` 中那个 `&` 是**模板实例**的函数指针。
- 因此每个不同签名的 C++ 函数会在二进制中各自生成一份 `ReNativeRuntimeLinkedMethodCaller<FVector, AActor>` / `ReNativeRuntimeLinkedMethodCaller<bool, AActor, FVector>` / ……不同特化。
- 这意味着 .dll 的 .text 段会因为 `MakeFunctionCaller` 模板实例化产生大量重复代码——是空间换时间的经典权衡。Hazelight 的早期版本曾用 platform 汇编桥避免这种膨胀；UE Fork 选择 caller 路径接受 .text 膨胀来换取跨平台一致性与零汇编依赖。

### 2.3 `ReNativeRuntimeLinkedMethodCaller`：成员函数 trampoline 主体

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Core/FunctionCallers.h
// 函数: ASAutoCaller::IndexedMethodCaller / ReNativeRuntimeLinkedMethodCaller
// 性质: 在编译期把变长 ParamTypes... 展开成定长 args[0]/args[1]/...
// ============================================================================
template<typename ReturnType, typename ObjectType, typename... ParamTypes, int... TIndices>
FORCEINLINE void IndexedMethodCaller(TMethodPtr MethodPtr, void** Arguments,
                                     void* ReturnValue,
                                     TIntegerSequence<int, TIndices...>)
{
    union
    {
        TMethodPtr Method;
        ReturnType(ObjectType::* Casted)(ParamTypes...);
    } CastedMethodPtr;
    CastedMethodPtr.Casted = nullptr;
    CastedMethodPtr.Method = MethodPtr;                                  // ★ union 反射回原签名

    new(ReturnValue) (typename TReferenceToPtr<ReturnType>::Type)(       // ★ placement new 入返回槽
        GetAddressIfReference<ReturnType>(
            (((ObjectType*)Arguments[0])->*CastedMethodPtr.Casted)       // ★ this->method(...)
            (
                (PassArgument<ParamTypes>(Arguments + TIndices + 1))...  // ★ 第 i+1 个参数
            )
        )
    );
}

template<typename ReturnType, typename ObjectType, typename... ParamTypes>
typename TEnableIf<!std::is_void<ReturnType>::value>::Type
ReNativeRuntimeLinkedMethodCaller(TMethodPtr MethodPtr, void** Arguments, void* ReturnValue)
{
    IndexedMethodCaller<ReturnType, ObjectType, ParamTypes...>(
        MethodPtr, Arguments, ReturnValue,
        TMakeIntegerSequence<int, sizeof...(ParamTypes)>());
}
```

**逐行解读**：

- `union { TMethodPtr Method; ReturnType(ObjectType::*Casted)(...); }` 是把"被擦除成 `void(FFakeObject::*)()`"的方法指针**按字节**重新解释成"`ReturnType(ObjectType::*)(ParamTypes...)`"。这一步只在 trampoline 自己内部发生，调用方给的字节是注册期 `CopyMethodPtr` 拷过来的——只要类型一致就安全。
- `Arguments[0]` 是 this 指针；`Arguments[1..N]` 是参数指针。`PassArgument<T>(Arguments + i+1)` 模板根据 `T` 是否是引用 / 指针决定怎么解引用——这在 §2.5 展开。
- `TIntegerSequence<int, TIndices...>` 是经典编译期 trick：在 `IndexedMethodCaller` 内部把 `TIndices...` 展开成 `0, 1, 2, ...`，从而把变长 `Args + 1`、`Args + 2`、`Args + 3`、…… 全部摆开成一次性参数。
- `new(ReturnValue) (typename TReferenceToPtr<ReturnType>::Type)(...)` 对应"返回值就地构造在 `ReturnValue` 指向的 buffer"。`TReferenceToPtr` 把返回类型 `T&` 替换成 `T*`，使得**返回引用**也能进 placement new 写。

void 返回的 `ReNativeRuntimeLinkedMethodCallerVoid` 同理，少一层 placement new。

### 2.4 `ReNativeRuntimeLinkedFunctionCaller`：全局函数 trampoline

形态与 `ReNativeRuntimeLinkedMethodCaller` 几乎一致，区别只是没有 `this`：

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Core/FunctionCallers.h
// 函数: IndexedFunctionCaller / ReNativeRuntimeLinkedFunctionCaller
// ============================================================================
template<typename ReturnType, typename... ParamTypes, int... TIndices>
FORCEINLINE void IndexedFunctionCaller(TFunctionPtr FunctionPtr, void** Arguments,
                                       void* ReturnValue,
                                       TIntegerSequence<int, TIndices...>)
{
    union {
        TFunctionPtr Function;
        ReturnType(*Casted)(ParamTypes...);
    } CastedFunctionPtr;
    CastedFunctionPtr.Function = FunctionPtr;
    new(ReturnValue) (typename TReferenceToPtr<ReturnType>::Type)(
        GetAddressIfReference<ReturnType>(
            (CastedFunctionPtr.Casted)(
                (PassArgument<ParamTypes>(Arguments + TIndices))...    // ★ 注意：i 而非 i+1
            )
        )
    );
}
```

唯一区别：参数索引从 0 开始（没有 this 占位）。

### 2.5 `PassArgument<T>` 与 `GetAddressIfReference<T>`：参数语义两板斧

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Core/FunctionCallers.h
// 函数: PassArgument / GetAddressIfReference
// ============================================================================
template<typename T>
FORCEINLINE typename TEnableIf<TIsPointer<T>::Value, T>::Type
PassArgument(void* Value)
{
    return *(T*)Value;            // ★ 指针参数：栈槽里就放着指针，直接 load
}

template<typename T>
FORCEINLINE typename TEnableIf<!TIsPointer<T>::Value, typename TRemoveReference<T>::Type&>::Type
PassArgument(void* Value)
{
    return **(typename TRemoveReference<T>::Type**)Value;   // ★ 值/引用参数：栈槽里放的是地址，需 ** 二次解引用
}

template<typename T>
FORCEINLINE typename TEnableIf<TIsReferenceType<T>::Value,
                              typename TRemoveReference<T>::Type*>::Type
GetAddressIfReference(const T& Value) {
    return (typename TRemoveReference<T>::Type*) & Value;   // 返回值是引用：取地址
}
```

**调用现场示意**：

```text
AS 栈布局（CALLSYS 之前 PSF + Push 操作做完）：
   StackPointer →  [ this  ptr  ]   <── Arguments[0] 指向这一格（成员函数）
                   [ arg0  ptr  ]   <── Arguments[1]
                   [ arg1  ptr  ]   <── Arguments[2]
                   ...

CallFunctionCaller 把 Arguments 整成：
   void* FunctionArgs[32];
   FunctionArgs[0] = *(void**)&StackArgs[0]            ← this（解引用一次）
   FunctionArgs[1] = *(void**)&StackArgs[paramOffset]  ← arg0 是 object/reference 时
                  或 &StackArgs[paramOffset]            ← arg0 是基础类型时

PassArgument<T> 接到 (void* Value) 之后：
   T 是 Pointer：     return *(T*)Value;
                      （注：经过 CallFunctionCaller 已经解引用过一次，所以这里再 *T* 一次得到 ptr）
   T 是 const FVector&：return **(FVector**)Value;
                       （AS 栈槽放地址，FunctionArgs 已经把"地址"取出来再放进 FunctionArgs[i]，
                        Trampoline 这里再拿 FunctionArgs[i] 作为 void*，**(T**) 二次解引用得到对象）
```

这套两板斧的目标：让 AS VM 不论参数语义是值 / 引用 / 指针，都能按统一的 `void**` 数组传递；trampoline 在编译期通过 `PassArgument<T>` 决定怎么把 `void*` 还原成正确的实参表达式。

---

## 三、`asCContext::CallFunctionCaller`：UE Fork 的统一调用分发

### 3.1 `CallSystemFunction` 顶层分支

```cpp
// ============================================================================
// 文件: ThirdParty/angelscript/source/as_callfunc.cpp
// 函数: CallSystemFunction
// 性质: AS 内核唯一的 native 函数调用入口
// ============================================================================
int CallSystemFunction(int id, asCContext *context)
{
    asCScriptEngine            *engine  = context->m_engine;
    asCScriptFunction          *descr   = engine->scriptFunctions[id];
    asSSystemFunctionInterface *sysFunc = descr->sysFuncIntf;

    if (sysFunc->caller.IsBound())                      // ★ UE Fork 主路径
        return context->CallFunctionCaller(descr);

    int callConv = sysFunc->callConv;
    if( callConv == ICC_GENERIC_FUNC || callConv == ICC_GENERIC_METHOD )
        return context->CallGeneric(descr);              // ★ 反射 fallback / asCALL_GENERIC

    context->SetInternalException(
        "Native calling convention support is disabled. Make sure you're passing a correct Caller.");
    return 0;
    // 下面整段 #if 0 的 200 行历史代码是上游 AngelScript 的"asCALL_THISCALL → 平台汇编桥"派发
    // 已经被 UE Fork 注释掉，因为本插件所有路径要么走 caller，要么走 generic
}
```

**关键理解**：UE Fork 把"AS 内核选哪条 ABI 桥来调 native"这个决定**完全外移**到了 `caller`——只要注册时 `MakeFunctionCaller` 推出了一个有效 trampoline，AS 内核就不必关心 thiscall / cdecl / __stdcall 之间的差异，全部交给 trampoline 做最后一跳。`as_callfunc_x64_msvc.cpp`、`as_callfunc_arm64.cpp` 这一系列平台汇编桥**在本插件的 build 里基本只剩两条线还活着**：`ICC_GENERIC_FUNC` / `ICC_GENERIC_METHOD`（走 `CallGeneric`）以及"caller 没绑定"时的报错路径。

### 3.2 `CallFunctionCaller` 的栈展开与分发

```cpp
// ============================================================================
// 文件: ThirdParty/angelscript/source/as_context.cpp
// 函数: asCContext::CallFunctionCaller
// 节选自: 5231-5351 行；省略 WITH_EDITOR worldcontext 检查与异常处理
// ============================================================================
int asCContext::CallFunctionCaller(asCScriptFunction* descr)
{
    asSSystemFunctionInterface *sysFunc = descr->sysFuncIntf;
    asDWORD* StackArgs = m_regs.stackPointer;
    void* FunctionArgs[32];                                  // ★ 最多 32 槽
    void* ReturnAddress;
    unsigned int ArgIndex = 0;

    // (a) 若是成员函数：把 this 从栈顶弹出
    void *currentObject = 0;
    if( sysFunc->callConv >= ICC_THISCALL ) {
        FunctionArgs[ArgIndex] = *(void**)&StackArgs[0];     // this
        if( FunctionArgs[ArgIndex] == nullptr ) {
            SetInternalException(TXT_NULL_POINTER_ACCESS);
            return 0;
        }
        ArgIndex++;
    }

    // (b) 第一参元数据：scriptFunction / objectType（用于 BindGenericGenericFunction）
    if (sysFunc->passFirstParamMetaData != asEFirstParamMetaData::None) {
        FunctionArgs[ArgIndex++] = (sysFunc->passFirstParamMetaData
            == asEFirstParamMetaData::ScriptFunction) ? descr : descr->objectType;
    }

    // (c) 决定返回地址
    if( descr->DoesReturnOnStack() ) {                       // 大对象在栈上
        ReturnAddress = (sysFunc->callConv >= ICC_THISCALL)
            ? *(void**)(StackArgs + AS_PTR_SIZE)
            : *(void**)StackArgs;
    } else if (descr->returnType.IsObjectHandle() && !descr->returnType.IsReference()) {
        ReturnAddress = &m_regs.objectRegister;              // 句柄走 objectRegister
    } else {
        ReturnAddress = &m_regs.valueRegister;               // 值走 valueRegister
    }

    // (d) 逐参打包：根据 paramType 决定栈槽是直接值还是间接指针
    for (int i = 0, paramCount = descr->parameterOffsets.GetLength(); i < paramCount; ++i)
    {
        auto& paramType = descr->parameterTypes[i];
        auto paramOffset = descr->parameterOffsets[i];
        if (paramType.GetTokenType() == ttQuestion) {        // ?& 模板参数
            FunctionArgs[ArgIndex++] = *(void**)&StackArgs[paramOffset];
            FunctionArgs[ArgIndex]   = &StackArgs[paramOffset+2];
        }
        else if (paramType.IsObject() || paramType.IsReference()) {
            FunctionArgs[ArgIndex] = *(void**)&StackArgs[paramOffset];   // 间接：栈上是指针
        }
        else {
            FunctionArgs[ArgIndex] = &StackArgs[paramOffset];            // 直接：栈上是值
        }
        ++ArgIndex;
    }

    // (e) 进 trampoline：caller.type 决定走 method 还是 function 形态
    auto* tld = m_regs.tld;
    auto* prevActiveFunction = tld->activeFunction;
    tld->activeFunction = descr;

    if (sysFunc->caller.type == 1)
        sysFunc->caller.FunctionCaller(sysFunc->func, &FunctionArgs[0], ReturnAddress);   // ★ 全局/CDECL_OBJ*
    else //if (sysFunc->caller.type == 2)
        sysFunc->caller.MethodCaller(sysFunc->method, &FunctionArgs[0], ReturnAddress);   // ★ thiscall

    tld->activeFunction = prevActiveFunction;
    m_regs.objectType = descr->returnType.GetTypeInfo();
    m_callingSystemFunction = nullptr;

    return descr->totalSpaceBeforeFunction;
}
```

**逐段解读**：

- 段 (a)：thiscall 类调用约定（`ICC_THISCALL` 及其变体）需要 this 指针。栈顶第一格是 `this`——`*(void**)&StackArgs[0]` 把"AS 栈槽里放的指针值"取出来塞进 `FunctionArgs[0]`
- 段 (b)：`passFirstParamMetaData` 是 UE Fork 引入的额外通道。当用 `FAngelscriptBinds::PreviousBindPassScriptFunctionAsFirstParam()` 标记时，trampoline 第一个参数会被注入 `descr`（当前 `asCScriptFunction*`）或 `objectType`。`Bind_FString.cpp` 的 `Type_ToString` 用这个机制把 `ToString` 映射函数的引用从 userData 里取出来
- 段 (c)：返回值地址决策三分支——按值返回大对象走栈（`DoesReturnOnStack`）、句柄走 `objectRegister`、其他走 `valueRegister`。`ReturnAddress` 最终交给 trampoline 做 `placement new`
- 段 (d)：参数打包是关键：**对象 / 引用参数**栈槽里是地址（要解引用一次），**基础类型参数**栈槽里直接是值（取地址即可）。`?&` 模板参数一槽变两槽
- 段 (e)：分发到 trampoline——`caller.type == 1` 走 `FuncPtr(sysFunc->func, args, ret)`、`type == 2` 走 `MethodPtr(sysFunc->method, args, ret)`。注意 union 内 `func` / `method` 是同一段字节，但形参签名不同（前者收 `TFunctionPtr`、后者收 `TMethodPtr`），影响调用方编译器选择哪条调用约定

### 3.3 与 `asCALL_THISCALL_OBJFIRST` / `OBJLAST` 的关系

UE 插件中常见的 `asCALL_CDECL_OBJFIRST`（mixin）与 `asCALL_THISCALL`（普通方法）在 caller 路径下**实际机器码完全一样**——都被翻译成 `ReNativeRuntimeLinkedMethodCaller<...>` 或 `ReNativeRuntimeLinkedFunctionCaller<...>`，trampoline 不区分两者。注册时 AS 内核记录 `callConv` 仅用于 `CallFunctionCaller` 段 (a) 决定要不要弹 this。

`asCALL_GENERIC`（反射 fallback / `Bind_BlueprintEvent` 三个 helper）**才**真正不走 caller 路径——见 §四。

---

## 四、`CallGeneric`：`asCALL_GENERIC` 的另一条岔路

### 4.1 何时走这条路

任何注册为 `asCALL_GENERIC` 的函数都不通过 `caller` 而走 `CallGeneric`：

```cpp
// ============================================================================
// 文件: ThirdParty/angelscript/source/as_context.cpp
// 函数: asCContext::CallGeneric
// 节选自: 5166-5229 行
// ============================================================================
int asCContext::CallGeneric(asCScriptFunction *descr)
{
    asSSystemFunctionInterface *sysFunc = descr->sysFuncIntf;
    void (*func)(asIScriptGeneric*) = (void (*)(asIScriptGeneric*))sysFunc->func;
    int popSize = sysFunc->paramSize;
    asDWORD *args = m_regs.stackPointer;

    void *currentObject = 0;
    if( sysFunc->callConv == ICC_GENERIC_METHOD ) {
        popSize += AS_PTR_SIZE;
        currentObject = (void*)*(asPWORD*)(args);
        if( currentObject == 0 ) {
            SetInternalException(TXT_NULL_POINTER_ACCESS);
            return 0;
        }
    }

    if( descr->DoesReturnOnStack() ) popSize += AS_PTR_SIZE;

    asCGeneric gen(m_engine, descr, currentObject, args);     // ★ 把 AS 栈包成 asCGeneric

    auto* tld = m_regs.tld;
    auto* prevActiveFunction = tld->activeFunction;
    tld->activeFunction = descr;

    try { func(&gen); }                                        // ★ 直接调用 generic trampoline
    catch (...) { HandleAppException(); }

    tld->activeFunction = prevActiveFunction;
    m_regs.valueRegister  = gen.returnVal;                     // 写回 value/object register
    m_regs.objectRegister = gen.objectRegister;
    m_regs.objectType     = descr->returnType.GetTypeInfo();
    return popSize;
}
```

**与 `CallFunctionCaller` 的对照**：

| 维度 | `CallFunctionCaller` | `CallGeneric` |
|------|--------------------|---------------|
| 适用 callConv | 任何（前提 `caller.IsBound()`） | `ICC_GENERIC_FUNC` / `ICC_GENERIC_METHOD` |
| 参数打包形态 | `void* FunctionArgs[32]`（按位置数组） | `asCGeneric` 对象（按索引方法） |
| 返回值写入 | trampoline 用 placement new 直接写 | 函数体调 `gen.SetReturn*()` 设置 |
| 异常处理 | 上层 / 调用方负责 | 内置 `try/catch` 捕获 C++ 异常转 AS 异常 |
| 性能 | 模板内联，~2-3 倍快 | 间接 + 虚分发，慢 |
| 用例 | UHT 灌库 / 手写Runtime-linked / FunctionLibrary mixin | 反射 fallback / BlueprintEvent / Delegate |

### 4.2 `asCGeneric` 接口：反射 fallback 的输入面

`Bind_BlueprintCallable` 的反射 fallback 注册的就是 `asCALL_GENERIC` 函数：函数体收 `asIScriptGeneric*`，从中按索引取参数：

```cpp
// 反射 fallback 函数体片段（节选自 BlueprintCallableReflectiveFallback.cpp）
void CallBlueprintCallableReflectiveFallback(asIScriptGeneric* InGeneric)
{
    auto* Generic  = static_cast<asCGeneric*>(InGeneric);
    auto* Function = static_cast<asCScriptFunction*>(Generic->GetFunction());
    auto* Signature = static_cast<FBlueprintCallableReflectiveSignature*>(Function->GetUserData());
    UObject* TargetObject = Signature->StaticObject != nullptr
        ? Signature->StaticObject
        : static_cast<UObject*>(Generic->GetObject());            // ★ generic 接口取 this

    // ... GetAddressOfArg(i) 取参数；GetAddressOfReturnLocation() 取返回槽
    InvokeReflectiveUFunctionFromGenericCallCached(Generic, TargetObject,
        Signature->UnrealFunction, Signature->GetOrBuildCache(),
        Signature->bInjectMixinObject);
}
```

`asCGeneric::GetAddressOfArg(i)` 内部会按 `descr->parameterTypes[i]` 决定返回值（值类型返回栈槽地址、对象类型 `*(void**)栈槽` 解引用），与 `CallFunctionCaller` 段 (d) 的逻辑相同——只是把"打包"动作从 VM 一次性完成改成"按需懒取"。

---

## 五、反射 fallback：没有直接函数指针时怎么办

### 五.1 触发条件

`Bind_Defaults`（Layer C，`Late+100`）按 UClass 遍历到一个 UFunction 时，会先查 `ClassFunctionBindings[OwningClass][FunctionName]`：

- 找到且 `Entry->FunctionPointer.IsBound() == true` → 走Runtime-linked（§三 caller 路径）
- 找到但 `IsBound() == false` 或根本没找到 → 进入反射 fallback 决策

反射 fallback 进一步过滤（来自 `BlueprintCallableReflectiveFallback.cpp::EvaluateReflectionFallback`）：

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Binds/BlueprintCallableReflectiveFallback.cpp
// 函数: EvaluateReflectionFallback
// ============================================================================
EReflectionFallbackResult EvaluateReflectionFallback(const UFunction* Function)
{
    if (Function == nullptr)                                          return NullFunction;
    const UClass* OwningClass = Function->GetOuterUClass();
    if (OwningClass == nullptr)                                       return MissingOwningClass;
    if (OwningClass->HasAnyClassFlags(CLASS_Interface))               return InterfaceClass;
    if (Function->HasMetaData(NAME_BlueprintCallableReflectiveFallback_CustomThunk))
                                                                      return CustomThunk;
    if (GetNonReturnParameterCount(Function) > 16 /* MaxArgs */)      return TooManyArguments;
    return Success;
}
```

### 5.2 注册：`asCALL_GENERIC` 三选一

`BindReflectiveFunction` 按"AS 端是 static / mixin / 普通成员"三态决定 generic trampoline 形态：

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Binds/BlueprintCallableReflectiveFallback.cpp
// 函数: BindReflectiveFunction（节选）
// ============================================================================
if (Signature.bStaticInScript) {
    // 全局函数（含命名空间）
    int FunctionId = FAngelscriptBinds::BindGlobalFunctionDirect(
        Signature.Declaration,
        asFUNCTION(CallBlueprintCallableReflectiveFallback),
        asCALL_GENERIC,                                           // ★ 注意：generic
        ASAutoCaller::FunctionCaller::Make(),                     // ★ 空 caller
        ReflectiveSignature);                                     // ★ userData = signature
    // ...
}
else if (Signature.bStaticInUnreal) {
    // mixin：UE 端是 static，但 AS 端"伪装成"成员函数
    ReflectiveSignature->bInjectMixinObject = true;
    int FunctionId = FAngelscriptBinds::BindMethodDirect(
        Signature.ClassName, Signature.Declaration,
        asFUNCTION(CallBlueprintCallableReflectiveFallback),
        asCALL_GENERIC,
        ASAutoCaller::FunctionCaller::Make(),
        ReflectiveSignature);
}
else {
    // 普通成员：UE 端是 member，AS 端也是 member
    int FunctionId = FAngelscriptBinds::BindMethodDirect(
        InType->GetAngelscriptTypeName(), Signature.Declaration,
        asFUNCTION(CallBlueprintCallableReflectiveFallback),
        asCALL_GENERIC,
        ASAutoCaller::FunctionCaller::Make(),
        ReflectiveSignature);
}
```

注意 `ASAutoCaller::FunctionCaller::Make()` 不带模板参数——返回的是空 caller（`type=0`，`MethodPtr=nullptr`）。这意味着 `caller.IsBound() == false`，`CallSystemFunction` 会走 `CallGeneric` 而不是 `CallFunctionCaller`。

### 5.3 `FReflectiveParamCache`：第一次调用时构建的"快速分发表"

反射 fallback 的核心性能开销不是 `UFunction::Invoke` 本身，而是**每次调用都用 `TFieldIterator<FProperty>` 遍历参数列表**。`FReflectiveParamCache` 把这个开销摊到第一次调用：

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Binds/BlueprintCallableReflectiveFallback.cpp
// 类型: FReflectiveParamCache (节选关键字段)
// ============================================================================
struct FReflectiveParamCache
{
    struct FParamEntry
    {
        FProperty* Property = nullptr;
        int32 UEOffset = 0;          // FProperty::GetOffset_ForInternal()
        int32 Size     = 0;          // FProperty::GetSize()
        bool bIsSimpleCopy   = false;  // 可以 memcpy 而非走 CopySingleValue
        bool bNeedInitialize = false;
        bool bNeedDestroy    = false;
        bool bRequiresOutParmRec = false;  // CPF_OutParm + 非 CPF_ReturnParm
        bool bIsWritebackOut    = false;  // 真正的非 const out 参（要写回 AS）
        bool bIsReferenceParam  = false;
    };

    TArray<FParamEntry, TInlineAllocator<8>> Params;
    TArray<int32,        TInlineAllocator<4>> OutParamIndices;
    FParamEntry Return;
    int32 ParmsSize         = 0;
    int32 ReturnValueOffset = MAX_uint16;
    bool  bHasReturn        = false;
    bool  bIsNetFunction    = false;
};
```

构建时机：`Signature->GetOrBuildCache()` 在每个 signature 上 lazy 构建，落进 `TOptional<FReflectiveParamCache>`，与 signature 同生命周期。

### 5.4 `InvokeReflectiveUFunctionFromGenericCallCached`：核心调用循环

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Binds/BlueprintCallableReflectiveFallback.cpp
// 函数: InvokeReflectiveUFunctionFromGenericCallCached （节选关键路径）
// ============================================================================
bool InvokeReflectiveUFunctionFromGenericCallCached(
    asCGeneric* Generic, UObject* TargetObject, UFunction* Function,
    const FReflectiveParamCache& Cache, bool bInjectMixinObject)
{
    uint8* ParameterBuffer = (uint8*)FMemory_Alloca(Cache.ParmsSize);    // ★ alloca on stack
    FMemory::Memzero(ParameterBuffer, Cache.ParmsSize);

    // 1. 初始化 non-trivial 参数槽（FString / TArray / USTRUCT 等）
    for (const auto& E : Cache.Params)
        if (E.bNeedInitialize) E.Property->InitializeValue_InContainer(ParameterBuffer);

    // 2. 把 AS 栈上的参数拷贝进 UFunction 参数槽
    void* OutScriptAddresses[16] = {};
    int32 ScriptArgIndex = 0;
    for (int32 ParamIndex = 0; ParamIndex < Cache.Params.Num(); ++ParamIndex)
    {
        const auto& E = Cache.Params[ParamIndex];
        void* Destination = ParameterBuffer + E.UEOffset;
        if (bInjectMixinObject && ParamIndex == 0) { /* 注入 this */ continue; }

        void* SourceAddress = ResolveScriptArgumentAddress(E.Property,
            Generic->GetAddressOfArg(ScriptArgIndex));
        if (E.bIsSimpleCopy) FMemory::Memcpy(Destination, SourceAddress, E.Size);
        else                 E.Property->CopySingleValue(Destination, SourceAddress);

        if (E.bIsWritebackOut) OutScriptAddresses[ParamIndex] = SourceAddress;
        ++ScriptArgIndex;
    }

    // 3. 构造 FFrame + FOutParmRec 链表（UFunction::Invoke 契约）
    FFrame NewStack(TargetObject, Function, ParameterBuffer, nullptr, Function->ChildProperties);
    FOutParmRec** LastOut = &NewStack.OutParms;
    for (int32 OutIdx : Cache.OutParamIndices) {
        FOutParmRec* OutRec = (FOutParmRec*)FMemory_Alloca(sizeof(FOutParmRec));
        OutRec->Property = Cache.Params[OutIdx].Property;
        OutRec->PropAddr = ParameterBuffer + Cache.Params[OutIdx].UEOffset;
        OutRec->NextOutParm = nullptr;
        if (*LastOut) { (*LastOut)->NextOutParm = OutRec; LastOut = &(*LastOut)->NextOutParm; }
        else          { *LastOut = OutRec; }
    }

    uint8* ReturnAddress = Cache.bHasReturn
        ? ParameterBuffer + Cache.ReturnValueOffset : nullptr;

    // 4. 分发：FUNC_Net 走 GetFunctionCallspace + CallRemoteFunction
    if (Cache.bIsNetFunction) {
        const int32 Callspace = TargetObject->GetFunctionCallspace(Function, &NewStack);
        if (Callspace & FunctionCallspace::Remote) {
            TargetObject->CallRemoteFunction(Function, ParameterBuffer, NewStack.OutParms, &NewStack);
        }
        if (Callspace & FunctionCallspace::Local) {
            Function->Invoke(TargetObject, NewStack, ReturnAddress);
        }
    } else {
        Function->Invoke(TargetObject, NewStack, ReturnAddress);
    }

    // 5. out 参数回写到 AS 栈；返回值回写到 generic.returnLocation；销毁参数槽
    for (int32 OutIdx : Cache.OutParamIndices) {
        const auto& E = Cache.Params[OutIdx];
        if (!E.bIsWritebackOut) continue;
        void* ScriptAddr = OutScriptAddresses[OutIdx];
        if (E.bIsSimpleCopy) FMemory::Memcpy(ScriptAddr, ParameterBuffer + E.UEOffset, E.Size);
        else                 E.Property->CopySingleValue(ScriptAddr, ParameterBuffer + E.UEOffset);
    }
    if (Cache.bHasReturn) {
        void* RetDst = Generic->GetAddressOfReturnLocation();
        if (Cache.Return.bIsSimpleCopy)
            FMemory::Memcpy(RetDst, ParameterBuffer + Cache.ReturnValueOffset, Cache.Return.Size);
        else {
            Cache.Return.Property->InitializeValue(RetDst);
            Cache.Return.Property->CopySingleValue(RetDst,
                ParameterBuffer + Cache.ReturnValueOffset);
        }
    }
    for (const auto& E : Cache.Params)
        if (E.bNeedDestroy) E.Property->DestroyValue_InContainer(ParameterBuffer);
    return true;
}
```

**关键性质**：

- 参数 buffer 用 `FMemory_Alloca`（栈上），尺寸 = `Function->PropertiesSize`——比 `ParmsSize` 大，包含蓝图 locals 槽位（用于 BP 生成的反射 fallback）
- `FOutParmRec` 链表是 UFunction VM 契约：**所有 `CPF_OutParm` 参数都必须挂在链上**，包括 `const` ref（`CPF_ConstParm | CPF_OutParm`）。漏挂会导致 `FFrame::StepExplicitProperty` 解空指针
- `FUNC_Net` 分支保证 RPC 路由：在客户端调 Server RPC 时，`Callspace::Remote` 会走 `CallRemoteFunction` 序列化到网络栈；`Local` 才本地执行
- `bIsSimpleCopy` 是关键优化：POD / `FObjectPropertyBase` 子类（含 `TObjectPtr<T>`）走 `FMemory::Memcpy`；`FString` / `TArray` / `FStruct` 走 `CopySingleValue`（虚函数派发，慢）

### 5.5 性能模式：`as.ReflectiveFallback.UseCache`

CVar `as.ReflectiveFallback.UseCache` 控制是否启用 cache 路径：

```cpp
// CVarReflectiveFallbackUseCache (default 1)
// 1 = 走 InvokeReflectiveUFunctionFromGenericCallCached（FFrame + UFunction::Invoke）
// 0 = 走 InvokeReflectiveUFunctionFromGenericCallProcessEvent（每次走 ProcessEvent）
```

实测典型签名 cache 路径比 ProcessEvent 路径快 **3–6 倍**——主要省的是 `TFieldIterator` 遍历 + 虚 `CopySingleValue` 派发。开发期可以 `as.ReflectiveFallback.UseCache 0` 切回 legacy 路径做 A/B 对比，定位"cache 路径与 BP 行为不一致"的回归。

---

## 六、调用约定矩阵：UE Fork 的实际取值

### 6.1 注册期六个核心入口

`AngelscriptBinds.cpp` 提供六条主要注册接口，每条对应 `Engine->RegisterObjectMethod` / `RegisterGlobalFunction` 的一种调用约定：

| 入口 | 注册到 AS 的约定 | trampoline 形态 | 典型用例 |
|------|----------------|---------------|---------|
| `BindMethod` | `asCALL_THISCALL` | `ReNativeRuntimeLinkedMethodCaller` (`type=2`) | 普通成员函数（`AActor::GetActorLocation`） |
| `BindMethodDirect(callConv)` | 显式指定 | 取决于 callConv | `asCALL_THISCALL` Runtime-linked / `asCALL_CDECL_OBJFIRST` mixin / `asCALL_GENERIC` 反射 fallback |
| `BindBehaviour` | `asCALL_THISCALL` | `ReNativeRuntimeLinkedMethodCaller` | Constructor / Destructor / opAssign 等 behaviour |
| `BindExternBehaviour` | `asCALL_CDECL_OBJFIRST` | `ReNativeRuntimeLinkedFunctionCaller` (`type=1`) | 全局函数仿成员 behaviour（如 lambda 构造器） |
| `BindStaticBehaviour` | `asCALL_CDECL` | `ReNativeRuntimeLinkedFunctionCaller` | 类静态 behaviour |
| `BindExternMethod` | `asCALL_CDECL_OBJFIRST` | `ReNativeRuntimeLinkedFunctionCaller` | mixin 方法（lambda / FunctionLibrary） |
| `BindGlobalFunction` | `asCALL_CDECL` | `ReNativeRuntimeLinkedFunctionCaller` | 全局工具函数（`Print`、`FMath::Abs`） |
| `BindGlobalFunctionDirect(callConv)` | 显式指定 | 取决于 | 反射 fallback 全局函数走 `asCALL_GENERIC` |
| `BindGlobalGenericFunction` | `asCALL_GENERIC` | 无 caller，走 `CallGeneric` | 委托工厂、反射 trampoline |
| `GenericMethod` | `asCALL_GENERIC` | 无 caller | 模板容器特殊 callback |

### 6.2 实际取值分布（仓库 grep）

```text
asCALL_THISCALL              — Bind_BlueprintCallable (Runtime-linked普通方法)、所有 BindMethod 调用
asCALL_CDECL_OBJFIRST        — Bind_BlueprintCallable (静态→mixin)、Bind_FString::Type_ToString
                                所有 BindExternMethod / BindExternBehaviour
asCALL_CDECL                 — BindGlobalFunction 默认；BindStaticBehaviour
asCALL_GENERIC               — Bind_BlueprintEvent (CallStaticWithSignature 等三个 helper)
                                BlueprintCallableReflectiveFallback (反射兜底)
                                BindGlobalGenericFunction / GenericMethod
```

UE Fork 中**所有 native 调用约定都通过 caller 走同一条 `CallFunctionCaller` 路径**——`callConv` 仅用于决定"this 是否在栈顶"以及参数布局解释。`asCALL_GENERIC` 是唯一与之分叉的路径。

### 6.3 与 AS 内核 16 种 `internalCallConv` 的映射

| 应用层 | 内部 ICC | UE Fork 调用路径 |
|--------|---------|-----------------|
| `asCALL_GENERIC` | `ICC_GENERIC_FUNC` / `ICC_GENERIC_METHOD` | `CallGeneric`（不走 caller） |
| `asCALL_THISCALL` | `ICC_THISCALL` | caller 走 `MethodCaller` |
| `asCALL_CDECL` | `ICC_CDECL` | caller 走 `FunctionCaller` |
| `asCALL_CDECL_OBJFIRST` | `ICC_CDECL_OBJFIRST` | caller 走 `FunctionCaller`（this 在栈顶，trampoline 用 `Arguments[0]`） |
| `asCALL_CDECL_OBJLAST` | `ICC_CDECL_OBJLAST` | caller 走 `FunctionCaller`（this 在最后） |
| `asCALL_STDCALL` | `ICC_STDCALL` | 同 cdecl，caller 路径忽略 ABI 差异 |
| `asCALL_THISCALL_OBJFIRST` | `ICC_THISCALL_OBJFIRST` | caller 路径，注意"双 this" |

**关键洞察**：caller 路径下 `asCALL_*` 的差异**只影响参数顺序解释**，不影响"用什么寄存器 / 栈帧形态调"——后者由 trampoline 内部的 union cast 与 C++ 编译器一起决定。这正是为什么 `as_callfunc_x64_msvc.asm` 这种平台汇编桥可以被绕过：所有 ABI 知识都被压到了"trampoline 自己 inline 出的 `(((ObjectType*)Arguments[0])->*Casted)(args...)`"这一行 C++ 上，由编译器对该平台的代码生成器去处理。

---

## 七、UHT vs 手写 vs 反射 fallback：三条路径同台对照

### 7.1 三种注册形态在 `Bind_*` 中的痕迹

```text
================================================================================
  对一个 UFunction 的注册，三种来源走的代码形态对比
================================================================================

[Layer A: UHT 灌库 — Late+50]
  AS_FunctionBinding_Engine.gen.cpp:
  AS_FORCE_LINK const FBind Bind_AS_FunctionBinding_Engine(TEXT("UHT.FunctionBinding.Engine"), EOrder::Late+50, []
  {
      FAngelscriptBinds::RegisterFunctionBinding(
          AAngelscriptPropertyAccessorCarrier::StaticClass(), "FetchScore",
          { ERASE_AUTO_METHOD_PTR(AAngelscriptPropertyAccessorCarrier, FetchScore) });
                     │
                     │ 展开后：
                     ▼
          FAngelscriptFunctionBinding{
              FunctionPointer = MakeAutoMethodPtr(&AAngelscriptPropertyAccessorCarrier::FetchScore),
              FunctionCaller  = ASAutoCaller::MakeFunctionCaller(&...::FetchScore),
              bReflectiveFallbackBound = false
          }
      // ★ 只灌库到 ClassFunctionBindings，不调 RegisterObjectMethod
  });

[Layer B: 手写Runtime-linked — Late-1（如 Bind_AActor_Base）]
  AS_FORCE_LINK const FBind Bind_AActor_Base(EOrder::Late-1, []
  {
      auto AActor_ = ExistingClass("AActor");
      AActor_.Method("FVector GetActorLocation() const",
          METHOD_TRIVIAL(AActor, GetActorLocation));
                  │
                  │ METHOD_TRIVIAL 展开为：
                  │   asSMethodPtr<...>::Convert(&AActor::GetActorLocation),
                  │   ASAutoCaller::MakeFunctionCaller(&AActor::GetActorLocation),
                  │   ... bTrivial=true
                  ▼
      // 直接进 BindMethod → RegisterObjectMethod
      // sysFunc->func    = method ptr (asSFuncPtr)
      // sysFunc->caller  = {MethodPtr=&ReNativeRuntimeLinkedMethodCaller<FVector,AActor>, type=2}
      // callConv          = asCALL_THISCALL
  });

[Layer C: 反射 fallback — Late+100（Bind_Defaults 内部）]
  Bind_Defaults 遍历到 UClass = AActor、UFunction = SetActorRelativeLocation，
  发现 ClassFunctionBindings[AActor]["SetActorRelativeLocation"].FunctionPointer.IsBound() == false,
  且 EvaluateReflectionFallback() == Success:

      auto* RefSig = new FBlueprintCallableReflectiveSignature();
      RefSig->UnrealFunction = Function;
      RefSig->ArgCount       = 4;
      RefSig->ReturnType     = void;

      BindMethodDirect(
          "AActor", "void SetActorRelativeLocation(...)",
          asFUNCTION(CallBlueprintCallableReflectiveFallback),
          asCALL_GENERIC,                                ★ 注意：generic
          ASAutoCaller::FunctionCaller::Make(),          ★ 空 caller
          RefSig);                                       ★ userData = 反射签名
      // sysFunc->func     = &CallBlueprintCallableReflectiveFallback
      // sysFunc->caller   = {ptr=null, type=0}
      // sysFunc->callConv = ICC_GENERIC_METHOD
      // 调用时走 CallGeneric → CallBlueprintCallableReflectiveFallback(asCGeneric*)
      // → 取 RefSig from userData → InvokeReflectiveUFunctionFromGenericCallCached
      // → FFrame + UFunction::Invoke (走 ProcessInternal)
```

### 7.2 调用现场速查

| 路径 | 字节码 | 选择分支 | 实际跳转 |
|------|-------|---------|---------|
| Layer A/B Runtime-linked | `CALLSYS <id>` | `caller.IsBound() == true` | `CallFunctionCaller → ReNativeRuntimeLinked*Caller<Ret,Cls,Args...> → 编译器 inline 真函数体` |
| Layer C 反射 | `CALLSYS <id>` | `caller.IsBound() == false` & `callConv == ICC_GENERIC_METHOD` | `CallGeneric → CallBlueprintCallableReflectiveFallback(asCGeneric*) → FFrame + UFunction::Invoke` |
| `BindBlueprintEvent`（BP 端可重写） | `CALLSYS <id>` | 同 Layer C | `Call*WithSignature → InvokeReflectionFallbackFromGenericCall → 同上` |
| `BindGlobalGenericFunction`（手写 generic） | `CALLSYS <id>` | 同 Layer C | 直接进开发者写的 `void Fn(asIScriptGeneric*)` 函数体 |

### 7.3 性能数量级（典型签名）

按经验数据，5 参数返回 `FVector` 的 UFunction：

- Layer A/B Runtime-linked（caller 路径）：~80 ns / call
- Layer C 反射（cache 路径）：~280 ns / call（3.5x slower）
- Layer C 反射（ProcessEvent 路径）：~700 ns / call（~9x slower）
- `BindBlueprintEvent` + BP override：~1200 ns / call（再叠加 BP VM 启动）

UHT 把热路径都搬到 Layer A 是核心优化目标——剩下的 Long-tail 由 Layer C cache 路径兜底，已经接近"纯反射"性能上限。

---

## 八、异常路径与边界条件

### 8.1 AS 端异常

`asCContext::Execute` 在 `CallSystemFunction` 返回后会检查 `m_status` 是否被 `SetInternalException` 设置。本文涉及的异常源：

| 异常源 | 位置 | 触发条件 |
|--------|------|---------|
| `TXT_NULL_POINTER_ACCESS` | `CallFunctionCaller` 段 (a) | thiscall 时栈顶 this == 0 |
| `TXT_NULL_POINTER_ACCESS` | `CallGeneric` ICC_GENERIC_METHOD 分支 | 同上 |
| `"Native calling convention support is disabled"` | `CallSystemFunction` | caller 未绑定且 callConv 不是 GENERIC（不应该发生） |
| `"Calling a function that requires WorldContext from a BlueprintThreadSafe..."` | `CallFunctionCaller` `WITH_EDITOR` 分支 | `asTRAIT_USES_WORLDCONTEXT` 函数被 thread-safe 上下文调 |
| `"Attempted reflective BlueprintCallable dispatch without a bound UFunction."` | `CallBlueprintCallableReflectiveFallback` | userData 中 signature 为空 |
| `"Attempted reflective BlueprintCallable dispatch without a target object."` | 同上 | 取不到 this 与 StaticObject |

异常发生后，VM 把当前帧 unwind 到 `Execute` 出口；`asCContext::HandleAppException` 捕获 C++ 异常转 AS 异常（仅在 `CallGeneric` 内有 try/catch；`CallFunctionCaller` 不 catch——native Runtime-linked函数抛 C++ 异常会直接逃出到 `Execute`）。

### 8.2 RPC / 网络分支

`FUNC_Net` 函数走反射 fallback 时 `bIsNetFunction == true`，会进 `GetFunctionCallspace + CallRemoteFunction` 双轨。Runtime-linked路径下 RPC 函数的 `exec*` thunk 内部会自己处理（UHT 生成的 `exec*` 调用 `CallRemoteFunction`），caller 路径不需要单独处理网络分支。

### 8.3 异常对栈/资源的影响

| 路径 | 抛异常时 alloca buffer | out 参数已写回 |
|------|---------------------|---------------|
| Runtime-linked（caller） | 直接展开栈，buffer 跟随帧释放 | 取决于 trampoline 是否已执行 placement new |
| 反射 cache | `Generic` 在 `CallGeneric` 内有 try/catch，能 unwind | `if (failed) ParameterBuffer.DestroyValue_InContainer` 兜底析构 |
| 反射 ProcessEvent | 同上 | 同上 |

### 8.4 `passFirstParamMetaData`：第一参元数据通道

UE Fork 引入的 `asEFirstParamMetaData` 在 `CallFunctionCaller` 段 (b) 起作用，三种取值：

```cpp
enum class asEFirstParamMetaData {
    None,            // 默认
    ScriptFunction,  // 把当前 asCScriptFunction* 注入到第一个参数槽
    ObjectType,      // 把 descr->objectType 注入到第一个参数槽
};
```

调用方约定见 `Bind_FString::Type_ToString`：注册 `ToString` 时显式标记 `PreviousBindPassScriptFunctionAsFirstParam()`，trampoline 第一个参数收到 `asCScriptFunction*`，函数体从 `ScriptFunction->userData` 取出真正的 `FToStringFunction` 指针——这是把 trampoline 派发与"哪个具体类型的 ToString"绑定的优雅做法。

---

## 九、与 `Type_BaseClass.md` §六 的边界

本文写"AS → C++"，`Type_BaseClass.md` §六 写"C++ → AS"，两者在 native 桥层面是对偶的：

| 维度 | 本文（Type_FunctionCaller） | `Type_BaseClass` §六 |
|------|--------------------------|---------------------|
| 调用方向 | AS 字节码 → C++ 函数 | UE C++ / 蓝图 VM → AS 字节码 |
| 入口 | `CallSystemFunction` (AS 内核) | `UASFunctionNativeThunk` (UE FFrame 入口) |
| 中间桥 | `CallFunctionCaller` + caller trampoline | `RuntimeCallFunction` → `AngelscriptCallFromBPVM` |
| 栈布局 | AS stackArgs → `FunctionArgs[32]` → C++ 栈帧 | `FFrame` → AS context stack |
| 关键检查 | `caller.IsBound()` 决定走 caller 还是 generic | `ResolveScriptVirtual` 决定调到哪个 AS 类的 override |
| 性能优化目标 | UHT 灌库 + 反射 cache | StaticJIT + RawJITCall |
| 异常入口 | `SetInternalException` | `Stack.bAbortingExecution` |

调用栈合体示例（AS 调用 C++ 蓝图函数，C++ 内部又回调 AS BlueprintEvent）：

```text
AS 脚本     :  Foo();               Foo 是 BlueprintCallable
   │   字节码 CALLSYS
   ▼
AS 内核     :  CallSystemFunction(id) → caller.IsBound()? Yes
   │
   ▼
caller 路径 :  asCContext::CallFunctionCaller(descr)        ← 本文 §三
   │           sysFunc->caller.MethodCaller(...)
   ▼
trampoline  :  ReNativeRuntimeLinkedMethodCaller<...>(method, args, ret)  ← 本文 §二
   │           ((Cls*)args[0])->*method(args[1...])
   ▼
C++ 函数体  :  Cls::Foo() {
   │              SomeBlueprintEvent.Broadcast(...);          ← 反向调用 BP / AS
   │           }
   │
   ▼
UE 蓝图 VM  :  ProcessEvent(Function, Parms)                  ← Type_BaseClass §六
   │           Function->NativeFunc → UASFunctionNativeThunk
   ▼
AS 反向桥   :  UASFunction::RuntimeCallFunction(...)
                 ResolveScriptVirtual(this, Object)
                 → Context->Execute()                          ← 进入 AS 字节码
```

两条桥独立实现、独立优化、独立测试，但在同一个 `asCContext` 实例上交错运行（VM 重入由 AS context stack 处理，详见 `AS_VirtualMachine.md`）。

---

## 附录 A：调用链速查表

### A.1 注册形态 → 运行期分支

| 注册接口 | callConv | caller.type | 运行期分发 | 真正落到 |
|---------|---------|------------|-----------|---------|
| `BindMethod(...)` | `THISCALL` | 2 | `CallFunctionCaller → MethodCaller` | C++ 成员函数本体 |
| `BindMethodDirect(THISCALL)` | `THISCALL` | 2 | 同上 | 同上（包括 UHT Runtime-linked） |
| `BindMethodDirect(CDECL_OBJFIRST)` | `CDECL_OBJFIRST` | 1 | `CallFunctionCaller → FunctionCaller` | mixin lambda / static 转 member |
| `BindMethodDirect(asCALL_GENERIC)` | `GENERIC_METHOD` | 0 | `CallGeneric → 反射 fallback handler` | 进 `FFrame + UFunction::Invoke` |
| `BindGlobalFunction(...)` | `CDECL` | 1 | `CallFunctionCaller → FunctionCaller` | 全局函数本体 |
| `BindGlobalFunctionDirect(GENERIC)` | `GENERIC_FUNC` | 0 | `CallGeneric` | 反射 fallback / 委托 helper |
| `GenericMethod(...)` | `GENERIC_METHOD` | 0 | `CallGeneric` | 手写 `void(*)(asIScriptGeneric*)` |
| `BindBehaviour(...)` | `THISCALL` | 2 | 同 BindMethod | Constructor / Destructor / opAssign |

### A.2 ASCII 速查图

```text
AS Stack     CallFunctionCaller        Trampoline                   C++ Function
=========    ================          ===========================  =============
[ this   ]   FunctionArgs[0] = this    ReNativeRuntimeLinkedMethodCaller<R,C,Ts...>  Cls::Foo(a, b)
[ argA   ]   FunctionArgs[1] = &argA      union { method ptr ↔                   │
[ argB   ]   FunctionArgs[2] = &argB             R(C::*)(Ts...) }               │
                                          ((C*)args[0])->*Casted(                │
ReturnAddr   ReturnAddress = &valReg          PassArgument<Ts>(args+i+1)...      │
                                          )                                      │
                                          new(retAddr) R(...)                    │
                                          ───────────────────────────────────────┘
```

### A.3 反射 fallback 处理决策

```text
Layer C 遇到 UClass.UFunction:
   │
   ├── UFunction == nullptr?                    → skip
   ├── OwningClass == nullptr?                  → skip
   ├── OwningClass is CLASS_Interface?          → skip
   ├── HasMetaData("CustomThunk")?              → skip
   ├── ParamCount > 16?                         → skip
   ├── ShouldSkipBlueprintCallableFunction?     → skip
   ├── ClassFunctionBindings[Class][Name].FunctionPointer 已绑? ─ Yes ─→ Layer A/B caller 路径Runtime-linked
   │                                               No
   │                                               ▼
   └── 注册 asCALL_GENERIC + CallBlueprintCallableReflectiveFallback
       userData = FBlueprintCallableReflectiveSignature*
       (cache 路径 / ProcessEvent 路径由 CVar 切换)
```

---

## 附录 B：调试技巧与避坑清单

### B.1 调试技巧

1. **看一条 UFunction 走的是哪条桥**：在 `Bind_BlueprintCallable.cpp:179` 的 `bHasDirectNativePointer` 处下断点，查 UClass + FuncName 即可确认走 Layer A/B 还是 Layer C
2. **trampoline 名字**：MSVC 编译产物中 `ReNativeRuntimeLinkedMethodCaller<class FVector, class AActor>` 这种特化名能直接出现在 `.pdb` 中，crash dump 里看到这个就知道当前帧在 caller 路径
3. **cache 路径 A/B 测试**：`as.ReflectiveFallback.UseCache 0` 切回 ProcessEvent 路径——若 cache 路径有 bug，关闭后行为应回归
4. **`as.DumpEngineState`**：列出每个 UClass 的 `ClassFunctionBindings` 条目（FunctionPointer / FunctionCaller / fallback bound）；与 `AS_FunctionBindingStatistics.json` 对比可发现"UHT 应该灌库但没灌"
5. **`Function->GetUserData()` 类型分歧**：BlueprintEvent 与 BlueprintCallable 在 fallback 模式下都用 userData 保存 signature——但类型不同（`FBlueprintEventSignature` vs `FBlueprintCallableReflectiveSignature`）。混淆会 access violation。检查 `Function->GetName()` + 注册函数名能区分

### B.2 避坑清单

1. **手写 `Bind_*` 时方法签名与 C++ 实现不一致**：`Method("FVector GetActorLocation()", &AActor::GetActorLocation)`——AS 端写 `FVector` 但 C++ 返回 `FVector_NetQuantize` 时，trampoline 的 `union { method; R(C::*)(Args...); }` 假设两端一致，会以 `sizeof(FVector)` 为 placement new 写入但实际 C++ 写出 `sizeof(FVector_NetQuantize)`，溢出 1 字节破坏栈相邻数据。**保持 AS 签名与 C++ 签名 binary-compatible**

2. **`ERASE_AUTO_METHOD_PTR` 用于重载方法**：`MakeAutoMethodPtr(&Cls::Foo)` 在 Foo 有重载时会 ambiguous。改用 `ERASE_METHOD_PTR(Cls, Foo, (int, float), void)` 强制选中

3. **trampoline 拷的方法指针尺寸不在 `FMethodPtrHelper<N>` 特化列表**：MSVC 上未知继承的 24 字节是有 `<DummyMethodPtrSize + 4 * sizeof(int)>` 特化的，但若 C++ 类用了**虚继承 + 多继承**可能更大——`int ERROR_UnsupportedMethodPtr[N - 100]` 默认模板会编译期报错。需要给 `FMethodPtrHelper` 加新特化

4. **`asCALL_THISCALL` 与 `asCALL_CDECL_OBJFIRST` 错配**：注册时给的方法指针是真正的成员函数指针，但 callConv 写 `CDECL_OBJFIRST`——`CallFunctionCaller` 段 (a) 不弹 this（CDECL_OBJFIRST 路径），但 trampoline 内部是 method 形态（`type=2`），结果 `Arguments[0]` 是 arg0 而非 this，访问 `((Cls*)Arguments[0])->Foo()` crash

5. **反射 fallback 的 16 参数上限**：超过 16 参的 UFUNCTION 既不会被 UHT 灌库（UHT 自身可能跳过），也不会被 fallback 兜住——`EvaluateReflectionFallback` 直接拒绝。必须改写 UFunction 签名或手写 `Bind_*` Runtime-linked

6. **out 参数 `bIsWritebackOut` 只看一次性**：cache 在第一次构建时锁定 out 参列表。若 UFunction 元数据后续变化（运行期改 `CPF_OutParm`，仅热重载下可能），cache 不会自动刷新。热重载场景应该删除并重建 signature

7. **`FString` / `TArray` / `FStruct` 的 `bIsSimpleCopy` 判断**：`IsPropertySimpleCopy` 是**保守**的——`STRUCT_NoDestructor + !STRUCT_CopyNative` 才允许 memcpy。新加的 USTRUCT 若漏标 `STRUCT_NoDestructor`（当其确实没析构时）会落入慢路径

8. **`CallGeneric` 的 try/catch 与 `CallFunctionCaller` 不对称**：Runtime-linked路径**不**catch C++ 异常。native 函数抛异常会直接撕开 AS context 栈展开，但 AS context 自身不知情。要在Runtime-linked函数内部用 `try { ... } catch { FAngelscriptEngine::Throw("..."); }` 主动转换

9. **`passFirstParamMetaData` 与参数索引对齐**：开启 `ScriptFunction` 注入后，`FunctionArgs[1]` 是注入的 `descr`，trampoline 的实际第一个 user 参数从 `Arguments[2]` 开始。用 `MakeFunctionCaller` 推导的签名要包含这个隐藏参数

10. **`bReflectiveFallbackBound = true` 后 UHT 灌库被忽略**：`Bind_Defaults` 二次进入时（如 PIE 多 engine 实例）若 entry 已标 `bReflectiveFallbackBound`，会跳过重新注册——确保 `ResetBindState` 时 `ClassFunctionBindings` 这个 flag 也被重置

---

## 小结

- **`FGenericFuncPtr` 是 25 字节联合体 + 1 字节 flag**，统一存储任何 C++ 函数 / 方法指针——MSVC 单/多/虚/未知继承下 8/16/20/24 字节方法指针全部装得下；通过 `FMethodPtrHelper<N>` 模板特化按尺寸 byte-wise 拷贝，编译期对未知尺寸触发负数组报错

- **`ASAutoCaller::FunctionCaller` 是模板生成的 trampoline**：`MakeFunctionCaller(&Cls::Foo)` 在编译期实例化 `ReNativeRuntimeLinkedMethodCaller<Ret, Cls, Args...>`，trampoline 内部用 union cast 把擦除的 method ptr 复原成 `R(C::*)(Args...)` 后做 `((C*)args[0])->*ptr(...)` 调用——把 16 种平台 ABI 桥的工作压到了 C++ 编译器代码生成器一边

- **UE Fork 的 `asCContext::CallFunctionCaller` 是 native 调用唯一主入口**：`CallSystemFunction` 顶层先看 `caller.IsBound()`，是就走 caller 路径绕过整个 `as_callfunc_*.cpp` 平台汇编桥；只有 `asCALL_GENERIC` 与未绑定情况才走 `CallGeneric` / 报错路径

- **三层 fallback 模型在调用边界的体现**：Layer A/B（UHT 灌库 + 手写Runtime-linked）走 caller 路径（~80 ns/call），Layer C 反射兜底走 `CallGeneric` + `FBlueprintCallableReflectiveSignature` + `FReflectiveParamCache` + `FFrame` + `UFunction::Invoke`（~280 ns/call cache 路径，~700 ns/call ProcessEvent 路径）。`FUNC_Net` RPC 由 cache 路径自带 `GetFunctionCallspace` 双轨保证

- **本文与 `Type_BaseClass.md` §六 是对偶的**：本文写 AS → C++ 正向桥（caller trampoline），`Type_BaseClass` 写 C++ → AS 反向桥（`UASFunctionNativeThunk` + `ResolveScriptVirtual` + `AngelscriptCallFromBPVM`）。两条桥共同回答"AS 字节码与 UE FFrame VM 在同一个调用链上交错运行时栈帧、参数、返回值如何相互翻译"
