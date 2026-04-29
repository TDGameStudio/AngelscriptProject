# `DefaultComponent` / `Attach` / `RootComponent` / `OverrideComponent` 实现原理

> 本文记录 AngelScript 插件中**组件类 UPROPERTY 修饰符**的完整实现：从源码字符到 SpawnActor 时刻组件实例化的全链路。
>
> 与 `Syntax_UPROPERTY.md` §七、§十.10.1 共享数据结构与运行时机制，本文专题展开。
> 与 `Syntax_DefaultStatement.md` §1.6 共享对象构造时序（Step 5 = 本文 §六）。

---

## 概览

`DefaultComponent` / `RootComponent` / `Attach` / `AttachSocket` / `OverrideComponent` / `ShowOnActor` 是 6 个**专为 Actor 服务**的 UPROPERTY 修饰符，让 AS 脚本能像 C++ 那样在 Actor 类体内**直接声明组件字段**：

```text
.as 源文件:
    UPROPERTY(DefaultComponent, RootComponent)
    UStaticMeshComponent MeshComp;

    UPROPERTY(DefaultComponent, Attach=MeshComp, AttachSocket=Weapon)
    UChildActorComponent WeaponComp;

    UPROPERTY(OverrideComponent=ParentMesh)
    UStaticMeshComponent MeshOverride;
```

它们走与普通 UPROPERTY **相同的预处理器流水线**，但额外在 Meta Map 中留下"组件标记"，由类生成器与运行时构造器接力完成最终的"创建子对象 + 写回 AS 属性指针 + 设置附加层级"全流程。

### 完整管线总览

```text
预处理器层 (Preprocessor)               类生成器层 (ClassGenerator)
=============================           ====================================
ProcessPropertyMacro 分发               (1) Analyze 早期校验 (WITH_EDITOR)
- DefaultComponent specifier            - 组件名是否与 C++ 父类冲突
  -> bInstancedReference=true,           - 类型是否继承 UActorComponent
     bBlueprintReadable=true,            - Attach 目标是否存在
     bEditableOnDefaults=true,
     Meta["DefaultComponent"]="True",   (2) DoFullReloadClass
     Meta["EditInlineDefaults"]="true"  - 调用 AddClassProperties 创建 FObjectProperty
- RootComponent  -> Meta["RootComponent"]
- Attach=Name    -> Meta["Attach"]      (3) FinalizeActorClass
- AttachSocket=N -> Meta["AttachSocket"]- 把 Meta 信息固化为 UASClass::FDefaultComponent[]
- OverrideComponent=Name                  与 FOverrideComponent[] 描述符
  -> 全部访问权限关闭, 仅 InstancedRef  - 编译期校验 (类型/抽象/RootComponent 唯一性)
  -> Meta["OverrideComponent"]=Name     - ClassConstructor = StaticActorConstructor
- ShowOnActor                           - ClassFlags |= CLASS_HasInstancedReference
  -> bEditableOnInstance=true
                                        运行时层 (StaticActorConstructor)
                                        ====================================
                                        SpawnActor 触发:
                                        Step 1: ApplyOverrideComponents
                                                (Initializer.SetDefaultSubobjectClass)
                                        Step 2: CodeSuperClass->ClassConstructor
                                        Step 3: Actor 设置 Tick 配置
                                        Step 4: new(Object) asCScriptObject
                                        Step 5: CreateDefaultComponents (★ 本文核心)
                                                - CreateDefaultSubobject 创建组件
                                                - 内存写回 AS 属性指针
                                                - SetupAttachment / DelayedAttach
                                                - 处理 OverrideComponents 引用
                                        Step 6: ExecuteConstructFunction
                                        Step 7: ExecuteDefaultsFunctions
```

### 三种组件修饰符语义对照

| 修饰符 | 行为 | 内存所有权 | 典型用例 |
|--------|------|-----------|---------|
| `DefaultComponent` | **创建** 一个新组件并挂在 Actor 上 | Actor 持有 | Mesh / Light / Camera 等需要新建的组件 |
| `OverrideComponent=ParentName` | **引用** 父类已有组件 | 父类持有 | 子类要操作父类创建的 Mesh，但不重复创建 |
| `ShowOnActor`（叠加修饰）| 让 `DefaultComponent` 字段在实例 Details 面板可编辑 | （继承 DefaultComponent）| 让玩家在编辑器实例上调整组件参数 |

### 4 个附属修饰符语义

| 修饰符 | 配套修饰符 | 行为 |
|--------|-----------|------|
| `RootComponent` | `DefaultComponent` | 标记此组件成为 Actor 的 RootComponent；旧 Root 自动挂到新 Root 下 |
| `Attach=Name` | `DefaultComponent`（必须 SceneComponent）| 运行时把此组件附加到名为 `Name` 的同 Actor 组件上 |
| `AttachSocket=Name` | `DefaultComponent` + `Attach`（隐含或显式）| 附加时使用指定 socket 名称 |
| `OverrideComponent=Name` | （独立修饰符）| 引用父类名为 `Name` 的组件，不创建新实例 |

---

## 一、修饰符词法扫描

与 `UPROPERTY(` 普通流程完全相同（详见 `Syntax_UPROPERTY.md` §一）：`ParseIntoChunks` 识别 `UPROPERTY(` → `'(' / ')'` 配对计数 → `;` 触发 `FinishMacro`，最终生成 `FMacro { Type=Property, Name="MeshComp", Arguments="DefaultComponent, RootComponent" }`。

`ParseSpecifiers(Macro.Arguments)` 把 `Arguments` 切分为 `FSpecifier[]`，逐个交给 `ProcessPropertyMacro` 处理。

---

## 二、核心数据结构

### 2.1 `FAngelscriptPropertyDesc`（中间描述符）

来自 `Syntax_UPROPERTY.md` §二，组件相关字段：

```cpp
struct FAngelscriptPropertyDesc
{
    FString PropertyName;
    FString LiteralType;                    // 如 "UStaticMeshComponent"
    FAngelscriptTypeUsage PropertyType;     // 真实组件类型

    bool bInstancedReference = false;        // 组件修饰符全部置 true
    bool bBlueprintReadable  = false;
    bool bBlueprintWritable  = false;
    bool bEditableOnDefaults = false;
    bool bEditableOnInstance = false;
    bool bEditConst          = false;
    // ...

    TMap<FName, FString> Meta;              // 组件相关键全部进 Meta:
    // - "DefaultComponent" = "True"
    // - "RootComponent"    = "True"
    // - "Attach"           = "MeshComp"
    // - "AttachSocket"     = "WeaponSocket"
    // - "OverrideComponent" = "ParentMesh"
    // - "EditInlineDefaults" = "true"
    // - "EditInline"         = "true"  (ShowOnActor 触发)
};
```

### 2.2 `UASClass::FDefaultComponent`

**源码所在**：`Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator/ASClass.h:37`。

```cpp
struct FDefaultComponent
{
    UClass* ComponentClass;                 // 组件类型 (UStaticMeshComponent / UCameraComponent / ...)
    FName   ComponentName;                  // 组件 FName, 等同 CreateDefaultSubobject 第二参数
    SIZE_T  VariableOffset;                 // 在 AS 对象内存中的字节偏移 (用于把组件指针写回 AS 字段)
    bool    bIsRoot;                        // 是否标记为 RootComponent
    bool    bEditorOnly;                    // 是否在 #if EDITOR 块中 (Cooked 包不创建)
    FName   Attach;                         // Attach=XXX 的目标组件名 (NAME_None = 自动挂 Root)
    FName   AttachSocket;                   // AttachSocket=YYY
};
TArray<FDefaultComponent> DefaultComponents;
```

