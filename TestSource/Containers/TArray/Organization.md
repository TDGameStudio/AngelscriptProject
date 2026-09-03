# TArray TestSource 整理记录

- 日期: 2026-08-26
- 范围: 仅 `TestSource/Containers/TArray`
- 状态: 约定已落地；`Function/` `Advance/` `Exception/` `Negative/` `UClass/` `Reject/` 已按 harness 收口。
- 已做: 去掉文件名 `Test_` 前缀；按 harness 拆成 `Function/` `Advance/` `UClass/` `Reject/` `Negative/` `Exception/`。`Negative/` 原名 `Nested/`，只收编不过的交叉容器，已去重并补声明位点。`Exception/` 只收能编译、调用后 Throw 的入口。`Advance/` 只收组合正例（逆操作、事务、回放等）。

本文是本目录的工作笔记，不是 runner 规范，也不改目录外的 OpenSpec / Generation 契约。

---

## 1. 约定：按 harness 归文件，不按模式拆文件

Observe / RoundTrip 不是主题，只是同一次验证的写法。主题只认目录 `Containers/TArray`。

| 文件角色 | 放什么 | 种类怎么标 |
|---|---|---|
| 函数文件 | 能编译的全局函数 / 脚本函数 | 函数注释 `@Kind Observe` 或 `@Kind RoundTrip` |
| UCLASS 文件 | TArray 挂在 `UPROPERTY`，或必须 Spawn 的活引用 | `NewObject` 宿主 `@Kind Observe`；`SpawnActor` `@Kind WorldStory` |
| 运行时异常文件 | 能编译；调用入口后 Throw | 文件头 `@Harness RuntimeException`；每个入口 `@Kind RuntimeException` |
| 组合 Advance 文件 | 多步 / 快照 / 回放等组合正例 | 文件头 `@Harness Advance`；`@Kind Observe` 或 `RoundTrip` |
| 编译失败文件 | 整份源码就是非法程序 | 文件头 `@Kind CompileReject`；**一个失败程序一个文件** |

函数名写行为，不写 `Observe_` / `_Nominal` 前缀。种类靠注释识别。

### 注释格式（UE `/** */`，给扫描器认）

一律用 Unreal / Doxygen 块注释，不要用 `// @Kind` 行注释。文件头一块，每个入口函数正上方一块；**函数文档和声明之间不要空行**（现有 `as_inventory` 只把紧邻声明的那一块当成 attached comment）。

标签一行一个 `@Name value`，便于 Python 用 `^\\s*\\*\\s*@(\\w+)\\s+(.*)$` 抽：

| 标签 | 写在哪 | 含义 |
|---|---|---|
| `@Theme` | 文件头 | 目录主题，如 `Containers.TArray` |
| `@Subject` | 文件头 | 本文件测的 API / 题材 |
| `@Harness` | 文件头，单值 | 文件怎么挂：`Function` / `Advance` / `UClass` / `CompileReject` / `RuntimeException` |
| `@Tag` | 文件头，**仅一个** | 本文件对应的 AS 模块，以及导入 C++ 后的测试集合。格式 `Containers.TArray.<FileStem>`，与 `.as` 文件名 1:1，例如 `Containers.TArray.TArrayAddAndOrder` |
| `@Namespace` | 文件头 | 脚本命名空间，本目录样板为 `TArrayTest`。导入 C++ 时用 `TArrayTest::` 限定入口 |
| `@Kind` | **每个测试案例一块** | `Observe` / `RoundTrip` / `WorldStory` / `CompileReject` / `RuntimeException`。不抽 Helper；同一 Observe 题材的步骤写在该 Observe 函数里 |
| `@Covers` | 函数 | 被测 surface，如 `TArray.Add` |
| `@Inputs` | 函数 | 构造与调用 |
| `@Return` | 函数 | 期望观察或返回值 |
| `@Param` | 函数 | 有参数时每个参数一行 |
| `@Boundary` | 函数，可选 | 越界 / 所有权 |

Function harness 里**每个测试案例都标 `UFUNCTION()`**，并且有完整 `/** */`。`/** */` 紧挨在 `UFUNCTION()` 上方，中间不要空行。这是全局 UFUNCTION，不需要为此改成 UCLASS。

示例见 `Function/TArrayAddAndOrder.as`。`Negative/`、`UClass/`、`Reject/` 已改成此格式（CompileReject 把 `@Kind` 写在文件头）。

### 同一个入口函数里能放什么 `@Kind`

一个 `@Tag` 模块可以有多个入口函数，但 **每个入口函数只有一个 `@Kind`**。同一题材的细节（先 Add 到 `[0]`、再追加、再确认前面不动）是步骤，不是新 kind，放进同一个 `Observe` 函数。

