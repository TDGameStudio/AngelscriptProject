# `UFUNCTION` 修饰符实现原理

> 本文记录 AngelScript 插件中 `UFUNCTION()` 修饰符从源码字符到运行时调用的完整链路。
>
> 与 `Syntax_UPROPERTY.md` 同属"修饰符语义"系列；与 `Syntax_DefaultStatement.md` 系列共享「预处理器 → 描述符 → 类生成器」三层架构。

---

## 概览

`UFUNCTION()` 在 AS 中**不是 C++ 宏展开**，而是一套 4 阶段管线：

```text
预处理器层 (Preprocessor)             AS 编译器层 (ThirdParty/angelscript)
================================      =================================
扫描 UFUNCTION( -> 分块识别为          完全无视 UFUNCTION 宏
EMacroType::Function                   只看到普通的 void Foo() 方法声明
v                                      v
ProcessFunctionMacro                   asCObjectType::methods[] 包含
解析 specifier -> 填 PropDesc 字段     asCScriptFunction* (字节码 + 可选 JIT)
v
ClassDesc->Methods.Add(FunctionDesc)
        |
        v
类生成器层 (ClassGenerator)            运行时调用层 (BPVM / ProcessEvent)
================================      =================================
DoFullReloadClass                      Blueprint VM 节点触发
- AllocateFunctionFor(选最优子类)        -> UASFunction::RuntimeCallFunction
- FunctionFlags 位填充                       -> AngelscriptCallFromBPVM
- AddFunctionReturnType / Argument                (FFrame -> ArgStack)
- StaticLink + FinalizeArguments       ProcessEvent 触发 (BlueprintImplementableEvent)
v                                       -> UASFunction::RuntimeCallEvent
UASClass::FuncMap[FName] = UASFunction      -> AngelscriptCallFromParms
                                              (Parms 内存块 -> Context)
```

**核心数据载体**：`FAngelscriptFunctionDesc`（位于 `Core/AngelscriptEngine.h:948`）—— 所有 specifier 都先被翻译成它的 `bool` 字段或 Meta Map。

整套管线两侧分工明确：

- **预处理器**：词法识别、修饰符语义解析、生成 BlueprintEvent / Net RPC 包装函数、把脚本函数名追加 `_Implementation` 后缀
- **AS 编译器**：把脚本函数（含 `_Implementation`）编译为字节码 + 可选 JIT
- **类生成器**：把 `FunctionDesc` 翻译为 `UASFunction`（继承 `UFunction`），落地到 `UClass::FuncMap`，让蓝图节点 / `ProcessEvent` 可以发现它
- **运行时**：通过双调用路径（BPVM 路径 + Parms 路径）从 UE 桥接到 AS 字节码

---

## 一、修饰符词法扫描：`UFUNCTION(` 识别

**源码所在**：`Plugins/Angelscript/Source/AngelscriptRuntime/Preprocessor/AngelscriptPreprocessor.cpp` `ParseIntoChunks`。

与 `UPROPERTY(` 完全同构：

- `case 'U'` + `IsStartOfIdentifier` + `Strncmp("UFUNCTION(", 10)` 识别宏起点
- `'(' / ')'` 配对计数 → `MacroExitScope`
- 遇到函数声明（`)` 后跟 `{` 或 `;`）触发 `FinishMacro`
- 反向扫描提取函数名、返回类型、参数列表

最终生成 `FMacro`：

```cpp
struct FMacro
{
    EMacroType Type;          // = EMacroType::Function
    FString    Name;          // 函数名（如 "MyEvent"）
    FString    Arguments;     // UFUNCTION(...) 括号内的原文（specifier 清单）
    FString    Comment;       // 紧邻的 /** ... */ 注释（→ ToolTip）
    bool       bEditorOnly;   // 来自 #if EDITOR 块
    int32      MacroStartPos; // UFUNCTION 起点
    int32      MacroEndPos;   // 结尾 ) 的下一位
    int32      NameStartPos;  // 函数名起点
    int32      NameEndPos;
    int32      FileLineNumber;
    // ...
};
```

---

## 二、核心数据结构：`FAngelscriptFunctionDesc`

**源码所在**：`Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.h:948`。

```cpp
struct FAngelscriptFunctionDesc
{
    // === 名字与签名 ===
    FString FunctionName;          // UE 侧函数名（可能含 _Implementation 后缀）
    FString OriginalFunctionName;  // 改名前的原名（FunctionName 被改时填充）
    FString ScriptFunctionName;    // AS 脚本侧实际绑定的函数名

    TMap<FName, FString> Meta;     // 元数据：Category / ToolTip / DisplayName / CallInEditor 等
    FAngelscriptTypeUsage ReturnType;
    TArray<FAngelscriptArgumentDesc> Arguments;

    // === 修饰符 -> bool 字段映射 ===
    bool bBlueprintCallable      = false;  // BlueprintCallable
    bool bBlueprintOverride      = false;  // BlueprintOverride（重写父类事件）
    bool bBlueprintEvent         = false;  // BlueprintEvent / Net RPC 共用标记
    bool bBlueprintPure          = false;  // BlueprintPure（隐含 Callable）

    bool bNetMulticast           = false;  // 标准 NetMulticast
    bool bNetClient              = false;  // 标准 Client
    bool bNetServer              = false;  // 标准 Server
    bool bNetValidate            = false;  // WithValidation
    bool bUnreliable             = false;  // Unreliable

    bool bBlueprintAuthorityOnly = false;  // BlueprintAuthorityOnly
    bool bExec                   = false;  // Exec
    bool bCanOverrideEvent       = true;   // 是否允许子类重写
    bool bIsStatic               = false;  // 全局/静态函数（自动填充）
    bool bIsConstMethod          = false;  // const 成员函数
    bool bThreadSafe             = false;  // BlueprintThreadSafe（注：当前项目预处理器无此分支，
                                           //                       只能由其他通道间接设置）
    bool bIsNoOp                 = false;  // 函数体完全为空
    bool bIsPrivate              = false;  // private 访问性
    bool bIsProtected            = false;  // protected 访问性

    int32 LineNumber = 1;
    asIScriptFunction* ScriptFunction = nullptr;  // 编译完成后填充
    UFunction*         Function       = nullptr;  // 类生成完成后填充
};
```

> 注：`OriginalFunctionName` 在 `FunctionName` 被预处理器改写时记录原名（例如 BlueprintEvent 包装路径），用于热重载比较与错误诊断。

---

## 三、语义解析：`ProcessFunctionMacro`

**源码所在**：`AngelscriptPreprocessor.cpp:1341` `ProcessFunctionMacro`。

调用时机：`ProcessMacros` 主循环中，遇到 `EMacroType::Function` 即分发到此。

### 3.1 入口：默认值与全局函数处理

```cpp
auto FunctionDesc = MakeShared<FAngelscriptFunctionDesc>();
FunctionDesc->LineNumber = Macro.FileLineNumber;

TSharedPtr<FAngelscriptClassDesc> ClassDesc;
if (Chunk.Type == EChunkType::Global)
{
    // 全局函数 -> 自动放入隐式静态类，暴露为 AS 全局命名空间
    FunctionDesc->bIsStatic = true;
    ClassDesc = GetOrCreateStaticsClass(File);
}
else
{
    ClassDesc = Chunk.ClassDesc;
}

ClassDesc->Methods.Add(FunctionDesc);

// 结构体内不允许 UFUNCTION
if (ClassDesc->bIsStruct)
{
    MacroError(...);  // "Structs may not have any UFUNCTION()s"
    bHasError = true;
}

// 默认蓝图可调用性（UAngelscriptSettings::bDefaultFunctionBlueprintCallable）
FunctionDesc->bBlueprintCallable = bDefaultFunctionBlueprintCallable;
FunctionDesc->FunctionName       = Macro.Name;
FunctionDesc->ScriptFunctionName = Macro.Name;

// #if EDITOR 块内 -> Meta["EditorOnly"]
if (Macro.bEditorOnly)
    FunctionDesc->Meta.Add(PP_NAME_EditorOnly, TEXT(""));

// 注释自动转 ToolTip
#if WITH_EDITOR
if (Macro.Comment.Len() != 0)
    FunctionDesc->Meta.Add(PP_NAME_ToolTip, FormatCommentForToolTip(Macro.Comment));
#endif
```

### 3.2 修饰符分发主循环

`ParseSpecifiers(Macro.Arguments)` 把 `UFUNCTION(...)` 内文按逗号 + `=` 切成 `FSpecifier[]`，然后逐个处理：

#### 蓝图可调用性

```cpp
else if (Spec.Name == PP_NAME_BlueprintCallable)
{
    FunctionDesc->bBlueprintCallable = true;
    bHadCallable = true;
}
else if (Spec.Name == PP_NAME_NotBlueprintCallable)
{
    FunctionDesc->bBlueprintCallable = false;   // 显式覆盖默认配置
    bHadNotCallable = true;
}
else if (Spec.Name == PP_NAME_BlueprintPure)
{
    FunctionDesc->bBlueprintCallable = true;    // Pure 隐含 Callable
    FunctionDesc->bBlueprintPure     = true;
}
```

#### BlueprintEvent — 自动生成包装函数

```cpp
else if (Spec.Name == PP_NAME_BlueprintEvent)
{
    if (FunctionDesc->bIsStatic) { MacroError(...); continue; }       // 全局函数禁止
    if (FunctionDesc->bBlueprintOverride) { MacroError(...); continue; } // 与 Override 互斥

    bool bAlreadyHasWrapper = FunctionDesc->bBlueprintEvent;

    if (!bHadCallable)
        FunctionDesc->bBlueprintCallable = false;  // BlueprintEvent 默认关闭 Callable

    FunctionDesc->bBlueprintEvent   = true;
    FunctionDesc->bCanOverrideEvent = true;        // 允许子类重写

    if (!bAlreadyHasWrapper)
    {
        // 生成调用包装：保留原名作为外部入口，
        // 实际脚本函数追加 _Implementation 后缀
        GenerateBlueprintEventWrapper(File, Chunk, Macro, FunctionDesc);
        FunctionDesc->ScriptFunctionName += TEXT("_Implementation");
    }
}
```

#### Net RPC — 标准 UE 路径

当前项目只保留标准 UE RPC 路径。历史 Haze RPC 分支已经移除，`NetFunction` / `CrumbFunction` / `DevFunction` 在 AS `UFUNCTION()` 中会按未知 specifier 报错：

