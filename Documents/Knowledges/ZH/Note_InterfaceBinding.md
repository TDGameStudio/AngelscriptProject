# Note_InterfaceBinding — 接口绑定现状

> **所属前缀**: Note_（零散笔记族）
> **关注层面**: 站在"现状记录"视角看 UInterface 在 AS 端的绑定面——脚本侧能/不能做什么、Phase 5 自动注册到底覆盖了多少、`UFUNCTION(BlueprintOverride)` 与原生 `BlueprintNativeEvent` 接口方法的对接路径、当前为什么不再支持脚本端 `UINTERFACE()` 自定义接口；不写 ClassGenerator 完整 10 步流程（详见 `Type_ClassGeneration.md`）、不写多重继承的总体策略（详见 `Type_BaseClass.md` §八）、不写如何"补齐"未实现能力（那是 OpenSpec / Plans 的范畴）
> **关键源码**:
> `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_BlueprintType.cpp` (~1405-1548 行，Phase 5)
> · `Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator/AngelscriptClassGenerator.cpp` (~58-70 行 `CallInterfaceMethod`、~5061-5189 行 接口校验)
> · `Plugins/Angelscript/Source/AngelscriptRuntime/Preprocessor/AngelscriptPreprocessor.cpp` (~1034-1057 行 接口列表解析、~1239-1257 行 接口擦除)
> · `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_Helpers.h` (~37-63 行 `GetInterfacePointerForCast`)
> · `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UObject.cpp` (~96-202 行 `ImplementsInterface` / `opCast` 接口分支)
> · `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.cpp` (~1475-1499 行 `RegisterInterfaceMethodSignature`)
> · `Plugins/Angelscript/Source/AngelscriptTest/Functional/Interface/AngelscriptInterfaceNativeTests.cpp`（5 个 TEST_METHOD）
> · `Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptNativeInterfaceTestHelpers.h`
> **关联文档**:
> `Documents/Knowledges/ZH/Type_BaseClass.md` — §八 多重基类/接口"shouldering"边界（本文是其"配置面 + 现状清单"补集）
> · `Documents/Knowledges/ZH/Type_ClassGeneration.md` — ClassGenerator 完整流程
> · `Documents/Knowledges/ZH/Type_BindSystem.md` — 绑定数据库与 `Bind_*.cpp` 节奏
> · `Documents/Knowledges/ZH/Diff_HazelightDefaultStatement.md` — 与 Hazelight 参考实现的差异比对（接口部分）

---

## 概览

本文聚焦一个核心问题：**当脚本端写 `class AImpl : AActor, UMyInterface` 时，从预处理器擦词到运行时调用 `Interface.GetValue()` 之间，到底有多少环节是已实现的、有多少是半实现、有多少根本不存在？**

`Type_BaseClass.md` §八已经从"Type_ 视角"讲清楚 ClassGenerator 阶段如何把接口塞进 `UClass::Interfaces` 数组、`bImplementedByK2 = true` 表示什么。本文是一份**现状笔记**——把所有"能用 / 不能用 / 半能用"的能力点列成清单，并对每一条说明限制的根因（AS 内核约束 / 插件未实现 / UE 反射约束）。

```text
================================================================================
  脚本端 class AImpl : AActor, UMyInterface 的能力分布
================================================================================

  脚本侧                         绑定层                        UE 反射层
  ─────                          ─────                         ─────
  class AImpl : AActor,          ┌─────────────────────────┐   ┌──────────────┐
   UMyInterface     ─────POS─►   │ Preprocessor             │   │ UClass       │
                                 │  ParseClass:             │   │ ::Interfaces │
                                 │    SuperClass=AActor     │   │   .Add(      │
                                 │    Implemented=          │   │    Class,    │
                                 │      [UMyInterface]      │   │    Offset=0, │
                                 │  AnalyzeClasses:         │   │    K2=true   │
                                 │    擦除 ", UMyInterface"  │   │   )          │
                                 └─────────────────────────┘   └──────────────┘
                                            │                         ▲
                                            ▼                         │
                                 ┌─────────────────────────┐          │
                                 │ ClassGenerator          │──────────┘
                                 │  ResolveInterfaceClass  │   FinalizeClass
                                 │  AddInterfaceRecursive  │   ~5061-5189
                                 │  FindFunctionByName     │   要求脚本类
                                 │  (校验所有接口方法)      │   提供同名 UFunction
                                 └─────────────────────────┘

  脚本调用 Iface.Foo()           ┌─────────────────────────┐   ┌──────────────┐
  ─────────────────POS─────────► │ Bind_BlueprintType.cpp  │──►│ ProcessEvent │
                                 │   Phase 5 自动注册:      │   │ (反射)       │
  Cast<UMyInterface>(Self)       │   GenericMethod(        │   └──────────────┘
                                 │     CallInterfaceMethod, │
                                 │     Sig                  │
                                 │   )                      │
                                 │   ↓                      │
                                 │ AngelscriptClassGenerator│
                                 │   CallInterfaceMethod:   │
                                 │     FindFunction(name)   │
                                 │     InvokeReflection-    │
                                 │       Fallback           │
                                 └─────────────────────────┘

  脚本端 UINTERFACE() {...}      ✗ 不存在 EChunkType::Interface
                                 ✗ Compiler 测试已被移除
                                 ✗ 仅原生 AS interface 可作非 UE 契约

================================================================================
```

后续按 (一) 现状一句话总结 → (二) 脚本声明现状 → (三) Phase 5 接口方法注册 → (四) 调用与 Cast 路径 → (五) `BlueprintOverride` 与接口的对接 → (六) 当前未实现能力清单 → (七) 测试覆盖现状 → (八) 限制根因分类 → 附录的顺序展开。

---

## 一、现状一句话总结

