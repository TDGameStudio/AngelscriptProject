# Syntax_TWeakObjectPtr — `TWeakObjectPtr<T>` UObject 弱引用实现原理

> **所属前缀**: Syntax_（智能指针与引用包装族）
> **关注层面**: 语法机制与实现原理（非用户使用指南）
> **关键源码**:
> `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_BlueprintType.cpp:2313-2665`
> （`FWeakObjectPtrType` 类型 facade + `Bind_TWeakObjectPtr_Declaration` / `Bind_TWeakObjectPtr` 两阶段绑定）
> **关联文档**:
> `Documents/Knowledges/ZH/Syntax_TSoftObjectPtr.md` — 兄弟智能指针，共享同文件注册
> · `Documents/Knowledges/ZH/Syntax_TArray.md` — 容器模板注册的参考对照（`TemplateCallback` 模式）
> · `Documents/Knowledges/ZH/Type_BindSystem.md` — `FAngelscriptType` / `FAngelscriptTypeUsage` 类型系统

---

## 概览

`TWeakObjectPtr<T>` 是 UE 的 UObject 弱引用包装——**不阻止 GC 回收目标对象**，访问前必须检查有效性。在当前 AS 插件中，它被实现为**分两阶段注册的模板值类型**，内部直接映射到 `TWeakObjectPtr<UObject>` 并通过子类型协变支持任意 `UObject` 派生类。

```text
AS 脚本侧                        C++ 实现侧
====================               ====================
TWeakObjectPtr<AActor> Ref;        ValueClass<TWeakObjectPtr<UObject>>("TWeakObjectPtr<class T>")
Ref = SomeActor;                   -> opAssign(T handle_only)
Ref.IsValid()                      -> Ptr->IsValid()
Ref.Get()                          -> Ptr->Get() 返回 T handle_only
AActor Actor = Ref;                -> opImplConv() const 隐式转换
if (Ref == OtherRef) ...           -> opEquals
Ref.IsStale()                      -> Ptr->IsStale()
Ref.IsExplicitlyNull()             -> Ptr->IsExplicitlyNull()
```

### 两阶段注册设计

```text
[阶段 1: EOrder::Early]  Bind_TWeakObjectPtr_Declaration
  - ValueClass<TWeakObjectPtr<UObject>>("TWeakObjectPtr<class T>", {bTemplate, Covariant})
  - 默认构造: new (Ptr) TWeakObjectPtr<UObject>(nullptr)
  - 拷贝构造: new (Ptr) TWeakObjectPtr<UObject>(*Other)
  - 拷贝赋值: *Ptr = *Other
  - TemplateCallback: 校验子类型必须是 UObject 指针

[阶段 2: EOrder::Late-10]  Bind_TWeakObjectPtr
  - 隐式构造: void f(T handle_only Object) -> 从裸指针构造
  - 隐式转换: T opImplConv() const -> Get() 返回裸指针
  - opEquals: 与 TWeakObjectPtr 或裸指针比较
  - opAssign: 从裸指针赋值
  - Get / IsValid / IsStale / IsExplicitlyNull 方法绑定
```

**为什么分两阶段？** 阶段 1 在 `EOrder::Early` 注册模板类型定义（其他绑定的方法签名可能用 `TWeakObjectPtr<T>` 作参数/返回类型）。阶段 2 在 `EOrder::Late-10`（所有 UObject 类型已注册后）补充需要裸指针 ↔ 弱引用互转的方法——这些方法依赖 `T handle_only` 语法，后者要求 T 类型已经注册。

---

## 一、类型 Facade: `FWeakObjectPtrType`

**源码所在**: `Bind_BlueprintType.cpp:2313-2520`。

`FWeakObjectPtrType` 继承自 `TAngelscriptCppType<TWeakObjectPtr<UObject>>`，实现 `FAngelscriptType` 接口将 `TWeakObjectPtr<T>` 桥接到 UE 反射系统。

### 1.1 核心接口映射

