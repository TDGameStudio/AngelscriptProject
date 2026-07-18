# Type_Core — 类型系统核心

> **所属前缀**: Type_（类型系统与生成链路族）
> **关注层面**: AngelScript 运行时类型对象（`asITypeInfo` / `asCObjectType` / `asCEnumType`）与 UE 反射对象（`UClass` / `UScriptStruct` / `UEnum` / `FProperty` / `UFunction`）之间的双向映射数据库——不深入"脚本侧 class 怎么变成 UClass"（那是 `Type_ClassGeneration`），也不深入"哪一份 `Bind_*.cpp` 怎么写"（那是 `Type_BindSystem`）；本文是这两件事共同依赖的**底层桥接层**
> **关键源码**:
> `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptType.h` (~752 行，`FAngelscriptType` / `FAngelscriptTypeUsage` / `FAngelscriptTypeDatabase` 三主角)
> · `Core/AngelscriptType.cpp` (~836 行，`GetTypeDatabase` / `Register` / `FromXxx` 工厂)
> · `Core/AngelscriptBindDatabase.h` / `.cpp` (~136 / ~212 行，cooked 路径的 `FAngelscriptBindDatabase`)
> · `Core/AngelscriptBinds.h` / `.cpp` (~714 / ~894 行，`FAngelscriptBinds::ReferenceClass / ValueClass` 入口)
> · `Binds/Bind_UStruct.cpp` (~1228 行，`FUStructType` 是 UStruct 子类的范例)
> · `Binds/Bind_BlueprintType.cpp` (~2700+ 行，`FUObjectType` / `FObjectPtrType` / `FWeakObjectPtrType` / `FSubclassOfType`)
> · `Binds/Bind_UEnum.cpp` (~588 行，`FEnumType` + script enum 注册)
> · `Binds/Bind_TArray.cpp` (~1830 行，`TArray<T>` 模板注册)
> · `Binds/Helper_PODType.h` / `Helper_CppType.h` (~80 / ~50 行，类型基类模板)
> **关联文档**:
> `Documents/Knowledges/ZH/Type_ClassGeneration.md` — 脚本类生成（消费 `FAngelscriptType` 完成 `UASClass` 链路）
> · `Documents/Knowledges/ZH/Type_StructGeneration.md` — 脚本结构体生成（同上，消费 `FAngelscriptTypeUsage::FromProperty`）
> · `Documents/Knowledges/ZH/Type_BindSystem.md` — `Bind_*.cpp` 注册框架（在 `FAngelscriptType` 之上的"应用层"）
> · `Documents/Knowledges/ZH/AS_TypeRegistration.md` — AS 内核 `RegisterObjectType` 实现细节
> · `Documents/Knowledges/ZH/AS_ScriptEngine.md` — `asCScriptEngine` 内部注册表布局
> · `Documents/Knowledges/ZH/Arch_Overview.md` — 术语对照表（附录 B）

---

## 概览

本文聚焦一个核心问题：**插件如何把 AngelScript 类型与 UE 反射类型建立双向映射、维护类型对象生命周期、并暴露足够细粒度的类型操作（创建 `FProperty` / `SetArgument` / `EmitReferenceInfo` / `GetHash` / ...）来支撑后续 ClassGeneration、StructGeneration、BindSystem 等子模块？**

```text
================================================================================
  类型系统核心：双向映射的三层结构
================================================================================

[AS 内核侧]                  [插件桥接层 — 本文焦点]                [UE 反射侧]
                                                                       
asITypeInfo*           ┌──────────────────────────┐           UClass*
 (asCObjectType)       │                          │            (UASClass / UClass)
asCEnumType            │   FAngelscriptType        │           UScriptStruct*
asCDataType            │   ─────────────────       │            (UASStruct / UScriptStruct)
asCObjectProperty      │   • 抽象基类: 30+ 虚方法 │           UEnum*
asIScriptFunction      │   • 子类: FUObjectType /  │           UDelegateFunction*
                       │           FUStructType /  │           
                       │           FEnumType /     │           FProperty 家族:
                       │           FObjectPtrType /│            FBoolProperty
                       │           FSubclassOfType │            FIntProperty
                       │           ... 50+ 个      │            FFloatProperty
                       │                          │            FStrProperty
                       │   FAngelscriptTypeUsage   │            FObjectProperty
                       │   ─────────────────────   │            FStructProperty
                       │   • 类型 + 修饰符快照    │            FEnumProperty
                       │   • SubTypes (模板递归)  │            FArrayProperty
                       │   • bIsRef / bIsConst    │            FMapProperty
                       │   • ScriptClass 联合体   │            FSoftObjectProperty
                       │                          │            FClassProperty
                       │   FAngelscriptTypeDatabase│            FInterfaceProperty
                       │   ──────────────────────  │            FDelegateProperty
                       │   • RegisteredTypes[]     │            FMulticastInlineDelegateProperty
                       │   • TypesByAngelscriptName│            ...
                       │   • TypesByClass          │           
                       │   • TypesByData           │           UFunction
                       │   • TypeFinders[]         │            (UASFunction)
                       │   • Script* 6 个泛型槽   │           
                       │   • ArrayTemplateTypeInfo │           
                       └──────────┬───────────────┘           
                                  │                            
                                  │ 由 FAngelscriptEngine 拥有 │
                                  │ TUniquePtr<...> TypeDatabase
                                  │ 一引擎实例一份数据库      
                                  │ (PIE 多引擎下不共享)      
                                  ▼                            
                       ┌──────────────────────────┐           
                       │ FAngelscriptBindDatabase  │  cooked 时:    
                       │  Structs / Classes /      │  Script/Binds.Cache
                       │  BoundEnums /             │  (FStructBind /     
                       │  BoundDelegateFunctions   │   FClassBind /      
                       │                          │   FMethodBind /     
                       │ → 编辑器期生成,           │   FPropertyBind 序列化)
                       │   cooked 期反序列化重放   │           
                       └──────────────────────────┘           
```

后续章节按"数据模型 → 注册管线 → 类型查询 → 子类设计 → 容器与模板 → 边界与协作"的顺序展开。前四节读完即可回答"我手上拿到一个 `FProperty*` 怎么找到它对应的 AS 类型"和"我手上拿到一个 `asITypeInfo*` 怎么找到它对应的 UE 类型"两个核心问题；后两节回答"为什么 `TArray<T>` 是模板而不是 N 个具体类型"和"本文与 `Type_ClassGeneration` / `Type_BindSystem` 的边界在哪"。

---

## 一、三个主角：`FAngelscriptType` / `FAngelscriptTypeUsage` / `FAngelscriptTypeDatabase`

类型系统核心由这三个数据结构构成。它们的关系是：**`FAngelscriptType` 是"类型本身"，`FAngelscriptTypeUsage` 是"类型在某个上下文中的一次具体使用"，`FAngelscriptTypeDatabase` 是"按多种维度索引的类型表"**。

### 1.1 `FAngelscriptType`：类型抽象基类

```cpp
// ============================================================================
// 文件: Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptType.h
// 节选自: FAngelscriptType (位于行 23-343, 共 30+ 个虚方法)
// 性质: 抽象基类。每个 Bind_*.cpp 通常会派生 1~3 个子类来实现一族类型
// ============================================================================
struct ANGELSCRIPTRUNTIME_API FAngelscriptType : TSharedFromThis<FAngelscriptType>
{
    // ★ 类型查询四件套（静态入口，本文 §三 详述）
    static TSharedPtr<FAngelscriptType> GetByClass(UClass*);
    static TSharedPtr<FAngelscriptType> GetByData(void*);
    static TSharedPtr<FAngelscriptType> GetByAngelscriptTypeName(const FString&);
    static TSharedPtr<FAngelscriptType> GetByProperty(FProperty*, bool);

    // ★ 注册入口
    static void Register(TSharedRef<FAngelscriptType>);
    static void RegisterAlias(const FString&, TSharedRef<FAngelscriptType>);
    static void RegisterTypeFinder(FTypeFinder);

    // ★ 类型基本信息
    virtual FString GetAngelscriptTypeName() const { return TEXT(""); }
    virtual UClass*   GetClass(const FAngelscriptTypeUsage&) const  { return nullptr; }
    virtual UStruct*  GetUnrealStruct(const FAngelscriptTypeUsage&) const { return nullptr; }
    virtual void*     GetData() const { return nullptr; }
    virtual asITypeInfo* GetAngelscriptTypeInfo(const FAngelscriptTypeUsage&) const { return nullptr; }

    // ★ FProperty 创建（Type_ClassGeneration / Type_StructGeneration 的 AddClassProperties 入口）
    virtual bool CanCreateProperty(const FAngelscriptTypeUsage&) const { return false; }
    virtual FProperty* CreateProperty(const FAngelscriptTypeUsage&, const FPropertyParams&) const { ... }

    // ★ 五大值操作（编译期 + 运行期共用）
    virtual bool CanCopy(...) const  { return false; }   virtual void CopyValue(...)   const {}
    virtual bool CanCompare(...) const { return false; } virtual bool IsValueEqual(...) const { ... }
    virtual bool CanConstruct(...) const{ return false; }virtual void ConstructValue(...) const {}
    virtual bool CanDestruct(...) const { return false; }virtual void DestructValue(...)  const {}
    virtual bool CanHashValue(...) const{ return false; }virtual uint32 GetHash(...)      const { ... }

    // ★ UE↔AS 数据搬运（UFunction Reflective Fallback 关键）
    virtual bool CanBeArgument(...) const { return false; }
    virtual void SetArgument(..., asIScriptContext*, FFrame&, const FArgData&) const { ... }
    virtual bool CanBeReturned(...) const { return false; }
    virtual void GetReturnValue(..., asIScriptContext*, void*) const { ... }

    // ★ GC schema 贡献
    virtual bool HasReferences(...) const { return false; }
    virtual void EmitReferenceInfo(..., FGCReferenceParams&) const {}

    // ★ 默认值往返、调试器接入、CppForm（StaticJIT）...
    // (剩余 10+ 虚方法略)
};
```

