# Type_StructGeneration — 脚本结构体生成机制

> **所属前缀**: Type_（类型系统与生成链路族）
> **关注层面**: 架构与实现原理（非用户使用指南）
> **关键源码**:
> `Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator/ASStruct.h` (61 行)
> · `ClassGenerator/ASStruct.cpp` (261 行，`FASStructOps` 核心 + `UASStruct` 实现)
> · `ClassGenerator/AngelscriptClassGenerator.cpp:2740-2790`（`CreateFullReloadStruct`）+ `L3215-3253`（`DoFullReloadStruct`）
> **关联文档**:
> `Documents/Knowledges/ZH/Type_ClassGeneration.md` — 类生成总览（本文是其 §Step 3 子流程的展开）
> · `Documents/Knowledges/ZH/Syntax_UPROPERTY.md` — 结构体属性也走 `AddClassProperties` → `CreateProperty` 链路

---

## 概览

脚本结构体（`struct`）在 AS 脚本中声明后，由 ClassGenerator 转换为 `UASStruct`（继承自 `UScriptStruct`），使其完全融入 UE 反射 / 序列化 / 蓝图系统。与类（`UASClass`）的最大区别：**结构体是纯值类型**——没有构造器分派、没有继承链、没有 GC 追踪（靠所在容器/属性的 Schema），但需要自定义 `ICppStructOps` 来支持构造 / 析构 / 拷贝 / 相等比较 / 哈希。

```text
============================================================================
  结构体生成全景
============================================================================

[.as 源码]
    struct FMyData
    {
        int Value = 42;
        FString Name;
        bool opEquals(const FMyData& Other) const { return Value == Other.Value; }
        uint32 Hash() const { return uint32(Value); }
        FString ToString() const { return f"FMyData({Value}, {Name})"; }
    }
        |
        | 编译 + 预处理器 -> FAngelscriptClassDesc { bIsStruct=true, ... }
        v
[Phase 1: CreateFullReloadStruct]  (L2740-2790)
    - NewObject<UASStruct> 创建 UE 反射对象
    - 从旧版本继承 Guid (热重载稳定性)
    - SetPropertiesSize(ScriptType->GetSize())
    - NotifyRegistrationEvent (告知 UE 资产系统)
        |
        v
[Phase 2: DoFullReloadStruct]  (L3215-3253)
    - 设置 MinAlignment / PropertyLink
    - Bind() + StaticLink()
    - CreateCppStructOps() -> FASStructOps 实例
    - AddClassProperties() -> FProperty 链生成
    - 热重载: ReplacedStruct->NewerVersion = NewStruct
        |
        v
[运行时]
    - UE 通过 ICppStructOps 调用 Construct / Destruct / Copy / Identical / GetStructTypeHash
    - FASStructOps 把每个操作桥接到 AS 脚本函数:
        Construct   -> ScriptType->beh.construct
        Destruct    -> asCScriptObject::CallDestructor
        Copy        -> asCScriptObject::PerformCopy
        Identical   -> opEquals(const FMyData&) const
        Hash        -> Hash() const
        ToString    -> ToString() const  (非 CppStructOps, 但 GetToStringFunction 暴露)
```

---

## 一、`UASStruct` —— 脚本结构体的 UE 反射代表

**源码所在**: `ASStruct.h:10-54`。

```cpp
UCLASS()
class ANGELSCRIPTRUNTIME_API UASStruct : public UScriptStruct
{
    UASStruct* NewerVersion = nullptr;        // 热重载版本链
    asITypeInfo* ScriptType = nullptr;        // AS 类型对象
    FGuid Guid;                                // 序列化稳定标识
    bool bIsScriptStruct;                      // 是否是脚本定义的（vs C++定义的）

    UScriptStruct* GetNewestVersion();         // 遍历版本链取最新版
    asIScriptFunction* GetToStringFunction() const;  // 取 ToString() 方法（如果有）

    FGuid GetCustomGuid() const override { return Guid; }
    void SetGuid(FName FromName);              // 从名字 SHA1 生成 Guid

    void UpdateScriptType();                   // 软重载时更新脚本指针 + StructFlags
    void PrepareCppStructOps() override;       // 延迟创建 CppStructOps
    ICppStructOps* CreateCppStructOps();        // 创建 FASStructOps
};
```