> **注意**：当前项目 `FDefaultComponent` **没有** `ComponentTemplate` 字段（Hazelight 某些版本会附 archetype 模板），组件初始值完全由 `default` 语句运行时赋值（详见 `Syntax_DefaultStatement.md`）。

### 2.3 `UASClass::FOverrideComponent`

```cpp
struct FOverrideComponent
{
    UClass* ComponentClass;                 // 引用的组件类型
    FName   OverrideComponentName;          // 父类中那个组件的 FName
    FName   VariableName;                   // 本类中此 AS 字段的名字
    SIZE_T  VariableOffset;                 // AS 字段偏移 (用于回填指针)
};
TArray<FOverrideComponent> OverrideComponents;
```

`OverrideComponent` 不创建新组件，而是**在运行时把父类已有组件的指针赋给本类 AS 字段**。`VariableName` 字段在最终的 `CreateDefaultComponents` 中实际不参与匹配（按 `OverrideComponentName` 在 Actor 组件列表中查找），更多是诊断与日志用途。

---

## 三、预处理器修饰符分发：`ProcessPropertyMacro`

**源码所在**：`Plugins/Angelscript/Source/AngelscriptRuntime/Preprocessor/AngelscriptPreprocessor.cpp:2550-2610` `ProcessPropertyMacro`。

### 3.1 `OverrideComponent` 分支（L2550）

```cpp
else if (Spec.Name == PP_NAME_OverrideComponent)
{
    // 完全只读: 不允许编辑、不允许蓝图访问
    PropDesc->bEditConst          = false;
    PropDesc->bEditableOnDefaults = false;
    PropDesc->bEditableOnInstance = false;
    PropDesc->bBlueprintWritable  = false;
    PropDesc->bBlueprintReadable  = false;

    // 但是 InstancedReference (UE GC 需要识别此引用以参与 Reachability 分析)
    PropDesc->bInstancedReference = true;

    // 把目标组件名记录到 Meta, 留给 FinalizeActorClass 消费
    PropDesc->Meta.Add(Spec.Name, Spec.Value);   // Meta["OverrideComponent"] = ParentName

    bIsOverrideComponent = true;
}
```

### 3.2 `DefaultComponent` 分支（L2561）

```cpp
else if (Spec.Name == PP_NAME_DefaultComponent)
{
    // 默认: 仅 OnDefaults 可编辑（CDO 阶段调整组件）
    if (!bHadShowOnActor)
    {
        PropDesc->bEditConst          = false;
        PropDesc->bEditableOnDefaults = true;
        PropDesc->bEditableOnInstance = false;
    }

    // 蓝图可读 (用于在蓝图中获取组件引用), 但禁止重新赋值
    PropDesc->bBlueprintWritable  = false;
    PropDesc->bBlueprintReadable  = true;
    PropDesc->bInstancedReference = true;
    bIsDefaultComponent = true;

    // 注释掉的: 早期版本会自动归类到 "DefaultComponents" Category
    //PropDesc->Meta.Add(PP_NAME_Category, TEXT("DefaultComponents"));

    PropDesc->Meta.Add(PP_NAME_EditInlineDefaults, TEXT("true"));
    PropDesc->Meta.Add(Spec.Name, TEXT("True"));     // Meta["DefaultComponent"] = "True"
}
```

### 3.3 `ShowOnActor` 分支（L2579）

```cpp
else if (Spec.Name == PP_NAME_ShowOnActor)
{
    bHadShowOnActor = true;
    // 让此 DefaultComponent 在每个 Actor 实例的 Details 面板可编辑
    PropDesc->bEditConst          = false;
    PropDesc->bEditableOnDefaults = true;
    PropDesc->bEditableOnInstance = true;        // (*) 关键: OnInstance 也开
    PropDesc->Meta.Add(PP_NAME_EditInline, TEXT("true"));
}
```

> **顺序敏感**：`bHadShowOnActor` 必须在 `DefaultComponent` 之前处理，否则 `DefaultComponent` 分支会强制重置 `bEditableOnInstance=false`。当前实现**不要求显式顺序**——`bHadShowOnActor` 在循环开始前已经初始化为 false，每次 `Spec` 循环单独检查；但**最佳实践**仍是 `UPROPERTY(DefaultComponent, ShowOnActor)` 这样写——更清晰。

### 3.4 `RootComponent` 分支（L2599）

```cpp
else if (Spec.Name == PP_NAME_RootComponent)
{
    bHadRootComponent = true;
    PropDesc->Meta.Add(Spec.Name, Spec.Value);    // Meta["RootComponent"] = Spec.Value（通常空字符串）
}
```

`RootComponent` 修饰符**不修改 PropDesc 字段**，只在 Meta 中留个标记。最终决定权在 `FinalizeActorClass` 中：`bIsRoot = Property->Meta.Contains(NAME_Actor_RootComponent)`。

### 3.5 `Attach` / `AttachSocket` 分支（L2604）

```cpp
else if (
    Spec.Name == PP_NAME_Attach
    || Spec.Name == PP_NAME_AttachSocket
){
    bHadAttachment = true;
    PropDesc->Meta.Add(Spec.Name, Spec.Value);   // 直接记录到 Meta
}
```

### 3.6 整体特点

| 设计点 | 说明 |
|--------|------|
| **Meta 驱动** | 6 个组件修饰符的最终去向**全部是 Meta Map**，不增加 PropDesc 的专用 bool 字段 |
| **职责分层** | 预处理器只做语义识别 + Meta 标记；真正的"创建组件"逻辑在 `FinalizeActorClass` + `CreateDefaultComponents` |
| **`OverrideComponent` 完全只读** | 5 个访问权限 bool 全部强制 false，避免用户在蓝图或编辑器误改父类组件引用 |
| **`DefaultComponent` 默认半只读** | 默认 `bBlueprintWritable=false`：蓝图可读组件引用，但不能重新赋值（防止意外 leak）|
| **`ShowOnActor` 必须配合** | 单独写 `ShowOnActor` 不会报错，但意义不大；只有与 `DefaultComponent` 联用才让"实例可编辑"生效 |

---

## 四、Analyze 早期校验（`WITH_EDITOR` 编辑器期）

**源码所在**：`AngelscriptClassGenerator.cpp:382-466`。

这一层校验在 **DoFullReloadClass 之前**执行，目的是在还没真正创建 UFunction / UClass 之前就发现错误，避免后续步骤白白跑一遍后失败。

### 4.1 `DefaultComponent` 三项校验

```cpp
if (PropertyDesc->Meta.Contains(NAME_Actor_DefaultComponent))
{
    // [校验 1] 同名组件不可在父类已存在
    UClass* CodeSuperClass = ClassData.NewClass->CodeSuperClass;
    UObject* CodeCDO = CodeSuperClass ? CodeSuperClass->GetDefaultObject() : nullptr;
    if (CodeCDO != nullptr
        && CodeCDO->GetDefaultSubobjectByName(*PropertyDesc->PropertyName) != nullptr)
    {
        ScriptCompileError(...);   // "Component with name X in class Y already exists in parent class."
        ClassData.ReloadReq = EReloadRequirement::Error;
    }

    // [校验 2] 类型必须 IsChildOf(UActorComponent)
    UClass* PropertyCodeSuper = ResolveCodeSuperForProperty(PropertyType);
    if (PropertyCodeSuper == nullptr
        || !PropertyCodeSuper->IsChildOf(UActorComponent::StaticClass()))
    {
        ScriptCompileError(...);   // "DefaultComponent ... does not derive from UActorComponent."
        ClassData.ReloadReq = EReloadRequirement::Error;
    }

    // [校验 3] Attach=Name 中的 Name 必须能在本类或继承的 CDO 中找到
    FString* AttachParentName = PropertyDesc->Meta.Find(NAME_Actor_Attach);
    if (AttachParentName != nullptr
        && PropertyCodeSuper != nullptr
        && PropertyCodeSuper->IsChildOf(USceneComponent::StaticClass()))
    {
        bool bAttachParentExists = false;

        // 先在本类的 AS 属性中找
        if (auto AttachProperty = ClassData.NewClass->GetProperty(*AttachParentName))
            bAttachParentExists = AttachProperty->Meta.Contains(NAME_Actor_DefaultComponent);

        // 然后在 C++ 父类的 CDO 中找
        if (!bAttachParentExists)
            bAttachParentExists = CodeCDO->GetDefaultSubobjectByName(**AttachParentName) != nullptr;

        if (!bAttachParentExists)
        {
            ScriptCompileError(...);   // "Attach parent X does not exist for DefaultComponent Y."
            ClassData.ReloadReq = EReloadRequirement::Error;
        }
    }
}
```