注意几个非显然的设计点：

- **`TSharedFromThis` + `TSharedPtr` 持有**：每个 `FAngelscriptType` 实例由 `FAngelscriptTypeDatabase` 通过 `TSharedRef` 持有，多个 `FAngelscriptTypeUsage` 通过 `TSharedPtr` 共享同一份。生命周期跟随数据库，不跟随 UE GC。
- **没有 `virtual destructor` 的 noexcept 担保**：基类只声明 `virtual ~FAngelscriptType() {}`，因此销毁路径跟普通 C++ 多态一致——数据库 `Empty()` 时 `TSharedRef` 引用计数归零即销毁子类。
- **`FPropertyParams` 是创建 `FProperty` 的统一入参**：包含 `Outer`（`FFieldVariant`，可以是 `UStruct*` 也可以是另一个 `FProperty*`）、`PropertyName`、`Struct`。这对**容器属性**（`FArrayProperty` 的元素 `FProperty*` Outer 是 array 自己）很关键。

### 1.2 `FAngelscriptTypeUsage`：类型 + 修饰符的一次"使用快照"

```cpp
// ============================================================================
// 文件: Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptType.h
// 节选自: FAngelscriptTypeUsage (位于行 349-588)
// 性质: 值类型，可拷贝、可嵌套（SubTypes 用于模板递归）
// ============================================================================
struct ANGELSCRIPTRUNTIME_API FAngelscriptTypeUsage
{
    TArray<FAngelscriptTypeUsage> SubTypes;     // ★ 模板递归 (TArray<TMap<K,V>>)
    TSharedPtr<FAngelscriptType>  Type;          // ★ 指向基类，多个 Usage 共享
    bool bIsReference = false;
    bool bIsConst     = false;

    // ★ 关键 union: 一个槽位三种解读，按上下文复用
    union
    {
        class asITypeInfo* ScriptClass;       // 脚本类型来自 AS 引擎
        class FProperty*   UnrealProperty;    // 来自 UE 反射
        int32              TypeIndex;         // 来自原始类型 id
    };

    // ★ 五大工厂入口
    static FAngelscriptTypeUsage FromProperty(FProperty*);                   // UE → AS
    static FAngelscriptTypeUsage FromProperty(asITypeInfo*, int32 PropIdx);  // AS struct.field → AS
    static FAngelscriptTypeUsage FromReturn(asIScriptFunction*);              // AS 函数返回值
    static FAngelscriptTypeUsage FromParam(asIScriptFunction*, int32);       // AS 函数参数
    static FAngelscriptTypeUsage FromTypeId(int32);                           // AS TypeId
    static FAngelscriptTypeUsage FromDataType(const asCDataType&);           // AS 编译期类型
    static FAngelscriptTypeUsage FromClass(UClass*);                         // UE Class → AS
    static FAngelscriptTypeUsage FromStruct(UScriptStruct*);                 // UE Struct → AS

    // ★ 等价比较（重要：含 SubTypes 递归 + 委托给 Type->IsTypeEquivalent）
    bool operator==(const FAngelscriptTypeUsage& Other) const;
    bool EqualsUnqualified(const FAngelscriptTypeUsage& Other) const;
    
    // ★ 一票转发到 Type-> 的 FORCEINLINE 包装（30+ 个）
    FORCEINLINE bool   CanCopy()  const { return Type.IsValid() && Type->CanCopy(*this); }
    FORCEINLINE void   CopyValue(void* Src, void* Dst) const { Type->CopyValue(*this, Src, Dst); }
    // ...
};
```

`FAngelscriptTypeUsage` 是**类型在一次具体使用中的状态机**。同一个 `FAngelscriptType*`（比如 `FUObjectType` 关联到 `AActor`）会被多个 `FAngelscriptTypeUsage` 引用——但每个 Usage 自己保存"是否 const、是否引用、模板子类型有哪些"等当下信息。这种设计让基类 `FAngelscriptType` 本身可以是无状态的（仅持有 "Class / StructName / ScriptType" 这种 immutable 信息），而把"在这一处的修饰符"分摊到 Usage 上，避免子类爆炸成笛卡尔积。

### 1.3 `FAngelscriptTypeDatabase`：按四维索引的类型表

```cpp
// ============================================================================
// 文件: Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptType.h
// 节选自: FAngelscriptTypeDatabase (位于行 590-609)
// 性质: 一引擎一份。由 FAngelscriptEngine::TypeDatabase TUniquePtr 持有
// ============================================================================
struct ANGELSCRIPTRUNTIME_API FAngelscriptTypeDatabase
{
    // ★ 四维索引（同一 Type 同时挂在多张表上）
    TArray<TSharedRef<FAngelscriptType>>           RegisteredTypes;       // 所有已注册类型
    TMap<FString, TSharedRef<FAngelscriptType>>    TypesByAngelscriptName;// "AActor" / "FVector" 反查
    TMap<UClass*, TSharedRef<FAngelscriptType>>    TypesByClass;          // UClass* 反查
    TMap<void*,   TSharedRef<FAngelscriptType>>    TypesByData;           // 任意 void* tag 反查（多用于 UScriptStruct*）

    // ★ Type Finder：处理"一个 FProperty 对应哪个 AS 类型"的灵活路由
    TArray<FAngelscriptType::FTypeFinder>          TypeFinders;
    TArray<TSharedRef<FAngelscriptType>>           TypesImplementingProperties;

    // ★ 六个"泛型脚本类型"槽位 —— 用于"未生成 UASClass / UASStruct"的兜底处理
    TSharedPtr<FAngelscriptType> ScriptObjectType;       // 任意 script object
    TSharedPtr<FAngelscriptType> ScriptEnumType;         // 任意 script enum
    TSharedPtr<FAngelscriptType> ScriptStructType;       // 任意 script struct
    TSharedPtr<FAngelscriptType> ScriptDelegateType;     // 任意 script delegate
    TSharedPtr<FAngelscriptType> ScriptMulticastDelegateType;
    TSharedPtr<FAngelscriptType> ScriptFloatType;
    TSharedPtr<FAngelscriptType> ScriptDoubleType;
    TSharedPtr<FAngelscriptType> ScriptFloatParamExtendedToDoubleType;
    TSharedPtr<FAngelscriptType> ScriptBoolType;

    // ★ 模板锚点
    asITypeInfo* ArrayTemplateTypeInfo = nullptr;        // TArray<T> 的 asITypeInfo
};
```

### 1.4 数据库的拥有者：`FAngelscriptEngine`

数据库**不是全局的** —— 它由 `FAngelscriptEngine` 通过 `TUniquePtr` 持有，因此一个进程里如果存在多个 `FAngelscriptEngine`（PIE 多 Engine、热重载临时引擎、Test Helper 创建的私有引擎），它们的类型数据库**各自独立**。

```cpp
// ============================================================================
// 文件: Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptType.cpp
// 函数: GetTypeDatabase (静态文件级)
// ============================================================================
static FAngelscriptTypeDatabase& GetTypeDatabase()
{
    if (FAngelscriptEngine* Engine = FAngelscriptEngine::TryGetCurrentEngine())
    {
        if (FAngelscriptTypeDatabase* DB = Engine->GetTypeDatabase())
        {
            return *DB;                              // ★ 优先用当前 Engine 的
        }
    }
    static FAngelscriptTypeDatabase LegacyDatabase;  // ★ 兜底：进程级单例
    return LegacyDatabase;
}
```

`TryGetCurrentEngine()` 走的是 `FAngelscriptEngineContextStack` —— 详见 `Arch_Overview.md` 附录 B 术语表。当所有 `FAngelscriptEngine` 都被销毁（例如测试结束），fallback 静态 `LegacyDatabase` 接管，避免裸调 `Register` 时崩。这条 fallback 设计**不**用于业务路径，仅给 fork 期间残留的"非 Engine 上下文"代码做兜底。

---

