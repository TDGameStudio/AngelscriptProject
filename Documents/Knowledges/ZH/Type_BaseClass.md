# Type_BaseClass — 脚本基类扩展策略

> **所属前缀**: Type_（类型系统与生成链路族）
> **关注层面**: 脚本类如何挂到一棵 UE C++ 反射类树上——`class AMyActor : AActor` 这一行从词法捕获、`CodeSuperClass` 解析、`UASClass::SetSuperStruct` 链接，到 `BlueprintEvent`/`BlueprintOverride` 虚函数转发的完整链路。本文不重写 `UASClass` 的字段语义（那是 `Type_ClassGeneration`），不重写 `FAngelscriptType` 的类型反查（那是 `Type_Core`），也不重写 `default Foo = X` 在 CDO 层面的具体写入流程（那是 `Syntax_DefaultStatement`）；本文聚焦的是"脚本端 `:` 之后那个名字"如何被翻译成"UE 端 `SetSuperStruct(NativeClass)`"这一件事
> **关键源码**:
> `Plugins/Angelscript/Source/AngelscriptRuntime/Preprocessor/AngelscriptPreprocessor.cpp` (~3094 行，`ResolveSuperClass` / 自动 statics 生成)
> · `Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator/AngelscriptClassGenerator.cpp` (~5932 行，`DoFullReloadClass` / `FinalizeClass` 三路分派)
> · `Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator/ASClass.cpp` (~3300 行，`StaticActorConstructor` / `StaticComponentConstructor` / `StaticObjectConstructor` / `ResolveScriptVirtual`)
> · `Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator/ASClass.h` (~555 行)
> · `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_BlueprintType.cpp` (~2700 行，`BindUClass` 把 UClass 注册成 AS 引用类型)
> · `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_BlueprintEvent.cpp` (`GetBlueprintEventByScriptName` + `BindBlueprintEvent` 反射回调)
> · `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_AActor.cpp` / `Bind_APlayerController.cpp` / `Bind_UActorComponent.cpp` / `Bind_USceneComponent.cpp`（手写 manual bind 的 4 大基类）
> **关联文档**:
> `Documents/Knowledges/ZH/Type_Core.md` — `FAngelscriptType::GetByAngelscriptTypeName` / `GetByClass` 这两条入口被 `ResolveSuperClass` 直接消费
> · `Documents/Knowledges/ZH/Type_ClassGeneration.md` — `UASClass` / `UASFunction` 字段、10 步 PerformReload 流程、三种构造器的字段级讲解
> · `Documents/Knowledges/ZH/Syntax_DefaultStatement.md` — `default SetReplicates(true)` / `default Health = 100` 在构造器中的写入位点
> · `Documents/Knowledges/ZH/Syntax_DefaultComponent.md` — `UPROPERTY(DefaultComponent)` 与基类 CDO 子对象的协作
> · `Documents/Knowledges/ZH/Arch_RuntimeLifecycle.md` — `BindScriptTypes` 阶段决定哪些 C++ 基类对脚本可见
> · `Documents/Knowledges/ZH/RT_HotReload.md` — 基类变更 / 接口列表变更如何触发 `FullReload`

---

## 概览

本文聚焦一个核心问题：**当一个 `.as` 文件写下 `class AMyActor : AActor`，插件如何识别"AActor"是一个 C++ 反射类、把它接到正确的 UE 反射类树上、让脚本类的虚函数（特别是 `BlueprintImplementableEvent` / `BlueprintNativeEvent`）能被 UE 蓝图 VM 与 C++ 调用方正确路由回到 AS 字节码？**

```text
================================================================================
  脚本基类扩展全景：从 ":" 之后那个名字到 SetSuperStruct(NativeClass)
================================================================================

[Phase 1: 预处理器扫描 .as 文本]
  ParseClass:    "class AMyActor : AActor { ... }"
                  └─ 正则捕获 group 5 = "AActor"
                  └─ ClassDesc->SuperClass = "AActor"      (字符串)
                  └─ 解析多基类逗号列表 -> ImplementedInterfaces[]
                                          (除第一项外都视作 UInterface)
       │
       ▼
[Phase 2: ResolveSuperClass —— 把字符串变成 UClass*]
  AnalyzeClasses(File, Chunk):
     ResolveSuperClass(ClassDesc):
        SuperType = FAngelscriptType::GetByAngelscriptTypeName("AActor")
                            ║
                            ║ Type_Core §三 入口
                            ▼
        UClass* Class = SuperType->GetClass(DefaultUsage)   = AActor::StaticClass()
        if (Class) {
           ClassDesc->bSuperIsCodeClass = true              ★ 是 C++ 基类
           ClassDesc->CodeSuperClass    = Class             ★ AActor 的 UClass*
        } else {
           // 走 AS-as-parent 路径，递归直到找到第一个 C++ 祖先
           Walk parent AS classes -> Supermost->CodeSuperClass
        }
       │
       ▼
[Phase 3: 自动注入静态成员]
  if (CodeSuperClass IsChildOf AActor)        + AMyActor Spawn(...)
  if (CodeSuperClass IsChildOf UActorComp)    + AMyActor Get/GetOrCreate/Create
  if (CodeSuperClass IsChildOf USubsystem)    + AMyActor Get()
       │
       ▼
[Phase 4: AS 引擎层注册]
  - 如果 bSuperIsCodeClass: 从 .as 文本中"擦掉" : AActor 整段（含逗号列表）
                           AS 编译器看到的就是裸 class AMyActor { ... }
                           AS 不知道 UE 类树存在
  - 如果 AS 父类:           保留 : ScriptParent，仅擦除 ", IXxx" 接口
       │
       ▼
[Phase 5: ClassGenerator 把脚本类挂到 UE 类树]
  CreateFullReloadClass:
    NewObject<UASClass>(GetPackage(), name)
    ScriptType->SetUserData(NewClass)        ★ asITypeInfo 反向指向 UASClass

  DoFullReloadClass:
    ParentASClass = (bSuperIsCodeClass ? nullptr : 父 UASClass)
    SuperClass    = ParentASClass ? ParentASClass : CodeSuperClass
    NewClass->SetSuperStruct(SuperClass)     ★ UE 类树挂接
    NewClass->bHasASClassParent = (ParentASClass != nullptr)
    AddClassProperties(...)                  ★ 从 SuperClass->GetPropertiesSize() 起算
    for each Method:
       UASFunction* Fn = AllocateFunctionFor(NewClass, Name, Desc)
       Fn->SetSuperStruct(ParentFunction)    ★ 关键：标记本函数 override 的是哪个父 UFunction

  FinalizeClass:
    if (NewClass IsChildOf AActor)          ClassConstructor = StaticActorConstructor
    elif (IsChildOf UActorComponent)        ClassConstructor = StaticComponentConstructor
    else                                    ClassConstructor = StaticObjectConstructor
       │
       ▼
[Phase 6: 运行时虚分派]
  C++ 端: Object->ProcessEvent(Func)
              └─ FuncMap 找到的是 UASFunction（因为 SetSuperStruct 把 override 链接好了）
              └─ UASFunctionNativeThunk -> RuntimeCallFunction
              └─ ResolveScriptVirtual(Function, Object)  ★ AS 内核 vfTable 查二级虚分派
              └─ Context->Execute()  -> 跑 AS 字节码

  AS 端: this.BeginPlay() / Super::BeginPlay()
              └─ 走 AS 字节码自己的虚函数表，跟 UE 反射无关
              └─ "调父类版本"用 Super:: 关键字（属于 AngelScript 语法层）
```

后续章节按"语法 → 解析 → 数据流 → 类树挂接 → 虚分派 → 边界"的顺序展开。一、二节回答"`:` 之后这个名字怎么变成 `UClass*`"；三、四、五节回答"挂上去之后 UE 怎么知道脚本端有哪些 override"；六、七节回答"运行时调用怎么穿过 UE 反射边界跑到 AS 字节码"；八节回答"为什么不能多重基类、`UInterface` 怎么充当"second base"、什么时候应该选脚本类还是蓝图类"。

---

## 一、脚本端语法：`class AMyActor : AActor` 的形式

### 1.1 三种合法形式

AngelScript 端的类声明在**形式上**支持四种，但语义上只有"单一基类 + 零或多个接口"是被接受的：

```angelscript
// 形式 A：继承一个 C++ 基类
class AMyActor : AActor
{
    UPROPERTY() int Health = 100;
};

// 形式 B：继承一个脚本基类
class AHealthPickup : AExamplePickupBase   // AExamplePickupBase 也是 .as 里写的
{
    default PickupValue = 25;
};

// 形式 C：继承基类 + 实现接口（多基类语法仅在第一项是真基类）
class APlayer : ACharacter, IDamageable, IInteractable
{
    UFUNCTION()
    float ApplyDamage(float Amount) override { ... }
};

// 形式 D：纯结构体，省略 ":" 隐式继承"无"
struct FPickupRecord
{
    int Quantity;
};
```

形式 A/B/C 的解析全部走预处理器同一条 `ResolveSuperClass` 路径；形式 D 走 `bIsStruct = true` 分支，**不**进 `ResolveSuperClass`（结构体没有 UE 反射父类，只对应 `UScriptStruct`，由 `Type_StructGeneration` 处理）。

### 1.2 命名前缀的硬约束

| 脚本端写的前缀 | 必须的 UE C++ 基类要求 | 否则 |
|--------------|---------------------|------|
| `A` 开头 | 解析后的 `CodeSuperClass` 必须 `IsChildOf(AActor::StaticClass())` | 编译报错（参考 `Bind_BlueprintType.cpp` 中前缀规范） |
| `U` 开头 | `IsChildOf(UObject::StaticClass())` 但**非** `AActor` | 同上 |
| `F` 开头 | 必然是 `bIsStruct = true` 路径 | 同上 |
| `E` 开头 | 必然是 `enum`，不进本文流程 | — |
| `I` 开头 | 必须是 `UInterface` 子类 | 同上 |

