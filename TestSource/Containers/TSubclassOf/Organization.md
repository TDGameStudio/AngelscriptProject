# TSubclassOf TestSource 整理记录

- 日期: 2026-08-27
- 范围: 仅 `TestSource/Containers/TSubclassOf`
- 状态: 约定已落地；`Function/` `Advance/` `Exception/` `UClass/` `Reject/` `Negative/` 已按 harness 收口。
- 已做: 去掉文件名 `Test_` 前缀与 `Positive_0N` / `Negative_0N` 编号命名；按 harness 拆目录；`// Theme:` 行注释换成 UE `/** */` 块注释；`Observe_` 前缀去掉，种类靠 `@Kind` 识别。

约定对齐 `../TArray/Organization.md` 与本族的 `../TWeakObjectPtr/Organization.md`。本目录是**类包装器**（`ETemplateFamily::ClassWrapper`），与 `TSoftClassPtr` 同族，与值容器有结构性差异。

---

## 1. 约定：按 harness 归文件，不按模式拆文件

| 文件角色 | 放什么 | 种类怎么标 |
|---|---|---|
| 函数文件 | 能编译的全局函数 / 脚本函数 | 函数注释 `@Kind Observe` 或 `@Kind RoundTrip` |
| UCLASS 文件 | TSubclassOf 挂在 `UPROPERTY`，或作工厂使用 | `NewObject` 宿主 `@Kind Observe` |
| 运行时异常文件 | 能编译；调用入口后 Throw | 文件头 `@Harness RuntimeException`；每个入口 `@Kind RuntimeException` |
| 组合 Advance 文件 | 多步 / 往返 / 工厂槽位 | 文件头 `@Harness Advance`；`@Kind Observe` 或 `RoundTrip` |
| 编译失败文件 | 整份源码就是非法程序 | 文件头 `@Kind CompileReject`；**一个失败程序一个文件** |

函数名写行为，不写 `Observe_` / `_Nominal` / `Positive_0N` 前缀。种类靠注释识别。

### 注释格式（UE `/** */`，给扫描器认）

文件头一块，每个入口函数正上方一块；**函数文档和声明之间不要空行**。标签一行一个 `@Name value`：

| 标签 | 写在哪 | 含义 |
|---|---|---|
| `@Theme` | 文件头 | `Containers.TSubclassOf` |
| `@Subject` | 文件头 | 本文件测的 API / 题材 |
| `@Harness` | 文件头，单值 | `Function` / `Advance` / `UClass` / `CompileReject` / `RuntimeException` |
| `@Tag` | 文件头，**仅一个** | `Containers.TSubclassOf.<FileStem>`，与文件名 1:1 |
| `@Namespace` | 文件头 | `TSubclassOfTest` |
| `@Kind` | **每个测试案例一块** | `Observe` / `RoundTrip` / `WorldStory` / `CompileReject` / `RuntimeException` |
| `@Covers` | 函数 | 被测 surface，如 `TSubclassOf.IsChildOf` |
| `@Inputs` / `@Return` / `@Param` / `@Boundary` | 函数 | 同其它目录 |

Function harness 里**每个测试案例都标 `UFUNCTION()`**，`/** */` 紧挨在 `UFUNCTION()` 上方。

**不能混进同一 `.as` 的：** 正例与任何 CompileReject；正例 Observe/RoundTrip 与任何 RuntimeException；两个独立 CompileReject 合成一个文件。

---

## 2. 目录分类（已落地）

```text
TestSource/Containers/TSubclassOf/
  Organization.md          本笔记
  Function/                能编译的全局函数 / Observe / RoundTrip
  Advance/                 组合正例（@Harness Advance）
  Exception/               类不匹配时 Throw（@Harness RuntimeException）
  UClass/                  TSubclassOf 作为 UPROPERTY / 工厂用法
  Reject/                  模板子类型 CompileReject
  Negative/                交叉容器 CompileReject
```

`@Tag` 仍是 `Containers.TSubclassOf.<FileStem>`，不因进子目录而改第三段。

## 3. 与值容器 / 弱指针的差异

### 3.1 没有元素类型后缀，维度是类层级

`T` 被约束为 UObject 派生类，TOptional 那套 `int/FString/FVector` 六件套不适用。本目录的维度是**类层级关系**：基类 / 派生类 / 无关类。每个 Function 文件自带 dummy `UCLASS` 三件套（Base / Derived / Unrelated）来表达层级，不依赖外部类。

### 3.2 有 Exception 目录（Throw 面非空）★ 与 TWeakObjectPtr 的关键差异

`Bind_TSubclassOf.h` 的 `ImplicitConstruct` 与 `SetClass` 在类不匹配时都 Throw：

```cpp
FAngelscriptEngine::Throw("Class set to TSubclassOf<> was not a child of templated class.");
```

且 Throw 之后 `*Ptr = nullptr`，holder 被置空而非保留脏值。