```cpp
    else if (Spec.Name == PP_NAME_NetMulticast
          || Spec.Name == PP_NAME_NetServer
          || Spec.Name == PP_NAME_NetClient)
    {
        // 标准 UE RPC 路径
        if (FunctionDesc->bBlueprintOverride) { MacroError(...); continue; }
        if (FunctionDesc->bIsStatic) { MacroError(...); continue; }

        if (!bHadNotCallable)
            FunctionDesc->bBlueprintCallable = true;

        FunctionDesc->bBlueprintEvent = true;
        FunctionDesc->bNetMulticast   = (Spec.Name == PP_NAME_NetMulticast);
        FunctionDesc->bNetClient      = (Spec.Name == PP_NAME_NetClient);
        FunctionDesc->bNetServer      = (Spec.Name == PP_NAME_NetServer);

#if AS_ENFORCE_SERVER_RPC_VALIDATION
        // 编译开关：Server RPC 强制配套 WithValidation
        if (FunctionDesc->bNetServer && !Specs.FindByPredicate(...))
        {
            MacroError(...);  // "Server but no WithValidation"
            bHasError = true;
            continue;
        }
#endif
        FunctionDesc->bCanOverrideEvent = false;
        GenerateBlueprintEventWrapper(File, Chunk, Macro, FunctionDesc);
        FunctionDesc->ScriptFunctionName += TEXT("_Implementation");
    }
    else if (Spec.Name == PP_NAME_WithValidation)
    {
        // 必须有 Server 或 Client 配套，否则报错
        if (Specs.FindByPredicate([](FSpecifier& s) {
            return s.Name == PP_NAME_NetServer || s.Name == PP_NAME_NetClient;
        }))
            FunctionDesc->bNetValidate = true;
        else { MacroError(...); bHasError = true; continue; }
    }
    else if (Spec.Name == PP_NAME_BlueprintAuthorityOnly)
    {
        FunctionDesc->bBlueprintAuthorityOnly = true;
    }
```

#### BlueprintOverride — 重写父类事件

```cpp
else if (Spec.Name == PP_NAME_BlueprintOverride)
{
    if (FunctionDesc->bIsStatic) { MacroError(...); continue; }
    if (FunctionDesc->bBlueprintEvent) { MacroError(...); continue; }   // 与 Event 互斥

    if (!bHadCallable)
        FunctionDesc->bBlueprintCallable = false;

    FunctionDesc->bBlueprintEvent    = true;
    FunctionDesc->bBlueprintOverride = true;

    // 不需要生成包装：包装由父类（AS 或 C++）提供
    FunctionDesc->ScriptFunctionName += TEXT("_Implementation");
}
```

#### 杂项

```cpp
else if (Spec.Name == PP_NAME_Exec)        FunctionDesc->bExec = true;
else if (Spec.Name == PP_NAME_Unreliable)  FunctionDesc->bUnreliable = true;
else if (Spec.Name == PP_NAME_CallInEditor)
    FunctionDesc->Meta.Add(Spec.Name, TEXT("true"));

// 元数据类修饰符直接写 Meta Map
else if (Spec.Name == PP_NAME_Category
      || Spec.Name == PP_NAME_Keywords
      || Spec.Name == PP_NAME_ToolTip
      || Spec.Name == PP_NAME_DisplayName
      || Spec.Name == PP_NAME_BlueprintProtected)
{
    FunctionDesc->Meta.Add(Spec.Name, Spec.Value);
}

// meta=(Key=Value, ...) 嵌套
else if (Spec.Name == PP_NAME_Meta)
{
    for (auto& Elem : Spec.List)
        if (!Elem.Name.IsNone())
            FunctionDesc->Meta.Add(Elem.Name, Elem.Value);
}

// ForcedAssets=(Key=Path, ...) -> Meta["ForcedAssets"] = "Key=Path;..."
else if (Spec.Name == PP_NAME_ForcedAssets)
{
    FString AssetsMeta;
    for (auto& Elem : Spec.List)
    {
        if (AssetsMeta.Len() != 0) AssetsMeta += TEXT(";");
        AssetsMeta += FString::Printf(TEXT("%s=%s"), *Elem.Name.ToString(), *Elem.Value);
    }
    FunctionDesc->Meta.Add(PP_NAME_ForcedAssets, AssetsMeta);
}

else
{
    MacroError(...);  // "Unknown function specifier"
    bHasError = true;
}
```

### 3.3 收尾：源码改写

`ProcessFunctionMacro` 末尾要做两件事，让 AS 编译器看到的是"普通函数声明"而不是带宏的源码：

```cpp
// 1) 如果脚本函数名被改了（_Implementation 后缀），把源码中的标识符也改了
if (FunctionDesc->ScriptFunctionName != Macro.Name)
    ReplaceInChunk(Chunk, Macro.NameStartPos, Macro.NameEndPos, FunctionDesc->ScriptFunctionName);

// 2) 把 UFUNCTION(...) 整个宏在 AS 看到的源码里抹空
ReplaceWithBlank(Chunk, Macro.MacroStartPos, Macro.MacroEndPos);
```

### 3.4 已识别的当前项目特性

| 特性 | 当前项目 | 说明 |
|------|---------|------|
| `BlueprintThreadSafe` 修饰符 | ❌ 预处理器**无此 specifier 分支** | 但 `bThreadSafe` 字段存在，由其他通道（如 UFunction Meta 反射）间接设置 |
| `BlueprintSetter` / `BlueprintGetter` | `PP_NAME_*` 已声明 | 但 `ProcessFunctionMacro` 内**无处理分支**——这两个常量只供 `UPROPERTY` 处使用 |
| Haze RPC 修饰符 | 已移除 | `NetFunction` / `CrumbFunction` / `DevFunction` 会作为未知 UFUNCTION specifier 报错 |
| `AS_ENFORCE_SERVER_RPC_VALIDATION` | 编译开关 | 启用时 Server RPC 强制要求 WithValidation |

---

## 三补、C++ 侧 UFUNCTION Meta vs AS specifier

**关键边界**：本文 §三 处理的是 **AS 脚本侧** `.as` 文件中的 `UFUNCTION()` specifier，由 `ProcessFunctionMacro` 解析。但还有另一类**完全独立**的修饰符——**C++ 头文件中的 `UFUNCTION(BlueprintCallable, Meta = (XXX))`**，这些 Meta 不经过 AS 预处理器，而是由 UE 自己的 UHT 处理后写入 `UFunction::FunctionMetaDataMap`，再由 AS 端**反射读取**消费。

### 3补.1 处理路径对照

```text
[AS 脚本侧 specifier]                      [C++ 侧 UFUNCTION Meta]
=============================               ====================================
.as 源码 UFUNCTION(BlueprintCallable)        .h 头文件 UFUNCTION(BlueprintCallable,
                                                                Meta = (ScriptTrivial))
        |                                                |
        | AngelscriptPreprocessor                        | Unreal Header Tool (UHT)
        | ::ProcessFunctionMacro                         | 写入 Function->MetaDataMap
        v                                                v
FAngelscriptFunctionDesc.bXxx                UFunction::HasMetaData("ScriptTrivial")
        |                                                |
        | AngelscriptClassGenerator                      | Helper_FunctionSignature.h
        | ::DoFullReloadClass                            | ::InitFromFunction
        v                                                v
UClass::FuncMap[Name] = UASFunction          FAngelscriptFunctionSignature.bXxx
                                                         |
                                                         | AngelscriptBinds::Method
                                                         v
                                             AS 引擎注册的原生绑定 (asFUNC)
                                             供 AS 脚本调用 / Static JIT 优化
```

**两条路径互不干扰**：AS 脚本侧 `UFUNCTION()` 写不写 `Meta = (ScriptTrivial)` 都没意义（预处理器不处理它），但若 AS 脚本端写了 `Meta = (ScriptTrivial)`，预处理器的 `else if (Spec.Name == PP_NAME_Meta)` 分支会把它**透传**到 `FunctionDesc->Meta` Map → 进而写入生成的 UFunction → 反射读取路径**仍能识别**。所以理论上 AS 端写也可以，但实际从未这么用——`ScriptTrivial` 主要给 C++ 端 BlueprintFunctionLibrary / UCLASS 静态函数使用。

### 3补.2 数据载体：`FAngelscriptFunctionSignature`

**源码所在**：`Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Helper_FunctionSignature.h:38`。

这是 C++ 侧 UFUNCTION Meta 的中间描述符，**与 §二 的 `FAngelscriptFunctionDesc` 完全独立**：

```cpp
struct FAngelscriptFunctionSignature
{
    TArray<FAngelscriptTypeUsage> ArgumentTypes;
    FAngelscriptTypeUsage         ReturnType;
    TArray<FString>               ArgumentNames;
    TArray<FString>               ArgumentDefaults;

    bool   bAllTypesValid               = true;
    int8   WorldContextArgument         = -1;     // <- WorldContext Meta
    int8   DeterminesOutputTypeArgument = -1;     // <- DeterminesOutputType Meta
    FString Declaration;
    FString ClassName;

    bool   bStaticInScript          = false;
    bool   bStaticInUnreal          = false;
    bool   bGlobalScope             = false;      // <- ScriptGlobalScope Meta
    bool   bNotAngelscriptProperty  = false;      // <- NotAngelscriptProperty Meta
    bool   bTrivial                 = false;      // <- ScriptTrivial Meta  (★ 本节焦点)
    bool   bBlueprintProtected      = false;      // <- BlueprintProtected Meta
    FString ScriptName;                            // <- ScriptName Meta

#if WITH_EDITOR
    bool   bDeprecated              = false;     // <- DeprecatedFunction Meta
    FString DeprecationMessage;                  // <- DeprecationMessage Meta
#endif

    UFunction* Function;
};
```

### 3补.3 当前项目支持的全部 C++ 侧 UFUNCTION Meta 清单

来自 `Helper_FunctionSignature.h:17-36` 静态常量 + `InitFromFunction` 实际处理逻辑：