这条约束的执行点散落在多处（`Bind_BlueprintType.cpp::BindUClass` 决定哪些 C++ UClass 被注册为前缀 `A` / `U`、`Type_Core` 的 `TypesByAngelscriptName` 反查时也按前缀查）。前缀规范的根本目的是**让脚本端在写 `class XYZ : ...` 时，从字面就能判断 `XYZ` 是 Actor、还是普通 UObject、还是 Struct**——避免运行时再去翻 UClass 树。

### 1.3 不支持的形式

```angelscript
// ❌ 多重 C++ 基类（C++ 只允许 single inheritance for UClass，AS 跟随这个约束）
class AHybrid : AActor, ACharacter { ... };       // 错：第二个 ACharacter 会被当成接口

// ❌ 接口当主基类
class AImpl : IDamageable { ... };                 // 错：CodeSuperClass 找不到（IDamageable 是 Interface）

// ❌ 继承 UDelegateFunction / UEnum / UScriptStruct 等非可继承类型
class ABad : UFunction { ... };                    // 错：bSuperIsCodeClass=true 但 UFunction 不在合法基类白名单
```

---

## 二、`ResolveSuperClass` —— 字符串到 `UClass*` 的解析

### 2.1 预处理器先捕获字符串

```cpp
// ============================================================================
// 文件: Plugins/Angelscript/Source/AngelscriptRuntime/Preprocessor/AngelscriptPreprocessor.cpp
// 函数: FAngelscriptPreprocessor::ParseClass (节选 ~1010-1057)
// 性质: 第一阶段，仅做文本解析，不查 UClass
// ============================================================================
TSharedRef<FAngelscriptClassDesc> ClassDesc = MakeShared<FAngelscriptClassDesc>();
ClassDesc->ClassName = ClassName;

if (Chunk.Type == EChunkType::Struct)
    ClassDesc->bIsStruct = true;

// ★ 捕获 group 5 = ":" 之后第一个 token (即直接基类名)
ClassDesc->SuperClass = MatchClass.GetCaptureGroup(5);
if (ClassDesc->SuperClass.Len() == 0)
{
    if (!ClassDesc->bIsStruct)
        ClassDesc->SuperClass = TEXT("UObject");   // ★ 缺省继承 UObject
}

// ★ 解析逗号分隔的接口列表
if (Chunk.Type == EChunkType::Class)
{
    static const FRegexPattern InheritancePattern(TEXT("(class|struct)\\s+[A-Za-z0-9_]+\\s*:\\s*([^{]+)"));
    FRegexMatcher MatchInherit(InheritancePattern, Chunk.Content);
    if (MatchInherit.FindNext())
    {
        FString InheritanceClause = MatchInherit.GetCaptureGroup(2).TrimStartAndEnd();
        TArray<FString> InheritanceList;
        InheritanceClause.ParseIntoArray(InheritanceList, TEXT(","));

        // ★ 第一项是 SuperClass，剩下的全部按 UInterface 处理
        for (int32 i = 1; i < InheritanceList.Num(); ++i)
            ClassDesc->ImplementedInterfaces.Add(InheritanceList[i].TrimStartAndEnd());
    }
}
```

注意几个非显然的设计点：

- **缺省基类是 `UObject` 而非 `nullptr`**：脚本写 `class XYZ { ... }` 不写 `:`，`SuperClass` 字符串被填成 `"UObject"`，让后续 `ResolveSuperClass` 总能命中。
- **结构体不参与缺省**：`struct FXxx { ... }` 不会被填 `UObject`，因为它后面会走 `bIsStruct=true` 路径完全跳过 `CodeSuperClass`。
- **接口列表是字符串**：解析阶段没有验证 `IDamageable` 真的是 `UInterface`——这是 `FinalizeClass` 阶段 `ResolveInterfaceClass` 的活。

### 2.2 `ResolveSuperClass` 解析两种父类

```cpp
// ============================================================================
// 文件: Plugins/Angelscript/Source/AngelscriptRuntime/Preprocessor/AngelscriptPreprocessor.cpp
// 函数: FAngelscriptPreprocessor::ResolveSuperClass (节选 ~3010-3094)
// 性质: 把 "AActor" / "AExamplePickupBase" 解析为 UClass* + bSuperIsCodeClass 标志
// ============================================================================
void FAngelscriptPreprocessor::ResolveSuperClass(TSharedPtr<FAngelscriptClassDesc> ClassDesc, bool bShowError)
{
    if (ClassDesc->CodeSuperClass != nullptr)
        return;                                                  // 已解析过

    ResolvingClasses.Add(ClassDesc);
    ClassDesc->bSuperIsCodeClass = false;

    // ★ 路径 A: 父类是 C++ 类（FAngelscriptType 反查）
    auto SuperType = FAngelscriptType::GetByAngelscriptTypeName(ClassDesc->SuperClass);
    if (SuperType.IsValid())
    {
        UClass* Class = SuperType->GetClass(FAngelscriptTypeUsage::DefaultUsage);
        if (Class != nullptr)
        {
            ClassDesc->bSuperIsCodeClass = true;                 // ★ "C++ 基类" 标志
            ClassDesc->CodeSuperClass    = Class;

#if WITH_EDITOR
            // ★ CannotDeriveAngelscript meta 拦截
            if (Class->HasMetaData(CP_NAME_CannotDeriveAngelscript))
            {
                LineError(*File, ClassDesc->LineNumber, FString::Printf(
                    TEXT("Class %s cannot inherit from C++ class %s which specifies CannotDeriveAngelscript meta"),
                    *ClassDesc->ClassName, *ClassDesc->SuperClass));
                bHasError = true;
            }
#endif
        }
    }

    // ★ 路径 B: 父类是 AS 类，递归查到第一个 C++ 祖先
    if (!ClassDesc->bSuperIsCodeClass)
    {
        TSharedPtr<FAngelscriptClassDesc> SuperClassDesc = GetClassDescFor(ClassDesc->SuperClass);
        if (!SuperClassDesc.IsValid())
            SuperClassDesc = FAngelscriptEngine::Get().GetClass(ClassDesc->SuperClass);
        else if (!ResolvingClasses.Contains(SuperClassDesc))
            ResolveSuperClass(SuperClassDesc, false);            // ★ 递归

        if (SuperClassDesc.IsValid())
        {
            // ★ 沿 AS 类链向上找第一个 bSuperIsCodeClass=true 的祖先
            TSharedPtr<FAngelscriptClassDesc> Supermost = SuperClassDesc;
            while (!Supermost->bSuperIsCodeClass)
            {
                TSharedPtr<FAngelscriptClassDesc> CheckSuper = GetClassDescFor(Supermost->SuperClass);
                if (!CheckSuper.IsValid())
                    CheckSuper = FAngelscriptEngine::Get().GetClass(Supermost->SuperClass);
                if (!CheckSuper.IsValid()) break;
                else if (!ResolvingClasses.Contains(CheckSuper))
                    ResolveSuperClass(CheckSuper, false);
                Supermost = CheckSuper;
            }
            ClassDesc->CodeSuperClass = Supermost->CodeSuperClass;  // ★ 共享祖先的 C++ 基类
        }
    }

    ResolvingClasses.Remove(ClassDesc);
}
```

注意：

- **`bSuperIsCodeClass` 与 `CodeSuperClass` 都被填**：路径 A 走完，两者都被设置；路径 B 走完，只有 `CodeSuperClass` 被填（沿用最近 C++ 祖先的），`bSuperIsCodeClass` 留 `false`。
- **递归保护 `ResolvingClasses`**：防止 AS 类相互引用导致死循环（`A : B`，`B : A`——虽然这种循环本身就是错的，但解析阶段需要先稳住）。
- **`Supermost` 命名误导**：它指的不是"最顶层"，而是"沿父链上溯遇到的第一个 `bSuperIsCodeClass=true` 节点"。一旦命中就停。

### 2.3 `bSuperIsCodeClass` 与 `CodeSuperClass` 两个字段的语义

```text
                     bSuperIsCodeClass     CodeSuperClass
  -------------------+---------------------+---------------------------------
  : AActor            true                  AActor::StaticClass()
  : AExamplePickup    false                 AActor::StaticClass()  (沿用祖先)
  : UObject (隐式)    true                  UObject::StaticClass()
  : ICustom           false  + bHasError    nullptr (CodeSuperClass 无法解析)

  → bSuperIsCodeClass=true:  脚本类直接挂在 C++ 类树上
  → bSuperIsCodeClass=false: 脚本类挂在另一个脚本类下，但仍能找到最近 C++ 祖先
                            （SetSuperStruct 时使用 ParentASClass 而非 CodeSuperClass）
```

这两个字段的差异决定了 `DoFullReloadClass`（§四）使用哪个 `UClass*` 调 `SetSuperStruct`。

### 2.4 接口擦除：让 AS 编译器看不到接口列表

```cpp
// ============================================================================
// 文件: Plugins/Angelscript/Source/AngelscriptRuntime/Preprocessor/AngelscriptPreprocessor.cpp
// 函数: AnalyzeClasses (节选 ~1219-1257)
// 性质: AS 编译器不理解 UE 的 UInterface，必须把继承列表"擦干净"
// ============================================================================
if (ClassDesc->bSuperIsCodeClass)
{
    // ★ 路径 A：脚本继承 C++ 类 -> 擦掉整段 ": AActor" 含 ", IXxx, IYyy"
    static const FRegexPattern ClassPattern(TEXT("(class|struct)\\s+([A-Za-z0-9_]+)(\\s*:[^{]+)?"));
    FRegexMatcher MatchClass(ClassPattern, Chunk.Content);
    int32 InheritBeginPos = MatchClass.GetCaptureGroupBeginning(3);
    int32 InheritEndPos   = MatchClass.GetCaptureGroupEnding(3);
    if (InheritBeginPos != -1)
        for (int32 Pos = InheritBeginPos; Pos < InheritEndPos; ++Pos)
            Chunk.Content[Pos] = ' ';                            // ★ 整段空格替换
}
else if (ClassDesc->ImplementedInterfaces.Num() > 0)
{
    // ★ 路径 B：脚本继承 AS 类 -> 仅擦 ", IXxx, IYyy"，保留 ": ScriptParent"
    static const FRegexPattern InheritPattern(TEXT(
        "(class|struct)\\s+[A-Za-z0-9_]+\\s*:\\s*[A-Za-z0-9_]+(\\s*,.+?)(?=\\s*\\{)"));
    // ... 用空格替换接口部分
}
```

