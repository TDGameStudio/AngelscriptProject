# Syntax_UPROPERTY — UPROPERTY 修饰符实现原理

> 本文描述当前项目（`Plugins/Angelscript/`）中 `UPROPERTY(...)` 修饰符从源码字符到 UE 反射 `FProperty` 的完整生成链路，以及配套的预编译持久化、热重载等价判断、组件初始化、网络复制注册等子系统。

---

## 概览

`UPROPERTY` 不是 AS 语言关键字，而是**预处理器层面的宏伪装**——AS 内核解析器对它一无所知，整条流水线由当前项目的预处理器与类生成器协作完成：

```text
.as 源码 (UPROPERTY(EditAnywhere, Replicated) int32 Health;)
    |
    +-- 预处理器 (Preprocessor) 路径
    |     [Step 1] 词法扫描 ParseIntoChunks
    |               识别 "UPROPERTY(" 并配对括号 -> FMacro
    |     [Step 2] 语义解析 ProcessPropertyMacro
    |               把每个 specifier 映射为 FAngelscriptPropertyDesc 中的 bool 字段
    |               或 Meta Map 条目
    |
    +-- AS 内核 (ThirdParty/angelscript) 路径
    |     完全无视 UPROPERTY 宏, 只看到普通的 `int32 Health;` 字段声明
    |     |
    |     v
    |     asCObjectType::properties[i] 包含 byteOffset
    |
    v 类生成器 (ClassGenerator) 路径
        [Step 3] AddClassProperties -> FAngelscriptTypeUsage::CreateProperty
                   创建对应的 FIntProperty / FObjectProperty / FStructProperty 等
        [Step 4] 按 PropDesc 的 bool 字段 + Meta Map 设置 CPF_* PropertyFlags
        [Step 5] DetectAngelscriptReferences
                   为没有 UPROPERTY 宏的私有属性补 GC Schema
        [Step 6] FinalizeClass -> FinalizeActorClass
                   把 DefaultComponent / OverrideComponent Meta
                   转换为 UASClass::FDefaultComponent / FOverrideComponent 描述符
        [Step 7] 运行时 SpawnActor -> CreateDefaultComponents 真正实例化组件
```

整个流水线的核心数据载体是 `FAngelscriptPropertyDesc`——所有 specifier 都先被翻译成它的字段，再由类生成器一次性消费。

### 完整生命周期 ASCII 全景

下图以 `UPROPERTY(EditAnywhere, BlueprintReadWrite, Replicated, Category="Combat") int32 Health;` 为例，展示从 `.as` 源码字符到运行时使用的完整生命周期。

```text
============================================================================
  脚本属性 UPROPERTY 修饰符的完整生命周期
============================================================================

  [.as 源文件]
      UPROPERTY(EditAnywhere, BlueprintReadWrite, Replicated, Category="Combat")
      int32 Health;
        |
        |  [Step 1] ParseIntoChunks (词法扫描)
        |      - case 'U' + IsStartOfIdentifier + Strncmp("UPROPERTY(", 10)
        |      - '(' / ')' 配对计数 -> MacroExitScope
        |      - ';' 触发 FinishMacro 反向扫描属性名/类型
        v
  [词法产物] FMacro
      Type        = EMacroType::Property
      Name        = "Health"
      SubjectType = "int32"
      Arguments   = "EditAnywhere, BlueprintReadWrite, Replicated, Category=\"Combat\""
        |
        |  [Step 2] ProcessPropertyMacro (语义解析)
        |      - ParseSpecifiers(Macro.Arguments) -> FSpecifier[]
        |      - for each specifier: 设置 PropDesc 的 bool 字段或 Meta Map
        v
  [描述符] FAngelscriptPropertyDesc
      PropertyName         = "Health"
      LiteralType          = "int32"
      bEditableOnDefaults  = true              <- EditAnywhere
      bEditableOnInstance  = true              <- EditAnywhere
      bBlueprintReadable   = true              <- BlueprintReadWrite
      bBlueprintWritable   = true              <- BlueprintReadWrite
      bReplicated          = true              <- Replicated
      Meta["Category"]     = "Combat"          <- Category=
        |
        |  [Step 3] asCModule 编译 (AS 内核, 与预处理并行发生)
        |      - BuildParallelParseScripts -> BuildGenerateTypes -> BuildLayoutClasses
        v
  asCObjectType::properties[i]
      asCObjectProperty::byteOffset = 4        (内存偏移由 AS 布局器计算)
        |
        |  [Step 4] AddClassProperties (类生成器, 描述符 -> FProperty)
        v
  PropDesc->PropertyType.CreateProperty(Params)
      -> new FIntProperty(InStruct, "Health", RF_Public)
      -> [WITH_EDITOR] SetMetaData("Category", "Combat")
      -> // CPF_RuntimeGenerated 该行被注释 (详见 §九.9.1)
      -> SetPropertyFlags(CPF_Net)              <- bReplicated=true
      -> SetPropertyFlags(CPF_BlueprintVisible) <- bBlueprintReadable=true
            (不设 CPF_BlueprintReadOnly         <- bBlueprintWritable=true)
      -> SetPropertyFlags(CPF_Edit)             <- bEditableOn*=true
            (不设 DisableEditOnInstance/Template <- 两者均为 true)
      -> InStruct->ChildProperties = NewProperty   (前插链表)
      -> InStruct->SetPropertiesSize(4)
      -> NewProperty->Link(ArDummy)
            check(GetOffset_ForUFunction() == 4)   (*) 内存对齐契约
        |
        |  [Step 5] DetectAngelscriptReferences (GC Schema 兜底)
        |      Health 是 int32 (基础类型)
        |      -> TypeId <= asTYPEID_LAST_PRIMITIVE -> 跳过
        v
        |  [Step 6] FinalizeClass / FinalizeActorClass
        |      非 DefaultComponent / OverrideComponent
        |      -> 不进入 ASClass->DefaultComponents[]
        v
  [最终态] UASClass / UScriptStruct 内
      FIntProperty "Health"
        PropertyFlags                = CPF_Net | CPF_BlueprintVisible | CPF_Edit
        Offset_Internal              = 4
        Meta                         = { "Category": "Combat" }
        RepNotifyFunc                = NAME_None
        BlueprintReplicationCondition = COND_None
        |
        |  [Step 7] 运行时使用
        v
  - 编辑器 Details 面板  : 读 CPF_Edit            -> 显示输入框
                          读 Meta["Category"]    -> 归类到 "Combat"
  - 蓝图节点系统         : 读 CPF_BlueprintVisible -> 暴露为 Get/Set 节点
  - 网络复制层           : 读 CPF_Net              -> GetLifetimeScriptReplicationList
                                                  -> FLifetimeProperty(RepIndex, COND_None)
  - 序列化系统           : 未设 CPF_Transient      -> 参与存档 / 关卡序列化
```

---

## 一、词法扫描：`ParseIntoChunks` 识别 `UPROPERTY(`

**源码所在**：`Plugins/Angelscript/Source/AngelscriptRuntime/Preprocessor/AngelscriptPreprocessor.cpp` 中的 `ParseIntoChunks`。

### 1.1 字符级扫描状态机

预处理器逐字符扫描原始 `.as` 文件，遇到 `'U'` 字符时进入候选分支：

```cpp
case 'U':
    // 严格的前置条件：
    //   1. 剩余字符 >= 10（够装 "UPROPERTY("）
    //   2. 当前处于 class/struct 作用域（ScopeCount == ClassExitScope + 1）
    //   3. 不在注释/字符串里
    //   4. 不在另一个宏的解析中（!bIsParsingMacro）
    //   5. IsStartOfIdentifier()：前一个字符不是字母/数字/下划线
    //      （防止误匹配 UPROPERTY2 等用户自定义标识符）
    if (RawSize - ChunkEnd >= 10
        && (ScopeCount == ClassExitScope + 1)
        && !bInComment && !bInString && !bIsParsingMacro
        && IsStartOfIdentifier())
    {
        if (FCString::Strncmp(&File.RawCode[ChunkEnd], TEXT("UPROPERTY("), 10) == 0
            && (ChunkType == EChunkType::Class || ChunkType == EChunkType::Struct))
        {
            bIsParsingMacro = true;
            ParsingMacro.Type = EMacroType::Property;
            ParsingMacro.MacroStartPos = ChunkEnd;
            // 顺手收集紧邻的注释（// xxx）作为 ToolTip
            if (PrevCommentStart != -1) { /* ... */ }
            MacroExitScope = -1;
        }
    }
```

### 1.2 括号配对状态机

`'('` / `')'` 维护 `BracketCount`，精确处理嵌套括号（如 `meta=(ClampMin=0)` 中的内层括号）：

```cpp
case '(':
    if (bIsParsingMacro && MacroExitScope == -1)
        MacroExitScope = BracketCount;   // 记录 UPROPERTY( 的括号层级
    BracketCount += 1;
    break;

case ')':
    BracketCount -= 1;
    if (bIsParsingMacro && MacroExitScope == BracketCount
        && ParsingMacro.MacroEndPos == -1)
        ParsingMacro.MacroEndPos = ChunkEnd + 1;   // 闭合到起始层级
    break;

case ';':   // 或 '='：触发 FinishMacro 反向扫描属性名/类型
    if (bIsParsingMacro && MacroExitScope == BracketCount)
        FinishMacro();
    break;
```

### 1.3 `FinishMacro`：反向扫描提取属性名与类型

```cpp
auto FinishMacro = [&]()
{
    // 提取 UPROPERTY(...) 括号内全部参数原文
    ParsingMacro.Arguments = File.RawCode.Mid(
        ParsingMacro.MacroStartPos + 10,                       // 跳过 "UPROPERTY("
        ParsingMacro.MacroEndPos - ParsingMacro.MacroStartPos - 11);

    // 从 ';' 位置反向跳过空白 → 得到属性名末位
    int32 EndOfWord = ChunkEnd - 1;
    while (EndOfWord > 0 && IsWhitespace(File.RawCode[EndOfWord])) EndOfWord -= 1;
    int32 StartOfWord = EndOfWord;
    while (StartOfWord > 0 && !IsWhitespace(...))                  StartOfWord -= 1;
    ParsingMacro.Name = File.RawCode.Mid(StartOfWord+1, ...);  // "Health"

    // 继续反向扫描到换行或 ')' → 得到类型字符串
    if (ParsingMacro.Type == EMacroType::Property)
    {
        // ParsingMacro.SubjectType = "int32" / "UStaticMeshComponent" 等
    }

    PendingMacros.Add(ParsingMacro);
    bIsParsingMacro = false;
};
```

### 1.4 `FMacro`：词法扫描的产物

```cpp
struct FMacro
{
    EMacroType Type;          // Property / Function / Class / Enum / EnumValue / EnumMeta
    int32 MacroStartPos = -1; // 'U' 位置（Chunk 内偏移）
    int32 MacroEndPos   = -1; // ')' 后一位
    int32 NameStartPos  = -1; // 属性名首字符
    int32 NameEndPos    = -1;
    FString Name;             // "Health"
    FString SubjectType;      // "int32"
    FString Arguments;        // "EditAnywhere, BlueprintReadWrite, Replicated"
    FString Comment;          // 紧邻在 UPROPERTY 前面的 // 注释
    int32 FileLineNumber = 0;
    bool bEditorOnly = false; // 处于 #if EDITOR 块内 → 后续转 Meta["EditorOnly"] → CPF_EditorOnly
    int32 SubjectIndex = 0;   // 仅 EnumValue/EnumMeta 使用
};
```

