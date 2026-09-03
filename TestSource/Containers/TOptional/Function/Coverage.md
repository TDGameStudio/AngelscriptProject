# TOptional Function 预期覆盖

- 日期: 2026-08-27
- 范围: 仅 `TestSource/Containers/TOptional/Function`
- Bind 权威: `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_TOptional.cpp`（`TOptional.MethodSurface`）
- 约定: 上级 `../Organization.md`；样板 `TOptionalSet.as` / `TOptionalEmptyConstruction.as`

本文只订 **Function harness** 的目标覆盖：能编译的全局 `UFUNCTION`，`@Kind Observe` / `RoundTrip`。运行时 Throw 在 `../Exception/`。组合在 `../Advance/`。UPROPERTY 在 `../UClass/`。

---

## 1. 怎么计数

覆盖率按 **Bind 方法 Subject** 计，不按文件数、不按元素类型。

| 层 | 分母 | 算覆盖的条件 | 目标 |
|---|---|---|---|
| L1 Bind Observe | 下表 13 个方法 | Function 里至少一条 `int` Observe **真正调用** 该方法 | **13/13（100%）** |
| L2 RoundTrip | 3 格：`const&in` / `&out` / `&inout` | 每个 Function Subject 文件（例外见 §5）按 `TOptionalSet` 写出 int 三方向 | **3/3（100%）** |
| L3 类型 | 不进分母 | 类型后缀六件套 | 见 §4 |

**不算进 L1：**

- 析构、`TemplateCallback`、`opForBegin/Next/End` 等内部协议（TOptional 无迭代协议）
- 容器套容器（`../Negative/`）
- 运行时 Throw（`../Exception/`）
- 组合 Advance（`../Advance/`）
- UPROPERTY 承载（`../UClass/`）

`IsSet` / `GetValue` 当观察通道出现在别的 Subject 里，**不**给那些 API 重复计分；只给声明 `@Covers TOptional.Xxx` 的文件计。

---

## 2. 当前 vs 目标

| 层 | 当前（Function 内） | 目标 |
|---|---|---|
| L1 Bind Observe | **13 / 13** | 13 / 13 |
| L2 RoundTrip | **3 / 3**（每个 Subject 文件 int 三方向） | 3 / 3 |
| 已按新注释重构 | 全部 Subject 均已 Observe + `const&in` / `&out` / `&inout` | 同左 |

---

## 3. Bind 方法矩阵（L1）

状态：**有** = 本目录已有真正调用该方法的 Observe。

| # | Subject | 绑定签名要点 | Function 文件 |
|---|---|---|---|
| 1 | Construct（默认） | `TOptional<T>()` | `TOptionalEmptyConstruction` |
| 2 | ImplicitConstruct | `TOptional<T>(const T&in if_handle_then_const)` | `TOptionalCopyAssign` |
| 3 | CopyConstruct | `TOptional<T>(const TOptional<T>&)` | `TOptionalCopyAssign` |
| 4 | `opAssign`（值） | `TOptional<T>& opAssign(const T&in if_handle_then_const)` | `TOptionalSet` |
| 5 | `opAssign`（optional） | `TOptional<T>& opAssign(const TOptional<T>&)` | `TOptionalCopyAssign` |
| 6 | `opEquals` | `bool opEquals(const TOptional<T>&) const` | `TOptionalCopyAssign` |
| 7 | `IsSet` | `bool IsSet() const` | `TOptionalIsSet` |
| 8 | `Set` | `void Set(const T&in if_handle_then_const) const` | `TOptionalSet` |
| 9 | `GetValue`（const） | `const T& GetValue() const` | `TOptionalGetValue` |
| 10 | `GetValue`（non-const） | `T& GetValue()` | `TOptionalGetValue` |
| 11 | `Get`（带默认值） | `const T& Get(const T&in if_handle_then_const) const` | `TOptionalGet` |
| 12 | `Reset` | `void Reset()` | `TOptionalReset` |
| 13 | Destruct | `void f()` | `TOptionalEmptyConstruction`（作用域退出即触发） |

析构没有单独 Observe：局部变量离开作用域时必然触发，由 `TOptionalEmptyConstruction` 的构造/析构配对隐式覆盖，不为此单建文件。

### 3.1 Throw 边界（决定 Function / Exception 的切分）

| 入口 | unset 时行为 | 归属 |
|---|---|---|
| `GetValue()` | **Throw** `"GetValue() called on Optional when not set!..."` | `../Exception/TOptionalGetValueUnset` |
| `Get(DefaultValue)` | 返回 fallback，**不 Throw** | 本目录 `TOptionalGet` |
| `IsSet()` | 返回 false，**不 Throw** | 本目录 `TOptionalIsSet` |
| `Reset()` | no-op，**不 Throw** | 本目录 `TOptionalReset` |