| Meta Key | 数据载体 | 实际作用 | 典型用例 |
|---------|---------|---------|---------|
| **`ScriptName`** | `ScriptName` 字段 | 重命名函数在 AS 中的可见名 | `UFUNCTION(..., Meta=(ScriptName="Modf"))` 把 `Modf_32` / `Modf_64` 都暴露为 `Modf` |
| **`ScriptTrivial`** | `bTrivial` | Static JIT 跳过样板代码（异常检查 / 调试钩子 / SystemFunction Inform）| FHitResult/UWorld 各种 setter/getter |
| **`ScriptMixin`** (类级) | 触发 Mixin 绑定路径 | 让 BlueprintFunctionLibrary 第一参成为 mixin 目标 | 详见 `Syntax_Mixin.md` |
| **`ScriptMethod`** (函数级，UE 5.7+) | 同上 | 函数级 Mixin 标记（替代类级 ScriptMixin） | 同上 |
| **`ScriptGlobalScope`** | `bGlobalScope` | 把 C++ 静态函数暴露到 AS 全局命名空间 | `Math::*` / `Print` 等 |
| **`NotAngelscriptProperty`** | `bNotAngelscriptProperty` | 排除自动暴露为 AS 属性 getter/setter | UFunction 看似 setter 但语义不符的情况 |
| **`WorldContext`** | `WorldContextArgument` 索引 | 标记某参数为 WorldContext，自动注入 `__WorldContext()` 默认值 | `BlueprintCallable` 静态函数的 World 参数 |
| **`OptionalWorldContext`** | 间接影响绑定 | WorldContext 但允许为 null | 见 `Bind_*` 系列 |
| **`CallableWithoutWorldContext`** | 间接影响绑定 | 无 World 上下文也允许调用 | 同上 |
| **`DeterminesOutputType`** | `DeterminesOutputTypeArgument` 索引 | 模板参数推导：返回值类型由该参数决定 | `Cast<T>` / `SpawnActor<T>` 等 |
| **`ScriptTooltip`** | 写入 `NAME_AS_Tooltip` | AS 端专用 ToolTip（覆盖标准 ToolTip） | C++ 与 AS 两边需要不同提示文案的场景 |
| **`ScriptNoDiscard`** | AS trait 直追 `no_discard` | 编译期警告：返回值必须使用 | 详见 §三补.5 |
| **`ScriptAllowDiscard`** | AS trait 直追 `allow_discard` | 覆盖父类的 NoDiscard | 同上 |
| **`ScriptAllowTemporaryThis`** | AS trait 直追 `accept_temporary_this` | 允许在临时对象上调用 | 见 `Diff_HazelightInsightsToBorrow.md` |
| **`UnsafeDuringActorConstruction`** | 当前项目仅识别为 Meta，无 AS trait 桥接 | 与 Hazelight 差异，详见对应 Diff 文档 | UE 标准 Meta |
| **`DeprecatedFunction`** + **`DeprecationMessage`** | `bDeprecated` + `DeprecationMessage` | 直追 AS `asTRAIT_DEPRECATED` + `deprecationMessage` | UE 标准 Meta，编译期产生 deprecation 警告 |
| **`BlueprintProtected`** | `bBlueprintProtected` | 限制只能在自身/子类蓝图中调用 | 与 §三 中同名 specifier 同源 |
| **`ToolTip`** | `Declaration` 中嵌入 | 标准 UE Meta，写入 AS 函数文档 | 自动来自 `/** ... */` 注释 |
| **`Category`** | `Declaration` 中嵌入 | 标准 UE Meta | 同上 |

### 3补.4 `ScriptTrivial` 完整链路

**关键**：这是一个**给 Static JIT 编译器的优化提示**，告诉 JIT："此 C++ 函数不会抛 AS 异常、不依赖系统调用通知、不需要单步调试支持"。

```text
[C++ 头文件]
    UFUNCTION(BlueprintCallable, Meta = (ScriptTrivial))
    static UPrimitiveComponent* GetComponent(const FHitResult& HitResult) { ... }
        |
        |  UHT 写入 UFunction MetaDataMap
        v
UFunction::HasMetaData("ScriptTrivial") = true
        |
        |  Helper_FunctionSignature.h:317  InitFromFunction
        v
FAngelscriptFunctionSignature::bTrivial = true
        |
        |  AngelscriptBinds.h:Method(...) 或 BindGlobalFunction(...)
        |  把 bTrivial 透传给 SCRIPT_NATIVE_METHOD / SCRIPT_NATIVE_FUNCTION 宏
        v
StaticJITBinds.cpp:BindNativeMethod(Binds, Name, bTrivial)
        |
        |  GScriptNativeForms.Add(...)  注册 FScriptNativeMethod{bTrivial=true}
        v
FScriptNativeMethod::IsTrivialFunction(EScriptFunctionCallMethod Method)
    return bTrivial && (Method != EScriptFunctionCallMethod::PointerCall);
                              (★ 仅 PointerCall 模式不享受优化)
        |
        |  AngelscriptBytecodes.cpp 字节码生成期决策
        v
bIsTrivialFunction = NativeForm->IsTrivialFunction(...)
        |
        +-- bIsTrivialFunction == true:
        |     - 跳过异常检查 (if Execution.bExceptionThrown) [[unlikely]]
        |     - 跳过调试行号注入 (DebugLineNumber)
        |     - 跳过 ShouldInformSystemFunction
        |     -> 生成更精简的 JIT 本地代码
        |
        +-- bIsTrivialFunction == false (默认):
              完整生成 try/catch + 调试钩子 + 系统通知
```

**适用条件**（典型场景）：

- 简单的 setter / getter（如 `FHitResult::SetActor` / `GetComponent`）
- 纯数学计算函数（如 `LerpShortestPath` / `WrapDouble` / `RInterpTo`）
- 不调用其他 AS 函数、不可能抛 AS 异常的 C++ 实现

**不适用**：

- 内部会调用 UFunction 反射的桥接函数
- 可能触发 GC 或 AS 异常的函数
- 涉及多线程切换的函数

**预编译序列化**：`bTrivial` 字段会写入 `FAngelscriptBindDatabase` 持久化（`AngelscriptBindDatabase.h:68/81`），让冷启动时无需重新读取 Meta 即可恢复 JIT 优化决策。

### 3补.5 其他高频 Meta 简析

#### `ScriptName` —— 函数重命名

```text
[C++ 头文件]
    UFUNCTION(BlueprintCallable, Meta = (ScriptName = "Modf"))
    static float Modf_32(float V, float& OutInt) { ... }
    UFUNCTION(BlueprintCallable, Meta = (ScriptName = "Modf"))
    static double Modf_64(double V, double& OutInt) { ... }
        |
        v
Helper_FunctionSignature.h:95  GetScriptNameForFunction
    if (HasMetaData(NAME_Signature_ScriptName))
        OutScriptName = GetPrimaryScriptName(GetMetaData("ScriptName"));
        |
        v
[AS 脚本端可见]
    Math::Modf(float, float&)   // 实际调用 Modf_32
    Math::Modf(double, double&) // 实际调用 Modf_64 (AS 函数重载机制)
```

**额外特性**：`ScriptName` 支持分号分隔多个名字（如 `"Modf;Modulus"`），`GetPrimaryScriptName` 取分号前的部分作为主名，其他名字作为别名注册。

**默认前缀剥离**（无 `ScriptName` 时）：

```cpp
OutScriptName.RemoveFromStart(TEXT("K2_"));        // K2_GetWorld -> GetWorld
OutScriptName.RemoveFromStart(TEXT("BP_"));        // BP_Spawn -> Spawn
OutScriptName.RemoveFromStart(TEXT("AS_"));        // AS_Print -> Print
// BlueprintEvent 额外:
OutScriptName.RemoveFromStart(TEXT("Received_"));  // Received_BeginPlay -> BeginPlay
OutScriptName.RemoveFromStart(TEXT("Receive"));    // ReceiveTick -> Tick
```

**禁用绑定**：`UFUNCTION(..., Meta=(ScriptName="-"))` → `Helper_FunctionSignature.h:313` 的 `if (ScriptName == "-") return;` 直接跳出绑定。

#### `ScriptGlobalScope` —— 暴露到 AS 全局命名空间

```cpp
// Helper_FunctionSignature.h:335
if (bStaticInUnreal)
{
    bGlobalScope = HasFuncMeta(NAME_Signature_ScriptGlobalScope);
    // ...
}
```

`bGlobalScope=true` 的函数不放在 `Math::` / `World::` 等命名空间下，而是直接挂在 AS 全局：

```text
UFUNCTION(BlueprintCallable, Meta = (ScriptGlobalScope))
static void Print(const FString& Msg);

// AS 端调用：
Print("Hello");                  // <- 全局可调
// 而不是：
Math::Print("Hello");            // <- 默认行为
```

#### `ScriptMixin` (类级) / `ScriptMethod` (函数级)

详见 `Documents/Knowledges/ZH/Syntax_Mixin.md`。简要：

```cpp
// 类级 ScriptMixin
UCLASS(Meta = (ScriptMixin = "AActor UWorld"))
class UMyMixinLibrary : public UBlueprintFunctionLibrary
{
    UFUNCTION(BlueprintCallable)
    static FVector GetMyLocation(const AActor* Actor);  // 第一参 AActor* -> AActor.GetMyLocation()
};

// 函数级 ScriptMethod (UE 5.7+, MixinClasses 为空时)
UFUNCTION(BlueprintCallable, Meta = (ScriptMethod))
static void DoSomething(UWidget* Widget, int32 Value);   // -> Widget.DoSomething(Value)
```

`Helper_FunctionSignature.h:339-365` 处理逻辑：取第一参类型作为 mixin 目标类型，把该函数注册为该类型的 AS 方法（去掉第一参）。

#### `WorldContext` —— 自动注入 World 默认值

```cpp
// Helper_FunctionSignature.h:279
const FString& WorldContextParam = GetFuncMetaRef(NAME_Signature_WorldContext);
if (WorldContextParam.Len() != 0)
{
    for (each ArgIndex)
        if (ArgumentNames[ArgIndex] == WorldContextParam)
        {
            ArgumentDefaults[ArgIndex] = TEXT("__WorldContext()");
            WorldContextArgument = ArgIndex;
        }
}
```

```text
UFUNCTION(BlueprintCallable, Meta = (WorldContext = "WorldCtx"))
static void DoStuff(UObject* WorldCtx, int32 Value);

// AS 端可省略第一参：
DoStuff(42);                     // 等价于 DoStuff(__WorldContext(), 42)
```

`__WorldContext()` 是 AS 内置魔法函数，在 BPVM / Parms 路径中由 `EArgumentVMBehavior::WorldContextObject` 行为自动注入，详见 §七.