## 二、注册管线：`FBind` → `Register` → `TypeFinder`

类型注册由 `FAngelscriptBinds::FBind` 静态触发器驱动，分三层调用：**AS 引擎注册（`RegisterObjectType`）→ 插件桥接层注册（`FAngelscriptType::Register`）→ Type Finder 路由注册**。三层都在 `BindScriptTypes()` 阶段一次性跑完。

### 2.1 总入口：`FAngelscriptEngine::BindScriptTypes`

```cpp
// ============================================================================
// 文件: Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.cpp
// 函数: BindScriptTypes
// 性质: 引擎 Initialize 时调用一次（也在多引擎重新 Compile 时再调）
// ============================================================================
void FAngelscriptEngine::BindScriptTypes()
{
    AS_PERF_SCOPE_STARTUP_BIND_SCRIPT_TYPES();
    LLM_SCOPE_BYTAG(Angelscript);

    FAngelscriptBinds::ResetGeneratedFunctionBindingTiming();
    FAngelscriptBinds::CallBinds(CollectDisabledBindNames());   // ★ 触发所有 FBind 静态实例
    FAngelscriptBinds::LogGeneratedFunctionBindingTimingSummary();
}
```

`FAngelscriptBinds::CallBinds` 按 `EOrder`（Early=-100 / Normal=0 / Late=+100）排序后逐一执行所有 `FBind` 闭包。`Bind_*.cpp` 文件通过下列匿名静态实例把自己挂上：

```cpp
// 范式: 类型族注册（Bind_UStruct.cpp:863, 行号容错~ Early+1）
AS_FORCE_LINK const FAngelscriptBinds::FBind Bind_StructDeclarations(
    (int32)FAngelscriptBinds::EOrder::Early + 1, []
{
    for (auto& DBBind : FAngelscriptBindDatabase::Get().Structs)
    {
        UScriptStruct* Struct = FindObject<UScriptStruct>(nullptr, *DBBind.UnrealPath);
        if (Struct == nullptr) continue;
        // ...
        BindStructType(DBBind.TypeName, Struct, BindFlags);   // ★ 每个 struct 走一遍 ValueClass + Register
    }
    BindStructTypeLookups();
});
```

### 2.2 三层注册的具体落点

```text
注册一个 UE struct（例如 FVector）的完整链路
================================================================

[1] AS 引擎层：声明类型存在
    FAngelscriptBinds::ValueClass<FVector>("FVector", Flags)
       └──► asCScriptEngine::RegisterObjectType("FVector", sizeof(FVector), flags)
              └──► allRegisteredTypes.Add(asCObjectType*)        // AS 内核注册表
                   registeredObjTypes.PushLast(asCObjectType*)
                   isPrepared = false                            // 强制下次 PrepareEngine 时重检

[2] 插件桥接层：登记 FAngelscriptType
    auto Type = MakeShared<FUStructType>(Struct, "FVector");
    Type->ScriptTypeInfo = Binds.GetTypeInfo();      // 反向缓存 asITypeInfo*
    Type->ScriptTypeInfo->SetUserData(Struct);       // ★ 在 asITypeInfo* 上挂 UScriptStruct*
    FAngelscriptType::Register(Type);
       └──► Database.RegisteredTypes.Add(Type)
            Database.TypesByAngelscriptName.Add("FVector", Type)
            Database.TypesByData.Add(Struct, Type)             // ★ UScriptStruct* 反查
            if (Type->CanQueryPropertyType())
                Database.TypesImplementingProperties.Add(Type) // 默认查询路径

[3] Type Finder 路由层（仅在 BindStructTypeLookups 跑一次）
    FAngelscriptType::RegisterTypeFinder([](FProperty* P, FAngelscriptTypeUsage& U) -> bool
    {
        FStructProperty* SP = CastField<FStructProperty>(P);
        if (SP == nullptr) return false;
        auto T = FAngelscriptType::GetByData(SP->Struct);   // ★ 用 UScriptStruct* 反查
        if (T.IsValid()) { U.Type = T; return true; }
        // 还要兜底处理 UASStruct（脚本侧 struct 还没生成 UASStruct 的临时阶段）
        ...
    });
```

注册 `UClass`（`Bind_BlueprintType.cpp::BindUClass`）走的是 `ReferenceClass` 而非 `ValueClass`，flags 是 `asOBJ_REF | asOBJ_NOCOUNT | asOBJ_IMPLICIT_HANDLE`——脚本里写 `AActor` 自动等价于 `AActor@`（handle）。注册 `UEnum`（`Bind_UEnum.cpp::Bind_Enums`）走的是 `FEnumBind`，最终调 `RegisterEnum + RegisterEnumValue`。

### 2.3 `Register` 的去重与冲突检查

```cpp
// ============================================================================
// 文件: Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptType.cpp
// 函数: FAngelscriptType::Register
// ============================================================================
void FAngelscriptType::Register(TSharedRef<FAngelscriptType> Type)
{
    auto& Database = GetTypeDatabase();
    FString AngelscriptName = Type->GetAngelscriptTypeName();

    if (Database.TypesByAngelscriptName.Contains(AngelscriptName))
    {
        UE_LOG(Angelscript, Warning, TEXT("Angelscript type %s is already registered. Skipping..."), *AngelscriptName);
        return;                                              // ★ 重名 = 警告 + 静默跳过
    }

    UClass* Class = Type->GetClass(FAngelscriptTypeUsage::DefaultUsage);
    if (Class != nullptr && Database.TypesByClass.Contains(Class))
    {
        UE_LOG(Angelscript, Error, TEXT("Angelscript type %s is bound to UClass %s that already has a binding!"),
               *AngelscriptName, *Class->GetName());
        ensure(false);                                       // ★ 同 UClass 多绑 = ensure 抛
        return;
    }
    // ...同样的逻辑给 GetData() 检查...

    Database.RegisteredTypes.Add(Type);
    Database.TypesByAngelscriptName.Add(AngelscriptName, Type);
    if (Class != nullptr) Database.TypesByData.Add(Class, Type);
    if (Type->GetData() != nullptr) Database.TypesByData.Add(Type->GetData(), Type);
    if (Type->CanQueryPropertyType()) Database.TypesImplementingProperties.Add(Type);
}
```

**重名是警告**而**同类多绑是 ensure** 这两条策略的差别值得注意：前者允许在多 `Bind_*.cpp` 间反复声明同名（fork 历史导致的轻度冗余），后者禁止——一个 `UClass*` 只能绑到唯一 `FAngelscriptType`，否则 `GetByClass` 拿到哪个就是不确定。

### 2.4 命名空间约定与名称映射

| AS 端写法 | 生成出 / 对应到 | 说明 |
|----------|--------------|------|
| `AActor` | `UClass*`（`AActor`） | UE C++ 写 `AActor`，AS 端**保留前缀** |
| `UStaticMesh` | `UClass*`（`UStaticMesh`） | 同上 |
| `FVector` | `UScriptStruct*`（`FVector`） | F 前缀保留 |
| `EBlendMode` | `UEnum*`（`EBlendMode`） | E 前缀保留 |
| `int / int32 / uint8 / float / double / bool` | UE 原始类型 | AS 内置；`int = int32`，`float = float32` |
| `FString` / `FName` / `FText` | `UScriptStruct*` | 通过 Bind_FString / Bind_FName 注册 |
| `TArray<T>` | 模板（见 §五） | 注册一次模板，N 次实例化 |
| `TMap<K, V>` / `TSet<T>` / `TOptional<T>` / `TWeakObjectPtr<T>` / `TSubclassOf<T>` / `TSoftObjectPtr<T>` | 模板（同上） | 见 `Syntax_*` 系列 |
| 脚本里 `class AMyActor : AActor` 声明的类 | 运行时生成 `UASClass*` | 由 `Type_ClassGeneration` 处理 |
| 脚本里 `struct FMyData` | 运行时生成 `UASStruct*` | 由 `Type_StructGeneration` 处理 |
| 脚本里 `enum EMyEnum` | 运行时生成 `UEnum*`（包内为 `/Script/Angelscript`） | 由 `Bind_UEnum.cpp` 与 ClassGenerator 协作 |

**没有"模块前缀"约定**：AS 端写 `Module::Type` 是 AS 语言的命名空间语法（`FAngelscriptBinds::FNamespace` RAII 包装 `SetDefaultNamespace`），但插件**不强制**给绑定类型加命名空间。所有 UE 反射类型默认进 AS 全局命名空间，靠 `U/A/F/E` 前缀防止冲突。

---

## 三、类型查询入口与 Type Finder 路由

类型核心提供两条路径回答"我手上拿到一个 UE 反射对象，怎么找到对应的 AS 类型"：**直接反查表**（O(1)）和 **TypeFinder 路由**（O(N)）。这两条互补——不是所有 `FProperty` 都能被表反查，因为表只索引 `UClass` / `void*`，而 `FProperty` 是字段级。

### 3.1 直接反查：四个静态入口