为什么 C++ 基类要整段擦掉？因为 **`AActor` 没有被 AS 引擎注册为可继承的 ScriptClass**——它是通过 `Bind_BlueprintType.cpp::BindUClass` 注册成 `asOBJ_REF | asOBJ_NOCOUNT | asOBJ_IMPLICIT_HANDLE` 的引用类型，不是 ScriptObject。如果留着 `: AActor`，AS 编译器会报"`AActor` is not a script class"。

而 AS 父类（路径 B）必须保留——AS 编译器需要知道"`AHealthPickup` 的字段布局是 `AExamplePickupBase` 的扩展"，否则无法生成正确的成员访问字节码。

---

## 三、自动 statics：基类决定脚本类自动生成什么

预处理器在确定 `CodeSuperClass` 后，会**根据基类的 UE 类继承关系**给脚本类**注入**一组静态函数。这是脚本端 `AMyActor::Spawn(...)` / `UMySubsystem::Get()` 这种"无声出现的方法"的来源。

```cpp
// ============================================================================
// 文件: Plugins/Angelscript/Source/AngelscriptRuntime/Preprocessor/AngelscriptPreprocessor.cpp
// 函数: AnalyzeClasses (节选 ~1260-1410)
// 性质: 基类感知的代码生成，输出到 File.GeneratedCode (会和 .as 拼接后送给 AS 编译器)
// ============================================================================
if (Chunk.Type == EChunkType::Class && ClassDesc->CodeSuperClass != nullptr)
{
    FString GeneratedStatics;
    GeneratedStatics += FString::Printf(TEXT("namespace %s%s {"), ...);

    if (ClassDesc->CodeSuperClass->IsChildOf(AActor::StaticClass()))
    {
        // ★ Actor 基类 -> 注入 Spawn 静态函数
        GeneratedStatics += FString::Printf(
            TEXT("\n %s Spawn(const FVector& Location = FVector::ZeroVector,")
            TEXT(" const FRotator& Rotation = FRotator::ZeroRotator,")
            TEXT(" const FName& Name = NAME_None, bool bDeferredSpawn = false, ULevel Level = nullptr) __generated {")
            TEXT("return Cast<%s>(SpawnActor(%s.Get(), Location, Rotation, Name, bDeferredSpawn, Level));")
            TEXT("}"),
            *ClassDesc->ClassName, *ClassDesc->ClassName, *ClassDesc->StaticClassGlobalVariableName);
    }
    else if (ClassDesc->CodeSuperClass->IsChildOf(UActorComponent::StaticClass()))
    {
        // ★ ActorComponent 基类 -> 注入 Get / GetOrCreate / Create
        GeneratedStatics += FString::Printf(TEXT("\n %s Get(const AActor Actor, FName WithName = NAME_None) __generated {..."));
        // ...
    }
    else if (ClassDesc->CodeSuperClass->IsChildOf(USubsystem::StaticClass()))
    {
        // ★ Subsystem 基类 -> 按 Engine/Editor/GameInstance/World/LocalPlayer 各自注入 Get()
        if (ClassDesc->CodeSuperClass->IsChildOf(UEngineSubsystem::StaticClass()))
            GeneratedStatics += /* return Cast<X>(USubsystemLibrary::GetEngineSubsystem(...)) */;
        else if (ClassDesc->CodeSuperClass->IsChildOf(UGameInstanceSubsystem::StaticClass()))
            /* ... GetGameInstanceSubsystem */
        // 同样有 UEditorSubsystem / UWorldSubsystem / ULocalPlayerSubsystem
    }
}
```

### 3.1 自动 statics 速查

| C++ 基类 | 注入的脚本端静态函数 | 用法 |
|---------|-------------------|------|
| `AActor` 子类 | `Spawn(Location, Rotation, Name, bDeferredSpawn, Level)` | `auto* A = AMyActor::Spawn(Loc);` |
| `UActorComponent` 子类 | `Get(Actor, Name)` / `GetOrCreate(Actor, Name)` / `Create(Actor, Name)` | `auto* C = UMyComp::Get(Actor);` |
| `UEngineSubsystem` 子类 | `Get()` | `auto* S = UMyEngineSubsystem::Get();` |
| `UEditorSubsystem` 子类（仅 WITH_EDITOR） | `Get()` | 同上 |
| `UGameInstanceSubsystem` 子类 | `Get()` | `auto* S = UMyGameSubsystem::Get();` |
| `UWorldSubsystem` 子类 | `Get()` | `auto* S = UMyWorldSubsystem::Get();` |
| `ULocalPlayerSubsystem` 子类 | `Get(LocalPlayer)` 与 `Get(PlayerController)` 双重载 | 同上 |

这些静态成员是**预处理阶段**注入的，对 AS 编译器而言它们就是 `.as` 源文件的一部分；脚本作者不能"覆盖"或"禁用"这些方法。

### 3.2 `__StaticType_<ClassName>` 全局变量

每个脚本类还会被注入一个**全局变量**：

```cpp
// 命名格式:  __StaticType_<ClassName>
// 类型:       const TSubclassOf<UObject>
// 初值:       nullptr (preprocessor 阶段)，运行时由 ClassGenerator::SetScriptStaticClass 回填
FString ClassVar = FString::Printf(TEXT("__StaticType_%s"), *ClassDesc->ClassName);
ClassDesc->StaticClassGlobalVariableName = ClassVar;
```

它是脚本端 `AMyActor::StaticClass()` / 自动 `Spawn` 的"原料"——所有需要拿到 `UClass*` 的内部代码都引用这个全局变量。`SetScriptStaticClass` 会在 `CreateFullReloadClass` 之后立即调用，把刚 `NewObject` 出来的 `UASClass*` 写进去。

---

## 四、ClassGenerator 阶段：脚本类挂到 UE 类树

### 4.1 `CreateFullReloadClass`：拿到一个空的 `UASClass`

```cpp
// ============================================================================
// 文件: Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator/AngelscriptClassGenerator.cpp
// 函数: FAngelscriptClassGenerator::CreateFullReloadClass (~2690-2733)
// 性质: 按 ClassDesc 创建一个 UASClass 实例，但还没绑定父类
// ============================================================================
void FAngelscriptClassGenerator::CreateFullReloadClass(FModuleData& ModuleData, FClassData& ClassData)
{
    auto ClassDesc = ClassData.NewClass;
    FString UnrealName = GetUnrealName(false, ClassDesc->ClassName);

    // ★ 热重载下旧类被改名为 _REPLACED_N
    UASClass* ReplacedClass = FindObject<UASClass>(FAngelscriptEngine::GetPackage(), *UnrealName);
    if (ReplacedClass)
    {
        ReplacedClass->Rename(/*Name=*/_REPLACED_N, nullptr, REN_DontCreateRedirectors);
        ReplacedClass->ClassFlags |= CLASS_NewerVersionExists;
    }

    // ★ Outer 永远是 /Script/Angelscript 包，所有脚本类共享同一 Outer
    UASClass* NewClass = NewObject<UASClass>(
        FAngelscriptEngine::GetPackage(),
        UASClass::StaticClass(),
        FName(*UnrealName),
        RF_Public | RF_Standalone | RF_MarkAsRootSet);

    // ★ asITypeInfo 反向指向 UASClass，FAngelscriptTypeUsage::FromTypeId 用得着
    asITypeInfo* ScriptType = ClassDesc->ScriptType;
    if (ScriptType != nullptr)
        ScriptType->SetUserData(NewClass);

    ClassDesc->Class = NewClass;

    // ★ 把 NewClass 写到 __StaticType_XXX 全局变量
    SetScriptStaticClass(ClassDesc, NewClass);

    // ★ Subsystem 类要在 SubsystemCollection 里挂上
    if (ClassDesc->CodeSuperClass->IsChildOf<UDynamicSubsystem>()
        || ClassDesc->CodeSuperClass->IsChildOf<UWorldSubsystem>())
    {
        if (ReplacedClass != nullptr)
            FSubsystemCollectionBase::DeactivateExternalSubsystem(ReplacedClass);
        ReinstancedSubsystems.Add(NewClass);
    }
}
```

注意此时 `NewClass->SuperStruct` 还是 `nullptr`——`SetSuperStruct` 是下一步的事。`UASClass` 创建出来已经有 `Outer = /Script/Angelscript`、有 `RF_MarkAsRootSet`（不会被 GC）、有 `RF_Standalone`（资产可见）。

### 4.2 `DoFullReloadClass`：`SetSuperStruct` 与 `bHasASClassParent`

