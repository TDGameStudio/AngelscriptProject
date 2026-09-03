# TObjectPtr TestSource 整理记录

- 日期: 2026-08-27
- 范围: 仅 `TestSource/Containers/TObjectPtr`
- 状态: 约定已落地；`Function/` `Advance/` `UClass/` `Reject/` `Negative/` 已按 harness 收口。
- 已做: 去掉文件名 `Test_` 前缀；按 harness 拆目录；`// Theme:` 行注释换成 UE `/** */` 块注释；`Observe_` 前缀去掉，种类靠 `@Kind` 识别；Actor 壳（`BeginPlay` + UPROPERTY 计数器）降成函数。

约定对齐 `../TArray/Organization.md` 与本族的 `../TWeakObjectPtr/Organization.md`。本目录是**对象包装器**（`ETemplateFamily::ObjectWrapper`），与 `TWeakObjectPtr` / `TSoftObjectPtr` 同族。

---

## 1. 约定：按 harness 归文件，不按模式拆文件

| 文件角色 | 放什么 | 种类怎么标 |
|---|---|---|
| 函数文件 | 能编译的全局函数 / 脚本函数 | 函数注释 `@Kind Observe` 或 `@Kind RoundTrip` |
| UCLASS 文件 | TObjectPtr 挂在 `UPROPERTY`，或依赖 GC 的保活断言 | `NewObject` 宿主 `@Kind Observe` |
| 组合 Advance 文件 | 多步 / 往返 / 槽位复用 | 文件头 `@Harness Advance`；`@Kind Observe` 或 `RoundTrip` |
| 编译失败文件 | 整份源码就是非法程序 | 文件头 `@Kind CompileReject`；**一个失败程序一个文件** |

函数名写行为，不写 `Observe_` / `Positive_0N` 前缀。种类靠注释识别。

### 注释格式（UE `/** */`，给扫描器认）

文件头一块，每个入口函数正上方一块；**函数文档和声明之间不要空行**。标签一行一个 `@Name value`：

| 标签 | 写在哪 | 含义 |
|---|---|---|
| `@Theme` | 文件头 | `Containers.TObjectPtr` |
| `@Subject` | 文件头 | 本文件测的 API / 题材 |
| `@Harness` | 文件头，单值 | `Function` / `Advance` / `UClass` / `CompileReject` / `RuntimeException` |
| `@Tag` | 文件头，**仅一个** | `Containers.TObjectPtr.<FileStem>`，与文件名 1:1 |
| `@Namespace` | 文件头 | `TObjectPtrTest` |
| `@Kind` | **每个测试案例一块** | `Observe` / `RoundTrip` / `WorldStory` / `CompileReject` / `RuntimeException` |
| `@Covers` | 函数 | 被测 surface，如 `TObjectPtr.Get` |
| `@Inputs` / `@Return` / `@Param` / `@Boundary` | 函数 | 同其它目录 |

Function harness 里**每个测试案例都标 `UFUNCTION()`**，`/** */` 紧挨在 `UFUNCTION()` 上方。

**不能混进同一 `.as` 的：** 正例与任何 CompileReject；正例 Observe/RoundTrip 与任何 RuntimeException；两个独立 CompileReject 合成一个文件。

---

## 2. 目录分类（已落地）

```text
TestSource/Containers/TObjectPtr/
  Organization.md          本笔记
  Function/                能编译的全局函数 / Observe / RoundTrip
  Advance/                 组合正例（@Harness Advance）
  UClass/                  TObjectPtr 作为 UPROPERTY / GC 保活断言
  Reject/                  模板子类型 CompileReject
  Negative/                交叉容器 CompileReject
```

**不建 `Exception/` 与 `Lifetime/`**，原因见 §3.2 与 §3.3。

`@Tag` 仍是 `Containers.TObjectPtr.<FileStem>`，不因进子目录而改第三段。

## 3. 与值容器 / 同族类型的差异

### 3.1 没有元素类型后缀，维度是目标类形态

`T` 被约束为 UObject 派生类，TOptional 那套 `int/FString/FVector` 六件套不适用。维度换成**目标类形态**：`UObject`（规范）/`AActor`/具体脚本类（UPROPERTY 形状）。

### 3.2 没有 Exception 目录（Throw 面为空）

`Bind_BlueprintType.cpp` 里 `TObjectPtr` 的 9 个入口**没有任何一个 Throw**：

- `Get()` 在空指针时返回 nullptr
- `opEquals` 不校验目标存活
- `opAssign` / `opImplConv` 不做类型校验（类型安全由模板实例化保证）

