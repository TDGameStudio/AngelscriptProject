# TObjectPtr Function 预期覆盖

- 日期: 2026-08-27
- 范围: 仅 `TestSource/Containers/TObjectPtr/Function`
- Bind 权威: `Bind_BlueprintType.cpp` 的 `Bind_BlueprintType_ObjectPtr` 段
- 约定: 上级 `../Organization.md`；样板 `TObjectPtrAssign.as`

本文只订 **Function harness** 的目标覆盖：能编译的全局 `UFUNCTION`，`@Kind Observe` / `RoundTrip`。UPROPERTY 与 GC 保活在 `../UClass/`。组合在 `../Advance/`。

---

## 1. 怎么计数

| 层 | 分母 | 算覆盖的条件 | 目标 |
|---|---|---|---|
| L1 Bind Observe | 下表 9 个入口 | Function 里至少一条 Observe **真正调用** 该入口 | **9/9（100%）** |
| L2 RoundTrip | 3 格：`const&in` / `&out` / `&inout` | 每个 Function Subject 文件按 `TObjectPtrAssign` 写出三方向 | **3/3（100%）** |
| L3 目标类形态 | 不进分母 | `UObject` 规范；`AActor` / 具体脚本类在 UClass | 见 §4 |

**不算进 L1：**

- `TemplateCallback` / 析构等内部协议（析构由局部作用域隐式覆盖）
- 包装器套包装器（`../Negative/`）
- UPROPERTY / GC 保活（`../UClass/`）
- 组合 Advance（`../Advance/`）

**没有 Exception：** `TObjectPtr` 的 9 个入口零 Throw，详见 `../Organization.md` §3.2。

---

## 2. 当前 vs 目标

| 层 | 当前 | 目标 |
|---|---|---|
| L1 Bind Observe | **9 / 9** | 9 / 9 |
| L2 RoundTrip | **3 / 3** | 3 / 3 |

---

## 3. Bind 入口矩阵（L1）

| # | 入口 | 签名 | Function 文件 |
|---|---|---|---|
| 1 | Construct | `void f()` | `TObjectPtrAssign` |
| 2 | CopyConstruct | `void f(const TObjectPtr<T>&)` | `TObjectPtrAssign` |
| 3 | ImplicitConstruct | `void f(T handle_only)` | `TObjectPtrAssign` |
| 4 | `opImplConv` | `T handle_only opImplConv() const` | `TObjectPtrAssign` |
| 5 | `opAssign`（指针） | `TObjectPtr<T>& opAssign(const TObjectPtr<T>&)` | `TObjectPtrAssign` |
| 6 | `opAssign`（对象） | `TObjectPtr<T>& opAssign(T handle_only)` | `TObjectPtrAssign` |
| 7 | `opEquals`（指针） | `bool opEquals(const TObjectPtr<T>&) const` | `TObjectPtrValidity` |
| 8 | `opEquals`（对象） | `bool opEquals(const T handle_only) const` | `TObjectPtrValidity` |
| 9 | `Get` | `T handle_only Get() const` | `TObjectPtrValidity` |

### 3.1 没有 IsValid / IsStale / IsExplicitlyNull

这三个谓词是 `TWeakObjectPtr` 独有的，`TObjectPtr` **没有**绑定它们。判断空指针只能用：

```angelscript
Ptr.Get() == nullptr
```

不要在本目录写 `Ptr.IsValid()` —— 它编不过，也不是漏测。这是两个类型最常被混淆的边界。

---

## 4. 目标类形态（L3，不进覆盖率）

值容器的类型后缀六件套不适用：`T` 被约束为 UObject 派生类。

| 形态 | 用途 | 位置 |
|---|---|---|
| `TObjectPtr<UObject>` | 规范形态 | Function 全部入口 |
| `TObjectPtr<AActor>` | Actor 目标，UPROPERTY 形状 | `../UClass/TObjectPtrProperty` |
| `TObjectPtr<具体脚本类>` | 强类型 UPROPERTY 形状 | `../UClass/TObjectPtrProperty` |

不要为每种 UObject 子类各写一份四件套 —— 行为同构，只有声明位点不同。

---

## 5. RoundTrip（L2）

指针作为 **UFUNCTION 参数**。样板 `TObjectPtrAssign.as`：Observe 若干条 + 三方向各一条，注释 `@Kind RoundTrip`，`@Param` 写清方向。不要抽 Helper。

| 方向 | 写法 | 语义 |
|---|---|---|
| `const TObjectPtr<UObject>&in` | `bool Read…(const TObjectPtr<UObject>&in Value)` | 只读，返回观察 |
| `TObjectPtr<UObject>&out` | `void Fill…(TObjectPtr<UObject>&out Result)` | 空 `&out` 发布一个对象 |
| `TObjectPtr<UObject>&inout` | `void …(TObjectPtr<UObject>&inout Value)` | 在已有指针上改一刀 |

Function 里**不调 `CollectGarbage()`** —— 强引用保活断言需要 UPROPERTY 宿主，归 `../UClass/TObjectPtrProperty`。

---

## 6. 与 UClass / Advance 的边界

| 题材 | 归属 | 原因 |
|---|---|---|
| 单 API 的 Observe / RoundTrip | `Function/` | 纯函数语义 |
| UPROPERTY 承载 | `../UClass/` | 需 UCLASS |
| GC 保活（强引用让目标存活） | `../UClass/` | 需 UPROPERTY 宿主 + `CollectGarbage()` |
| 多步序列 / 槽位复用 | `../Advance/` | 组合编排 |
| 包装器套包装器 | `../Negative/` | 编译拒绝 |
| 模板子类型非法 | `../Reject/` | 编译拒绝 |

**没有失效题材**：`TObjectPtr` 保活，目标不会在持有期间消失，因此不建 `Lifetime/`（见 `../Organization.md` §3.3）。

---

## 7. Function 文件清单

| 文件 | 角色 |
|---|---|
| `TObjectPtrAssign.as` | 默认空、对象赋值、隐式转换、指针拷贝与独立、nullptr 清空、重分配 + 三方向 |
| `TObjectPtrValidity.as` | Get 稳定性、同目标相等与独立、指针 vs 对象相等、异目标不等 + 三方向 |

UPROPERTY 与保活在 `../UClass/`，组合在 `../Advance/`。