```cpp
// ============================================================================
// 文件: Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptType.cpp
// 函数: GetByAngelscriptTypeName / GetByClass / GetByData / GetByProperty
// ============================================================================
TSharedPtr<FAngelscriptType> FAngelscriptType::GetByAngelscriptTypeName(const FString& Name)
{
    auto* Found = GetTypeDatabase().TypesByAngelscriptName.Find(Name);
    return Found != nullptr ? *Found : nullptr;
}

TSharedPtr<FAngelscriptType> FAngelscriptType::GetByClass(UClass* ForClass)         { /* TypesByClass */ }
TSharedPtr<FAngelscriptType> FAngelscriptType::GetByData(void* ForData)             { /* TypesByData (UScriptStruct* / UEnum* / ...) */ }

TSharedPtr<FAngelscriptType> FAngelscriptType::GetByProperty(FProperty* P, bool bQueryTypeFinders)
{
    auto& Database = GetTypeDatabase();

    // ★ 1) 先跑 TypeFinder（因为 FProperty 之间的差异比 FAngelscriptType 多，需要细分）
    if (bQueryTypeFinders)
    {
        FAngelscriptTypeUsage Usage;
        for (auto& Finder : Database.TypeFinders)
            if (Finder(P, Usage))
                return Usage.Type;
    }
    // ★ 2) Fallback：遍历所有"声明 CanQueryPropertyType()=true 的 Type"，按 MatchesProperty 路由
    for (auto& CheckType : Database.TypesImplementingProperties)
        if (CheckType->MatchesProperty(FAngelscriptTypeUsage::DefaultUsage, P,
                                       FAngelscriptType::EPropertyMatchType::TypeFinder))
            return CheckType;

    return nullptr;
}
```

### 3.2 `FromProperty`：`FAngelscriptTypeUsage` 工厂

`GetByProperty` 只回答"是哪种 type"。要拿到含**修饰符**的完整 Usage（包括 const / reference / 模板 SubTypes），用 `FAngelscriptTypeUsage::FromProperty`：

```cpp
// ============================================================================
// 文件: Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptType.cpp
// 函数: FAngelscriptTypeUsage::FromProperty
// ============================================================================
FAngelscriptTypeUsage FAngelscriptTypeUsage::FromProperty(FProperty* Property)
{
    FAngelscriptTypeUsage Usage;
    auto& Database = GetTypeDatabase();

    // ★ TypeFinder 优先（容器/智能指针类型在这里被特化）
    for (auto& Finder : Database.TypeFinders)
        if (Finder(Property, Usage))
            break;

    if (!Usage.Type.IsValid())
        Usage.Type = FAngelscriptType::GetByProperty(Property, /*bQueryTypeFinders=*/false);

    if (Property->HasAnyPropertyFlags(CPF_ConstParm))
        Usage.bIsConst = true;

    const bool bIsRef = Property->HasAnyPropertyFlags(CPF_ReferenceParm)
        || (Property->HasAnyPropertyFlags(CPF_OutParm) && !Property->HasAnyPropertyFlags(CPF_ReturnParm));
    if (bIsRef)
        Usage.bIsReference = true;

    return Usage;
}
```

`CPF_ReferenceParm` 与 `CPF_OutParm` 的处理是 UFunction 参数 `in/out/inout` 三态的核心：

| UFunction Flags | AS 端 Usage |
|------|------|
| `CPF_OutParm` (无 `CPF_ReferenceParm`，无 `CPF_ReturnParm`) | `bIsReference = true` (out 参数) |
| `CPF_ReferenceParm` | `bIsReference = true` |
| `CPF_ConstParm` | `bIsConst = true` |
| `CPF_ReturnParm` | 通过 `FromReturn(asIScriptFunction*)` 处理，不进 `FromProperty` 路径 |

### 3.3 `FromTypeId`：从 AS TypeId 反向回到 UE 类型

```cpp
// ============================================================================
// 文件: Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptType.cpp
// 函数: FAngelscriptTypeUsage::FromTypeId (节选 ~340-438)
// 性质: AS → UE 的核心入口；调试器 / 函数桥 / 类型校验都靠它
// ============================================================================
FAngelscriptTypeUsage FAngelscriptTypeUsage::FromTypeId(int32 TypeId)
{
    FAngelscriptTypeUsage Usage;

    // ★ 1) 原始数值类型走快路径
    switch (TypeId & asTYPEID_MASK_SEQNBR)
    {
    case asTYPEID_BOOL:    Usage.Type = GetByAngelscriptTypeName(TEXT("bool"));   break;
    case asTYPEID_INT32:   Usage.Type = GetByAngelscriptTypeName(TEXT("int"));    break;
    case asTYPEID_FLOAT32: Usage.Type = GetByAngelscriptTypeName(TEXT("float32"));break;
    // ... bool/int8/16/32/64, uint8/16/32/64, float32/64
    }

    if (!Usage.Type.IsValid())
    {
        asITypeInfo* ScriptType = Manager.Engine->GetTypeInfoById(TypeId);
        if (ScriptType != nullptr)
        {
            // ★ 2) 脚本类型（asOBJ_SCRIPT_OBJECT）走泛型槽
            if (ScriptType->GetFlags() & asOBJ_SCRIPT_OBJECT)
            {
                if (ScriptType->GetFlags() & asOBJ_VALUE)
                {
                    void* UserData = ScriptType->GetUserData();
                    if      (UserData == TAG_UserData_Delegate)
                        Usage.Type = GetScriptDelegate();
                    else if (UserData == TAG_UserData_Multicast_Delegate)
                        Usage.Type = GetScriptMulticastDelegate();
                    else if (UserData == nullptr)
                        Usage.Type = GetScriptStruct();
                    else { /* 还可能是 UDelegateFunction* 委托签名 */ }
                }
                else
                    Usage.Type = GetScriptObject();

                Usage.ScriptClass = ScriptType;
                return Usage;
            }
            // ★ 3) 脚本枚举走 ScriptEnum 槽
            if ((ScriptType->GetFlags() & asOBJ_ENUM) && ScriptType->GetModule() != nullptr)
            {
                Usage.Type = GetScriptEnum();
                Usage.ScriptClass = ScriptType;
                return Usage;
            }
            // ★ 4) 普通注册类型按名查
            Usage.Type = GetByAngelscriptTypeName(ANSI_TO_TCHAR(ScriptType->GetName()));
            Usage.ScriptClass = ScriptType;

            // ★ 5) 模板类型递归填 SubTypes
            for (int32 i = 0, N = ScriptType->GetSubTypeCount(); i < N; ++i)
            {
                Usage.SubTypes.Add(FromTypeId(ScriptType->GetSubTypeId(i)));
                if (!Usage.SubTypes.Last().IsValid())
                {
                    Usage.Type = nullptr; Usage.SubTypes.Empty(); break;
                }
            }
        }
    }
    return Usage;
}
```

这条函数是整个文件最密集的逻辑，承担了"AS 引擎随便给我一个 TypeId 我能不能转成 Usage"的所有 case。注意：

- **`asOBJ_SCRIPT_OBJECT` 用泛型槽，不进按名表**：因为脚本类的名字会在热重载时变（"FMyData_REPLACED_3"），按名查会找不到——所以脚本类共享一个 `ScriptObjectType` / `ScriptStructType`，靠 `Usage.ScriptClass` 区分。
- **Delegate 通过 `UserData` tag 区分**：`TAG_UserData_Delegate = 0x1` / `TAG_UserData_Multicast_Delegate = 0x2`（见 `AngelscriptType.cpp:25-26`）——这两个魔数地址永远不会被合法对象命中，作为类型标记。
- **模板递归 SubType**：进入 `FromTypeId` 自身，遇到 `TArray<FStructProperty>` 这样的复合类型自动展开成 SubTypes 数组。如果任意 SubType 解析失败，整个 Usage **回退为非法**——避免半推半就的部分类型。

---

## 四、`FAngelscriptType` 的子类家族

`FAngelscriptType` 有大量子类（散落在 `Binds/Bind_*.cpp` 中，共约 50+ 个），按职责分为五族。本节挑代表性子类剖析**它们如何通过 override 把抽象操作变成具体行为**。

### 4.1 五族划分

| 族 | 代表子类 | 文件 | 作用 |
|----|---------|------|------|
| **POD/原始类型** | `FBoolType` / `FIntType` / `FFloatType` / 等 | `Binds/Bind_PrimitiveTypes.cpp` 系列 | bool / int / float / ...；继承 `TAngelscriptPODType<T>` |
| **UE Object 引用** | `FUObjectType` / `FObjectPtrType` / `FWeakObjectPtrType` / `FSubclassOfType` / `FSoftObjectPtrType` | `Bind_BlueprintType.cpp` / `Bind_TSoftObjectPtr.cpp` | UObject* / TObjectPtr / TWeakObjectPtr / TSubclassOf / TSoftObjectPtr |
| **UE Struct** | `FUStructType` / `FInstancedStructType` | `Bind_UStruct.cpp` / `Bind_FInstancedStruct.cpp` | UScriptStruct → struct 字段 |
| **UE Enum** | `FEnumType` | `Bind_UEnum.cpp` | UEnum → enum 字段 |
| **容器/特殊** | `FArrayType` / `FMapType` / `FSetType` / `FOptionalType` / `FDelegateType` / `FInterfaceType` / `FNameType` / `FStringType` | `Bind_TArray.cpp` / `Bind_TMap.cpp` / ... | 模板容器 + 特殊类型（FName / FString / FText） |