### 1.1 `Guid` —— 序列化稳定性

```cpp
void UASStruct::SetGuid(FName FromName)
{
    FString HashString = TEXT("Script:");
    HashString += FromName.ToString();
    uint32 HashBuffer[5];
    FSHA1::HashBuffer(*HashString, BufferLength, reinterpret_cast<uint8*>(HashBuffer));
    Guid = FGuid(HashBuffer[1], HashBuffer[2], HashBuffer[3], HashBuffer[4]);
}
```

`Guid` 对序列化至关重要——UE 的 `FStructSerializerBackend` 使用 `GetCustomGuid()` 标识结构体类型。热重载时旧版本的 `Guid` 会被新版本继承（`CreateFullReloadStruct:2768`），保证已保存资产的反序列化不会因类型 ID 变化而失败。

### 1.2 `NewerVersion` 版本链

与 `UASClass::NewerVersion` 相同的设计：热重载时旧 `UASStruct` 不被销毁，挂到新版本的 `NewerVersion` 指针上。`GetNewestVersion()` 在运行时遍历链取最新版本——让仍持有旧指针的 `FStructProperty` 能透明地跟踪到最新定义。

### 1.3 `UpdateScriptType` —— 软重载入口

```cpp
void UASStruct::UpdateScriptType()
{
    FASStructOps* Ops = ((FASStructOps*)GetCppStructOps());
    Ops->SetFromStruct(this);                                    // 重新解析 opEquals/Hash/ToString

    if (Ops->EqualsFunction != nullptr)
        StructFlags = EStructFlags(StructFlags | STRUCT_IdenticalNative);
    else
        StructFlags = EStructFlags(StructFlags & ~STRUCT_IdenticalNative);
}
```

软重载时（仅函数体变更），`UpdateScriptType` 重新从 `asCObjectType` 查找 `opEquals`、`Hash`、`ToString` 方法指针，并更新 `StructFlags`——不需要重建 `UASStruct` 对象。

---

## 二、`FASStructOps` —— CppStructOps 桥接

**源码所在**: `ASStruct.cpp:16-209`。

`FASStructOps` 继承自 `UASStruct::ICppStructOps`（即 `UScriptStruct::ICppStructOps`），是 UE 结构体操作的标准接口。它把 UE 的 `Construct/Destruct/Copy/Identical/GetStructTypeHash` 五个 C++ 虚操作桥接到 AS 脚本函数。

### 2.1 数据结构

```cpp
struct FASStructOps : UASStruct::ICppStructOps
{
    UASStruct* Struct;
    asCObjectType* ScriptType;

    asIScriptFunction* EqualsFunction;        // opEquals(const T&) const -> bool
    asIScriptFunction* ConstructFunction;     // 默认构造函数
    asIScriptFunction* ToStrFunction;         // ToString() const -> FString
    asIScriptFunction* HashFunction;          // Hash() const -> uint32

    FASFakeVTable FakeVTable;                 // UE 5 的 FakeVPtr 机制
};
```

### 2.2 方法解析：`SetFromStruct`

