# TWeakObjectPtr Function 预期覆盖

- 日期: 2026-08-27
- 范围: 仅 `TestSource/Containers/TWeakObjectPtr/Function`
- Bind 权威: `Bind_BlueprintType.cpp` 的 `Bind_BlueprintType_WeakObjectPtr` 段
- 约定: 上级 `../Organization.md`；样板 `TWeakObjectPtrAssign.as`

本文只订 **Function harness** 的目标覆盖：能编译的全局 `UFUNCTION`，`@Kind Observe` / `RoundTrip`。失效/GC 在 `../Lifetime/`。UPROPERTY 在 `../UClass/`。组合在 `../Advance/`。

---

## 1. 怎么计数

| 层 | 分母 | 算覆盖的条件 | 目标 |
|---|---|---|---|
| L1 Bind Observe | 下表 12 个入口 | Function 里至少一条 Observe **真正调用** 该入口 | **12/12（100%）** |
| L2 RoundTrip | 3 格：`const&in` / `&out` / `&inout` | 每个 Function Subject 文件按 `TWeakObjectPtrAssign` 写出三方向 | **3/3（100%）** |
| L3 目标类形态 | 不进分母 | `UObject` 规范；`AActor` 在 UClass 覆盖 | 见 §4 |

**不算进 L1：**

- `TemplateCallback` / 析构等内部协议（析构由局部作用域隐式覆盖）
- 包装器套包装器（`../Negative/`）
- 失效 / GC（`../Lifetime/`）
- UPROPERTY 承载（`../UClass/`）
- 组合 Advance（`../Advance/`）

**没有 Exception：** `TWeakObjectPtr` 的 12 个入口零 Throw，`Get()` 在失效时返回 nullptr。详见 `../Organization.md` §3.2。

---

## 2. 当前 vs 目标

| 层 | 当前 | 目标 |
|---|---|---|
| L1 Bind Observe | **12 / 12** | 12 / 12 |
| L2 RoundTrip | **3 / 3** | 3 / 3 |

---

## 3. Bind 入口矩阵（L1）

| # | 入口 | 签名 | Function 文件 |
|---|---|---|---|
| 1 | Construct | `void f()` | `TWeakObjectPtrEmptyConstruction` |
| 2 | CopyConstruct | `void f(const TWeakObjectPtr<T>&)` | `TWeakObjectPtrAssign` |
| 3 | ImplicitConstruct | `void f(T handle_only)` | `TWeakObjectPtrAssign` |
| 4 | `opImplConv` | `T handle_only opImplConv() const` | `TWeakObjectPtrAssign` |
| 5 | `opAssign`（指针） | `TWeakObjectPtr<T>& opAssign(const TWeakObjectPtr<T>&)` | `TWeakObjectPtrAssign` |
| 6 | `opAssign`（对象） | `TWeakObjectPtr<T>& opAssign(T handle_only)` | `TWeakObjectPtrAssign` |
| 7 | `opEquals`（指针） | `bool opEquals(const TWeakObjectPtr<T>&) const` | `TWeakObjectPtrValidity` |
| 8 | `opEquals`（对象） | `bool opEquals(const T handle_only) const` | `TWeakObjectPtrAssign` |
| 9 | `Get` | `T handle_only Get() const` | `TWeakObjectPtrValidity` |
| 10 | `IsValid` | `bool IsValid() const` | `TWeakObjectPtrValidity` |
| 11 | `IsStale` | `bool IsStale() const` | `TWeakObjectPtrValidity` |
| 12 | `IsExplicitlyNull` | `bool IsExplicitlyNull() const` | `TWeakObjectPtrValidity` |

`IsStale()` 在 Function 里只断言**活对象时不为 stale**；stale 为 true 的那一条依赖 GC，归 `../Lifetime/`，且不做硬断言（见 §5）。

---

## 4. 目标类形态（L3，不进覆盖率）

值容器的类型后缀六件套在这里不适用：`T` 被约束为 UObject 派生类。

| 形态 | 用途 | 位置 |
|---|---|---|
| `TWeakObjectPtr<UObject>` | 规范形态 | Function 全部入口 |
| `TWeakObjectPtr<AActor>` | Actor 目标，UPROPERTY 形状 | `../UClass/TWeakObjectPtrProperty` |

不要为 `UObject` / `AActor` 各写一份 Function 四件套 —— 两者行为同构，只有声明位点不同。

---

## 5. RoundTrip（L2）

指针作为 **UFUNCTION 参数**。样板 `TWeakObjectPtrAssign.as`：Observe 若干条 + 三方向各一条，注释 `@Kind RoundTrip`，`@Param` 写清方向。不要抽 Helper。

| 方向 | 写法 | 语义 |
|---|---|---|
| `const TWeakObjectPtr<UObject>&in` | `bool Read…(const TWeakObjectPtr<UObject>&in Value)` | 只读，返回观察 |
| `TWeakObjectPtr<UObject>&out` | `void Fill…(TWeakObjectPtr<UObject>&out Result)` | 空 `&out` 发布一个对象 |
| `TWeakObjectPtr<UObject>&inout` | `void …(TWeakObjectPtr<UObject>&inout Value)` | 在已有指针上改一刀 |

`TWeakObjectPtrEmptyConstruction` 的三方向语义特殊：`&out` 是**留空**，`&inout` 是**重置回默认态**，不要为了凑「填值」而扭曲。

Function 里**不调 `CollectGarbage()`** —— 那是 `../Lifetime/` 的特权。

---

## 6. 与 Lifetime / UClass 的边界

| 题材 | 归属 | 原因 |
|---|---|---|
| 单 API 的 Observe / RoundTrip | `Function/` | 纯函数语义 |
| 目标失效 / GC 后状态 | `../Lifetime/` | 需 `CollectGarbage()`，跨步骤 |
| UPROPERTY 承载 / 循环引用形状 | `../UClass/` | 需 UCLASS |
| 多步序列 / 槽位复用 | `../Advance/` | 组合编排 |
| 包装器套包装器 | `../Negative/` | 编译拒绝 |
| 模板子类型非法 | `../Reject/` | 编译拒绝 |

---

## 7. Function 文件清单

| 文件 | 角色 |
|---|---|
| `TWeakObjectPtrEmptyConstruction.as` | 空不变量（默认 null / 显式空非 stale）+ 三方向 |
| `TWeakObjectPtrAssign.as` | 对象赋值、指针赋值、隐式转换、重分配 + 三方向 |
| `TWeakObjectPtrValidity.as` | 状态三元组、nullptr 语义、清空、共享目标独立 + 三方向 |

失效在 `../Lifetime/`，UPROPERTY 在 `../UClass/`，组合在 `../Advance/`。