#### `DeterminesOutputType` —— 模板参数推导

```cpp
UFUNCTION(BlueprintCallable, Meta = (DeterminesOutputType = "ActorClass"))
static AActor* SpawnActorByClass(TSubclassOf<AActor> ActorClass, ...);
```

`Helper_FunctionSignature.h:294` 记录 `DeterminesOutputTypeArgument` 索引，AS 端调用时根据传入的 `TSubclassOf<T>` 把返回值类型从 `AActor*` 收窄为 `T*`。

#### `ScriptNoDiscard` / `ScriptAllowDiscard`

直接追加到 AS 函数声明的 trait 列表：

```cpp
// Helper_FunctionSignature.h 拼装 Declaration 时
if (Function->HasMetaData(NAME_ScriptNoDiscard))
    Declaration += TEXT(" no_discard");
if (Function->HasMetaData(NAME_ScriptAllowDiscard))
    Declaration += TEXT(" allow_discard");
```

→ AS 编译器据此在调用点强制检查返回值是否被使用，丢弃则编译期警告。

### 3补.6 设计哲学

| 维度 | AS specifier (`UFUNCTION()`) | C++ Meta (`Meta=(...)`) |
|------|-----------------------------|------------------------|
| **使用场景** | AS 脚本写的函数变成 UFunction | C++ 写的 UFunction 暴露给 AS |
| **驱动方** | AS 预处理器主动解析 | UE 反射系统被动读取 |
| **数据载体** | `FAngelscriptFunctionDesc` | `FAngelscriptFunctionSignature` |
| **代表性 key** | `BlueprintCallable / BlueprintEvent / NetMulticast / Exec` | `ScriptTrivial / ScriptName / ScriptMixin / ScriptGlobalScope / WorldContext / DeterminesOutputType` |
| **影响时机** | 编译期 + UFunction 创建期 | 绑定期 + JIT 编译期 |

这两条独立路径之所以存在，是因为它们解决的问题方向相反：

- AS specifier 决定**脚本函数怎么对外**（作为 UFunction 注册）
- C++ Meta 决定**外部 UFunction 怎么对内**（作为 AS 可调用绑定）

两条路径在 `UClass::FuncMap` 处汇合，但元数据驱动机制完全独立。

---

## 四、`GenerateBlueprintEventWrapper` —— 包装函数生成

**源码所在**：`AngelscriptPreprocessor.cpp` `GenerateBlueprintEventWrapper`。

### 4.1 为什么需要包装函数？

UE 的 `BlueprintImplementableEvent` / `BlueprintNativeEvent` 模式有"双函数"约定：

- **外部入口函数**（如 `OnFire`）—— 蓝图 / C++ 调用方调用此函数；如果子类重写了，自动派发到子类版本
- **`_Implementation` 函数**（如 `OnFire_Implementation`）—— 真正的实现体；父类提供默认实现

AS 脚本作者只写**一个函数**，预处理器需要为他自动生成另一个：

```text
作者写：
    UFUNCTION(BlueprintEvent)
    void OnFire(int32 Damage) { Print(...); }

预处理器生成：
    void OnFire(int32 Damage)               // <-- 包装函数（外部入口）
    {
        // 调用注入：通过 UFunction 反射查找 OnFire_Implementation
        // 然后用 ProcessEvent 走完整的虚分发链
        FAngelscriptManager::CallFunction("OnFire", Damage);
    }
    void OnFire_Implementation(int32 Damage) // <-- 实际脚本主体
    { Print(...); }
```

### 4.2 包装函数的特性

| 维度 | 包装函数 | `_Implementation` 函数 |
|------|---------|----------------------|
| 名字 | 原名（`OnFire`）| 原名 + `_Implementation`（`OnFire_Implementation`）|
| 谁注册到 UClass | 包装函数 → 蓝图节点 / C++ 看到的就是它 | 不直接暴露给蓝图，只作为 AS 字节码 |
| `ScriptFunctionName` 字段 | `OnFire`（包装本身）| 通过 `+= "_Implementation"` 改写 |
| 包装实现 | 通过 `ProcessEvent` 派发，触发虚分发 | AS 字节码直接执行 |

### 4.3 适用场景

调用 `GenerateBlueprintEventWrapper` 的修饰符共 4 种：

| 修饰符 | 触发包装生成？ |
|--------|--------------|
| `BlueprintEvent` | ✅ |
| `NetMulticast` / `Server` / `Client`（标准）| ✅ |
| `BlueprintOverride` | ❌（包装由父类提供） |

注：同一函数同时被多个修饰符标记时（如 `BlueprintEvent + NetMulticast`），用 `bAlreadyHasWrapper` flag 防止重复生成。

---

## 五、类生成：`DoFullReloadClass` 中的 UFunction 创建

**源码所在**：`Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator/AngelscriptClassGenerator.cpp:3424` 起。

### 5.1 主流程

```cpp
for (auto FunctionDesc : ClassDesc->Methods)
{
    // [Step 1] 按签名特征选择最优 UASFunction 子类
    auto* NewFunction = UASFunction::AllocateFunctionFor(NewClass, FunctionName, FunctionDesc);

    // [Step 2] 基础初始化
    NewFunction->ReturnValueOffset = MAX_uint16;
    NewFunction->FirstPropertyToInit = NULL;
    //NewFunction->FunctionFlags |= FUNC_RuntimeGenerated;  // (*) 当前项目此行被注释, 详见 §九
    NewFunction->ScriptFunction = FunctionDesc->ScriptFunction;
    NewFunction->GeneratedSourceLineNumber = FunctionDesc->LineNumber + 1;

    // [Step 3] 把脚本函数已有的 JIT 结果拷过来 (final 函数才走非虚 JIT 路径)
    if (ScriptFunction->traits.GetTrait(asTRAIT_FINAL))
    {
        NewFunction->JitFunction          = ScriptFunction->jitFunction;
        NewFunction->JitFunction_Raw      = ScriptFunction->jitFunction_Raw;
        NewFunction->JitFunction_ParmsEntry = ScriptFunction->jitFunction_ParmsEntry;
    }

    // [Step 4] FunctionDesc -> EFunctionFlags 位填充
    if (FunctionDesc->bBlueprintCallable && !FunctionDesc->bIsPrivate)
        NewFunction->FunctionFlags |= FUNC_BlueprintCallable;       // 0x04000000

    if ((FunctionDesc->bBlueprintEvent && FunctionDesc->bCanOverrideEvent)
        || FunctionDesc->bBlueprintOverride)
        NewFunction->FunctionFlags |= FUNC_BlueprintEvent;          // 0x08000000

    if (FunctionDesc->bBlueprintPure && !FunctionDesc->bIsPrivate)
        NewFunction->FunctionFlags |= FUNC_BlueprintPure;           // 0x10000000

    if (FunctionDesc->bIsStatic)              NewFunction->FunctionFlags |= FUNC_Static;
    if (FunctionDesc->bNetMulticast)          NewFunction->FunctionFlags |= FUNC_NetMulticast;
    if (FunctionDesc->bNetClient)             NewFunction->FunctionFlags |= FUNC_NetClient;
    if (FunctionDesc->bNetServer)             NewFunction->FunctionFlags |= FUNC_NetServer;
    if (FunctionDesc->bBlueprintAuthorityOnly)NewFunction->FunctionFlags |= FUNC_BlueprintAuthorityOnly;
    if (FunctionDesc->bExec)                  NewFunction->FunctionFlags |= FUNC_Exec;

    // 网络函数自动追加 FUNC_Net + 默认 Reliable
    if ((NewFunction->FunctionFlags & FUNC_NetFuncFlags) != 0)
    {
        NewFunction->FunctionFlags |= FUNC_Net;
        if (!FunctionDesc->bUnreliable)
            NewFunction->FunctionFlags |= FUNC_NetReliable;
    }

    if (FunctionDesc->bIsConstMethod)
        NewFunction->FunctionFlags |= FUNC_Const;

    // [Step 5] 父类同名函数继承部分 flag (Public/Protected/Private/BlueprintPure 等)
    if (ParentFunction)
    {
        NewFunction->FunctionFlags |= (ParentFunction->FunctionFlags
            & (FUNC_FuncInherit | FUNC_Public | FUNC_Protected
               | FUNC_Private   | FUNC_BlueprintPure | FUNC_HasOutParms));
    }

    // [Step 6] 返回值与参数 -> FProperty
    AddFunctionReturnType(NewFunction, FunctionDesc->ReturnType);
    for (auto& ArgDesc : FunctionDesc->Arguments)
    {
        FProperty* Prop = AddFunctionArgument(NewFunction, ArgDesc);
        if (Prop->HasAnyPropertyFlags(CPF_OutParm))
            NewFunction->FunctionFlags |= FUNC_HasOutParms;
    }

    // [Step 7] 静态函数自动注入隐式 WorldContext
    if (FunctionDesc->bIsStatic)
    {
        FAngelscriptArgumentDesc ArgDesc;
        ArgDesc.ArgumentName = TEXT("_World_Context");
        ArgDesc.Type.Type = FAngelscriptType::GetByClass(UObject::StaticClass());
        FProperty* Prop = AddFunctionArgument(NewFunction, ArgDesc, false);
        Prop->PropertyFlags |= CPF_WorldContext;
        NewFunction->bIsWorldContextGenerated = true;
    }

    // [Step 8] 链入 UClass 的函数链表 + 注册到 FuncMap
    NewFunction->Next = NewClass->Children;
    NewClass->Children = NewFunction;
    NewClass->AddFunctionToFunctionMap(NewFunction, NewFunction->GetFName());

    // [Step 9] 静态链接 + 参数布局终结化
    NewFunction->StaticLink(true);
    NewFunction->FinalizeArguments();           // 详见 §六

    if (NewFunction->ReturnArgument.Property != nullptr)
        NewFunction->ReturnValueOffset =
            NewFunction->ReturnArgument.Property->GetOffset_ForUFunction();
}
```

---

## 六、`AllocateFunctionFor` —— 子类决策树

**源码所在**：`Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator/ASClass.cpp:1777`。

`UASFunction` 不是单一类，而是一族特化子类。每个子类针对特定参数 / 返回值布局重写 `Invoke / RuntimeCallFunction / RuntimeCallEvent`，在最优路径上**消除参数 marshalling 的分支判断**——典型的"为常见情况硬编码"优化。