```cpp
// ============================================================================
// 文件: Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator/AngelscriptClassGenerator.cpp
// 函数: DoFullReloadClass (~3275-3415)
// 性质: 把 NewClass 挂到 UE 类树上，并跟父类拷贝继承属性
// ============================================================================
UASClass* ParentASClass = nullptr;
UClass* ParentCodeClass = ClassDesc->CodeSuperClass;

if (!ClassDesc->bSuperIsCodeClass)
{
    // ★ AS 父类路径：拿到父 UASClass
    auto ParentDesc = GetClassDesc(ClassDesc->SuperClass);
    if (ParentDesc.IsValid() && ParentDesc->Class != nullptr)
        ParentASClass = Cast<UASClass>(ParentDesc->Class);
    else
    {
        // 从 ActiveClassesByName 取已有的（热重载未触及的父类）
        ParentASClass = Cast<UASClass>(FAngelscriptEngine::Get().GetClass(ClassDesc->SuperClass)->Class);
    }
}

UClass* SuperClass = ParentASClass ? ParentASClass : ParentCodeClass;
UASClass* NewClass = (UASClass*)ClassDesc->Class;

// ★ 基础 ClassFlags 设置：CompiledFromBlueprint 是关键
NewClass->ClassFlags  = CLASS_CompiledFromBlueprint;
NewClass->bIsScriptClass = true;
NewClass->ClassFlags |= (SuperClass->ClassFlags & CLASS_ScriptInherit);

// ★ 关键挂接
NewClass->PropertyLink = SuperClass->PropertyLink;     // 先继承父的 PropertyLink，AddClassProperties 后会扩展
NewClass->SetSuperStruct(SuperClass);                  // ← UE 类树正式挂接
NewClass->bHasASClassParent = ParentASClass != nullptr;

// ★ 编辑器元数据：让 BP 能继承 / 显示在 ClassPicker 中
NewClass->SetMetaData(TEXT("BlueprintType"),  TEXT("true"));
NewClass->SetMetaData(TEXT("IsBlueprintBase"),TEXT("true"));

NewClass->ClassWithin = UObject::StaticClass();
NewClass->Bind();                                       // ★ UClass::Bind() 完成 ClassConstructor 之外的链接

// ★ 各种 ClassFlags 透传
if (ClassDesc->bAbstract)             NewClass->ClassFlags |= CLASS_Abstract;
if (ClassDesc->bTransient)            NewClass->ClassFlags |= CLASS_Transient;
if (ClassDesc->bDefaultToInstanced)   NewClass->ClassFlags |= CLASS_DefaultToInstanced;
if (ClassDesc->bEditInlineNew)        NewClass->ClassFlags |= CLASS_EditInlineNew;
if (!ClassDesc->bPlaceable)           NewClass->ClassFlags |= CLASS_NotPlaceable;
if (ClassDesc->bIsDeprecatedClass)    NewClass->ClassFlags |= CLASS_Deprecated;

// ★ 然后再把脚本端属性叠在父类布局之上
int32 PropertiesSize = AddClassProperties(ClassDesc);
const int32 SuperClassPropertiesSize = Cast<UASClass>(SuperClass) != nullptr
    ? CastChecked<UASClass>(SuperClass)->GetContainerSize()
    : SuperClass->GetPropertiesSize();
check(PropertiesSize >= SuperClassPropertiesSize);     // ★ 必然 >= 父类大小
```

几个关键设计点：

- **`PropertyLink = SuperClass->PropertyLink` 是初始值**：表面上是"先把父类的 PropertyLink 抄过来"，但 `AddClassProperties` 会在前面 prepend 自己新增的属性，最终形成"自己的 + 父的"链。
- **`SuperClass = ParentASClass ? ParentASClass : ParentCodeClass`**：脚本继承脚本时挂到脚本父；脚本继承 C++ 时挂到 C++ 父——**不是**所有脚本类都直挂 `CodeSuperClass`。
- **`Bind()` 不是 `BindScriptTypes()`**：这里调的是 `UClass::Bind`（基础链接），跟插件的"绑定阶段"无关。
- **`PropertiesSize >= SuperClassPropertiesSize`**：脚本类的内存布局**总是父类大小+脚本字段**，不能比父类小（这是单继承下的必然结果）。

### 4.3 `UASFunction::SetSuperStruct(ParentFunction)` —— 函数级 override 链接

```cpp
// ============================================================================
// 文件: Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator/AngelscriptClassGenerator.cpp
// 函数: AddFunctionsToClass (节选 ~3420-3530)
// 性质: 每个脚本函数都生成一个 UASFunction，并通过 SetSuperStruct 链接到父类同名 UFunction
// ============================================================================
FName FunctionName(*FunctionDesc->FunctionName);
UFunction* ParentFunction = SuperClass->FindFunctionByName(FunctionName);    // ★ 父类同名查找

auto* NewFunction = UASFunction::AllocateFunctionFor(NewClass, FunctionName, FunctionDesc);
NewFunction->SetSuperStruct(ParentFunction);              // ★ 关键：标记 override 关系
NewFunction->FunctionFlags |= FUNC_Native;
NewFunction->SetNativeFunc(&UASFunctionNativeThunk);     // ★ UE 调本函数会进 thunk

// ★ FUNC_BlueprintEvent / FUNC_Net* 标志位
if (FunctionDesc->bBlueprintCallable && !FunctionDesc->bIsPrivate)
    NewFunction->FunctionFlags |= FUNC_BlueprintCallable;
if ((FunctionDesc->bBlueprintEvent && FunctionDesc->bCanOverrideEvent) || FunctionDesc->bBlueprintOverride)
    NewFunction->FunctionFlags |= FUNC_BlueprintEvent;
if (FunctionDesc->bNetMulticast)  NewFunction->FunctionFlags |= FUNC_NetMulticast;
if (FunctionDesc->bNetClient)     NewFunction->FunctionFlags |= FUNC_NetClient;
if (FunctionDesc->bNetServer)     NewFunction->FunctionFlags |= FUNC_NetServer;
// ...

if (ParentFunction)
{
    // ★ 从父函数继承访问性 / Pure / OutParms 标志
    NewFunction->FunctionFlags |= (ParentFunction->FunctionFlags
        & (FUNC_FuncInherit | FUNC_Public | FUNC_Protected | FUNC_Private
           | FUNC_BlueprintPure | FUNC_HasOutParms));
#if WITH_EDITOR
    FMetaData::CopyMetadata(ParentFunction, NewFunction);
#endif
}
```

`SetSuperStruct(ParentFunction)` 是**整个虚函数转发链最关键的一行**——它让 UE 知道"`AMyActor::BeginPlay` 的 UASFunction 重写了 `AActor::ReceiveBeginPlay` 的 UFunction"。后续 UE 走 `FuncMap` 查找 `AMyActor::ReceiveBeginPlay` 时，会走脚本类的 FuncMap 而非 `AActor` 的（因为 UE 的 `FindFunctionByName` 沿 `SuperStruct` 链查找）。

---

## 五、虚函数转发链：`BlueprintImplementableEvent` / `BlueprintNativeEvent` 的 override

### 5.1 编译期检查：`BlueprintOverride` 必须有可 override 的目标

`BlueprintOverride` 不是 AS 关键字，而是 UFUNCTION 修饰符；它**强制**该 AS 方法在父类（C++ 或 AS）必须有一个 `BlueprintEvent` 等可被覆盖的对应物。检查在 `AnalyzeClass` 里：

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/ClassGenerator/AngelscriptClassGenerator.cpp
// 函数: AnalyzeFunction (节选 ~840-940)
// 性质: BlueprintOverride 三段式回退检查：C++ event -> AS event -> 报错
// ============================================================================
if (FunctionDesc->bBlueprintOverride)
{
    FunctionDesc->OriginalFunctionName = FunctionDesc->FunctionName;

    // ★ 1) 沿 C++ 父链查 BlueprintEvent (FUNC_BlueprintEvent)
    auto* ParentFunction = GetBlueprintEventByScriptName(CodeSuperClass, FunctionDesc->FunctionName);
    if (ParentFunction != nullptr)
    {
        // 找到了——把脚本端的"BeginPlay"重命名为 UE 端实际的 "ReceiveBeginPlay"
        FunctionDesc->FunctionName = ParentFunction->GetName();
    }
    else if (AngelscriptSuperClass.IsValid())
    {
        // ★ 2) 沿 AS 父链查 BlueprintEvent
        TSharedPtr<FAngelscriptClassDesc> CheckSuperClass = AngelscriptSuperClass;
        while (CheckSuperClass.IsValid())
        {
            auto SuperFunctionDesc = CheckSuperClass->GetMethod(FunctionDesc->FunctionName);
            if (SuperFunctionDesc.IsValid()) break;
            if (!CheckSuperClass->bSuperIsCodeClass)
                CheckSuperClass = EnsureClassAnalyzed(CheckSuperClass->SuperClass);
            else break;
        }
        // 校验 SignatureMatches / 必须 bBlueprintEvent ...
    }
    else
    {
        // ★ 3) 找不到 -> 报错
        ScriptCompileError(TEXT(
            "BlueprintOverride method %s in class %s does not exist in superclass %s, "
            "or is not a BlueprintImplementableEvent or BlueprintNativeEvent in C++."));
    }
}
```

### 5.2 `GetBlueprintEventByScriptName`：脚本名 ↔ UE 函数名映射

C++ 端的 `BlueprintImplementableEvent` 经常用 `ScriptName=` meta 暴露一个简短名给蓝图（`ReceiveBeginPlay` 暴露为 `BeginPlay`）。脚本端用 `BlueprintOverride` 时，写的就是这个简短名：

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Binds/Bind_BlueprintEvent.cpp
// 函数: GetBlueprintEventByScriptName (~113-144)
// 性质: 双层缓存：先查 GBlueprintEventsByScriptName 表，miss 再扫 UFunction 字段
// ============================================================================
TMap<UClass*, TMap<FString, UFunction*>> GBlueprintEventsByScriptName;

UFunction* GetBlueprintEventByScriptName(UClass* Class, const FString& ScriptName)
{
    UClass* CheckClass = Class;
    while (CheckClass != nullptr)
    {
        // ★ 缓存命中
        auto* List = GBlueprintEventsByScriptName.Find(CheckClass);
        if (List != nullptr)
            if (auto** Function = List->Find(ScriptName))
                return *Function;

        // ★ 缓存 miss：遍历当前类（不含父）的 UFunction
        for (TFieldIterator<UFunction> FunctionIt(CheckClass, EFieldIteratorFlags::ExcludeSuper); FunctionIt; ++FunctionIt)
        {
            UFunction* Function = *FunctionIt;
            if (Function != nullptr
                && Function->HasAnyFunctionFlags(FUNC_BlueprintEvent)
                && FAngelscriptFunctionSignature::GetScriptNameForFunction(Function) == ScriptName)
            {
                GBlueprintEventsByScriptName.FindOrAdd(CheckClass).Add(ScriptName, Function);
                return Function;
            }
        }
        CheckClass = CheckClass->GetSuperClass();
    }
    return nullptr;
}
```

