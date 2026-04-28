# Syntax_DefaultStatement — `default` 语句实现原理

> **所属前缀**: Syntax_
> **关注层面**: 语法机制与实现原理（非用户使用指南）
> **关键源码**: `Plugins/Angelscript/Source/AngelscriptRuntime/Preprocessor/AngelscriptPreprocessor.cpp` · `Binds/Helper_FunctionSignature.h` · `ClassGenerator/AngelscriptClassGenerator.cpp` · 各 `Bind_*.cpp`

---

## 概览：两套独立的 `default` 机制

AngelScript 插件中 `default` 是一个高度重载的关键字，背后是**两条彼此独立的实现路径**，初学者最容易混淆：

```text
"default" 关键字的两种含义

[Path 1] 类体顶层的 default 语句
    形如:    default bReplicates = true;
             default Mesh.RelativeLocation = FVector(0,0,90);
    实现:    预处理器 ProcessDefaults -> ClassDesc.DefaultsCode
             -> 生成 void __InitDefaults() AS 函数
             -> 对象构造时 ExecuteDefaultsFunctions 执行

[Path 2] 函数参数默认值
    形如:    void Foo(int X = 42, FVector Pos = FVector::ZeroVector)
    实现:    UFunction meta CPP_Default_* -> 类型转换接口
             -> asCScriptFunction::defaultArgs[]
             -> AS 编译器在调用点展开为字节码
```

两条路径**不共享任何数据结构**，只是关键字字面量相同。本文按这两条路径分别展开，最后汇总跨路径的协同点（热重载、预编译、错误诊断）。

---

## 一、属性 default 语句（路径 ①）

### 1.1 全景：两层协作（预处理器 + 修改后的 AS 内核）

**关键事实**：路径 ① 的字节码生成**不是**"预处理器拼接字符串 → 提交给 AS 编译器"那样朴素的做法。实际上是两层协作：

```text
预处理器层 (Preprocessor)              AS 内核层 (修改后的 ThirdParty/angelscript)
============================           ==============================================
扫描行首 default -> Chunk.Defaults     AS 解析器把 default 行识别为
v                                      snClassDefaultStatement AST 节点
ProcessDefaults 拼接字符串             v
v                                      as_builder.cpp 收集到
ClassDesc->DefaultsCode                classDecl->defaultStatements
(只用于热重载比较!)                    v
                                       若 defaultStatements 非空
                                       -> AddInitDefaultsFunction(ot, file)
                                          为类型注册一个 __InitDefaults 方法
                                       v
                                       asCCompiler::CompileDefaultStatements
                                    遍历 defaultStatements 节点
                                    重新解析每条为表达式并编译为字节码
```

也就是说：
- **预处理器只把 `default` 行作为字符串保存在 `ClassDesc->DefaultsCode` 字段中**，这个字符串**唯一的用途是热重载时检测 default 语句是否变化**（见 §3.2）
- **真正的字节码生成由 AS 内核完成**，使用的是 AS 解析器原生识别出的 `snClassDefaultStatement` 节点，与 `ClassDesc->DefaultsCode` 字符串完全独立

理解这一点对追踪 default 实际行为至关重要。

### 1.2 预处理器侧：分块扫描与 `Chunk.Defaults`

源码所在：`AngelscriptPreprocessor.cpp` / `AngelscriptPreprocessor.h`

预处理器把 `.as` 文件按 `class` / `struct` 切分成 `FChunk`，扫描时遇到行首 `default ` 关键字就在 `Chunk.Defaults` 数组里登记一条 `FDefaultsCode`：

```cpp
struct FDefaultsCode
{
    int32 StartPos;     // "default" 关键字在 Chunk.Content 中的字节偏移
    int32 NewStartPos;  // ProcessReplacements 期间用于偏移修正
};

struct FChunk
{
    FString Content;
    TArray<FDefaultsCode> Defaults;  // 该 Chunk 内所有 default 语句的位置列表
    TSharedPtr<FAngelscriptClassDesc> ClassDesc;
    // ...
};
```

扫描登记位置（`AngelscriptPreprocessor.cpp:3636`）：

```cpp
if (FCString::Strncmp(&File.RawCode[ChunkEnd], TEXT("default"), 7) == 0
    && IsWhitespace(File.RawCode[ChunkEnd + 7]))
{
    FDefaultsCode Code;
    Code.StartPos = ChunkEnd - ChunkStart;
    PendingDefaults.Add(Code);
    break;
}
```

### 1.3 `ProcessDefaults`：拼接为单段字符串（仅供热重载比较）

`AngelscriptPreprocessor.cpp:1230` 把每条 `default` 行剪掉关键字前缀后顺序拼接，写到 `ClassDesc->DefaultsCode`：

```cpp
void FAngelscriptPreprocessor::ProcessDefaults(FFile& File, FChunk& Chunk)
{
    if (Chunk.Defaults.Num() == 0)
        return;
    if (!Chunk.ClassDesc.IsValid())
        return;

    ProcessReplacements(File, Chunk);   // 先做流式替换，保证偏移正确

    FString GeneratedDefaults;
    int32 PlacementStart = -1;
    int32 PlacementEnd = -1;

    for (FDefaultsCode& Code : Chunk.Defaults)
    {
        // 找到该 default 行的换行位置
        int32 EndPos = Code.StartPos;
        while (EndPos < Chunk.Content.Len() && Chunk.Content[EndPos] != '\n')
            ++EndPos;

        // Mid(StartPos + 8, ...) 跳过 "default "（恰好 8 个字符）
        FString DefaultsLine = Chunk.Content
            .Mid(Code.StartPos + 8, EndPos - Code.StartPos - 8)
            .TrimStartAndEnd();

        StripCommentsFromLine(DefaultsLine);
        GeneratedDefaults += DefaultsLine;       // 直接拼接，不加分隔符
    }

    Chunk.ClassDesc->DefaultsCode = GeneratedDefaults;
}
```

**`ClassDesc->DefaultsCode` 只在热重载时被使用**（`AngelscriptClassGenerator.cpp:1399`）：

```cpp
// 如果 default 语句的内容变了，建议触发 FullReload
if (ClassData.OldClass->DefaultsCode != ClassData.NewClass->DefaultsCode)
{
    if (ClassData.ReloadReq < EReloadRequirement::FullReloadSuggested)
        ClassData.ReloadReq = EReloadRequirement::FullReloadSuggested;
}
```

它**不参与字节码生成**——`Content.Mid(StartPos + 8, ...)` 提取出的 `default` 行原文也不会被 AS 编译器看到。预处理器从 `Chunk.Content` 里**根本不删掉这些行**，AS 编译器自己用解析器去识别它们（见 §1.4）。

### 1.4 AS 内核侧：`snClassDefaultStatement` AST 节点与 `__InitDefaults`

源码所在：`Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/`（项目对 AS 内核的修改）。

**步骤一**：AS 解析器（修改过的 `as_parser.cpp`）把每条 `default` 行识别为 `snClassDefaultStatement` 类型的 AST 节点。

**步骤二**：`as_builder.cpp:715` 在遍历类成员时收集这些节点：

```cpp
else if (node->nodeType == snClassDefaultStatement)
{
    node->DisconnectParent();
    decl->defaultStatements.PushLast(node);
}
```

**步骤三**：`as_builder.cpp:756` 检查到该类有 default 语句后注册 `__InitDefaults` 方法：

```cpp
// Add an initDefaults function if we have default statements
if (decl->defaultStatements.GetLength() != 0)
    AddInitDefaultsFunction(ot, decl->script);
```

**步骤四**：`asCBuilder::AddInitDefaultsFunction`（`as_builder.cpp:4193`）在 `objType->methods` 中插入一个名为 `__InitDefaults`、空签名 `void()` 的函数槽位，但**不立即编译**——"The bytecode for the default constructor will be generated only after the potential inheritance has been established"。

**步骤五**：编译该方法时，`asCCompiler::CompileFunctionImpl` 检测到当前函数是 `__InitDefaults`：

```cpp
// as_compiler.cpp:1001
static const asCString __InitDefaultsName("__InitDefaults");
m_isInitDefaults = in_outFunc->name == __InitDefaultsName;

// 编译期允许直接修改 EditConst 等"只读"属性
allowEditPropertyAccess = m_isInitDefaults
                       || in_outFunc->name == __ConstructionScript
                       || in_outFunc->name.StartsWith("__Init_")
                       || ...;
```

进入函数体生成时分发到 `CompileDefaultStatements`：

```cpp
// as_compiler.cpp:1127
else if (m_isInitDefaults)
{
    CompileDefaultStatements(&byteCode);
}
```

**步骤六**：`asCCompiler::CompileDefaultStatements`（`as_compiler.cpp:804`）遍历步骤二收集的 AST 节点，把每个节点重新交给 `asCParser` 解析为表达式，编译进字节码：

```cpp
void asCCompiler::CompileDefaultStatements(asCByteCode* bc)
{
    asASSERT(m_classDecl);

    for (asUINT n = 0; n < m_classDecl->defaultStatements.GetLength(); n++)
    {
        asCScriptNode* originalDefaultNode = m_classDecl->defaultStatements[n];
        asCParser parser(builder);
        // ...（重新解析为表达式 + 编译为字节码）
    }

    m_classDecl->defaultStatements.SetLength(0);   // 一次性消费完
}
```

