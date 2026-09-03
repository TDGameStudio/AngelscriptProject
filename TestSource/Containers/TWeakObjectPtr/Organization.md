# TWeakObjectPtr TestSource 整理记录

- 日期: 2026-08-27
- 范围: 仅 `TestSource/Containers/TWeakObjectPtr`
- 状态: 约定已落地；`Function/` `Advance/` `Lifetime/` `UClass/` `Reject/` `Negative/` 已按 harness 收口。
- 已做: 去掉文件名 `Test_` 前缀与 `Positive_0N` / `Negative_0N` 编号命名；按 harness 拆目录；`// Theme:` 行注释换成 UE `/** */` 块注释；`Observe_` 前缀去掉，种类靠 `@Kind` 识别。

约定对齐 `../TArray/Organization.md`、`../TMap/Organization.md`、`../TOptional/Organization.md`。本目录是**对象包装器**（`ETemplateFamily::ObjectWrapper`），与值容器有几处结构性差异，见 §3。

---

## 1. 约定：按 harness 归文件，不按模式拆文件

| 文件角色 | 放什么 | 种类怎么标 |
|---|---|---|
| 函数文件 | 能编译的全局函数 / 脚本函数 | 函数注释 `@Kind Observe` 或 `@Kind RoundTrip` |
| UCLASS 文件 | TWeakObjectPtr 挂在 `UPROPERTY`，或循环引用形状 | `NewObject` 宿主 `@Kind Observe` |
| 生命周期文件 | 依赖 GC / 失效的状态转移 | 文件头 `@Harness Lifetime`；`@Kind Observe` |
| 组合 Advance 文件 | 多步 / 往返 / 槽位复用 | 文件头 `@Harness Advance`；`@Kind Observe` 或 `RoundTrip` |
| 编译失败文件 | 整份源码就是非法程序 | 文件头 `@Kind CompileReject`；**一个失败程序一个文件** |

函数名写行为，不写 `Observe_` / `_Nominal` / `Positive_0N` 前缀。种类靠注释识别。

### 注释格式（UE `/** */`，给扫描器认）

文件头一块，每个入口函数正上方一块；**函数文档和声明之间不要空行**。标签一行一个 `@Name value`：

| 标签 | 写在哪 | 含义 |
|---|---|---|
| `@Theme` | 文件头 | `Containers.TWeakObjectPtr` |
| `@Subject` | 文件头 | 本文件测的 API / 题材 |
| `@Harness` | 文件头，单值 | `Function` / `Advance` / `Lifetime` / `UClass` / `CompileReject` / `RuntimeException` |
| `@Tag` | 文件头，**仅一个** | `Containers.TWeakObjectPtr.<FileStem>`，与文件名 1:1 |
| `@Namespace` | 文件头 | `TWeakObjectPtrTest` |
| `@Kind` | **每个测试案例一块** | `Observe` / `RoundTrip` / `WorldStory` / `CompileReject` / `RuntimeException` |
| `@Covers` | 函数 | 被测 surface，如 `TWeakObjectPtr.IsValid` |
| `@Inputs` / `@Return` / `@Param` / `@Boundary` | 函数 | 同其它目录 |

Function harness 里**每个测试案例都标 `UFUNCTION()`**，`/** */` 紧挨在 `UFUNCTION()` 上方。

### 同一个入口函数里能放什么 `@Kind`

一个 `@Tag` 模块可以有多个入口函数，但 **每个入口函数只有一个 `@Kind`**。

| `@Kind` | 能否作为本模块第二个入口 | 原因 |
|---|---|---|
| `Observe` | 能 | 同题材本地步骤 |
| `RoundTrip` | **能**：`const&in` / `&out` / `&inout` 各一条。每个案例自包含，不抽 Helper |
| `WorldStory` | 不能 | 需要 SpawnActor；本目录无 Actor 壳 |
| `RuntimeException` | 能，但本目录无 Throw 面（见 §3.2） | 会抛，不能再返回 bool |
| `CompileReject` | 不能 | 整模块编不过 |