| `@Kind` | 能否放进 **同一个 Observe 函数体** | 能否作为 **本模块第二个入口** | 原因 |
|---|---|---|---|
| `Observe` | 能 | 本文件已有 `AddAppendsInInsertionOrder` | Add 顺序的本地步骤 |
| `RoundTrip` | 不能塞进 Observe 函数 | **能**，本文件三个独立入口：`ReadInsertionOrder`（`const&in`）、`FillIntArrayByAdd`（`&out`）、`AppendWithAdd`（`&inout`）。每个案例自包含，不抽 Helper |
| `WorldStory` | 不能 | 不能（harness 不是 UClass） | 需要 Spawn；只在 `UClass/TArrayUObjectReferences` |
| `RuntimeException` | 不能 | **能**，但只在 `Exception/` 文件里当独立入口 | 会抛，不能再返回 bool；不要和 Observe / RoundTrip 同文件 |
| `CompileReject` | 不能 | 不能 | 整模块编不过 |

本 Observe 函数里可以顺带读 `Num`、`[]`、`IsEmpty`，它们是观察通道，不要为此再加 `@Kind`。拷贝独立、空构造、错误元素类型都不是 Add 顺序，不要塞进来。

**不能混进同一 `.as` 的：**

- 正例函数 / 正例 UCLASS 与任何 CompileReject
- 正例 Observe / RoundTrip 与任何 RuntimeException（Throw 进 `Exception/`）
- 两个独立 CompileReject 合成一个文件（编译器常在第一个错误停，后面的 case 变假覆盖）

---

## 2. 目录分类（已落地）

```text
TestSource/Containers/TArray/
  Organization.md          本笔记
  Function/                能编译的全局函数 / Observe / RoundTrip（无 UCLASS）
  Advance/                 组合正例（@Harness Advance）：逆操作、事务、回放、sidecar
  Exception/               能编译、调用后 Throw（@Harness RuntimeException）
  UClass/                  TArray 作为 UPROPERTY / 活 Actor 引用；清单见 UClass/Coverage.md
  Reject/                  类型 / 下标 / 未绑定 UE API 的 CompileReject；清单见 Reject/Coverage.md
  Negative/                交叉容器 CompileReject（外层 TArray）；清单见 Negative/Coverage.md
```

`@Tag` 仍是 `Containers.TArray.<FileStem>`，不因进子目录而改第三段。`@Theme` 仍是 `Containers.TArray`。

## 3. 目标文件形态（正例，尚未合并）

粗算能编译的正例从约 40 个文件收到 3～4 个：

```text
TArrayOps.as           空构造、Add/Num/[]/Contains/Empty/RemoveAt、FString/FVector 特有语义
TArrayFunctions.as     数组作脚本函数参数/返回值（FRotator / FTransform / FLinearColor 往返）
```

UClass 已收到 3 个文件，见 `UClass/Coverage.md`，不再并进一个 `TArrayUClass.as`。

运行时异常不并进正例：见 `Exception/` 与 `Exception/Coverage.md`。

`TArrayFloatIndexTruncation.as` 当前把 `void Test()` 和 Observe 混在一起：截断 oracle 进函数文件；若仍要「字符串下标拒绝」则单独 CompileReject。

`ParseIntoArrayDelimiterVariants.as` 测的是 `FString.ParseIntoArray`，归属有疑问，合并前先留着或标为错位。

编译失败仍按非法构造种类各留一文件，见 §5。

---

## 4. 当前文件盘点

### 4.1 `Function/` 函数正例（无 UCLASS）

`TArrayAddAndOrder`、`TArrayContains`、`TArrayNum`、`TArrayIndexAccess`、`TArrayEmptyClear`、`TArrayRemoveAt`、`TArrayEmptyConstruction`、以及其余 Subject 正例（见 `Function/Coverage.md`）。`TArrayFloatIndexTruncation`、值类型往返、错位的 `ParseIntoArrayDelimiterVariants` 仍在本目录。Throw 入口在 `Exception/`。组合 Extra 在 `Advance/`。

### 4.2 `UClass/` TArray 作为 UPROPERTY / 活引用

清单见 `UClass/Coverage.md`。`TArrayProperty`（int / FString / FName / FVector）、`ArrayOfStructsContainingArrays`（合法 struct 内再放 TArray）、`TArrayUObjectReferences`（`SpawnActor`）。不把 Bind API 再套 Actor 壳。

### 4.3 `Reject/` 类型 / 下标 / 未绑定 API

清单与 diagnostic 见 `Reject/Coverage.md`。不要和 `Negative/`（嵌套容器）、`Exception/`（能编译后 Throw）混。

### 4.4 `Advance/` 组合正例

多步 / 快照 / 回放。文件头 `@Harness Advance`。清单见 `Advance/Coverage.md`。不要和单 API Function 文件、Throw、CompileReject 混。

