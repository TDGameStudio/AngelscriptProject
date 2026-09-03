# TSubclassOf Function 预期覆盖

- 日期: 2026-08-27
- 范围: 仅 `TestSource/Containers/TSubclassOf/Function`
- Bind 权威: `Bind_BlueprintType.cpp` 的 `Bind_BlueprintType_SubclassOf` 段；实现 `Bind_TSubclassOf.h`
- 约定: 上级 `../Organization.md`；样板 `TSubclassOfAssign.as`

本文只订 **Function harness** 的目标覆盖：能编译的全局 `UFUNCTION`，`@Kind Observe` / `RoundTrip`。类不匹配 Throw 在 `../Exception/`。UPROPERTY 在 `../UClass/`。组合在 `../Advance/`。

---

## 1. 怎么计数

| 层 | 分母 | 算覆盖的条件 | 目标 |
|---|---|---|---|
| L1 Bind Observe | 下表 14 个入口 | Function 里至少一条 Observe **真正调用** 该入口 | **14/14（100%）** |
| L2 RoundTrip | 3 格：`const&in` / `&out` / `&inout` | 每个 Function Subject 文件按 `TSubclassOfAssign` 写出三方向 | **3/3（100%）** |
| L3 类形态 | 不进分母 | 基类 / 派生类 / 无关类三件套 | 见 §4 |

**不算进 L1：**

- `TemplateCallback` / 析构等内部协议
- 包装器套包装器（`../Negative/`）
- 类不匹配 Throw（`../Exception/`）
- UPROPERTY / 工厂（`../UClass/`）
- 组合 Advance（`../Advance/`）

---

## 2. 当前 vs 目标

| 层 | 当前 | 目标 |
|---|---|---|
| L1 Bind Observe | **14 / 14** | 14 / 14 |
| L2 RoundTrip | **3 / 3** | 3 / 3 |

---

## 3. Bind 入口矩阵（L1）

| # | 入口 | 签名 | Function 文件 |
|---|---|---|---|
| 1 | Construct | `void f()` | `TSubclassOfEmptyConstruction` |
| 2 | CopyConstruct | `void f(const TSubclassOf<T>&)` | `TSubclassOfAssign` |
| 3 | ImplicitConstruct | `void f(UClass)` | `../Exception/`（Throw 面） |
| 4 | `opImplConv`（UClass） | `UClass opImplConv() const` | `TSubclassOfAssign` |
| 5 | `opImplConv`（UObject） | `UObject opImplConv() const` | `TSubclassOfAssign` |
| 6 | `opAssign`（holder） | `TSubclassOf<T>& opAssign(const TSubclassOf<T>&)` | `TSubclassOfAssign` |
| 7 | `opAssign`（UClass） | `void opAssign(UClass)` | `TSubclassOfAssign`（匹配路径） |
| 8 | `Set` | `void Set(UClass) const` | `TSubclassOfAssign`（匹配路径） |
| 9 | `opEquals`（holder） | `bool opEquals(const TSubclassOf<T>&) const` | `TSubclassOfAssign` |
| 10 | `opEquals`（UClass） | `bool opEquals(UClass) const` | `TSubclassOfAssign` |
| 11 | `Get` | `UClass Get() const` | `TSubclassOfTypeCheck` |
| 12 | `IsValid` | `bool IsValid() const` | `TSubclassOfEmptyConstruction` |
| 13 | `IsChildOf` | `bool IsChildOf(UClass) const` | `TSubclassOfTypeCheck` |
| 14 | `GetDefaultObject` | `T handle_only GetDefaultObject() const` | `TSubclassOfTypeCheck` |

### 3.1 Throw 边界（决定 Function / Exception 的切分）

三个写入入口（ImplicitConstruct / `opAssign(UClass)` / `Set`）走**同一个** `SetClass`，类不匹配时统一 Throw `"Class set to TSubclassOf<> was not a child of templated class."`，并把 holder 置空。

所以 Function 里这三个入口**只测匹配路径**（派生类塞进基类 holder、显式 nullptr）。不匹配路径全部归 `../Exception/TSubclassOfClassNotChild`。

| 入口 | 不匹配时 | 归属 |
|---|---|---|
| `Set(UClass)` | **Throw** | `../Exception/` |
| `opAssign(UClass)` | **Throw** | `../Exception/` |
| 隐式构造 `= UClass` | **Throw** | `../Exception/` |
| `Set(nullptr)` / `= nullptr` | 置空，不抛 | 本目录 `TSubclassOfAssign` |
| `IsChildOf(nullptr)` | false，不抛 | 本目录 `TSubclassOfTypeCheck` |
| `GetDefaultObject()` 于空 holder | nullptr，不抛 | 本目录 `TSubclassOfEmptyConstruction` |

---

## 4. 类形态（L3，不进覆盖率）

值容器的类型后缀六件套不适用。本目录的维度是**类层级三件套**，每个 Function 文件自带 dummy `UCLASS`：

| 形态 | 用途 |
|---|---|
| Base | 模板参数或查询基准 |
| Derived | 满足基类模板的合法写入值 |
| Unrelated | 与 Base 无继承关系，Throw 的触发值（`../Exception/`） |

不要为每个 UObject 子类各写一份四件套 —— 行为同构，只有层级关系不同。

---

## 5. RoundTrip（L2）

holder 作为 **UFUNCTION 参数**。样板 `TSubclassOfAssign.as`：Observe 若干条 + 三方向各一条，注释 `@Kind RoundTrip`，`@Param` 写清方向。不要抽 Helper。

| 方向 | 写法 | 语义 |
|---|---|---|
| `const TSubclassOf<UObject>&in` | `bool Read…(const TSubclassOf<UObject>&in Value)` | 只读，返回观察 |
| `TSubclassOf<UObject>&out` | `void Fill…(TSubclassOf<UObject>&out Result)` | 空 `&out` 填入一个类 |
| `TSubclassOf<UObject>&inout` | `void …(TSubclassOf<UObject>&inout Value)` | 在已有 holder 上改一刀 |

`TSubclassOfEmptyConstruction` 的三方向语义特殊：`&out` 是**留空**，`&inout` 是**重置回默认态**，不要为了凑「填值」而扭曲。

Function 里只写**匹配**路径，任何不匹配的写入都属于 `../Exception/`。

---

## 6. 与 Exception / UClass / Advance 的边界

| 题材 | 归属 | 原因 |
|---|---|---|
| 单 API 的 Observe / RoundTrip | `Function/` | 纯函数语义 |
| 类不匹配 Throw | `../Exception/` | 会抛，不能再返回 bool |
| UPROPERTY / 工厂用法 | `../UClass/` | 需 UCLASS |
| 多步序列 / 工厂槽位 | `../Advance/` | 组合编排 |
| 包装器套包装器 | `../Negative/` | 编译拒绝 |
| 模板子类型非法 | `../Reject/` | 编译拒绝 |

---

## 7. Function 文件清单

| 文件 | 角色 |
|---|---|
| `TSubclassOfEmptyConstruction.as` | 空不变量（null / IsChildOf false / CDO null）+ 三方向 |
| `TSubclassOfAssign.as` | 派生类赋值、Set、nullptr 清空、隐式转换、holder 拷贝独立 + 三方向 |
| `TSubclassOfTypeCheck.as` | IsChildOf 自反/派生/无关/nullptr、CDO 稳定与归属 + 三方向 |

Throw 在 `../Exception/`，UPROPERTY 在 `../UClass/`，组合在 `../Advance/`。