### 4.2 `FUStructType` —— UE Struct 的桥接典范

```cpp
// ============================================================================
// 文件: Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UStruct.cpp
// 函数: FUStructType (节选行 34-410)
// 性质: 一个 FUStructType 实例对应一个 UScriptStruct（FVector / FRotator / FTransform / ...）
//       script struct 共享一个 Struct=nullptr 的"泛型"实例，靠 Usage.ScriptClass 区分
// ============================================================================
struct FUStructType : FAngelscriptType
{
    UScriptStruct* Struct = nullptr;
    asITypeInfo*   ScriptTypeInfo = nullptr;
    FString        StructName;

    // ★ GetUnrealStruct: 给"AddClassProperties"提供 UStruct
    UStruct* GetUnrealStruct(const FAngelscriptTypeUsage& Usage) const override { return GetStruct(Usage); }

    // ★ CreateProperty: AddClassProperties 的核心
    FProperty* CreateProperty(const FAngelscriptTypeUsage& Usage, const FPropertyParams& Params) const override
    {
        UScriptStruct* UsedStruct = GetStruct(Usage);
        auto* StructProp = new FStructProperty(Params.Outer, Params.PropertyName, RF_Public);
        StructProp->Struct = UsedStruct;
        return StructProp;
    }

    // ★ HasReferences: 有 UObject 引用就告诉 GC（递归检查 PropertyLink）
    bool HasReferences(const FAngelscriptTypeUsage& Usage) const override { /* PropertyLink 遍历 */ }

    // ★ EmitReferenceInfo: 把 STRUCT_AddStructReferencedObjects 与每个 FProperty 的 schema 都加进去
    void EmitReferenceInfo(const FAngelscriptTypeUsage& Usage, FGCReferenceParams& Params) const override
    {
        UScriptStruct* UsedStruct = GetStruct(Usage);
        if (UsedStruct->StructFlags & STRUCT_AddStructReferencedObjects)
        {
            UE::GC::StructAROFn ARO = UsedStruct->GetCppStructOps()->AddStructReferencedObjects();
            Params.Schema->Add(UE::GC::DeclareMember(Params.Names.Top(), Params.AtOffset,
                                                    UE::GC::EMemberType::MemberARO, ARO));
        }
        for (FProperty* P = UsedStruct->PropertyLink; P; P = P->PropertyLinkNext)
            P->EmitReferenceInfo(*Params.Schema, Params.AtOffset, Encountered, *Params.DebugPath);
    }

    // ★ SetArgument: UE 调 AS 函数时，把 FFrame 上的 struct 读出来塞给 AS Context
    void SetArgument(..., asIScriptContext* Context, FFrame& Stack, const FArgData& Data) const override
    {
        UScriptStruct* UsedStruct = GetStruct(Usage);
        uint8* StructMemory = (uint8*)Data.StackPtr;
        UsedStruct->InitializeStruct(StructMemory, 1);

        if (Usage.bIsReference)
        {
            uint8& RefValue = Stack.StepCompiledInRef<FStructProperty, uint8>(StructMemory);
            Context->SetArgAddress(ArgumentIndex, &RefValue);
        }
        else
        {
            Stack.StepCompiledIn<FStructProperty>(StructMemory);
            Context->SetArgObject(ArgumentIndex, StructMemory);
        }
    }

    // ★ Construct/Destruct/Copy/Equal/Hash 都委托给 UScriptStruct 自己的 InitializeStruct/DestroyStruct/...
};
```

注意 `Struct == nullptr` 的两种角色：

1. **C++ struct 的 FUStructType**（`MakeShared<FUStructType>(Struct, "FVector")`）—— `Struct` 非空，`GetData()` 返回 `Struct`；
2. **泛型 script struct 的 FUStructType**（`SetScriptStruct(MakeShared<FUStructType>(nullptr, TEXT("")))`）—— `Struct` 为空，所有方法都从 `Usage.ScriptClass->GetUserData()` 取 `UScriptStruct*`（这是 `UASStruct`）。

### 4.3 `FUObjectType` —— UClass 引用的桥接

`FUObjectType` 的设计与 `FUStructType` 同构，但有几条细节差异：

```cpp
// ============================================================================
// 文件: Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_BlueprintType.cpp
// 节选自: FUObjectType (位于行 91-700)
// ============================================================================
struct FUObjectType : TAngelscriptPODType<UObject*>      // ★ 继承 POD<UObject*>，因为 handle 本质是指针
{
    UClass*      Class = nullptr;
    FString      ClassName;
    asITypeInfo* ClassScriptType = nullptr;

    // ★ CreateProperty: UClass* 类型的字段创建 FClassProperty 而非 FObjectProperty
    FProperty* CreateProperty(const FAngelscriptTypeUsage& Usage, const FPropertyParams& Params) const override
    {
        if (Class == UClass::StaticClass())
        {
            auto* P = new FClassProperty(Params.Outer, Params.PropertyName, RF_Public);
            P->PropertyClass = Class;
            P->MetaClass = UObject::StaticClass();
            return P;
        }
        auto* P = new FObjectProperty(Params.Outer, Params.PropertyName, RF_Public);
        P->PropertyClass = (Class != nullptr) ? Class : (UClass*)Usage.ScriptClass->GetUserData();
        return P;
    }

    // ★ CanQueryPropertyType=false: 不走 GetByProperty 兜底，所有 Object 走专用 TypeFinder
    bool CanQueryPropertyType() const override { return false; }
};
```

为什么 `CanQueryPropertyType=false`？因为 **`UClass` 数量太多**（数千个），`TypesByClass` 表已经能 O(1) 反查；如果再让 `TypesImplementingProperties` 遍历这些类型，性能不能接受。所以 `BindUClassLookup()` 注册了一个**单一 TypeFinder**，里面通过 `CastField<FObjectProperty>` 一次区分 `FObjectProperty / FWeakObjectProperty / FClassProperty` + `CPF_TObjectPtr`，然后**再**通过 `FromClass(P->PropertyClass)` 走 `TypesByClass` 反查找到精确的 `FUObjectType`。

### 4.4 `FEnumType` —— UEnum 的桥接

```cpp
// ============================================================================
// 文件: Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UEnum.cpp
// 节选自: FEnumType (位于行 ~50-330)
// ============================================================================
struct FEnumType : FAngelscriptType
{
    UEnum* Enum = nullptr;        // C++ 端 UEnum；脚本端 enum 这里是 nullptr，靠 Usage.ScriptClass

    bool CanCopy(...) const override { return true; }
    bool NeedCopy(...) const override { return true; }
    void CopyValue(...) const override { *(uint8*)Dst = *(uint8*)Src; }    // ★ 全部按 uint8 处理
    int32 GetValueSize(...) const override { return 1; }                   // ★ 哪怕 enum class : int64 也按 1 字节传

    // ★ SetArgument: SetArgByte（注意 enum 在 AS 字节码里就是 1 字节）
    void SetArgument(...) const override
    {
        uint8* V = (uint8*)Data.StackPtr;
        if (Usage.bIsReference)
        {
            uint8& Ref = Stack.StepCompiledInRef<FEnumProperty, uint8>(V);
            Context->SetArgAddress(ArgumentIndex, &Ref);
        }
        else
        {
            Stack.StepCompiledIn<FEnumProperty>(V);
            Context->SetArgByte(ArgumentIndex, *V);
        }
    }
};
```

`FEnumType` 是**所有 enum 共享一个语义实现**——脚本侧不区分 `EBlendMode` 和 `ECollisionChannel` 的具体值类型，统一按 1 字节处理。这意味着 AS 端不能定义 `int64` 底层类型的 enum —— `Bind_UEnum.cpp` 的 TypeFinder 也只识别 `FByteProperty` / `FEnumProperty(FByteProperty 底层)` / `FEnumProperty(FIntProperty 底层)` 三种。脚本端的 `enum EXxx` 编译产生 `UUserDefinedEnum*`，由 `UAngelscriptScriptEnum`（待 ClassGenerator 处理）封装。

### 4.5 `FSubclassOfType` / `FObjectPtrType` / `FWeakObjectPtrType` —— 智能指针包装

这三类都是**模板包装类型**——它们的 `FAngelscriptType` 有一个**模板基类型**（`asITypeInfo* BaseTypeInfo`），所有 `TSubclassOf<X>` / `TObjectPtr<X>` / `TWeakObjectPtr<X>` 共享同一个 `FAngelscriptType` 实例，靠 `FAngelscriptTypeUsage::SubTypes[0]` 区分内部类型。