> **闭环原则**："Fail closed before swap-in"：早期校验失败立即 `ClassData.ReloadReq = EReloadRequirement::Error`，让本次模块切换被取消，已运行的旧版本继续生效。

### 4.2 `OverrideComponent` 校验：跨继承链查找

```cpp
if (PropertyDesc->Meta.Contains(NAME_Actor_OverrideComponent))
{
    UClass* PropertyCodeSuper = ResolveCodeSuperForProperty(PropertyType);
    FString* OverrideComponentName = PropertyDesc->Meta.Find(NAME_Actor_OverrideComponent);

    if (OverrideComponentName != nullptr
        && PropertyCodeSuper != nullptr
        && PropertyCodeSuper->IsChildOf(UActorComponent::StaticClass()))
    {
        bool bOverrideTargetExists = false;

        // [路径 A] 沿 AS 父类链向上找 (FAngelscriptClassDesc)
        TSharedPtr<FAngelscriptClassDesc> CheckSuperClass = AngelscriptSuperClass;
        while (CheckSuperClass.IsValid())
        {
            if (auto OverrideProperty = CheckSuperClass->GetProperty(*OverrideComponentName))
                bOverrideTargetExists = OverrideProperty->Meta.Contains(NAME_Actor_DefaultComponent);

            if (bOverrideTargetExists || CheckSuperClass->bSuperIsCodeClass) break;
            CheckSuperClass = EnsureClassAnalyzed(CheckSuperClass->SuperClass);
        }

        // [路径 B] 沿 C++ 父类链向上找 CDO 中的子对象
        if (!bOverrideTargetExists)
        {
            for (UClass* CheckCodeSuperClass = ClassData.NewClass->CodeSuperClass;
                 CheckCodeSuperClass != nullptr;
                 CheckCodeSuperClass = CheckCodeSuperClass->GetSuperClass())
            {
                // 在 CDO 中找同名 SubObject
                // ...
            }
        }

        if (!bOverrideTargetExists)
            ScriptCompileError(...);   // "OverrideComponent target ... not found in parent classes."
    }
}
```

> **跨继承链双路径**：A 路径（AS 父类链）+ B 路径（C++ 父类链）确保无论目标组件来自 AS 父类还是 C++ 父类都能找到。

---

## 五、`FinalizeActorClass` —— Meta 固化为 FDefaultComponent[]

**源码所在**：`AngelscriptClassGenerator.cpp:5199` `FinalizeActorClass`。

`Analyze` 通过后，`DoFullReloadClass` 完成普通属性创建。最后 `FinalizeActorClass` 接管 Actor 类型的特殊收尾：把 Property 的 Meta 信息**固化为 `UASClass::FDefaultComponent` / `FOverrideComponent` 描述符**，并完成所有编译期不变量校验。

### 5.1 入口设置

```cpp
void FAngelscriptClassGenerator::FinalizeActorClass(
    FModuleData& ModuleData, TSharedPtr<FAngelscriptClassDesc> ClassDesc)
{
    UASClass* ASClass = (UASClass*)ClassDesc->Class;
    check(ASClass->DefaultComponents.Num() == 0);    // 防重入断言

    // [Step 1] 关键: Actor 用专属构造函数 (替换默认 ClassConstructor)
    ClassDesc->Class->ClassConstructor = &UASClass::StaticActorConstructor;

    // [Step 2] 遍历所有属性, 按 Meta 分发到 DefaultComponents[] / OverrideComponents[]
    for (auto Property : ClassDesc->Properties)
    {
        if (Property->Meta.Contains(NAME_Actor_DefaultComponent))
            /* 走 §5.2 流程 */;
        else if (Property->Meta.Contains(NAME_Actor_OverrideComponent))
            /* 走 §5.3 流程 */;
    }
}
```

### 5.2 `DefaultComponent` 构建（L5211）

```cpp
if (Property->Meta.Contains(NAME_Actor_DefaultComponent))
{
    UASClass::FDefaultComponent Comp;
    Comp.ComponentClass  = Property->PropertyType.GetClass();
    Comp.ComponentName   = *Property->PropertyName;
    Comp.VariableOffset  = Property->ScriptPropertyOffset;
    Comp.bIsRoot         = Property->Meta.Contains(NAME_Actor_RootComponent);

#if WITH_EDITOR
    Comp.bEditorOnly = Property->Meta.Contains(NAME_Meta_EditorOnly);
#else
    Comp.bEditorOnly = false;
    ensure(!Property->Meta.Contains(NAME_Meta_EditorOnly));
    // (*) Cooked 包不应该出现 EditorOnly 组件; 出现则说明编译期未正确剥离
#endif

    // Attach 与 AttachSocket 默认 NAME_None
    FString* FoundAttach = Property->Meta.Find(NAME_Actor_Attach);
    Comp.Attach = FoundAttach ? FName(**FoundAttach) : NAME_None;

    FString* FoundSocket = Property->Meta.Find(NAME_Actor_AttachSocket);
    Comp.AttachSocket = FoundSocket ? FName(**FoundSocket) : NAME_None;

    // ===== 5 项编译期校验 =====

    // [校验 1] ComponentClass 必须 IsChildOf(UActorComponent)
    if (Comp.ComponentClass == nullptr
        || !Comp.ComponentClass->IsChildOf(UActorComponent::StaticClass()))
    {
        ScriptCompileError(...);
        ModuleData.NewModule->bModuleSwapInError = true;
        continue;
    }

    // [校验 2] 抽象类组件不可在非抽象 Actor 上创建
    if (Comp.ComponentClass->HasAnyClassFlags(CLASS_Abstract) && !ClassDesc->bAbstract)
    {
        ScriptCompileError(...);   // "component class is abstract and cannot be added"
        continue;
    }

    // [校验 3] 设置 Attach 时, ComponentClass 必须 IsChildOf(USceneComponent)
    if (Comp.Attach != NAME_None && !Comp.ComponentClass->IsChildOf(USceneComponent::StaticClass()))
        ScriptCompileError(...);   // "component attach set, but is not a type of scene component"

    // [校验 4] RootComponent 标记时也必须 IsChildOf(USceneComponent)
    if (Comp.bIsRoot && !Comp.ComponentClass->IsChildOf(USceneComponent::StaticClass()))
        ScriptCompileError(...);   // "RootComponent set, but is not a type of scene component"

#if WITH_EDITOR
    // [校验 5] 整个继承链上不能有第二个 RootComponent
    if (Comp.bIsRoot)
    {
        FString OtherRoot;
        auto* CheckClass = ASClass;
        while (CheckClass != nullptr && OtherRoot.IsEmpty())
        {
            for (auto& OtherComponent : CheckClass->DefaultComponents)
            {
                if (OtherComponent.bIsRoot)
                {
                    OtherRoot = OtherComponent.ComponentName.ToString();
                    break;
                }
            }
            CheckClass = Cast<UASClass>(CheckClass->GetSuperClass());
            if (CheckClass != nullptr) EnsureClassFinalized(CheckClass);
        }

        if (!OtherRoot.IsEmpty())
            ScriptCompileError(...);   // "is RootComponent, but the actor already has root component X"
    }
#endif

    ASClass->DefaultComponents.Add(Comp);
    ASClass->ClassFlags |= CLASS_HasInstancedReference;   // GC 标记: 此类含 InstancedReference
}
```