### 1.5 类生成器：抓取 `__InitDefaults` 函数指针

`AngelscriptClassGenerator.cpp:5881` 中的 `UpdateConstructAndDefaultsFunctions` 在 AS 编译完成后通过名字查找回这个由内核自动生成的函数指针：

```cpp
void FAngelscriptClassGenerator::UpdateConstructAndDefaultsFunctions(
    TSharedPtr<FAngelscriptClassDesc> ClassDesc, UASClass* Class)
{
    asCObjectType* ObjType = (asCObjectType*)Class->ScriptTypePtr;
    if (ObjType != nullptr)
    {
        Class->ConstructFunction =
            ObjType->GetEngine()->GetFunctionById(ObjType->beh.construct);

        // 只取本类自己声明的 __InitDefaults，不接受继承来的
        // （父类的会在执行时按继承链单独调用，避免双重执行）
        auto* DefaultsFunction = (asCScriptFunction*)ObjType
            ->GetMethodByDecl("void __InitDefaults()");
        if (DefaultsFunction != nullptr && DefaultsFunction->objectType == ObjType)
            Class->DefaultsFunction = DefaultsFunction;

        ((asCScriptFunction*)Class->ConstructFunction)->isInUse = true;
        if (Class->DefaultsFunction != nullptr)
            ((asCScriptFunction*)Class->DefaultsFunction)->isInUse = true;
    }
}
```

### 1.6 运行时：`ExecuteDefaultsFunctions` 按继承链执行

对象构造结束时调用 `ExecuteDefaultsFunctions`（`ASClass.cpp:1093`），逻辑是沿继承链向上收集所有 `__InitDefaults`，**从最远的祖类向当前子类倒序执行**：

```cpp
static FORCEINLINE_DEBUGGABLE void ExecuteDefaultsFunctions(UObject* Object, UASClass* Class)
{
    if (Class->OwnerScriptEngine == nullptr)
        return;

    UASClass* DefaultsClass  = Class;
    UASClass* ParentDefaults = Cast<UASClass>(Class->GetSuperClass());

    if (ParentDefaults == nullptr)
    {
        // 无父类：直接执行当前类的 __InitDefaults
        if (Class->DefaultsFunction != nullptr)
        {
            FAngelscriptContext Context(Object, Class->DefaultsFunction->GetEngine());
            if (!PrepareAngelscriptContext(Context, Class->DefaultsFunction, *Class->GetPathName()))
                return;
            Context->m_executeVirtualCall = false;     // 禁用虚分发，强制本层
            Context->SetObject(Object);
            Context->Execute();
        }
    }
    else
    {
        // 沿继承链收集所有 __InitDefaults
        TArray<asIScriptFunction*, TFixedAllocator<32>> DefaultsFunctions;
        while (DefaultsClass != nullptr)
        {
            if (DefaultsClass->DefaultsFunction != nullptr
                && DefaultsClass->OwnerScriptEngine != nullptr)
                DefaultsFunctions.Add(DefaultsClass->DefaultsFunction);
            DefaultsClass = Cast<UASClass>(DefaultsClass->GetSuperClass());
        }

        // 倒序执行：祖→父→子，子类可覆盖父类已设的值
        for (int32 i = DefaultsFunctions.Num() - 1; i >= 0; --i)
        {
            FAngelscriptContext Context(Object, DefaultsFunctions[i]->GetEngine());
            if (!PrepareAngelscriptContext(Context, DefaultsFunctions[i], *Class->GetPathName()))
                return;
            Context->m_executeVirtualCall = false;
            Context->SetObject(Object);
            Context->Execute();
        }
    }
}
```

调用时机：`UASClass::FinishConstructObject` / `StaticComponentConstructor` / `StaticObjectConstructor` 在对象构造的尾声触发，且仅当 `bApplyDefaults && !bIsScriptAllocation` 时执行。

### 1.7 整体数据流

```text
.as 源码
  default bReplicates = true;
  default Mesh.RelativeLocation = FVector(0,0,90);
        |
        +-- 预处理器路径 (仅供热重载比较) --------------------------
        |     ParseIntoChunks -> Chunk.Defaults += FDefaultsCode{StartPos=...}
        |     ProcessDefaults (拼接字符串)
        |     v
        |     ClassDesc.DefaultsCode = "bReplicates = true;Mesh.RelativeLocation = FVector(0,0,90);"
        |     (只用于 ClassGenerator 比较 OldClass.DefaultsCode != NewClass.DefaultsCode)
        |
        +-- AS 内核路径 (真正生成字节码) ----------------------------
              AS 解析器: default 行 -> snClassDefaultStatement AST 节点
              as_builder.cpp: 节点收集到 decl->defaultStatements
              defaultStatements 非空 -> AddInitDefaultsFunction(ot)
              注册 "void __InitDefaults()" 方法到 ObjType->methods
              v
              CompileFunctionImpl 检测到 m_isInitDefaults = true
              -> CompileDefaultStatements 重新解析每条节点为表达式 + 字节码
              v
              UpdateConstructAndDefaultsFunctions
              通过 GetMethodByDecl("void __InitDefaults()") 抓取函数指针
              UASClass.DefaultsFunction = asCScriptFunction*
              v
              对象构造时 ExecuteDefaultsFunctions
              沿继承链 祖->父->子 倒序执行 (m_executeVirtualCall=false)
              v
              UObject 实例的属性和子对象初始化完成
```

---

## 二、函数参数默认值（路径 ②）

完全独立于路径 ①，这条路径管的是 `void Foo(int X = 42)` 这种声明，数据走 **C++ UFunction meta ↔ asCScriptFunction::defaultArgs[] ↔ 蓝图引脚** 三向同步。

### 2.1 核心数据结构

```cpp
// AngelscriptEngine.h（注意：不在 AngelscriptManager.h，AngelscriptManager 在历史版本中已合并到 AngelscriptEngine）
struct FAngelscriptArgumentDesc
{
    FString ArgumentName;       // 参数名
    FString DefaultValue;       // 字符串化默认值（"nullptr" / "FVector()" / "42"）
    FAngelscriptTypeUsage Type; // 参数 AS 类型
    bool bBlueprintByValue   = false;
    bool bBlueprintOutRef    = false;
    bool bBlueprintInRef     = false;
    bool bInRefForceCopyOut  = false;

    bool IsDefinitionEquivalent(const FAngelscriptArgumentDesc& Other) const;
    // ↑ 注意：刻意不比较 DefaultValue 和 ArgumentName
};

// Helper_FunctionSignature.h
struct FAngelscriptFunctionSignature
{
    TArray<FAngelscriptTypeUsage> ArgumentTypes;
    TArray<FString>               ArgumentNames;
    TArray<FString>               ArgumentDefaults;  // 三态："-" | "" | 具体值
    int8 WorldContextArgument          = -1;
    int8 DeterminesOutputTypeArgument  = -1;
    FString Declaration;       // 最终注册到 AS 引擎的完整声明字符串
    UFunction* Function;
    // ...
};
```

`ArgumentDefaults[i]` 的三态语义至关重要：

| 值 | 含义 | 后续行为 |
|----|------|---------|
| `"-"` | 无默认值哨兵 | `BuildFunctionDeclaration` 跳过，不生成 `= xxx` |
| `""`（空串） | 默认值 = 类型零值 | 调用 `UnrealToAngelscript("")` 生成 `FVector()` 等 |
| 具体字符串如 `"1.0,0.0,0.0"` | 显式默认值 | 调用 `UnrealToAngelscript()` 转换 |
| `"__WorldContext()"` | 魔法标记（**带括号**） | 调用前由引擎自动注入真实 WorldContext |

注意 `ArgumentDefaults` 中 WorldContext 的字面值就是 `"__WorldContext()"`（带括号），不是 `"__WorldContext"`：

```cpp
// Helper_FunctionSignature.h:284
ArgumentDefaults[ArgIndex] = TEXT("__WorldContext()");
```

`ModifyScriptFunction` 写入 `asCScriptFunction::hiddenArgumentDefault` 时也是带括号的 `"__WorldContext()"`（`Helper_FunctionSignature.h:513`）。这两处保持一致——`__WorldContext` 是一个全局函数名，带 `()` 表示调用它。

### 2.2 类型转换接口：三个虚方法

每个 AS 类型实现以下三个虚方法，构成默认值在 Unreal/AS 之间的双向转换体系：

```cpp
// ① Unreal 格式 → AS 格式（绑定阶段，把 UFunction meta 译为 AS 表达式）
virtual bool DefaultValue_UnrealToAngelscript(
    const FAngelscriptTypeUsage& Usage,
    const FString& InValue,    // 例："0.0,0.0,0.0"
    FString& OutValue) const;  // 例："FVector(0.000000,0.000000,0.000000)"

// ② AS 格式 → Unreal 格式（写回 UFunction meta，蓝图引脚才能显示默认值）
virtual bool DefaultValue_AngelscriptToUnreal(
    const FAngelscriptTypeUsage& Usage,
    const FString& InValue,    // 例："FVector::ZeroVector"
    FString& OutValue) const;  // 例：""（约定空串=零值）

// ③ 类型级兜底（Unreal 没有给值时使用，仅 Delegate 实现）
virtual bool DefaultValue_AngelscriptFallback(
    const FAngelscriptTypeUsage& Usage,
    FString& OutAngelscriptValue) const;
```

