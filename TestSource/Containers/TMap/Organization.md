# TMap TestSource 整理记录

- 日期: 2026-08-26
- 范围: 仅 `TestSource/Containers/TMap`
- 状态: 约定已落地；`Function/` `Advance/` `Exception/` `Negative/` `Reject/` `UClass/` 已按 TArray harness 收口。
- 已做: 去掉文件名 `Test_` 前缀；按 harness 拆成 `Function/` `Advance/` `UClass/` `Reject/` `Negative/` `Exception/`。Actor 壳降成函数。外层 TMap 的交叉容器从 `Containers/TArray/Negative` 搬来。

本文是本目录的工作笔记，不是 runner 规范，也不改目录外的 OpenSpec / Generation 契约。约定对齐 `../TArray/Organization.md`。

---

## 1. 约定：按 harness 归文件，不按模式拆文件

Observe / RoundTrip 不是主题，只是同一次验证的写法。主题只认目录 `Containers/TMap`。

| 文件角色 | 放什么 | 种类怎么标 |
|---|---|---|
| 函数文件 | 能编译的全局函数 / 脚本函数 | 函数注释 `@Kind Observe` 或 `@Kind RoundTrip` |
| UCLASS 文件 | 必须有 `UCLASS` / `UPROPERTY` / `UFUNCTION` / Spawn | 类或函数注释 `@Kind WorldStory` 或 `Observe` |
| 运行时异常文件 | 能编译；调用入口后 Throw | 文件头 `@Harness RuntimeException`；每个入口 `@Kind RuntimeException` |
| 组合 Advance 文件 | 多步 / 快照 / 回放等组合正例 | 文件头 `@Harness Advance`；`@Kind Observe` 或 `RoundTrip` |
| 编译失败文件 | 整份源码就是非法程序 | 文件头 `@Kind CompileReject`；**一个失败程序一个文件** |

函数名写行为，不写 `Observe_` / `_Nominal` 前缀。种类靠注释识别。

### 注释格式（UE `/** */`，给扫描器认）

一律用 Unreal / Doxygen 块注释，不要用 `// @Kind` 行注释。文件头一块，每个入口函数正上方一块；**函数文档和声明之间不要空行**。

标签一行一个 `@Name value`，便于 Python 用 `^\\s*\\*\\s*@(\\w+)\\s+(.*)$` 抽：

| 标签 | 写在哪 | 含义 |
|---|---|---|
| `@Theme` | 文件头 | 目录主题，`Containers.TMap` |
| `@Subject` | 文件头 | 本文件测的 API / 题材 |
| `@Harness` | 文件头，单值 | 文件怎么挂：`Function` / `Advance` / `UClass` / `CompileReject` / `RuntimeException` |
| `@Tag` | 文件头，**仅一个** | 本文件对应的 AS 模块。格式 `Containers.TMap.<FileStem>`，与 `.as` 文件名 1:1 |
| `@Namespace` | 文件头 | 脚本命名空间，本目录样板为 `TMapTest` |
| `@Kind` | **每个测试案例一块** | `Observe` / `RoundTrip` / `WorldStory` / `CompileReject` / `RuntimeException` |
| `@Covers` | 函数 | 被测 surface，如 `TMap.Add` |
| `@Inputs` | 函数 | 构造与调用 |
| `@Return` | 函数 | 期望观察或返回值 |
| `@Param` | 函数 | 有参数时每个参数一行 |
| `@Boundary` | 函数，可选 | 缺键 / 迭代器越界 |

Function harness 里**每个测试案例都标 `UFUNCTION()`**，并且有完整 `/** */`。`/** */` 紧挨在 `UFUNCTION()` 上方。

示例见 `Function/TMapAdd.as`。

### 同一个入口函数里能放什么 `@Kind`

一个 `@Tag` 模块可以有多个入口函数，但 **每个入口函数只有一个 `@Kind`**。

| `@Kind` | 能否放进 **同一个 Observe 函数体** | 能否作为 **本模块第二个入口** | 原因 |
|---|---|---|---|
| `Observe` | 能 | 能 | 同题材本地步骤 |
| `RoundTrip` | 不能塞进 Observe 函数 | **能**：`const&in` / `&out` / `&inout` 各一条。每个案例自包含，不抽 Helper |
| `WorldStory` | 不能 | 不能（harness 不是 UClass） | 需要 UCLASS / BeginPlay / Spawn |
| `RuntimeException` | 不能 | **能**，但只在 `Exception/` 文件里当独立入口 | 会抛，不能再返回 bool |
| `CompileReject` | 不能 | 不能 | 整模块编不过 |

`Num` / `Contains` / `[]` 当观察通道出现在别的 Subject 里，不要为此再加 `@Kind`。

**不能混进同一 `.as` 的：**

- 正例函数 / 正例 UCLASS 与任何 CompileReject
- 正例 Observe / RoundTrip 与任何 RuntimeException
- 两个独立 CompileReject 合成一个文件

只在 `BeginPlay` 里调 API、用 `UPROPERTY` 当计数器的 Actor 壳，改成函数后进入 `Function/`。

哈希表**没有插入顺序保证**。GetKeys / GetValues / foreach 只断言 Num 与 Contains / 成员关系，不断言槽位顺序。`opEquals` 按 pair 多重集合比较，插入顺序不同仍可相等。