| 接口 | 实现 | 作用 |
|------|------|------|
| `GetAngelscriptTypeName` | 返回 `"TWeakObjectPtr"` | dump / 错误信息 |
| `GetObjectClass(Usage)` | `Usage.SubTypes[0].GetClass()` | 解析 T 对应的 UClass |
| `CanCreateProperty` | 检查 SubTypes[0] 有效 + 可解析出 UClass | 决定能否作 UPROPERTY |
| `CreateProperty` | `new FWeakObjectProperty(...)` + 设置 `PropertyClass` | 创建 UE 反射属性 |
| `MatchesProperty` | 检查 `FWeakObjectProperty` + `CPF_UObjectWrapper` + 类匹配 | 参数匹配 |
| `SetArgument` | 从 FFrame 栈取 `TWeakObjectPtr<UObject>`, 按引用/值传给 AS | 与 UFunction 互调 |
| `GetReturnValue` | 从 AS context 取返回的 `TWeakObjectPtr<UObject>` | 函数返回桥接 |
| `GetCppForm` | `TWeakObjectPtr<前缀+类名>` | Codegen / StaticJIT |
| `GetDebuggerValue/Scope/Member` | 委托给 `FUObjectType::FillObject*` | DAP 调试器 |
| `CanQueryPropertyType` | `return false` | 不参与反向类型查询 |
| `DescribesCompleteType` | `SubTypes.Num() >= 1 && SubTypes[0].IsValid()` | 类型完整性 |

### 1.2 `CreateProperty` —— 生成 `FWeakObjectProperty`

```cpp
FProperty* CreateProperty(const FAngelscriptTypeUsage& Usage, const FPropertyParams& Params) const override
{
    UClass* ObjectClass = Usage.SubTypes[0].GetClass();
    check(ObjectClass);

    auto* Property = new FWeakObjectProperty(Params.Outer, Params.PropertyName, RF_Public);
    Property->PropertyClass = ObjectClass;    // 如 AActor, UActorComponent 等

    return Property;
}
```

这使得 `.as` 中的 `UPROPERTY() TWeakObjectPtr<AActor> Target;` 在 UE 反射系统中表现为一个标准的 `FWeakObjectProperty`——编辑器面板显示正确的类过滤器、序列化/反序列化正常工作。

### 1.3 `MatchesProperty` —— 名称回退匹配

```cpp
bool MatchesProperty(const FAngelscriptTypeUsage& Usage, const FProperty* Property, EPropertyMatchType MatchType) const override
{
    const FWeakObjectProperty* ObjectPtrProp = CastField<FWeakObjectProperty>(Property);
    if (ObjectPtrProp == nullptr) return false;
    if ((ObjectPtrProp->PropertyFlags & CPF_UObjectWrapper) == 0) return false;

    UClass* AssociatedClass = GetObjectClass(Usage);
    if (AssociatedClass != nullptr)
    {
        return ObjectPtrProp->PropertyClass == AssociatedClass;       // 直接比较 UClass 指针
    }
    else
    {
        // Workaround: 分析阶段 UClass 还未创建, 退化为字符串名比较
        FString CheckName = ANSI_TO_TCHAR(Usage.SubTypes[0].ScriptClass->GetName());
        CheckName.RemoveFromStart(TEXT("U"));
        CheckName.RemoveFromStart(TEXT("A"));
        FString PropClassName = ObjectPtrProp->PropertyClass->GetName();
        return PropClassName == CheckName;
    }
}
```

名称回退是热重载场景下的安全网——脚本类的 `UASClass` 可能还在 `Setup()` 阶段未创建，此时只能按名字匹配。

---

## 二、阶段 1: 模板声明注册

**源码所在**: `Bind_BlueprintType.cpp:2528-2567`。