`BuildFunctionDeclaration` 中的优先级：

```text
ArgumentDefaults[i] != "-"
    v 优先调用 UnrealToAngelscript
    +- 失败 -> 尝试 Fallback
ArgumentDefaults[i] == "-"
    v 直接尝试 Fallback (类型自带兜底, 如 Delegate -> "FXxx()")
    +- Fallback 也失败 -> 该参数及其后所有参数均不带默认值
```

### 2.3 关键转换规则速查

```text
类型               Unreal 格式                  AS 表达式
==================================================================
int/float/bool     "42"/"3.14"/"true"          原样透传 ("- 42" -> "-42" 去空格)
FString            "Hello"                      "\"Hello\"" (加引号)
FName              ""/"None"                    "NAME_None"
                   "MyName"                     "FName(\"MyName\")"
                   预处理器先把字面量替换为 __STATIC_NAME(n) 索引
UEnum              ""                           "EnumName::第0项"
                   "MyValue"                    "EnumName::MyValue"
UObject*/TSubclassOf  ""/"null"/"nullptr"      "nullptr"
FVector            ""                           "FVector()"
                   "1.0,2.0,3.0"               "FVector(1.0,2.0,3.0)"
                   AS 反向：识别 ZeroVector/UpVector/ForwardVector/...
                   FVector(42.0) 单参数 → 标量广播为 "42,42,42"
FRotator           ""                           "FRotator()"
                   AS 反向：识别 ZeroRotator
FLinearColor       "R=1 G=0 B=0 A=1"            "FLinearColor(1,0,0,1)"
                   解析器：FLinearColor::InitFromString（不用 FDefaultValueHelper）
                   AS 反向：识别 White/Gray/Black/Red/Green/Blue/Yellow/Transparent
Delegate           （Unreal 不写默认值）         Fallback → "FXxxDelegate()"
__WorldContext     "__WorldContext"             "__WorldContext"（透传）
```

**两个非对称要点**：
- `ZeroVector` / `ZeroRotator` 等"零"常量是**单向识别**：只在 AS→Unreal 方向被识别（输出空字符串），Unreal→AS 方向永远生成 `FVector()` 这种构造形式
- `FLinearColor` 解析走 `FLinearColor::InitFromString` 而不是 `FDefaultValueHelper::ParseLinearColor`，与其他向量类型解耦

### 2.4 主流程：`InitFromFunction` → `BuildFunctionDeclaration`

`Helper_FunctionSignature.h` 的 `InitFromFunction` 在引擎启动 / 热重载时为每个 UFunction 生成完整 AS 声明：

```cpp
void InitFromFunction(TSharedRef<FAngelscriptType> InType, UFunction* InFunction, ...)
{
    Function = InFunction;

    for (TFieldIterator<FProperty> It(Function);
         It && (It->PropertyFlags & CPF_Parm); ++It)
    {
        FProperty* Property = *It;
        FAngelscriptTypeUsage Type = FAngelscriptTypeUsage::FromProperty(Property);

        if (Property->PropertyFlags & CPF_ReturnParm)
        {
            ReturnType = Type;
        }
        else
        {
            ArgumentTypes.Add(Type);
            ArgumentNames.Add(Property->GetName());

            // 读取 UFUNCTION(DefaultValue=...) 编译后写在 meta 里的值
            FString DefaultMeta = TEXT("CPP_Default_");
            DefaultMeta += Property->GetName();         // "CPP_Default_Location"

            if (Function->HasMetaData(*DefaultMeta))
            {
                FString MetaStr = Function->GetMetaData(*DefaultMeta);
                if (MetaStr == TEXT("None"))
                    MetaStr = TEXT("");                 // FName 的 None 视为空
                ArgumentDefaults.Add(MetaStr);
            }
            else
            {
                ArgumentDefaults.Add(TEXT("-"));        // 无默认值哨兵
            }
        }
    }

    // WorldContext 参数注入魔法默认值（注意带括号）
    const FString& WCParam =
        Function->GetMetaData(NAME_Signature_WorldContext);
    if (WCParam.Len() != 0)
    {
        for (int32 i = 0; i < ArgumentTypes.Num(); ++i)
            if (ArgumentNames[i] == WCParam)
            {
                ArgumentDefaults[i] = TEXT("__WorldContext()");
                WorldContextArgument = i;
                break;
            }
    }

    // ScriptName == "-" 早退：函数从 AS 命名空间彻底隐藏
    if (ScriptName == TEXT("-"))
        return;

    // ScriptMixin：剥离第一个参数（this 对象），同步偏移 default 数组
    // UE 5.7+ 还支持函数级别 ScriptMethod meta 自动推断 mixin 目标
    if (HasScriptMixin && ArgumentTypes[0].IsObjectPointer())
    {
        ArgumentTypes.RemoveAt(0);
        ArgumentNames.RemoveAt(0);
        ArgumentDefaults.RemoveAt(0);     // ← default 数组联动裁剪
        if (WorldContextArgument >= 0)
            WorldContextArgument -= 1;    // ← 索引同步偏移
    }

    Declaration = FAngelscriptType::BuildFunctionDeclaration(
        ReturnType, ScriptName, ArgumentTypes, ArgumentNames, ArgumentDefaults,
        Function->HasAnyFunctionFlags(FUNC_Const) && !bStaticInScript);

    // 末尾追加返回值丢弃修饰符（与 default 共存于同一 Declaration 字符串）
    if (ReturnType.IsValid())
    {
        if (HasFuncMeta(NAME_ScriptNoDiscard))
            Declaration += TEXT(" no_discard");
        else if (HasFuncMeta(NAME_ScriptAllowDiscard))
            Declaration += TEXT(" allow_discard");
    }
}
```

`BuildFunctionDeclaration` 内部分两遍：

```cpp
FString FAngelscriptType::BuildFunctionDeclaration(...)
{
    // 第一遍：为每个参数计算 AS 默认值字符串，记录最后一个无默认值参数的位置
    int32 LastArgumentWithoutDefault = -1;
    for (int32 i = 0; i < ArgumentTypes.Num(); ++i)
    {
        FString& ASDefault = AngelscriptDefaultValues.Emplace_GetRef();
        bool bValid = false;

        if (ArgumentDefaults.IsValidIndex(i) && ArgumentDefaults[i] != TEXT("-"))
            bValid = ArgumentTypes[i].DefaultValue_UnrealToAngelscript(
                ArgumentDefaults[i], ASDefault);
        else
            bValid = ArgumentTypes[i].DefaultValue_AngelscriptFallback(ASDefault);

        if (!bValid) LastArgumentWithoutDefault = i;
    }

    // 第二遍：拼接，仅当 i > LastArgumentWithoutDefault 时附加 "= xxx"
    // （AS 语法要求：有默认值的参数必须连续排在尾部）
    for (int32 i = 0; i < ArgumentTypes.Num(); ++i)
    {
        // ... 拼 "Type Name" ...
        if (i > LastArgumentWithoutDefault
            && AngelscriptDefaultValues[i].Len() > 0)
            Declaration += TEXT(" = ") + AngelscriptDefaultValues[i];
    }
}
```

### 2.5 注册到 AS 引擎与 `ModifyScriptFunction`

声明字符串注册：

```cpp
asIScriptEngine->RegisterObjectMethod(ClassName, *Declaration, funcPtr, ...);
// AS 引擎解析声明中的 "= expr" 并存入 asCScriptFunction::defaultArgs[]
```

之后 `ModifyScriptFunction` 把不能用字符串表达的特殊属性写入 AS 函数对象（`Helper_FunctionSignature.h:512`）：

```cpp
void ModifyScriptFunction(int FunctionId)
{
    auto* ScriptFunction = (asCScriptFunction*)
        FAngelscriptManager::Get().GetScriptEngine()->GetFunctionById(FunctionId);

    if (WorldContextArgument != -1)
    {
        ScriptFunction->hiddenArgumentIndex   = WorldContextArgument;
        ScriptFunction->hiddenArgumentDefault = "__WorldContext()";
        // ↑ 关键：写入这两字段后，AS 编译器在调用点会跳过该参数
        //   并由引擎在调用前注入真实 WorldContext 指针（脚本完全无感）
    }

    if (DeterminesOutputTypeArgument != -1)
        ScriptFunction->determinesOutputTypeArgumentIndex = DeterminesOutputTypeArgument;

    if (bNotAngelscriptProperty) ScriptFunction->SetProperty(false);
    if (bBlueprintProtected)     ScriptFunction->SetProtected(true);

#if WITH_EDITOR
    // 注入 C++ 文档注释，与 default 值共用同一个 FunctionId
    FAngelscriptDocs::AddUnrealDocumentation(FunctionId,
        Function->GetMetaData(NAME_Signature_ToolTip),
        Function->GetMetaData(NAME_Signature_Category),
        Function);

    // 生成 AS 调用示例 tooltip（参数列表只显示参数名，不重复 default 值文本）
    FString ScriptTooltip = ...;
    Function->SetMetaData(NAME_AS_Tooltip, *ScriptTooltip);
#endif
}
```