`SubmitChunk`（遇到 `}` 时触发）把 `PendingMacros` 转移到对应 `FChunk.Macros`，并把全局偏移修正为 Chunk 相对偏移。

---

## 二、核心数据结构：`FAngelscriptPropertyDesc`

**源码所在**：`Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.h:798`（`FAngelscriptManager` 已合并到 `FAngelscriptEngine`，与 default 文档约定一致）。

```cpp
struct FAngelscriptPropertyDesc
{
    FString PropertyName;                 // 属性名
    FString LiteralType;                  // 脚本中声明的原始类型字符串
    FAngelscriptTypeUsage PropertyType;   // 经类型系统解析后的最终类型

    TMap<FName, FString> Meta;            // UPROPERTY(meta=(K=V)) 与"纯 Meta 修饰符"的最终归宿

    // === 蓝图访问 ===
    bool bBlueprintReadable  = false;     // BlueprintReadOnly / BlueprintReadWrite
    bool bBlueprintWritable  = false;     // BlueprintReadWrite

    // === 编辑器可见性 ===
    bool bEditableOnDefaults = false;     // EditDefaultsOnly / EditAnywhere
    bool bEditableOnInstance = false;     // EditInstanceOnly / EditAnywhere
    bool bEditConst          = false;     // VisibleXxx → "可见但只读"

    // === 组件引用 ===
    bool bInstancedReference = false;     // DefaultComponent / OverrideComponent / Instanced
    bool bPersistentInstance = false;     // Instanced（驱动 STRUCT_HasInstancedReference 气泡）

    bool bAdvancedDisplay   = false;      // AdvancedDisplay
    bool bTransient         = false;      // Transient（也由 BindWidget 隐含设置）
    bool bSkipSerialization = false;      // SkipSerialization
    bool bSaveGame          = false;      // SaveGame
    bool bConfig            = false;      // Config

    // === 网络复制 ===
    bool bReplicated     = false;         // Replicated / ReplicatedUsing
    bool bSkipReplication = false;        // NotReplicated（仅 struct 字段）
    TEnumAsByte<ELifetimeCondition> ReplicationCondition = COND_None;
    bool bRepNotify      = false;         // ReplicatedUsing=FuncName

    bool bInterp                  = false;// Interp（Sequencer 可驱动）
    bool bAssetRegistrySearchable = false;// AssetRegistrySearchable
    bool bNoClear                 = false;// NoClear

    // === AS 访问权限（来自 private:/protected: 块）===
    bool bIsPrivate   = false;
    bool bIsProtected = false;

    // === AS 引擎内部数据 ===
    int32  ScriptPropertyIndex  = -1;     // asCObjectType::properties 数组索引
    SIZE_T ScriptPropertyOffset = 0;      // 在脚本对象内存中的字节偏移

    int32 LineNumber = 1;                 // 用于错误诊断
    bool  bHasUnrealProperty = false;     // AddClassProperties 成功后置 true（GC Schema 兜底用）

    // 热重载等价性比较（不比较 PropertyName/LiteralType/Meta）
    bool IsDefinitionEquivalent(const FAngelscriptPropertyDesc& Other) const;
};
```

**关键设计点**：
- 修饰符到字段的映射是**一对一/一对多**——一个 specifier 可能同时改多个 bool 字段（如 `EditAnywhere` 同时设置两个 editable）
- 纯元数据修饰符（`Category` / `ClampMin` / `ToolTip`）走 `Meta` Map 而不占独立 bool 位
- `IsDefinitionEquivalent` 是热重载决策依据（详见 §六）

---

## 三、语义解析：`ProcessPropertyMacro`

**源码所在**：`AngelscriptPreprocessor.cpp` 中 `ProcessPropertyMacro`（约 2400 行起）。

### 3.1 入口与项目级默认值

```cpp
void FAngelscriptPreprocessor::ProcessPropertyMacro(FFile& File, FChunk& Chunk, FMacro& Macro)
{
    auto PropDesc = MakeShared<FAngelscriptPropertyDesc>();
    PropDesc->LineNumber   = Macro.FileLineNumber;
    PropDesc->PropertyName = Macro.Name;
    PropDesc->LiteralType  = Macro.SubjectType;

    auto ClassDesc = Chunk.ClassDesc;
    ClassDesc->Properties.Add(PropDesc);

    // 从预处理器构造时缓存的 UAngelscriptSettings 应用全局默认
    // —— 此处即 default 文档 §7.16 提到的"项目级隐式上下文"
    switch (EditSpecifier)
    {
        case EAngelscriptPropertyEditSpecifier::EditAnywhere:
            PropDesc->bEditableOnDefaults = true;
            PropDesc->bEditableOnInstance = true; break;
        // ...
    }
    switch (DefaultPropertyBlueprintSpecifier)
    {
        case EAngelscriptPropertyBlueprintSpecifier::BlueprintReadWrite:
            PropDesc->bBlueprintReadable = true;
            PropDesc->bBlueprintWritable = true; break;
        // ...
    }
```

### 3.2 修饰符大分发（按主题）

修饰符识别用 `static FName PP_NAME_*` 常量（声明于同文件 `1336`、`2272-2276`、`2305-2306` 行附近）。

#### 蓝图访问

```cpp
else if (Spec.Name == PP_NAME_BlueprintReadWrite) { PropDesc->bBlueprintWritable = PropDesc->bBlueprintReadable = true; }
else if (Spec.Name == PP_NAME_BlueprintReadOnly)  { PropDesc->bBlueprintWritable = false; PropDesc->bBlueprintReadable = true; }
else if (Spec.Name == PP_NAME_BlueprintHidden)    { PropDesc->bBlueprintWritable = PropDesc->bBlueprintReadable = false; }

else if (Spec.Name == PP_NAME_BlueprintSetter)
{
    if (!Spec.Value.IsEmpty()) PropDesc->Meta.Add(PP_NAME_BlueprintSetter, Spec.Value);
    else MacroError(...);   // 函数名为空 → 编译错误
}
else if (Spec.Name == PP_NAME_BlueprintGetter) { /* 同上 */ }
```

#### 编辑器可见性（Edit / Visible / Not 三大组）

```cpp
// Edit 组：可读写
else if (Spec.Name == PP_NAME_EditAnywhere)     { PropDesc->bEditableOnDefaults = PropDesc->bEditableOnInstance = true; }
else if (Spec.Name == PP_NAME_EditDefaultsOnly) { PropDesc->bEditableOnDefaults = true;  PropDesc->bEditableOnInstance = false; }
else if (Spec.Name == PP_NAME_EditInstanceOnly) { PropDesc->bEditableOnDefaults = false; PropDesc->bEditableOnInstance = true;  }
else if (Spec.Name == PP_NAME_EditConst)        { PropDesc->bEditConst = true; }

// Visible 组：bEditConst=true 强制只读，但仍占面板
else if (Spec.Name == PP_NAME_VisibleAnywhere)     { PropDesc->bEditConst = true; PropDesc->bEditableOnDefaults = PropDesc->bEditableOnInstance = true; }
else if (Spec.Name == PP_NAME_VisibleDefaultsOnly) { PropDesc->bEditConst = true; PropDesc->bEditableOnDefaults = true;  PropDesc->bEditableOnInstance = false; }
else if (Spec.Name == PP_NAME_VisibleInstanceOnly) { PropDesc->bEditConst = true; PropDesc->bEditableOnDefaults = false; PropDesc->bEditableOnInstance = true; }

// Not 组：彻底从面板移除（与 Visible 组的语义差异在于不设 bEditConst）
else if (Spec.Name == PP_NAME_NotEditable
      || Spec.Name == PP_NAME_NotVisible) { PropDesc->bEditableOnDefaults = PropDesc->bEditableOnInstance = false; }
```

#### 网络复制

```cpp
else if (Spec.Name == PP_NAME_Replicated) { PropDesc->bReplicated = true; }
else if (Spec.Name == PP_NAME_ReplicatedUsing)
{
    PropDesc->bReplicated = PropDesc->bRepNotify = true;
    PropDesc->Meta.Add(PP_NAME_ReplicatedUsing, Spec.Value);  // 函数名存入 Meta
}
else if (Spec.Name == PP_NAME_ReplicationCondition)
{
    if (Spec.Value == TEXT("OwnerOnly"))      PropDesc->ReplicationCondition = COND_OwnerOnly;
    else if (Spec.Value == TEXT("InitialOnly")) PropDesc->ReplicationCondition = COND_InitialOnly;
    // ...其他 14 种条件
}
else if (Spec.Name == PP_NAME_NotReplicated)  { PropDesc->bSkipReplication = true; }   // 仅 Struct 可用
```

> 注：参考文档中提及的 Hazelight 独有的 `PP_NAME_ReplicationPushModel` + `PushModelReplicatedProperties` Push Model 优化在**当前项目缺失**——已识别的 Hazelight 差异之一，详见 §九。

#### 序列化

```cpp
else if (Spec.Name == PP_NAME_Transient)         { PropDesc->bTransient = true; }
else if (Spec.Name == PP_NAME_SaveGame)          { PropDesc->bSaveGame  = true; }
else if (Spec.Name == PP_NAME_SkipSerialization) { PropDesc->bSkipSerialization = true; }
else if (Spec.Name == PP_NAME_Config)            { PropDesc->bConfig    = true; }
```

#### 组件相关（DefaultComponent / OverrideComponent / ShowOnActor）

```cpp
// DefaultComponent：声明拥有的子组件，CDO 可编辑（调整组件属性），实例不可改类型
else if (Spec.Name == PP_NAME_DefaultComponent)
{
    if (!bHadShowOnActor)  // ShowOnActor 已先到达时，保留它对 instance 的开放
    {
        PropDesc->bEditableOnDefaults = true;
        PropDesc->bEditableOnInstance = false;
    }
    PropDesc->bBlueprintWritable  = false;
    PropDesc->bBlueprintReadable  = true;
    PropDesc->bInstancedReference = true;
    PropDesc->Meta.Add(PP_NAME_EditInlineDefaults, TEXT("true"));
    PropDesc->Meta.Add(PP_NAME_DefaultComponent,   TEXT("True"));  // ← FinalizeActorClass 扫描此 Key
    bIsDefaultComponent = true;
}

// OverrideComponent=ParentName：完全只读引用父类已有组件（运行时类型可被替换）
else if (Spec.Name == PP_NAME_OverrideComponent)
{
    PropDesc->bBlueprintReadable  = false;
    PropDesc->bBlueprintWritable  = false;
    PropDesc->bEditableOnDefaults = false;
    PropDesc->bEditableOnInstance = false;
    PropDesc->bInstancedReference = true;
    PropDesc->Meta.Add(PP_NAME_OverrideComponent, Spec.Value);     // 父类组件名作 Value
    bIsOverrideComponent = true;
}

// ShowOnActor：叠加在 DefaultComponent 上，让组件属性也允许在 Actor 实例上编辑
else if (Spec.Name == PP_NAME_ShowOnActor)
{
    bHadShowOnActor = true;
    PropDesc->bEditConst          = false;
    PropDesc->bEditableOnDefaults = true;
    PropDesc->bEditableOnInstance = true;
    PropDesc->Meta.Add(PP_NAME_EditInline, TEXT("true"));
}

// RootComponent：与 DefaultComponent 联用，标记此组件为 Actor 根
else if (Spec.Name == PP_NAME_RootComponent)
{
    PropDesc->Meta.Add(PP_NAME_RootComponent, TEXT("True"));       // ← FinalizeActorClass 读取
}

// Instanced（值类型字段标记，触发 STRUCT_HasInstancedReference 气泡）
else if (Spec.Name == PP_NAME_Instanced) { PropDesc->bPersistentInstance = true; }
```