```cpp
AS_FORCE_LINK const FAngelscriptBinds::FBind Bind_TWeakObjectPtr_Declaration(
    (int32)FAngelscriptBinds::EOrder::Early, []
{
    FBindFlags Flags;
    Flags.bTemplate = true;
    Flags.TemplateType = "<T>";
    Flags.ExtraFlags = asOBJ_TEMPLATE_SUBTYPE_COVARIANT;      // ★ 子类型协变

    auto TWeakObjectPtr_ = FAngelscriptBinds::ValueClass<TWeakObjectPtr<UObject>>(
        "TWeakObjectPtr<class T>", Flags);

    // 默认构造: 空弱引用
    TWeakObjectPtr_.Constructor("void f()", [](TWeakObjectPtr<UObject>* Ptr)
    {
        new (Ptr) TWeakObjectPtr<UObject>(nullptr);
    });

    // 拷贝构造
    TWeakObjectPtr_.Constructor("void f(const TWeakObjectPtr<T>& Other)",
        [](TWeakObjectPtr<UObject>* Ptr, const TWeakObjectPtr<UObject>* Other)
    {
        new (Ptr) TWeakObjectPtr<UObject>(*Other);
    });

    // 拷贝赋值
    TWeakObjectPtr_.Method("TWeakObjectPtr<T>& opAssign(const TWeakObjectPtr<T>& Other)",
        [](TWeakObjectPtr<UObject>* Ptr, const TWeakObjectPtr<UObject>* Other)
            -> TWeakObjectPtr<UObject>&
    {
        *Ptr = *Other;
        return *Ptr;
    });

    // TemplateCallback: 子类型校验
    TWeakObjectPtr_.TemplateCallback("bool f(int&in Type, int&out ErrorMessage)",
        [](asITypeInfo* TemplateType, asCString* ErrorMessage) -> bool
    {
        if (TemplateType->GetSubTypeCount() != 1)
            return false;
        // ... 校验 SubType 是 UObject 派生类 ...
    });
});
```

关键点：

- **`asOBJ_TEMPLATE_SUBTYPE_COVARIANT`**: `TWeakObjectPtr<UPlayer>` 可隐式视作 `TWeakObjectPtr<UObject>` 的子类型——这使得接受 `TWeakObjectPtr<UObject>` 参数的函数可以传入任何具体类型的弱引用。
- **底层类型统一为 `TWeakObjectPtr<UObject>`**: 所有 `TWeakObjectPtr<T>` 实例化在内存中都是同一个 `TWeakObjectPtr<UObject>`，靠 `SubTypes[0]` 记录实际的 T 类型——与 `TSubclassOf<T>` / `TSoftObjectPtr<T>` 采用相同策略。

---

## 三、阶段 2: 方法补充注册

**源码所在**: `Bind_BlueprintType.cpp:2569-2622`。

```cpp
AS_FORCE_LINK const FAngelscriptBinds::FBind Bind_TWeakObjectPtr(
    (int32)FAngelscriptBinds::EOrder::Late-10, []
{
    auto TWeakObjectPtr_ = FAngelscriptBinds::ExistingClass("TWeakObjectPtr<T>");

    // 隐式构造: 从裸指针创建弱引用
    TWeakObjectPtr_.ImplicitConstructor("void f(T handle_only Object)",
        [](TWeakObjectPtr<UObject>* Ptr, UObject* Object)
    {
        new (Ptr) TWeakObjectPtr<UObject>(Object);
    });

    // 隐式转换: 弱引用 -> 裸指针 (注意: 如果已失效返回 nullptr)
    TWeakObjectPtr_.Method("T handle_only opImplConv() const",
        [](const TWeakObjectPtr<UObject>* Ptr) { return Ptr->Get(); });

    // 等值比较: 弱引用 vs 弱引用
    TWeakObjectPtr_.Method("bool opEquals(const TWeakObjectPtr<T>& Other) const",
        [](const TWeakObjectPtr<UObject>& Self, const TWeakObjectPtr<UObject>& Other) -> bool
        { return Self == Other; });

    // 等值比较: 弱引用 vs 裸指针
    TWeakObjectPtr_.Method("bool opEquals(const T handle_only Other) const",
        [](const TWeakObjectPtr<UObject>& Self, UObject* Other) -> bool
        { return Self == Other; });

    // 赋值: 从裸指针
    TWeakObjectPtr_.Method("TWeakObjectPtr<T>& opAssign(T handle_only Other)",
        [](TWeakObjectPtr<UObject>* Self, UObject* Other)
        { *Self = Other; return Self; });

    // 核心查询方法
    TWeakObjectPtr_.Method("T handle_only Get() const",
        [](TWeakObjectPtr<UObject>* Ptr) { return Ptr->Get(); });

    TWeakObjectPtr_.Method("bool IsValid() const",
        [](TWeakObjectPtr<UObject>* Ptr) { return Ptr->IsValid(); });

    TWeakObjectPtr_.Method("bool IsStale() const",
        [](TWeakObjectPtr<UObject>* Ptr) { return Ptr->IsStale(); });

    TWeakObjectPtr_.Method("bool IsExplicitlyNull() const",
        [](TWeakObjectPtr<UObject>* Ptr) { return Ptr->IsExplicitlyNull(); });
});
```

