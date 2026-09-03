# TSoftObjectPtr Function 预期覆盖

- 日期: 2026-08-27
- 范围: 仅 `TestSource/Containers/TSoftObjectPtr/Function`
- Bind 权威: `Binds/Bind_TSoftObjectPtr.cpp`（`BindSoftPtrBaseMethods` + `TSoftObjectPtr_` 段）
- 约定: 上级 `../Organization.md`；样板 `TSoftObjectPtrPath.as`

本文只订 **Function harness** 的目标覆盖：能编译的全局 `UFUNCTION`，`@Kind Observe` / `RoundTrip`。异步加载在 `../Async/`。UPROPERTY 在 `../UClass/`。组合在 `../Advance/`。

---

## 1. 怎么计数

| 层 | 分母 | 算覆盖的条件 | 目标 |
|---|---|---|---|
| L1 Bind Observe | 下表 19 个非异步入口 | Function 里至少一条 Observe **真正调用** 该入口 | **19/19（100%）** |
| L2 RoundTrip | 3 格：`const&in` / `&out` / `&inout` | 每个 Function Subject 文件写出三方向 | **3/3（100%）** |
| L3 目标类形态 | 不进分母 | `UObject` 规范；`AActor` / 具体脚本类在 UClass | 见 §4 |

**不算进 L1：**

- `LoadAsync`（20 号入口）—— 归 `../Async/`
- `EditorOnlyLoadSynchronous`（21 号）—— `WITH_EDITOR` 专属，见 `../Organization.md` §6
- 析构 / `TemplateCallback` 等内部协议
- 包装器套包装器（`../Negative/`）
- UPROPERTY / 不固定资产（`../UClass/`）
- 组合 Advance（`../Advance/`）

**没有 Exception：** `TSoftObjectPtr` 零 Throw，`Get()` 在未加载时返回 nullptr。详见 `../Organization.md` §3.2。

---

## 2. 当前 vs 目标

| 层 | 当前 | 目标 |
|---|---|---|
| L1 Bind Observe（非异步） | **19 / 19** | 19 / 19 |
| L2 RoundTrip | **3 / 3** | 3 / 3 |

---

## 3. Bind 入口矩阵（L1）

基础方法（`BindSoftPtrBaseMethods`）：

| # | 入口 | 签名 | Function 文件 |
|---|---|---|---|
| 1 | Construct | `void f()` | `TSoftObjectPtrPath` |
| 2 | Construct（路径） | `void f(const FSoftObjectPath&)` | `TSoftObjectPtrPath` |
| 4 | `ToSoftObjectPath` | `FSoftObjectPath ToSoftObjectPath() const` | `TSoftObjectPtrPath` |
| 5 | `ToString` | `FString ToString() const` | `TSoftObjectPtrPath` |
| 6 | `GetLongPackageName` | `FString GetLongPackageName() const` | `TSoftObjectPtrPath` |
| 7 | `GetAssetName` | `FString GetAssetName() const` | `TSoftObjectPtrPath` |
| 8 | `IsValid` | `bool IsValid() const` | `TSoftObjectPtrPath` |
| 9 | `IsPending` | `bool IsPending() const` | `TSoftObjectPtrPath` |
| 10 | `IsNull` | `bool IsNull() const` | `TSoftObjectPtrPath` |
| 11 | `Reset` | `void Reset()` | `TSoftObjectPtrPath` |
| 12 | `opAssign`（路径） | `TSoftObjectPtr<T>& opAssign(const FSoftObjectPath&)` | `TSoftObjectPtrPath` |

`TSoftObjectPtr_` 特有：

| # | 入口 | 签名 | Function 文件 |
|---|---|---|---|
| 13 | ImplicitConstruct | `void f(T handle_only)` | `TSoftObjectPtrAssign` |
| 14 | CopyConstruct | `void f(const TSoftObjectPtr<T>&)` | `TSoftObjectPtrAssign` |
| 15 | `opAssign`（对象） | `TSoftObjectPtr<T>& opAssign(T handle_only)` | `TSoftObjectPtrAssign` |
| 16 | `opAssign`（指针） | `TSoftObjectPtr<T>& opAssign(const TSoftObjectPtr<T>&)` | `TSoftObjectPtrAssign` |
| 17 | `opEquals`（指针） | `bool opEquals(const TSoftObjectPtr<T>&) const` | `TSoftObjectPtrAssign` |
| 18 | `opEquals`（对象） | `bool opEquals(T handle_only) const` | `TSoftObjectPtrAssign` |
| 19 | `Get` | `T handle_only Get() const` | `TSoftObjectPtrAssign` |

