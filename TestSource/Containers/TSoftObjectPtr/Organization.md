# TSoftObjectPtr TestSource 整理记录

- 日期: 2026-08-27
- 范围: 仅 `TestSource/Containers/TSoftObjectPtr`
- 状态: 约定已落地；`Function/` `Advance/` `Async/` `UClass/` `Reject/` `Negative/` 已按 harness 收口。
- 已做: 去掉文件名 `Test_` 前缀与 `Positive_0N` / `Negative_0N` 编号命名；按 harness 拆目录；`// Theme:` 行注释换成 UE `/** */` 块注释；`Observe_` 前缀去掉，种类靠 `@Kind` 识别。

约定对齐 `../TArray/Organization.md` 与本族的 `../TWeakObjectPtr/Organization.md`。本目录是**对象包装器**（`ETemplateFamily::ObjectWrapper`），且是四者中唯一带**异步加载**题材的。

---

## 1. 约定：按 harness 归文件，不按模式拆文件

| 文件角色 | 放什么 | 种类怎么标 |
|---|---|---|
| 函数文件 | 能编译的全局函数 / 脚本函数 | 函数注释 `@Kind Observe` 或 `@Kind RoundTrip` |
| UCLASS 文件 | TSoftObjectPtr 挂在 `UPROPERTY`，或依赖「不固定资产」语义 | `NewObject` 宿主 `@Kind Observe` |
| 异步文件 | `LoadAsync` 及回调时序 | 文件头 `@Harness Async`；`@Kind Observe` |
| 组合 Advance 文件 | 多步 / 往返 / 状态迁移 | 文件头 `@Harness Advance`；`@Kind Observe` 或 `RoundTrip` |
| 编译失败文件 | 整份源码就是非法程序 | 文件头 `@Kind CompileReject`；**一个失败程序一个文件** |

函数名写行为，不写 `Observe_` / `Positive_0N` 前缀。种类靠注释识别。

### 注释格式（UE `/** */`，给扫描器认）

文件头一块，每个入口函数正上方一块；**函数文档和声明之间不要空行**。标签一行一个 `@Name value`：

| 标签 | 写在哪 | 含义 |
|---|---|---|
| `@Theme` | 文件头 | `Containers.TSoftObjectPtr` |
| `@Subject` | 文件头 | 本文件测的 API / 题材 |
| `@Harness` | 文件头，单值 | `Function` / `Advance` / `Async` / `UClass` / `CompileReject` / `RuntimeException` |
| `@Tag` | 文件头，**仅一个** | `Containers.TSoftObjectPtr.<FileStem>`，与文件名 1:1 |
| `@Namespace` | 文件头 | `TSoftObjectPtrTest` |
| `@Kind` | **每个测试案例一块** | `Observe` / `RoundTrip` / `WorldStory` / `CompileReject` / `RuntimeException` |
| `@Covers` | 函数 | 被测 surface，如 `TSoftObjectPtr.IsPending` |
| `@Inputs` / `@Return` / `@Param` / `@Boundary` | 函数 | 同其它目录 |

Function harness 里**每个测试案例都标 `UFUNCTION()`**，`/** */` 紧挨在 `UFUNCTION()` 上方。

**不能混进同一 `.as` 的：** 正例与任何 CompileReject；正例 Observe/RoundTrip 与任何 RuntimeException；两个独立 CompileReject 合成一个文件。

---

## 2. 目录分类（已落地）

```text
TestSource/Containers/TSoftObjectPtr/
  Organization.md          本笔记
  Function/                能编译的全局函数 / Observe / RoundTrip
  Advance/                 组合正例（@Harness Advance）
  Async/                   LoadAsync 与回调时序（@Harness Async）★ 本族新增
  UClass/                  TSoftObjectPtr 作为 UPROPERTY / 不固定资产语义
  Reject/                  模板子类型 CompileReject
  Negative/                交叉容器 CompileReject
```

`@Tag` 仍是 `Containers.TSoftObjectPtr.<FileStem>`，不因进子目录而改第三段。