| 主题 | 现状 | 关键限制根因 |
|------|------|------------|
| 脚本类**实现** C++ 原生 UInterface | ✅ 已实现，路径稳定 | — |
| 脚本类实现**多接口**（C++ 原生） | ✅ 已实现（`AddInterfaceRecursive` 处理父接口） | — |
| 接口方法**调用**（脚本→反射→ProcessEvent） | ✅ Phase 5 自动注册全部 `BlueprintCallable/Event/Pure` 方法 | — |
| 通过 `Cast<UMyInterface>` 取得接口引用并调用 | ✅ `Bind_UObject.cpp::opCast` 接口分支 + `GetInterfacePointerForCast` | — |
| `IMyInterface::Execute_Foo(Actor)` 反向 C++→脚本 | ✅ 走 UE 标准反射路径，脚本类的 UFunction 被 ProcessEvent 命中 | — |
| 脚本端**定义** `UINTERFACE()` 自定义接口 | ✗ **已废弃**，编译期不存在该 chunk type | 见 §六 |
| 脚本端 `interface IFoo {...}`（AS 原生语法） | ⚠ AS 编译器层面可解析，但**没有 UE 反射壳**——无法用作 UFUNCTION 参数、无法被 C++ 看见 | AS 内核约束 + 未做 UE 桥接 |
| 多接口实现时，C++ `PointerOffset != 0` 分支正确性 | ✅ `GetInterfacePointerForCast` + `UObject::GetInterfaceAddress` 闭环 | — |
| `FInterfaceProperty`（`TScriptInterface<I>`）在脚本端可作 UPROPERTY | ⚠ 半实现：通过 `GetInterfacePointerForCast` 读写 `FScriptInterface`，但脚本端**没有专门的 `TScriptInterface<>` 类型映射**——脚本只看到底层 UObject 引用 | 详见 §六.4 |
| 接口默认实现（C++ 端 `Foo_Implementation` 兜底） | ✅ UE 反射路径走 `Object->FindFunction(name)` 命中真正的 `_Implementation`；脚本类如果不重写则继承默认 | — |
| 接口里的 `BlueprintImplementableEvent`（无 native 兜底） | ✅ 脚本提供同名 UFUNCTION 即可；不提供则编译期被 `FindFunctionByName` 校验拦截 | — |
| 脚本类继承的接口方法是否走"同一个 `BlueprintEvent` thunk" | ❌ **不是同一条路径**——接口方法走 `CallInterfaceMethod`（独立的 generic 入口），普通 `BlueprintEvent` 走 `CallEventWithSignature`；二者最终都汇入 `InvokeReflectionFallbackFromGenericCall`，但前端入口分离 |

> 一句话总结：**脚本作为接口"实现者"的能力是完整的；脚本作为接口"声明者"的能力被刻意移除。**

---

## 二、脚本端的接口声明现状

### 2.1 唯一支持的语法：`class X : Base, IFoo, UBar` 中的逗号尾项

预处理器 `ParseClass` 在解析继承列表时：

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Preprocessor/AngelscriptPreprocessor.cpp
// 函数: ParseClass —— 接口列表分离
// 节选自: ~1034-1057 行
// ============================================================================
// Parse implemented interfaces from the inheritance list (comma-separated after superclass)
// Syntax: class MyClass : BaseClass, IMyInterface, IOtherInterface { ... }
if (Chunk.Type == EChunkType::Class)
{
    static const FRegexPattern InheritancePattern(
        TEXT("(class|struct)\\s+[A-Za-z0-9_]+\\s*:\\s*([^{]+)"));
    FRegexMatcher MatchInherit(InheritancePattern, Chunk.Content);
    if (MatchInherit.FindNext())
    {
        FString InheritanceClause = MatchInherit.GetCaptureGroup(2).TrimStartAndEnd();
        TArray<FString> InheritanceList;
        InheritanceClause.ParseIntoArray(InheritanceList, TEXT(","));

        // First entry is the superclass, remaining are interfaces
        for (int32 i = 1; i < InheritanceList.Num(); ++i)
        {
            FString InterfaceName = InheritanceList[i].TrimStartAndEnd();
            if (InterfaceName.Len() > 0)
                ClassDesc->ImplementedInterfaces.Add(InterfaceName);  // ★
        }
    }
}
```

随后 `AnalyzeClasses` 将", IFoo, UBar"从源文本里**用空格擦掉**，只保留"`: BaseClass`"——这样后续 AS 编译器看到的脚本就是单继承形式，不会因为 AS 不支持多继承而报错：

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Preprocessor/AngelscriptPreprocessor.cpp
// 函数: AnalyzeClasses —— 接口擦除
// 节选自: ~1239-1257 行
// ============================================================================
else if (ClassDesc->ImplementedInterfaces.Num() > 0)
{
    // For AS classes with a script superclass, strip only the interface parts
    // (after the first comma). Keep ": SuperClassName" but remove ", IIface".
    static const FRegexPattern InheritPattern(
        TEXT("(class|struct)\\s+[A-Za-z0-9_]+\\s*:\\s*[A-Za-z0-9_]+(\\s*,.+?)(?=\\s*\\{)"));

    FRegexMatcher MatchInherit(InheritPattern, Chunk.Content);
    if (MatchInherit.FindNext())
    {
        int32 InterfaceListBegin = MatchInherit.GetCaptureGroupBeginning(2);
        int32 InterfaceListEnd = MatchInherit.GetCaptureGroupEnding(2);
        if (InterfaceListBegin != -1)
        {
            for (int32 Pos = InterfaceListBegin; Pos < InterfaceListEnd; ++Pos)
                Chunk.Content[Pos] = ' ';   // ★ 用空格覆盖整段
        }
    }
}
```

接口名以何种形式书写都允许（`UMyInterface` / `IMyInterface` / `MyInterface`），最终在 ClassGenerator 阶段的 `ResolveInterfaceClass` 里做名称→ `UClass*` 的反查。

### 2.2 已废弃的语法：脚本端 `UINTERFACE()` 自定义接口

**当前已不能在 .as 里定义新的 UInterface**。决定性证据：

```cpp
// ============================================================================
// 文件: AngelscriptTest/Compiler/AngelscriptCompilerPipelineInterfaceTests.cpp
// 角色: 整个测试文件就剩一行注释 —— 用例已删
// ============================================================================
// InterfaceAnnotatedRoundTrip test removed: UINTERFACE() is deprecated and
// scripts can no longer define custom interfaces.
```