析构（3 号）由局部作用域隐式覆盖，不单建文件。

### 3.1 三态不变量（本目录最容易测错的地方）

| 状态 | IsNull | IsPending | IsValid | 构造方式 |
|---|---|---|---|---|
| 默认 | **true** | false | false | `TSoftObjectPtr<UObject> S;` |
| 有路径未加载 | false | **true** | false | `S = FSoftObjectPath(...)` |
| 已解析 | false | false | **true** | 资产已加载 / 赋活对象 |
| Reset 后 | **true** | false | false | `S.Reset()` |

**用 `IsNull()` 判空，不要用 `!IsValid()`。** pending 也满足 `!IsValid()`，两者语义不同 —— `TSoftObjectPtrPath.PathOnlyPointerIsPending` 与 `DefaultConstructionIsNotPending` 分别钉住这两格。

---

## 4. 目标类形态（L3，不进覆盖率）

值容器的类型后缀六件套不适用：`T` 被约束为 UObject 派生类。

| 形态 | 用途 | 位置 |
|---|---|---|
| `TSoftObjectPtr<UObject>` | 规范形态 | Function 全部入口 |
| `TSoftObjectPtr<AActor>` | Actor 目标，UPROPERTY 形状 | `../UClass/TSoftObjectPtrProperty` |
| `TSoftObjectPtr<具体脚本类>` | 强类型 UPROPERTY 形状 | `../UClass/TSoftObjectPtrProperty` |

不要为每种 UObject 子类各写一份四件套 —— 行为同构，只有声明位点不同。

---

## 5. RoundTrip（L2）

指针作为 **UFUNCTION 参数**。样板 `TSoftObjectPtrPath.as`：Observe 若干条 + 三方向各一条，注释 `@Kind RoundTrip`，`@Param` 写清方向。不要抽 Helper。

| 方向 | 写法 | 语义 |
|---|---|---|
| `const TSoftObjectPtr<UObject>&in` | `bool Read…(const TSoftObjectPtr<UObject>&in Value)` | 只读，返回观察 |
| `TSoftObjectPtr<UObject>&out` | `void Fill…(TSoftObjectPtr<UObject>&out Result)` | 空 `&out` 填入路径或对象 |
| `TSoftObjectPtr<UObject>&inout` | `void …(TSoftObjectPtr<UObject>&inout Value)` | 在已有指针上改一刀 |

Function 里**不调 `LoadAsync`**（归 `../Async/`）、**不调 `CollectGarbage()`**（保活语义归 `../UClass/`）。

---

## 6. 与 Async / UClass / Advance 的边界

| 题材 | 归属 | 原因 |
|---|---|---|
| 单 API 的 Observe / RoundTrip | `Function/` | 纯函数语义，同步返回 bool |
| `LoadAsync` 与回调时序 | `../Async/` | 不返回结果，只能回调捕获 |
| UPROPERTY 承载 | `../UClass/` | 需 UCLASS |
| 不固定资产（pending 而非 valid） | `../UClass/` | 需 UPROPERTY 宿主表达「引用者已加载而资产未加载」 |
| 多步序列 / 状态迁移 | `../Advance/` | 组合编排 |
| 包装器套包装器 | `../Negative/` | 编译拒绝 |
| 模板子类型非法 | `../Reject/` | 编译拒绝 |

---

## 7. Function 文件清单

| 文件 | 角色 |
|---|---|
| `TSoftObjectPtrPath.as` | 三态（null / pending / valid）、路径访问器、路径往返、包与资产名、Reset + 三方向 |
| `TSoftObjectPtrAssign.as` | 对象赋值捕获路径、指针拷贝与独立、nullptr 清空、指针/对象相等 + 三方向 |

异步在 `../Async/`，UPROPERTY 在 `../UClass/`，组合在 `../Advance/`。