`Function/` 里所有 `GetValue()` 读都在**已 Set** 之后，不触碰 Throw 路径。

---

## 4. 元素类型（L3，不进覆盖率）

不要再开 `TOptionalFStringSet` 这种按类型命名的零散文件。类型走 **同一 Subject 文件的后缀六件套**，和 `TOptionalSet.as` 一样：

| 后缀 | 类型 | 比较 |
|---|---|---|
| （无） | `TOptional<int>` 规范 | `==` |
| `_FString` | `TOptional<FString>` | `==` |
| `_FName` | `TOptional<FName>` | `==` |
| `_bool` | `TOptional<bool>` | `==` |
| `_FVector` | `TOptional<FVector>` | `Equals` |
| `_UObject` | `TOptional<UObject>` | 指针身份；`UObject` 本身是 Abstract，用本文件 dummy `UCLASS` + `NewObject` |

`TOptionalEmptyConstruction` 是空不变量模板：int 全量，其余类型只断言 unset 默认与拷贝独立。

**每个 Function Subject 的 Observe + 三方向 RoundTrip 都要套这套后缀。**

例外：

- `TOptionalEmptyConstruction` 不套 RoundTrip 三格
- Throw 在 `../Exception/`，组合在 `../Advance/`，UPROPERTY 在 `../UClass/`，都不套

### 4.1 Presence / Value 两条独立状态线

存 `0`、`false`、`""`、`nullptr` 都是 **set**，不等于 unset。钉住这条不变量的入口：

- `TOptionalEmptyConstruction.UnsetDiffersFromSetDefaultValue`（int 0）
- `TOptionalEmptyConstruction.UnsetDiffersFromSetFalse_bool`（bool false）
- `TOptionalEmptyConstruction.AssigningNullptrStillSets_UObject`（UObject nullptr）
- `TOptionalIsSet.IsSetTrueForStoredZero`（int 0）
- `TOptionalIsSet.IsSetTrueForStoredEmptyString_FString`（FString ""）
- `TOptionalGet.GetReturnsValueOrFallback_bool`（存 false 读回 false，不是 fallback）

---

## 5. RoundTrip（L2）

Function 里 optional 作为 **UFUNCTION 参数**，不是「本地 Set 再读」。样板是 `TOptionalSet.as`：同一 Subject 文件里 **Observe 一条 + int 三方向各一条**，注释 `@Kind RoundTrip`，`@Param` 写清方向。不要抽 Helper。

| 方向 | 写法 | 命名习惯 |
|---|---|---|
| `const TOptional<int>&in` | `bool Read…(const TOptional<int>&in Value)` | 只读，返回观察 |
| `TOptional<int>&out` | `void Fill…(TOptional<int>&out Result)` | 空 `&out` 填成约定值 |
| `TOptional<int>&inout` | `void …(TOptional<int>&inout Value)` | 在已有 optional 上改一刀 |

**例外（不套这三格）：** `TOptionalEmptyConstruction`。运行时 Throw 在 `../Exception/`，组合在 `../Advance/`，UPROPERTY 在 `../UClass/`，也都不套。

`Reset` 的 `&inout` 天然是「清空」方向，`Get` 的 `&out` 天然是「留空以触发 fallback」方向 —— 这两格按语义写，不要为了凑「填值」而扭曲。

---

## 6. 运行时异常

Throw 入口在 `../Exception/`（`@Harness RuntimeException`），**不要**写进本目录的 Observe 文件。`GetValue` 的合法读取路径（`IsSet()` 为真之后）仍靠本目录 `TOptionalGetValue`；unset 读归 `../Exception/TOptionalGetValueUnset`。

`Get(DefaultValue)`、`IsSet()`、`Reset()` 在 unset 时都不抛，**它们不是 Exception 的来源**。

---

## 7. Function 文件清单

| 文件 | 角色 |
|---|---|
| `TOptionalEmptyConstruction.as` | 空不变量 + 类型后缀（无 RoundTrip 三格）；隐式覆盖析构 |
| `TOptionalSet.as` | Set Observe + opAssign（值）Observe + 三方向 + 类型后缀 |
| `TOptionalIsSet.as` | IsSet 生命周期 Observe + 三方向 + 类型后缀；set/unset 不变量 |
| `TOptionalGetValue.as` | const / non-const GetValue Observe + 三方向 + 类型后缀 |
| `TOptionalGet.as` | Get 带默认值 Observe（含 unset fallback，不抛）+ 三方向 + 类型后缀 |
| `TOptionalReset.as` | Reset Observe（含 no-op / 重设）+ 三方向 + 类型后缀 |
| `TOptionalCopyAssign.as` | opAssign（optional）Observe + opEquals Observe + 隐式/拷贝构造 Observe + 三方向 + 类型后缀 |

组合 Extra 在 `../Advance/`，Throw 在 `../Exception/`，UPROPERTY 在 `../UClass/`。