预处理器的 `EChunkType` 枚举只有 `Global / Class / Struct / Enum` 四个值——**没有 `Interface`**：

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Preprocessor/AngelscriptPreprocessor.h
// 节选自: ~162-168 行
// ============================================================================
enum class EChunkType : uint8
{
    Global,
    Class,
    Struct,
    Enum,
};
```

这意味着脚本端写：

```angelscript
// ✗ 当前不存在该语法 —— 预处理器不会识别
UINTERFACE()
class IMyInterface
{
    UFUNCTION()
    int Foo();
}
```

会被预处理器当成普通 class 解析，但缺少 `UInterface` 反射壳，最终报"unknown super type"或"is not a valid UInterface"。

### 2.3 AS 原生 `interface IFoo {...}` 的现状

AS 内核**支持**纯脚本接口（`interface` 关键字），如：

```angelscript
interface IValueProvider { int GetValue(); }
class Provider : IValueProvider { int GetValue() { return 42; } }
```

但这条路径**没有桥接到 UE 反射层**——AS 内核里的 `asITypeInfo` 是接口类型，但**不会**生成 `UClass`、不会进入 `UClass::Interfaces` 数组、不能用作 `UFUNCTION` 参数类型、对 BP 与 C++ 不可见。`AngelscriptInheritanceTests.cpp::FAngelscriptInheritanceInterfaceTest` 直接断言 `ASInheritanceInterface should remain unsupported on this branch`——即纯脚本接口在**当前 fork** 上压根连编译都过不了：

```cpp
// ============================================================================
// 文件: AngelscriptTest/Functional/Inheritance/AngelscriptInheritanceTests.cpp
// 函数: FAngelscriptInheritanceInterfaceTest::RunTest
// 节选自: ~85-97 行
// ============================================================================
const bool bCompiled = CompileModuleWithResult(
    &Engine, ECompileType::SoftReloadOnly,
    TEXT("ASInheritanceInterface"), ScriptFilename,
    TEXT("interface IValueProvider { int GetValue(); } "
         "class Provider : IValueProvider { int GetValue() { return 42; } } "
         "int Test() { Provider Instance; return 42; }"),
    CompileResult);
UE_SET_LOG_VERBOSITY(Angelscript, Log);
if (!TestFalse(TEXT("Inheritance.Interface should remain unsupported on this branch"), bCompiled))
    return false;
bPassed = CompileResult == ECompileResult::Error;
```

——也就是说，**脚本端无论以哪种语法都无法定义新接口**。脚本只能消费 C++ 原生 `UINTERFACE`。

---

## 三、Phase 5：C++ UInterface 方法的自动注册

`Bind_BlueprintType.cpp` 在 `Bind_Defaults`（`EOrder::Late + 100`）的最后一步 Phase 5 专门处理接口——这是**当前接口能用的核心入口**。

### 3.1 为什么需要 Phase 5：Phase 2 漏掉了接口

`TFieldIterator<UFunction>(Class, ExcludeSuper)` 在普通 UClass 上工作正常，但接口的 `UFunction` 的 `GetOuter()` 是**接口 UClass 自身**，不是实现类——所以 Phase 2 的扫描会跳过接口方法。同时 `BlueprintCallableReflectiveFallback.cpp` 显式拒绝接口：

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Binds/BlueprintCallableReflectiveFallback.cpp
// 节选自: ~944-949 行
// ============================================================================
if (OwningClass->HasAnyClassFlags(CLASS_Interface))
{
    return EReflectionFallbackResult::InterfaceClass;   // ★ 反射 fallback 主动跳过接口
}
```

两条路径都不覆盖接口方法 → 必须有专门的 Phase 5。

### 3.2 Phase 5 的两轮工作

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Binds/Bind_BlueprintType.cpp
// 角色: Phase 5 —— 接口方法自动注册
// 节选自: ~1411-1547 行（精简）
// ============================================================================
extern ANGELSCRIPTRUNTIME_API void CallInterfaceMethod(class asIScriptGeneric* InGeneric);

int32 TotalInterfaceMethodsBound = 0;
TArray<FInterfaceBindEntry> InterfacesToBind;

// 收集已注册为 AS 类型的 native UInterface
for (auto& BindOrder : ClassesToBind)
{
    UClass* Class = BindOrder.Class;
    if (Class == nullptr || Class == UInterface::StaticClass()) continue;
    if (!Class->HasAnyClassFlags(CLASS_Interface)) continue;
    if (!Class->HasAnyClassFlags(CLASS_Native))    continue;  // ★ 仅 C++ 原生
    if (BindOrder.ScriptType == nullptr)           continue;
    InterfacesToBind.Add({Class, BindOrder.Type->GetAngelscriptTypeName()});
}

// Round 1: 给每个接口注册它"自己"的方法（不含父接口）
for (auto& Entry : InterfacesToBind)
{
    FAngelscriptBinds Binds = FAngelscriptBinds::ExistingClass(Entry.TypeName);

    for (TFieldIterator<UFunction> FuncIt(Entry.InterfaceClass, EFieldIteratorFlags::ExcludeSuper);
         FuncIt; ++FuncIt)
    {
        UFunction* Function = *FuncIt;
        if (Function->GetOuter() == UInterface::StaticClass()) continue;
        if (!Function->HasAnyFunctionFlags(FUNC_BlueprintCallable | FUNC_BlueprintEvent | FUNC_BlueprintPure))
            continue;
        if (FAngelscriptBinds::ShouldSkipBlueprintCallableFunction(Function)) continue;

        // ... 构造 Declaration（参数 / 返回值 / const）...

        FInterfaceMethodSignature* Sig =
            FAngelscriptEngine::Get().RegisterInterfaceMethodSignature(FName(*FuncName));  // ★
        Binds.GenericMethod(Declaration, CallInterfaceMethod, Sig);                        // ★
        ++TotalInterfaceMethodsBound;
    }
}

// Round 2: 父接口方法继承——子接口 CopySystemType(父接口)
for (auto& Entry : InterfacesToBind)
{
    UClass* SuperInterface = Entry.InterfaceClass->GetSuperClass();
    if (SuperInterface == nullptr || SuperInterface == UInterface::StaticClass()) continue;
    if (!SuperInterface->HasAnyClassFlags(CLASS_Interface))                       continue;

    asITypeInfo* ChildScriptType  = ScriptEngine->GetTypeInfoByName(...);
    asITypeInfo* ParentScriptType = ScriptEngine->GetTypeInfoByName(...);
    if (ChildScriptType != nullptr && ParentScriptType != nullptr)
        ChildScriptType->CopySystemType(ParentScriptType);   // ★ 让子接口"看到"父接口方法
}
```

**为什么是两轮**：直接走 `IncludeSuper` 会让父接口的方法被**重复注册**到子接口（`ExistingType->GetMethodByName` 检测可去重，但更省事的是先各自注册自己的、再用 `CopySystemType` 拷贝指针）。`CopySystemType` 把父接口在 AS 引擎的方法表条目"贴"到子类型的方法表上——是 AS 内核里实现 OOP 继承的标准动作。

### 3.3 `CallInterfaceMethod`：所有接口方法共享的 generic 入口

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/ClassGenerator/AngelscriptClassGenerator.cpp
// 函数: CallInterfaceMethod
// 节选自: ~58-70 行
// ============================================================================
void CallInterfaceMethod(asIScriptGeneric* InGeneric)
{
    asCGeneric* Generic = static_cast<asCGeneric*>(InGeneric);
    auto* Sig = (FInterfaceMethodSignature*)Generic->GetFunction()->GetUserData();
    if (Sig == nullptr) return;

    UObject* Object = (UObject*)Generic->GetObject();
    if (Object == nullptr) return;

    UFunction* RealFunc = Object->FindFunction(Sig->FunctionName);   // ★ 反射查找真正实现
    if (RealFunc == nullptr) return;
    InvokeReflectionFallbackFromGenericCall(Generic, Object, RealFunc);  // ★ 走通用反射桥
}
```