```cpp
void SetFromStruct(UASStruct* InStruct)
{
    ScriptType = (asCObjectType*)InStruct->ScriptType;

    if (ScriptType != nullptr)
    {
        // 构造函数: AS 行为表 beh.construct
        if (ScriptType->beh.construct != 0)
            ConstructFunction = Manager.Engine->GetFunctionById(ScriptType->beh.construct);

        // opEquals: "bool opEquals(const FMyData& Other) const"
        if (ScriptType->GetFirstMethod("opEquals") != nullptr)
        {
            FString EqualsDecl = FString::Printf(
                TEXT("bool opEquals(const %s& Other) const"), StructName);
            EqualsFunction = ScriptType->GetMethodByDecl(TCHAR_TO_ANSI(*EqualsDecl));
        }

        // ToString: "FString ToString() const"
        if (ScriptType->GetFirstMethod("ToString") != nullptr)
            ToStrFunction = ScriptType->GetMethodByDecl("FString ToString() const");

        // Hash: "uint32 Hash() const"
        if (ScriptType->GetFirstMethod("Hash") != nullptr)
            HashFunction = ScriptType->GetMethodByDecl("uint32 Hash() const");
    }
}
```

方法解析是**按签名精确匹配**的——不是 `GetFirstMethod` 就行，还要用 `GetMethodByDecl` 确认完整签名（包括 const 修饰和参数类型）。这避免了重载歧义。

### 2.3 五个桥接操作

| UE 操作 | FASStructOps 方法 | 桥接目标 | 细节 |
|---------|-------------------|---------|------|
| **Construct** | `FASStructOps::Construct` | `beh.construct` | 有构造函数时调 AS 构造；否则 `Memzero` |
| **Destruct** | `FASStructOps::Destruct` | `asCScriptObject::CallDestructor` | 直接调 AS 对象析构器 |
| **Copy** | `FASStructOps::Copy` | `asCScriptObject::PerformCopy` | 按 AS 对象拷贝语义（含非 POD 成员递归拷贝） |
| **Identical** | `FASStructOps::Identical` | `opEquals(const T&) const` | 有 `opEquals` 时调用；否则返回 `false`（不可比较） |
| **GetStructTypeHash** | `FASStructOps::GetStructTypeHash` | `uint32 Hash() const` | 有 `Hash` 方法时调用；否则返回 0 |

### 2.4 `FASFakeVTable` —— UE 5 的 FakeVPtr 机制

```cpp
struct FASFakeVTable : public UE::CoreUObject::Private::FStructOpsFakeVTable
{
    void* Construct;
    void* Destruct;
    void* Copy;
    void* Identical;
    void* GetStructTypeHash;
};

// 构造函数中:
FakeVPtr = &FakeVTable;
FakeVTable.Construct = reinterpret_cast<void*>(&FASStructOps::Construct);
FakeVTable.Destruct  = reinterpret_cast<void*>(&FASStructOps::Destruct);
// ...
FakeVTable.Capabilities.HasDestructor   = true;
FakeVTable.Capabilities.HasCopy         = true;
FakeVTable.Capabilities.HasIdentical    = (EqualsFunction != nullptr);
FakeVTable.Capabilities.HasGetTypeHash  = (HashFunction != nullptr);
FakeVTable.Capabilities.ComputedPropertyFlags |= (HashFunction != nullptr) ? CPF_HasGetValueTypeHash : CPF_None;
```

UE 5 的 `ICppStructOps` 使用 `FakeVPtr` 机制替代传统 C++ 虚函数表——通过 `Capabilities` 位图告诉 UE 哪些操作可用。这让 UE 在序列化/网络复制/编辑器面板中根据能力位做快速分支，不需要尝试调用再检查返回值。

关键能力位映射：

| 能力位 | 设置条件 | 影响 |
|--------|---------|------|
| `HasDestructor` | 恒 true | UE 会在结构体生命周期结束时调 `Destruct` |
| `HasCopy` | 恒 true | UE 用 `Copy` 而不是 `Memcpy` 进行赋值 |
| `HasIdentical` | `EqualsFunction != nullptr` | 编辑器 Diff / 网络复制变量检测可用 |
| `HasGetTypeHash` | `HashFunction != nullptr` | 可用作 `TMap`/`TSet` 的 key |
| `CPF_HasGetValueTypeHash` | `HashFunction != nullptr` | 属性反射级别标记 |

