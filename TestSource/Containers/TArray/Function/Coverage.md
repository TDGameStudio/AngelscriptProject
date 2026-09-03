# TArray Function 预期覆盖

- 日期: 2026-08-26
- 范围: 仅 `TestSource/Containers/TArray/Function`
- Bind 权威: `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_TArray.cpp`（`TArray.MethodSurface`）
- 约定: 上级 `../Organization.md`；样板 `TArrayAddAndOrder.as` / `TArrayEmptyConstruction.as`

本文只订 **Function harness** 的目标覆盖：能编译的全局 `UFUNCTION`，`@Kind Observe` / `RoundTrip`。运行时 Throw 在 `../Exception/`。`../UClass/` 只覆盖 UPROPERTY / 活 Actor 引用，不是 Function 的来源。缺的 Subject 直接在本目录写 `.as`。

---

## 1. 怎么计数

覆盖率按 **Bind 方法 Subject** 计，不按文件数、不按元素类型。

| 层 | 分母 | 算覆盖的条件 | 目标 |
|---|---|---|---|
| L1 Bind Observe | 下表 36 个方法 | Function 里至少一条 `int` Observe **真正调用** 该方法（空路径也算，但非空语义另有缺口栏） | **36/36（100%）** |
| L2 RoundTrip | 4 格：`const&in` / `&out` / `&inout` / 返回值 | 每个 Function Subject 文件（例外见 §5）按 `TArrayAddAndOrder` 写出 int 三方向；返回值仍由值类型往返文件承担 | **4/4（100%）** |
| L3 类型 | 不进分母 | 空不变量 + Add 顺序已有类型表即可；其余 Subject 默认只写 `int` | 见 §4 |

**不算进 L1：**

- 析构、`TemplateCallback`、`opForBegin/Next/End/Value/Key` 内部协议（foreach 合成一个 Subject）
- Reject 里的别名：`Find` / `FindLast` / `Reverse` / `RemoveAll` / `StableSort` / Heap / Predicate / Bound（见 `../Reject/Coverage.md`）
- 容器套容器（`../Negative/`）
- 运行时 Throw（`../Exception/`）
- 组合 Advance（`../Advance/`）
- 必须 World 的活 Actor 引用（留 `UClass/TArrayUObjectReferences`）
- 错位：`ParseIntoArrayDelimiterVariants.as`（`FString.ParseIntoArray`）

`Num` / `[]` / `IsEmpty` 当观察通道出现在别的 Subject 里，**不**给那些 API 重复计分；只给声明 `@Covers TArray.Xxx` 的文件计。

---

## 2. 当前 vs 目标

| 层 | 当前（Function 内） | 目标 |
|---|---|---|
| L1 Bind Observe | **36 / 36** | 36 / 36 |
| L2 RoundTrip | **4 / 4**（每个 Subject 文件 int 三方向；FRotator / FTransform / FLinearColor 补返回值） | 4 / 4 |
| 已按新注释重构 | Function Subject 均已 Observe + `const&in` / `&out` / `&inout` | 同左 |

`../UClass/` 见 `UClass/Coverage.md`。Function 正例不从那里搬。

---

## 3. Bind 方法矩阵（L1）

状态：**有** = 本目录已有真正调用该方法的 Observe。