### 5.3 `OverrideComponent` 构建（L5311）

```cpp
else if (Property->Meta.Contains(NAME_Actor_OverrideComponent))
{
    UASClass::FOverrideComponent Comp;
    Comp.ComponentClass        = Property->PropertyType.GetClass();
    Comp.OverrideComponentName = *Property->Meta[NAME_Actor_OverrideComponent];
    Comp.VariableName          = *Property->PropertyName;
    Comp.VariableOffset        = Property->ScriptPropertyOffset;

    // [校验 1] 类型必须 IsChildOf(UActorComponent)
    if (Comp.ComponentClass == nullptr
        || !Comp.ComponentClass->IsChildOf(UActorComponent::StaticClass()))
        /* error + continue */;

    // [校验 2] 抽象类组件
    if (Comp.ComponentClass->HasAnyClassFlags(CLASS_Abstract) && !ClassDesc->bAbstract)
        /* error + continue */;

#if WITH_EDITOR
    // [校验 3] (本文 §4.2 已展开): 跨 AS / C++ 双继承链查找父类同名组件
    UClass* ClassOfOverrideComponent = nullptr;
    /* 三路查找:
       A) ParentASClass.DefaultComponents
       B) C++ Actor CDO.GetComponents()
       C) TFieldIterator 扫 CPF_InstancedReference 抽象属性 (处理父类抽象 SceneComponent 字段)
       目的: 验证 OverrideComponent="ParentMesh" 中的 ParentMesh 真的存在于继承链 */
#endif

    ASClass->OverrideComponents.Add(Comp);
}
```

### 5.4 `bModuleSwapInError` 错误传播

任一校验失败都会触发：

```cpp
ModuleData.NewModule->bModuleSwapInError = true;
```

这个标记会让模块切换在最终阶段被取消——失败的模块**不替换**当前已运行的模块，旧版本继续生效。这是热重载的"无破坏性"保证。

### 5.5 `CLASS_HasInstancedReference` 副作用

```cpp
ASClass->ClassFlags |= CLASS_HasInstancedReference;
```

这个标志告诉 UE GC：**本类含有 `Instanced` 类型的对象引用**，垃圾回收期间需要走更精细的引用追踪路径。所有持有 `DefaultComponent` 或 `OverrideComponent` 的 AS 类都会自动获得此标志。

---

## 六、运行时构造：`StaticActorConstructor` 7 步时序

**源码所在**：`Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator/ASClass.cpp` `UASClass::StaticActorConstructor`。

每次 `SpawnActor` / `NewObject<MyASActor>` 都会触发此函数：

```text
SpawnActor / NewObject<MyASActor>
        |
        v
UASClass::StaticActorConstructor(FObjectInitializer& Initializer)
    |
    +-- [Step 1] ApplyOverrideComponents(Initializer, Actor, Class)
    |     - 子类先, 父类后 (与 C++ Override 顺序一致)
    |     - 对每个 OverrideComponent 调用:
    |         Initializer.SetDefaultSubobjectClass(Override.OverrideComponentName,
    |                                              Override.ComponentClass)
    |       告诉 ObjectInitializer: 父类创建该名字的子对象时, 用我指定的类替代
    |
    +-- [Step 2] Class->CodeSuperClass->ClassConstructor(Initializer)
    |     - 调用最近的 C++ 父类构造函数 (走标准 UE 路径)
    |     - C++ 父类的 CreateDefaultSubobject 会被 Step 1 的 SetDefaultSubobjectClass 影响
    |
    +-- [Step 3] Actor->Tick 配置
    |     - PrimaryActorTick.bCanEverTick = Class->bCanEverTick
    |     - PrimaryActorTick.bStartWithTickEnabled = Class->bStartWithTickEnabled
    |
    +-- [Step 4] new(Object) asCScriptObject(ScriptType)
    |     - AS 零初始化所有 AS 字段 (含 DefaultComponent/OverrideComponent 字段, 此时全 nullptr)
    |     - bIsScriptAllocation 路径下跳过此步
    |
    +-- [Step 5] CreateDefaultComponents(Initializer, Actor, Class)        ★ 本文核心
    |     - 父类先递归
    |     - 创建本类 DefaultComponents
    |     - 内存写回 AS 属性指针
    |     - SetupAttachment / DelayedAttach
    |     - 处理 OverrideComponents 引用
    |
    +-- [Step 6] ExecuteConstructFunction(Object, Class)
    |     - 执行 AS 类的构造函数体 (脚本中的 AMyActor() {})
    |
    +-- [Step 7] ExecuteDefaultsFunctions(Object, Class)
          - 执行所有 default 语句 (详见 Syntax_DefaultStatement)
          - 此时 AS 字段中的组件指针已有效, 可以 Mesh.RelativeLocation = ...
```

### 6.1 `ApplyOverrideComponents` 详解

**源码所在**：`ASClass.cpp:1186`。

```cpp
static FORCEINLINE_DEBUGGABLE void ApplyOverrideComponents(
    const FObjectInitializer& Initializer, AActor* Actor, UASClass* ScriptClass)
{
    // (*) 关键顺序: 子类先, 父类后
    // 因为 ObjectInitializer 期望子类的 override 先注册, 才能被父类构造时识别

    for (int32 i = 0, Count = ScriptClass->OverrideComponents.Num(); i < Count; ++i)
    {
        auto& Override = ScriptClass->OverrideComponents[i];

        UClass* ComponentClass = Override.ComponentClass;
#if AS_CAN_HOTRELOAD
        // 热重载防护: 如果 ComponentClass 是 AS 类, 取最新版本
        UASClass* asClass = Cast<UASClass>(ComponentClass);
        if (asClass != nullptr)
            ComponentClass = asClass->GetMostUpToDateClass();
#endif

        // 关键: 通过 ObjectInitializer 告诉 UE
        // "父类创建名为 OverrideComponentName 的子对象时, 改用 ComponentClass 类型"
        Initializer.SetDefaultSubobjectClass(Override.OverrideComponentName, ComponentClass);
    }

    // 父类递归
    if (UASClass* ParentClass = Cast<UASClass>(ScriptClass->GetSuperClass()))
        ApplyOverrideComponents(Initializer, Actor, ParentClass);
}
```

> **注意**：此时**还没有真正创建组件**。`SetDefaultSubobjectClass` 只是告诉 `ObjectInitializer` "用这个类替代"，真正的创建发生在 Step 2 的 `CodeSuperClass->ClassConstructor` 内部（C++ 父类调用 `CreateDefaultSubobject` 时）。

### 6.2 `CreateDefaultComponents` 详解

**源码所在**：`ASClass.cpp:1212`。