---

## 三、ClassGenerator 中的结构体生成流程

### 3.1 `CreateFullReloadStruct` —— 创建 UE 对象

**源码所在**: `AngelscriptClassGenerator.cpp:2740-2790`。

```text
CreateFullReloadStruct(ModuleData, ClassData):
  [1] 查找并重命名旧版本 (ReplacedStruct)
      FindObject<UASStruct>(Package, UnrealName)
      ReplacedStruct->Rename("FMyData_REPLACED_N")

  [2] NewObject<UASStruct> 创建新的 UE 反射对象
      RF_Public | RF_Standalone | RF_MarkAsRootSet

  [3] 继承 Guid (热重载稳定性)
      if (ReplacedStruct) NewStruct->Guid = ReplacedStruct->Guid;
      else NewStruct->SetGuid(NewStruct->GetFName());   // SHA1 生成

  [4] 设置编辑器元数据 (DisplayName + ClassDesc->Meta)

  [5] 关联 AS ScriptType
      ScriptType->SetUserData(NewStruct)
      SetPropertiesSize(ScriptType->GetSize())

  [6] 通知 UE 资产系统
      NotifyRegistrationEvent(Package, UnrealName, NRT_Struct, NRP_Finished)

  [7] ClassDesc->Struct = NewStruct
```

### 3.2 `DoFullReloadStruct` —— 填充属性与操作

**源码所在**: `AngelscriptClassGenerator.cpp:3215-3253`。

```text
DoFullReloadStruct(ModuleData, ClassData):
  [1] NewStruct->PropertyLink = nullptr          // 清空属性链
  [2] NewStruct->MinAlignment = ScriptType->alignment
  [3] NewStruct->Bind()                          // UE 内部绑定

  [4] ClassDesc->Struct = NewStruct
      NewStruct->ScriptType = ScriptType
      SetPropertiesSize(ScriptType->GetSize())

  [5] CreateCppStructOps() -> FASStructOps        // 创建结构体操作桥
      PrepareCppStructOps()                       // 注册到 UE

  [6] AddClassProperties(ClassDesc)               // 遍历 AS 属性, 创建 FProperty
      SetPropertiesSize(PropertiesSize)

  [7] StaticLink()                                // UE 内部链接
      DestructorLink = nullptr

  [8] 热重载版本链
      if (ReplacedStruct)
          ReplacedStruct->NewerVersion = NewStruct
```

### 3.3 与类重载的顺序关系

在 `PerformReload` 10 步流程中（见 `Type_ClassGeneration.md` §四）：

```text
Step 2: 枚举重载
Step 3: 结构体重载 ← DoFullReloadStruct 在此执行
Step 4: 委托重载
Step 6: 类重载   ← DoFullReloadClass
```

结构体**必须在类之前重载**——因为类属性可能是结构体类型（`UPROPERTY() FMyData Data;`），`AddClassProperties` 需要查到已经就绪的 `UASStruct` 来创建 `FStructProperty`。

---

## 四、脚本结构体的可选契约方法

脚本作者可以在 `struct` 中定义以下方法，`FASStructOps` 会自动识别并桥接：

| 方法 | 签名 | 用途 | 影响 |
|------|------|------|------|
| **构造函数** | （默认构造） | 初始化字段 | Construct 时调用 |
| **`opEquals`** | `bool opEquals(const T& Other) const` | 相等比较 | `HasIdentical=true`，编辑器 Diff / 网络复制 |
| **`Hash`** | `uint32 Hash() const` | 哈希值 | `HasGetTypeHash=true`，可用作 TMap/TSet key |
| **`ToString`** | `FString ToString() const` | 字符串表示 | 调试/日志，`GetToStringFunction()` 暴露 |

全部可选。不实现任何方法的 struct 退化为纯 POD 值类型（Construct 走 `Memzero`，不可比较，不可哈希）。