## 3. 与值容器 / 同族类型的差异

### 3.1 三态而非二态

值容器的状态是「有值 / 无值」。软指针是**三态**，这是它最容易被测错的地方：

| 状态 | IsNull | IsPending | IsValid | 触发 |
|---|---|---|---|---|
| 默认构造 | **true** | false | false | `TSoftObjectPtr<UObject> S;` |
| 有路径未加载 | false | **true** | false | `S = FSoftObjectPath(...)` |
| 已解析 | false | false | **true** | 资产已加载 / 赋了活对象 |
| Reset 之后 | **true** | false | false | `S.Reset()` |

三个谓词互斥。测「空」用 `IsNull()`，不要用 `!IsValid()` —— pending 也是 `!IsValid()`，两者不能混。

### 3.2 没有 Exception 目录（Throw 面为空）

`Bind_TSoftObjectPtr.cpp` 里 `TSoftObjectPtr` 的入口**没有任何一个 Throw**：

- `Get()` 在资产未加载时返回 **nullptr**，不是抛异常
- `ToSoftObjectPath()` / `ToString()` / `GetAssetName()` / `GetLongPackageName()` 纯字符串访问
- `Reset()` 在空指针上是 no-op

对比：同目录树的 `../TSubclassOf` 有 Throw 面（类不匹配），所以它有 `Exception/`。

### 3.3 新增 `Async/` harness

`LoadAsync(FOnSoftObjectLoaded)` 是软指针独有的。它和 Function 的观测方式根本不同：

- Function 入口**同步返回**一个 bool 观察
- `LoadAsync` **不返回结果**，观察只能通过回调捕获

这类入口单列 `Async/`，文件头 `@Harness Async`，`@Kind` 仍是 `Observe`。回调**可能同步触发**（资产已加载时），所以每个入口必须在调用前绑定委托，且不能假设异步。

`Async/` 的入口返回 `void` 并用 `ensure()` 断言，而不是返回 bool。

### 3.4 交叉容器规则

- **非法**：`TSoftObjectPtr<TSoftObjectPtr<UObject>>`（包装器套包装器）→ `Negative/`
- **合法**：`TArray<TSoftObjectPtr<UObject>>`（容器装包装器）。一层容器 + 一层包装器，不是容器套容器

---

## 4. Bind 权威

`Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_TSoftObjectPtr.cpp`。

`BindSoftPtrBaseMethods`（约 124–138 行，软指针与软类指针共用）：

| # | 入口 | 签名 | 位置 |
|---|---|---|---|
| 1 | Construct | `void f()` | `Function/TSoftObjectPtrPath` |
| 2 | Construct（路径） | `void f(const FSoftObjectPath&)` | `Function/TSoftObjectPtrPath` |
| 3 | Destructor | `void f()` | 隐式覆盖 |
| 4 | `ToSoftObjectPath` | `FSoftObjectPath ToSoftObjectPath() const` | `Function/TSoftObjectPtrPath` |
| 5 | `ToString` | `FString ToString() const` | `Function/TSoftObjectPtrPath` |
| 6 | `GetLongPackageName` | `FString GetLongPackageName() const` | `Function/TSoftObjectPtrPath` |
| 7 | `GetAssetName` | `FString GetAssetName() const` | `Function/TSoftObjectPtrPath` |
| 8 | `IsValid` | `bool IsValid() const` | `Function/TSoftObjectPtrPath` |
| 9 | `IsPending` | `bool IsPending() const` | `Function/TSoftObjectPtrPath` |
| 10 | `IsNull` | `bool IsNull() const` | `Function/TSoftObjectPtrPath` |
| 11 | `Reset` | `void Reset()` | `Function/TSoftObjectPtrPath` |
| 12 | `opAssign`（路径） | `TSoftObjectPtr<T>& opAssign(const FSoftObjectPath&)` | `Function/TSoftObjectPtrPath` |

`TSoftObjectPtr_` 特有（约 215–232 行）：