### 6.1 决策树

```text
AllocateFunctionFor(InClass, ObjectName, FunctionDesc)
    |
    +-- bThreadSafe = true
    |     -> UASFunction[_JIT]                          (走最通用路径, 不做特化)
    |
    +-- !bIsStatic AND ReturnType=void AND Args.Num()=0
    |     -> UASFunction_NoParams[_JIT]                 (无参数最快路径)
    |
    +-- !bIsStatic AND ReturnType=void AND Args.Num()=1 AND !Args[0].IsRef AND IsPrimitive
    |     +-- ArgSize=1                                 -> UASFunction_ByteArg[_JIT]
    |     +-- ArgSize=4 AND Type=ScriptFloat            -> UASFunction_FloatArg[_JIT]
    |     +-- ArgSize=4 AND Type=FloatExtendedToDouble  -> UASFunction_FloatExtendedToDoubleArg[_JIT]
    |     +-- ArgSize=4 (其他)                          -> UASFunction_DWordArg[_JIT]
    |     +-- ArgSize=8 AND Type=ScriptDouble           -> UASFunction_DoubleArg[_JIT]
    |     +-- ArgSize=8 (其他)                          -> UASFunction_QWordArg[_JIT]
    |
    +-- !bIsStatic AND ReturnType=void AND Args.Num()=1 AND Args[0].IsRef
    |     -> UASFunction_ReferenceArg[_JIT]             (单引用参数路径)
    |
    +-- !bIsStatic AND ReturnType=Primitive AND Args.Num()=0
    |     +-- ReturnSize=1                              -> UASFunction_ByteReturn[_JIT]
    |     +-- ReturnSize=4 AND Float                    -> UASFunction_FloatReturn[_JIT]
    |     +-- ReturnSize=4 AND FloatExtendedToDouble    -> UASFunction_FloatExtendedToDoubleReturn[_JIT]
    |     +-- ReturnSize=4 (其他)                       -> UASFunction_DWordReturn[_JIT]
    |     +-- ... (8 字节同理)
    |
    +-- 其他 (参数数 > 1 / 返回值复杂 / 静态 / ...)
          -> UASFunction[_JIT]                          (通用路径)
```

### 6.2 JIT 变体的判定

```cpp
const bool bHasNonVirtualJitFunction =
    ScriptFunction != nullptr
    && ScriptFunction->jitFunction          != nullptr
    && ScriptFunction->jitFunction_Raw      != nullptr
    && ScriptFunction->jitFunction_ParmsEntry != nullptr
    && ScriptFunction->traits.GetTrait(asTRAIT_FINAL);   // (*) final 才能跳过虚分发
```

只有同时满足 4 个条件才能走 `_JIT` 子类，跳过虚函数表查找直接调用本地机器码。

### 6.3 设计意图

- **常见调用模式硬编码**：游戏代码中 `void Tick(float DeltaTime)` / `void OnDamage(int32 Amount)` / `bool IsAlive() const` 这类签名极常见，特化子类把参数 marshalling 简化为单个 `Memcpy`
- **JIT 路径与解释路径并存**：每个子类都有 `_JIT` 双胞胎；`final` 函数走非虚 JIT，其他走解释执行
- **避免分支预测失败**：在热路径上少一次 `switch (ArgType)` 就能多省几个 cycle

---

## 七、`FinalizeArguments` —— 双路径布局计算

**源码所在**：`ASClass.cpp` `UASFunction::FinalizeArguments`。

调用时机：`StaticLink()` 之后、首次运行时调用之前。为每个参数确定**双路径行为枚举** + **内存偏移**。

### 7.1 `FArgument` 双行为枚举

每个参数同时持有两套行为枚举，分别服务两条调用路径：

```cpp
struct FArgument
{
    FProperty* Property = nullptr;
    FAngelscriptTypeUsage Type;

    // === BPVM 路径用 (从 FFrame 取参数) ===
    EArgumentVMBehavior VMBehavior;        // 决定如何 StepCompiledIn / 析构
    int32 StackOffset = 0;                 // ArgStack 临时缓冲区中的字节偏移
    int32 ValueBytes  = 0;                 // 值类型大小

    // === Parms 路径用 (从 Parms 内存块取参数) ===
    EArgumentParmBehavior ParmBehavior;    // 决定如何 SetArgXxx
    int32 PosInParmStruct = 0;             // UFunction Parms 内存块中的字节偏移
                                           // 由 Property->GetOffset_ForUFunction() 决定
};
```

### 7.2 行为枚举速览

```text
EArgumentVMBehavior                        EArgumentParmBehavior
=======================================    ==========================================
None                       (void)          Reference                (传地址)
Reference                  (复杂值类型)     Value1Byte               (1B POD)
ReferencePOD               (POD 引用)      Value2Byte               (2B POD)
FloatExtendedToDouble      (4B->8B)        Value4Byte               (4B POD)
WorldContextObject         (注入 WC)       Value8Byte               (8B POD / 指针)
ObjectPointer              (UObject* 8B)   FloatExtendedToDouble    (4B->8B)
Value1Byte                 (1B POD)        ReferencePOD             (POD 引用)
Value2Byte                 (2B POD)        ReturnObjectPointer      (UObject* 返回)
Value4Byte                 (4B POD)
Value8Byte                 (8B POD)
ReturnObjectPOD            (POD 结构返回)
ReturnObjectValue          (值类型返回)
```

### 7.3 主要分发逻辑

```cpp
for (int32 i = 0; i < Arguments.Num(); ++i)
{
    auto& Arg = Arguments[i];
    int32 ArgSize  = Arg.Type.GetValueSize();
    int32 ArgAlign = Arg.Type.GetValueAlignment();

    // 按 AS 值类型对齐要求在 ArgStack 临时缓冲中分配槽
    int32 AlignOffset = (Align(ArgStackSize, ArgAlign) - ArgStackSize);
    ArgStackSize += AlignOffset;

    Arg.ValueBytes      = ArgSize;
    Arg.StackOffset     = ArgStackSize;                            // BPVM 偏移
    Arg.PosInParmStruct = Arg.Property->GetOffset_ForUFunction();  // Parms 偏移

    if (Arg.Type.bIsReference)
    {
        Arg.ParmBehavior = EArgumentParmBehavior::Reference;       // 统一传地址
        if (Arg.Type.IsObjectPointer())
            Arg.VMBehavior = EArgumentVMBehavior::ReferencePOD;
        else if (Arg.Type.NeedConstruct())
            Arg.VMBehavior = EArgumentVMBehavior::Reference;       // 复杂值: 需构造析构
        else
            Arg.VMBehavior = EArgumentVMBehavior::ReferencePOD;
    }
    else if (Arg.Type.IsObjectPointer())
    {
        Arg.ParmBehavior = EArgumentParmBehavior::Value8Byte;      // 指针 8B 值传递
        if (WorldContextIndex == i)
            Arg.VMBehavior = EArgumentVMBehavior::WorldContextObject;
        else
            Arg.VMBehavior = EArgumentVMBehavior::ObjectPointer;
    }
    else
    {
        // POD 基础类型: 按字节数分派, 双路径一一对应
        switch (ArgSize)
        {
            case 1: Arg.VMBehavior = EArgumentVMBehavior::Value1Byte;
                    Arg.ParmBehavior = EArgumentParmBehavior::Value1Byte; break;
            case 2: ... case 4: ... case 8: ... 等
        }
    }

    // 需要析构的引用参数收入 DestroyArguments[]
    if (Arg.Type.CanDestruct() && Arg.Type.NeedDestruct())
        DestroyArguments.Add(Arg);

    ArgStackSize += ArgSize;
}
```

返回值处理对称但有专用枚举（`ReturnObjectPOD` / `ReturnObjectValue` / `ReturnObjectPointer`），略。

### 7.4 设计意图

| 设计点 | 原因 |
|--------|------|
| **一参数双枚举** | 两条调用路径（BPVM / Parms）的参数源不同：BPVM 走 `FFrame::StepCompiledIn` 链表式取参；Parms 走 `Parms 内存块` 直接 Memcpy。同一份类型信息要分别决定双侧行为 |
| **`StackOffset` vs `PosInParmStruct`** | BPVM 需要临时缓冲（处理引用参数构造/析构）；Parms 路径直接对应 UFunction 内存布局 |
| **`DestroyArguments` 单独维护** | POD 不需要析构；复杂值类型才入此列表，避免热路径上做无意义判断 |
| **`WorldContextObject` 特化** | 静态函数自动注入的隐式 `_World_Context` 参数不来自调用方，需要从全局 WorldContext 单例取 |

---

## 八、双运行时调用路径

`UASFunction` 暴露两个运行时入口，对应 UE 两种触发场景：

### 8.1 `RuntimeCallFunction` —— Blueprint VM 路径

**触发场景**：蓝图节点触发 / 控制台 `Exec` 命令 / `CallFunction(...)` 等。
**入参**：`UObject* Object, FFrame& Stack, RESULT_DECL`。

```text
Blueprint VM 节点
    |
    v
UASFunction_QWordArg::RuntimeCallFunction(Object, Stack, RESULT)
    |
    +-- [热重载防护] ScriptFunction == nullptr -> return  (#if AS_CAN_HOTRELOAD)
    +-- [线程检查]   !bThreadSafe -> CheckGameThreadExecution
    +-- [虚表解析]   ResolveScriptVirtual(this, Object) -> 实际重写函数
    |
    +-- AngelscriptCallFromBPVM<TThreadSafe, TNonVirtual>()
        |
        +-- ArgStack = FMemory_Alloca(ArgStackSize)            (引用参数临时缓冲)
        +-- VMArgs   = FMemory_Alloca(8*ArgCount + 16)          (AS 参数指针数组)
        |
        +-- for (Arg : Arguments)
        |     按 Arg.VMBehavior 分支:
        |     - Value4Byte:  Stack.StepCompiledIn -> Memcpy 到 VMArgs[i]
        |     - ReferencePOD: Stack.StepCompiledInRef -> 取地址写 VMArgs[i]
        |     - Reference:   Stack.StepCompiledInRef -> 在 ArgStack 构造副本
        |     - WorldContextObject: 注入全局 World 单例
        |     - ...
        |
        +-- 执行模式:
        |     +-- [JIT 路径] (JitFunction_Raw)(Object, VMArgs, &OutValue)
        |     +-- [解释路径] FAngelscriptPooledContextBase::Execute()
        |                    -> Context->Prepare(ScriptFunction)
        |                    -> Arg.Type.SetArgument(i, Context, Stack, Data)
        |                    -> Context->Execute()  (字节码解释)
        |
        +-- OutValue -> 按 ReturnArgument.VMBehavior 拷贝到 RESULT_PARAM
        +-- DestroyArguments[] 列表中的复杂值类型在 ArgStack 上析构
```