#### Attach / AttachSocket（SceneComponent 层级控制）

```cpp
else if (Spec.Name == PP_NAME_Attach)        { PropDesc->Meta.Add(PP_NAME_Attach,        Spec.Value); }  // "MyMesh"
else if (Spec.Name == PP_NAME_AttachSocket)  { PropDesc->Meta.Add(PP_NAME_AttachSocket,  Spec.Value); }  // "HandSocket"
```

这两条 Meta 由 `CreateDefaultComponents` 在运行时消费（详见 §七）。

#### UI 绑定

```cpp
else if (Spec.Name == PP_NAME_BindWidget)
{
    PropDesc->Meta.Add(PP_NAME_BindWidget, TEXT(""));
    PropDesc->bTransient          = true;     // BindWidget 自动是 Transient
    PropDesc->bBlueprintReadable  = true;
}
```

> 注：当前项目仅识别 `BindWidget`。Hazelight 还支持 `BindWidgetAnim`（动画资产绑定）、`BindWidgetOptional`（可选绑定）、`BindComponent`（蓝图组件绑定）这 3 个修饰符——已识别 Hazelight 差异，详见 §九。

#### Meta 透传 + 错误兜底

```cpp
else if (Spec.Name == PP_NAME_Meta)
{
    for (auto& Elem : Spec.List)              // ParseSpecifiers 已切好键值对
        PropDesc->Meta.Add(Elem.Name, Elem.Value);
    // 常见 key：ClampMin / ClampMax / UIMin / UIMax / EditCondition
    //          AllowPrivateAccess / MakeEditWidget / Units / ...
}

// 纯元数据修饰符（无对应 bool 字段，直接挂 Meta）
else if (Spec.Name == PP_NAME_Category
      || Spec.Name == PP_NAME_DisplayName
      || Spec.Name == PP_NAME_ToolTip
      || Spec.Name == PP_NAME_Keywords
      || Spec.Name == PP_NAME_EditInline
      || Spec.Name == PP_NAME_ExposeOnSpawn
      || Spec.Name == PP_NAME_EditFixedSize
      || Spec.Name == PP_NAME_BlueprintProtected) { PropDesc->Meta.Add(Spec.Name, Spec.Value); }

// 默认分支：未知 specifier 一律编译期报错
else
{
    MacroError(File, Macro,
        FString::Printf(TEXT("Unknown property specifier %s on property %s::%s."),
            *Spec.Name.ToString(), *ClassDesc->ClassName, *PropDesc->PropertyName));
    bHasError = true;
}
```

---

## 四、类生成：`AddClassProperties`（描述符 → FProperty）

**源码所在**：`Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator/AngelscriptClassGenerator.cpp:2851`。

### 4.1 主流程

```cpp
int32 FAngelscriptClassGenerator::AddClassProperties(TSharedPtr<FAngelscriptClassDesc> ClassDesc)
{
    auto* ScriptType = (asCObjectType*)ClassDesc->ScriptType;
    UStruct* InStruct = ClassDesc->Class ? (UStruct*)ClassDesc->Class : (UStruct*)ClassDesc->Struct;

    // 倒序遍历：保证 ChildProperties 链表（前插）后的顺序与 AS 一致
    for (int32 i = ScriptType->properties.GetLength() - 1; i >= 0; --i)
    {
        asCObjectProperty* ScriptProp = ScriptType->properties[i];
        int PropertyOffset = ScriptProp->byteOffset;

        if (ScriptType->IsPropertyInherited(i)) continue;

        TSharedPtr<FAngelscriptPropertyDesc> PropDesc = ClassDesc->GetProperty(ScriptProp->name);
        if (!PropDesc.IsValid()) continue;

        // 类型分派工厂：FAngelscriptTypeUsage 持有 FAngelscriptType*，
        // 它的 CreateProperty 是虚函数，每种类型实现自己的 FProperty 构造逻辑
        FProperty* NewProperty = PropDesc->PropertyType.CreateProperty(Params);
        PropDesc->bHasUnrealProperty = true;

        // —— 见下方 4.2 设置 CPF Flags ——
    }

    return PropertiesSize;
}
```

### 4.2 CPF Flag 映射（核心区块）

> **重要差异**：参考文档示例代码以 `NewProperty->SetPropertyFlags(CPF_RuntimeGenerated);` 起头，但**当前项目此行被注释掉**（`AngelscriptClassGenerator.cpp:2948`）：
>
> ```cpp
> //NewProperty->SetPropertyFlags(CPF_RuntimeGenerated);
> ```
>
> 原因详见 `Diff_HazelightDefaultStatement.md` §二.差异②：`AngelscriptPropertyFlags` / `CPF_RuntimeGenerated` 这套 UE 引擎扩展位需要修改 `Engine/Source/Runtime/CoreUObject/`，**独立插件无法平移**。当前项目走"主动留白"策略，等待替代方案（详见 `Plan_DefaultStatementHazelightParity.md` Phase 2）。

CPF 设置的真实顺序（精简自源码 `AngelscriptClassGenerator.cpp:2940-3045`）：

```cpp
#if WITH_EDITOR
// ① 写入所有 Meta 键值对（Category / Tooltip / ClampMin 等）
for (auto& Elem : PropDesc->Meta)
    NewProperty->SetMetaData(Elem.Key, *Elem.Value);
if (PropDesc->bIsProtected)
    NewProperty->SetMetaData(FUNCMETA_BlueprintProtected, TEXT("true"));
#endif

// ② 网络复制（互斥分支：bReplicated / bSkipReplication）
if (PropDesc->bReplicated)
{
    NewProperty->SetPropertyFlags(CPF_Net);
    NewProperty->SetBlueprintReplicationCondition(PropDesc->ReplicationCondition);

    if (PropDesc->bRepNotify)
    {
        FString* RepNotifyFunc = PropDesc->Meta.Find(TEXT("ReplicatedUsing"));
        if (RepNotifyFunc != nullptr)
        {
            NewProperty->SetPropertyFlags(CPF_RepNotify);
            NewProperty->RepNotifyFunc = FName(**RepNotifyFunc);
        }
    }
}
else if (PropDesc->bSkipReplication)
{
    NewProperty->SetPropertyFlags(CPF_RepSkip);     // 仅 struct 字段允许
}

// ③ 序列化控制
if (PropDesc->bSkipSerialization) NewProperty->SetPropertyFlags(CPF_SkipSerialization);
if (PropDesc->bSaveGame)          NewProperty->SetPropertyFlags(CPF_SaveGame);

// ④ 蓝图可见性（含 private 例外）
if ((PropDesc->bBlueprintReadable || PropDesc->bBlueprintWritable)
 && (!PropDesc->bIsPrivate || PropDesc->Meta.Find(NAME_AllowPrivateAccess)))
{
    NewProperty->SetPropertyFlags(CPF_BlueprintVisible);
    if (!PropDesc->bBlueprintWritable)
        NewProperty->SetPropertyFlags(CPF_BlueprintReadOnly);
}

// ⑤ 编辑器可见性（注意：CPF_BlueprintAssignable 委托属性走另一支）
if (!NewProperty->HasAnyPropertyFlags(CPF_BlueprintAssignable))
{
    if (PropDesc->bEditableOnInstance || PropDesc->bEditableOnDefaults)
    {
        NewProperty->SetPropertyFlags(CPF_Edit);
        if (!PropDesc->bEditableOnInstance) NewProperty->SetPropertyFlags(CPF_DisableEditOnInstance);
        if (!PropDesc->bEditableOnDefaults) NewProperty->SetPropertyFlags(CPF_DisableEditOnTemplate);
        if (PropDesc->bEditConst)            NewProperty->SetPropertyFlags(CPF_EditConst);
    }
}
else if (PropDesc->Meta.Find(TEXT("BPCannotCallEvent")) || PropDesc->bIsPrivate || PropDesc->bIsProtected)
{
    NewProperty->ClearPropertyFlags(CPF_BlueprintCallable);   // 委托 + private/protected → 禁止蓝图调用
}

// ⑥ 组件相关
if (PropDesc->bInstancedReference)
    NewProperty->SetPropertyFlags(CPF_InstancedReference | CPF_ExportObject | CPF_EditConst);
if (PropDesc->bPersistentInstance)
    MarkUStructContainsReference();             // STRUCT_HasInstancedReference 气泡上传

// ⑦ 杂项
if (PropDesc->bAdvancedDisplay)         NewProperty->SetPropertyFlags(CPF_AdvancedDisplay);
if (PropDesc->bTransient)               NewProperty->SetPropertyFlags(CPF_Transient);
if (PropDesc->bConfig)                  NewProperty->SetPropertyFlags(CPF_Config);
if (PropDesc->bInterp)                  NewProperty->SetPropertyFlags(CPF_Interp);
if (PropDesc->bAssetRegistrySearchable) NewProperty->SetPropertyFlags(CPF_AssetRegistrySearchable);
if (PropDesc->bNoClear)                 NewProperty->SetPropertyFlags(CPF_NoClear);

// ⑧ Meta 驱动的 Flag（不占独立 bool 字段）
if (PropDesc->Meta.Contains(NAME_ExposeOnSpawn))   NewProperty->SetPropertyFlags(CPF_ExposeOnSpawn);
if (PropDesc->Meta.Contains(NAME_EditFixedSize))   NewProperty->SetPropertyFlags(CPF_EditFixedSize);
if (PropDesc->Meta.Contains(NAME_Meta_EditorOnly)) NewProperty->SetPropertyFlags(CPF_EditorOnly);
```

### 4.3 容器属性的气泡传播

容器内含 `Instanced` 引用时必须把 `CPF_ContainsInstancedReference` 一路上传到所属 `UStruct`，否则 GC 与 PIE 拷贝路径会漏过这些引用：

```cpp
if (FArrayProperty* ArrayProp = CastField<FArrayProperty>(NewProperty))
{
    BubbleUpInstanceReferenceFlags(ArrayProp, ArrayProp->Inner);
    ArrayProp->Inner->ClearPropertyFlags(CPF_PropagateToArrayInner);
    if (PropDesc->bPersistentInstance) ApplyInstancedPropertyFlags(ArrayProp, ArrayProp->Inner);
    ArrayProp->Inner->SetPropertyFlags(ArrayProp->GetPropertyFlags() & CPF_PropagateToArrayInner);
}
else if (FMapProperty* MapProp = CastField<FMapProperty>(NewProperty))
{
    BubbleUpInstanceReferenceFlags(MapProp, MapProp->ValueProp);
    BubbleUpInstanceReferenceFlags(MapProp, MapProp->KeyProp);
    // CPF_PropagateToMapValue / CPF_PropagateToMapKey 同步
}
else if (FSetProperty* SetProp = CastField<FSetProperty>(NewProperty))
{
    BubbleUpInstanceReferenceFlags(SetProp, SetProp->ElementProp);
    // CPF_PropagateToSetElement 同步
}
else if (FStructProperty* StructProperty = CastField<FStructProperty>(NewProperty))
{
    if (PropDesc->bPersistentInstance) ApplyInstancedPropertyFlags(StructProperty, nullptr);
}
else
{
    BubbleUpInstanceReferenceFlags(nullptr, NewProperty);
}
```