对比：同目录树的 `../TSubclassOf` 有 Throw 面（类不匹配），所以它有 `Exception/`。

### 3.3 没有 Lifetime 目录（无失效题材）

这是 `TObjectPtr` 与 `TWeakObjectPtr` 最本质的差异：

| 指针 | 是否保活 | 目标消失后 | 有无失效题材 |
|---|---|---|---|
| `TObjectPtr` | **保活** | 目标不会消失（强引用） | **无** |
| `TWeakObjectPtr` | 不保活 | `IsStale()` / `IsValid()` 变化 | 有 → `../TWeakObjectPtr/Lifetime/` |

`TObjectPtr` 唯一和 GC 相关的断言是「**强引用让目标存活**」，那是一个**保活正例**而非失效观察，且需要 UPROPERTY 宿主，所以放在 `UClass/TObjectPtrProperty` 而不单建 `Lifetime/`。

### 3.4 交叉容器规则

- **非法**：`TObjectPtr<TObjectPtr<UObject>>`（包装器套包装器）→ `Negative/`
- **合法**：`TArray<TObjectPtr<AActor>>`（容器装包装器）。一层容器 + 一层包装器，不是容器套容器

---

## 4. Bind 权威

`Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_BlueprintType.cpp`，`Bind_BlueprintType_ObjectPtr` 段（约 2795–2829 行）。9 个入口：

| # | 入口 | 签名 | 位置 |
|---|---|---|---|
| 1 | Construct | `void f()` | `Function/TObjectPtrAssign` |
| 2 | CopyConstruct | `void f(const TObjectPtr<T>&)` | `Function/TObjectPtrAssign` |
| 3 | ImplicitConstruct | `void f(T handle_only Object)` | `Function/TObjectPtrAssign` |
| 4 | `opImplConv` | `T handle_only opImplConv() const` | `Function/TObjectPtrAssign` |
| 5 | `opAssign`（指针） | `TObjectPtr<T>& opAssign(const TObjectPtr<T>&)` | `Function/TObjectPtrAssign` |
| 6 | `opAssign`（对象） | `TObjectPtr<T>& opAssign(T handle_only)` | `Function/TObjectPtrAssign` |
| 7 | `opEquals`（指针） | `bool opEquals(const TObjectPtr<T>&) const` | `Function/TObjectPtrValidity` |
| 8 | `opEquals`（对象） | `bool opEquals(const T handle_only) const` | `Function/TObjectPtrValidity` |
| 9 | `Get` | `T handle_only Get() const` | `Function/TObjectPtrValidity` |

实现见同文件 `FAngelscriptBlueprintTypeBinds::ConstructObjectPtr` 等。

**注意：`TObjectPtr` 没有 `IsValid()` / `IsStale()` / `IsExplicitlyNull()`。** 这三个是 `TWeakObjectPtr` 独有的。判断空指针用 `Get() == nullptr`。

---

## 5. 当前文件盘点

### 5.1 `Function/`

`TObjectPtrAssign`（默认空、对象赋值、隐式转换、指针拷贝与独立、nullptr 清空、重分配 + 三方向）、`TObjectPtrValidity`（Get 稳定性、指针相等与独立、指针 vs 对象相等、异目标不等 + 三方向）。清单见 `Function/Coverage.md`。

### 5.2 `UClass/`

`TObjectPtrProperty`（UPROPERTY 三种形状的空/赋值/每实例 + **强引用保活**：`CollectGarbage()` 后仍可解析 + 清空回 null）。

### 5.3 `Advance/`

`TObjectPtrSequence`（重复 assign/clear 周期、槽位复用、跨边界传递与回读、发布/撤回）。

### 5.4 `Reject/`

`TObjectPtrMissingTypeArgs`、`TObjectPtrOfStruct`。

### 5.5 `Negative/`

`TObjectPtrNestedLocal`。

---

## 6. 暂不处理

- 不改目录外 OpenSpec / Generation 契约（仍可能指向旧 `Test_ObjectReference*` / `Test_TObjectPtrRouting` 路径）
- 不迁移错位文件：`Test_NativeInterfaceReferenceHandles`、`Test_HandleSetContainer`、`Test_EnhancedInputBindingHandlesAndRemoval` 测的是接口句柄与输入绑定，不是 TObjectPtr API，归属需与 `Bindings/` 协调后再动
- 不建 `Exception/`（Throw 面为空，见 §3.2）
- 不建 `Lifetime/`（无失效题材，保活断言在 `UClass/`，见 §3.3）
- 不写 SpawnActor 活引用（`NewObject` 已够，无 WorldStory 题材）