---

## 2. 目录分类（已落地）

```text
TestSource/Containers/TMap/
  Organization.md          本笔记
  Function/                能编译的全局函数 / Observe / RoundTrip（无 UCLASS 宿主，UObject dummy 除外）
  Advance/                 组合正例（@Harness Advance）：逆操作、事务、回放、sidecar
  Exception/               能编译、调用后 Throw（@Harness RuntimeException）
  UClass/                  带 UCLASS 的正例（UPROPERTY / Spawn）
  Reject/                  类型 / 别名 / 不支持 API 的 CompileReject
  Negative/                交叉容器 CompileReject（外层 TMap）
```

`@Tag` 仍是 `Containers.TMap.<FileStem>`，不因进子目录而改第三段。`@Theme` 仍是 `Containers.TMap`。

## 3. 目标文件形态

能编译的正例按 Bind Subject 分文件，不按元素类型拆零散文件。类型走同一 Subject 的后缀四件套（见 `Function/Coverage.md`）。

运行时异常不并进正例：见 `Exception/`。组合 Extra 在 `Advance/`。

编译失败仍按非法构造种类各留一文件。

---

## 4. 当前文件盘点

### 4.1 `Function/` 函数正例（无业务 UCLASS）

`TMapEmptyConstruction`、`TMapAdd`、`TMapContains`、`TMapNum`、`TMapIndexAccess`、`TMapRemove`、`TMapFind`、`TMapFindOrAdd`、`TMapEmptyClear`、`TMapCopyAssign`、`TMapGetKeysValues`、`TMapForEach`。Throw 入口在 `Exception/`。组合 Extra 在 `Advance/`。

错位仍在本目录：`SupportedLogLevelsMapToAutomationSafeVerbosity`、`EnhancedInputRuntimeMappingContextMatrix`、`EnhancedInputMappingContextAndActionValues`（不是 TMap API）。

### 4.2 `UClass/` 正例

真正需要类：

- `TMapProperty`（UPROPERTY 多形状）
- `MapOfStructsContainingArrays`（合法：`TMap<int, USTRUCT{ TArray<int> }>`）
- `TMapUObjectReferences`（`SpawnActor`）

### 4.3 `Reject/` 类型 / 别名 / 不支持 API

`TMapMissingTypeArgs`、`TMapOneTypeArg`、`TMapAddWrongKeyType`、`TMapAddWrongValueType`、`TMapIndexWrongKeyType`、`TMapVoidValueType`、`TMapUnknownType`、`TMapUnsupportedApiAliases`、`TMapForEachPairUnsupported`、`TMapByValueMutation`。

### 4.4 `Advance/` 组合正例

多步 / 快照 / 回放。文件头 `@Harness Advance`。清单见 `Advance/Coverage.md`。

### 4.5 `Exception/` 运行时 Throw

能编译的全局 `UFUNCTION`，调用后 `FAngelscriptEngine::Throw`。清单见 `Exception/Coverage.md`。

### 4.6 `Negative/` 交叉容器 / 嵌套

清单见 `Negative/Coverage.md`。一个非法程序一个文件。

---

## 5. 交叉容器测试

绑定规则：**容器不能再嵌套容器**。`TMap<K, TMap<...>>`、`TMap<K, TArray<V>>`、`TMap<K, TSet<...>>` 都应编译拒绝。清单见 `Negative/Coverage.md`。

**允许的「看起来像嵌套」**：结构体成员里再放容器，例如 `TMap<int, FMapPayload>` 且 `FMapPayload` 含 `TArray<int>`。正例在 `UClass/MapOfStructsContainingArrays.as`。

`TArray<TMap<...>>` 外层是 TArray，留在 `Containers/TArray/Negative`。

### 5.1 收口规则

1. 去重按「外层容器 × 内层容器 × 声明位点」。
2. 每个非法程序单独一个文件。
3. 元素类型默认 `int`；两层一条、三层一条。
4. 签名位点（参数/返回值）用 `TMap<int, TMap<int, int>>` 代表；Array/Set-in-map 只留 local + UPROPERTY。

### 5.2 交叉矩阵（本目录已覆盖）

| 外层 \ 内层 | TMap | TArray | TSet |
|---|---|---|---|
| TMap | local / property / 两层+三层 / 参数 / 返回值 | local + property | local + property |
| TArray | 在 `Containers/TArray/Negative` | 不在本目录 | 不在本目录 |
| TSet | 见 `Containers/TSet/Negative` | 见 `Containers/TSet/Negative` | 见 `Containers/TSet/Negative` |

---

## 6. 暂不处理

- 不改目录外 OpenSpec / Generation contracts（仍可能指向旧 `Test_` 路径）
- 不上 `.Generate.as` 类型矩阵生成器（Function 文件已手写/一次生成落地）
- 不把 Bindings 主题语料迁进来
- 不把错位的 Enhanced Input / Log 文件现在就搬走
- 不写 foreach 中途改 map（`AS_ITERATOR_DEBUGGING`）
- 不写不可比较 value 的 `opEquals` Throw（`Cannot compare map key/value type for equality.`）
- 不把 float 当 map key（哈希/相等是坑，不进类型后缀）

TSet 已按同一套 harness 收口，见 `Containers/TSet/Organization.md`。