```cpp
static FORCEINLINE_DEBUGGABLE void CreateDefaultComponents(
    const FObjectInitializer& Initializer, AActor* Actor, UASClass* ScriptClass)
{
    // (*) 关键顺序: 父类先, 子类后 (与 default 语句执行顺序一致)
    if (UASClass* ParentClass = Cast<UASClass>(ScriptClass->GetSuperClass()))
        CreateDefaultComponents(Initializer, Actor, ParentClass);

    // 临时缓冲: 收集需要延迟附加的 SceneComponent (Attach 目标可能尚未创建)
    TArray<TPair<USceneComponent*, int32>, TInlineAllocator<4>> DelayedComponentAttach;

    for (int32 i = 0, Count = ScriptClass->DefaultComponents.Num(); i < Count; ++i)
    {
        auto& DC = ScriptClass->DefaultComponents[i];

        UClass* ComponentClass = DC.ComponentClass;
#if AS_CAN_HOTRELOAD
        UASClass* asClass = Cast<UASClass>(ComponentClass);
        if (asClass != nullptr)
            ComponentClass = asClass->GetMostUpToDateClass();
#endif

        // [Step A] CreateDefaultSubobject (含 EditorOnly 分支)
        UActorComponent* Component;
        if (WITH_EDITOR && DC.bEditorOnly)
            Component = (UActorComponent*)Initializer.CreateEditorOnlyDefaultSubobject(
                Actor, DC.ComponentName, ComponentClass, false);
        else
            Component = (UActorComponent*)Initializer.CreateDefaultSubobject(
                Actor, DC.ComponentName, ComponentClass, ComponentClass, true, false);

        // [Step B] 抽象类组件防御
        AS_ENSURE(!ComponentClass->HasAnyClassFlags(CLASS_Abstract)
                  || Actor->GetClass()->HasAnyClassFlags(CLASS_Abstract),
            TEXT("Attempted to instantiate abstract component of type %s on non-abstract actor of type %s"),
            *ComponentClass->GetName(), *Actor->GetClass()->GetName());

        // [Step C] ★ 关键: 把组件指针写回 AS 对象内存
        // 这是 AS 脚本中 MeshComp.SetStaticMesh(...) 能正常工作的唯一前提
        UActorComponent** VariablePtr =
            (UActorComponent**)((SIZE_T)Actor + DC.VariableOffset);
        *VariablePtr = Component;

        // [Step D] SceneComponent 附加层级处理
        if (auto* SC = Cast<USceneComponent>(Component))
        {
            if (DC.bIsRoot)
            {
                // RootComponent 标记: 替换 Actor 的 Root, 旧 Root 挂到新 Root 下
                auto* PreviousRoot = Actor->GetRootComponent();
                SC->SetupAttachment(nullptr);
                Actor->SetRootComponent(SC);
                if (PreviousRoot != nullptr)
                    PreviousRoot->SetupAttachment(SC);
            }
            else if (DC.Attach == NAME_None)
            {
                // 未指定 Attach
                if (Actor->GetRootComponent() == nullptr)
                {
                    // 当前还没有 Root -> 自动成为 Root
                    SC->SetupAttachment(nullptr);
                    Actor->SetRootComponent(SC);
                }
                else
                {
                    // 已有 Root -> 自动挂到 Root 下
                    SC->SetupAttachment(Actor->GetRootComponent(), DC.AttachSocket);
                }
            }
            else
            {
                // 指定了 Attach=Name -> 延迟到所有组件创建完后再挂
                DelayedComponentAttach.Add({ SC, i });
            }
        }
    }

    // [Step E] 延迟附加: 所有组件创建完后回扫 Attach 目标
    for (auto& [SC, Idx] : DelayedComponentAttach)
    {
        auto& DC = ScriptClass->DefaultComponents[Idx];

        // 在 Actor 已有的组件中按 FName 查找 Attach 目标
        USceneComponent* AttachTo = nullptr;
        for (auto* CheckComponent : Actor->GetComponents())
        {
            if (CheckComponent->GetFName() == DC.Attach)
            {
                if (auto* CheckSC = Cast<USceneComponent>(CheckComponent))
                {
                    AttachTo = CheckSC;
                    break;
                }
            }
        }

        if (AttachTo != nullptr)
        {
            SC->SetupAttachment(AttachTo, DC.AttachSocket);
        }
        else
        {
            // 找不到目标 -> 兜底: 挂到 Root, 没有 Root 就自己成为 Root
            if (Actor->GetRootComponent() != nullptr)
                SC->SetupAttachment(Actor->GetRootComponent(), DC.AttachSocket);
            else
            {
                SC->SetupAttachment(nullptr);
                Actor->SetRootComponent(SC);
            }
        }
    }

    // [Step F] 处理 OverrideComponents: 把父类组件指针赋给本类 AS 字段
    for (int32 i = 0, Count = ScriptClass->OverrideComponents.Num(); i < Count; ++i)
    {
        auto& Override = ScriptClass->OverrideComponents[i];
        UActorComponent** VariablePtr =
            (UActorComponent**)((SIZE_T)Actor + Override.VariableOffset);

        // 在 Actor 已有的所有组件中按 OverrideComponentName 找
        for (auto* CheckComponent : Actor->GetComponents())
        {
            if (CheckComponent->GetFName() == Override.OverrideComponentName)
            {
                *VariablePtr = CheckComponent;
                break;
            }
        }
    }
}
```

### 6.3 三种附加场景速览

| `bIsRoot` | `Attach` | `AttachSocket` | 行为 |
|-----------|----------|---------------|------|
| `true` | — | — | 替换 Actor 的 RootComponent；旧 Root 挂到新 Root 下 |
| `false` | `NAME_None` | — | 若 Actor 还没有 Root → 自己成为 Root；否则挂到 Root |
| `false` | `MeshComp` | `WeaponSocket` | 立即记入 `DelayedComponentAttach`；所有组件创建完后按 FName 查找并挂 |

### 6.4 RootComponent 抢占模式的语义

注意 [Step D] 中的关键设计：

```text
新 RootComponent 出现时:
    PreviousRoot = Actor->GetRootComponent()
    新 SC 成为 Root
    PreviousRoot 不丢, 而是被挂到新 Root 下
```

这意味着 AS 脚本可以**安全地"接管"** C++ 父类已设的 Root：父类创建的 Root 不会消失，会自动成为新 Root 的子节点。这与 UE 标准 `SetRootComponent` 的行为不同（UE 会丢弃旧 Root），是 AS 插件**专门为脚本作者优化的"无破坏性 Root 升级"**。

### 6.5 与 `Syntax_DefaultStatement.md` 的衔接

```text
StaticActorConstructor 时序:
    Step 1-4: 准备阶段
    Step 5:   CreateDefaultComponents          <- 本文 §六
              (此时 AS 字段中的组件指针已有效)
    Step 6:   ExecuteConstructFunction
    Step 7:   ExecuteDefaultsFunctions         <- Syntax_DefaultStatement
              (此时可以写 default Mesh.RelativeLocation = FVector(...))
```

`UPROPERTY` 字段的"内存指针有效"发生在 Step 5，而它的 `default` 赋值发生在 Step 7——两者同处对象构造尾段，但分工明确：先完成组件实例化 + 内存写回，再用 default 语句对组件做配置。

---

## 七、完整链路 ASCII 全景

下图以三个组件属性为例展示从源码到运行调用的端到端路径：