每个接口方法在注册时都关联了一个 `FInterfaceMethodSignature`（结构体内仅含 `FName FunctionName`，由 `RegisterInterfaceMethodSignature` 创建）。运行时入口拿到 `(Object, FunctionName)` 后用 `Object->FindFunction(name)` 在**实现类**上查找——这才是关键设计：**接口方法不直接调用，而是借接口签名→在对象上反查实现**。这覆盖了三种实现来源：

- 脚本类的 UFUNCTION（脚本实现接口）；
- C++ 类的 `Foo_Implementation`（native 实现）；
- BP 类的图（蓝图实现）。

---

## 四、调用与 Cast 路径

### 4.1 `Cast<UMyInterface>(SomeUObject)` 在脚本端

`Bind_UObject.cpp` 的 `opCast` 模板专门处理接口分支：

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Binds/Bind_UObject.cpp
// 函数: UObject opCast 通用模板（接口分支）
// 节选自: ~169-202 行
// ============================================================================
const bool bIsA = Object->IsA(AssociatedClass);
const bool bAssociatedClassIsInterface = AssociatedClass->HasAnyClassFlags(CLASS_Interface);
const bool bImplementsInterface = bAssociatedClassIsInterface
    && Object->GetClass()->ImplementsInterface(AssociatedClass);

if (bIsA)
    *(UObject**)OutAddress = Object;
else if (bImplementsInterface)
    *(UObject**)OutAddress = Object;     // ★ 接口分支：写回 UObject* 自身
else
    *(UObject**)OutAddress = nullptr;
```

注意**接口分支写回的是 UObject* 自身**，不是 C++ 端的 interface vptr 偏移——脚本侧的"接口引用"和"UObject 引用"在内存表示上**完全等价**，差异只在 AS 类型系统的视角中。后续脚本侧通过该引用调接口方法时，进入 §3.3 的 `CallInterfaceMethod`，用 UObject 自身做反射 lookup。

### 4.2 `GetInterfacePointerForCast` 的真正用武之地

`Bind_Helpers.h` 提供的这个 helper **不在 `opCast` 路径**，而在 `FInterfaceProperty` 的 Get/Set accessor 里——后者驱动 `FScriptInterface::SetInterface`，必须给 UE 反射层一个**正确偏移**的接口指针：

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Binds/Bind_Helpers.h
// 函数: GetInterfacePointerForCast
// 节选自: ~37-63 行
// ============================================================================
// Returns the correctly-offset interface pointer for a UObject that implements
// a UInterface. For script-implemented interfaces `PointerOffset` is 0 and this
// returns the object itself; for C++ native implementations the object embeds
// the interface at some `PointerOffset`, and we must call `UObject::GetInterfaceAddress`
// to obtain the true interface vtable pointer.
static void* GetInterfacePointerForCast(UObject* Object, UClass* InterfaceClass)
{
    if (Object == nullptr || InterfaceClass == nullptr) return nullptr;
    if (!InterfaceClass->HasAnyClassFlags(CLASS_Interface)) return nullptr;
    if (!Object->GetClass()->ImplementsInterface(InterfaceClass)) return nullptr;

    void* NativeAddress = Object->GetInterfaceAddress(InterfaceClass);
    return NativeAddress != nullptr ? NativeAddress : static_cast<void*>(Object);  // ★
}
```

—— `GetInterfaceAddress` 在多继承的 C++ 类上返回非零偏移；在脚本类（`PointerOffset == 0`）或 BP 类上返回 `nullptr`，此时 fallback 到 UObject 自身。`AngelscriptInterfaceNativePointerOffsetTests.cpp::MultiInterfaceCast` 专门覆盖这条路径——同一 UObject 同时实现两个 C++ 接口，每个接口在对象内有不同 vptr 偏移。

### 4.3 `IMyInterface::Execute_Foo(Actor)` 反向调用

C++ 调脚本类实现的接口方法时，走的是 UE 标准 `Execute_<Func>` 模板——它内部 `FindFunction(FN_Foo)` + `ProcessEvent`。脚本侧的 `UFUNCTION()` 已经登记到了脚本类的 `FuncMap`（由 ClassGenerator 完成），所以反射查找命中。

`AngelscriptInterfaceNativeTests.cpp::NativeImplement` 的最后两行测试就是这条路径：

```cpp
// ============================================================================
// 文件: AngelscriptTest/Functional/Interface/AngelscriptInterfaceNativeTests.cpp
// 节选自: ~162-170 行
// ============================================================================
TestRunner->TestEqual(
    TEXT("C++ Execute_ bridge should call the script implementation of GetNativeValue"),
    IAngelscriptNativeParentInterface::Execute_GetNativeValue(Actor), 123);  // ★
IAngelscriptNativeParentInterface::Execute_SetNativeMarker(Actor, TEXT("FromCpp"));
```

这条路径**完全走 UE 标准 BlueprintNativeEvent 反射**——本插件没有任何特殊代码介入。能走通是因为 ClassGenerator 在 `FinalizeClass` 阶段**把脚本端的 `int GetNativeValue() const` 注册成了同名 UFunction**（详见 §五.2），UE 反射查 `FuncMap` 时命中即可。

---

## 五、`BlueprintOverride` 与接口的对接

### 5.1 接口方法**不需要** `BlueprintOverride` 修饰

这是新手最容易踩的坑。脚本端实现接口方法时，直接写 `UFUNCTION()` 即可——**不要**加 `BlueprintOverride`：

```angelscript
class ATestInterfaceNativeImplement : AActor, UAngelscriptNativeParentInterface
{
    UFUNCTION()                                  // ★ 不是 BlueprintOverride
    int GetNativeValue() const { return 123; }

    UFUNCTION()                                  // ★
    void SetNativeMarker(FName Marker) { ... }
}
```

而 `BeginPlay` 这种**父类的 BlueprintImplementableEvent** 才需要 `BlueprintOverride`：

```angelscript
    UFUNCTION(BlueprintOverride)                 // ★ 这是覆盖父类 ReceiveBeginPlay
    void BeginPlay() { ... }
```