### 3.1 `handle_only` 关键字

`T handle_only` 是当前 fork 的特殊参数修饰——表示"此参数接受/返回的是**对象指针（句柄）**而不是对象引用"。在 `TWeakObjectPtr` 上下文中：

- `opImplConv` 返回 `T handle_only` = 返回裸 `UObject*`
- `ImplicitConstructor` 接受 `T handle_only` = 接受裸 `UObject*`

这让脚本可以在 `TWeakObjectPtr<T>` 和 `T` 之间**无感转换**：

```angelscript
AActor Actor = SpawnActor(AMyActor);
TWeakObjectPtr<AActor> Ref = Actor;          // 隐式构造
AActor SameActor = Ref;                       // opImplConv (如果已失效返回 nullptr)
```

### 3.2 方法速查

| 方法 | AS 签名 | 语义 |
|------|---------|------|
| **Get** | `T Get() const` | 取裸指针，失效返回 `nullptr` |
| **IsValid** | `bool IsValid() const` | 目标存在且未被 GC |
| **IsStale** | `bool IsStale() const` | 曾有值但目标已被 GC |
| **IsExplicitlyNull** | `bool IsExplicitlyNull() const` | 从未赋值 / 显式赋 `nullptr` |
| **opAssign(T)** | `TWeakObjectPtr<T>& opAssign(T)` | 从裸指针赋值 |
| **opAssign(Ref)** | `TWeakObjectPtr<T>& opAssign(const TWeakObjectPtr<T>&)` | 从另一个弱引用拷贝 |
| **opEquals(Ref)** | `bool opEquals(const TWeakObjectPtr<T>&)` | 比较两个弱引用 |
| **opEquals(T)** | `bool opEquals(T)` | 与裸指针比较 |
| **opImplConv** | `T opImplConv() const` | 隐式转换为裸指针 |

---

## 四、UE 反射桥接

### 4.1 RegisterTypeFinder —— C++ 端 `TWeakObjectPtr<T>` 字段反向解析

**源码所在**: `Bind_BlueprintType.cpp:2638-2665`。

```cpp
auto WeakObjectPtrType = MakeShared<FWeakObjectPtrType>();
FAngelscriptType::Register(WeakObjectPtrType);

FAngelscriptType::RegisterTypeFinder([=](FProperty* Property, FAngelscriptTypeUsage& Usage) -> bool
{
    // Detect TWeakObjectPtr properties
    const FWeakObjectProperty* WeakObjectProperty = CastField<FWeakObjectProperty>(Property);
    if (WeakObjectProperty != nullptr)
    {
        FAngelscriptTypeUsage InnerType = FAngelscriptTypeUsage::FromClass(WeakObjectProperty->PropertyClass);
        if (!InnerType.IsValid())
            return false;

        Usage.Type = WeakObjectPtrType;
        Usage.SubTypes.SetNum(1);
        Usage.SubTypes[0] = InnerType;
        return true;
    }
    // ...
});
```

当 C++ 类暴露 `UPROPERTY() TWeakObjectPtr<AActor> Target;` 给 AS 时：

1. UHT 生成 `FWeakObjectProperty { PropertyClass = AActor::StaticClass() }`；
2. `RegisterTypeFinder` 把 `FWeakObjectProperty` 解析为 `FAngelscriptTypeUsage{ Type=WeakObjectPtrType, SubTypes=[ObjectType(AActor)] }`；
3. AS 端可写 `MyClass.Target.IsValid()` 直接操作。

### 4.2 `CPF_UObjectWrapper` 标志