### 4.1 用法示例

```angelscript
struct FInventoryItem
{
    int32 ItemId;
    int32 Count;
    FString Name;

    // 有了 opEquals -> 可以用 TArray.Contains / Remove / FindIndex
    bool opEquals(const FInventoryItem& Other) const
    {
        return ItemId == Other.ItemId;
    }

    // 有了 Hash -> 可以用作 TMap<FInventoryItem, V> / TSet<FInventoryItem> 的 key
    uint32 Hash() const
    {
        return uint32(ItemId);
    }

    // 有了 ToString -> 调试面板和 f-string 可以直接显示
    FString ToString() const
    {
        return f"Item({ItemId}: {Name} x{Count})";
    }
}
```

---

## 五、与类（`UASClass`）的核心差异

| 维度 | `UASStruct` | `UASClass` |
|------|------------|-----------|
| 继承自 | `UScriptStruct` | `UClass` |
| 语义 | 纯值类型 | UObject 引用类型 |
| 内存 | 栈上 / 嵌入字段 | 堆上（NewObject） |
| 继承 | 无（`SetSuperStruct(nullptr)`） | 支持单继承链 |
| 构造器 | `ICppStructOps::Construct` | `UASClass::StaticXxxConstructor` |
| 析构 | `ICppStructOps::Destruct` | `RuntimeDestroyObject` |
| GC | 不参与（靠所在容器/属性 Schema） | 通过 `UObject` 引用追踪 |
| 默认组件 | 不适用 | `FDefaultComponent` |
| 蓝图可见 | 作 UPROPERTY 字段 / 函数参数 | 可实例化、蓝图继承 |
| 序列化标识 | `Guid`（SHA1 from name） | `UClass::GetPathName()` |
| 热重载 | `NewerVersion` 链 | `NewerVersion` 链（相同设计） |
| CppStructOps | `FASStructOps`（5 个操作桥接） | 不适用（`UClass` 用 `ClassConstructor`） |

---

## 六、设计哲学

### 6.1 为什么结构体没有继承？

```cpp
NewStruct->SetSuperStruct(nullptr);    // L2765
```

UE 的 `UScriptStruct` 技术上支持 `SuperStruct`，但当前 fork 选择不让脚本结构体继承：

```text
+ 原因:
  - AS 脚本结构体是 asCObjectType (值类型), 本身不支持继承层次
  - UE C++ struct 继承主要用于反射 meta 继承, 不是 OOP 继承
  - 保持简单: 结构体就是纯数据包, 行为走 mixin / FunctionLibrary

+ 代价:
  - 不能 "struct FDerived : FBase"
  - 如需复用字段, 必须用组合 (FDerived 内嵌 FBase 字段)
```

### 6.2 为什么 `FASStructOps` 用 `FakeVPtr` 而不是普通虚函数？

UE 5 的 `ICppStructOps` 从传统虚函数表迁移到了 `FakeVPtr` + `Capabilities` 位图。这是 UE 引擎侧的设计，`FASStructOps` 跟随：

```text
+ 优势:
  - 能力位查询是 O(1) 的 bit test, 不需要虚函数调用
  - 每个 struct 的操作集可以**运行时动态决定** (有 opEquals -> 设 HasIdentical)
  - UE 5 的序列化管线严格依赖 Capabilities 位, 不走虚函数分派

- 代价:
  - 实现稍复杂 (需要手动构造 FakeVTable 并填入函数指针)
  - 但只有 5 个操作, 一次性工作量不大
```

### 6.3 为什么 `ToString` 不走 CppStructOps?

`ToString()` 不是 UE `ICppStructOps` 标准接口的一部分（UE 结构体没有通用的 `ToString` 虚函数）。`FASStructOps` 额外存储 `ToStrFunction` 指针，通过 `UASStruct::GetToStringFunction()` 公开给调用方——主要被 `Bind_FString.cpp` 的 `Append(const T&)` 和调试器使用。