```cpp
// 共享设计的代价: BaseTypeInfo 是单例
// (Bind_BlueprintType.cpp:1809)
asITypeInfo* FSubclassOfType::BaseTypeInfo = nullptr;
// ...
FSubclassOfType::BaseTypeInfo = FAngelscriptEngine::Get().Engine->GetTypeInfoByName("TSubclassOf");
```

容器属性的 TypeFinder（`Bind_BlueprintType.cpp:2496`）做 `FObjectProperty + CPF_TObjectPtr` 检测、`FWeakObjectProperty` 检测、`FClassProperty + CPF_TObjectPtr` 检测时，每次都构造 `FAngelscriptTypeUsage { Type = ObjectPtrType, SubTypes = [InnerType] }`。

---

## 五、容器与模板：`TArray<T>` / `TMap<K,V>` 的"模板实例化"边界

容器是类型系统里最复杂的一族，因为它们既要在 AS 端表现为模板（`TArray<int>` 共用 `TArray` 字节码模板），又要在 UE 端展开成具体的 `FArrayProperty` / `FMapProperty`。

### 5.1 模板的两层抽象

```text
                ┌─────────────────────────────────────────────────────┐
                │  AS 引擎层: TArray<class T> 注册一次                  │
                │     RegisterObjectType("TArray<T>", asOBJ_VALUE | asOBJ_TEMPLATE) │
                │     ScriptType->GetSubTypeCount() = 1                 │
                │     ★ 字节码层面所有 TArray<X> 共用同一份 method 表   │
                └────────────┬────────────────────────────────────────┘
                             │
                             ▼ 每次脚本写 TArray<int> 触发
                ┌─────────────────────────────────────────────────────┐
                │  AS 内核: 模板特化（TemplateCallback 决策）           │
                │     TArray<X>.TemplateCallback("bool f(int&in T, ...)")│
                │       └─ 验证 T 能否构造 / 拷贝 / 析构               │
                │       └─ 失败 -> ErrorMessage, 编译错                │
                │  得到 asITypeInfo* TArray_X，但底层 method 不复制     │
                └────────────┬────────────────────────────────────────┘
                             │
                             ▼ 调到 SetArgument / CreateProperty
                ┌─────────────────────────────────────────────────────┐
                │  插件层: FAngelscriptArrayType 的 Usage 解读          │
                │     Usage.SubTypes[0] 提供 T 的 FAngelscriptType      │
                │     CreateProperty 创建 FArrayProperty, Inner=T's prop │
                └─────────────────────────────────────────────────────┘
```

### 5.2 `Bind_TArray.cpp` 注册片段

```cpp
// ============================================================================
// 文件: Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_TArray.cpp
// 节选自: Bind_TArray (位于行 1381-1410)
// ============================================================================
AS_FORCE_LINK const FAngelscriptBinds::FBind Bind_TArray(FAngelscriptBinds::EOrder::Early, []
{
    FBindFlags Flags;
    Flags.bTemplate     = true;
    Flags.TemplateType  = "<T>";
    Flags.ExtraFlags    = asOBJ_TEMPLATE_SUBTYPE_COVARIANT;

    auto TArray_ = FAngelscriptBinds::ValueClass<FScriptArray>("TArray<class T>", Flags);
    TArray_.Constructor("void f()", FUNC_TRIVIAL(FArrayOperations::Construct));

    // ★ 注册为引擎的"默认数组类型"——脚本里写 [int] 字面量也会走它
    FAngelscriptType::SetArrayTemplateTypeInfo(TArray_.GetTypeInfo());
    FAngelscriptEngine::Get().Engine->RegisterDefaultArrayType("TArray<T>");

    // ★ TemplateCallback: 脚本写 TArray<XXX> 时，AS 引擎用它决定能不能实例化
    TArray_.TemplateCallback("bool f(int&in Type, int&out ErrorMessage)",
    [](asITypeInfo* TemplateType, asCString* ErrorMessage) -> bool
    {
        if (TemplateType->GetSubType(0)
            && (TemplateType->GetSubType(0)->GetFlags() & asOBJ_TEMPLATE_SUBTYPE) != 0)
            return true;                    // 泛型推迟检查
        return ValidateArrayOperations(TemplateType, ErrorMessage) != nullptr;
    });

    TArray_.Method("T& opIndex(int Index)", &FArrayOperations::OpIndex);
    // ...
});
```

### 5.3 模板的"实例化"在 AS 端是延迟的

```text
TArray<int> 与 TArray<FVector> 在 AS 引擎里:
  - 属于同一个 asCObjectType.templateBaseType = TArray<T>
  - 但是各有自己的 asITypeInfo* (TArray_int / TArray_FVector)
  - Methods 表通过 GetSubTypeId() 在调用时动态展开类型

类比 C++ STL:
  - vector<int>::push_back 与 vector<float>::push_back 是不同函数（C++ 编译期实例化）
  - AS 的 TArray<int>::push_back 与 TArray<float>::push_back 是同一个字节码（运行期解读 SubTypeId）
  - 这让 AS 引擎能用 1 份 method 表服务所有 TArray<X>
```

`FAngelscriptType::SetArrayTemplateTypeInfo` 把模板基类型的 `asITypeInfo*` 缓存到数据库，后续任何"我想知道当前类型是不是 TArray"的检查（脚本对象 GC schema、序列化、调试器）都通过这个锚点判定。

---

## 六、`FAngelscriptBindDatabase`：cooked 期的"瘦数据库"

`FAngelscriptBindDatabase`（在 `AngelscriptBindDatabase.h`）跟 `FAngelscriptTypeDatabase` 是**两个不同的东西**——名字相近但职责正交：

| 项 | `FAngelscriptTypeDatabase` | `FAngelscriptBindDatabase` |
|---|---------------------------|---------------------------|
| 内容 | 运行期 `FAngelscriptType` 实例 | 序列化的 "Class/Struct/Method/Property 元描述"（纯数据） |
| 持有 | `FAngelscriptEngine` `TUniquePtr` | 同上（也是 `FAngelscriptEngine` 字段） |
| 来源 | Bind_*.cpp 的 `FBind` 闭包构造 | 编辑器期遍历 UE 反射写到 `Script/Binds.Cache` 文件 |
| 用途 | 类型查询、`FProperty` 创建、`SetArgument` | 在 cooked 路径**没有 Editor 反射**时，**重放** Bind |
| 生命周期 | 引擎 Initialize → 引擎 Shutdown | 同上，但 Cache 文件在编辑器期一次生成 |

```cpp
// ============================================================================
// 文件: Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptBindDatabase.h
// 节选: FAngelscriptStructBind / FAngelscriptClassBind 数据形态
// ============================================================================
struct FAngelscriptStructBind
{
    FString TypeName;                      // "FVector"
    FString UnrealPath;                    // "/Script/CoreUObject.Vector"
    TArray<FAngelscriptPropertyBind> Properties;
    UScriptStruct* ResolvedStruct = nullptr;   // 加载后回填
};

struct FAngelscriptClassBind
{
    FString TypeName;                      // "AActor"
    FString UnrealPath;                    // "/Script/Engine.Actor"
    TArray<FAngelscriptMethodBind> Methods;
    TArray<FAngelscriptPropertyBind> Properties;
    UClass* ResolvedClass = nullptr;
};
```

cooked 启动时，`Bind_StructDeclarations` / `Bind_ClassDeclarations` 这种 `FBind` 闭包**遍历 `FAngelscriptBindDatabase::Get().Structs/Classes`**（而不是 `TObjectRange<UScriptStruct>`），按持久化的元数据重放 `BindStructType` / `BindClassType`，绕开"Editor 反射在 cook 后会被 strip"的限制。

注意：`FAngelscriptBindDatabase` **不参与脚本类型注册**（脚本端的 `class AMyActor : AActor` 由 ClassGenerator 在运行时生成 `UASClass`，根本没经过 cache）。它只持久化 C++ 端 UE 反射的元数据。

---

## 七、生命周期协同：UE GC × AS RefCount × 数据库

类型系统涉及三种独立的生命周期，理解它们的协同点是排查"类型对象悬空"问题的钥匙。

```text
================================================================================
  三套生命周期对照
================================================================================

[A. UE 类型对象]            [B. AS 类型对象]          [C. 插件桥接层]
UClass / UScriptStruct /   asCObjectType /          FAngelscriptType
UEnum / UDelegateFunction  asCEnumType / ...        (TSharedRef in DB)
                                                     
管理: GC + UObject          管理: AS RefCount         管理: TSharedRef RAII
       ROOTED               (asCTypeInfo::             (FAngelscriptTypeDatabase
                            externalRefCount /          .RegisteredTypes 持引用)
                            internalRefCount)         
                                                     
销毁: 引擎 Shutdown 后     销毁: asCScriptEngine     销毁: TypeDatabase.Reset()
       UE GC 一并回收        ::Release() (refCount=0)   (FAngelscriptEngine
                                                       Shutdown)
                                                     
        ▲                          ▲                          ▲
        │                          │                          │
        └──────────────────────────┼──────────────────────────┘
                                   │
                  ★ 协同点: SetUserData()
                  asITypeInfo->SetUserData(UScriptStruct* / UEnum* / UClass*)
                    => asITypeInfo 反向持有 UE 对象指针 (raw)
                    => 但不增加 UE 引用计数
                    => 因此 UE 类型必须保证比 AS 类型先于销毁
```