### 2.6 反向写回：脚本函数 default → UFunction meta

当 AS 脚本自己定义带默认值的 `UFUNCTION` 函数时，`AngelscriptClassGenerator.cpp` 中的 `AddFunctionArgument` 会把 AS 默认值反向写到生成的 `UASFunction` meta 上，让蓝图引脚也能显示该默认值：

```cpp
FProperty* FAngelscriptClassGenerator::AddFunctionArgument(
    UFunction* NewFunction,
    const FAngelscriptArgumentDesc& ArgDesc,
    bool bAddToArgList)
{
    FProperty* NewProperty = ArgDesc.Type.CreateProperty(Params);
    NewProperty->SetPropertyFlags(CPF_Parm | CPF_RuntimeGenerated);

#if WITH_EDITOR
    if (ArgDesc.DefaultValue.Len() != 0)
    {
        FString UnrealDefault;
        if (ArgDesc.Type.DefaultValue_AngelscriptToUnreal(
                ArgDesc.DefaultValue, UnrealDefault))
        {
            FString MetaKey = TEXT("CPP_Default_");
            MetaKey += ArgDesc.ArgumentName;
            NewFunction->SetMetaData(*MetaKey, *UnrealDefault);
            // ↑ 蓝图通过 UEdGraphSchema_K2::FindFunctionParameterDefaultValue
            //   读取这个 meta，在节点引脚上预填默认值
        }
    }
#endif
    // ...
}
```

仅 `WITH_EDITOR` 下执行——Shipping 包的 `UASFunction` 不含该 meta，但 `defaultArgs[]` 依然有效（运行时调用展开不依赖 meta）。

### 2.7 调用点字节码展开

AS 编译器（`asCCompiler::CompileFunctionCall`）看到调用缺省参数时，**编译期**展开 `defaultArgs[]` 中的表达式直接内联到调用字节码中：

```
脚本调用：SpawnActor(MyClass);

AS 编译器查 defaultArgs[1..3]：
  [1] = "FVector(0,0,0)"      → 编译为 CONSTRUCT FVector(0,0,0) 字节码
  [2] = "FRotator()"          → 编译为 CONSTRUCT FRotator() 字节码
  [3] = "__WorldContext()"    → hiddenArgumentIndex 标记，不生成脚本侧字节码

字节码序列：
  asBC_PSF v0                       // MyClass
  asBC_PSF tmp_vec; CONSTRUCT FVector  // 临时 FVector
  asBC_PSF tmp_rot; CONSTRUCT FRotator // 临时 FRotator
  // hiddenArg 跳过
  asBC_CALL SpawnActor
```

**生命周期**：默认值对象是**调用点的临时栈对象**，函数返回后立即由 `FDestructorCall` 析构。

### 2.8 StaticJIT 路径：字节码 → 原生 C++

`AngelscriptBytecodes.cpp` 中的 `FDefaultConstructCall::CallDefaultConstruct` 把 CONSTRUCT 字节码翻译为原生 C++ 调用，三条优先级路径：

```
路径 ①：原生访问 + TrivialFunction → 直接内联构造
        ((FVector*)addr)->FVector::FVector(0,0,0);

路径 ②：系统函数 → 通过函数指针调用
        auto fn = (void(*)(void*))BehFunc.GetFunction();
        fn((void*)addr);

路径 ③：脚本结构体 → 调用 AS 脚本构造
        FCallScriptFunction(BehFunc).MakeCall(Context);
```

### 2.9 Shipping 包：`InitFromDB` 跳过 default 数组

```cpp
void InitFromDB(..., const FAngelscriptMethodBind& DBBind, ...)
{
    Function = InFunction;
    Declaration = DBBind.Declaration;   // 已含 "= default_value" 完整字符串
    WorldContextArgument = DBBind.WorldContextArgument;
    // ArgumentDefaults 不填充，AS 引擎直接从 Declaration 字符串解析默认值
}
```

绑定数据库（DB）保存的是已经构造好的完整 `Declaration`，运行时不需要再走 `CPP_Default_*` meta + 类型转换的链路，启动更快。

---

## 三、跨路径协同点

### 3.1 预编译数据持久化：两条路径都走 `ParameterDefaultArgs`

`PrecompiledData.h`：

```cpp
struct FAngelscriptPrecompiledFunctionSignature
{
    FStringInArchive Name;
    FStringInArchive Namespace;
    TArray<FAngelscriptPrecompiledDataType> ParameterTypes;
    TArray<int32>    ParameterFlags;
    TArray<FStringInArchive> ParameterDefaultArgs;  // ← 持久化 defaultArgs[]
    FAngelscriptPrecompiledDataType ReturnType;
};

// 顶层数据还序列化 StaticNames，用来还原 FName 默认值的 __STATIC_NAME(n) 索引
struct FAngelscriptPrecompiledData
{
    TArray<FName> StaticNames;
    // ...
};
```

数据流：

```text
asCScriptFunction::defaultArgs[]
    | InitFrom()
    v
FAngelscriptPrecompiledFunctionSignature::ParameterDefaultArgs
    | FArchive 序列化   -> .precompiled 文件
    | FArchive 反序列化 <- .precompiled 文件
    v
ParameterDefaultArgs[]
    | Create()
    v
asCScriptFunction::defaultArgs[]    (冷启动跳过重编译)
```

属性 `default` 路径不直接序列化——它的最终产物 `__InitDefaults()` 字节码是普通脚本函数，跟随模块字节码一起持久化。

### 3.2 热重载：刻意排除 `DefaultValue` 比较

这是一个非常重要的设计决策（`AngelscriptEngine.h`）：

```cpp
bool FAngelscriptArgumentDesc::IsDefinitionEquivalent(
    const FAngelscriptArgumentDesc& Other) const
{
    return Other.bBlueprintByValue   == bBlueprintByValue
        && Other.bBlueprintOutRef    == bBlueprintOutRef
        && Other.bBlueprintInRef     == bBlueprintInRef
        && Other.bInRefForceCopyOut  == bInRefForceCopyOut
        && Other.Type                == Type;
        // ↑ DefaultValue 和 ArgumentName 都不参与比较
}
```

后果：

```
修改前：void Foo(int X = 10)
修改后：void Foo(int X = 99)

IsDefinitionEquivalent → true
    → ReloadReq < FullReloadRequired
    → 不重建 UClass / UASFunction
    → 只更新 asCScriptFunction::defaultArgs[]

✅ AS 脚本调用时立即用新值（99）
⚠️ 蓝图节点引脚还显示旧值（10），需要手动刷新蓝图才更新
```

属性 `default`（路径 ①）的热重载策略与路径 ② 相反——**修改属性 default 语句会建议触发 FullReload**（`AngelscriptClassGenerator.cpp:1397`）：

```cpp
// If we changed code in 'default' statements, we need to suggest a full reload
// to propagate the changes to properties properly.
if (ClassData.OldClass->DefaultsCode != ClassData.NewClass->DefaultsCode)
{
    if (ClassData.ReloadReq < EReloadRequirement::FullReloadSuggested)
        ClassData.ReloadReq = EReloadRequirement::FullReloadSuggested;
}
```

这正是预处理器把 default 语句拼接为 `ClassDesc->DefaultsCode` 字符串的**唯一目的**——做整段文本比较，发现变化就建议 FullReload。设计上是"建议"（Suggested）而非"必需"（Required），因为：
- AS 字节码本身在每次重编译时都会重生成（`__InitDefaults` 跟随类的字节码）
- 但**已经存在的 UObject 实例**的属性值不会自动跑一遍新的 `__InitDefaults`——为了让旧实例的属性同步到新默认值，需要 FullReload 重建实例
- 用户可以选择拒绝这次 FullReload，但旧实例会保留 default 修改前的值

两条路径热重载策略对比：

| 路径 | `IsDefinitionEquivalent` 是否含 default | 修改 default 后果 |
|------|----------------------------------------|------------------|
| 路径 ① 属性 default | 通过 `DefaultsCode` 整段字符串比较 | `FullReloadSuggested`：建议重建实例以应用新默认值 |
| 路径 ② 函数参数 default | `DefaultValue` 不参与等价性比较 | 不触发 FullReload，只更新 `defaultArgs[]`；蓝图引脚需手动刷新 |

### 3.3 错误诊断点

```
错误点 ①：AS 编译期 — 调用点参数不足
    LogAngelscriptError() → asMSGTYPE_ERROR
    → UE_LOG(Angelscript, Error, ...) + Diagnostics 收集
    → VS Code Problems 面板红色波浪线（行号/列号）

错误点 ②：绑定阶段 — 默认值格式无法解析
    UnrealToAngelscript 返回 false 且 Fallback 也失败
    → LastArgumentWithoutDefault 标记
    → 该参数及其后的所有参数在 AS 中都成为必填
    （不崩溃，只是"默默丢失"默认值）

错误点 ③：JIT 编译期 — 默认值对象构造失败
    check(beh.construct != 0) 失败
    → 引擎断言崩溃（开发构建）
    原因：声明里有 "= SomeType()" 但 SomeType 没注册构造函数

错误点 ④：运行时 — WorldContext 注入失败
    SetNullPointerException()
    → HandleExceptionFromJIT() → LogAngelscriptException()
    → UE 运行时空指针 + 调用堆栈
```