---

## 七、关键结论速查

| 主题 | 结论 |
|------|------|
| **核心类型** | `UASStruct` 继承 `UScriptStruct`，表示 AS 脚本定义的值类型结构体 |
| **CppStructOps 桥接** | `FASStructOps` 把 UE 的 Construct/Destruct/Copy/Identical/Hash 五个操作桥接到 AS 脚本函数 |
| **可选契约** | `opEquals`（相等）/ `Hash`（哈希）/ `ToString`（字符串化）全部可选，不实现则能力位关闭 |
| **无继承** | `SetSuperStruct(nullptr)`，结构体不支持继承，走组合 |
| **FakeVPtr** | 跟随 UE 5 `ICppStructOps` 的 `FakeVPtr + Capabilities` 位图机制 |
| **Guid 稳定性** | SHA1 from name，热重载时从旧版本继承，保证序列化兼容 |
| **版本链** | `NewerVersion` 指针链，与 `UASClass` 相同设计 |
| **拓扑排序** | 结构体在类之前重载（Step 3 < Step 6），保证类属性的 `FStructProperty` 能找到就绪的 `UASStruct` |
| **属性生成** | 与类共用 `AddClassProperties` → `FAngelscriptTypeUsage::CreateProperty` 链路 |
| **软重载** | `UpdateScriptType()` 重新解析方法指针 + 更新 `StructFlags`，不重建 `UASStruct` |

---

## 八、关联文档

- 上层架构：
  - `Documents/Knowledges/ZH/Type_ClassGeneration.md` — 类生成总览（本文是其 Step 3 子流程展开）
  - `Documents/Knowledges/ZH/Arch_Overview.md` — 插件总体概览
- 属性与语法：
  - `Documents/Knowledges/ZH/Syntax_UPROPERTY.md` — `FProperty` 创建链路（`AddClassProperties` 共用）
  - `Documents/Knowledges/ZH/Syntax_DefaultStatement.md` — `default` 语句（对结构体字段默认值的影响）
- 运行时：
  - `Documents/Knowledges/ZH/RT_HotReload.md` — 热重载链路（`NewerVersion` / `UpdateScriptType` 的调用者）
- 核心源码：
  - `Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator/ASStruct.h` / `.cpp`
  - `Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator/AngelscriptClassGenerator.cpp:2740-2790, 3215-3253`
- 测试覆盖：
  - `Plugins/Angelscript/Source/AngelscriptTest/ClassGenerator/` — 28 个类/结构体生成测试

---

## 九、修订记录

| 版本 | 日期 | 内容 |
|------|------|------|
| v1.0 | 2026-04-29 | 首版：基于 `ASStruct.h`(61 行) / `ASStruct.cpp`(261 行) / `AngelscriptClassGenerator.cpp:2740-2790, 3215-3253` 完整产出。覆盖：① 全景流程（CreateFullReloadStruct → DoFullReloadStruct → FASStructOps 运行时桥接）；② `UASStruct` 字段详解（NewerVersion 版本链 / Guid 序列化标识 / UpdateScriptType 软重载 / PrepareCppStructOps 延迟创建）；③ `FASStructOps` 五个操作桥接（Construct / Destruct / Copy / Identical / GetStructTypeHash）+ 方法签名精确匹配逻辑 + `FakeVPtr` / `Capabilities` 位图机制；④ `CreateFullReloadStruct` 7 步（NewObject / Guid 继承 / Meta / ScriptType / NotifyRegistration）+ `DoFullReloadStruct` 8 步（Alignment / Bind / CppStructOps / AddClassProperties / StaticLink / 版本链）；⑤ 与类重载的拓扑排序约束；⑥ 可选契约方法（opEquals / Hash / ToString）+ 用法示例；⑦ 与 `UASClass` 核心差异对比表；⑧ 3 个设计哲学（无继承 / FakeVPtr / ToString 非标准）。 |