`FAngelscriptFunctionSignature::GetScriptNameForFunction(Function)` 优先返回 `Function->GetMetaData("ScriptName")`，否则返回 `Function->GetName()` 去掉 "Receive" 前缀。这个映射使脚本作者写：

```angelscript
class AMyActor : AActor
{
    UFUNCTION(BlueprintOverride)
    void BeginPlay() { ... }                  // ★ 脚本写 BeginPlay
                                              //   实际 override AActor::ReceiveBeginPlay
}
```

`AnalyzeFunction` 检测到 `bBlueprintOverride=true` 后，把 `FunctionDesc->FunctionName` 从 `"BeginPlay"` 改写为 `"ReceiveBeginPlay"`——这样 `SetSuperStruct(SuperClass->FindFunctionByName("ReceiveBeginPlay"))` 才能命中。

### 5.3 `BlueprintEvent` 与 `BlueprintOverride` 的差异

| 修饰符 | 用途 | 父类要求 | 生成的 FunctionFlags |
|------|------|---------|--------------------|
| `UFUNCTION()` | 普通可被脚本/蓝图调用的方法 | 父类不能有同名函数 | `FUNC_BlueprintCallable` |
| `UFUNCTION(BlueprintCallable)` | 同上但显式 | 同上 | `FUNC_BlueprintCallable` |
| `UFUNCTION(BlueprintEvent)` | **本类**新增可被子类（包括 BP 子类）覆盖的事件 | 父类不能有同名函数 | `FUNC_BlueprintEvent` |
| `UFUNCTION(BlueprintOverride)` | 覆盖父类的 `BlueprintEvent` / `BlueprintImplementableEvent` / `BlueprintNativeEvent` | 父类必须有匹配的 BlueprintEvent | `FUNC_BlueprintEvent`（继承自父） |
| 不写 `UFUNCTION` | 纯脚本方法，UE 反射不可见 | — | 不生成 UASFunction，仅存在于 AS vftable |

注意脚本端**不区分**蓝图侧的 `BlueprintImplementableEvent` 与 `BlueprintNativeEvent`：

- C++ 写 `BlueprintImplementableEvent` 表示"C++ 没有实现，BP/AS 必须实现"；
- C++ 写 `BlueprintNativeEvent` 表示"C++ 有默认实现（`_Implementation` 函数），BP/AS 可选 override"；
- AS 端两者都用 `BlueprintOverride` 写，**没有差别**——是否调到 C++ 默认实现由 UFunction VM 内核决定。

### 5.4 编译期防御：`BlueprintEvent` 不能撞父类同名

```cpp
// ============================================================================
// 函数: AnalyzeFunction (~795-836)
// 性质: BlueprintCallable / BlueprintEvent 不允许撞父类同名（除非显式 BlueprintOverride）
// ============================================================================
if ((FunctionDesc->bBlueprintCallable || FunctionDesc->bBlueprintEvent)
    && !FunctionDesc->bBlueprintOverride)
{
    UFunction* ParentFunction = CodeSuperClass->FindFunctionByName(*FunctionDesc->FunctionName);
    if (ParentFunction != nullptr)
    {
        ScriptCompileError(TEXT(
            "%s method %s in class %s already specified in superclass %s."),
            FunctionDesc->bBlueprintEvent ? TEXT("BlueprintEvent") : TEXT("BlueprintCallable"),
            ...);
    }
}
```

这条防御保证脚本端不会**意外**遮蔽（hide）父类同名 UFunction——任何想覆盖父类 UFunction 的脚本方法都必须显式写 `BlueprintOverride`。

---

## 六、运行时虚分派：UE 调到 AS 字节码

### 6.1 `UASFunctionNativeThunk` —— 唯一的"native" 入口

每个 `UASFunction` 都被设置 `FUNC_Native` 标志位，并把 `NativeFunc` 指向 `UASFunctionNativeThunk`。当 UE Blueprint VM 执行到一个 UASFunction 时，按 `FUNC_Native` 走 native call path：

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/ClassGenerator/ASClass.cpp
// 函数: UASFunctionNativeThunk (~1965-1976)
// 性质: 所有脚本函数共用的 UE→AS 入口
// ============================================================================
void UASFunctionNativeThunk(UObject* Object, FFrame& Stack, RESULT_DECL)
{
    // BP VM 通过 Generated wrapper frame 进入，但 CurrentNativeFunction 指向真实 UASFunction
    UASFunction* Function = Cast<UASFunction>(Stack.CurrentNativeFunction);
    if (Function == nullptr)
        Function = Cast<UASFunction>(Stack.Node);
    check(Function != nullptr);
    Function->RuntimeCallFunction(Object, Stack, RESULT_PARAM);
}
```

`RuntimeCallFunction` 是 `UASFunction` 的**虚方法**，被 17+ 子类（`UASFunction_NoParams` / `UASFunction_DWordArg` / ...）按签名特化。`Type_ClassGeneration §1.3` 已展开特化谱系，本文不重复。

### 6.2 `ResolveScriptVirtual` —— AS 引擎的二级虚分派

UE 通过 `SetSuperStruct` 把脚本类的 UASFunction 链接到父类 UFunction，但**实际跑哪个 AS 字节码**还取决于运行时 Object 的最具体类：

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/ClassGenerator/ASClass.cpp
// 函数: ResolveScriptVirtual (~105-122)
// 性质: 把"父类 UFunction 持有的 ScriptFunction"路由到"运行时实际类的 ScriptFunction"
// ============================================================================
FORCEINLINE static asCScriptFunction* ResolveScriptVirtual(UASFunction* Function, UObject* Object)
{
    asCScriptFunction* VirtualScriptFunction = (asCScriptFunction*)Function->ScriptFunction;
    if (VirtualScriptFunction->vfTableIdx == -1)
        return VirtualScriptFunction;                 // ★ 非虚函数直接返回

    UASClass* asClass = UASClass::GetFirstASClass(Object);
    if (asClass == nullptr) return VirtualScriptFunction;

    asCObjectType* ObjectType = (asCObjectType*)asClass->ScriptTypePtr;
    if (ObjectType == nullptr) return VirtualScriptFunction;

    // ★ 用 vfTableIdx 在运行时类的虚函数表中找最具体实现
    asCScriptFunction* RealScriptFunction = ObjectType->virtualFunctionTable[VirtualScriptFunction->vfTableIdx];
    return RealScriptFunction ? RealScriptFunction : VirtualScriptFunction;
}
```

为什么需要"二级"虚分派？UE 的虚分派靠 `FuncMap`（按 FName 查找）；但脚本类是 AS 引擎管理的，AS 引擎有自己的 `virtualFunctionTable`。**`UASFunction` 本身**只持有"脚本基类的"`asIScriptFunction*`——必须在调用时通过 `vfTableIdx` 找到"运行时类的"`asIScriptFunction*`。

例：

```text
class AParent : AActor       UASFunction("BeginPlay") -> ScriptFunction = AParent_BeginPlay (vfTableIdx=3)
class AChild : AParent       UASFunction("BeginPlay") -> ScriptFunction = AChild_BeginPlay  (vfTableIdx=3)

UE 调一个 AChild 实例的 BeginPlay:
  - FuncMap 查找 -> 命中 AChild 的 UASFunction (因为 SetSuperStruct 链接了)
  - thunk 进入 -> ResolveScriptVirtual(AChild's UASFunction, AChild instance)
  - vfTableIdx=3 -> AChild ScriptType 的 vftable[3] = AChild_BeginPlay
```

这是一个**对偶虚分派**机制——UE 反射查 `FuncMap`，AS 引擎查 `virtualFunctionTable`，两层独立但通过 `vfTableIdx` 对齐。

### 6.3 `BindBlueprintEvent` —— 反射 fallback 路径