---

## 四、ASCII 全景架构图

```text
=====================================================================
  [Path 1] 属性 default (类体顶层 default 语句)
=====================================================================

.as 源码 (default Mesh.RelativeLocation = FVector(0,0,90);)
    |
    +-- 预处理器路径 (仅供热重载比较) --------------------------------
    |     ParseIntoChunks -> Chunk.Defaults += FDefaultsCode
    |     ProcessDefaults -> ClassDesc.DefaultsCode (拼接字符串)
    |       | 仅用于 ClassGenerator 比较
    |       | if OldClass.DefaultsCode != NewClass.DefaultsCode:
    |       |     ReloadReq = FullReloadSuggested
    |
    +-- AS 内核路径 (真正生成字节码) ----------------------------------
          AS 解析器: default 行 -> snClassDefaultStatement AST 节点
          as_builder.cpp 收集到 decl->defaultStatements
          AddInitDefaultsFunction -> 注册 "void __InitDefaults()" 槽位
          asCCompiler::CompileDefaultStatements
            遍历 defaultStatements, 重新解析为表达式 + 字节码
          v
          UpdateConstructAndDefaultsFunctions
            GetMethodByDecl("void __InitDefaults()")
          UASClass.DefaultsFunction = asCScriptFunction*
          v
          对象构造时 ExecuteDefaultsFunctions
          沿继承链 祖->父->子 倒序执行 (m_executeVirtualCall=false)


=====================================================================
  [Path 2] 函数参数默认值
=====================================================================

C++ UFunction
  meta CPP_Default_Location = "0.0,0.0,0.0"
  meta WorldContext = "WorldContextObject"
        | InitFromFunction 读 meta
        v
  ArgumentDefaults[] = ["-", "0.0,0.0,0.0", "", "__WorldContext()"]
                        ^     ^              ^    ^
                        无    具体值          零   魔法标记 (带括号)
        | BuildFunctionDeclaration (两遍)
        |   第1遍: 调用 UnrealToAngelscript 或 Fallback
        |   第2遍: 拼接 "Type Name = ASDefault"
        v
  Declaration = "void SpawnActor(
                    TSubclassOf<AActor> Class,
                    FVector Location = FVector(0.0,0.0,0.0),
                    FRotator Rotation = FRotator(),
                    UObject@ Ctx = __WorldContext()) const no_discard"
        | asIScriptEngine::RegisterObjectMethod
        v
  asCScriptFunction::defaultArgs[]
        | ModifyScriptFunction
        |   hiddenArgumentIndex   = WorldContextArgument
        |   hiddenArgumentDefault = "__WorldContext()"
        v
  AS 编译器在调用点展开 defaultArgs -> CONSTRUCT 字节码
        | StaticJIT
        v
  原生 C++ 构造调用 + 函数调用


[反向闭环: 脚本 -> 蓝图]

AS 脚本写: UFUNCTION() void Foo(int X = 42)
    | AddFunctionArgument [WITH_EDITOR]
    |   AngelscriptToUnreal: "42" -> "42"
    |   NewFunction->SetMetaData("CPP_Default_X", "42")
    v
UASFunction 含 CPP_Default_X meta
    | UEdGraphSchema_K2::FindFunctionParameterDefaultValue
    v
蓝图节点引脚预填默认值 "42"


[预编译持久化]

asCScriptFunction::defaultArgs[]
    <-> FAngelscriptPrecompiledFunctionSignature::ParameterDefaultArgs
    <-> .precompiled 文件 (含 StaticNames 表用于 FName)


[两条路径的热重载策略]

[Path 1]: DefaultsCode 字符串比较 -> 改 default 触发 FullReloadSuggested
          原因: 旧实例已经构造完成, 需要重建才能应用新的 __InitDefaults

[Path 2]: IsDefinitionEquivalent 不比较 DefaultValue
          -> 改 default 不触发 FullReload, 只更新 defaultArgs[]
          -> AS 立即生效, 蓝图引脚需手动刷新
```

---

## 五、关键源码索引

| 关注点 | 源码位置 |
|--------|---------|
| 路径① 预处理器扫描登记 | `AngelscriptPreprocessor.cpp:3636` 在 `ParseIntoChunks` 中识别 `default ` |
| 路径① 拼接 DefaultsCode 字符串（**仅供热重载比较**） | `AngelscriptPreprocessor.cpp:1230` `ProcessDefaults` |
| 路径① 主流程调度 | `AngelscriptPreprocessor.cpp:280` 主流程循环 |
| 路径① AS 解析器节点定义 | `as_parser.cpp` `snClassDefaultStatement` 节点类型 |
| 路径① AS 内核节点收集 | `as_builder.cpp:715` 在 `RegisterScriptFunctionFromNode` 同级遍历中收集 |
| 路径① AS 内核 `__InitDefaults` 注册 | `as_builder.cpp:4193` `AddInitDefaultsFunction` |
| 路径① AS 内核字节码生成 | `as_compiler.cpp:804` `CompileDefaultStatements` |
| 路径① 类生成器抓取函数指针 | `AngelscriptClassGenerator.cpp:5881` `UpdateConstructAndDefaultsFunctions` |
| 路径① 运行时执行 | `ASClass.cpp:1093` `ExecuteDefaultsFunctions` |
| 路径① 热重载比较点 | `AngelscriptClassGenerator.cpp:1397` `DefaultsCode` 整段字符串比较 |
| 路径② 数据结构 | `AngelscriptEngine.h` `FAngelscriptArgumentDesc` |
| 路径② 函数签名 | `Helper_FunctionSignature.h` `FAngelscriptFunctionSignature` |
| 路径② meta 读取 | `Helper_FunctionSignature.h:257` `InitFromFunction` 中 `CPP_Default_` |
| 路径② 声明拼装 | `AngelscriptType.cpp` `BuildFunctionDeclaration` |
| 路径② WorldContext 注入 | `Helper_FunctionSignature.h:512` `ModifyScriptFunction` |
| 路径② 反向写回 | `AngelscriptClassGenerator.cpp:4008` `AddFunctionArgument` |
| 路径② Delegate 特殊路径 | `Bind_BlueprintEvent.cpp:749` `BindDelegateEvent` |
| 路径② 类型转换实现 | `Bind_Primitives.cpp` / `Bind_FVector.cpp` / `Bind_FName.cpp` / `Bind_UEnum.cpp` / `Bind_Delegates.cpp` 等 |
| JIT 默认值构造 | `AngelscriptBytecodes.cpp` `FDefaultConstructCall::CallDefaultConstruct` |
| 预编译持久化 | `PrecompiledData.h` `FAngelscriptPrecompiledFunctionSignature` |
| 热重载等价性比较 | `AngelscriptEngine.h` `FAngelscriptArgumentDesc::IsDefinitionEquivalent` |
| FName 静态表查询 | `Bind_FName.cpp:61` `FAngelscriptEngine::TryGetStaticName` |
| 蓝图引脚读取 | `EdGraphSchema_K2.cpp` `FindFunctionParameterDefaultValue` |

---

## 六、关键结论速查

| 主题 | 结论 |
|------|------|
| **两套独立机制** | 类体顶层 `default` 语句（→ `__InitDefaults`）与函数参数 `=` 默认值（→ `defaultArgs[]`）共用关键字但实现完全分离 |
| **类体 default 编译产物** | AS 解析器把 `default` 行识别为 `snClassDefaultStatement` AST 节点 → AS 内核 `as_builder.cpp` 收集到 `decl->defaultStatements` → `AddInitDefaultsFunction` 注册 `__InitDefaults` 方法 → `CompileDefaultStatements` 生成字节码；预处理器的 `ClassDesc->DefaultsCode` 字符串**不参与字节码生成**，**只用于热重载比较** |
| **类体 default 执行顺序** | `ExecuteDefaultsFunctions` 沿继承链祖→父→子倒序执行，`m_executeVirtualCall=false` 禁用虚分发避免递归 |
| **函数参数 default 编译产物** | 字符串存于 `asCScriptFunction::defaultArgs[]`，AS 编译器在**调用点**展开为构造字节码内联到调用序列 |
| **`-` 哨兵** | `ArgumentDefaults[i]=="-"` 表示该参数没有任何默认值；空串则代表"默认值=类型零值" |
| **`__WorldContext()` 魔法** | `ArgumentDefaults` 与 `hiddenArgumentDefault` 都是带括号的 `"__WorldContext()"`（一个全局函数调用表达式），通过 `hiddenArgumentIndex` 在调用点对脚本完全透明地注入真实 WorldContext |
| **数据流主向** | C++ UFunction meta → AS `defaultArgs[]`（绑定时正向）；AS 脚本 default → UFunction meta（仅 `WITH_EDITOR` 反向写回，供蓝图引脚显示） |
| **路径② 热重载策略** | `IsDefinitionEquivalent` 刻意不比 `DefaultValue` → 改 default 不触发 FullReload → AS 立即生效但蓝图引脚需手动刷新 |
| **路径① 热重载策略** | `ClassDesc->DefaultsCode` 整段字符串比较 → 修改即触发 `FullReloadSuggested`（建议而非强制），目的是让旧实例的属性同步到新默认值 |
| **预编译持久化** | `defaultArgs[]` 序列化到 `FAngelscriptPrecompiledFunctionSignature::ParameterDefaultArgs`（`.precompiled` 文件），Shipping 冷启动跳过重编译 |
| **Delegate 例外** | `BindDelegateEvent` 中 `ArgumentDefaults` 永远为空数组——`Broadcast` / `Execute` / `ExecuteIfBound` 调用必须显式传所有参数；`Execute` 系列额外追加 `allow_discard` 修饰符 |
| **Delegate Fallback** | `Bind_Delegates.cpp` 是当前唯一实现 `DefaultValue_AngelscriptFallback` 的类型，回退结果是 `Name + "()"`（如 `"FMyDelegate()"`） |
| **错误集中点** | ① AS 编译期参数不匹配 → VS Code Problems；② 绑定期默认值无法解析 → 默默降级为必填；③ JIT 期构造函数缺失 → 断言崩溃；④ 运行期 WorldContext 失效 → 空指针异常 |