### 8.2 `RuntimeCallEvent` —— ProcessEvent / Parms 路径

**触发场景**：C++ `ProcessEvent` 调用 / `BlueprintImplementableEvent` 触发 / Net RPC 投递。
**入参**：`UObject* Object, void* Parms`（连续内存块，包含所有参数 + 返回值）。

```text
C++ ProcessEvent / RPC 投递
    |
    v
UASFunction_QWordArg::RuntimeCallEvent(Object, Parms)
    |
    +-- [热重载防护] / [线程检查] / [虚表解析]  (与 BPVM 路径相同)
    |
    +-- AngelscriptCallFromParms<TThreadSafe, TNonVirtual>()
        |
        +-- 执行模式:
        |     +-- [JIT Parms 路径] (JitFunction_ParmsEntry)(Execution, Object, Parms)
        |     +-- [解释路径]
        |          for (Arg : Arguments)
        |              ValuePtr = (uint8*)Parms + Arg.PosInParmStruct
        |              按 Arg.ParmBehavior 分支:
        |              - Value4Byte: Context->SetArgDWord(i, *(uint32*)ValuePtr)
        |              - Reference:  Context->SetArgAddress(i, ValuePtr)
        |              - ...
        |          Context->Execute()
        |          返回值 -> 写到 (uint8*)Parms + ReturnArgument.PosInParmStruct
```

### 8.3 双路径对比

| 维度 | BPVM 路径 (`RuntimeCallFunction`) | Parms 路径 (`RuntimeCallEvent`) |
|------|----------------------------------|--------------------------------|
| **参数来源** | `FFrame` 字节码栈（流式 `StepCompiledIn`）| `void* Parms` 连续内存块 |
| **偏移依据** | 流式遍历，依赖 `Arg.StackOffset` | 直接计算 `(uint8*)Parms + Arg.PosInParmStruct` |
| **行为枚举** | `EArgumentVMBehavior` | `EArgumentParmBehavior` |
| **JIT 入口** | `JitFunction_Raw` | `JitFunction_ParmsEntry` |
| **典型触发** | 蓝图节点 / 控制台 / 反射调用 | C++ `ProcessEvent` / RPC / `Event` 派发 |
| **临时缓冲** | 需要 `FMemory_Alloca(ArgStackSize)` 处理引用参数 | 不需要——Parms 内存块就是参数最终位置 |

---

## 九、UASFunction 子类完整谱系

```text
UFunction (UE 引擎)
    |
    +-- UASFunction (基类, 通用路径; 同时是 bThreadSafe / 复杂签名 / 多参数 兜底子类)
        |
        +-- UASFunction_NoParams              + UASFunction_NoParams_JIT
        |
        +-- UASFunction_ByteArg               + UASFunction_ByteArg_JIT
        +-- UASFunction_DWordArg              + UASFunction_DWordArg_JIT
        +-- UASFunction_QWordArg              + UASFunction_QWordArg_JIT
        +-- UASFunction_FloatArg              + UASFunction_FloatArg_JIT
        +-- UASFunction_DoubleArg             + UASFunction_DoubleArg_JIT
        +-- UASFunction_FloatExtendedToDoubleArg + _JIT
        +-- UASFunction_ReferenceArg          + UASFunction_ReferenceArg_JIT
        |
        +-- UASFunction_ByteReturn            + UASFunction_ByteReturn_JIT
        +-- UASFunction_DWordReturn           + UASFunction_DWordReturn_JIT
        +-- UASFunction_FloatReturn           + UASFunction_FloatReturn_JIT
        +-- UASFunction_FloatExtendedToDoubleReturn + _JIT
        +-- ... (其他 Return 子类同理)
```

每个子类成对出现：基础版 + `_JIT` 版。`AllocateFunctionFor` 根据 `bHasNonVirtualJitFunction` 决定走哪一支。

---

## 十、热重载机制

热重载是 UFUNCTION 链路的关键路径之一。`FAngelscriptClassGenerator::PerformReload(bFullReload)` 根据 `ShouldFullReload(ClassData)` 决定走哪一条：

### 10.1 软重载 — `DoSoftReload`（仅函数体变化）

**核心优化**：不重建 `UASFunction`，仅更新 `ScriptFunction` 指针。

```text
触发条件: 函数签名 / 参数类型 / 返回值 / 类继承结构均未变, 仅函数体改变

DoSoftReload(ModuleData, ClassData)
    +-- 重新链接属性内存偏移 (属性可能因对齐变化)
    +-- 销毁旧的序列化 Schema (DestroyUnversionedSchema)
    +-- 更新 DefaultComponents / OverrideComponents 的 VariableOffset
    +-- 更新 UASClass.ScriptTypePtr -> 新的 asITypeInfo
    |
    +-- for (FuncDesc : ClassDesc->Methods)
    |     OldFuncDesc = ClassData.OldClass->GetMethod(FuncDesc->FunctionName)
    |     if (OldFuncDesc.IsValid())
    |         FuncDesc->Function = OldFuncDesc->Function          (复用旧 UASFunction!)
    |         ((UASFunction*)Function)->ScriptFunction =
    |             FuncDesc->ScriptFunction                         (*) 直接覆写指针
    |         SoftReloadFunction(Function)                         (递归更新参数中的 asITypeInfo*)
    |
    +-- 重新组装 GC ReferenceTokenStream
    +-- 实例属性值迁移 (保存 -> 析构旧 -> 重建新 -> 恢复)
```

### 10.2 全量重载 — `DoFullReloadClass`（结构变化）

**触发条件**：签名 / 属性结构 / 继承层次 任一变化。

```text
PerformReload(bFullReload=true)
    +-- CreateFullReloadClass: 旧类重命名为 _REPLACED_N, 创建新 UASClass
    +-- DoFullReloadClass:
    |     - 完整走一遍 §五 流程
    |     - 重建所有 UASFunction (AllocateFunctionFor + StaticLink + FinalizeArguments)
    |     - 重新注册到 UClass::FuncMap
    +-- FinalizeClass -> InitDefaultObjects -> VerifyClass
    +-- OnClassReload.Broadcast / OnFullReload.Broadcast
        +-- FClassReloadHelper::PerformReinstance
            +-- CollectGarbage / ReparentHierarchies / 刷新蓝图节点
            +-- (UE 路径) FReload::NotifyChange -> Reinstance -> Finalize
```

### 10.3 软 / 全量决策表

| 变化类型 | 触发的重载 |
|---------|-----------|
| 函数体（语句、表达式）变化 | 软重载 |
| 函数参数类型 / 返回值变化 | **全量重载** |
| 函数新增 / 删除 | **全量重载** |
| 类继承层次变化 | **全量重载** |
| 属性新增 / 删除 / 类型变化 | **全量重载** |
| `UFUNCTION(...)` 修饰符变化 | **全量重载**（`FunctionFlags` 是 UFunction 创建期一次性写入） |

---

## 十一、与 Hazelight 引擎实现的差异

### 11.1 架构性差异（不可平移）

| 差异 | 当前项目 | Hazelight | 处理决策 |
|------|---------|-----------|---------|
| `FUNC_RuntimeGenerated` 标记 | ❌ 该行被注释（`AngelscriptClassGenerator.cpp:3428` / `:3904`） | ✅ UE 引擎扩展位 | **架构性差异**，与 `Syntax_UPROPERTY.md` §九.9.1 中 `CPF_RuntimeGenerated` 同源 |

### 11.2 修饰符级别差异（可补足）

| 修饰符 | 当前项目 | Hazelight | 影响 |
|--------|---------|-----------|------|
| `BlueprintThreadSafe` | ❌ `ProcessFunctionMacro` 无此 specifier 分支 | ✅ 处理 | 用户在 `UFUNCTION()` 内写 `BlueprintThreadSafe` 会触发 "Unknown function specifier" 错误 |
| `BlueprintSetter` / `BlueprintGetter`（在函数上）| 部分支持：`PP_NAME_*` 已声明，但 `ProcessFunctionMacro` 无处理分支 | ✅ 完整 | UFUNCTION 端写这两个修饰符也会报错（注：UPROPERTY 端两者完全可用） |

### 11.3 编译开关差异

| 开关 | 当前项目 | 行为 |
|------|---------|------|
| `AS_ENFORCE_SERVER_RPC_VALIDATION` | 编译开关 | 启用时 Server RPC 强制要求 `WithValidation`，否则报错 |
| `AS_CAN_HOTRELOAD` | 编译开关 | 控制 `RuntimeCallFunction` 是否做 `ScriptFunction == nullptr` 防护 |

> 历史 Haze RPC 编译分支已移除；标准 `NetMulticast` / `Server` / `Client` 是当前唯一 AS RPC 路径。

> 完整差异分析风格见 `Documents/Knowledges/ZH/Diff_HazelightDefaultStatement.md` 与 `Diff_HazelightInsightsToBorrow.md`。
> 上述 §11.2 修饰符补足建议未来纳入新 Plan（如 `Plan_HazelightUFUNCTIONParity.md`）。

---

## 十二、修饰符 → FunctionFlags / Meta 完整速查表

### 12.1 蓝图可见性

```text
BlueprintCallable           ->  bBlueprintCallable=true
                                + 非 private  ->  FUNC_BlueprintCallable
NotBlueprintCallable        ->  bBlueprintCallable=false  (覆盖默认配置)
BlueprintPure               ->  bBlueprintPure=true + bBlueprintCallable=true
                                + 非 private  ->  FUNC_BlueprintPure | FUNC_BlueprintCallable
BlueprintEvent              ->  bBlueprintEvent=true + bCanOverrideEvent=true
                                + bCanOverrideEvent  ->  FUNC_BlueprintEvent
                                + 生成包装函数 + ScriptName += "_Implementation"
                                + 默认 bBlueprintCallable=false (除非显式 BlueprintCallable)
BlueprintOverride           ->  bBlueprintOverride=true + bBlueprintEvent=true
                                ->  FUNC_BlueprintEvent
                                + 不生成包装 (父类已有) + ScriptName += "_Implementation"
                                + 默认 bBlueprintCallable=false
BlueprintAuthorityOnly      ->  bBlueprintAuthorityOnly=true
                                ->  FUNC_BlueprintAuthorityOnly
BlueprintProtected          ->  Meta["BlueprintProtected"]=Spec.Value
```