### 5.2 ClassGenerator 的接口方法存在性校验

实现类的接口方法**必须存在**——`FinalizeClass` 阶段会逐个检查：

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/ClassGenerator/AngelscriptClassGenerator.cpp
// 函数: FinalizeClass —— 接口方法校验
// 节选自: ~5163-5188 行
// ============================================================================
for (const FImplementedInterface& Impl : NewClass->Interfaces)
{
    UClass* InterfaceClass = Impl.Class;
    if (InterfaceClass == nullptr) continue;

    for (TFieldIterator<UFunction> FuncIt(InterfaceClass, EFieldIteratorFlags::ExcludeSuper);
         FuncIt; ++FuncIt)
    {
        UFunction* InterfaceFunc = *FuncIt;
        if (InterfaceFunc->GetOuter() == UInterface::StaticClass()) continue;

        UFunction* ImplFunc = NewClass->FindFunctionByName(InterfaceFunc->GetFName());  // ★
        const bool bResolvedToInterfaceStub = ImplFunc != nullptr
            && ImplFunc->GetOwnerClass() != nullptr
            && ImplFunc->GetOwnerClass()->HasAnyClassFlags(CLASS_Interface);
        if (ImplFunc == nullptr || bResolvedToInterfaceStub)
        {
            FAngelscriptEngine::Get().ScriptCompileError(
                ModuleData.NewModule, ClassDesc->LineNumber,
                FString::Printf(TEXT("Class %s implements interface %s but is missing required method '%s'."),
                *ClassDesc->ClassName, *InterfaceClass->GetName(), *InterfaceFunc->GetName()));
            ModuleData.NewModule->bModuleSwapInError = true;
        }
    }
}
```

**两个失败条件**：
- `ImplFunc == nullptr`：脚本类没声明同名方法；
- `bResolvedToInterfaceStub`：`FindFunctionByName` 命中的是接口里的**抽象 stub**（即接口方法是 `BlueprintImplementableEvent`，且实现类没提供 override，UE 反射会指回接口 stub）。

### 5.3 `BlueprintImplementableEvent` vs `BlueprintNativeEvent` 接口方法的差异

| 接口方法类型 | C++ 端是否有 `_Implementation` | 脚本类不写时 | 写时 |
|-----|-----|-----|-----|
| `BlueprintCallable + BlueprintNativeEvent` | ✅ 有 | 反射 fallback 调 `Foo_Implementation` | 脚本 UFUNCTION 覆盖 native 默认 |
| `BlueprintCallable + BlueprintEvent`（即 `BlueprintImplementableEvent`） | ✗ 无 | **编译期报错**——FinalizeClass 检测到 stub | 脚本 UFUNCTION 提供唯一实现 |
| 纯 `BlueprintCallable`（非 event） | ✅ 必须有 native 实现 | OK——反射 fallback 调 native | 脚本不能覆盖（除非 native 标记 virtual） |

> **重要语义**：脚本类的接口方法 override **不走** `BlueprintOverride` 那套"父类同名方法名重映射 (`BeginPlay`→`ReceiveBeginPlay`)"——接口方法名就是接口里的原名 (`GetNativeValue` 永远是 `GetNativeValue`，没有 `_Implementation` 后缀的脚本对应)。这是因为 UE 反射在 `FuncMap` 中按 FName 查找，接口方法和 `BlueprintImplementableEvent` 的命名规则不同。

### 5.4 接口方法不共享 `BlueprintEvent` thunk

普通 `BlueprintEvent` 由 `Bind_BlueprintEvent.cpp::CallEventWithSignature` 派发；接口方法由 `Bind_BlueprintType.cpp::Phase 5` → `CallInterfaceMethod` 派发。两者最终都汇入 `InvokeReflectionFallbackFromGenericCall(Generic, TargetObject, Function)`，但**前端 generic 入口与 `Sig*` 类型完全独立**：

```text
普通 BlueprintEvent:
  asIScriptGeneric ─► CallEventWithSignature(Generic)
                         ↓
                       Sig = (FBlueprintEventSignature*)Function->GetUserData()
                         ↓
                       InvokeReflectionFallbackFromGenericCall(
                         Generic, GetObject(), Sig->UnrealFunction)

接口方法:
  asIScriptGeneric ─► CallInterfaceMethod(Generic)
                         ↓
                       Sig = (FInterfaceMethodSignature*)Function->GetUserData()
                         ↓
                       UFunction* RealFunc = Object->FindFunction(Sig->FunctionName)  // ★ 关键差异
                         ↓
                       InvokeReflectionFallbackFromGenericCall(
                         Generic, Object, RealFunc)