### 4.4 内存对齐断言

```cpp
NewProperty->Next = InStruct->ChildProperties;
InStruct->ChildProperties = NewProperty;          // 前插链表
InStruct->SetPropertiesSize(PropertyOffset);
NewProperty->Link(ArDummy);

// ⚠️ 核心保护：FProperty 的 Offset 必须与 AS 脚本属性的 byteOffset 完全一致
check(NewProperty->GetOffset_ForUFunction() == PropertyOffset);
```

这是 AS 脚本对象内存布局与 UE 反射系统**对齐契约**——失败即断言崩溃。能保证它成立的前提是：AS 内核的内存布局算法使用与 UE 平台相同的对齐规则（自然对齐、按指针大小对齐等）。

---

## 五、GC Schema 兜底：`DetectAngelscriptReferences`

**源码所在**：`AngelscriptClassGenerator.cpp` 中 `DetectAngelscriptReferences`，在 `AddClassProperties` 之后调用。

### 5.1 为什么需要

`AddClassProperties` 只为有 `UPROPERTY(...)` 宏的字段创建 `FProperty`，UE 的 GC 也只通过 `FProperty` 链表追踪引用。但 AS 允许声明**没有 UPROPERTY 宏的纯脚本属性**——这些字段会被 AS 字节码分配并使用，里面如果存放了 `UObject*` 指针，UE GC 完全看不到。

`DetectAngelscriptReferences` 的职责就是：为这些"GC 盲区"属性手动注入 `UE::GC::FSchemaView` 条目。

### 5.2 主流程

```cpp
void FAngelscriptClassGenerator::DetectAngelscriptReferences(TSharedPtr<FAngelscriptClassDesc> ClassDesc)
{
    UASClass* Class = (UASClass*)ClassDesc->Class;
    asITypeInfo* ScriptType = (asITypeInfo*)Class->ScriptTypePtr;
    if (ScriptType == nullptr) return;

    UE::GC::FSchemaBuilder Schema(0);
    UE::GC::FPropertyStack PropertyStack;
    FAngelscriptType::FGCReferenceParams RefParams;
    RefParams.Class     = Class;
    RefParams.DebugPath = &PropertyStack;
    RefParams.Schema    = &Schema;

    Schema.Append(Class->ReferenceSchema.Get());           // 不覆盖 AddClassProperties 已写入的部分
    const int32 NumPreviousMembers = Schema.NumMembers();

    for (int32 i = 0, Count = ScriptType->GetPropertyCount(); i < Count; ++i)
    {
        const char* Name; int PropertyOffset; int TypeId;
        ScriptType->GetProperty(i, &Name, &TypeId, nullptr, nullptr, &PropertyOffset);

        if (TypeId <= asTYPEID_LAST_PRIMITIVE) continue;     // int/float/bool 无引用，跳过
        if (ScriptType->IsPropertyInherited(i)) continue;     // 父类自己处理

        auto PropDesc = ClassDesc->GetProperty(ANSI_TO_TCHAR(Name));
        bool bAddedAsUnrealProperty = PropDesc.IsValid() && PropDesc->bHasUnrealProperty;

        if (!bAddedAsUnrealProperty)                          // 关键过滤
        {
            FAngelscriptTypeUsage PropertyType = PropDesc.IsValid()
                ? PropDesc->PropertyType
                : FAngelscriptTypeUsage::FromProperty(ScriptType, i);

            if (PropertyType.HasReferences())                  // 类型层次的多态判断
            {
                RefParams.AtOffset = PropertyOffset;
                RefParams.Names.Push(Name);
                PropertyType.EmitReferenceInfo(RefParams);     // 生成 GC Schema 条目
                RefParams.Names.Pop();
            }
        }
    }

    if (Schema.NumMembers() != NumPreviousMembers || NumPreviousMembers == 0)
    {
        UE::GC::FSchemaView View(Schema.Build(GetARO(Class)), UE::GC::EOrigin::Other);
        Class->ReferenceSchema.Set(View);
    }
}
```

### 5.3 `EmitReferenceInfo` 的多态分派

| 类型 | 实现位置 | 输出 |
|------|---------|------|
| `UObject*` / `UObjectPtr` | `Bind_BlueprintType.cpp` | `EMemberType::Reference` |
| `UStruct` | `Bind_UStruct.cpp` | `EMemberType::MemberARO`（自定义 ARO）+ 递归 PropertyLink |
| `TArray<T>` | `Bind_TArray.cpp` | `EMemberType::SparseStructArray` + 内部 Element Schema |
| `TMap<K,V>` | `Bind_TMap.cpp` | MapLayout + Key/Value Schema |
| `TSet<T>` | `Bind_TSet.cpp` | SetLayout + Element Schema |

---

## 六、热重载等价判断：`IsDefinitionEquivalent`

**源码所在**：`AngelscriptEngine.h` 中 `FAngelscriptPropertyDesc::IsDefinitionEquivalent`。

```cpp
bool IsDefinitionEquivalent(const FAngelscriptPropertyDesc& Other) const
{
    return Other.bBlueprintReadable    == bBlueprintReadable
        && Other.bBlueprintWritable    == bBlueprintWritable
        && Other.bEditableOnDefaults   == bEditableOnDefaults
        && Other.bEditableOnInstance   == bEditableOnInstance
        && Other.bAdvancedDisplay      == bAdvancedDisplay
        && Other.bEditConst            == bEditConst
        && Other.bInstancedReference   == bInstancedReference
        && Other.bPersistentInstance   == bPersistentInstance
        && Other.bTransient            == bTransient
        && Other.bConfig               == bConfig
        && Other.bInterp               == bInterp
        && Other.bAssetRegistrySearchable == bAssetRegistrySearchable
        && Other.bNoClear              == bNoClear
        && Other.bReplicated           == bReplicated
        && Other.ReplicationCondition  == ReplicationCondition
        && Other.bSkipReplication      == bSkipReplication
        && Other.bSkipSerialization    == bSkipSerialization
        && Other.bSaveGame             == bSaveGame
        && Other.bRepNotify            == bRepNotify
        && Other.bIsPrivate            == bIsPrivate
        && Other.bIsProtected          == bIsProtected
        ;
}
```

### 关键策略

- **比较的是结构性 bool 字段**——所有影响 CPF Flag 的修饰符变化都会触发 `FullReload`
- **不比较** `PropertyName` / `LiteralType` / `Meta`：
  - 名字或类型变化必然导致 `IsDefinitionEquivalent` 在更高层（属性集合的 diff）就被判定为"完全不同"，不会走到这里
  - `Meta` 中绝大多数变化（如 `Category` / `ToolTip`）只影响编辑器展示，不需要重建 UClass
- 与 default 文档 §3.2 的 `IsDefinitionEquivalent`（不比较 `DefaultValue`）形成对比：default 走"建议 FullReload"（`FullReloadSuggested`），UPROPERTY 修饰符走"必须 FullReload"

---

## 七、Actor 终结化：`FinalizeActorClass` 与组件实例化

**源码所在**：`AngelscriptClassGenerator.cpp` `FinalizeActorClass` + `ASClass.cpp` `CreateDefaultComponents`。

### 7.1 `FDefaultComponent` / `FOverrideComponent` 描述符

`UASClass`（`ASClass.h:37` 起）持有两组组件描述符：

```cpp
struct FDefaultComponent          // 对应 UPROPERTY(DefaultComponent)
{
    UClass*  ComponentClass;      // 组件类型
    FName    ComponentName;       // 组件 FName，等同 CreateDefaultSubobject 的 Name
    SIZE_T   VariableOffset;      // AS 对象内存中的偏移（用于把组件指针写回 AS 属性）
    FName    Attach;              // Attach=XXX 的目标组件名（NAME_None = root 或自动）
    FName    AttachSocket;        // AttachSocket=YYY
    bool     bIsRoot;             // RootComponent 修饰符
    bool     bEditorOnly;         // 来自 #if EDITOR 块（Cooked 包不创建）
};
TArray<FDefaultComponent> DefaultComponents;

struct FOverrideComponent         // 对应 UPROPERTY(OverrideComponent=ParentName)
{
    UClass*  ComponentClass;
    FName    OverrideComponentName;  // 父类组件名
    FName    VariableName;            // 本类属性名
    SIZE_T   VariableOffset;
};
TArray<FOverrideComponent> OverrideComponents;
```

### 7.2 `FinalizeActorClass` 转换 Meta → 描述符

```cpp
void FAngelscriptClassGenerator::FinalizeActorClass(FModuleData& M, TSharedPtr<FAngelscriptClassDesc> ClassDesc)
{
    UASClass* ASClass = (UASClass*)ClassDesc->Class;
    check(ASClass->DefaultComponents.Num() == 0);

    // ① 设置 Actor 专属构造函数（每次 SpawnActor 触发）
    ClassDesc->Class->ClassConstructor = &UASClass::StaticActorConstructor;

    // ② 遍历所有属性，根据 Meta 分发到两个描述符列表
    for (auto Property : ClassDesc->Properties)
    {
        if (Property->Meta.Contains(NAME_Actor_DefaultComponent))
        {
            UASClass::FDefaultComponent Comp;
            Comp.ComponentClass = Property->PropertyType.GetClass();
            Comp.ComponentName  = *Property->PropertyName;
            Comp.VariableOffset = Property->ScriptPropertyOffset;
            Comp.bIsRoot        = Property->Meta.Contains(NAME_Actor_RootComponent);
            FString* FoundAttach = Property->Meta.Find(NAME_Actor_Attach);
            Comp.Attach = FoundAttach ? **FoundAttach : NAME_None;
            FString* FoundSocket = Property->Meta.Find(NAME_Actor_AttachSocket);
            Comp.AttachSocket = FoundSocket ? **FoundSocket : NAME_None;

            // ── 编译期验证（违反即 ScriptCompileError） ──
            //   1. ComponentClass 必须 IsChildOf(UActorComponent)
            //   2. ComponentClass 不能是 abstract（除非本类也 abstract）
            //   3. 设置了 Attach 时必须 IsChildOf(USceneComponent)
            //   4. RootComponent 标记时必须 IsChildOf(USceneComponent)
            //   5. [WITH_EDITOR] 整个继承链上只允许一个 RootComponent

            ASClass->DefaultComponents.Add(Comp);
            ASClass->ClassFlags |= CLASS_HasInstancedReference;
        }
        else if (Property->Meta.Contains(NAME_Actor_OverrideComponent))
        {
            UASClass::FOverrideComponent Comp;
            Comp.ComponentClass        = Property->PropertyType.GetClass();
            Comp.OverrideComponentName = *Property->Meta[NAME_Actor_OverrideComponent];
            Comp.VariableName          = *Property->PropertyName;
            Comp.VariableOffset        = Property->ScriptPropertyOffset;

            // [WITH_EDITOR] 三路查找父类组件类型：
            //   路径 A：父类是 UASClass → 扫描其 DefaultComponents 列表
            //   路径 B：父类是 C++ Actor → 通过 GetComponents() 找运行时组件
            //   路径 C：抽象类组件不在 GetComponents 中 → TFieldIterator 扫 CPF_InstancedReference 属性

            ASClass->OverrideComponents.Add(Comp);
            ASClass->ClassFlags |= CLASS_HasInstancedReference;
        }
    }
}
```