**不能混进同一 `.as` 的：** 正例与任何 CompileReject；正例 Observe/RoundTrip 与任何 RuntimeException；两个独立 CompileReject 合成一个文件。

---

## 2. 目录分类（已落地）

```text
TestSource/Containers/TWeakObjectPtr/
  Organization.md          本笔记
  Function/                能编译的全局函数 / Observe / RoundTrip
  Advance/                 组合正例（@Harness Advance）
  Lifetime/                GC / 失效题材（@Harness Lifetime）★ 本族新增
  UClass/                  TWeakObjectPtr 作为 UPROPERTY / 循环引用形状
  Reject/                  模板子类型 CompileReject
  Negative/                交叉容器 CompileReject
```

`@Tag` 仍是 `Containers.TWeakObjectPtr.<FileStem>`，不因进子目录而改第三段。

## 3. 与值容器的结构性差异

### 3.1 没有元素类型后缀六件套

TOptional 的 `int / FString / FName / bool / FVector / UObject` 六件套来自它是**值容器**，元素类型可以自由替换。`TWeakObjectPtr<T>` 的 `T` 被 `ValidateObjectTemplate` 约束为 **UObject 派生类**，套类型后缀没有意义。

本目录的维度换成：**目标类形态**（`UObject` / `AActor`）与**状态三元组**（valid / stale / explicitly-null）。

### 3.2 没有 Exception 目录（Throw 面为空）

`Bind_BlueprintType.cpp` 里 `TWeakObjectPtr` 的 12 个方法**没有任何一个 Throw**：

- `Get()` 在目标失效时返回 **nullptr**，不是抛异常
- `IsValid()` / `IsStale()` / `IsExplicitlyNull()` 纯查询
- `opEquals` 与 `opAssign` 不校验目标存活状态

所以本目录**不建 `Exception/`**。失效的可观察行为走 `Lifetime/`，不抛。

（对比：`../TSubclassOf` 的 `Set` / 隐式构造在类型不匹配时**会 Throw**，那个目录才有 Exception。）

### 3.3 新增 `Lifetime/` harness

值容器没有「目标会消失」的概念。弱指针有，且失效只能在 GC 之后观察，和单 API 的 Function 观测方式不同（需要先构造、再释放、再 `CollectGarbage`、再复查）。这类入口单列 `Lifetime/`，文件头 `@Harness Lifetime`，`@Kind` 仍是 `Observe` / `RoundTrip`。

`Lifetime/` 的入口**可以**调 `CollectGarbage()`；`Function/` 的入口一律不调，保持纯函数语义。

### 3.4 交叉容器规则与值容器相反

值容器的规则是「容器不能套容器」。对象包装器不同：

- **非法**：`TWeakObjectPtr<TWeakObjectPtr<UObject>>`（包装器套包装器）→ `Negative/`
- **合法**：`TArray<TWeakObjectPtr<AActor>>`（容器装包装器）。这是一层容器 + 一层包装器，不是容器套容器，是弱指针最常用的真实形状之一。

所以本目录的 `Negative/` 只收包装器套包装器，`TArray<TWeakObjectPtr<...>>` 的正例留在 `UClass/` 或 `Function/`，不要误判为非法。

---

## 4. Bind 权威

`Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_BlueprintType.cpp`，`Bind_BlueprintType_WeakObjectPtr` 段（约 2896–2945 行）。12 个入口：