C++ 基类的 UFunction 不一定都被 manual `Bind_AActor.cpp` 直接绑定方法（`AActor` 有数百个 UFunction，不可能全部 hand-coded）。`Bind_BlueprintEvent.cpp::BindBlueprintEvent` 通过反射构造**通用回调**，让任意 UFunction 都能被 AS 调用：

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Binds/Bind_BlueprintEvent.cpp
// 函数: BindBlueprintEvent (~648-735)
// 性质: 把任意 UFunction 注册成 AS 端可调方法，回调走通用 generic call
// ============================================================================
void BindBlueprintEvent(TSharedRef<FAngelscriptType> InType, UFunction* Function, FAngelscriptMethodBind& DBBind)
{
    // ★ 1) 构造类型化的签名 (FAngelscriptFunctionSignature)
    FAngelscriptFunctionSignature Signature;
    Signature.InitFromDB(InType, Function, DBBind, /* bInitTypes= */ true);
    if (!Signature.bAllTypesValid) return;

    // ★ 2) 把 UFunction 信息塞进一个 FBlueprintEventSignature，挂到 AS 函数 UserData
    auto* Sig = NewOwnedBlueprintEventSignature();
    Sig->FunctionName = Function->GetFName();
    Sig->UnrealFunction = Function;
    Sig->ArgCount = Signature.ArgumentTypes.Num();
    Sig->ReturnType = Signature.ReturnType;
    for (int32 i = 0; i < Sig->ArgCount; ++i)
        Sig->Arguments[i] = Signature.ArgumentTypes[i];

    // ★ 3) 注册一个 GenericCall 类型的 AS 方法，回调里用 ProcessEvent 调原 UFunction
    int32 FunctionId = FAngelscriptBinds::BindMethodDirect(InType->GetAngelscriptTypeName(),
        Signature.Declaration,
        asFUNCTION(CallEventWithSignature), asCALL_GENERIC,
        ASAutoCaller::FunctionCaller::Make(), Sig);

    // ★ 4) 缓存到 GBlueprintEventsByScriptName 供 BlueprintOverride 反查
    GBlueprintEventsByScriptName.FindOrAdd(CastChecked<UClass>(Function->GetOuter()))
                                .Add(Signature.ScriptName, Function);
}
```

`CallEventWithSignature` 在脚本调用时被 AS 引擎触发：从 `asIScriptGeneric` 取出 self + 参数，按 `FBlueprintEventSignature` 的类型描述把它们打包到 `ArgumentBuffer`，再调 `Object->ProcessEvent(Function, &ArgumentBuffer[0])`。`ProcessEvent` 内部走 UE 标准虚分派——如果脚本子类 override 了，它会走回 UASFunction（再回到 §6.1 的 thunk）。

整个机制构成一个**完整闭环**：

```text
                       脚本端 BlueprintOverride                   C++ / 蓝图调用
                              │                                       │
                              ▼                                       ▼
       UFunction 的 SetSuperStruct                  Object->ProcessEvent(Function, Parms)
              建立 UE 反射的 override 链                          │
                              │                                       │
                              ▼                                       ▼
            FAngelscriptFunctionSignature       FuncMap 查找 -> UASFunction (子类)
            Sig 与 GBlueprintEventsByScriptName              │
            建立"父 UFunction ↔ 子 UASFunction" 缓存          │
                              │                                       ▼
                              ▼                              UASFunctionNativeThunk
                   反向：脚本 BlueprintOverride 时          → ResolveScriptVirtual
                   GetBlueprintEventByScriptName            → AS Context Execute
                   给出父 UFunction（用于编译期校验）       → 跑子类 AS 字节码
```

### 6.4 数据成员的访问：父类字段的内存布局

脚本类的内存布局**总是**父类大小 + 脚本字段：

```text
SuperClass = AActor 的实例:        AActor 字段 (~448 字节)
SuperClass = AMyActor : AActor:   [AActor 字段 ~448B] [脚本字段 N B] [asCScriptObject 内部数据]

SuperClass = AChild : AMyActor:   [AActor 字段 ~448B] [AMyActor 脚本字段 N B] [AChild 脚本字段 M B]
```

`AddClassProperties` 从 `SuperClass->GetPropertiesSize()`（C++ 父）或 `SuperClass->GetContainerSize()`（脚本父）开始 offset，逐个 push 自己的字段。访问 C++ 基类 UPROPERTY 时（如 `this.Tags.Add(...)`），AS 字节码生成的内存偏移是直接读 `AActor::Tags` 的字段偏移——**不经过任何 wrapper**。

这是为什么"脚本类与 C++ 基类的成员叠加"是**零开销**的：脚本字段是 C++ 字段后面的连续内存块，没有"中间层"或"代理对象"。

---

## 七、运行时构造器分派：三路 ClassConstructor

`FinalizeClass` 根据 `NewClass` 是否 `IsChildOf(AActor)` / `IsChildOf(UActorComponent)` 选择三种构造器之一。三者共享同一个核心模式："**调 C++ 父构造器 → placement-new AS 对象 → 调 AS 构造函数**"。

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/ClassGenerator/ASClass.cpp
// 函数: StaticActorConstructor / StaticComponentConstructor / StaticObjectConstructor
// 性质: 都把"C++ 基类构造"放在最前面，确保后续 AS 字节码运行时所有 C++ 字段已就绪
// ============================================================================

// 共同模式（伪码）：
{
    UObject* Object = Initializer.GetObj();
    UASClass* Class = GetFirstASClass(Object);
    asCObjectType* ScriptType = (asCObjectType*)Class->ScriptTypePtr;

    // ★ 1) 调 C++ 基类构造（不是 SuperClass！是最近 native 祖先 CodeSuperClass）
    Class->CodeSuperClass->ClassConstructor(Initializer);

    // ★ 2) Actor: 应用 OverrideComponent；Tick 设置；CreateDefaultComponents
    //    Component: 设 Tick 设置
    //    Object: 无附加

    // ★ 3) placement-new AS ScriptObject 到 Object 内存末端
    if (!bIsScriptAllocation && ScriptType != nullptr)
        new(Object) asCScriptObject(ScriptType);

    // ★ 4) 调 AS 构造函数（运行 default 语句 + 用户构造体）
    if (!bIsScriptAllocation)
        ExecuteConstructFunction(Object, Class);
    if (bApplyDefaults && !bIsScriptAllocation)
        ExecuteDefaultsFunctions(Object, Class);
}
```

### 7.1 为什么是 `CodeSuperClass` 而不是 `GetSuperClass()`？

```text
class AParent : AActor   父 UASClass (脚本)
class AChild : AParent   子 UASClass (脚本)

构造一个 AChild 实例:
  AChild::ClassConstructor (= StaticActorConstructor) 被调
    Class = AChild (UASClass)
    Class->GetSuperClass() = AParent (UASClass)        ← 如果调这个会怎样？
    Class->CodeSuperClass  = AActor                    ← 实际调这个

  如果调 AParent::ClassConstructor 会发生什么？
  → AParent 的 ClassConstructor 也是 StaticActorConstructor
  → 它又会调 AParent->CodeSuperClass->ClassConstructor = AActor()
  → ★ AActor 构造器被调 2 次（一次给 AParent，一次给 AChild）—— 灾难
```

**所以三路构造器都直接跳到 `CodeSuperClass`**，跳过所有 AS 中间父类。AS 父类的"构造逻辑"应该在它自己的 AS 构造函数里，而不是在 ClassConstructor 里——这样 `ExecuteConstructFunction` 一次性运行从最顶 AS 父类到最底 AS 子类的所有构造函数（AS 内核处理，跟 UE 反射无关）。

### 7.2 `default` 语句与基类 CDO 的协作

```angelscript
class AMyActor : AActor
{
    UPROPERTY() float Speed = 600.0;     // ★ 脚本字段默认值，写在 AS 字节码里
    default SetReplicates(true);          // ★ 调用父类方法的"默认语句"
    default Tags.Add(n"MyTag");           // ★ 修改父类字段的"默认语句"
}
```

执行顺序：

```text
StaticActorConstructor:
  1. CodeSuperClass(=AActor) 构造           // C++ 字段 + AActor::Tags 等初始化
  2. placement-new asCScriptObject          // AS 字段全 0
  3. ExecuteConstructFunction(Object)        // AS 构造函数体：
        AS 字段默认值赋值 (Speed = 600.0)
        AS 用户构造体（如果 .as 写了显式构造）
  4. ExecuteDefaultsFunctions(Object)        // default 语句：
        SetReplicates(true)                  → 实际是 this.SetReplicates(true)
        Tags.Add(n"MyTag")                   → 实际是 this.Tags.Add(...)
```

**`default` 语句不是构造时的"字段赋值"，而是构造时的"行为调用"**——它生成一个 AS 函数 `__InitDefaults()`，在 `ExecuteDefaultsFunctions` 中被调，能调用父类的任意 UFUNCTION 或读写父类字段。详见 `Syntax_DefaultStatement.md`。

### 7.3 `DefaultComponent` 与基类 CDO 子对象冲突

脚本端写 `UPROPERTY(DefaultComponent) USphereComponent CollisionSphere;` 时，编译期检查：

```cpp
// ============================================================================
// 文件: AngelscriptClassGenerator.cpp ~387-394
// ============================================================================
UClass* CodeSuperClass = ClassData.NewClass->CodeSuperClass;
UObject* CodeCDO = CodeSuperClass != nullptr ? CodeSuperClass->GetDefaultObject() : nullptr;
if (CodeCDO != nullptr && CodeCDO->GetDefaultSubobjectByName(*PropertyDesc->PropertyName) != nullptr)
{
    ScriptCompileError(TEXT("Component with name %s in class %s already exists in parent class."), ...);
}
```

防御目的：脚本端 `UPROPERTY(DefaultComponent) UStaticMeshComponent Mesh;` 不能和 `ACharacter::Mesh`（C++ 父类已有的 DefaultSubobject）撞名——否则 `CreateDefaultSubobject` 会断言。这条规则强制脚本作者用 `OverrideComponent` 修饰符代替（见 `Syntax_DefaultComponent`）。

---

## 八、多重基类、接口与"shouldering" 边界

### 8.1 不支持多重 UClass 基类

UE 的 `UClass` 是**单继承**的（`SetSuperStruct(SuperClass)` 只能传一个）。AngelScript 跟随这个约束——`class AHybrid : AActor, ACharacter` 在解析阶段，第二个 `ACharacter` 被当作 `IInterface`，导致 `ResolveInterfaceClass` 失败报错。

要在脚本里复用多个 C++ 类的功能，正确做法是：

| 替代手段 | 适用场景 |
|--------|---------|
| **接口（UInterface）** | 类型契约（`IDamageable`、`IInteractable`） |
| **DefaultComponent** | 复用一组组件能力（`USphereComponent + UProjectileMovementComponent`） |
| **Mixin 函数库** | 复用静态行为（详见 `Type_FunctionLibrary`） |
| **Composable / `ComposeOntoClass`** | 把脚本类"贴"到一个 BP 类的 ClassConstructor 后面（仅 Hazelight fork 实验性特性） |

### 8.2 接口作为"second base"

`class AImpl : ACharacter, IDamageable, IInteractable` 中，`IDamageable` / `IInteractable` 走 `ImplementedInterfaces` 数组，最终在 `FinalizeClass` 阶段调 `NewClass->Interfaces.Add(FImplementedInterface{...})`。`PointerOffset = 0`、`bImplementedByK2 = true` —— 这是蓝图风格的接口实现，不是 C++ 多继承。