```cpp
if ((ObjectPtrProp->PropertyFlags & CPF_UObjectWrapper) == 0)
    return false;
```

`MatchesProperty` 中的这个检查确保只匹配标准的 `TWeakObjectPtr` 属性（带 `CPF_UObjectWrapper` 标志），不会误匹配到普通 `UObject*` 字段。

---

## 五、与 `TSubclassOf` / `TSoftObjectPtr` 的共性

三种智能指针/引用包装在当前插件中**共享完全相同的注册模式**：

| 维度 | `TWeakObjectPtr<T>` | `TSubclassOf<T>` | `TSoftObjectPtr<T>` |
|------|---------------------|-------------------|---------------------|
| 源文件 | `Bind_BlueprintType.cpp` | 同 | `Bind_TSoftObjectPtr.cpp` |
| 底层 C++ 类型 | `TWeakObjectPtr<UObject>` | `TSubclassOf<UObject>` | `TSoftObjectPtr<UObject>` |
| 模板协变 | `asOBJ_TEMPLATE_SUBTYPE_COVARIANT` | 同 | 同 |
| 两阶段注册 | Early + Late-10 | 同 | 同 |
| `handle_only` | `opImplConv / ImplicitConstructor` | 同 | 部分 |
| UE 反射属性 | `FWeakObjectProperty` | `FClassProperty` | `FSoftObjectProperty` |
| GC 交互 | **不阻止 GC**（弱引用本质） | **不阻止 GC**（仅持有 UClass 指针） | **不阻止 GC**（路径引用） |

---

## 六、关键限制与用法注意

### 6.1 弱引用不阻止 GC

```angelscript
TWeakObjectPtr<AActor> Ref = SpawnActor(AMyActor);
// ... 之后 GC 回收了这个 Actor ...
if (Ref.IsValid())        // false
    Ref.Get();            // 不会进入
```

脚本作者**必须**在使用前调 `IsValid()`（或直接用隐式转换 + null 检查）。

### 6.2 `IsStale` vs `IsExplicitlyNull` vs `IsValid`

| 方法 | 含义 | 典型场景 |
|------|------|---------|
| `IsValid()` | 目标存在且可访问 | 常规使用前检查 |
| `IsStale()` | 曾经有效，但目标已被 GC/销毁 | 检测"曾经持有但已过期" |
| `IsExplicitlyNull()` | 从未赋值 / 显式赋了 `nullptr` | 区分"初始状态"与"曾持有后失效" |

```text
创建后未赋值:            IsValid=false, IsStale=false, IsExplicitlyNull=true
赋值有效对象:            IsValid=true,  IsStale=false, IsExplicitlyNull=false
对象被 GC 回收后:        IsValid=false, IsStale=true,  IsExplicitlyNull=false
显式赋 nullptr:          IsValid=false, IsStale=false, IsExplicitlyNull=true
```

### 6.3 隐式转换的安全性

```angelscript
AActor Actor = Ref;                           // opImplConv -> 可能返回 nullptr!
if (Actor != nullptr)
    Actor.DoSomething();                      // 安全

// 等价但更简洁的写法:
if (Ref.IsValid())
    Ref.Get().DoSomething();
```

`opImplConv` 内部就是 `Ptr->Get()`——如果对象已失效返回 `nullptr`。不会抛异常，但**使用方有责任判空**。

### 6.4 不支持嵌套在容器中

```angelscript
TArray<TWeakObjectPtr<AActor>> Arr;           // ✗ 编译期报错
```

与 `TArray`/`TMap`/`TSet` 的嵌套限制一致——所有容器的 `CanBeTemplateSubType() = false`。变通：用 struct 包一层。

---

## 七、关键结论速查