### 7.3 `CreateDefaultComponents` 运行时实例化

```cpp
static FORCEINLINE_DEBUGGABLE void CreateDefaultComponents(
    const FObjectInitializer& Initializer, AActor* Actor, UASClass* ScriptClass)
{
    // ① 递归处理父类（祖→父→子，与 default 执行顺序一致）
    if (UASClass* ParentClass = Cast<UASClass>(ScriptClass->GetSuperClass()))
        CreateDefaultComponents(Initializer, Actor, ParentClass);

    TArray<TPair<USceneComponent*, int32>, TInlineAllocator<4>> DelayedComponentAttach;

    // ② 遍历本类 DefaultComponents
    for (int32 i = 0; i < ScriptClass->DefaultComponents.Num(); ++i)
    {
        auto& DC = ScriptClass->DefaultComponents[i];
        UClass* ComponentClass = DC.ComponentClass;
#if AS_CAN_HOTRELOAD
        ComponentClass = ComponentClass->GetMostUpToDateClass();   // 热重载时取最新版本
#endif

        UActorComponent* Component;
        if (WITH_EDITOR && DC.bEditorOnly)
            Component = (UActorComponent*)Initializer.CreateEditorOnlyDefaultSubobject(...);
        else
            Component = (UActorComponent*)Initializer.CreateDefaultSubobject(
                Actor, DC.ComponentName, ComponentClass, ComponentClass, true, false);

        // ③ 关键：把组件指针写回 AS 对象内存
        // 这是 AS 脚本中 `MeshComp.SetStaticMesh(...)` 能正常工作的唯一前提
        UActorComponent** VariablePtr = (UActorComponent**)((SIZE_T)Actor + DC.VariableOffset);
        *VariablePtr = Component;

        // ④ SceneComponent 附加层级
        if (auto* SC = Cast<USceneComponent>(Component))
        {
            if (DC.bIsRoot)
            {
                auto* PrevRoot = Actor->GetRootComponent();
                SC->SetupAttachment(nullptr);
                Actor->SetRootComponent(SC);
                if (PrevRoot != nullptr) PrevRoot->SetupAttachment(SC);   // 旧 Root 挂到新 Root 下
            }
            else if (DC.Attach == NAME_None)
            {
                if (Actor->GetRootComponent() == nullptr)
                {
                    SC->SetupAttachment(nullptr);
                    Actor->SetRootComponent(SC);                   // 第一个 SceneComponent 自动成 Root
                }
                else
                    SC->SetupAttachment(Actor->GetRootComponent(), DC.AttachSocket);
            }
            else
                DelayedComponentAttach.Add({ SC, i });             // 目标可能尚未创建
        }
    }

    // ⑤ 延迟附加：所有组件都创建后回扫，按 FName 找 Attach 目标
    for (auto& [SC, Idx] : DelayedComponentAttach)
    {
        auto& DC = ScriptClass->DefaultComponents[Idx];
        USceneComponent* AttachTo = nullptr;
        for (auto* C : Actor->GetComponents())
            if (C->GetFName() == DC.Attach)
                if (auto* CSC = Cast<USceneComponent>(C)) { AttachTo = CSC; break; }

        if (AttachTo != nullptr)            SC->SetupAttachment(AttachTo, DC.AttachSocket);
        else if (Actor->GetRootComponent()) SC->SetupAttachment(Actor->GetRootComponent(), DC.AttachSocket);
        else                                { SC->SetupAttachment(nullptr); Actor->SetRootComponent(SC); }
    }

    // ⑥ OverrideComponent：扫描 Actor 的所有组件，按 FName 找父类同名组件，写回引用
    for (auto& OC : ScriptClass->OverrideComponents)
    {
        UActorComponent** VariablePtr = (UActorComponent**)((SIZE_T)Actor + OC.VariableOffset);
        for (auto* C : Actor->GetComponents())
            if (C->GetFName() == OC.OverrideComponentName) { *VariablePtr = C; break; }
    }
}
```

### 7.4 `StaticActorConstructor` 完整时序

```text
SpawnActor -> UASClass::StaticActorConstructor(FObjectInitializer)
  [Step 1] ApplyOverrideComponents             // OverrideComponent 变量预填 nullptr
  [Step 2] Class->CodeSuperClass->ClassConstructor(Initializer)  // C++ 基类构造
  [Step 3] Actor->PrimaryActorTick.bCanEverTick = Class->bCanEverTick  // Tick 配置
  [Step 4] new(Object) asCScriptObject(ScriptType)               // AS 零初始化所有属性
  [Step 5] CreateDefaultComponents(...)                          // (*) 组件实例化 + AS 属性写回
  [Step 6] ExecuteConstructFunction(...)                         // AS 构造函数体 (脚本中的 AMyActor() {})
  [Step 7] ExecuteDefaultsFunctions(...)                         // (*) 所有 default 语句执行
                                                                 //     (详见 Syntax_DefaultStatement)
```

`UPROPERTY` 字段的"内存指针有效"发生在 **Step 5**，而它的 `default` 赋值发生在 **Step 7**——两者同处对象构造尾段，但分工明确。

### 7.5 组件修饰符完整链路 ASCII 全景

下图以三个组件属性为例，展示组件相关 UPROPERTY 修饰符从源码到运行时的完整路径。

```text
============================================================================
  组件修饰符完整链路: DefaultComponent / OverrideComponent / Attach
============================================================================

  [.as 源文件]
      UPROPERTY(DefaultComponent, RootComponent)
      UStaticMeshComponent MeshComp;

      UPROPERTY(DefaultComponent, Attach=MeshComp, AttachSocket=WeaponSocket)
      UChildActorComponent WeaponComp;

      UPROPERTY(OverrideComponent=ParentMeshComp)
      UStaticMeshComponent MeshOverride;
        |
        |  ===== 阶段 1: 预处理 (修饰符 -> Meta Map) =====
        v
ProcessPropertyMacro()
    [MeshComp]   DefaultComponent + RootComponent
        - bInstancedReference = true
        - bBlueprintReadable  = true,  bBlueprintWritable  = false
        - bEditableOnDefaults = true,  bEditableOnInstance = false
        - Meta["DefaultComponent"]   = "True"  (FinalizeActorClass 扫描 key)
        - Meta["EditInlineDefaults"] = "true"
        - Meta["RootComponent"]      = "True"  (FinalizeActorClass 判断 bIsRoot)

    [WeaponComp] DefaultComponent + Attach + AttachSocket
        - 同上 + Meta["Attach"]       = "MeshComp"
              + Meta["AttachSocket"] = "WeaponSocket"

    [MeshOverride] OverrideComponent=ParentMeshComp
        - bInstancedReference   = true
        - bBlueprintReadable    = false, bBlueprintWritable    = false
        - bEditableOnDefaults   = false, bEditableOnInstance   = false
        - Meta["OverrideComponent"] = "ParentMeshComp"
        |
        |  ===== 阶段 2: AddClassProperties (FProperty 生成) =====
        v
  AddClassProperties()
    [MeshComp]
      FObjectProperty { PropertyClass = UStaticMeshComponent }
      Flags: CPF_BlueprintVisible | CPF_InstancedReference | CPF_ExportObject
           | CPF_EditConst | CPF_Edit | CPF_DisableEditOnInstance
      check(GetOffset_ForUFunction() == ScriptPropertyOffset)   (*) 对齐断言

    [WeaponComp]
      FObjectProperty { PropertyClass = UChildActorComponent }
      Flags: 同上

    [MeshOverride]
      FObjectProperty { PropertyClass = UStaticMeshComponent }
      Flags: CPF_InstancedReference | CPF_ExportObject | CPF_EditConst
      (*) 不含 CPF_BlueprintVisible / CPF_Edit -- OverrideComponent 完全只读
        |
        |  ===== 阶段 3: FinalizeClass -> FinalizeActorClass =====
        v
  FinalizeClass(ModuleData, ClassData)
    - ClassData.bFinalized = true                  (防重入)
    - NewClass->SetUpRuntimeReplicationData()      (RepIndex 在这里分配)
    - IsChildOf(AActor) -> FinalizeActorClass(...)
        - ClassConstructor = &UASClass::StaticActorConstructor
        - 遍历 ClassDesc->Properties:

            [MeshComp] Meta.Contains("DefaultComponent")
              FDefaultComponent {
                  ComponentClass = UStaticMeshComponent
                  ComponentName  = "MeshComp"
                  VariableOffset = ScriptPropertyOffset
                  bIsRoot        = true
                  Attach         = NAME_None
              }
              编译期验证: IsChildOf(USceneComponent) / 非 Abstract / Root 唯一性
              -> ASClass->DefaultComponents.Add(Comp)
                 ASClass->ClassFlags |= CLASS_HasInstancedReference

            [WeaponComp] Meta.Contains("DefaultComponent")
              FDefaultComponent {
                  ComponentName = "WeaponComp"
                  Attach        = "MeshComp"        (非 NAME_None)
                  AttachSocket  = "WeaponSocket"
              }
              -> 运行时走 DelayedComponentAttach 路径

            [MeshOverride] Meta.Contains("OverrideComponent")
              FOverrideComponent {
                  ComponentClass        = UStaticMeshComponent
                  OverrideComponentName = "ParentMeshComp"
                  VariableName          = "MeshOverride"
                  VariableOffset        = ScriptPropertyOffset
              }
              [WITH_EDITOR] 三路查找父类组件类型:
                A) ParentASClass.DefaultComponents
                B) C++ Actor CDO.GetComponents()
                C) TFieldIterator 扫 CPF_InstancedReference 抽象属性
              -> ASClass->OverrideComponents.Add(Comp)
        |
        |  ===== 阶段 4: 运行时 SpawnActor -> StaticActorConstructor =====
        v
  UASClass::StaticActorConstructor(FObjectInitializer)
    [Step 1] ApplyOverrideComponents              (MeshOverride 变量预填 nullptr)
    [Step 2] CodeSuperClass->ClassConstructor     (C++ 基类构造)
    [Step 3] Actor->Tick 设置                      (来自 UASClass 元数据)
    [Step 4] new(Object) asCScriptObject(...)     (AS 零初始化所有属性)
    [Step 5] CreateDefaultComponents(...)         (递归: 父类先)

      [MeshComp] bIsRoot=true
        - CreateDefaultSubobject("MeshComp", UStaticMeshComponent)
        - *(VariableOffset 处) = Component        (*) 内存写回 AS 属性
        - SetupAttachment(nullptr)
        - Actor->SetRootComponent(SC)

      [WeaponComp] Attach="MeshComp" (延迟附加)
        - CreateDefaultSubobject("WeaponComp", UChildActorComponent)
        - *(VariableOffset 处) = Component        (*) 先写回引用
        - DelayedComponentAttach.Add({SC, idx})

      [循环结束后处理 DelayedComponentAttach]
        - 遍历 Actor->GetComponents() 找 FName=="MeshComp"
        - WeaponComp->SetupAttachment(MeshComp, "WeaponSocket")

      [处理 OverrideComponents]
        - 遍历 Actor->GetComponents() 找 FName=="ParentMeshComp"
        - *(MeshOverride VariableOffset 处) = ParentMeshComp

    [Step 6] ExecuteConstructFunction             (执行 AS 构造函数体)
    [Step 7] ExecuteDefaultsFunctions             (执行所有 default 语句, 见 Syntax_DefaultStatement)
        |
        |  ===== 运行时效果 =====
        v
  AS 脚本访问 (VariableOffset 处的指针有效):
      MeshComp.SetStaticMesh(MyMesh);
      WeaponComp.ChildActorClass = AMyWeapon::StaticClass();
      MeshOverride.SetMobility(EComponentMobility::Movable);   // 指向父类已有组件

  组件层级 (内存态):
      Actor
        +-- MeshComp (RootComponent)
            +-- WeaponComp (AttachSocket="WeaponSocket")
      ParentMeshComp (来自 C++ 父类, 被 MeshOverride 引用)

  UClass 元数据:
      ASClass->DefaultComponents[]  = [{MeshComp,Root}, {WeaponComp,Attach=MeshComp}]
      ASClass->OverrideComponents[] = [{ParentMeshComp -> MeshOverride}]
      ASClass->ClassFlags |= CLASS_HasInstancedReference
```