```text
============================================================================
  组件修饰符完整生命周期: DefaultComponent + RootComponent + Attach + OverrideComponent
============================================================================

  [.as 源文件]
      UPROPERTY(DefaultComponent, RootComponent)
      UStaticMeshComponent MeshComp;

      UPROPERTY(DefaultComponent, Attach=MeshComp, AttachSocket=WeaponSocket)
      UChildActorComponent WeaponComp;

      UPROPERTY(OverrideComponent=ParentMeshComp)
      UStaticMeshComponent MeshOverride;
        |
        | [Phase 1] 预处理器: ProcessPropertyMacro 修饰符分发
        v
  [MeshComp] DefaultComponent + RootComponent
      bInstancedReference = true
      bBlueprintReadable  = true,  bBlueprintWritable = false
      bEditableOnDefaults = true,  bEditableOnInstance = false
      Meta["DefaultComponent"]   = "True"
      Meta["EditInlineDefaults"] = "true"
      Meta["RootComponent"]      = ""

  [WeaponComp] DefaultComponent + Attach + AttachSocket
      (同 MeshComp 基础设置)
      Meta["Attach"]       = "MeshComp"
      Meta["AttachSocket"] = "WeaponSocket"

  [MeshOverride] OverrideComponent=ParentMeshComp
      bInstancedReference = true
      bBlueprintReadable / bBlueprintWritable = false
      bEditableOnDefaults / bEditableOnInstance = false
      Meta["OverrideComponent"] = "ParentMeshComp"
        |
        | [Phase 2] 编辑器期 Analyze 校验 (WITH_EDITOR)
        v
  AngelscriptClassGenerator.cpp:382-466
    [DefaultComponent 校验]
      - 同名组件不可在父类已存在
      - 类型必须 IsChildOf(UActorComponent)
      - Attach=Name 中的 Name 必须能在本类或继承的 CDO 中找到
    [OverrideComponent 校验]
      - 跨 AS / C++ 双继承链查找父类同名组件
    校验失败 -> ClassData.ReloadReq = EReloadRequirement::Error -> 模块切换被取消
        |
        | [Phase 3] DoFullReloadClass 创建 FObjectProperty
        v
  AddClassProperties:
    [MeshComp / WeaponComp]
      FObjectProperty { PropertyClass = UStaticMeshComponent / UChildActorComponent }
      Flags: CPF_BlueprintVisible | CPF_InstancedReference | CPF_ExportObject
           | CPF_EditConst | CPF_Edit | CPF_DisableEditOnInstance
    [MeshOverride]
      FObjectProperty { PropertyClass = UStaticMeshComponent }
      Flags: CPF_InstancedReference | CPF_ExportObject | CPF_EditConst
      (*) 不含 CPF_BlueprintVisible / CPF_Edit -- OverrideComponent 完全只读
        |
        | [Phase 4] FinalizeActorClass 把 Meta 固化为 FDefaultComponent[]
        v
  AngelscriptClassGenerator.cpp:5199 FinalizeActorClass
    ASClass->ClassConstructor = &UASClass::StaticActorConstructor

    遍历 ClassDesc->Properties:

      [MeshComp]
        FDefaultComponent {
            ComponentClass  = UStaticMeshComponent
            ComponentName   = "MeshComp"
            VariableOffset  = ScriptPropertyOffset
            bIsRoot         = true
            bEditorOnly     = false
            Attach          = NAME_None
            AttachSocket    = NAME_None
        }
        校验: IsChildOf(USceneComponent) / 非 Abstract / Root 唯一性 (沿继承链)
        -> ASClass->DefaultComponents.Add(...)
        ASClass->ClassFlags |= CLASS_HasInstancedReference

      [WeaponComp]
        FDefaultComponent {
            ComponentName = "WeaponComp"
            Attach        = "MeshComp"        (非 NAME_None)
            AttachSocket  = "WeaponSocket"
            bIsRoot       = false
        }
        校验: IsChildOf(USceneComponent) (因为有 Attach)
        -> 运行时走 DelayedComponentAttach 路径

      [MeshOverride]
        FOverrideComponent {
            ComponentClass        = UStaticMeshComponent
            OverrideComponentName = "ParentMeshComp"
            VariableName          = "MeshOverride"
            VariableOffset        = ScriptPropertyOffset
        }
        校验: 跨继承链找到 ParentMeshComp 的真实类型
        -> ASClass->OverrideComponents.Add(...)
        |
        | [Phase 5] 运行时 SpawnActor -> StaticActorConstructor
        v
  ASClass.cpp UASClass::StaticActorConstructor(FObjectInitializer)
    [Step 1] ApplyOverrideComponents (子类先, 父类后)
        Initializer.SetDefaultSubobjectClass("ParentMeshComp", UStaticMeshComponent)
        告诉 ObjectInitializer: 父类创建 ParentMeshComp 时改用此类型

    [Step 2] CodeSuperClass->ClassConstructor(Initializer)
        C++ 父类构造 -> 内部 CreateDefaultSubobject("ParentMeshComp", ...)
        Step 1 的 SetDefaultSubobjectClass 在此生效

    [Step 3] Actor->Tick 设置 (来自 UASClass 元数据)

    [Step 4] new(Object) asCScriptObject(ScriptType)
        AS 字段零初始化, 此时 MeshComp/WeaponComp/MeshOverride 三个字段全 nullptr

    [Step 5] CreateDefaultComponents (★ 核心) 父类先递归
        [MeshComp] bIsRoot=true
          - CreateDefaultSubobject("MeshComp", UStaticMeshComponent)
          - *(VariableOffset) = Component         (★ 内存写回)
          - SetupAttachment(nullptr)
          - PreviousRoot = Actor->GetRootComponent()
          - Actor->SetRootComponent(MeshComp)
          - PreviousRoot != null ? PreviousRoot->SetupAttachment(MeshComp) : pass
            (★ 旧 Root 不丢, 自动挂到新 Root 下)

        [WeaponComp] Attach="MeshComp" 延迟附加
          - CreateDefaultSubobject("WeaponComp", UChildActorComponent)
          - *(VariableOffset) = Component         (★ 先写回引用)
          - DelayedComponentAttach.Add({WeaponComp, idx})

        [循环结束后处理 DelayedComponentAttach]
          - 遍历 Actor->GetComponents() 找 FName=="MeshComp"
          - 找到 -> WeaponComp->SetupAttachment(MeshComp, "WeaponSocket")
          - 找不到 -> 兜底挂 Root 或自己成为 Root

        [处理 OverrideComponents]
          - 遍历 Actor->GetComponents() 找 FName=="ParentMeshComp"
          - *(MeshOverride.VariableOffset) = ParentMeshComp

    [Step 6] ExecuteConstructFunction (执行 AS 构造函数体)

    [Step 7] ExecuteDefaultsFunctions (★ 此时组件指针已有效, 可执行 default 赋值)
        default Mesh.RelativeLocation = FVector(0, 0, 90);
        default WeaponComp.ChildActorClass = AMyWeapon::StaticClass();
        default MeshOverride.SetMobility(EComponentMobility::Movable);
        |
        | [Phase 6] 运行时效果
        v
  AS 脚本访问 (VariableOffset 处的指针有效):
      MeshComp.SetStaticMesh(MyMesh);
      WeaponComp.ChildActorClass = AMyWeapon::StaticClass();
      MeshOverride.SetMobility(EComponentMobility::Movable);   // 指向父类已有组件

  组件层级 (内存态):
      Actor
        +-- MeshComp (RootComponent)
            +-- WeaponComp (AttachSocket="WeaponSocket")
        +-- ParentMeshComp (来自 C++ 父类, 被 MeshOverride 引用)

  UClass 元数据:
      ASClass->DefaultComponents[]  = [{MeshComp,Root}, {WeaponComp,Attach=MeshComp}]
      ASClass->OverrideComponents[] = [{ParentMeshComp -> MeshOverride}]
      ASClass->ClassFlags |= CLASS_HasInstancedReference
```

---

## 八、修饰符速查表

### 8.1 修饰符 → PropDesc 字段 → Meta Map

