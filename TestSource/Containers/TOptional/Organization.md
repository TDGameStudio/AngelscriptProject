# TOptional TestSource 整理记录

- 日期: 2026-08-27
- 范围: 仅 `TestSource/Containers/TOptional`
- 状态: 约定已落地；`Function/` `Advance/` `Exception/` `Negative/` `Reject/` `UClass/` 按 harness 收口。
- 已做: 去掉原 `Test_TOptional_Mixed_0N` 命名；按 harness 拆成六个子目录；`void Test()` 断言壳去掉，只留真正的入口；`Observe_` / `_Nominal` 前缀去掉，种类靠 `@Kind` 注释识别；CompileReject 一个非法程序一个文件。

本文是本目录的工作笔记，不是 runner 规范，也不改目录外的 OpenSpec / Generation 契约。约定对齐 `../TArray/Organization.md` 与 `../TMap/Organization.md`。

---

## 1. 约定：按 harness 归文件，不按模式拆文件

Observe / RoundTrip 不是主题，只是同一次验证的写法。主题只认目录 `Containers/TOptional`。

| 文件角色 | 放什么 | 种类怎么标 |
|---|---|---|
| 函数文件 | 能编译的全局函数 / 脚本函数 | 函数注释 `@Kind Observe` 或 `@Kind RoundTrip` |
| UCLASS 文件 | TOptional 挂在 `UPROPERTY` | `NewObject` 宿主 `@Kind Observe` |
| 运行时异常文件 | 能编译；调用入口后 Throw | 文件头 `@Harness RuntimeException`；每个入口 `@Kind RuntimeException` |
| 组合 Advance 文件 | 多步 / 往返 / 生命周期组合正例 | 文件头 `@Harness Advance`；`@Kind Observe` 或 `RoundTrip` |
| 编译失败文件 | 整份源码就是非法程序 | 文件头 `@Kind CompileReject`；**一个失败程序一个文件** |

函数名写行为，不写 `Observe_` / `_Nominal` 前缀。种类靠注释识别。

### 注释格式（UE `/** */`，给扫描器认）

一律用 Unreal / Doxygen 块注释，不要用 `// @Kind` 行注释。文件头一块，每个入口函数正上方一块；**函数文档和声明之间不要空行**。

标签一行一个 `@Name value`：

| 标签 | 写在哪 | 含义 |
|---|---|---|
| `@Theme` | 文件头 | 目录主题，`Containers.TOptional` |
| `@Subject` | 文件头 | 本文件测的 API / 题材 |
| `@Harness` | 文件头，单值 | `Function` / `Advance` / `UClass` / `CompileReject` / `RuntimeException` |
| `@Tag` | 文件头，**仅一个** | 格式 `Containers.TOptional.<FileStem>`，与 `.as` 文件名 1:1 |
| `@Namespace` | 文件头 | 脚本命名空间，本目录样板为 `TOptionalTest` |
| `@Kind` | **每个测试案例一块** | `Observe` / `RoundTrip` / `WorldStory` / `CompileReject` / `RuntimeException` |
| `@Covers` | 函数 | 被测 surface，如 `TOptional.IsSet` |
| `@Inputs` | 函数 | 构造与调用 |
| `@Return` | 函数 | 期望观察或返回值 |
| `@Param` | 函数 | 有参数时每个参数一行 |
| `@Boundary` | 函数，可选 | 越界 / unset 状态 |

Function harness 里**每个测试案例都标 `UFUNCTION()`**，并且有完整 `/** */`。`/** */` 紧挨在 `UFUNCTION()` 上方。

示例见 `Function/TOptionalSet.as`。

### 同一个入口函数里能放什么 `@Kind`

一个 `@Tag` 模块可以有多个入口函数，但 **每个入口函数只有一个 `@Kind`**。

| `@Kind` | 能否放进同一个 Observe 函数体 | 能否作为本模块第二个入口 | 原因 |
|---|---|---|---|
| `Observe` | 能 | 能 | 同题材本地步骤 |
| `RoundTrip` | 不能塞进 Observe 函数 | **能**：`const&in` / `&out` / `&inout` 各一条。每个案例自包含，不抽 Helper |
| `WorldStory` | 不能 | 不能 | 需要 SpawnActor；本目录无 Actor 壳 |
| `RuntimeException` | 不能 | **能**，但只在 `Exception/` 里 | 会抛，不能再返回 bool |
| `CompileReject` | 不能 | 不能 | 整模块编不过 |

`IsSet` / `GetValue` 当观察通道出现在别的 Subject 里，不要为此再加 `@Kind`。拷贝独立、零值边界、类型后缀都是**同一 Subject 的步骤**，不拆文件。

**不能混进同一 `.as` 的：**

- 正例函数 / 正例 UCLASS 与任何 CompileReject
- 正例 Observe / RoundTrip 与任何 RuntimeException
- 两个独立 CompileReject 合成一个文件（编译器常在第一个错误停）

---

## 2. 目录分类（已落地）