```

差异点：**普通 BlueprintEvent 在编译期就把 `UnrealFunction*` 写进 Sig**（一对一绑定到具体类）；**接口方法只写 `FName`**，调用时再到具体对象上 `FindFunction`——这是为了让同一个接口方法绑定能服务**任意**实现该接口的对象（脚本类、native 类、BP 类皆可）。

---

## 六、当前未实现 / 半实现能力清单

### 6.1 不能在脚本端定义新 UInterface

**根因**：插件刻意未实现 `EChunkType::Interface`。考虑：

- **AS 内核约束**：AS 的 `interface` 是脚本侧概念，不与 UClass 双向绑定。要让脚本接口被 BP/C++ 看见，需要在编译期生成对应的 `UInterface` 反射壳——这条路径需要走 ClassGenerator 全部 10 步流程（命名、反射、分发、生命周期），工作量等同于 `class` 通道再做一遍。
- **UE 反射约束**：`UInterface` 在 UE 中是与 `UClass::Interfaces` 数组、`PointerOffset`、`bImplementedByK2` 等字段深度耦合的类型；脚本生成的接口必须正确处理"native 实现 vs 蓝图实现"的二重性。当前这条路径未实现，且历史测试已被显式删除。
- **业务收益不足**：现有 C++ 项目用 `UINTERFACE()` 已经够用；脚本接口通常是**消费端**——脚本类实现 C++ 已存在的契约（`IDamageable`、`IInteractable` 等）。脚本定义新接口的需求被认为不足以支撑实现成本。

### 6.2 纯 AS `interface IFoo` 不接通 UE 反射

AS 内核支持 `interface IFoo { void Bar(); }` 语法，但插件没有为它生成 UClass 壳。这条路径**当前甚至连基础编译都失败**（见 §2.3 测试断言）——这意味着脚本里既不能写 `interface ICustomScript`，也不能让脚本类只实现"AS 原生接口"而不实现 UE 接口。

### 6.3 `class : I, J` 中只允许 C++ 原生 UInterface

`Phase 5` 收集环节有一个隐藏约束：

```cpp
if (!Class->HasAnyClassFlags(CLASS_Native)) continue;   // ★ 只挑 C++ 原生接口
```

**意味着**：BP 定义的 `UBlueprintInterface` 子类**不会被自动注册方法表**到 AS。脚本类如果实现一个 BP 接口，编译期 `FindFunctionByName` 校验仍然能过（因为 `UClass::Interfaces` 数组写入正常），但脚本端**无法直接调用** BP 接口方法——只能借 `Cast` + `FindFunction + ProcessEvent` 手动触发。

### 6.4 没有专门的 `TScriptInterface<I>` 类型映射

UE 反射里 `FInterfaceProperty` 对应 C++ 的 `TScriptInterface<I>`（包含 `UObject*` 与 `void* InterfacePointer` 二元组）。脚本端**没有专门的 `TScriptInterface<>` 类型**——读写 `FInterfaceProperty` 的 UPROPERTY 时，AS 看到的是底层 UObject 引用，通过 `GetInterfacePointerForCast` 在 set 时计算正确的 `PointerOffset`。

**实际后果**：脚本里写 `UInterface MyRef = Cast<UMyInterface>(Self)` 是 OK 的；但脚本不能像 C++ 那样获取 "`(IFoo*)Interface.GetInterface()`" 这种二元组的双向访问——脚本只看到 UObject 视角，所有调用都走反射 lookup。

### 6.5 接口测试中需要 `EnsureNativeInterfaceBound` 手动触发

`Bind_BlueprintType.cpp::Phase 5` 在 `Bind_Defaults` 阶段对**已 cooked 的所有 BindOrder**做扫描——这意味着只有在引擎启动时被遍历到的接口才会自动注册方法表。**测试模块新声明的 `UINTERFACE` 类型**（如 `UAngelscriptNativeParentInterface`）在 BindOrder 扫描时可能不在内，必须由测试 helper 手动补齐：

```cpp
// ============================================================================
// 文件: AngelscriptTest/Shared/AngelscriptNativeInterfaceTestHelpers.h
// 函数: EnsureNativeInterfaceBound（节选）
// 节选自: ~24-125 行
// ============================================================================
inline void EnsureNativeInterfaceBound(UClass* InterfaceClass)
{
    if (InterfaceClass == nullptr || InterfaceClass == UInterface::StaticClass()) return;
    if (!InterfaceClass->HasAnyClassFlags(CLASS_Interface | CLASS_Native))        return;

    auto* ScriptEngine = FAngelscriptEngine::Get().Engine;
    if (ScriptEngine == nullptr) return;

    const FString TypeName = FAngelscriptType::GetBoundClassName(InterfaceClass);

    // 1. 注册类型（若未注册）
    asITypeInfo* ExistingType = ScriptEngine->GetTypeInfoByName(TCHAR_TO_ANSI(*TypeName));
    if (ExistingType == nullptr)
    {
        FAngelscriptBinds Binds = FAngelscriptBinds::ReferenceClass(TypeName, InterfaceClass);
        // ... CopySystemType(UObject) 让 opCast 工作 ...
    }

    // 2. 注册方法（与 Phase 5 Round 1 完全相同的 GenericMethod + CallInterfaceMethod 模式）
    for (TFieldIterator<UFunction> FuncIt(InterfaceClass); FuncIt; ++FuncIt) { ... }

    // 3. 父接口链接（与 Phase 5 Round 2 完全相同的 CopySystemType 模式）
    UClass* SuperInterface = InterfaceClass->GetSuperClass();
    if (SuperInterface != nullptr && SuperInterface->HasAnyClassFlags(CLASS_Interface))
    {
        EnsureNativeInterfaceBound(SuperInterface);
        // ChildScriptType->CopySystemType(ParentScriptType);
    }
}
```

**这意味着实际项目场景下，如果在 plugin/runtime module 之外定义了新接口（如 game module 自己加的 `IDamageable`），需要确保它被 `Bind_BlueprintType.cpp` 的 Phase 5 扫描覆盖**——只要该接口随对应 .uasset 或 native module 在引擎初始化时被注册到 `FAngelscriptBindDatabase`，自动注册就会生效；否则就需要手动调 `EnsureNativeInterfaceBound`（但该 helper 当前只在 Test 模块导出，不是公共 API）。

### 6.6 接口方法的 `UPARAM(ref)` 行为通过 UE 反射兜底

`AngelscriptNativeInterfaceTestTypes.h` 有 `UPARAM(ref) int32& Value` 参数：

```cpp
UFUNCTION(BlueprintCallable, BlueprintNativeEvent)
void AdjustNativeValue(int32 Delta, UPARAM(ref) int32& Value);
```

脚本端调用时 ref 参数语义由 `InvokeReflectionFallbackFromGenericCall` → `ProcessEvent` 闭环——**不是**插件层手写 ref 处理。这条路径已通过 `NativeReferenceRoundTrip` 与 `NativeReferenceRoundTripCppBridgeMutatesActorState` 测试覆盖。

---

## 七、测试覆盖现状

`AngelscriptTest/Functional/Interface/` 目录下当前存在 6 个 .cpp，按主题分布：

| 测试文件 | 主要 TEST_METHOD | 验证点 |
|---------|----------------|--------|
| `AngelscriptInterfaceNativeTests.cpp` | `NativeImplement` / `NativeInheritedImplement` / `NativeReferenceRoundTrip` / `NativeReferenceRoundTripCppBridgeMutatesActorState` / `NativeInheritedParentBridgeSetterAndRef` | 单接口实现、子接口继承父接口、ref 参数双向、C++ Execute_ 反向调用 |
| `AngelscriptInterfaceNativeBindingTests.cpp` | `SignatureRegistrationLifecycle` | `FInterfaceMethodSignature` 数组生命周期管理 |
| `AngelscriptInterfaceNativeLifecycleTests.cpp` | `SignatureRegistrationRelease` | 多次 register / release 平衡，热重载场景下不泄漏 |
| `AngelscriptInterfaceNativeBridgeTests.cpp` | `CppImplementerScriptCall` | C++ 实现接口的对象，从脚本侧 Cast + 调方法 |
| `AngelscriptInterfaceNativeInheritedChildSurfaceTests.cpp` | `ChildSurfaceIncludesParentMethods` | Phase 5 Round 2 (`CopySystemType`) 的父接口方法可见性 |
| `AngelscriptInterfaceNativePointerOffsetTests.cpp` | `MultiInterfaceCast` / `ScriptClassStillZeroOffset` | 多 C++ 接口的 vptr 偏移正确性 + 脚本类 PointerOffset == 0 验证 |
| `ClassGenerator/AngelscriptInterfaceDispatchBridgeTests.cpp` | `CallInterfaceMethodDispatchesToImplementingUFunction` | `CallInterfaceMethod → FindFunction` 派发链 |

补充：
- `Compiler/AngelscriptCompilerPipelineInterfaceTests.cpp`：**整个文件只剩一行注释**——历史的 `InterfaceAnnotatedRoundTrip`（脚本端 `UINTERFACE()` 自定义接口）已被显式删除。
- `Functional/Inheritance/AngelscriptInheritanceTests.cpp::FAngelscriptInheritanceInterfaceTest`：负面测试，断言纯 AS `interface IFoo` 在当前 fork 上**编译失败**。

> **没有 Disabled 测试**——接口域所有测试均处于活跃状态（与 `AGENTS.md` "仅 2 个 Disabled 测试" 的总数一致：`TestEngineHelperTests.cpp:106` + `SourceNavigationTests.cpp:125`，都不在 Interface 目录）。

---

## 八、限制根因分类

把 §一 的不能做项映射到根因：

| 限制 | 根因分类 | 解释 |
|------|---------|------|
| 脚本端 `UINTERFACE()` 不可用 | **插件未实现** + 业务收益评估 | EChunkType 缺 Interface；ClassGenerator 没有接口生成路径；历史测试已删除 |
| 纯 AS `interface IFoo` 编译失败 | **插件未对接** + AS 内核兼容性 | AS 内核支持，但插件未加 UClass 壳生成；当前 fork 的负面断言固化 |
| BP 定义的接口不进 Phase 5 自动方法注册 | **插件未实现** | Phase 5 显式 `CLASS_Native` 过滤；BP 接口只走 `UClass::Interfaces` 数组层 |
| 脚本端没有 `TScriptInterface<>` 类型 | **AS 内核约束** + 设计取舍 | AS 类型系统需要为每个 `TScriptInterface<I>` 实例化生成模板特化；当前用 UObject 单视角统一处理 |
| 测试模块新接口需手动 `EnsureNativeInterfaceBound` | **Phase 5 时机约束** | Phase 5 在 `Bind_Defaults` 一次性扫描，后置注册的接口不在扫描范围内 |
| 接口方法不能用 `BlueprintOverride` | **UE 反射约束** | `BlueprintOverride` 是 `BlueprintImplementableEvent` 的脚本端语法糖；接口方法不需要"父类名重映射"——它们的 FName 就是接口里的原名 |
| 多重 UClass 继承不支持 | **UE 反射约束** | `UClass::SetSuperStruct` 单继承；详见 `Type_BaseClass.md` §八 |

**总结**：当前接口绑定的限制**绝大多数来自插件刻意未实现某条路径**，而非 AS 内核或 UE 反射的硬约束。换言之，如有需求，§六.1-6.4 都是**可以实现的**——只是当前的设计取舍是"消费端足够用就行"。

---

## 附录 A：能力速查表

| 场景 | 能否 | 关键源码 / 测试 |
|------|------|--------------|
| 脚本类实现单 C++ 接口 | ✅ | `AngelscriptInterfaceNativeTests.cpp::NativeImplement` |
| 脚本类实现多 C++ 接口 | ✅ | `AngelscriptInterfaceNativePointerOffsetTests.cpp::MultiInterfaceCast` |
| 脚本类实现继承的接口（子接口自动覆盖父接口） | ✅ | `AngelscriptInterfaceNativeTests.cpp::NativeInheritedImplement` |
| `Cast<UMyInterface>(SomeObject)` 在脚本端 | ✅ | `Bind_UObject.cpp::opCast` 接口分支 |
| `Iface.Foo()` 在脚本端调接口方法 | ✅ | Phase 5 + `CallInterfaceMethod` |
| `IMyInterface::Execute_Foo(Actor)` C++→脚本反向 | ✅ | UE 标准反射，无插件介入 |
| 接口方法 UPARAM(ref) 参数双向 | ✅ | `NativeReferenceRoundTrip` 测试 |
| 接口默认实现兜底（`Foo_Implementation`） | ✅ | UE 反射，脚本不重写时自动走 native |
| BlueprintImplementableEvent 接口方法 | ✅（脚本必须实现） | `FinalizeClass` 校验拦截 |
| 脚本端 `UINTERFACE()` 自定义接口 | ✗ | EChunkType 无 Interface；测试已删 |
| 纯 AS `interface IFoo` 接通 UE | ✗ | `FAngelscriptInheritanceInterfaceTest` 负面断言 |
| 实现 BP 定义的接口（自动方法注册） | ✗（手动 cast + FindFunction） | Phase 5 `CLASS_Native` 过滤 |
| 脚本端 `TScriptInterface<I>` 类型 | ✗（用 UObject 引用代替） | 无专门类型映射 |
| 测试模块新接口的方法自动注册 | ⚠（需 `EnsureNativeInterfaceBound`） | `AngelscriptNativeInterfaceTestHelpers.h` |

---

## 附录 B：常见错误与诊断

| 现象 / 报错 | 第一时间检查 | 第二时间检查 |
|----------|-----------|-----------|
| `Class %s implements %s, but it is not a valid UInterface.` | 名字拼写、`U` 前缀大小写、对应 C++ 类是否带 `UINTERFACE()` 标注 | 该接口是否在 `Bind_BlueprintType` 的 BindOrder 中（即 `Bind_Defaults` 时是否可见） |
| `Class %s implements interface %s but is missing required method '%s'.` | 脚本类有没有同名 UFUNCTION（FName 必须完全匹配，包括大小写） | 接口方法是否是 `BlueprintImplementableEvent`（无 `_Implementation`），脚本必须实现；若是 `BlueprintNativeEvent`，脚本不写时也会通过校验（默认走 `_Implementation`） |
| 脚本端 `Iface.Foo()` 编译期 "no method named Foo" | Phase 5 是否注册了该方法（log 含 `[Interface] Auto-registered N methods`） | 该接口是否 `CLASS_Native`（BP 接口不进 Phase 5）；测试场景下是否已 `EnsureNativeInterfaceBound` |
| 脚本写 `interface IMyThing { ... }` 编译失败 | 当前 fork **不支持** AS 原生接口接通 UE | 改用 C++ `UINTERFACE()` 定义，脚本侧只实现 |
| 脚本写 `UINTERFACE() class IMyScriptIface` 失败 | EChunkType 无 Interface，预处理器把它当普通 class 解析 | 当前 fork **不支持脚本端定义接口**——历史 `InterfaceAnnotatedRoundTrip` 测试已删 |
| `Cast<UMyInterface>(Obj)` 始终返回 null | `Obj->GetClass()->ImplementsInterface(InterfaceClass)` 是否为 true | `UObject::opCast` 日志（接口分支会 `UE_LOG(Display)` 打印 isA / implements 状态） |
| `IFoo::Execute_Bar(Actor)` 命中父类默认实现而非脚本 override | 脚本类的 UFUNCTION 名字是否与接口里的 FName 完全一致 | `FinalizeClass` 是否将该 UFunction 注册到了实现类的 FuncMap（dump CSV 可查） |
| 多 C++ 接口对象的第二个接口调用崩溃 | `GetInterfacePointerForCast` 是否返回正确的 `PointerOffset` | `MultiInterfaceCast` 测试是否通过；`Object->GetInterfaceAddress(InterfaceClass)` 是否非零 |
| 热重载后接口签名残留导致 OOM | `FInterfaceMethodSignature` 数组生命周期 | `SignatureRegistrationRelease` 测试覆盖；`Engine.ReleaseInterfaceMethodSignature` 是否被调用 |

---

## 小结

- **脚本作为接口"实现者"的能力是完整的**：单接口、多接口、继承接口、`Cast` 取得引用、调用方法、ref 参数双向、C++ `Execute_` 反向调用——全部由 6 个 Functional/Interface 测试 + 1 个 ClassGenerator 测试覆盖，无 Disabled。
- **脚本作为接口"声明者"的能力被刻意移除**：`UINTERFACE()` 不可用（`EChunkType` 无 Interface），纯 AS `interface IFoo` 当前 fork 编译失败（负面断言固化在 `FAngelscriptInheritanceInterfaceTest`）。这条路径不是技术不可达，而是设计取舍：**消费端用 C++ 已存在的契约就行**。
- **Phase 5 是接口能用的核心**：`Bind_BlueprintType.cpp::~1405-1547` 在 `Bind_Defaults` 阶段一次性扫描所有 BindOrder 中的 `CLASS_Native | CLASS_Interface` UClass，逐方法 `GenericMethod(CallInterfaceMethod, FInterfaceMethodSignature*)` 注册——**这是接口方法可调用的唯一注册入口**。BP 接口、运行期后置注册的接口需手动 `EnsureNativeInterfaceBound` 兜底。
- **接口方法不共享 BlueprintEvent thunk**：普通 `BlueprintEvent` 的 Sig 在编译期一对一绑死 UnrealFunction*；接口方法的 Sig 仅记 FName，调用时再到具体对象上 `FindFunction`——这是为了让同一签名服务任意实现该接口的对象（脚本/native/BP 三种）。两条路径共享的只是后端 `InvokeReflectionFallbackFromGenericCall`。
- **接口方法不需要 `BlueprintOverride` 修饰符**——这与 `BeginPlay` / `Tick` 等覆盖父类 `BlueprintImplementableEvent` 的写法是**两种不同的语义**：接口方法用 FName 直查 `FuncMap` 命中即可，不走"父类同名方法名重映射"路径。
- **多重 UClass 继承不支持是 UE 反射的硬约束**，与本文讨论的接口能力无直接关系；详见 `Type_BaseClass.md` §八。本文聚焦的是"在单父类基础上叠加 N 个接口"的现状，这条路径已稳定。
- **本文边界**：不重复 `Type_BaseClass.md` §八的多重基类总策略、不重复 `Type_ClassGeneration.md` 的 ClassGenerator 10 步流程、不写"如何补齐 §六的未实现项"（那是 OpenSpec / Plans 的职责）；本文只回答"现在能做什么、不能做什么、为什么"。

---

## 修订记录

| 版本 | 日期 | 内容 |
|------|------|------|
| v1.0 | 2026-05-22 | 首版：基于 `Bind_BlueprintType.cpp` (~1405-1548 行 Phase 5 双轮注册) / `AngelscriptClassGenerator.cpp` (~58-70 行 `CallInterfaceMethod`、~5061-5189 行 `ResolveInterfaceClass` + `AddInterfaceRecursive` + `FindFunctionByName` 校验) / `AngelscriptPreprocessor.cpp` (~1034-1057 行 接口列表分离 + ~1239-1257 行 接口擦除) / `Bind_Helpers.h::GetInterfacePointerForCast` / `Bind_UObject.cpp::opCast` 接口分支 / `AngelscriptEngine.cpp::RegisterInterfaceMethodSignature` 与 `ReleaseInterfaceMethodSignature` / `Functional/Interface/` 7 个测试文件 + `Compiler/AngelscriptCompilerPipelineInterfaceTests.cpp` 注释残骸 + `Functional/Inheritance/AngelscriptInheritanceTests.cpp` 负面断言 / `AngelscriptNativeInterfaceTestHelpers.h::EnsureNativeInterfaceBound` 完整产出。覆盖：① 现状一句话总结表（13 项能 / 不能 / 半能）；② 脚本端接口声明的三种语法（`: Base, IFoo` 支持 / `UINTERFACE()` 已废弃 / 纯 AS `interface` 不接通 UE）；③ Phase 5 双轮注册 + 与 Phase 2/反射 fallback 的边界（`CLASS_Interface` 显式跳过、`CLASS_Native` 显式过滤）；④ `CallInterfaceMethod` 派发链（FName→FindFunction→InvokeReflectionFallback）+ `Cast<>` 接口分支写回 UObject* 自身 + `GetInterfacePointerForCast` 在 `FInterfaceProperty` 路径的偏移处理；⑤ `BlueprintOverride` 与接口方法的差异语义 + `BlueprintImplementableEvent` 接口方法的强校验 + `BlueprintEvent thunk` vs `Interface thunk` 的前端入口分离；⑥ 6 项未实现/半实现能力清单（脚本定义 UINTERFACE / 纯 AS interface 接通 / BP 接口自动注册 / TScriptInterface 映射 / Phase 5 时机约束 / UPARAM ref 完全走 UE 反射）；⑦ 7 个 Functional/Interface 测试 + 1 个 ClassGenerator 测试 + 2 个负面断言的覆盖矩阵；⑧ 限制根因分类（插件未实现 / AS 内核约束 / UE 反射约束 / Phase 时机）；⑨ 附录 A 14 项能力速查表 + 附录 B 9 项常见错误诊断起点。 |