| 主题 | 结论 |
|------|------|
| **不是独立 Bind 文件** | 实现在 `Bind_BlueprintType.cpp:2313-2665`，与 `TSubclassOf`/`TSoftObjectPtr` 共享同文件 |
| **两阶段注册** | `EOrder::Early`（模板定义+基础构造/拷贝）→ `EOrder::Late-10`（隐式转换+裸指针互操作） |
| **底层统一为 `TWeakObjectPtr<UObject>`** | 所有 `T` 实例化共享同一内存布局，靠 `SubTypes[0]` 区分具体类型 |
| **子类型协变** | `asOBJ_TEMPLATE_SUBTYPE_COVARIANT` 让 `TWeakObjectPtr<UPlayer>` 可传给 `TWeakObjectPtr<UActor>` 参数 |
| **隐式双向转换** | `ImplicitConstructor`（裸指针→弱引用）+ `opImplConv`（弱引用→裸指针），脚本中无感 |
| **UE 反射桥** | `CreateProperty` 创建 `FWeakObjectProperty`；`RegisterTypeFinder` 反向解析 |
| **弱引用核心语义** | 不阻止 GC；使用前必须 `IsValid()`；`Get()` 失效返回 `nullptr` |
| **三种状态查询** | `IsValid`（可用）/ `IsStale`（曾有效但已过期）/ `IsExplicitlyNull`（从未赋值或显式 null） |
| **调试器支持** | `GetDebuggerValue/Scope/Member` 委托给 `FUObjectType::FillObject*`，调试面板正常展开 |
| **与兄弟智能指针** | 与 `TSubclassOf` / `TSoftObjectPtr` 共享完全相同的注册模式（两阶段+协变+handle_only） |

---

## 八、关联文档

- 兄弟智能指针：
  - `Documents/Knowledges/ZH/Syntax_TSoftObjectPtr.md` — TSoftObjectPtr / TSoftClassPtr 软引用（待写）
  - `Documents/Knowledges/ZH/Syntax_TSubclassOf.md` — TSubclassOf<T> 类型安全引用（待写）
- 容器参考：
  - `Documents/Knowledges/ZH/Syntax_TArray.md` — 模板容器注册模式（`TemplateCallback` / `EOrder::Early`）
- 类型系统：
  - `Documents/Knowledges/ZH/Type_BindSystem.md` — `FAngelscriptType` / `FAngelscriptTypeUsage` 多态分派
  - `Documents/Knowledges/ZH/Type_ClassGeneration.md` — `UASClass` 生成链路（CreateProperty 共用）
- 核心源码：
  - `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_BlueprintType.cpp:2313-2665` — 完整实现
- 测试覆盖：
  - `Plugins/Angelscript/Source/AngelscriptTest/GC/AngelscriptGCTests.cpp` — GC 与弱引用相关
  - `Plugins/Angelscript/Source/AngelscriptTest/ClassGenerator/AngelscriptASClassReferenceSchemaTests.cpp` — 引用 Schema 测试

---

## 九、修订记录

| 版本 | 日期 | 内容 |
|------|------|------|
| v1.0 | 2026-04-29 | 首版：基于 `Bind_BlueprintType.cpp:2313-2665`（`FWeakObjectPtrType` facade 完整实现 + `Bind_TWeakObjectPtr_Declaration` 阶段 1 + `Bind_TWeakObjectPtr` 阶段 2 + `RegisterTypeFinder` 反射桥）完整产出。覆盖：① 两阶段注册设计动机（Early 模板定义 + Late-10 裸指针互操作）；② `FWeakObjectPtrType` 接口职责映射（CreateProperty / MatchesProperty / SetArgument / GetReturnValue / 调试器）；③ 阶段 1 注册细节（`asOBJ_TEMPLATE_SUBTYPE_COVARIANT` / `TWeakObjectPtr<UObject>` 底层统一 / TemplateCallback 校验）；④ 阶段 2 方法补充（`ImplicitConstructor` / `opImplConv` / `opEquals` / `opAssign` / `Get` / `IsValid` / `IsStale` / `IsExplicitlyNull`）+ `handle_only` 关键字含义；⑤ UE 反射双向桥（`FWeakObjectProperty` 创建 + `RegisterTypeFinder` 反向解析 + `CPF_UObjectWrapper` 标志 + 名称回退匹配）；⑥ 与 `TSubclassOf` / `TSoftObjectPtr` 的共性对比表；⑦ 4 项关键限制（不阻止 GC / 三种状态查询 / 隐式转换安全 / 不支持容器嵌套）。 |