```text
DefaultComponent              ->  bInstancedReference=true,
                                  bBlueprintReadable=true,  bBlueprintWritable=false,
                                  bEditableOnDefaults=true (除非 ShowOnActor 在前),
                                  bEditableOnInstance=false (除非 ShowOnActor 在前),
                                  Meta["DefaultComponent"]   = "True",
                                  Meta["EditInlineDefaults"] = "true"

RootComponent (与 DefaultComponent 联用)
                              ->  Meta["RootComponent"] = ""
                                  -> FDefaultComponent::bIsRoot = true

Attach=ComponentName          ->  Meta["Attach"] = "ComponentName"
                                  -> FDefaultComponent::Attach = FName("ComponentName")
                                     运行时延迟附加: 所有组件创建后按 FName 查找

AttachSocket=SocketName       ->  Meta["AttachSocket"] = "SocketName"
                                  -> FDefaultComponent::AttachSocket = FName("SocketName")

OverrideComponent=ParentName  ->  bInstancedReference=true,
                                  所有 5 个访问权限 = false,
                                  Meta["OverrideComponent"] = "ParentName"
                                  -> FOverrideComponent { OverrideComponentName = "ParentName" }
                                     运行时引用父类同名组件 (不创建新实例)

ShowOnActor (与 DefaultComponent 联用, 必须在 DefaultComponent 之前)
                              ->  bEditableOnInstance = true,
                                  Meta["EditInline"] = "true"
                                  让组件在每个 Actor 实例的 Details 面板可编辑
```

### 8.2 组件修饰符的"含义矩阵"

| 修饰符 | 创建新组件 | 引用已有组件 | 设为 Root | 附加到指定组件 | 实例可编辑 |
|--------|-----------|-------------|-----------|--------------|-----------|
| `DefaultComponent` | ✅ | — | — | — | — |
| `DefaultComponent + RootComponent` | ✅ | — | ✅ 抢占 | — | — |
| `DefaultComponent + Attach=X` | ✅ | — | — | ✅ 延迟 | — |
| `DefaultComponent + Attach=X + AttachSocket=Y` | ✅ | — | — | ✅ + socket | — |
| `DefaultComponent + ShowOnActor` | ✅ | — | — | — | ✅ |
| `OverrideComponent=X` | — | ✅ | — | — | — |

### 8.3 常见组合用例

```text
[最简单的 Mesh Actor]
    UPROPERTY(DefaultComponent, RootComponent)
    UStaticMeshComponent Mesh;

[Mesh + Camera (默认挂在 Mesh 下)]
    UPROPERTY(DefaultComponent, RootComponent)
    UStaticMeshComponent Mesh;

    UPROPERTY(DefaultComponent)        // 自动挂到 Mesh (因为 Mesh 是 Root)
    UCameraComponent Camera;

[Mesh + 武器 (挂在指定 socket)]
    UPROPERTY(DefaultComponent, RootComponent)
    USkeletalMeshComponent SkelMesh;

    UPROPERTY(DefaultComponent, Attach=SkelMesh, AttachSocket=hand_r_socket)
    UChildActorComponent Weapon;

[继承 C++ Actor + 替换其 Mesh 子类]
    // C++ 父类有: UStaticMeshComponent* Mesh;
    UPROPERTY(OverrideComponent=Mesh)
    UCustomStaticMeshComponent CustomMesh;        // 替换为子类版本

[继承 C++ Actor + 引用其 Mesh 操作]
    UPROPERTY(OverrideComponent=Mesh)
    UStaticMeshComponent ParentMesh;              // 引用, 不替换
```

### 8.4 关键限制速览

| 限制 | 来源 | 说明 |
|------|------|------|
| 类型必须 `IsChildOf(UActorComponent)` | `FinalizeActorClass:5237` | DefaultComponent / OverrideComponent 都强制 |
| 抽象类组件不可在非抽象 Actor 上创建 | `FinalizeActorClass:5247` | `Comp.ComponentClass->HasAnyClassFlags(CLASS_Abstract)` 检查 |
| `Attach` / `RootComponent` 必须 `IsChildOf(USceneComponent)` | `FinalizeActorClass:5257/5266` | 非 SceneComponent 没法挂层级 |
| 整个继承链上只能有一个 RootComponent | `FinalizeActorClass:5277-5305` | `WITH_EDITOR` 编辑器期校验 |
| 同名组件不可在 C++ 父类 CDO 中已存在 | `Analyze:388` | 编辑器期早期校验 |
| `Attach=Name` 中 Name 必须存在于本类或继承 CDO | `Analyze:411-432` | 编辑器期早期校验 |
| `OverrideComponent=Name` 必须找到父类同名组件 | `Analyze:443-464` + `FinalizeActorClass:5340-` | 跨 AS / C++ 双继承链查找 |
| 嵌套 `UPROPERTY()` 内不允许 | （UPROPERTY 通用约束）| 与所有 UPROPERTY 修饰符相同 |

---

## 九、设计哲学

### 9.1 为什么用 Meta 而非专用 bool 字段？

`PropDesc` 没有 `bIsDefaultComponent / bIsRootComponent / bIsOverrideComponent` 等专用 bool，全部走 Meta Map：

```text
+ 优势:
  - 修饰符增删改不需要改 PropDesc 数据结构, 只需改 ProcessPropertyMacro
  - 同一套 PropertyDesc 既服务 UPROPERTY 又服务组件特殊语义
  - Meta Map 天然可序列化到 .precompiled (无需扩展持久化结构)

- 代价:
  - FinalizeActorClass 每次都要 Meta.Contains/Find, 而非直接 if (bIsDefaultComponent)
  - 但 FinalizeActorClass 仅在类生成期跑一次, 性能可忽略
```

### 9.2 为什么 RootComponent 是"抢占模式"而非"独占模式"？

```cpp
// CreateDefaultComponents 中:
if (DC.bIsRoot)
{
    auto* PreviousRoot = Actor->GetRootComponent();   // (1) 取旧 Root
    SC->SetupAttachment(nullptr);
    Actor->SetRootComponent(SC);                       // (2) 替换为新 Root
    if (PreviousRoot != nullptr)
        PreviousRoot->SetupAttachment(SC);             // (3) ★ 旧 Root 不丢, 挂到新 Root 下
}
```

**对比 UE 标准 `SetRootComponent`**：UE 默认会丢弃旧 Root，需要用户手动处理。

**AS 插件的差异**：脚本作者通常无法控制 C++ 父类的 Root 设置（如 `AActor` 默认有 `RootComponent = SceneComponent`）。"抢占模式"让 AS 脚本可以**安全升级 Root** 而不破坏父类已建立的层级——旧 Root 自动成为新 Root 的子节点，所有挂在旧 Root 上的孩子都跟着平移。

### 9.3 为什么 Attach 必须延迟到所有组件创建后？

```cpp
// CreateDefaultComponents 中:
else
{
    // Attach=Name 的组件不立即挂, 而是放入 DelayedComponentAttach 列表
    DelayedComponentAttach.Add({ SC, i });
}

// 循环结束后:
for (auto& [SC, Idx] : DelayedComponentAttach)
{
    auto& DC = ScriptClass->DefaultComponents[Idx];
    // 此时 Actor->GetComponents() 已包含本类所有 DefaultComponent
    USceneComponent* AttachTo = ...;  // 按 FName 查找
}
```

**原因**：`UPROPERTY` 字段在类内的**声明顺序未定**（AS 不保证），如果 `WeaponComp(Attach=MeshComp)` 比 `MeshComp` 先声明，立即附加会失败。延迟到所有组件创建完后再回扫，可以容忍任意声明顺序。

### 9.4 为什么 OverrideComponent 完全只读？

```cpp
// ProcessPropertyMacro 中 OverrideComponent 分支:
PropDesc->bEditConst          = false;
PropDesc->bEditableOnDefaults = false;
PropDesc->bEditableOnInstance = false;
PropDesc->bBlueprintWritable  = false;
PropDesc->bBlueprintReadable  = false;
```