`opAssign(UClass)` 与 `Set` 走**同一个** `SetClass`，所以两者 Throw 行为一致 —— 这是 `Exception/TSubclassOfClassNotChild` 同时覆盖三条写入路径（Set / 隐式构造 / opAssign）的原因。

对比：同族的 `../TWeakObjectPtr` 零 Throw（`Get()` 失效返回 nullptr），所以那个目录**不建 `Exception/`**。

### 3.3 交叉容器规则

- **非法**：`TSubclassOf<TSubclassOf<UObject>>`（包装器套包装器）→ `Negative/`
- **合法**：`TArray<TSubclassOf<AActor>>`（容器装包装器）。一层容器 + 一层包装器，不是容器套容器

---

## 4. Bind 权威

`Binds/Bind_BlueprintType.cpp` 的 `Bind_BlueprintType_SubclassOf` 段（约 2836–2889 行），实现在 `Binds/Bind_TSubclassOf.h` 的 `FAngelscriptSubclassOfHelpers`。

| # | 入口 | 签名 | 位置 |
|---|---|---|---|
| 1 | Construct | `void f()` | `Function/TSubclassOfEmptyConstruction` |
| 2 | CopyConstruct | `void f(const TSubclassOf<T>&)` | `Function/TSubclassOfAssign` |
| 3 | ImplicitConstruct | `void f(UClass Class)` **Throw** | `Exception/TSubclassOfClassNotChild` |
| 4 | `opImplConv`（UClass） | `UClass opImplConv() const` | `Function/TSubclassOfAssign` |
| 5 | `opImplConv`（UObject） | `UObject opImplConv() const` | `Function/TSubclassOfAssign` |
| 6 | `opAssign`（holder） | `TSubclassOf<T>& opAssign(const TSubclassOf<T>&)` | `Function/TSubclassOfAssign` |
| 7 | `opAssign`（UClass） | `void opAssign(UClass Class)` **Throw** | `Exception/TSubclassOfClassNotChild` |
| 8 | `Set` | `void Set(UClass Class) const` **Throw** | `Exception/TSubclassOfClassNotChild` |
| 9 | `opEquals`（holder） | `bool opEquals(const TSubclassOf<T>&) const` | `Function/TSubclassOfAssign` |
| 10 | `opEquals`（UClass） | `bool opEquals(UClass Other) const` | `Function/TSubclassOfAssign` |
| 11 | `Get` | `UClass Get() const` | `Function/TSubclassOfTypeCheck` |
| 12 | `IsValid` | `bool IsValid() const` | `Function/TSubclassOfEmptyConstruction` |
| 13 | `IsChildOf` | `bool IsChildOf(UClass Other) const` | `Function/TSubclassOfTypeCheck` |
| 14 | `GetDefaultObject` | `T handle_only GetDefaultObject() const` | `Function/TSubclassOfTypeCheck` |

`IsChildOf` 对 nullptr 返回 false 而不抛（`Class != nullptr && Other != nullptr && ...`）。
`GetDefaultObject` 在 null 时返回 nullptr 而不抛。

---

## 5. 当前文件盘点

### 5.1 `Function/`

`TSubclassOfEmptyConstruction`（空不变量 + 三方向）、`TSubclassOfAssign`（赋值 / Set / 隐式转换 / 独立拷贝 + 三方向）、`TSubclassOfTypeCheck`（IsChildOf 三关系 / nullptr 边界 / CDO + 三方向）。清单见 `Function/Coverage.md`。

### 5.2 `Exception/`

`TSubclassOfClassNotChild`（Set 无关类、隐式构造无关类、opAssign 无关类、基类塞进派生 holder）。

### 5.3 `UClass/`

`TSubclassOfProperty`（UPROPERTY 空/赋值/层级/每实例 + 直接作工厂 + 清空后层级失效）。

### 5.4 `Advance/`

`TSubclassOfSequence`（重复 set/clear 周期、可配置工厂槽位、跨边界层级查询、收窄）。

### 5.5 `Reject/`

`TSubclassOfMissingTypeArgs`、`TSubclassOfOfStruct`。

### 5.6 `Negative/`

`TSubclassOfNestedLocal`。

---

## 6. 暂不处理

- 不改目录外 OpenSpec / Generation 契约（仍可能指向旧 `Test_TSubclassOf_*` 路径）
- 不迁移错位文件：`Test_GetAllComponentsFiltersSubclassesAndAppends` 测的是组件查询而非 TSubclassOf API，归属需与 `Feature/` 协调后再动
- 不建 `Lifetime/`（TSubclassOf 持有 UClass，不涉及目标失效，无 GC 题材）
- 不写 SpawnActor 活引用（`NewObject` 已够验证工厂用法，无 WorldStory 题材）
- 不写 hot-reload 期间 `bWillBecomeCorrect` 的宽容路径（依赖 `AS_CAN_HOTRELOAD` 与 reinstancing 时序）