### 7.1 销毁顺序的硬约束

```text
正确销毁顺序:
  1) FAngelscriptEngine::Shutdown
     a) ScriptEngine->ShutDownAndRelease()  // AS 内核释放所有 asITypeInfo
     b) TypeDatabase.Reset()                // 释放 FAngelscriptType (TSharedRef -> 0)
     c) BindDatabase.Reset()                // 释放 cooked 元数据缓存
  2) UE 进程退出 / Module 卸载
     a) UE GC 回收 UScriptStruct / UClass / UEnum

错误顺序导致的崩:
  - 脚本运行中 UE GC 回收了 UScriptStruct
  - 后续脚本调用 ScriptType->GetUserData() 拿到悬空指针
  - InitializeStruct(...) 崩在虚函数表

防护机制:
  - UE 类型几乎都是 RF_Standalone | RF_Public（绑定时 SetFlags 加 ROOTED）
  - UASClass / UASStruct 在 ClassGenerator 中显式 AddToRoot
  - 卸载 plugin 时先调 FAngelscriptEngine::Shutdown 才会触发 GC
```

### 7.2 热重载下的版本链（与 `Type_ClassGeneration` 协作）

热重载产生的 "旧 `UASClass`" 不会被立即 GC，而是挂在 `NewerVersion` 链上（详见 `Type_ClassGeneration.md` §1.2）。`FAngelscriptType` 这一层**不参与版本链**——它只持有"脚本类型的 `asITypeInfo*`"或"C++ UClass*"，对版本变化保持透明：

- C++ UClass 变了（不应该发生）→ `TypesByClass` 失效，但因为 UE 反射对象的 ID 不变，没有问题；
- 脚本 UASClass 重载 → `Usage.ScriptClass` 是新的 `asITypeInfo*`，老的 `asITypeInfo*` 由 `UpdatedScriptTypeMap` 转发到新的（详见 `AngelscriptClassGenerator.cpp`）。

---

## 八、与 `Type_ClassGeneration` / `Type_BindSystem` 的边界

最后一节明确"哪些事不在本文写"：

```text
                ┌────────────────────────────────────────┐
                │  Type_BindSystem.md (待写)              │
                │  ──────────────────                     │
                │  • Bind_*.cpp 怎么组织                  │
                │  • FBind / EOrder / FNamespace 用法     │
                │  • 121 个 Bind_*.cpp 的全景             │
                │  • UHT 生成的 AS_FunctionBinding_*.cpp    │
                │  • Reflective Fallback 链路             │
                │     (UFunction → AS method via         │
                │      FAngelscriptTypeUsage::SetArgument) │
                └─────────────────┬──────────────────────┘
                                  │ 消费
                                  ▼
                ┌────────────────────────────────────────┐
                │  Type_Core.md  (本文)                   │
                │  ──────────────────                     │
                │  • FAngelscriptType / TypeUsage / DB    │
                │  • 类型查询四件套 + TypeFinder          │
                │  • 子类家族剖析 (FUStructType / ...)    │
                │  • 模板 (TArray<T>) 实例化语义          │
                │  • cooked BindDatabase 与 TypeDatabase  │
                │    的差异                                │
                │  • 生命周期协同                          │
                └─────────────────┬──────────────────────┘
                                  │ 消费
                                  ▼
                ┌────────────────────────────────────────┐
                │  Type_ClassGeneration.md / Type_StructGeneration.md │
                │  ──────────────────                     │
                │  • UASClass / UASStruct / UASFunction   │
                │  • Setup/PerformReload/Finalize 链路    │
                │  • AddClassProperties(ClassDesc) 调:    │
                │      FAngelscriptTypeUsage::FromProperty │
                │      Type->CreateProperty                │
                │  • DefaultComponent / Constructor       │
                │    分派 (Actor/Component/Object)        │
                └────────────────────────────────────────┘
```

| 主题 | 应该写在 | 不应该写在 |
|------|---------|-----------|
| "FAngelscriptType 有哪些子类、字段是什么" | **Type_Core**（本文） | Bind_* 文件结构是 BindSystem 的事 |
| "Bind_UStruct.cpp 第几个 FBind 在干什么" | Type_BindSystem | Type_Core 不抄 cpp 文件目录 |
| "UASClass 的 ClassConstructor 怎么分派 Actor/Component/Object" | Type_ClassGeneration | Type_Core 不写 UASClass 的细节 |
| "脚本里 `UPROPERTY()` 是怎么变成 FProperty 的" | Syntax_UPROPERTY | Type_Core 给"创建 FProperty 的入口"，Syntax 给"修饰符语法" |
| "TArray 是怎么把 push_back 字节码挂到内置方法上的" | Syntax_TArray | Type_Core 只写"模板实例化的两层抽象" |
| "热重载时旧 UASClass 怎么挂版本链" | Type_ClassGeneration §1.2 | Type_Core 只说"FAngelscriptType 不参与版本链" |
| "asITypeInfo / asCObjectType 内部字段" | AS_TypeRegistration / AS_ScriptEngine | Type_Core 仅引用 |

---

## 附录 A：类型映射对照速查表

下表把"插件维护者最常被问"的类型映射按"UE 反射 ↔ AS 表示 ↔ FAngelscriptType 子类 ↔ Bind 入口"四列汇总。**用于快速回答"我想给 X 类型加个 Y 操作要改哪个文件"**。

| UE 反射 | AS 端写法 | `FAngelscriptType` 子类 | Bind 入口（典型文件） | 备注 |
|--------|----------|------------------------|---------------------|------|
| `bool` / `int8/16/32/64` / `uint8/16/32/64` / `float` / `double` | `bool` / `int` / `int64` / `uint8` / `float32` / `float64` | `T*Type` (`Bool`/`Int`/`Float`...) | `Bind_PrimitiveTypes.cpp` 系列 | 内置原始类型，AS 引擎自带 |
| `FString` | `FString` | `FStringType` | `Bind_FString.cpp` | StringFactory 注册 |
| `FName` | `FName` | `FNameType` | `Bind_FName.cpp` | POD-ish |
| `FText` | `FText` | `FTextType` | `Bind_FText.cpp` | 与 FString 关联 |
| `UClass*`（具体类如 `AActor`） | `AActor`（`asOBJ_REF + IMPLICIT_HANDLE`） | `FUObjectType` | `Bind_BlueprintType.cpp::BindUClass` | 数据库 `TypesByClass` 反查 |
| `UClass*`（meta 类） | `UClass`（同上） | `FUObjectType`（`Class==UClass::StaticClass()`） | 同上 | `CreateProperty` 走 `FClassProperty` 分支 |
| `UScriptStruct*` | `FXxx`（`asOBJ_VALUE`） | `FUStructType` | `Bind_BlueprintType.cpp::BindUStruct` / `Bind_UStruct.cpp` | 数据库 `TypesByData` 反查 |
| `UEnum*` | `EXxx`（1 字节） | `FEnumType` | `Bind_UEnum.cpp::Bind_Enums` | TypeFinder 处理 byte/int 底层 |
| `TObjectPtr<X>` | `X`（同 UClass 写法） | `FObjectPtrType`（带 `SubTypes[0]`） | `Bind_BlueprintType.cpp::BindUClassLookup` | TypeFinder 检测 `CPF_TObjectPtr` |
| `TWeakObjectPtr<X>` | `TWeakObjectPtr<X>` | `FWeakObjectPtrType` | 同上 | 用 SubType 持有 X |
| `TSubclassOf<X>` | `TSubclassOf<X>` | `FSubclassOfType` | 同上 | `BaseTypeInfo` 单例 |
| `TSoftObjectPtr<X>` / `TSoftClassPtr<X>` | `TSoftObjectPtr<X>` / `TSoftClassPtr<X>` | `FSoftObjectPtrType` / `FSoftClassPtrType` | `Bind_TSoftObjectPtr.cpp` | `FSoftObjectPath` 包装 |
| `FInstancedStruct` | `FInstancedStruct` | `FInstancedStructType` | `Bind_FInstancedStruct.cpp` | StructUtils 桥接 |
| `TArray<T>` | `TArray<T>`（模板） | `FArrayType` (内部+`FAngelscriptArrayIteratorType`) | `Bind_TArray.cpp` | `RegisterDefaultArrayType` |
| `TMap<K,V>` | `TMap<K,V>` | `FMapType` | `Bind_TMap.cpp` | KeyFuncs 约束（可哈希） |
| `TSet<T>` | `TSet<T>` | `FSetType` | `Bind_TSet.cpp` | 同 TMap key 约束 |
| `TOptional<T>` | `TOptional<T>` | `FOptionalType` | `Bind_TOptional.cpp` | IsSet/Get/Reset |
| `UDelegateFunction*`（单播） | 脚本 `delegate XXX(...)` 生成 `asOBJ_SCRIPT_OBJECT` | `ScriptDelegateType` 泛型槽 | `Bind_Delegates.cpp` | `UserData = TAG_UserData_Delegate (0x1)` |
| `UDelegateFunction*`（多播） | `event` 关键字 | `ScriptMulticastDelegateType` 泛型槽 | 同上 | `UserData = 0x2` |
| `UInterface*` | `IXxx` | `FInterfaceType`（注册为 `asOBJ_REF + asOBJ_NOCOUNT`） | `Bind_Interfaces.cpp`（部分） | 见 `Note_InterfaceBinding.md` |
| 脚本 `class AMyActor : AActor` | `AMyActor`（运行时 UASClass） | `ScriptObjectType` 泛型槽 | ClassGenerator | `Usage.ScriptClass = asITypeInfo` 区分 |
| 脚本 `struct FMyData` | `FMyData`（运行时 UASStruct） | `ScriptStructType` 泛型槽 | ClassGenerator | 同上 |
| 脚本 `enum EMyEnum` | `EMyEnum`（运行时 UEnum） | `ScriptEnumType` 泛型槽 | ClassGenerator | 同上 |