### 12.2 网络 RPC（标准路径）

```text
NetMulticast                ->  bNetMulticast=true + bBlueprintEvent=true
                                + bCanOverrideEvent=false
                                + 生成包装 + ScriptName += "_Implementation"
                                ->  FUNC_NetMulticast | FUNC_Net (+ FUNC_NetReliable 默认)
Server                      ->  bNetServer=true (其他同上)
                                ->  FUNC_NetServer | FUNC_Net
Client                      ->  bNetClient=true (其他同上)
                                ->  FUNC_NetClient | FUNC_Net
WithValidation              ->  bNetValidate=true (必须配 Server/Client, 否则报错)
                                ->  FUNC_NetValidate
Unreliable                  ->  bUnreliable=true
                                ->  不追加 FUNC_NetReliable (默认追加)
```

### 12.3 已移除的 Haze RPC 修饰符

```text
NetFunction                 ->  未知 UFUNCTION specifier
CrumbFunction               ->  未知 UFUNCTION specifier
DevFunction                 ->  未知 UFUNCTION specifier
```

### 12.4 编辑器与命令行

```text
CallInEditor                ->  Meta["CallInEditor"]="true"
                                (编辑器 Details 面板可点击调用)
Exec                        ->  bExec=true  ->  FUNC_Exec
                                (允许从控制台命令行调用)
```

### 12.5 元数据直通（无独立 bool）

```text
Category=X                  ->  Meta["Category"]=X         (蓝图分类路径)
Keywords=X                  ->  Meta["Keywords"]=X         (蓝图搜索词)
DisplayName=X               ->  Meta["DisplayName"]=X      (节点显示名)
ToolTip=X                   ->  Meta["ToolTip"]=X          (鼠标悬浮提示)
                                注: 函数注释自动转 ToolTip, 无需手写
meta=(K=V, ...)             ->  Meta[K]=V, ... (通用 UE meta 透传)
ForcedAssets=(K=Path, ...)  ->  Meta["ForcedAssets"]="K=Path;..."
                                (强制异步加载关联资产)
```

### 12.6 隐式（非 specifier）

```text
#if EDITOR 块内              ->  Macro.bEditorOnly=true
                                + Meta["EditorOnly"]=""
                                (Cooked 包此函数不存在)

全局函数 (Chunk.Type=Global) ->  bIsStatic=true
                                ->  FUNC_Static
                                + 进入隐式 Statics 类
                                + 自动注入 _World_Context 参数

const 成员函数 (AS 语法)     ->  bIsConstMethod=true
                                ->  FUNC_Const

private / protected 块       ->  bIsPrivate / bIsProtected
                                + 影响 FUNC_BlueprintCallable / FUNC_BlueprintPure 决策
                                + 影响包装函数生成
```

### 12.7 互斥与约束矩阵

| 修饰符 / 上下文 | 互斥 / 约束 |
|---------------|-----------|
| `BlueprintEvent` ↔ `BlueprintOverride` | 二选一，同时声明 → 编译期报错 |
| `BlueprintEvent` / `BlueprintOverride` / `Net*` | 全局函数（`bIsStatic`）禁用，触发即报错 |
| `WithValidation` | 必须有 `Server` 或 `Client` 配套 |
| `Server` (启用 `AS_ENFORCE_SERVER_RPC_VALIDATION`) | 必须有 `WithValidation` 配套 |
| 任何 UFUNCTION | 结构体 (`bIsStruct`) 内禁用，触发即报错 |
| 未知 specifier | 编译期报错 "Unknown function specifier" |

### 12.8 C++ 侧 UFUNCTION Meta（绑定路径专用，不经预处理器）

> 详见 §三补。这些 Meta 写在 C++ 头文件的 `UFUNCTION(..., Meta=(...))` 中，由 UE 反射系统填入 UFunction，再由 `Helper_FunctionSignature.h::InitFromFunction` 反射读取。**与 §三 处理的 AS specifier 是两条独立链路。**

```text
ScriptName=X[;Alias]      ->  ScriptName 字段 + 别名注册
                              (默认前缀剥离: K2_ / BP_ / AS_ / Received_ / Receive)
                              ScriptName="-"  ->  完全不绑定到 AS

ScriptTrivial             ->  bTrivial=true
                              -> Static JIT 跳过异常检查 / 调试钩子 / SystemFunction Inform
                              -> 适用: setter/getter / 纯数学函数 / 不抛 AS 异常的 C++ 实现

ScriptMixin="Cls1 Cls2"   ->  类级 Mixin 标记 (BlueprintFunctionLibrary)
                              -> 第一参类型成为 mixin 目标
ScriptMethod              ->  函数级 Mixin 标记 (UE 5.7+ 替代)
                              -> 用第一参类型自动推导 mixin 目标

ScriptGlobalScope         ->  bGlobalScope=true
                              -> 暴露到 AS 全局命名空间 (而非 Math:: / World:: 等)

NotAngelscriptProperty    ->  bNotAngelscriptProperty=true
                              -> 排除自动 getter/setter 暴露

WorldContext="ParamName"  ->  WorldContextArgument = 参数索引
                              -> AS 端可省略, 自动注入 __WorldContext()
OptionalWorldContext      ->  WorldContext 但允许 null
CallableWithoutWorldContext -> 无 World 上下文也允许

DeterminesOutputType="X"  ->  DeterminesOutputTypeArgument = 参数索引
                              -> 模板返回值类型推导 (TSubclassOf<T> -> T*)

ScriptTooltip="X"         ->  写入 NAME_AS_Tooltip
                              -> AS 端专用 ToolTip (覆盖标准 ToolTip)
ScriptNoDiscard           ->  Declaration 追加 " no_discard"
                              -> AS 编译期警告: 返回值必须使用
ScriptAllowDiscard        ->  Declaration 追加 " allow_discard"
                              -> 覆盖父类 NoDiscard
ScriptAllowTemporaryThis  ->  AS trait 桥接为 accept_temporary_this
                              -> (注: 当前项目此桥接缺失, 详见 Plan_DefaultStatementHazelightParity §1.5)

DeprecatedFunction        ->  bDeprecated=true
                              -> AS 编译期产生 deprecation 警告
DeprecationMessage="X"    ->  DeprecationMessage 字段
                              -> 上述警告附带的提示文案

UnsafeDuringActorConstruction
                          ->  当前项目仅识别为 Meta, 无 AS trait 桥接
                              -> (注: Hazelight 自动桥接为 unsafe_during_construction)

BlueprintProtected        ->  bBlueprintProtected=true
                              -> 与 §三 中同名 specifier 同源, 限制蓝图调用范围
```

> **为什么 C++ 侧需要这些独立 Meta**：C++ 侧 `BlueprintFunctionLibrary` 的静态函数本身遵循 UE 反射约定，不能改写其签名；这些 Meta 是 AS 绑定层的"翻译层指令"，告诉绑定层如何把 UFunction 映射成符合 AS 编程习惯的形态（如重命名、Mixin、全局命名空间、JIT 优化提示）。

---

## 十三、完整生命周期 ASCII 全景

下图以 `UFUNCTION(BlueprintEvent, Category="Combat") void OnFire(int32 Damage);` 为例，展示从源码字符到运行时使用的完整生命周期。

```text
============================================================================
  UFUNCTION 修饰符的完整生命周期
============================================================================

  [.as 源文件]
      UFUNCTION(BlueprintEvent, Category="Combat")
      void OnFire(int32 Damage) { Print(...); }
        |
        |  [Step 1] ParseIntoChunks (词法扫描)
        |      - case 'U' + IsStartOfIdentifier + Strncmp("UFUNCTION(", 10)
        |      - '(' / ')' 配对计数 -> MacroExitScope
        |      - 函数声明结束 ('{' 或 ';') 触发 FinishMacro
        v
  [词法产物] FMacro
      Type        = EMacroType::Function
      Name        = "OnFire"
      Arguments   = "BlueprintEvent, Category=\"Combat\""
      Comment     = ""
        |
        |  [Step 2] ProcessFunctionMacro (语义解析)
        |      - 全局 / 类内判定 -> ClassDesc / bIsStatic
        |      - ParseSpecifiers -> FSpecifier[]
        v
  [描述符] FAngelscriptFunctionDesc (按 specifier 填充)
      FunctionName       = "OnFire"
      ScriptFunctionName = "OnFire_Implementation"   <- BlueprintEvent 后缀
      bBlueprintEvent    = true                      <- BlueprintEvent
      bCanOverrideEvent  = true                      <- BlueprintEvent (允许子类重写)
      bBlueprintCallable = false                     <- BlueprintEvent 默认关闭
      Meta["Category"]   = "Combat"                  <- Category=
        |
        |  + 调用 GenerateBlueprintEventWrapper:
        |    在源码里追加 OnFire (包装) + 把 OnFire -> OnFire_Implementation
        v
  [源码改写]
      void OnFire(int32 Damage) { /* 包装: ProcessEvent 派发 */ }
      void OnFire_Implementation(int32 Damage) { Print(...); }   // <- 原函数体
        |
        |  [Step 3] AS 编译器编译 (与预处理并行)
        v
  asCScriptFunction
      jitFunction          = ...   (可选)
      jitFunction_Raw      = ...   (可选, 仅 final 函数)
      jitFunction_ParmsEntry = ... (可选)
      traits.GetTrait(asTRAIT_FINAL) = bool
        |
        |  [Step 4] DoFullReloadClass (类生成器)
        v
  for (FunctionDesc : ClassDesc->Methods)
      [Step 4.1] AllocateFunctionFor
                 -> 对于 OnFire (void, 1 个 int32 参数)
                    -> UASFunction_DWordArg[_JIT]
      [Step 4.2] FunctionFlags 位填充
                 -> FUNC_BlueprintEvent (因为 bBlueprintEvent && bCanOverrideEvent)
                 -> 不设 FUNC_BlueprintCallable (bBlueprintCallable=false)
                 -> [WITH_EDITOR] SetMetaData("Category", "Combat")
                 -> // FUNC_RuntimeGenerated 该行被注释 (详见 §十一.11.1)
      [Step 4.3] AddFunctionReturnType / AddFunctionArgument
                 -> 创建 FIntProperty "Damage" (CPF_Parm)
      [Step 4.4] StaticLink + FinalizeArguments
                 -> Damage.VMBehavior = Value4Byte
                    Damage.ParmBehavior = Value4Byte
                    Damage.PosInParmStruct = 0
        |
        v
  [最终态] UClass::FuncMap["OnFire"] = UASFunction_DWordArg
      FunctionFlags = FUNC_BlueprintEvent
      ScriptFunction = asCScriptFunction* (指向 OnFire_Implementation)
      Arguments[0] = { Property=FIntProperty Damage, VMBehavior=Value4Byte, ... }
        |
        |  [Step 5] 运行时使用
        v
  - 蓝图节点系统 : 读 FUNC_BlueprintEvent -> 暴露为可重写事件节点
  - 蓝图编辑器   : 读 Meta["Category"]    -> 节点归类到 "Combat"
  - C++ 调用     : ProcessEvent("OnFire", &Parms)
                    -> UASFunction_DWordArg::RuntimeCallEvent
                    -> AngelscriptCallFromParms
                    -> Context->SetArgDWord(0, *(uint32*)Parms)
                    -> Execute -> AS 字节码 OnFire_Implementation
  - 蓝图节点触发 : Blueprint VM
                    -> UASFunction_DWordArg::RuntimeCallFunction
                    -> AngelscriptCallFromBPVM
                    -> Stack.StepCompiledIn(&Damage)
                    -> 执行 OnFire 包装 -> ProcessEvent -> 派发到 OnFire_Implementation
```