**意图**：`OverrideComponent` 是"引用父类组件"的纯输入路径，**不应该让用户在编辑器或蓝图中重新赋值**——若赋值会覆盖父类组件指针，导致父类逻辑访问错误对象。完全只读防止此类错误。

---

## 十、关键结论速查

| 主题 | 结论 |
|------|------|
| **6 个修饰符的本质** | `DefaultComponent / RootComponent / Attach / AttachSocket / OverrideComponent / ShowOnActor` 全部是 UPROPERTY 修饰符，走 `ProcessPropertyMacro` 主流程 |
| **数据传递媒介** | 全部通过 `PropDesc.Meta Map` 传递到 `FinalizeActorClass`，没有专用 PropDesc bool 字段 |
| **`DefaultComponent` 创建组件** | 在 `CreateDefaultComponents` 中调 `Initializer.CreateDefaultSubobject`，把组件指针写回 `Actor + VariableOffset` |
| **`OverrideComponent` 引用组件** | `ApplyOverrideComponents` 中调 `Initializer.SetDefaultSubobjectClass` 替换类型；`CreateDefaultComponents` 末尾按 FName 在 `Actor->GetComponents()` 中查找并写回 AS 字段 |
| **`RootComponent` 抢占模式** | 旧 Root 不丢，自动挂到新 Root 下，安全升级 Root 不破坏父类层级 |
| **`Attach=Name` 延迟附加** | 立即记入 `DelayedComponentAttach`，所有组件创建完后按 FName 查找；找不到则兜底挂 Root |
| **`AttachSocket=Name` 配套** | 必须配 `Attach`（或 `RootComponent` 隐含的 Root）；纯文本字段，运行时传给 `SetupAttachment(parent, socket)` |
| **`ShowOnActor` 含义** | 让 `DefaultComponent` 字段在每个 Actor 实例 Details 面板可编辑（默认仅 OnDefaults） |
| **核心数据结构** | `UASClass::FDefaultComponent`（7 字段）/ `UASClass::FOverrideComponent`（4 字段），位于 `ASClass.h:37/49` |
| **类生成器入口** | `FinalizeActorClass` 把 Meta 信息固化为 `FDefaultComponent[]` / `FOverrideComponent[]`，并设置 `ClassConstructor = StaticActorConstructor` |
| **运行时入口** | `StaticActorConstructor` 7 步时序：ApplyOverride → CodeSuperConstructor → Tick → asCScriptObject → CreateDefault → ConstructFunc → DefaultsFunc |
| **CLASS_HasInstancedReference** | 任一 DefaultComponent / OverrideComponent 都会让 ASClass 自动获得此标志，影响 GC 引用追踪精度 |
| **抽象组件防护** | 编译期 + 运行期双重检查（`HasAnyClassFlags(CLASS_Abstract)`），防止抽象 ActorComponent 被实例化 |
| **RootComponent 唯一性** | `WITH_EDITOR` 期沿继承链扫描所有 AS 父类的 `DefaultComponents[]`，不允许出现两个 `bIsRoot=true` |
| **`#if EDITOR` 块内组件** | 自动 `Meta["EditorOnly"]`，运行时 `bEditorOnly=true` 走 `CreateEditorOnlyDefaultSubobject`，Cooked 包不创建 |
| **错误集中点** | ① 类型非 UActorComponent → ScriptCompileError；② 抽象类在非抽象 Actor → ScriptCompileError；③ Attach/Root 非 SceneComponent → ScriptCompileError；④ 多个 RootComponent → ScriptCompileError；⑤ 同名组件已在 C++ 父类 → ScriptCompileError；⑥ Attach 目标找不到 → ScriptCompileError；⑦ OverrideComponent 找不到父类同名 → ScriptCompileError |

---

## 十一、与 Hazelight 引擎实现的差异

本文未发现当前项目相对 Hazelight 的显著差异。组件修饰符的核心机制（`FDefaultComponent` / `FOverrideComponent` / `CreateDefaultComponents` / `ApplyOverrideComponents` / `StaticActorConstructor` 7 步时序）与 Hazelight **几乎完全一致**。

唯一可能的差异点：当前项目热重载路径（`#if AS_CAN_HOTRELOAD` 块内的 `GetMostUpToDateClass()`）做了**更细粒度的处理**——只对 `Cast<UASClass>(ComponentClass)` 成功时才取最新版本，避免对 C++ 类型做无意义的 lookup。但这是优化细节而非差异。

详细差异分析风格见 `Documents/Knowledges/ZH/Diff_HazelightDefaultStatement.md` 与 `Diff_HazelightInsightsToBorrow.md`。

---

## 十二、关联文档

- 实现原理（兄弟章节）：
  - `Documents/Knowledges/ZH/Syntax_UPROPERTY.md` — UPROPERTY 修饰符（共享 `ProcessPropertyMacro` 流水线、§七.7.5 组件链路 ASCII 全景）
  - `Documents/Knowledges/ZH/Syntax_DefaultStatement.md` — `default` 语句（与本文 §六.6.5 共享对象构造时序）
  - `Documents/Knowledges/ZH/Syntax_UFUNCTION.md` — UFUNCTION 修饰符（共享 `FMacro` / `Process*Macro` 流水线）
  - `Documents/Knowledges/ZH/Syntax_DelegateEvent.md` — `delegate` / `event` 关键字
- 差异分析：
  - `Documents/Knowledges/ZH/Diff_HazelightDefaultStatement.md` — 架构性差异背景
  - `Documents/Knowledges/ZH/Diff_HazelightInsightsToBorrow.md` — Hazelight 可借鉴设计点全插件汇总
- 架构与运行时（待写）：
  - `Documents/Knowledges/ZH/Type_ClassGeneration.md` — 类生成机制（`AddClassProperties` / `FinalizeActorClass` 详细机制）
  - `Documents/Knowledges/ZH/RT_HotReload.md` — 热重载链路全景（含组件指针迁移）

---

## 十三、修订记录

| 版本 | 日期 | 内容 |
|------|------|------|
| v1.0 | 2026-04-28 | 首版：基于当前项目实际源码（`AngelscriptPreprocessor.cpp:2273-2610` / `AngelscriptClassGenerator.cpp:382-466 + 5199-5400` / `ASClass.cpp:1186-1416` / `ASClass.h:37-56`）完整产出。覆盖：① 6 个组件修饰符的语义对照与附属关系；② `FAngelscriptPropertyDesc` Meta 驱动数据流；③ `UASClass::FDefaultComponent` / `FOverrideComponent` 完整字段；④ `ProcessPropertyMacro` 修饰符分发逻辑（5 个分支 + 顺序敏感处理）；⑤ Analyze 早期校验（WITH_EDITOR 双继承链查找）；⑥ `FinalizeActorClass` 5 项编译期校验 + RootComponent 唯一性沿继承链验证；⑦ `StaticActorConstructor` 7 步时序详解；⑧ `ApplyOverrideComponents` 子类先父类后顺序与 `SetDefaultSubobjectClass` 机制；⑨ `CreateDefaultComponents` 6 步流程（含 RootComponent 抢占模式 + DelayedComponentAttach 兜底逻辑 + OverrideComponents 末尾回填）；⑩ 三种附加场景速览表 + 4 个设计哲学解析。所有 ASCII 图遵循纯 ASCII 风格（与 `Syntax_DefaultStatement.md` v1.3 / `Syntax_UPROPERTY.md` v1.3 / `Syntax_UFUNCTION.md` v1.1 / `Syntax_DelegateEvent.md` v1.0 统一）。本次未引用 Hazelight 参考文档，全程直接核对当前项目源码事实。 |