### 4.5 `Exception/` 运行时 Throw

能编译的全局 `UFUNCTION`，调用后 `FAngelscriptEngine::Throw`。文件头 `@Harness RuntimeException`。清单与文案见 `Exception/Coverage.md`。不要和 Function Observe 同文件，也不要放进 `Negative/`。

### 4.6 `Negative/` 交叉容器 / 嵌套

清单与 diagnostic 见 `Negative/Coverage.md`。一个非法程序一个文件。不要和 `Reject/`、`Exception/` 混。

---

## 5. 交叉容器测试

绑定规则：**容器不能再嵌套容器**。`TArray<TArray<T>>`、`TArray<TMap<...>>`、`TArray<TSet<...>>`、`TMap<K, TArray<V>>` 都应编译拒绝。清单见 `Negative/Coverage.md`。

**允许的「看起来像嵌套」**：结构体成员里再放容器，例如 `TArray<FArrayPayload>` 且 `FArrayPayload` 含 `TArray<int>`。这是一层容器 + 一层 USTRUCT，不是容器套容器。正例在 `UClass/ArrayOfStructsContainingArrays.as`。

### 5.1 收口规则（已按此执行）

1. 去重按「外层容器 × 内层容器 × 声明位点」，不要按文件名感觉去重。`TArray<TMap>` 和 `TMap<..., TArray>` 是两种模板实例。
2. 每个非法程序单独一个文件；编译器常在第一个错误停。
3. 元素类型默认 `int`；`bool` 与 int 同构则不另建文件。两层一条、三层一条，证明深度不会改走别的错误。
4. 签名位点（参数/返回值）用 `TArray<TArray<int>>` 代表；Map/Set-in-array 只留 local + UPROPERTY。
5. `TMap<int, TArray<int>>` 外层是 TMap，已搬到 `Containers/TMap/Negative/TMapOfArraysProperty.as`。`TSet<TArray<...>>` 在 `Containers/TSet/Negative`。

### 5.2 当前交叉 / 嵌套文件

#### 非法：TArray 套 TArray

| 文件 | 位点 | 类型 |
|---|---|---|
| `TArrayNestedLocal.as` | local | `TArray<TArray<int>>` |
| `TArrayNestedLocalDeep.as` | local | `TArray<TArray<TArray<int>>>` |
| `TArrayNestedProperty.as` | UPROPERTY | `TArray<TArray<int>>` |
| `TArrayNestedPropertyDeep.as` | UPROPERTY | `TArray<TArray<TArray<int>>>` |
| `TArrayNestedParam.as` | UFUNCTION 参数 | `TArray<TArray<int>>` |
| `TArrayNestedReturn.as` | UFUNCTION 返回值 | `TArray<TArray<int>>` |

#### 非法：TArray 套 TMap / TSet

| 文件 | 位点 | 类型 |
|---|---|---|
| `TArrayOfMapsLocal.as` | local | `TArray<TMap<int, FString>>` |
| `TArrayOfMapsProperty.as` | UPROPERTY | `TArray<TMap<int, FString>>` |
| `TArrayOfSetsLocal.as` | local | `TArray<TSet<int>>` |
| `TArrayOfSetsProperty.as` | UPROPERTY | `TArray<TSet<int>>` |

#### 非法：TMap 套 TArray（外层不是 TArray，已搬走）

已搬到 `Containers/TMap/Negative/TMapOfArraysProperty.as`。

#### 合法：USTRUCT 内再放 TArray

| 文件 | 位点 | 类型 | 备注 |
|---|---|---|---|
| `UClass/ArrayOfStructsContainingArrays.as` | UPROPERTY + NewObject | `TArray<FArrayPayload>`，payload 含 `TArray<int>` | **正例**，不是 Reject |

### 5.3 交叉矩阵（本目录已覆盖）

| 外层 \ 内层 | TArray | TMap | TSet |
|---|---|---|---|
| TArray | local / property / 两层+三层 / 参数 / 返回值 | local + property | local + property |
| TMap | 已搬到 `Containers/TMap/Negative` | 见 `Containers/TMap/Negative` | 见 `Containers/TMap/Negative` |
| TSet | 见 `Containers/TSet/Negative` | 见 `Containers/TSet/Negative` | 见 `Containers/TSet/Negative` |

---

## 6. 暂不处理

- 不合并正例文件（等本笔记确认后再做）
- 不改目录外 OpenSpec / `review01.md` / Generation contracts（仍指向旧 `Test_` 路径）
- 不上 `.Generate.as` 类型矩阵生成器
- 不把 Bindings 主题语料迁进来
- 不在本目录发明 `Containers/Cross` 新树；TMap / TSet 已按同一 harness 收口