---

## 十四、关键结论速查

| 主题 | 结论 |
|------|------|
| **UFUNCTION 不是 AS 关键字** | 完全是预处理器层面的宏伪装，AS 内核解析器对它无感知；预处理器收尾时把宏抹空让 AS 看到普通声明 |
| **核心数据载体** | `FAngelscriptFunctionDesc`（位于 `Core/AngelscriptEngine.h:948`），所有 specifier 都翻译为它的 `bool` 字段或 Meta Map |
| **入口识别** | `ParseIntoChunks` 中 `case 'U'` + `Strncmp("UFUNCTION(", 10)`，与 `UPROPERTY` 同构 |
| **修饰符分发** | `ProcessFunctionMacro` 第 1403~1642 行，按 `Spec.Name` 单一 if-else if 链分发 |
| **BlueprintEvent / Net RPC 包装** | `GenerateBlueprintEventWrapper` 自动生成包装函数 + 把脚本函数名追加 `_Implementation` 后缀 |
| **BlueprintOverride 不需要包装** | 包装由父类提供（AS 父类或 C++ 父类），仅追加 `_Implementation` 后缀 |
| **互斥矩阵** | `BlueprintEvent` ↔ `BlueprintOverride` 互斥；全局函数禁 `Event/Override/Net*`；结构体禁所有 UFUNCTION |
| **WithValidation 配套** | 必须有 `Server` / `Client`；启用 `AS_ENFORCE_SERVER_RPC_VALIDATION` 时 Server 强制要求 `WithValidation` |
| **AllocateFunctionFor** | 按"返回值 / 参数特征"决策树选最优子类（NoParams / ByteArg / DWordArg / FloatArg / ReferenceArg / ...），消除热路径分支 |
| **JIT 子类条件** | 必须 `jitFunction` / `jitFunction_Raw` / `jitFunction_ParmsEntry` 三者非 null，且函数 `final`（asTRAIT_FINAL） |
| **FinalizeArguments 双行为** | 每个参数同时持有 `VMBehavior`（BPVM 路径用）+ `ParmBehavior`（Parms 路径用），双偏移 `StackOffset` / `PosInParmStruct` |
| **双调用入口** | `RuntimeCallFunction`（蓝图 VM / 控制台）+ `RuntimeCallEvent`（ProcessEvent / RPC），分别走 BPVM 路径和 Parms 路径 |
| **静态函数 WorldContext** | 自动注入隐式 `_World_Context` 参数，`CPF_WorldContext` 标志，运行时由 `WorldContextObject` 行为枚举从全局取 |
| **`FUNC_RuntimeGenerated` 缺失** | 当前项目此行被刻意注释（`:3428` / `:3904`），与 `Syntax_UPROPERTY.md` 的 `CPF_RuntimeGenerated` 同源——架构性差异 |
| **热重载策略** | 函数体改 → 软重载（仅覆写 `ScriptFunction` 指针）；签名 / 修饰符 / 结构改 → 全量重载（`AllocateFunctionFor` 重选 + 重建） |
| **错误集中点** | ① 未知 specifier → 编译期报错；② 全局函数 + Event/Override/Net* → 报错；③ Event ↔ Override 互斥违反 → 报错；④ WithValidation 未配 Server/Client → 报错；⑤ 结构体内 UFUNCTION → 报错；⑥ Server RPC 缺 WithValidation（启用强制开关时）→ 报错 |
| **C++ 侧 Meta 独立链路** | 写在 C++ 头文件 `UFUNCTION(..., Meta=(ScriptTrivial / ScriptName / ScriptMixin / ...))` 中的 Meta **不经预处理器**，由 `Helper_FunctionSignature.h::InitFromFunction` 反射读取，填入 `FAngelscriptFunctionSignature`（与 `FAngelscriptFunctionDesc` 完全独立）。详见 §三补 |
| **`ScriptTrivial` 优化机制** | `bTrivial=true` → Static JIT 跳过异常检查 / 调试钩子 / SystemFunction Inform，生成更精简本地代码；适用于 setter/getter / 纯数学函数等不抛 AS 异常的 C++ 实现 |

---

## 十五、关联文档

- 实现原理（兄弟章节）：
  - `Documents/Knowledges/ZH/Syntax_UPROPERTY.md` — `UPROPERTY` 修饰符（共享 `FMacro` / `ProcessXxxMacro` 流水线，`FUNC_RuntimeGenerated` 与 `CPF_RuntimeGenerated` 同源）
  - `Documents/Knowledges/ZH/Syntax_DefaultStatement.md` — `default` 语句（与本文 §五 共享对象构造时序）
  - `Documents/Knowledges/ZH/Syntax_DelegateEvent.md` — `delegate` / `event` 关键字（与 BlueprintEvent 包装机制有关）
- 差异分析：
  - `Documents/Knowledges/ZH/Diff_HazelightDefaultStatement.md` — `RuntimeGenerated` 系列架构性差异背景
  - `Documents/Knowledges/ZH/Diff_HazelightInsightsToBorrow.md` — Hazelight 可借鉴设计点全插件汇总
- 架构与运行时：
  - `Documents/Knowledges/ZH/Type_FunctionCaller.md` — `UASFunction` 函数调用桥（待写）
  - `Documents/Knowledges/ZH/RT_HotReload.md` — 热重载链路（待写）
  - `Documents/Knowledges/ZH/RT_StaticJIT.md` — Static JIT 与 `_JIT` 子类（待写）

---

## 十六、修订记录

| 版本 | 日期 | 内容 |
|------|------|------|
| v1.0 | 2026-04-28 | 首版：基于 `Temp/Temp_UFunction/ufunction.md` 五轮迭代分析 + 当前项目实际源码核对完整产出。覆盖：词法扫描 / 数据结构 / 预处理器修饰符分发 / BlueprintEvent 包装 / `DoFullReloadClass` 类生成 / `AllocateFunctionFor` 子类决策树 / `FinalizeArguments` 双路径布局 / 双运行时调用路径 (`RuntimeCallFunction` + `RuntimeCallEvent`) / 热重载（软 / 全量决策）。已识别并标注当前项目与 Hazelight 的差异：① `FUNC_RuntimeGenerated` 该行被注释（与 `CPF_RuntimeGenerated` 同源架构性差异）；② `BlueprintThreadSafe` 修饰符无 specifier 分支；③ `BlueprintSetter/Getter` 在 UFUNCTION 端无处理分支（仅 UPROPERTY 端可用）。所有 ASCII 图遵循纯 ASCII 风格（与 `Syntax_DefaultStatement.md` v1.3、`Syntax_UPROPERTY.md` v1.3 统一）。 |
| v1.1 | 2026-04-28 | 补足 v1.0 遗漏的关键章节 **§三补 — C++ 侧 UFUNCTION Meta vs AS specifier**。澄清两条独立链路的边界：① AS 脚本侧 `UFUNCTION(BlueprintCallable)` 由 `ProcessFunctionMacro` 处理，落到 `FAngelscriptFunctionDesc.bXxx`；② C++ 侧 `UFUNCTION(..., Meta=(ScriptTrivial))` 由 UE 反射 + `Helper_FunctionSignature.h::InitFromFunction` 处理，落到 `FAngelscriptFunctionSignature.bXxx`。新增内容包括：3补.1 处理路径对照图；3补.2 `FAngelscriptFunctionSignature` 数据结构；3补.3 当前项目支持的全部 C++ 侧 UFUNCTION Meta 清单（19 项，含 `ScriptName / ScriptTrivial / ScriptMixin / ScriptMethod / ScriptGlobalScope / NotAngelscriptProperty / WorldContext / OptionalWorldContext / CallableWithoutWorldContext / DeterminesOutputType / ScriptTooltip / ScriptNoDiscard / ScriptAllowDiscard / ScriptAllowTemporaryThis / UnsafeDuringActorConstruction / DeprecatedFunction / DeprecationMessage / BlueprintProtected / ToolTip / Category`）；3补.4 `ScriptTrivial` 完整链路（C++ Meta -> bTrivial -> StaticJIT.IsTrivialFunction -> 字节码生成期跳过样板代码）；3补.5 其他高频 Meta 简析（`ScriptName` 多名注册与默认前缀剥离、`ScriptGlobalScope` 全局命名空间、`ScriptMixin/ScriptMethod` 函数级 Mixin 推导、`WorldContext` 自动注入 `__WorldContext()`、`DeterminesOutputType` 模板返回值推导、`ScriptNoDiscard/AllowDiscard` AS trait 桥接）；3补.6 设计哲学对照。同步在 §十二 速查表新增 §12.8 节列出所有 C++ 侧 Meta；§十四 关键结论新增两条相关条目。 |