| # | 入口 | 签名要点 | 位置 |
|---|---|---|---|
| 1 | Construct | `void f()` | `Function/TWeakObjectPtrEmptyConstruction` |
| 2 | CopyConstruct | `void f(const TWeakObjectPtr<T>&)` | `Function/TWeakObjectPtrAssign` |
| 3 | ImplicitConstruct | `void f(T handle_only Object)` | `Function/TWeakObjectPtrAssign` |
| 4 | opImplConv | `T handle_only opImplConv() const` | `Function/TWeakObjectPtrAssign` |
| 5 | opAssign（指针） | `TWeakObjectPtr<T>& opAssign(const TWeakObjectPtr<T>&)` | `Function/TWeakObjectPtrAssign` |
| 6 | opAssign（对象） | `TWeakObjectPtr<T>& opAssign(T handle_only)` | `Function/TWeakObjectPtrAssign` |
| 7 | opEquals（指针） | `bool opEquals(const TWeakObjectPtr<T>&) const` | `Function/TWeakObjectPtrValidity` |
| 8 | opEquals（对象） | `bool opEquals(const T handle_only) const` | `Function/TWeakObjectPtrAssign` |
| 9 | Get | `T handle_only Get() const` | `Function/TWeakObjectPtrValidity` |
| 10 | IsValid | `bool IsValid() const` | `Function/TWeakObjectPtrValidity` |
| 11 | IsStale | `bool IsStale() const` | `Function/TWeakObjectPtrValidity` |
| 12 | IsExplicitlyNull | `bool IsExplicitlyNull() const` | `Function/TWeakObjectPtrValidity` |

实现见 `FAngelscriptBlueprintTypeBinds`（同文件 318–336 行）。

### 4.1 状态三元组

三个谓词是**独立轴**，不是同一个问题的三种问法：

| 状态 | IsValid | IsStale | IsExplicitlyNull | 触发 |
|---|---|---|---|---|
| 默认构造 | false | false | **true** | `TWeakObjectPtr<UObject> W;` |
| 持有活对象 | **true** | false | false | `W = Obj;` |
| 手工清空 | false | false | **true** | `W = nullptr;` |
| 目标已被回收 | false | **true** | false | 目标释放后 `CollectGarbage()` |

「失效」与「显式空」的区别是 `Lifetime/TWeakObjectPtrInvalidation` 的核心不变量。

---

## 5. 当前文件盘点

### 5.1 `Function/`

`TWeakObjectPtrEmptyConstruction`（空不变量 + 三方向）、`TWeakObjectPtrAssign`（赋值 + 隐式转换 + 三方向）、`TWeakObjectPtrValidity`（状态三元组 + 三方向）。清单见 `Function/Coverage.md`。

### 5.2 `Lifetime/`

`TWeakObjectPtrInvalidation`（释放后失效、失效 ≠ 显式空、手工清空、弱引用不保活）。

### 5.3 `UClass/`

`TWeakObjectPtrProperty`（UPROPERTY 空/赋值/每实例独立 + 强前向弱回指打破循环 + 清空回指）。

### 5.4 `Advance/`

`TWeakObjectPtrSequence`（重复 assign/clear 周期、槽位复用、跨边界传递与隐式转换回读）。

### 5.5 `Reject/`

`TWeakObjectPtrMissingTypeArgs`、`TWeakObjectPtrOfStruct`、`TWeakObjectPtrOfPrimitive`。

### 5.6 `Negative/`

`TWeakObjectPtrNestedLocal`（`TWeakObjectPtr<TWeakObjectPtr<UObject>>`）。

---

## 6. 暂不处理

- 不改目录外 OpenSpec / Generation 契约（仍可能指向旧 `Test_TWeakObjectPtr_*` 路径）
- 不把 `Test_GCReachabilityAndWeakInvalidationBoundary` 的 GC 边界断言搬进 `Lifetime/`（依赖 C++ fixture，需先确认 harness 支持）
- 不写 `IsStale()` 为 true 的强断言（依赖 GC 时序，只在 `Lifetime/` 里观察失效，不对 stale 位做硬断言）
- 不写 SpawnActor 活引用（`NewObject` 已够，无 WorldStory 题材）
- 不建 `Exception/`（Throw 面为空，见 §3.2）