---

## 八、网络复制运行时：`GetLifetimeScriptReplicationList`

**源码所在**：`ASClass.cpp` `UASClass::GetLifetimeScriptReplicationList`，被引擎层 hook 调用（`ASClass.h:79` 声明）。

### 8.1 主流程

**当前项目实际实现**（`ASClass.cpp:898`）非常精简，**仅使用 2 参形式**：

```cpp
void UASClass::GetLifetimeScriptReplicationList(TArray<FLifetimeProperty>& OutLifetimeProps) const
{
    // 遍历本类（不含父类）所有 FProperty
    for (TFieldIterator<FProperty> It(this, EFieldIteratorFlags::ExcludeSuper); It; ++It)
    {
        FProperty* Prop = *It;
        if (Prop != NULL && Prop->GetPropertyFlags() & CPF_Net)
        {
            // ★ 注意：当前项目使用 2 参短构造 + AddUnique
            //   不传递 RepNotifyCondition / bIsPushBased
            //   → 引擎走默认值（REPNOTIFY_OnChanged + bIsPushBased=false）
            OutLifetimeProps.AddUnique(
                FLifetimeProperty(Prop->RepIndex, Prop->GetBlueprintReplicationCondition()));
        }
    }

    // 递归向父 AS 类传播（处理多层 AS 继承链）
    UASClass* SuperScriptClass = Cast<UASClass>(GetSuperStruct());
    if (SuperScriptClass != NULL)
        SuperScriptClass->GetLifetimeScriptReplicationList(OutLifetimeProps);
    // 终止条件：父类不是 UASClass（C++ 基类自己处理 GetLifetimeReplicatedProps）
}
```

**与 Hazelight 的实现对照**：

```cpp
// Hazelight 版本（参考）：4 参完整形式 + Push Model 检查
const bool bIsPushModel = PushModelReplicatedProperties.Contains(Prop->GetFName());
OutLifetimeProps.Add(FLifetimeProperty(
    Prop->RepIndex,
    Prop->GetBlueprintReplicationCondition(),
    REPNOTIFY_OnChanged,                // 显式指定 RepNotify 模式
    bIsPushModel                         // Push Model 标志
));
```

差异梳理：

| 维度 | 当前项目 | Hazelight |
|------|---------|-----------|
| `FLifetimeProperty` 构造 | 2 参（RepIndex + Condition） | 4 参（含 RepNotifyCondition + bIsPushBased） |
| 防重逻辑 | `AddUnique`（依赖 `==` 运算符） | `FindByPredicate` 显式按 RepIndex 比较 |
| `REPNOTIFY_OnChanged` | 默认值 | 显式传递 |
| Push Model | **不参与**，永远走每帧轮询 | 通过 `PushModelReplicatedProperties` 列表识别 |

**实际行为后果**：
- 默认 `RepNotifyCondition` 在 UE 5.7 中是 `REPNOTIFY_OnChanged`，与 Hazelight 一致——**该差异无影响**
- 默认 `bIsPushBased` 是 `false`——当前项目所有 AS 复制属性都走传统每帧轮询路径（`bIsPushBased=false`）
- `AddUnique` 与 `FindByPredicate` 在 `FLifetimeProperty` 重载了 `operator==` 按 RepIndex 比较的前提下行为等价

### 8.2 `FLifetimeProperty` 数据结构

```cpp
class FLifetimeProperty
{
public:
    uint16              RepIndex;
    ELifetimeCondition  Condition;          // COND_None / COND_OwnerOnly / COND_InitialOnly / ... 14 种
    ELifetimeRepNotifyCondition RepNotifyCondition;   // AS 固定 REPNOTIFY_OnChanged
    bool                bIsPushBased;       // true=服务器手动 MarkDirty 推送；false=每帧轮询比对
};
```

---

## 九、与 Hazelight 引擎实现的差异（速览）

UPROPERTY 的核心流水线（预处理 + 描述符 + AddClassProperties + DetectAngelscriptReferences + FinalizeActorClass + CreateDefaultComponents）与 Hazelight **几乎完全一致**。已识别的差异（按主题分组）：

### 9.1 架构性差异（不可平移）

| 差异 | 当前项目 | Hazelight | 处理决策 |
|------|---------|-----------|---------|
| `CPF_RuntimeGenerated` 设置 | ❌ 该行被注释（`AngelscriptClassGenerator.cpp:2948`） | ✅ 通过自定义 `APF_RuntimeGenerated` + 引擎扩展位 | **架构性差异**，独立插件无法平移，详见 `Diff_HazelightDefaultStatement.md` §二.差异② 及 `Plan_DefaultStatementHazelightParity.md` Phase 2 |
| `AngelscriptPropertyFlags` 字段（`APF_*` 标志位） | ❌ 完全缺失 | ✅ 修改 UE 引擎核心 `FProperty` 加字段 | **架构性差异**，需替代方案 |

### 9.2 修饰符级别的能力缺失（可补足）

| 修饰符 | 当前项目 | Hazelight | 影响范围 | 补足成本 |
|--------|---------|-----------|---------|---------|
| `BindWidgetAnim` | ❌ `PP_NAME_BindWidgetAnim` 不存在 | ✅ 与 `BindWidget` 同形式 | UMG 动画资产无法用 AS 绑定，必须借蓝图 | 极低（与 BindWidget 同模式） |
| `BindWidgetOptional` | ❌ `PP_NAME_BindWidgetOptional` 不存在 | ✅ | 用户编译期无法声明"可选绑定" | 极低 |
| `BindComponent` | ❌ `PP_NAME_BindComponent` 不存在 | ✅ | 蓝图组件绑定能力缺失 | 中 |
| `ReplicationPushModel` | ❌ `PP_NAME_ReplicationPushModel` 不存在 + `UASClass::PushModelReplicatedProperties` 列表不存在 | ✅ 完整 Push Model 路径 | 复制走传统每帧轮询，性能不如 Push Model | 中（需 §8.1 同步改造） |

### 9.3 实现简化差异（行为一致但代码更精简）

| 实现点 | 当前项目 | Hazelight | 实际后果 |
|--------|---------|-----------|---------|
| `GetLifetimeScriptReplicationList` 构造形式 | 2 参 `FLifetimeProperty(RepIndex, Condition)` + `AddUnique` | 4 参 `FLifetimeProperty(..., REPNOTIFY_OnChanged, bIsPushModel)` + `FindByPredicate` | 当前项目走 UE 默认 `RepNotifyCondition`（恰好就是 `REPNOTIFY_OnChanged`），行为一致；但 Push Model 不可用（详见 9.2） |
| `FAngelscriptPrecompiledProperty` 序列化 | 逐字段 `Ar << bool` 直接写入 | 20 个 bool packed 进 uint32 位掩码 | 当前项目预编译文件略大（每个属性多约 16 字节），但加载 / 保存逻辑更简单直观 |
| `FAngelscriptPrecompiledProperty` 字段 | 无 `bNoClear`、无 `bConfig` 单独 packing 优化、`ReplicationCondition` 用 `int32` | 含 `bNoClear` bit、`ReplicationCondition` 用 `uint8` | 当前项目存盘的属性失去 `NoClear` 信息——加载后该 flag 丢失（运行时编译路径不受影响） |
| `bIsPrivate` / `bIsProtected` 序列化时机 | 永远序列化（在 `if (bIsUnrealProperty)` 块外） | 在块内序列化 | 无运行时影响 |

### 9.4 关联文档与执行计划

> 完整差异分析见 `Documents/Knowledges/ZH/Diff_HazelightDefaultStatement.md`、`Documents/Knowledges/ZH/Diff_HazelightInsightsToBorrow.md`。
>
> 上述 §9.2 修饰符补足、§9.3 序列化优化建议在 `Plan_DefaultStatementHazelightParity.md` 后续扩展或新建独立 Plan（如 `Plan_HazelightUPROPERTYParity.md`）。

---

## 十、修饰符 → CPF / Meta 完整速查表