---

## 附录 B：常见调试线索

下表是**类型系统排错时的十条 grep 起点**——按现象列出最先该看的源码位置。

| 现象 | 第一站 | 第二站 |
|------|--------|--------|
| 脚本调函数报 "Type 'XXX' is not registered" | `FAngelscriptType::Register` 调用栈 | 检查对应 `Bind_*.cpp::FBind` 是否被加载（`AS_FORCE_LINK` 是否生效） |
| `FromProperty` 返回 invalid Usage | `Bind_*.cpp` 中的 `RegisterTypeFinder` 列表 | 确认 TypeFinder 顺序 + 该 FProperty 的 CPF flags |
| `CreateProperty` 崩 ensure | `FAngelscriptType::CreateProperty` 默认实现（基类） | 子类没 override → 应该走专用 finder 而不是这里 |
| 热重载后 `GetByClass` 拿到旧版本 | `UpdatedScriptTypeMap` (`AngelscriptClassGenerator.cpp`) | `TypesByClass` 是按 `UClass*`，UClass 没换地址不会重映射 |
| "Type X is bound to UClass Y that already has a binding!" | 重复 `Register` 调用栈 | 检查多 `Bind_*.cpp` 是否声明同名 / fork 残留 |
| AS 端 `for-each` TArray 字段失败 | `FAngelscriptType::SetArrayTemplateTypeInfo` 调用 | `Bind_TArray.cpp` 是否加载、`RegisterDefaultArrayType` 是否调过 |
| 调试器看不到 struct 字段 | `FUStructType::GetDebuggerScope` / `GetDebuggerMember` | 检查 `bIsScriptStruct` 与 `Usage.ScriptClass` 是否对齐 |
| GC 漏抓脚本 struct 内的 UObject 引用 | `FUStructType::EmitReferenceInfo` | `STRUCT_AddStructReferencedObjects` flag + `PropertyLink` 链表 |
| cooked 里 struct 找不到（编辑器没事） | `Script/Binds.Cache` 是否生成、版本号匹配（`CacheVersion=1`） | `FAngelscriptBindDatabase::TryLoad` 错误日志 |
| AS 端写 `default Health = 100` 没生效 | `FAngelscriptType::DefaultValue_AngelscriptToUnreal` | 类型子类是否实现该 override |

---

## 小结

- **数据模型三主角**：`FAngelscriptType`（无状态类型基类）、`FAngelscriptTypeUsage`（一次使用快照含修饰符 + SubTypes）、`FAngelscriptTypeDatabase`（按四维索引的类型表）。三者关系决定了"类型本身可被多个上下文复用、修饰符存储分摊在 Usage 上、查询通过 Database 入口"。
- **数据库由 `FAngelscriptEngine` 拥有**：不是进程级单例。多 Engine（PIE / 测试）下各自独立，靠 `TryGetCurrentEngine() + LegacyDatabase` 兜底。
- **注册三层**：AS 引擎层（`RegisterObjectType`）、插件桥接层（`FAngelscriptType::Register`）、Type Finder 路由层（`RegisterTypeFinder`）。`Bind_*.cpp` 的 `FBind` 闭包按 EOrder 调度，`FAngelscriptEngine::BindScriptTypes` 一次性执行。
- **类型查询四入口 + TypeFinder**：`GetByAngelscriptTypeName` / `GetByClass` / `GetByData` / `GetByProperty`；其中 `GetByProperty` 优先走 TypeFinder（细分容器/智能指针），否则遍历 `TypesImplementingProperties`。`FromProperty` 在此之上把 const/ref/CPF flag 折进 Usage。
- **子类家族 50+ 个**：分 POD、UE Object、UE Struct、UE Enum、容器/特殊五族。每个子类 override 30+ 虚方法的子集，把抽象操作（CreateProperty / SetArgument / EmitReferenceInfo / GetHash）变成具体行为。
- **模板的"延迟实例化"**：`TArray<T>` 在 AS 引擎里**只注册 1 份字节码模板** + `TemplateCallback` 校验，不同 `T` 共享 method 表。`FAngelscriptArrayType` 通过 `Usage.SubTypes[0]` 解读元素类型。`SetArrayTemplateTypeInfo` 提供模板锚点。
- **`FAngelscriptBindDatabase` 与 `FAngelscriptTypeDatabase` 分工明确**：前者是 cooked 期持久化的 C++ 反射元数据缓存（`Script/Binds.Cache`），后者是运行期 `FAngelscriptType` 实例库。BindDatabase **不**参与脚本类型注册（那是 ClassGenerator 的事）。
- **生命周期协同的硬约束**：销毁顺序必须是 `AS Engine ShutDown → TypeDatabase.Reset → UE GC`。`asITypeInfo->SetUserData(UScriptStruct*)` 是裸指针反持有，UE 类型必须先于 AS 类型存在、后于 AS 类型销毁。
- **本文边界**：`Type_Core` 写底层映射；`Type_BindSystem` 写 `Bind_*.cpp` 应用组织；`Type_ClassGeneration` / `Type_StructGeneration` 写"脚本声明 → UE 反射对象"的链路。三者共享同一份 `FAngelscriptType` 数据模型。

---

## 修订记录

| 版本 | 日期 | 内容 |
|------|------|------|
| v1.0 | 2026-05-24 | 首版：基于 `AngelscriptType.h`(~752 行) / `AngelscriptType.cpp`(~836 行) / `AngelscriptBindDatabase.h`(~136 行) / `AngelscriptBindDatabase.cpp`(~212 行) / `AngelscriptBinds.h`(~714 行) / `AngelscriptBinds.cpp`(~894 行) / `Bind_UStruct.cpp`(~1228 行) / `Bind_BlueprintType.cpp` / `Bind_UEnum.cpp`(~588 行) / `Bind_TArray.cpp`(~1830 行) / `Helper_PODType.h` 完整产出。覆盖：① 三主角数据模型（`FAngelscriptType` 30+ 虚方法、`FAngelscriptTypeUsage` 修饰符快照 + SubTypes 递归、`FAngelscriptTypeDatabase` 四维索引 + 9 个泛型槽 + 模板锚点）；② 数据库由 Engine 拥有 + `LegacyDatabase` 兜底；③ 注册三层链路（AS 引擎 RegisterObjectType / FAngelscriptType::Register / RegisterTypeFinder）+ `Register` 重名警告与同 UClass 多绑 ensure 策略；④ 命名空间约定与名称映射对照；⑤ 类型查询四入口（GetByAngelscriptTypeName / GetByClass / GetByData / GetByProperty）+ TypeFinder 优先策略；⑥ `FromProperty` / `FromTypeId` / `FromReturn` / `FromParam` 工厂集 + CPF_OutParm/ReferenceParm/ConstParm 三态映射；⑦ 子类家族五族划分（POD / UE Object / UE Struct / UE Enum / 容器特殊）+ FUStructType / FUObjectType / FEnumType / FSubclassOfType / FObjectPtrType / FWeakObjectPtrType 关键 override 剖析；⑧ TArray<T> / TMap<K,V> 模板"延迟实例化"两层抽象 + TemplateCallback 校验；⑨ `FAngelscriptBindDatabase` 与 `FAngelscriptTypeDatabase` 职责对照；⑩ 生命周期三套时钟（UE GC × AS RefCount × TSharedRef）协同点 SetUserData 裸指针 + 销毁顺序硬约束；⑪ 与 `Type_ClassGeneration` / `Type_BindSystem` 的边界划分表；⑫ 附录 A 类型映射四列对照速查表（25 行常用类型）+ 附录 B 十条排错 grep 起点。 |