---

## 七、附录：易遗漏的实现细节

### 7.1 `FName` 的 `__STATIC_NAME(n)` 索引机制

`FName` 默认值在两个方向上都有特殊处理，并依赖一个**全局静态名字表**，AS 通过 `FAngelscriptEngine::TryGetStaticName(Index, OutName)` 反查：

```cpp
// Bind_FName.cpp — UnrealToAngelscript：把 FName meta 包成 FName("...") 字面量
bool DefaultValue_UnrealToAngelscript(...)
{
    if (InValue == "None" || InValue == "NAME_None" || InValue.IsEmpty())
    {
        OutValue = TEXT("NAME_None");           // 统一用 NAME_None
        return true;
    }
    OutValue = FString::Printf(TEXT("FName(\"%s\")"), *InValue);
    return true;
}

// Bind_FName.cpp — AngelscriptToUnreal：识别预处理器替换后的 __STATIC_NAME(n) 索引
bool DefaultValue_AngelscriptToUnreal(...)
{
    OutValue = InValue;
    OutValue.TrimStartAndEndInline();

    if (OutValue == "None" || OutValue == "NAME_None")
    {
        OutValue = TEXT("None");
        return true;
    }

    // 剥掉 FName(...) 包裹
    if (OutValue.RemoveFromStart(TEXT("FName")))
    {
        OutValue.TrimStartAndEndInline();
        OutValue.RemoveFromStart(TEXT("("));
        OutValue.RemoveFromEnd(TEXT(")"));
    }

    // 关键：预处理器把 FName 字面量替换为 __STATIC_NAME(n) 数字索引
    if (OutValue.RemoveFromStart(TEXT("__STATIC_NAME (")))
    {
        int32 Index = -1;
        LexFromString(Index, *OutValue);

        FName StaticName;
        if (FAngelscriptEngine::TryGetStaticName(Index, StaticName))   // ← 实际 API
        {
            OutValue = StaticName.ToString();
            return true;
        }
        return false;
    }

    OutValue = OutValue.TrimQuotes();
    return true;
}
```

`__STATIC_NAME(int Id)` 本身是 AS 全局函数（`Bind_FName.cpp:207` 中 `FAngelscriptBinds::BindGlobalFunction("const FName& __STATIC_NAME(int Id) no_discard", ...)`），运行时由 AS 字节码直接调用查表。

**完整闭环**：

```
.as 源码    : default MyName = n"PlayerStart"
预处理器    : 替换为 default MyName = __STATIC_NAME(42)
              并把 "PlayerStart" 加入引擎的静态名字表 [42]
AS 编译     : __InitDefaults 字节码引用 __STATIC_NAME(42) 全局函数
反向写回    : 蓝图节点引脚需要时通过 TryGetStaticName(42) 反查 → "PlayerStart"
预编译持久化 : StaticNames 整表随 FAngelscriptPrecompiledData 序列化
```

### 7.2 `FString` 引号处理的两端对称

```cpp
// Unreal → AS：加双引号
bool FStringType::DefaultValue_UnrealToAngelscript(...)
{
    OutValue = FString::Printf(TEXT("\"%s\""), *InValue);   // "Hello" → "\"Hello\""
    return true;
}

// AS → Unreal：用 TrimQuotes() 去引号
bool FStringType::DefaultValue_AngelscriptToUnreal(...)
{
    OutValue = InValue.TrimQuotes();                        // "\"Hello\"" → "Hello"
    return true;
}
```

`TrimQuotes()` 是 UE 提供的字符串方法，只剥去**首尾匹配的**单/双引号，对内容中的引号保持原样。

### 7.3 数字类型的负号空格处理

AS 编译器在序列化某些表达式时会把负数表示为 `"- 42"`（运算符 + 操作数），但 Unreal meta 约定的是紧凑格式 `"-42"`：

```cpp
// Bind_Primitives.cpp — TPrimitiveAngelscriptType
bool DefaultValue_AngelscriptToUnreal(
    const FAngelscriptTypeUsage& Usage,
    const FString& AngelscriptValue,
    FString& OutUnrealValue) const override
{
    if (Usage.bIsReference)
        return false;                       // 引用参数不允许默认值

    OutUnrealValue = AngelscriptValue;
    if (OutUnrealValue.StartsWith("- "))
        OutUnrealValue = TEXT("-") + AngelscriptValue.Mid(1).TrimStartAndEnd();
    return true;
}
```

如果不去这个空格，蓝图节点引脚会显示成 `"- 42"`，这是 UI 上的展示瑕疵。

### 7.4 `LastArgumentWithoutDefault` 存在的理由：AS 语法约束

AngelScript 与 C++/C# 一样要求**有默认值的参数必须连续排在尾部**。Unreal 反射元数据并不强制这一点——一个 UFunction 完全可以是 `void Foo(int A = 10, FVector B, int C = 20)`。`BuildFunctionDeclaration` 必须自己处理这种"中间打洞"的情况：

```
C++ UFunction 元数据：
  [A: CPP_Default_A=10]   [B: 无 default]   [C: CPP_Default_C=20]

第一遍：
  i=0 A:  UnrealToAngelscript 成功
  i=1 B:  ArgumentDefaults[1]=="-" → Fallback 失败
          → LastArgumentWithoutDefault = 1
  i=2 C:  UnrealToAngelscript 成功

第二遍拼接：
  i=0 A:  i (0) > LastArgumentWithoutDefault (1) ? 否 → 不附加 "= 10"
  i=1 B:  i (1) > LastArgumentWithoutDefault (1) ? 否 → 不附加默认值
  i=2 C:  i (2) > LastArgumentWithoutDefault (1) ? 是 → 附加 "= 20"

最终 AS 声明：void Foo(int A, FVector B, int C = 20)
            ↑ A 的默认值被"丢弃"了，因为它前面有无默认值参数
```

这是一种**保守降级**——宁可让用户多写几个实参，也不让 AS 编译器拒绝这个声明。

### 7.5 `FVector` scalar 广播与精度差异

```cpp
// FVector AS→Unreal 的构造形式解析
else if (FDefaultValueHelper::GetParameters(CppForm, TEXT("FVector"), Parameters))
{
    FVector Vector;
    double Scalar;
    if (FDefaultValueHelper::ParseVector(Parameters, Vector))
        OutForm = FString::Printf(TEXT("%f,%f,%f"), Vector.X, Vector.Y, Vector.Z);
    else if (FDefaultValueHelper::ParseDouble(Parameters, Scalar))
        OutForm = FString::Printf(TEXT("%f,%f,%f"), Scalar, Scalar, Scalar);
    //                                              ↑ 单参数广播为三个分量
}
```

`FVector(42.0)` → `"42.000000,42.000000,42.000000"`，对应 UE 中 `FVector::FVector(double InF)` 的统一构造行为。

**精度路径分叉**：

| 类型 | 解析器 |
|------|--------|
| `FVector` / `FVector2D` | `ParseDouble` |
| `FVector3f` / `FVector2f` | `ParseFloat` |

float / double 的解析路径完全独立，避免了精度损失或越界问题。

### 7.6 `FLinearColor` 8 个具名静态常量

```cpp
// FLinearColorType::DefaultValue_AngelscriptToUnreal
if (FDefaultValueHelper::Is(CppForm, TEXT("FLinearColor :: White")))      OutForm = FLinearColor::White.ToString();
else if (FDefaultValueHelper::Is(CppForm, TEXT("FLinearColor :: Gray")))  OutForm = FLinearColor::Gray.ToString();
else if (FDefaultValueHelper::Is(CppForm, TEXT("FLinearColor :: Black"))) OutForm = FLinearColor::Black.ToString();
else if (FDefaultValueHelper::Is(CppForm, TEXT("FLinearColor :: Transparent"))) OutForm = FLinearColor::Transparent.ToString();
else if (FDefaultValueHelper::Is(CppForm, TEXT("FLinearColor :: Red")))   OutForm = FLinearColor::Red.ToString();
else if (FDefaultValueHelper::Is(CppForm, TEXT("FLinearColor :: Green"))) OutForm = FLinearColor::Green.ToString();
else if (FDefaultValueHelper::Is(CppForm, TEXT("FLinearColor :: Blue")))  OutForm = FLinearColor::Blue.ToString();
else if (FDefaultValueHelper::Is(CppForm, TEXT("FLinearColor :: Yellow"))) OutForm = FLinearColor::Yellow.ToString();
else { /* GetParameters + ParseLinearColor 通用解析 */ }
```