```cpp
// ============================================================================
// 文件: AngelscriptClassGenerator.cpp ~5113-5160
// 函数: AddInterfaceRecursive lambda
// 性质: 递归解析接口，包括接口的父接口
// ============================================================================
TFunction<void(UClass*)> AddInterfaceRecursive = [&](UClass* InterfaceClass)
{
    if (InterfaceClass == nullptr || InterfaceClass == UInterface::StaticClass()) return;
    if (AddedInterfaces.Contains(InterfaceClass)) return;
    AddedInterfaces.Add(InterfaceClass);

    // 父接口先加
    UClass* SuperInterface = InterfaceClass->GetSuperClass();
    if (SuperInterface != nullptr && SuperInterface->HasAnyClassFlags(CLASS_Interface))
        AddInterfaceRecursive(SuperInterface);

    for (const FImplementedInterface& ParentImpl : InterfaceClass->Interfaces)
        AddInterfaceRecursive(ParentImpl.Class);

    FImplementedInterface ImplementedInterface;
    ImplementedInterface.Class           = InterfaceClass;
    ImplementedInterface.PointerOffset   = 0;            // ★ K2-style，无 vptr 偏移
    ImplementedInterface.bImplementedByK2 = true;        // ★ 标记为蓝图风格
    NewClass->Interfaces.Add(ImplementedInterface);
};
```

接口方法的实现要求：每个 `InterfaceFunc` 都必须在脚本类中找到**同名 UFunction**（`NewClass->FindFunctionByName`），否则 `bModuleSwapInError = true`。

### 8.3 `CannotDeriveAngelscript` 元数据

C++ 端可以通过类元数据**禁止**某些 UClass 被 AS 继承：

```cpp
UCLASS(meta = (CannotDeriveAngelscript))
class UMyOpaqueBase : public UObject { ... };
```

预处理器在 `ResolveSuperClass` 中检测此 meta 并报错。常见用途：

- 包含**线程不安全字段**的类（脚本可能从任意线程调用，会破坏不变量）；
- 包含**不可序列化的非 UPROPERTY 字段**的类（脚本没法继承字段布局）；
- **C++ 编译器内部代理类**（如某些 BP-only 工具类）。

### 8.4 脚本基类 vs 蓝图基类：决策树

| 情境 | 选脚本类 | 选蓝图类 |
|------|---------|---------|
| 业务逻辑代码量大、热重载频繁 | ✅ | ❌（每次改逻辑都要重 BP 编译） |
| 需要 UI 资产、动画蒙太奇等可视化资源 | ❌（脚本不能挂资产） | ✅ |
| 需要 BP 子类继续 derive | ✅（脚本类带 `BlueprintType + IsBlueprintBase = true`） | ✅ |
| 需要从 C++ 引用具体类型（`UMyActor* P`） | ❌（脚本类只能 cooked 后引用，编译期 C++ 拿不到） | ❌（蓝图也不能在 C++ 编译期拿到） |
| 网络复制 + RPC | ✅（`Server` / `Client` / `NetMulticast` 完整支持） | ✅ |
| 有大量纯函数算法（pathfinding 等） | ✅（StaticJIT 优化） | ❌（BP VM 慢） |
| 需要 GAS Ability 集成 | ⚠️（`Bind_AAbility` 部分能力） | ✅（GAS 主流仍是 BP） |
| 需要外部模组（DLC）扩展 | ❌（脚本类是 cooked 时就固化） | ⚠️（取决于打包策略） |

**当一个 UClass 同时被 .as 与 BP 继承时**，UE 会将它们视作两个独立子类——AS 子类挂在 `/Script/Angelscript/AMyActor`，BP 子类挂在 `/Game/Blueprints/BP_MyActor`，互不影响。脚本基类生成 `IsBlueprintBase=true` 的 `UASClass`，BP 子类把它当作普通 `UClass` 父继承，BP 编辑器中也能选择脚本类作为父类。

---

## 九、当前已 manual bind 的 C++ 基类清单

`AGENTS.md` 的"Recently Completed Milestones"列出 4 大基类的 manual bind 已落地，本节给出对应的 `Bind_*.cpp` 入口与各自的特殊处理。

| C++ 基类 | manual bind 文件 | `ExistingClass` 调用次数 | 关键自定义 |
|---------|------------------|----------------------|----------|
| `AActor` | `Bind_AActor.cpp` | 1 处 | `GetComponentsByClass` 模板特化、Spawn helper |
| `APawn` | `Bind_AActor.cpp`（合并）/ 通过 `BlueprintType.ReflectionBindings` 反射 | — | 主要靠反射 fallback |
| `AController` | `Bind_AActor.cpp`（合并） | — | 同上 |
| `APlayerController` | `Bind_APlayerController.cpp` | 3 处 | `EnableInput` / `DisableInput` 等输入入口 |
| `UActorComponent` | `Bind_UActorComponent.cpp` | 4 处 | Tick / Activate 系列、`GetOwner` |
| `USceneComponent` | `Bind_USceneComponent.cpp` | 2 处 | `GetWorldTransform` / `AttachToComponent` |
| `UObject` | `Bind_UObject.cpp` | — | `Cast` 模板、UClass 比较 |
| `UWorld` | `Bind_UWorld.cpp` | — | World API 入口 |

**注**：脚本端 `class APickup : APawn` 在编译期能用——即使 `Bind_AActor.cpp` 里没有为 `APawn` 显式 `ExistingClass`。原因是：
- `Bind_BlueprintType.cpp::Bind_BlueprintType_Declarations` 阶段从 `FAngelscriptBindDatabase::Get().Classes` 自动遍历**所有**已 cooked 的 UClass，调 `BindUClass(Class, "APawn")`——把 `APawn` 注册成 AS 引用类型；
- 后续 `BlueprintType.ReflectionBindings` callback 再用反射把 `APawn` 的所有 `BlueprintCallable` / `BlueprintEvent` UFunction 通过 `BindBlueprintEvent` 路径暴露给 AS。

`ExistingClassForTarget` 是**第二轮微调**——往已注册的类上**追加**精心设计的 method（参数模板、out 参数等反射推不出来的形式）。`Bind_AActor.cpp` 的手写 surface 位于 `ManualBindings`，固定早于 `ReflectionBindings`，因此反射路径不会用反射版本覆盖手写版本。

---

## 附录 A：从 `: AActor` 到 `SetSuperStruct(AActor)` 的源码地图

| 阶段 | 源码位置 | 关键符号 |
|------|---------|---------|
| 词法捕获 | `AngelscriptPreprocessor.cpp::ParseClass` (~1010-1057) | `MatchClass.GetCaptureGroup(5)` |
| 接口列表分离 | 同上 | `ImplementedInterfaces.Add(...)` |
| 解析 SuperClass | `AngelscriptPreprocessor.cpp::ResolveSuperClass` (~3010-3094) | `bSuperIsCodeClass` / `CodeSuperClass` |
| `CannotDeriveAngelscript` 检查 | 同上 ~3029 | `Class->HasMetaData(CP_NAME_CannotDeriveAngelscript)` |
| 自动 statics 注入 | `AngelscriptPreprocessor.cpp::AnalyzeClasses` (~1260-1410) | `Spawn` / `Get` / `Get(LocalPlayer)` 等 |
| 接口擦除 | 同上 (~1219-1257) | `Chunk.Content[Pos] = ' '` |
| `BindScriptTypes` 阶段注册 UClass | `Bind_BlueprintType.cpp::BindUClass` (~691-717) | `MakeShared<FUObjectType>(Class, TypeName)` |
| `Bind_*.cpp` 手写方法 | `Bind_AActor.cpp` / `Bind_APlayerController.cpp` / ... | `FAngelscriptBinds::ExistingClass` |
| 反射 fallback 注册 | `Bind_BlueprintType.cpp::BindBlueprintTypeReflectionBindings` | `BindBlueprintEvent` / `BindBlueprintCallable` |
| 命名缓存 | `Bind_BlueprintEvent.cpp::GetBlueprintEventByScriptName` (~113-144) | `GBlueprintEventsByScriptName` |
| 创建 `UASClass` | `AngelscriptClassGenerator.cpp::CreateFullReloadClass` (~2690-2733) | `NewObject<UASClass>(...) + ScriptType->SetUserData(NewClass)` |
| `SetSuperStruct` 挂接 | `AngelscriptClassGenerator.cpp::DoFullReloadClass` (~3275-3415) | `NewClass->SetSuperStruct(SuperClass)` |
| `bHasASClassParent` 标志 | 同上 ~3405 | `NewClass->bHasASClassParent = ParentASClass != nullptr` |
| `UASFunction` 函数级 override | `AngelscriptClassGenerator.cpp::AddFunctionsToClass` (~3420-3530) | `NewFunction->SetSuperStruct(ParentFunction)` |
| `BlueprintOverride` 校验 | `AngelscriptClassGenerator.cpp::AnalyzeFunction` (~840-940) | `GetBlueprintEventByScriptName(CodeSuperClass, ...)` |
| `FinalizeClass` 三路分派 | `AngelscriptClassGenerator.cpp::FinalizeClass` (~5191-5197) | `if IsChildOf(AActor)` / `IsChildOf(UActorComponent)` |
| `ClassConstructor` 设置 | 同上 + `FinalizeActorClass` / `FinalizeComponentClass` / `FinalizeObjectClass` | `ClassConstructor = StaticActorConstructor` |
| 接口 Interfaces 数组填充 | `AngelscriptClassGenerator.cpp::FinalizeClass` (~5061-5189) | `NewClass->Interfaces.Add(FImplementedInterface{...})` |
| 三路构造器 | `ASClass.cpp::StaticActorConstructor` (~1375) / `StaticComponentConstructor` (~1434) / `StaticObjectConstructor` (~1487) | `Class->CodeSuperClass->ClassConstructor(Initializer)` |
| 二级虚分派 | `ASClass.cpp::ResolveScriptVirtual` (~105-122) | `ObjectType->virtualFunctionTable[vfTableIdx]` |
| UE→AS 入口 | `ASClass.cpp::UASFunctionNativeThunk` (~1965-1976) | `Function->RuntimeCallFunction(Object, Stack, ...)` |