```text
TestSource/Containers/TOptional/
  Organization.md          本笔记
  Function/                能编译的全局函数 / Observe / RoundTrip（无 UCLASS 宿主）
  Advance/                 组合正例（@Harness Advance）：往返、多步生命周期
  Exception/               能编译、调用后 Throw（@Harness RuntimeException）
  UClass/                  TOptional 作为 UPROPERTY；清单见 UClass/Coverage.md
  Reject/                  声明 / 元素类型的 CompileReject；清单见 Reject/Coverage.md
  Negative/                交叉容器 CompileReject（容器套容器）；清单见 Negative/Coverage.md
```

`@Tag` 仍是 `Containers.TOptional.<FileStem>`，不因进子目录而改第三段。`@Theme` 仍是 `Containers.TOptional`。

## 3. Bind 权威

`Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_TOptional.cpp` 的 `TOptional.MethodSurface`：

Construct（默认）/ ImplicitConstruct（从值）/ CopyConstruct（从 optional）/ Destruct / `opAssign(const TOptional<T>&)` / `opAssign(const T&in)` / `opEquals` / `IsSet` / `Set` / `GetValue() const` / `GetValue()` / `Get(const T&in)` / `Reset`。

两个关键点决定了本目录的拆分：

1. **`GetValue()` 在 unset 时 Throw**（`"GetValue() called on Optional when not set! Check the optional with IsSet() first."`）。所以 unset 读只出现在 `Exception/`，`Function/` 里的读一律先 Set。
2. **`Get(DefaultValue)` 不 Throw**，unset 时返回 fallback。所以「unset 的安全读」是 `Function/TOptionalGet` 的 Observe，不是 Exception。

Presence 与 value 是**两条独立状态线**：存 `0` / `false` / `""` 都是 set。`Function/TOptionalEmptyConstruction` 与 `TOptionalIsSet` 各自钉住这条不变量。

---

## 4. 当前文件盘点

### 4.1 `Function/` 函数正例

六个 Subject，见 `Function/Coverage.md`：`TOptionalEmptyConstruction`、`TOptionalSet`、`TOptionalIsSet`、`TOptionalGetValue`、`TOptionalGet`、`TOptionalReset`、`TOptionalCopyAssign`。

每个 Subject 文件：Observe + `const&in` / `&out` / `&inout` 三方向 + 类型后缀。`TOptionalEmptyConstruction` 是空不变量模板，不套三方向。

### 4.2 `UClass/` 正例

`TOptionalProperty`（UPROPERTY 六种元素形状 + 每实例独立状态）。

### 4.3 `Reject/` 声明 / 元素类型

`TOptionalMissingTypeArgs`、`TOptionalAssignWrongElementType`、`TOptionalUnknownElementType`。

### 4.4 `Negative/` 交叉容器

`TOptionalOfArrayLocal`、`TOptionalOfArrayProperty`、`TOptionalOfMapLocal`、`TOptionalOfOptionalLocal`。诊断统一是 `"Containers cannot be nested in other containers"`。

### 4.5 `Exception/` 运行时 Throw

`TOptionalGetValueUnset`（unset 读 / Reset 后读 / 从 unset 赋值后读；含 FString、FVector 两个非平凡元素类型）。

### 4.6 `Advance/` 组合正例

`TOptionalRoundTrip`（跨 UFUNCTION 边界的往返 + 「maybe result」产出/消费两个分支）、`TOptionalSequence`（重复 set/reset 周期、跨步骤携带、latest-wins 槽位）。

---

## 5. 交叉容器测试

绑定规则：**容器不能再嵌套容器**。`Bind_TOptional.cpp` 的 `ValidateOptionalOperations` 在 `!Type.CanBeTemplateSubType()` 时返回 `"Containers cannot be nested in other containers"`。

因此 `TOptional<TArray<...>>`、`TOptional<TMap<...>>`、`TOptional<TOptional<...>>` 全部编译拒绝，清单见 `Negative/Coverage.md`。

`TArray<TOptional<int>>` / `TMap<int, TOptional<int>>` 的**外层不是 TOptional**，按 TArray / TMap 目录自己的 Negative 规则归属，不在本目录。

### 5.1 收口规则

1. 去重按「外层容器 × 内层容器 × 声明位点」。
2. 每个非法程序单独一个文件。
3. 元素类型默认 `int`。
4. 位点取 local + UPROPERTY 两个代表；签名位点不另建文件。

### 5.2 交叉矩阵（本目录已覆盖）

| 外层 \ 内层 | TArray | TMap | TSet | TOptional |
|---|---|---|---|---|
| TOptional | local + property | local | 不在本目录 | local |

---

## 6. 暂不处理

- 不改目录外 OpenSpec / Generation 契约（仍可能指向旧 `Test_TOptional_Mixed_0N` 路径）
- 不上 `.Generate.as` 类型矩阵生成器（Function 文件已手写落地）
- 不写 `foreach` / 迭代器（TOptional 无迭代协议）
- 不写 `TSet` 内层位点（与 TMap 位点同构，不重复建文件）
- 不写 SpawnActor 活引用（TOptional 无 WorldStory 题材，`NewObject` 已够）