| # | 入口 | 签名 | 位置 |
|---|---|---|---|
| 13 | ImplicitConstruct | `void f(T handle_only Object)` | `Function/TSoftObjectPtrAssign` |
| 14 | CopyConstruct | `void f(const TSoftObjectPtr<T>&)` | `Function/TSoftObjectPtrAssign` |
| 15 | `opAssign`（对象） | `TSoftObjectPtr<T>& opAssign(T handle_only)` | `Function/TSoftObjectPtrAssign` |
| 16 | `opAssign`（指针） | `TSoftObjectPtr<T>& opAssign(const TSoftObjectPtr<T>&)` | `Function/TSoftObjectPtrAssign` |
| 17 | `opEquals`（指针） | `bool opEquals(const TSoftObjectPtr<T>&) const` | `Function/TSoftObjectPtrAssign` |
| 18 | `opEquals`（对象） | `bool opEquals(T handle_only) const` | `Function/TSoftObjectPtrAssign` |
| 19 | `Get` | `T handle_only Get() const` | `Function/TSoftObjectPtrAssign` |
| 20 | `LoadAsync` | `void LoadAsync(FOnSoftObjectLoaded) const` | `Async/TSoftObjectPtrLoadAsync` |
| 21 | `EditorOnlyLoadSynchronous` | `T handle_only EditorOnlyLoadSynchronous() const` | 见 §6 |

共 21 个入口（`EditorOnlyLoadSynchronous` 为 `WITH_EDITOR` 专属）。

同文件还有 **TSoftClassPtr**（`ETemplateFamily::ClassWrapper`，约 236–251 行），与 `TSubclassOf` 同族。本目录范围外的 `Test_SoftClassPtr*` 文件需按 `../TSubclassOf/Organization.md` 的约定归位，见 §6。

---

## 5. 当前文件盘点

### 5.1 `Function/`

`TSoftObjectPtrPath`（三态、路径访问器、路径往返、Reset + 三方向）、`TSoftObjectPtrAssign`（对象赋值捕获路径、指针拷贝独立、nullptr 清空、相等性 + 三方向）。清单见 `Function/Coverage.md`。

### 5.2 `Async/`

`TSoftObjectPtrLoadAsync`（已解析指针的回调、pending 指针发请求、LoadAsync 不改写路径、回调前 Reset 留空）。

### 5.3 `UClass/`

`TSoftObjectPtrProperty`（UPROPERTY 三形状的空/路径/解析/每实例 + **不固定资产**：pending 而非 valid + Reset 回 null）。

### 5.4 `Advance/`

`TSoftObjectPtrSequence`（重复 assign/reset 周期、pending 换 resolved、跨边界读路径不加载、发布 pending / 换回路径）。

### 5.5 `Reject/`

`TSoftObjectPtrMissingTypeArgs`。

### 5.6 `Negative/`

`TSoftObjectPtrNestedLocal`。

---

## 6. 暂不处理

- 不改目录外 OpenSpec / Generation 契约（仍可能指向旧 `Test_TSoftObjectPtr_*` / `Test_SoftClassPtr*` 路径）
- **不收 TSoftClassPtr**：旧文件里混有 4 个 `Test_SoftClassPtr*`（Basics / Path / ConfiguredPath / AsProperty）。它属 `ClassWrapper` 族，与 `../TSubclassOf` 同族，应归到独立的 `Containers/TSoftClassPtr/` 或并入 `TSubclassOf` —— 需先定目录归属再动
- **不收 `EditorOnlyLoadSynchronous`**：`WITH_EDITOR` 专属方法，需要 editor-only harness，当前六 harness 没有对应落点
- 不迁移错位文件：`Test_SoftReference*`、`Test_SynchronousSoftObjectPathLoad`、`Test_GlobalLoadObject` 测的是资产加载 API 而非软指针本身，归属需与 `Bindings/` 协调后再动
- 不建 `Exception/`（Throw 面为空，见 §3.2）
- 不建 `Lifetime/`（软指针因路径未解析而 pending，不是因目标消失而失效；GC 相关断言是「不固定资产」，已在 `UClass/`）