---

## 附录 B：常见错误与诊断速查

| 现象 / 报错 | 第一时间检查 | 第二时间检查 |
|----------|-----------|-----------|
| `Class %s has an unknown super type %s.` | `ClassDesc->SuperClass` 字符串与 `FAngelscriptType::GetByAngelscriptTypeName` 反查 | `Bind_BlueprintType.cpp` 是否注册了该 UClass、`AS_FORCE_LINK` 是否生效 |
| `Class %s cannot inherit from C++ class %s which specifies CannotDeriveAngelscript meta` | C++ 端类的 `meta = (CannotDeriveAngelscript)` 是否故意 | 如果不是故意要禁，去 C++ 头里删 meta |
| `BlueprintOverride method %s does not exist in superclass` | 父类有没有用 `BlueprintImplementableEvent` / `BlueprintNativeEvent` / `BlueprintEvent` 标记同名方法 | `GetScriptNameForFunction` 的 `ScriptName` meta 是否对得上 |
| `BlueprintEvent method %s already specified in superclass` | 误把覆盖父类事件的方法写成了 `BlueprintEvent`（应改 `BlueprintOverride`） | — |
| `Method %s in parent class is not a BlueprintImplementableEvent or BlueprintNativeEvent` | 父类同名方法是 `BlueprintCallable` 或 native 函数，不可被 override | 改名或在父类加 `BlueprintEvent` |
| 脚本类继承后 UE 蓝图编辑器**找不到**该类 | `NewClass->ClassFlags` 是否漏 `CLASS_NotPlaceable`；`SetMetaData("BlueprintType", "true")` 是否被脚本端 meta 覆盖 | `bAbstract = true` 的脚本类不会出现在 ClassPicker |
| 脚本类 SpawnActor 时 C++ 父类成员未初始化 | `StaticActorConstructor` 是否调到 `Class->CodeSuperClass->ClassConstructor`（应该会，除非 `bIsScriptAllocation` 路径） | 检查 `CodeSuperClass` 是不是被错误填成 AS 父类 |
| `AChild::BeginPlay` 被调时跑的是父类版本 | `vfTableIdx` 是否被 AS 编译器分配（脚本端方法签名是否完全一致） | `GetFirstASClass(Object)->ScriptTypePtr` 是否指向 AChild 的 asITypeInfo |
| 同一 UClass 被 `Register` 多次 | 多个 `Bind_*.cpp` 是否声明同名 | fork 残留的 `BindUClass` 重复调用 |
| 脚本类继承的 `DefaultComponent` 与父类同名 | `CodeSuperClass->GetDefaultObject()->GetDefaultSubobjectByName` 命中 | 改用 `OverrideComponent = "ParentSubobjectName"` 而非 DefaultComponent |
| 接口方法未实现报错 | 脚本类是否提供同名 UFUNCTION（**注意签名要完全匹配 InterfaceFunc**） | `bImplementedByK2 = true` 模式不要求 PointerOffset，但要求 FuncMap 命中 |

---

## 小结

- **"`:` 之后那个名字"**有两种归宿：C++ UClass（走 `bSuperIsCodeClass=true` + `CodeSuperClass` 双填）或 AS UASClass（走 `bSuperIsCodeClass=false` + 沿父链溯第一个 C++ 祖先填 `CodeSuperClass`）。后续整个流程对二者只在"`SetSuperStruct(ParentASClass ? ParentASClass : CodeSuperClass)`"这一步上分支；其余字段（属性布局、虚函数表、Interfaces）共用同一条流水。
- **多基类语法不存在于 UClass 单继承约束之下**：脚本端的逗号分隔列表，第一个是真基类，其余全部当作 `UInterface`。`UInterface` 走 `bImplementedByK2=true` 模式，本质是一个"契约 + FuncMap 强制存在"，不是 C++ 多继承的 vptr 偏移。
- **`BlueprintOverride` 是脚本端唯一的"显式覆盖" UFUNCTION 修饰符**：编译期通过 `GetBlueprintEventByScriptName` 沿 C++ 父链 / AS 父链双向查找，命中后把脚本端的 `BeginPlay` 重命名为 UE 端的 `ReceiveBeginPlay`，再走 `SetSuperStruct(ParentFunction)` 完成 UFunction 级 override。
- **虚函数转发是双层的**：UE 反射层走 `FuncMap` 与 `SuperStruct` 链找到 `UASFunction`；`UASFunctionNativeThunk` 进入后再用 `ResolveScriptVirtual(vfTableIdx)` 在 AS 引擎的 `virtualFunctionTable` 中找到运行时类的 `asIScriptFunction*`。两层用 `vfTableIdx` 对齐，缺一不可。
- **三种构造器都跳到 `CodeSuperClass`**：避免脚本父链上的每个中间类都把 C++ 基类构造器多调一次。AS 父类自身的"构造逻辑"由 `asCScriptObject` 的内核管理，跟 UE 反射无关。
- **`Bind_AActor` / `Bind_APlayerController` / `Bind_UActorComponent` / `Bind_USceneComponent` 是 4 大手工绑定的核心**，但**不是**继承能用的全部基础——`Bind_BlueprintType.cpp` 在 `Bind_BlueprintType_Declarations` 阶段已把所有 cooked UClass 反射注册成 AS 类型，手写文件只追加反射推不出来的方法（参数模板、`out` 形参、`?` 通用参数等）。
- **数据成员叠加是零开销**：脚本类的内存布局是 C++ 父类大小 + 脚本字段连续追加，访问 `this.Tags` 直接读 `AActor::Tags` 字段偏移，无 wrapper、无代理。
- **本文边界**：本文不重复 `Type_ClassGeneration` 的 10 步流程、不重复 `Type_Core` 的类型反查表设计、不重复 `Syntax_DefaultStatement` 的默认语句执行细节、不重复 `RT_HotReload` 的 SoftReload/FullReload 决策——本文只回答"基类怎么从字符串变成 UClass、虚函数怎么从 AS 字节码穿透回 UE 反射"两个核心问题。

---

## 修订记录

| 版本 | 日期 | 内容 |
|------|------|------|
| v1.0 | 2026-05-22 | 首版：基于 `AngelscriptPreprocessor.cpp::ParseClass`/`ResolveSuperClass`/`AnalyzeClasses` (~1010-3094 行) / `AngelscriptClassGenerator.cpp::CreateFullReloadClass`/`DoFullReloadClass`/`AnalyzeFunction`/`FinalizeClass` (~840-5189 行) / `ASClass.cpp::StaticActorConstructor`/`StaticComponentConstructor`/`StaticObjectConstructor`/`ResolveScriptVirtual`/`UASFunctionNativeThunk` (~105-1976 行) / `Bind_BlueprintType.cpp::BindUClass`/`Bind_Defaults` / `Bind_BlueprintEvent.cpp::GetBlueprintEventByScriptName`/`BindBlueprintEvent` / `Bind_AActor.cpp` / `Bind_APlayerController.cpp` / `Bind_UActorComponent.cpp` / `Bind_USceneComponent.cpp` 完整产出。覆盖：① 脚本基类的三种合法形式 + 命名前缀硬约束 + 不支持形式；② 预处理器两阶段解析（词法捕获 group 5 -> ResolveSuperClass 路径 A/B）+ `bSuperIsCodeClass`/`CodeSuperClass` 字段语义；③ 自动 statics 注入：Actor 的 Spawn、Component 的 Get/GetOrCreate/Create、5 类 Subsystem 的 Get + `__StaticType_*` 全局变量；④ ClassGenerator 阶段：`CreateFullReloadClass` 拿 NewObject + SetUserData，`DoFullReloadClass` 的 SuperClass 选择（ParentASClass 优先 CodeSuperClass）+ `SetSuperStruct` + ClassFlags 透传 + `PropertyLink` 链表初始化、`UASFunction::SetSuperStruct(ParentFunction)` 函数级 override 链接；⑤ 虚函数转发链：编译期 BlueprintOverride 三段回退（C++ event -> AS event -> 报错）+ `GetBlueprintEventByScriptName` 双层缓存 + `BlueprintEvent`/`BlueprintOverride` 行为差异表 + 编译期防御不允许 BlueprintCallable/BlueprintEvent 撞父类同名；⑥ 运行时虚分派：`UASFunctionNativeThunk` 唯一入口 + `ResolveScriptVirtual` 通过 `vfTableIdx` 查 AS `virtualFunctionTable` 完成二级虚分派 + `BindBlueprintEvent` 反射 fallback 通过 `ProcessEvent` 闭环 + 内存布局零开销叠加；⑦ 三路 ClassConstructor 共享"调 CodeSuperClass→placement-new asCScriptObject→ExecuteConstruct/DefaultsFunctions"模式 + 为何用 `CodeSuperClass` 而非 `GetSuperClass()`（避免 C++ 基类构造器多次调用）+ `default` 语句与基类 CDO 协作 + `DefaultComponent` 与父类 CDO 子对象冲突防御；⑧ 多重基类策略：UClass 单继承约束 + `IInterface` 作"second base" 走 `bImplementedByK2=true`+`PointerOffset=0` + `CannotDeriveAngelscript` meta 拦截 + 脚本类 vs 蓝图类决策树；⑨ 当前已 manual bind 的 4 大基类清单（AActor/APlayerController/UActorComponent/USceneComponent）+ 手写 vs 反射 fallback 的边界（`ExistingClass` 在 `EOrder::Late-1`，反射在 `EOrder::Late+100`）；⑩ 附录 A 17 行源码地图速查表 + 附录 B 11 条常见错误诊断起点。 |