注意 `FLinearColor` **没有 `ZeroColor` 这种"输出空字符串"的常量**——所有 8 个常量都展开为完整数值，与 `FVector::ZeroVector` 的处理方式不同（详见 7.7）。

### 7.7 `ZeroVector` / `ZeroRotator` 的"返回 true 但 OutForm 为空"语义

```cpp
// FVectorType::DefaultValue_AngelscriptToUnreal
if (FDefaultValueHelper::Is(CppForm, TEXT("FVector :: ZeroVector")))
    return true;                          // ← 返回 true，但 OutForm 保持空
```

这是一个反直觉的约定——空字符串在 Unreal meta 中等价于"默认零值"，所以 `FVector::ZeroVector` 反向写回时刻意不输出 `"0,0,0"`，而是输出空字符串以触发 UE 的"零值简写"路径。

完整的"零值常量"清单：

| 类型 | 零值常量 | 行为 |
|------|---------|------|
| `FVector` | `ZeroVector` | OutForm = `""` |
| `FVector2D` / `FVector2f` | `ZeroVector` | OutForm = `""` |
| `FVector3f` | `ZeroVector` | OutForm = `""` |
| `FRotator` / `FRotator3f` | `ZeroRotator` | OutForm = `""` |

非零静态常量（`UpVector` / `ForwardVector` / `RightVector` / `OneVector` / `UnitVector`）都正常输出具体数值。

### 7.8 `UEnum` 的空字符串 → 第 0 项

```cpp
bool FEnumType::DefaultValue_UnrealToAngelscript(...)
{
    OutValue = InValue;
    if (!OutValue.Contains(TEXT("::")))
    {
        FString EnumName = ...;
        if (OutValue.Len() == 0)
        {
            if (Enum == nullptr) return false;
            OutValue = Enum->GetNameStringByValue(0);   // ← 取值为 0 的枚举项名称
            OutValue = FString::Printf(TEXT("%s::%s"), *EnumName, *OutValue);
            // ECollisionChannel 空字符串 → "ECollisionChannel::ECC_WorldStatic"
        }
        else
        {
            OutValue = FString::Printf(TEXT("%s::%s"), *EnumName, *OutValue);
        }
    }
    return true;
}
```

Unreal 的枚举默认值约定与字符串/向量不同——空字符串不代表"枚举值 0"的字面量，而是要查表得到值为 0 的枚举项名称。如果枚举的第 0 项名为 `ECC_WorldStatic`，AS 声明里就必须写出完整的 `ECollisionChannel::ECC_WorldStatic`。

### 7.9 Delegate 的两个特殊性

**特殊性一**：`Bind_Delegates.cpp` 是**唯一已知实现 `DefaultValue_AngelscriptFallback` 的类型**：

```cpp
struct FScriptDelegateType : FAngelscriptType
{
    FString Name;
    bool DefaultValue_AngelscriptFallback(
        const FAngelscriptTypeUsage&, FString& OutAngelscriptValue) const
    {
        OutAngelscriptValue = Name + TEXT("()");         // → "FMyDelegate()"
        return true;
    }
    // 既不实现 UnrealToAngelscript，也不实现 AngelscriptToUnreal
    // 因为 C++ 侧从不在 UFunction meta 里给 delegate 参数设默认值
};

struct FMulticastScriptDelegateType : FAngelscriptType { /* 同上 */ };
```

这意味着 Delegate 类型参数的默认值生成路径**完全绕过双向转换**，只走 Fallback 兜底。

**特殊性二**：`BindDelegateEvent` 中传给 `BuildFunctionDeclaration` 的 `ArgumentDefaults` **永远为空数组**：

```cpp
// Bind_BlueprintEvent.cpp — BindDelegateEvent
TArray<FString> ArgumentDefaults;       // 声明了，但永远不填充
for (TFieldIterator<FProperty> It(Function); ...) {
    ArgumentNames.Add(Property->GetName());
    // 没有读取 CPP_Default_* meta
}

// 三种委托方法都不带默认值
Delegate_.GenericMethod(
    BuildFunctionDeclaration(ReturnType, "Broadcast", Types, Names,
        ArgumentDefaults /*空*/, true), ...);
```

这是**刻意设计**——`Broadcast` / `Execute` / `ExecuteIfBound` 调用必须显式传入所有参数，与 Delegate 类型作为**值参数**时通过 Fallback 拿到默认值是两件不同的事。

### 7.10 `ScriptName == "-"` 早退机制

```cpp
// Helper_FunctionSignature.h — InitFromFunction()
ScriptName = GetScriptNameForFunction(Function);

if (ScriptName == TEXT("-"))
    return;
// ↑ 该函数从 AS 命名空间彻底隐藏：
//   - Declaration 不生成
//   - WorldContext default 不注入
//   - DeterminesOutputType 不设置
//   - ArgumentDefaults 已被填充但不被使用（"白读"）
```

这是 UFunction 的 `ScriptName="-"` meta 约定，专门用来对 AS 屏蔽某些函数。读到这一步时 `ArgumentDefaults` 已经填好了，但后面所有依赖它的步骤都被跳过——这是少数几个**性能浪费可接受**的设计点（早退检查放在前面会破坏代码组织）。

### 7.11 `ScriptMixin` 对 `ArgumentDefaults` 的联动裁剪

C++ 静态函数被绑定为某个类型的 Mixin 成员函数时，第 0 个参数（`this` 对象）需要从签名中剥离。三个并行数组必须同步裁剪，索引型字段也要同步偏移：

```cpp
const FString& MixinClasses =
    Function->GetOuterUClass()->GetMetaData(NAME_Signature_ScriptMixin);

if (MixinClasses.Len() != 0 && ArgumentTypes.Num() > 0
    && (ArgumentTypes[0].IsObjectPointer() || ArgumentTypes[0].bIsReference))
{
    FString FirstParamType = ArgumentTypes[0].Type->GetAngelscriptTypeName();
    for (const FString& Mixin : MixinList)
    {
        if (FirstParamType == Mixin)
        {
            ArgumentTypes.RemoveAt(0);
            ArgumentNames.RemoveAt(0);
            ArgumentDefaults.RemoveAt(0);            // ← 联动裁剪
            ClassName = Mixin;
            bStaticInScript = false;

            if (WorldContextArgument >= 0)
                WorldContextArgument -= 1;           // ← 索引同步偏移
            if (DeterminesOutputTypeArgument >= 0)
                DeterminesOutputTypeArgument -= 1;
            break;
        }
    }
}
```

**副作用**：原 C++ 静态函数的第 0 个参数如果设了 `CPP_Default_*` meta，这个默认值会随 `RemoveAt(0)` 一起丢失——但实际上第 0 个参数本来就是 Mixin 目标对象，必须由调用方提供，丢失默认值无影响。

### 7.12 `WriteToDB` 中 `ScriptName` 仅在 `BlueprintEvent` 才持久化

```cpp
void WriteToDB(FAngelscriptMethodBind& DBBind)
{
    DBBind.Declaration = Declaration;       // 完整声明（含 default 值）
    DBBind.UnrealPath  = Function->GetName();
    DBBind.WorldContextArgument = WorldContextArgument;
    // ...

    if (Function->HasAnyFunctionFlags(FUNC_BlueprintEvent))
        DBBind.ScriptName = ScriptName;     // ← 只有 BlueprintEvent 才存
}
```

普通函数的 ScriptName 可以从 `Function->GetName()` 推导出来；而 `BlueprintEvent` 经过了 `Received_` / `Receive` 前缀剥除，不持久化就无法在 Shipping 包里恢复。这是 DB 体积优化的一个细节。

### 7.13 `Declaration` 末尾的修饰符追加

`InitFromFunction` 在 `BuildFunctionDeclaration` 之后还会向 `Declaration` 末尾追加返回值修饰符，与 default 值共存于同一个声明字符串中（`Helper_FunctionSignature.h:413`）：

```cpp
// 仅当返回值有效时才追加（修饰符针对返回值）
if (ReturnType.IsValid())
{
    if (HasFuncMeta(NAME_ScriptNoDiscard))
        Declaration += TEXT(" no_discard");
    else if (HasFuncMeta(NAME_ScriptAllowDiscard))
        Declaration += TEXT(" allow_discard");
}
```

完整 Declaration 示例：

```
"int32 GetScore(int32 PlayerId = 0) const no_discard"
                          ^^^^^^^^         ^^^^^^^^^^
                          default 值        AS 编译器强制使用返回值
```

`no_discard` 与 `allow_discard` 是**互斥的**——同时设置时 `no_discard` 优先。理解这一点对调试 `RegisterObjectMethod` 失败的"莫名"声明字符串错误非常关键。

> 注：`Bind_FString.cpp` / `Bind_InputEvents.cpp` 中能见到 `accept_temporary_this` 字面量（用于直接构造 AS 类型注册声明）。当前 `Helper_FunctionSignature.h` 也已支持通过 UFUNCTION `meta=(ScriptAllowTemporaryThis)` 自动追加该 modifier。