| # | Subject | 绑定签名要点 | Function 文件 |
|---|---|---|---|
| 1 | Construct | `TArray<T>()` | `TArrayEmptyConstruction` |
| 2 | `IsEmpty` | `bool IsEmpty() const` | `TArrayEmptyConstruction` |
| 3 | `Num` | `int Num() const` | `TArrayNum` |
| 4 | `opIndex` | `T& / const T& opIndex(int)` | `TArrayIndexAccess` |
| 5 | `Add` | `void Add(const T&in if_handle_then_const)` | `TArrayAddAndOrder` |
| 6 | `Contains` | `bool Contains(...) const` | `TArrayContains` |
| 7 | `Empty` | `void Empty(ReservedSize=0)` | `TArrayEmptyClear` |
| 8 | `RemoveAt` | `void RemoveAt(Index)` | `TArrayRemoveAt` |
| 9 | `FindIndex` | `int32 FindIndex(...) const` | `TArrayFind` |
| 10 | `Sort` | `void Sort(bDescendingOrder=false)` | `TArraySort` |
| 11 | `Append` | `void Append(const TArray<T>&)` | `TArrayAppend` |
| 12 | `Insert` | `void Insert(Value, Index=0)` | `TArrayInsert` |
| 13 | `AddUnique` | `bool AddUnique(...)` | `TArrayAddUnique` |
| 14 | `Swap` | `void Swap(i, j)` | `TArraySwap` |
| 15 | `Reserve` | `void Reserve(n)` | `TArrayCapacity` |
| 16 | `SetNum` | `void SetNum(n)` | `TArrayCapacity` |
| 17 | `SetNumZeroed` | `void SetNumZeroed(n)` | `TArrayCapacity` |
| 18 | `Reset` | `void Reset(ReservedSize=0)` | `TArrayCapacity` |
| 19 | `Shrink` | `void Shrink()` | `TArrayCapacity` |
| 20 | `Max` | `int Max() const` | `TArrayCapacity` |
| 21 | `GetSlack` | `int GetSlack() const` | `TArrayCapacity` |
| 22 | `GetAllocatedSize` | `int64 GetAllocatedSize() const` | `TArrayCapacity` |
| 23 | `Remove` | `int Remove(Value)` | `TArrayRemove` |
| 24 | `RemoveSingle` | `int RemoveSingle(Value)` | `TArrayRemove` |
| 25 | `RemoveSwap` | `int RemoveSwap(Value)` | `TArrayRemove` |
| 26 | `RemoveSingleSwap` | `int RemoveSingleSwap(Value)` | `TArrayRemove` |
| 27 | `RemoveAtSwap` | `void RemoveAtSwap(Index)` | `TArrayRemove` |
| 28 | `opAssign` | `TArray<T>& opAssign(const TArray<T>&)` | `TArrayCopyAssign` |
| 29 | `opEquals` | `bool opEquals(const TArray<T>&) const` | `TArrayCopyAssign` |
| 30 | `Copy` | `void Copy(Source, SourceIndex, Count, TargetIndex=0)` | `TArrayCopyAssign` |
| 31 | `MoveAssignFrom` | `void MoveAssignFrom(TArray<T>&)` | `TArrayCopyAssign` |
| 32 | `IsValidIndex` | `bool IsValidIndex(int32) const` | `TArrayLastValidIndex` |
| 33 | `Last` | `T& / const T& Last(IndexFromEnd=0)` | `TArrayLastValidIndex` |
| 34 | `Shuffle` | `void Shuffle()` | `TArrayShuffle` |
| 35 | foreach | `for (T Value : Array)` / `opFor*` | `TArrayForEach` |
| 36 | `Iterator` | `TArrayIterator<T> Iterator()` | `TArrayForEach` |

`Reverse` / `Find` / `FindLast` / `RemoveAll` **不是** 漏测，见 `../Reject/`。

---

## 4. 元素类型（L3，不进覆盖率）

不要再开 `TArrayFStringAdd` 这种按类型命名的零散文件。类型走 **同一 Subject 文件的后缀四件套**，和 `TArrayAddAndOrder.as` 一样：

| 后缀 | 类型 | 比较 |
|---|---|---|
| （无） | `int` 规范 | `==` |
| `_float` | `float` | `==` |
| `_bool` | `bool` | `==`；只有两个取值，序列允许重复 |
| `_FString` | `FString` | `==` |
| `_FVector` | `FVector` | `Equals` |
| `_UObject` | `UObject` 句柄 | 指针身份；`UObject` 本身是 Abstract，用本文件 dummy `UCLASS` + `NewObject` |

`TArrayEmptyConstruction` 仍是空不变量模板（int Full；其它 Key；另有 `AActor` + `nullptr`）。

**每个 Function Subject 的 Observe + 三方向 RoundTrip 都要套这套后缀。** 多 API 合文件只给主 API 四件套加类型；其余 overload 保持 `int` Observe。

例外：

- `TArray.Sort`：**没有** `_FVector` / `_UObject`（元素不可排序，没有 `opCmp`）
- `bool` 的 FindIndex 没有「第三种缺席值」；AddUnique 最多两个唯一值
- float 下标 / EmptyConstruction / ParseIntoArray 不套这套后缀；Throw 在 `../Exception/`，组合在 `../Advance/`，也不套
- `AActor` 不进这些 Function 文件（EmptyConstruction Key 已有 `nullptr`）
- FString 的 `Add("")` 仍只写在 AddAndOrder 的 FString Observe 里
- 需要 `SpawnActor` 的活引用仍留 `UClass/TArrayUObjectReferences`

---

## 5. RoundTrip（L2）

Function 里数组作为 **UFUNCTION 参数/返回值**，不是「本地 Add 再读」。样板是 `TArrayAddAndOrder.as`：同一 Subject 文件里 **Observe 一条 + int 三方向各一条**，注释 `@Kind RoundTrip`，`@Param` 写清方向。不要抽 Helper。

每个 Function Subject 文件都要有这三格，并且 **按 §4 用类型后缀重复**（`int` 无后缀）：

| 方向 | 写法 | 命名习惯 |
|---|---|---|
| `const TArray<int>&in` | `bool Read…(const TArray<int>&in Values)` | 只读，返回观察 |
| `TArray<int>&out` | `void Fill…(TArray<int>&out Result)` | 空 `&out` 填成约定序列 |
| `TArray<int>&inout` | `void …(TArray<int>&inout Values)` | 在已有序列上改一刀 |