| UPROPERTY 修饰符 | PropDesc 字段 | 最终效果 | 备注 |
|------------------|--------------|---------|------|
| `EditAnywhere` | `bEditableOnDefaults/Instance=true` | `CPF_Edit` | 最常用 |
| `EditDefaultsOnly` | `bEditableOnDefaults=true` | `CPF_Edit \| CPF_DisableEditOnInstance` | 仅 CDO |
| `EditInstanceOnly` | `bEditableOnInstance=true` | `CPF_Edit \| CPF_DisableEditOnTemplate` | 仅实例 |
| `NotEditable` / `NotVisible` | 两个 editable 都 false | （无 CPF_Edit） | 彻底隐藏 |
| `VisibleAnywhere` | `bEditConst=true` + `bEditable*=true` | `CPF_Edit \| CPF_EditConst` | 灰化显示 |
| `VisibleDefaultsOnly` | 同上 + 仅 OnDefaults | `CPF_Edit \| CPF_EditConst \| CPF_DisableEditOnInstance` | |
| `VisibleInstanceOnly` | 同上 + 仅 OnInstance | `CPF_Edit \| CPF_EditConst \| CPF_DisableEditOnTemplate` | |
| `EditConst` | `bEditConst=true` | `CPF_EditConst` | 与 Edit/Visible 联用 |
| `BlueprintReadWrite` | `bBlueprintReadable/Writable=true` | `CPF_BlueprintVisible` | |
| `BlueprintReadOnly` | `bBlueprintWritable=false` | `CPF_BlueprintVisible \| CPF_BlueprintReadOnly` | |
| `BlueprintHidden` | 两个 blueprint 都 false | 不设 CPF_BlueprintVisible | |
| `BlueprintSetter=Func` | `Meta["BlueprintSetter"]=Func` | 蓝图写时调用 Func | 函数名为空 → 编译错误 |
| `BlueprintGetter=Func` | `Meta["BlueprintGetter"]=Func` | 蓝图读时调用 Func | 同上 |
| `BlueprintProtected` | `Meta["BlueprintProtected"]=true` | 子类蓝图可访问 | |
| `Replicated` | `bReplicated=true` | `CPF_Net` | |
| `ReplicatedUsing=Func` | `bReplicated=true, bRepNotify=true, Meta["ReplicatedUsing"]=Func` | `CPF_Net \| CPF_RepNotify, RepNotifyFunc=Func` | |
| `ReplicationCondition=X` | `ReplicationCondition=COND_X` | `SetBlueprintReplicationCondition` | 14 种条件 |
| `NotReplicated` | `bSkipReplication=true` | `CPF_RepSkip` | **仅 struct 字段** |
| `Transient` | `bTransient=true` | `CPF_Transient` | |
| `SaveGame` | `bSaveGame=true` | `CPF_SaveGame` | |
| `SkipSerialization` | `bSkipSerialization=true` | `CPF_SkipSerialization` | |
| `Config` | `bConfig=true` | `CPF_Config` | 从 .ini 读取 |
| `AdvancedDisplay` | `bAdvancedDisplay=true` | `CPF_AdvancedDisplay` | 折叠到高级区 |
| `Interp` | `bInterp=true` | `CPF_Interp` | Sequencer 可驱动 |
| `AssetRegistrySearchable` | `bAssetRegistrySearchable=true` | `CPF_AssetRegistrySearchable` | |
| `NoClear` | `bNoClear=true` | `CPF_NoClear` | 禁止设为 None |
| `Instanced` | `bPersistentInstance=true` | `STRUCT_HasInstancedReference` 气泡传播 | |
| `DefaultComponent` | `bInstancedReference=true` + `bBlueprintReadable=true` + `Meta["DefaultComponent"]="True"` + `Meta["EditInlineDefaults"]="true"` | `CPF_InstancedReference \| CPF_ExportObject \| CPF_EditConst` + 进入 `UASClass::DefaultComponents[]` | |
| `RootComponent` | `Meta["RootComponent"]="True"` | `FDefaultComponent::bIsRoot=true` | 与 DefaultComponent 联用 |
| `Attach=Name` | `Meta["Attach"]=Name` | `FDefaultComponent::Attach=Name` | 运行时延迟附加 |
| `AttachSocket=Name` | `Meta["AttachSocket"]=Name` | `FDefaultComponent::AttachSocket=Name` | |
| `OverrideComponent=Name` | `bInstancedReference=true` + 所有访问权限=false + `Meta["OverrideComponent"]=Name` | 进入 `UASClass::OverrideComponents[]` | 完全只读引用父类组件 |
| `ShowOnActor` | `bEditableOnInstance=true` + `Meta["EditInline"]="true"` | 实例可编辑组件属性 | 叠加于 DefaultComponent |
| `BindWidget` | `bTransient=true` + `bBlueprintReadable=true` + `Meta["BindWidget"]=""` | `CPF_Transient \| CPF_BlueprintVisible` | UMG 绑定 |
| `Category=X` | `Meta["Category"]=X` | Details 面板分组 | |
| `DisplayName=X` | `Meta["DisplayName"]=X` | 编辑器显示名 | |
| `ToolTip=X` | `Meta["ToolTip"]=X` | 鼠标悬停提示 | （注释自动转入） |
| `Keywords=X` | `Meta["Keywords"]=X` | 搜索关键字 | |
| `meta=(ExposeOnSpawn)` | `Meta["ExposeOnSpawn"]` | `CPF_ExposeOnSpawn` | SpawnActor 暴露参数 |
| `meta=(EditFixedSize)` | `Meta["EditFixedSize"]` | `CPF_EditFixedSize` | 数组定长 |
| `meta=(AllowPrivateAccess)` | `Meta["AllowPrivateAccess"]` | 允许 private 暴露蓝图 | |
| `meta=(ClampMin/Max=X)` | `Meta["ClampMin"]=X` 等 | 编辑器输入约束 | |
| `meta=(EditCondition=Expr)` | `Meta["EditCondition"]=Expr` | 条件显示/灰化 | |
| `#if EDITOR ... #endif` 块内 | `Macro.bEditorOnly=true` → `Meta["EditorOnly"]` | `CPF_EditorOnly` | Cooked 包不存在 |

### 10.1 修饰符 → 字段 → CPF / Meta 数据流分组速查

下面按主题分组呈现修饰符流向。每个分组用三段式表达：
**修饰符** → **PropDesc 字段（来自 §三）** → **最终 CPF / Meta 效果（来自 §四）**。

#### 蓝图访问

```text
BlueprintReadWrite        ->  bBlueprintReadable=T, bBlueprintWritable=T
BlueprintReadOnly         ->  bBlueprintReadable=T, bBlueprintWritable=F
BlueprintHidden           ->  bBlueprintReadable=F, bBlueprintWritable=F
                              |
                              v  AddClassProperties §4.2 (4)
                              CPF_BlueprintVisible (+ CPF_BlueprintReadOnly?)
                              注: private 默认不暴露, 需 meta=(AllowPrivateAccess)

BlueprintSetter=Func      ->  Meta["BlueprintSetter"]=Func
BlueprintGetter=Func      ->  Meta["BlueprintGetter"]=Func
BlueprintProtected        ->  Meta["BlueprintProtected"]=true
```

#### 编辑器可见性

```text
EditAnywhere              ->  bEditableOnDefaults=T, bEditableOnInstance=T
EditDefaultsOnly          ->  bEditableOnDefaults=T, bEditableOnInstance=F
EditInstanceOnly          ->  bEditableOnDefaults=F, bEditableOnInstance=T
NotEditable / NotVisible  ->  两个 editable 都为 F
EditConst                 ->  bEditConst=T
VisibleAnywhere           ->  bEditConst=T + bEditable* 都为 T
VisibleDefaultsOnly       ->  bEditConst=T + 仅 OnDefaults
VisibleInstanceOnly       ->  bEditConst=T + 仅 OnInstance
                              |
                              v  AddClassProperties §4.2 (5)
                              CPF_Edit (+ DisableEditOnInstance/Template)
                              (+ CPF_EditConst when bEditConst)
```

#### 网络复制

```text
Replicated                ->  bReplicated=T
ReplicatedUsing=Func      ->  bReplicated=T, bRepNotify=T,
                              Meta["ReplicatedUsing"]=Func
ReplicationCondition=X    ->  ReplicationCondition=COND_X
NotReplicated (Struct)    ->  bSkipReplication=T
                              |
                              v  AddClassProperties §4.2 (2)
                              CPF_Net (+ CPF_RepNotify, RepNotifyFunc=Func)
                              CPF_RepSkip (Struct 字段)
                              SetBlueprintReplicationCondition(COND_X)
```

#### 序列化

```text
Transient                 ->  bTransient=T              ->  CPF_Transient
SaveGame                  ->  bSaveGame=T               ->  CPF_SaveGame
SkipSerialization         ->  bSkipSerialization=T      ->  CPF_SkipSerialization
Config                    ->  bConfig=T                 ->  CPF_Config
```

#### 显示与杂项

```text
AdvancedDisplay           ->  bAdvancedDisplay=T         ->  CPF_AdvancedDisplay
Interp                    ->  bInterp=T                  ->  CPF_Interp
AssetRegistrySearchable   ->  bAssetRegistrySearchable=T ->  CPF_AssetRegistrySearchable
NoClear                   ->  bNoClear=T                 ->  CPF_NoClear
                              注: 当前项目预编译序列化丢失该字段, 详见 §十一
```

#### 实例引用

```text
Instanced                 ->  bPersistentInstance=T
                              |
                              v  AddClassProperties §4.2 (6)
                              MarkUStructContainsReference()
                              -> STRUCT_HasInstancedReference 气泡上传
```

#### 组件（仅 Actor）

```text
DefaultComponent          ->  bInstancedReference=T,
                              bBlueprintReadable=T,
                              Meta["DefaultComponent"]="True",
                              Meta["EditInlineDefaults"]="true"
                              |
                              v  AddClassProperties §4.2 (6) + FinalizeActorClass §7.2
                              CPF_InstancedReference | CPF_ExportObject | CPF_EditConst
                              + UASClass::DefaultComponents.Add(FDefaultComponent{...})

RootComponent             ->  Meta["RootComponent"]="True"
                              -> FDefaultComponent::bIsRoot=true
Attach=Name               ->  Meta["Attach"]=Name
                              -> FDefaultComponent::Attach=Name
AttachSocket=Name         ->  Meta["AttachSocket"]=Name
                              -> FDefaultComponent::AttachSocket=Name

OverrideComponent=Name    ->  bInstancedReference=T,
                              所有访问权限=F,
                              Meta["OverrideComponent"]=Name
                              |
                              v
                              CPF_InstancedReference | CPF_ExportObject | CPF_EditConst
                              + UASClass::OverrideComponents.Add(FOverrideComponent{...})

ShowOnActor               ->  bEditableOnInstance=T, Meta["EditInline"]="true"
                              注: 必须与 DefaultComponent 联用
```

#### UI 绑定

```text
BindWidget                ->  bTransient=T, bBlueprintReadable=T,
                              Meta["BindWidget"]=""
                              |
                              v
                              CPF_Transient | CPF_BlueprintVisible

注: 当前项目缺失 BindWidgetAnim / BindWidgetOptional / BindComponent
    -- 详见 §九.9.2 已识别 Hazelight 差异
```

#### Meta 直通（无独立 bool 字段）

```text
Category=X                ->  Meta["Category"]=X         -> Details 面板分组
DisplayName=X             ->  Meta["DisplayName"]=X      -> 编辑器显示名
ToolTip=X                 ->  Meta["ToolTip"]=X          -> 鼠标悬停 (注释自动转入)
Keywords=X                ->  Meta["Keywords"]=X         -> 搜索关键字

meta=(ExposeOnSpawn)      ->  Meta["ExposeOnSpawn"]      ->  CPF_ExposeOnSpawn
meta=(EditFixedSize)      ->  Meta["EditFixedSize"]      ->  CPF_EditFixedSize
meta=(AllowPrivateAccess) ->  Meta["AllowPrivateAccess"] -> 允许 private 暴露蓝图
meta=(ClampMin/Max=X)     ->  Meta["ClampMin/Max"]=X     -> 编辑器输入约束
meta=(EditCondition=Expr) ->  Meta["EditCondition"]=Expr -> 条件显示/灰化
```

#### 隐式属性（非 specifier，但影响行为）

```text
#if EDITOR 块内           ->  Macro.bEditorOnly=true,
                              Meta["EditorOnly"]=""      ->  CPF_EditorOnly
                              注: Cooked 包此属性不存在

private: / protected: 块  ->  bIsPrivate / bIsProtected
                              影响 CPF_BlueprintVisible 决策 (§4.2 ④)
                              bIsProtected -> SetMetaData("BlueprintProtected", "true")
```

---

## 十一、预编译持久化：`FAngelscriptPrecompiledProperty`

**源码所在**：`Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/PrecompiledData.h:188`。

> **重要差异提示**：参考文档（Hazelight 第四轮版本）描述的"20 个 bool packed 进 uint32 位掩码"序列化格式**仅适用于 Hazelight**。当前项目采用**更直观的逐字段序列化**（`Ar << bool`），代码更简单但磁盘体积略大。

### 11.1 真实字段定义（当前项目）