### 7.14 `AS_Tooltip` 不重复 default 值文本

```cpp
#if WITH_EDITOR
FString ScriptTooltip;
if (!bStaticInScript)
    ScriptTooltip += FString::Printf(TEXT("%s Target;\n"), *ClassName);
if (ReturnType.IsValid())
{
    ScriptTooltip += ReturnType.GetAngelscriptDeclaration();
    ScriptTooltip += TEXT(" ReturnValue = ");
}
ScriptTooltip += bStaticInScript ? ClassName + TEXT("::") : TEXT("Target.");
ScriptTooltip += ScriptName + TEXT("(");
for (int32 i = 0; i < ArgumentTypes.Num(); ++i)
{
    if (i != 0) ScriptTooltip += TEXT(", ");
    ScriptTooltip += ArgumentNames[i];                    // ← 只有参数名
    // 这里特意不输出 default 值——避免与 Declaration 字符串重复
}
ScriptTooltip += TEXT(");");
Function->SetMetaData(NAME_AS_Tooltip, *ScriptTooltip);
#endif
```

蓝图节点的 tooltip 只展示**调用骨架**而不展示默认值，因为：
1. Declaration 字符串已经在 LSP 悬浮提示中完整显示
2. 蓝图节点引脚旁会单独显示默认值（来自 `CPP_Default_*` meta 反向写回）

### 7.15 函数级别的 `IsDefinitionEquivalent` 也排除 default

不仅参数级别 `FAngelscriptArgumentDesc::IsDefinitionEquivalent` 不比较 `DefaultValue`，函数级别的 `FAngelscriptFunctionDesc::IsDefinitionEquivalent` 也只比较访问控制和网络/蓝图标志，不包含返回类型和参数 default：

```cpp
bool FAngelscriptFunctionDesc::IsDefinitionEquivalent(
    const FAngelscriptFunctionDesc& Other) const
{
    return Other.bBlueprintCallable    == bBlueprintCallable
        && Other.bBlueprintOverride    == bBlueprintOverride
        && Other.bBlueprintEvent       == bBlueprintEvent
        && Other.bBlueprintPure        == bBlueprintPure
        && Other.bNetFunction          == bNetFunction
        // ... 一系列标志位 ...
        && Other.bIsConstMethod        == bIsConstMethod
        && Other.bThreadSafe           == bThreadSafe
        && Other.bIsPrivate            == bIsPrivate
        && Other.bIsProtected          == bIsProtected;
    // 无返回类型比较，无参数默认值比较
}
```

这两层等价性比较共同确保 default 值修改是**最低代价的热重载操作**——只更新字节码，不动 UClass 任何字段。

### 7.16 `UAngelscriptSettings` 全局 default 配置

预处理器构造时从设置中读取一组**全局默认配置**，影响整个项目所有属性和函数的默认行为：

```cpp
FAngelscriptPreprocessor::FAngelscriptPreprocessor()
{
    auto Settings = UAngelscriptSettings::StaticClass()
        ->GetDefaultObject<UAngelscriptSettings>();

    bDefaultFunctionBlueprintCallable      = Settings->bDefaultFunctionBlueprintCallable;
    DefaultPropertyEditSpecifier           = Settings->DefaultPropertyEditSpecifier;
    DefaultPropertyEditSpecifierForStructs = Settings->DefaultPropertyEditSpecifierForStructs;
    DefaultPropertyBlueprintSpecifier      = Settings->DefaultPropertyBlueprintSpecifier;

    for (auto& Flag : Settings->PreprocessorFlags)
    {
        PreprocessorFlags.Add(Flag, true);
        PreprocessorFlagsFromIni.Add(Flag);
    }
}
```

这些"项目级别"默认值并不通过 `default` 关键字写在每个类里，但它们直接决定 `default` 语句解析后属性的可编辑性、蓝图可见性等元数据。修改这些 INI 设置等于一次性改变全部 default 语句的"隐式上下文"。

### 7.17 父类 `__InitDefaults` 的排除规则

类生成器在挂载 `DefaultsFunction` 时显式排除继承来的版本：

```cpp
auto* DefaultsFunction = (asCScriptFunction*)ObjType
    ->GetMethodByDecl("void __InitDefaults()");
if (DefaultsFunction != nullptr && DefaultsFunction->objectType == ObjType)
    Class->DefaultsFunction = DefaultsFunction;
//                            ↑ 必须是本类自己声明的，不能是继承来的
```

**为什么**：`ExecuteDefaultsFunctions` 沿继承链单独遍历每一层，如果 `Class->DefaultsFunction` 误指向父类版本，会导致父类的初始化代码**被执行两次**（一次通过 `Class->DefaultsFunction`，一次通过遍历父类时的 `ParentClass->DefaultsFunction`）。强制本层声明保证每层 `__InitDefaults` **恰好执行一次**。

### 7.18 `ProcessReplacements` 必须先于 `ProcessDefaults`

```cpp
void FAngelscriptPreprocessor::ProcessDefaults(FFile& File, FChunk& Chunk)
{
    if (Chunk.Defaults.Num() == 0)
        return;

    ProcessReplacements(File, Chunk);   // ← 必须先做流式替换
    // ...
}
```

`ProcessMacros` 等更早阶段产生的 `Replacements` 会改变 `Chunk.Content` 的字节布局，但 `Chunk.Defaults[i].StartPos` 是**替换前的偏移**。`ProcessReplacements` 在此处把所有挂起的替换批量应用，并**同步修正 `Defaults[i].StartPos / NewStartPos`**，确保后面 `Mid(StartPos + 8, ...)` 切到的是正确的赋值表达式。

如果忘记这一步，default 行内容会"错位"，生成的 `__InitDefaults()` 函数体可能包含语法错误甚至吃掉相邻 UPROPERTY 声明的一部分。

---

## 八、与 Hazelight 引擎实现的差异

本节内容已独立成文，详见：

- **差异分析（知识库）** → `Documents/Knowledges/ZH/Diff_HazelightDefaultStatement.md`
  - 列出所有已发现的偏离点（含一致项、设计差异、能力缺失）
  - 对每条差异给出处理决策（不追平 / 走替代方案 / 建议补足）

- **补足执行计划（Plans）** → `Documents/Plans/Plan_DefaultStatementHazelightParity.md`
  - 把上述"建议补足"项分解为可执行步骤
  - 包含 backport `unsafe_during_construction` / `defaults` AS 内核 trait 与 `AngelscriptPropertyFlags` 替代方案两条主线

简要结论：核心 default 语义路径（预处理器分块 → AS 内核生成 `__InitDefaults` → 继承链倒序执行）与 Hazelight **完全一致**；AS 内核两个安全 trait（`unsafe_during_construction` / `defaults`）已补足，`AngelscriptPropertyFlags` 引擎扩展位已改为插件内 `FProperty` 查询 API 替代。

---

## 九、附录：源码常量对照速查

| 常量 / 字符串 | 用途 | 来源 |
|--------------|------|------|
| `"CPP_Default_<ParamName>"` | UFunction meta key 前缀 | `Helper_FunctionSignature.h` `InitFromFunction` |
| `"-"` | `ArgumentDefaults` 哨兵：无默认值 | 同上 |
| `""`（空串） | 默认值 = 类型零值 | 同上 |
| `"None"` | FName 的 null 约定（在读取阶段被改写为空串） | 同上 |
| `"__WorldContext()"` | `ArgumentDefaults` 中的魔法标记 + `hiddenArgumentDefault` 写入值（**带括号**，Hazelight 不带括号是变量引用） | `Helper_FunctionSignature.h:284` `Helper_FunctionSignature.h:513` |
| `"__STATIC_NAME (n)"` | FName 字面量被预处理器替换的索引格式 | `Bind_FName.cpp` |
| `"__InitDefaults"` | 属性 default 拼装出的 AS 函数名（由 AS 内核 `AddInitDefaultsFunction` 注入，不是预处理器拼接） | `as_builder.cpp:4205` |
| `"void __InitDefaults()"` | `GetMethodByDecl` 查询字符串 | `AngelscriptClassGenerator.cpp:5889` |
| `"FVector :: ZeroVector"` | `FDefaultValueHelper::Is` 比较时的"去空格"格式 | `Bind_FVector.cpp` |
| `"no_discard"` / `"allow_discard"` | AS 声明末尾追加的返回值修饰符 | `Helper_FunctionSignature.h:415` `InitFromFunction` |
| `NAME_Signature_WorldContext` | 标识 WorldContext 参数的 UFunction meta key | `Helper_FunctionSignature.h` |
| `NAME_Signature_ScriptMixin` | 触发 Mixin 第一个参数裁剪的 UClass meta key | 同上 |
| `NAME_OptionalWorldContext` | 允许函数缺省 WorldContext 的 meta | 同上 |
| `NAME_CallableWithoutWorldContext` | （当前项目独有，UE5.7 适配）禁止参与 WorldContext 推断的 meta | 同上 |
| `NAME_AS_Tooltip` | AS 调用示例 tooltip 的 UFunction meta key | `ModifyScriptFunction` |