**例外（不套这三格）：** `TArrayEmptyConstruction`（空不变量模板）、`TArrayFloatIndexTruncation`、`ParseIntoArrayDelimiterVariants`。运行时 Throw 在 `../Exception/`。组合在 `../Advance/`。

返回 `TArray<T>` 仍由值类型往返文件承担，不要求每个 Subject 再写第四条：

| 方向 | 文件 |
|---|---|
| 返回 `TArray<T>` | `TArrayFRotatorFunctionRoundTrip` / `TArrayFTransformFunctionRoundTrip` / `FunctionArrayAndConversionRoundTrip` |

多 API 合文件（Remove / Capacity / CopyAssign / LastValidIndex / ForEach）**三方向挂在主 API 上**（Remove、Reserve、opAssign、Last、foreach），其余 overload 保持 Observe。

值类型往返（FRotator / FTransform / FLinearColor）是 **同一 L2 格子的实例**，不是新的 Bind 方法。不要再为 `FQuat` 等无差别复制。

---

## 6. 运行时异常与下标行为

Throw 入口在 `../Exception/`（`@Harness RuntimeException`），**不要**写进本目录的 Observe 文件。L1 的 `opIndex` 合法下标仍靠 `TArrayIndexAccess`。`IsValidIndex` 返回 false 也不是 Throw。

| 文件 | `@Kind` | 算什么 |
|---|---|---|
| `TArrayFloatIndexTruncation` | `Observe` | `Arr[0.5f]` 截断为 int 下标（引擎允许隐式转换） |

字符串下标拒绝在 `../Reject/TArrayStringIndexAccess`。异常文案与文件清单见 `../Exception/Coverage.md`。未绑定 API 清单见 `../Reject/Coverage.md`。

---

## 7. Function 文件清单

一文件一个 Subject（或一组紧密 API）。正例都在本目录直接写；**不要**从 `../UClass/` 搬 UPROPERTY 或 Actor 引用。

| 文件 | 角色 |
|---|---|
| `TArrayEmptyConstruction.as` | 空不变量 + 类型 Key（无 RoundTrip 三格） |
| `TArrayAddAndOrder.as` | Add Observe + 三方向 + 类型后缀 |
| `TArrayContains.as` | Contains Observe + 三方向 + 类型后缀 |
| `TArrayIndexAccess.as` | 合法 `[]` Observe + 三方向 + 类型后缀 |
| `TArrayNum.as` | Num Observe + 三方向 + 类型后缀 |
| `TArrayEmptyClear.as` | Empty() Observe + 三方向 + 类型后缀 |
| `TArrayRemoveAt.as` | RemoveAt Observe + 三方向 + 类型后缀 |
| `TArrayFind.as` | FindIndex Observe + 三方向 + 类型后缀 |
| `TArraySort.as` | Sort Observe + 三方向 + 类型后缀（无 FVector/UObject） |
| `TArrayInsert.as` | Insert Observe + 三方向 + 类型后缀 |
| `TArrayAppend.as` | Append Observe + 三方向 + 类型后缀；另有空数组 Append |
| `TArraySwap.as` | Swap Observe + 三方向 + 类型后缀 |
| `TArrayAddUnique.as` | AddUnique Observe + 三方向 + 类型后缀 |
| `TArrayRemove.as` | Remove 三方向 + 类型后缀；其余 Remove* 仅 int Observe；缺席 Remove / RemoveAtSwap 黄金序 |
| `TArrayCapacity.as` | Reserve 三方向 + 类型后缀；其余 capacity 仅 int Observe；SetNum(0) / Reserve 小于 Num |
| `TArrayCopyAssign.as` | opAssign 三方向 + 类型后缀；Copy / Move / Equals 仅 int Observe；赋空 / 自赋值 |
| `TArrayLastValidIndex.as` | Last 三方向 + 类型后缀；IsValidIndex 仅 int Observe（含空数组 0） |
| `TArrayForEach.as` | foreach 三方向 + 类型后缀；Iterator 仅 int Observe |
| `TArrayShuffle.as` | Shuffle Observe + 三方向 + 类型后缀 |
| `TArrayFloatIndexTruncation.as` | float 下标截断 |
| `TArrayFRotatorFunctionRoundTrip.as` | L2 值类型往返 |
| `TArrayFTransformFunctionRoundTrip.as` | L2 值类型往返 |
| `FunctionArrayAndConversionRoundTrip.as` | L2 FLinearColor 往返 |
| `ParseIntoArrayDelimiterVariants.as` | 错位：`FString.ParseIntoArray` |

组合 Extra 在 `../Advance/`，见该目录 `Coverage.md`。

---

## 8. Extra

Function 不再收组合盒。`TArrayAdvance.as` 已删除，案例按协议在 `../Advance/`。