```cpp
struct FAngelscriptPrecompiledProperty
{
    // === Angelscript 数据（永远序列化）===
    FStringInArchive Name;
    FAngelscriptPrecompiledDataType Type;
    bool bIsPrivate   = false;
    bool bIsProtected = false;

    // === 预处理器数据 ===
    bool bIsUnrealProperty;            // 是否有 UPROPERTY 宏；为 false 时下面字段全部跳过
    TArray<FStringInArchive, TPrecompiledAllocator<>> MetaSpec;     // Meta 键
    TArray<FStringInArchive, TPrecompiledAllocator<>> MetaValues;   // Meta 值
    bool  bBlueprintReadable;
    bool  bBlueprintWritable;
    bool  bEditConst;
    bool  bEditableOnDefaults;
    bool  bEditableOnInstance;
    bool  bInstancedReference;
    bool  bPersistentInstance;
    bool  bAdvancedDisplay;
    bool  bTransient;
    bool  bReplicated;
    int32 ReplicationCondition;        // 注意：是 int32，不是 uint8
    bool  bSkipReplication;
    bool  bSkipSerialization;
    bool  bSaveGame;
    bool  bRepNotify;                  // 仅 bReplicated=true 时序列化
    bool  bConfig;
    bool  bInterp;
    bool  bAssetRegistrySearchable;
    // 注意：当前项目无 bNoClear 字段
    //      → NoClear 修饰符在 .precompiled 文件中无法持久化
    //      → Shipping 包冷启动会丢失 NoClear 信息
};
```

### 11.2 实际序列化逻辑

```cpp
inline friend FArchive& operator<<(FArchive& Ar, FAngelscriptPrecompiledProperty& Data)
{
    Ar << Data.Name;
    Ar << Data.Type;
    Ar << Data.bIsPrivate;        // 注意：永远序列化（不在 if (bIsUnrealProperty) 内）
    Ar << Data.bIsProtected;

    Ar << Data.bIsUnrealProperty;
    if (Data.bIsUnrealProperty)
    {
        Ar << Data.MetaSpec;
        Ar << Data.MetaValues;
        Ar << Data.bBlueprintReadable;
        Ar << Data.bBlueprintWritable;
        Ar << Data.bEditConst;
        Ar << Data.bEditableOnDefaults;
        Ar << Data.bEditableOnInstance;
        Ar << Data.bInstancedReference;
        Ar << Data.bPersistentInstance;
        Ar << Data.bAdvancedDisplay;
        Ar << Data.bTransient;
        Ar << Data.bReplicated;
        Ar << Data.bSkipReplication;
        Ar << Data.bSkipSerialization;
        Ar << Data.bSaveGame;
        if (Data.bReplicated)             // 嵌套 if：仅复制属性才存这两个
        {
            Ar << Data.ReplicationCondition;
            Ar << Data.bRepNotify;
        }
        Ar << Data.bConfig;
        Ar << Data.bInterp;
        Ar << Data.bAssetRegistrySearchable;
    }
    return Ar;
}
```

### 11.3 加载路径优势

Shipping 包冷启动时不需要重跑 `ParseIntoChunks` + `ProcessPropertyMacro` 的字符串解析全流程，直接从 `.precompiled` 文件反序列化 `FAngelscriptPrecompiledProperty[]`，再交给 `AddClassProperties` 走相同的 CPF 分发逻辑——保证运行时行为一致，启动速度大幅提升。

### 11.4 当前项目实现的两点已知不足

| 问题 | 当前行为 | 影响 |
|------|---------|------|
| 缺 `bNoClear` 字段 | `NoClear` 修饰符不持久化 | Shipping 冷启动丢失 NoClear 信息（但运行时编译路径不受影响——首次编译时仍然正常设置 `CPF_NoClear`，仅缓存反序列化路径丢失） |
| 未做位掩码 packing | 逐字段写入 ~20 个 bool（每个 1 字节） | `.precompiled` 文件每个属性多约 16 字节体积；与 Hazelight 不兼容（不能跨实现共享缓存） |

补足建议参考 §9.3，可纳入未来的 `Plan_HazelightUPROPERTYParity.md`。

---

## 十二、关键结论速查

| 主题 | 结论 |
|------|------|
| **UPROPERTY 不是 AS 关键字** | 完全是预处理器层面的宏伪装，AS 内核解析器对它无感知 |
| **核心数据载体** | `FAngelscriptPropertyDesc`（位于 `AngelscriptEngine.h:798`），所有 specifier 都先翻译为它的 bool 字段或 Meta Map |
| **入口识别** | `ParseIntoChunks` 中 `case 'U'` + `Strncmp("UPROPERTY(", 10)` + 5 个前置条件（含作用域、注释/字符串排除、IsStartOfIdentifier 防误匹配） |
| **括号配对** | 用 `BracketCount` + `MacroExitScope` 状态机精确处理 `meta=(...)` 的嵌套括号 |
| **属性名 / 类型提取** | `FinishMacro` 从 `;` 位置反向扫描跳过空白获取名字，再继续反向到换行/`)` 获取类型 |
| **CPF 分发位置** | `AngelscriptClassGenerator.cpp:2851` `AddClassProperties` 中按 PropDesc 字段顺序设置 `CPF_*` 标志位 |
| **CPF_RuntimeGenerated 缺失** | 当前项目该行被刻意注释（`:2948`），属于 `AngelscriptPropertyFlags` 架构性差异，详见 §九 |
| **内存对齐契约** | `check(NewProperty->GetOffset_ForUFunction() == ScriptProp->byteOffset)` 保证 AS 与 UE 反射布局完全一致，失败即崩溃 |
| **GC 兜底** | `DetectAngelscriptReferences` 为没有 UPROPERTY 宏的私有引用属性补 `UE::GC::FSchemaView`，避免内存泄漏 |
| **热重载策略** | `IsDefinitionEquivalent` 比较所有结构性 bool 字段 → 任何修饰符变化都 **必须 FullReload**（与 default 的"建议 FullReload"形成对比） |
| **DefaultComponent 三态** | `FDefaultComponent` 在 FinalizeActorClass 构建 → CreateDefaultComponents 在 SpawnActor 时 `CreateDefaultSubobject` + 内存写回 AS 属性 |
| **OverrideComponent 引用** | 仅引用，不创建；FinalizeActorClass 三路查找父类组件类型；CreateDefaultComponents 末尾按 FName 写回引用 |
| **网络复制注册** | `GetLifetimeScriptReplicationList` 遍历 CPF_Net 属性 + 沿 UASClass 继承链递归；引擎层 hook 在 `GetLifetimeReplicatedProps` 中调用 |
| **Push Model 缺失** | 当前项目 `GetLifetimeScriptReplicationList` 用 2 参 `FLifetimeProperty(RepIndex, Condition)` + `AddUnique`，无 Push Model 检查；引擎走传统每帧轮询路径——已识别 Hazelight 差异 |
| **预编译持久化** | `FAngelscriptPrecompiledProperty` **逐字段 `Ar << bool` 序列化**（不是参考文档的位掩码 packing），缺少 `bNoClear` 字段——属于当前项目 vs Hazelight 的实现差异，详见 §九.9.3、§十一.11.4 |
| **未知修饰符处理** | `ProcessPropertyMacro` 默认分支调 `MacroError` 编译期报错 → VS Code Problems 可见 |
| **错误集中点** | ① 未知 specifier → 编译期报错；② BlueprintSetter/Getter 函数名为空 → 编译期报错；③ 内存对齐失败 → check 崩溃；④ DefaultComponent 类型/抽象/继承约束违反 → ScriptCompileError；⑤ RootComponent 唯一性违反（继承链） → ScriptCompileError |

---

## 十三、关联文档

- 实现原理（兄弟章节）：
  - `Documents/Knowledges/ZH/Syntax_DefaultStatement.md` — `default` 语句实现原理（与本文 §六 / §七.4 紧密关联）
  - `Documents/Knowledges/ZH/Syntax_DefaultComponent.md` — `DefaultComponent` / `Attach` / `RootComponent` 组件声明专题（待写）
  - `Documents/Knowledges/ZH/Syntax_UFUNCTION.md` — `UFUNCTION` 修饰符（共享 FMacro / ProcessXxxMacro 流水线）
- 差异分析：
  - `Documents/Knowledges/ZH/Diff_HazelightDefaultStatement.md` — `AngelscriptPropertyFlags` 架构性差异详述
  - `Documents/Knowledges/ZH/Diff_HazelightInsightsToBorrow.md` — Hazelight 可借鉴设计点全插件汇总
- 执行计划：
  - `Documents/Plans/Plan_DefaultStatementHazelightParity.md` — `CPF_RuntimeGenerated` 替代方案 Phase 2
- 架构总览：
  - `Documents/Knowledges/ZH/Arch_Overview.md` — 插件总体架构（待写）
  - `Documents/Knowledges/ZH/Type_ClassGeneration.md` — 类生成机制（待写，含 ASClass/Generator 协作）

---

## 十四、修订记录

| 版本 | 日期 | 内容 |
|------|------|------|
| v1.0 | 2026-04-28 | 首版：基于 `Temp/Temp_UProperty/uproperty.md` 五轮迭代分析 + 实际源码核对完整产出，覆盖词法扫描/语义解析/CPF 映射/GC 兜底/热重载/组件实例化/网络复制/预编译持久化全链路；记录已识别 Hazelight 差异（`CPF_RuntimeGenerated`、`ReplicationPushModel`、`BindWidgetAnim`、`AngelscriptPropertyFlags`） |
| v1.1 | 2026-04-28 | 与当前仓库实际源码做精细比对，修正多处与参考文档（Hazelight）不符的描述：① §三.UI 绑定 — 补充缺失的 `BindWidgetOptional` / `BindComponent` 修饰符；② §八.8.1 — 修正 `GetLifetimeScriptReplicationList` 实际为 2 参 `AddUnique` 简化版，无 Push Model 检查；③ §九 — 重组为三类差异（架构性 / 修饰符缺失 / 实现简化）；④ §十一 — 完全重写预编译序列化描述（实际为逐字段 `Ar << bool`，非位掩码 packing；缺 `bNoClear` 字段；`ReplicationCondition` 用 `int32`） |
| v1.2 | 2026-04-28 | 整合参考文档中跨 5 轮迭代的 ASCII 图示，新增 3 张全景图：① 概览之后 — **完整生命周期 ASCII 全景**（以 `int32 Health` 为例展示从源码字符到运行时使用的全链路）；② §七.5 — **组件修饰符完整链路 ASCII 全景**（DefaultComponent + RootComponent + Attach + OverrideComponent 端到端流程）；③ §十.10.1 — **修饰符 → 字段 → CPF / Meta 数据流全景图**（按 9 个主题分组的可视化映射）。所有图示均已适配当前项目实际源码（含 `CPF_RuntimeGenerated` 注释、`GetLifetimeScriptReplicationList` 2 参形式、缺失修饰符标注等）。 |
| v1.3 | 2026-04-28 | 重写所有 ASCII 图示以提升字体兼容性。**问题**：v1.2 图示大量使用全角字符（`▼ ▌ ★ ① ② ─ │ ┌ └ ═ ➡`），在非等宽字体或不同操作系统/浏览器下会发生宽度错位、对齐失效甚至字符不显示。**修复**：① 全角符号 → 纯 ASCII（`v` `|` `+` `-` `=` `*`）；② 圆圈数字 `①②③` → `[Step 1]` / `(1)` `(2)`；③ 主题分隔符 `▌` → Markdown 三级标题；④ 复杂全景流程图（图 3）从单一代码块拆分为 9 个分主题的小代码块，每块独立紧凑、便于在网页上分块渲染；⑤ 注释强调改用纯文本"注:"前缀而非 `★`。所有图示在等宽字体（VS Code / 网页 `<pre>`）和比例字体（GitHub Markdown 默认 / Notion）下都能稳定显示。 |
