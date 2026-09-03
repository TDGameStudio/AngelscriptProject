# TMap Function 预期覆盖

- 日期: 2026-08-26
- 范围: 仅 `TestSource/Containers/TMap/Function`
- Bind 权威: `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_TMap.cpp`（`TMap.MethodSurface`）
- 约定: 上级 `../Organization.md`；样板 `TMapAdd.as` / `TMapEmptyConstruction.as`

本文只订 **Function harness** 的目标覆盖：能编译的全局 `UFUNCTION`，`@Kind Observe` / `RoundTrip`。运行时 Throw 在 `../Exception/`。UClass Actor 壳 **不是** Function 的来源。缺的 Subject 直接在本目录写 `.as`。

---

## 1. 怎么计数

覆盖率按 **Bind 方法 Subject** 计，不按文件数、不按元素类型。

| 层 | 分母 | 算覆盖的条件 | 目标 |
|---|---|---|---|
| L1 Bind Observe | 下表 19 个方法 | Function 里至少一条 `int` Observe **真正调用** 该方法 | **19/19（100%）** |
| L2 RoundTrip | 3 格：`const&in` / `&out` / `&inout` | 每个 Function Subject 文件（例外见 §5）按 `TMapAdd` 写出 int 三方向 | **3/3（100%）** |
| L3 类型 | 不进分母 | 空不变量 + Add 已有类型表即可；其余 Subject 默认套后缀 | 见 §4 |

**不算进 L1：**

- 析构、`TemplateCallback`、`opForBegin/Next/End/Value/Key` 内部协议（foreach 合成一个 Subject）
- Reject 里的别名：`GenerateKeyArray` / `FindRef` / `FindChecked` / `Reserve` / `Shrink` / `Append` / `FilterByPredicate` / `Pair.Key`
- 容器套容器（`../Negative/`）
- 运行时 Throw（`../Exception/`）
- 组合 Advance（`../Advance/`）
- 必须 World 的活 Actor 引用（留 `UClass/TMapUObjectReferences`）
- 错位：Enhanced Input / Log helper 文件

`Num` / `Contains` / `[]` 当观察通道出现在别的 Subject 里，**不**给那些 API 重复计分；只给声明 `@Covers TMap.Xxx` 的文件计。

---

## 2. 当前 vs 目标

| 层 | 当前（Function 内） | 目标 |
|---|---|---|
| L1 Bind Observe | **19 / 19** | 19 / 19 |
| L2 RoundTrip | **3 / 3**（每个 Subject 文件 int 三方向） | 3 / 3 |
| 已按新注释重构 | Function Subject 均已 Observe + `const&in` / `&out` / `&inout` | 同左 |

---

## 3. Bind 方法矩阵（L1）

状态：**有** = 本目录已有真正调用该方法的 Observe。

| # | Subject | 绑定签名要点 | Function 文件 |
|---|---|---|---|
| 1 | Construct | `TMap<K,V>()` | `TMapEmptyConstruction` |
| 2 | `IsEmpty` | `bool IsEmpty() const` | `TMapEmptyConstruction` |
| 3 | `Num` | `int32 Num() const` | `TMapNum` |
| 4 | `opIndex` | `V& / const V& opIndex(const K&)`（缺键 Throw，合法路径在此） | `TMapIndexAccess` |
| 5 | `Add` | `void Add(const K&, const V&)` | `TMapAdd` |
| 6 | `Contains` | `bool Contains(const K&) const` | `TMapContains` |
| 7 | `Remove` | `bool Remove(const K&)` | `TMapRemove` |
| 8 | `RemoveAndCopyValue` | `bool RemoveAndCopyValue(const K&, V&out)` | `TMapRemove` |
| 9 | `Find` | `bool Find(const K&, V&out) const` | `TMapFind` |
| 10 | `FindOrAdd` 默认 | `V& FindOrAdd(const K&)` | `TMapFindOrAdd` |
| 11 | `FindOrAdd` 带默认值 | `V& FindOrAdd(const K&, const V&)` | `TMapFindOrAdd` |
| 12 | `opAssign` | `TMap<K,V>& opAssign(const TMap<K,V>&)` | `TMapCopyAssign` |
| 13 | `opEquals` | `bool opEquals(const TMap<K,V>&) const` | `TMapCopyAssign` |
| 14 | `Empty` | `void Empty(int32 Slack=0)` | `TMapEmptyClear` |
| 15 | `Reset` | `void Reset()` | `TMapEmptyClear` |
| 16 | `GetKeys` | `void GetKeys(TArray<K>&) const` | `TMapGetKeysValues` |
| 17 | `GetValues` | `void GetValues(TArray<V>&) const` | `TMapGetKeysValues` |
| 18 | foreach | `for (auto E : Map)` / `opFor*` | `TMapForEach` |
| 19 | `Iterator` | `TMapIterator<K,V> Iterator()` | `TMapForEach` |

`GenerateKeyArray` / `FindRef` 等 **不是** 漏测，见 `../Reject/`。

头文件注释写「缺键 `[]` 会插入默认值」，实现是 **Throw**。合法 `[]` 只覆盖已有键；缺键在 `../Exception/TMapIndexMissingKey`。

---

## 4. 元素类型（L3，不进覆盖率）

不要再开 `TMapFStringAdd` 这种按类型命名的零散文件。类型走 **同一 Subject 文件的后缀四件套**，和 `TMapAdd.as` 一样：

| 后缀 | 类型 | 比较 |
|---|---|---|
| （无） | `TMap<int, int>` 规范 | `==` |
| `_FString` | `TMap<FString, int>` | 键 `==` |
| `_FName` | `TMap<FName, int>` | 键 `==` |
| `_bool` | `TMap<int, bool>` | `==` |
| `_FVector` | `TMap<int, FVector>` | 值 `Equals` |
| `_UObject` | `TMap<int, UObject>` | 指针身份；`UObject` 本身是 Abstract，用本文件 dummy `UCLASS` + `NewObject` |

`TMapEmptyConstruction` 仍是空不变量模板（int Full；其它 Key）。

**每个 Function Subject 的 Observe + 三方向 RoundTrip 都要套这套后缀。** 多 API 合文件只给主 API 四件套加类型；其余 overload 保持 `int` Observe。

例外：

- 没有 `_float`：float 当 map key 哈希/相等是坑；不当 value 单独拆文件
- `TMapEmptyConstruction` 不套 RoundTrip 三格
- Throw 在 `../Exception/`，组合在 `../Advance/`，也不套
- 需要 `SpawnActor` 的活引用仍留 `UClass/TMapUObjectReferences`

GetKeys / foreach **不断言迭代顺序**，只断言 Num 与 Contains。

---

## 5. RoundTrip（L2）

Function 里 map 作为 **UFUNCTION 参数**，不是「本地 Add 再读」。样板是 `TMapAdd.as`：同一 Subject 文件里 **Observe 一条 + int 三方向各一条**，注释 `@Kind RoundTrip`，`@Param` 写清方向。不要抽 Helper。

| 方向 | 写法 | 命名习惯 |
|---|---|---|
| `const TMap<int,int>&in` | `bool Read…(const TMap<int,int>&in Values)` | 只读，返回观察 |
| `TMap<int,int>&out` | `void Fill…(TMap<int,int>&out Result)` | 空 `&out` 填成约定 pair |
| `TMap<int,int>&inout` | `void …(TMap<int,int>&inout Values)` | 在已有 map 上改一刀 |

**例外（不套这三格）：** `TMapEmptyConstruction`。运行时 Throw 在 `../Exception/`。组合在 `../Advance/`（含返回 `TMap<int,int>`）。

多 API 合文件（Remove / EmptyClear / CopyAssign / GetKeysValues / ForEach）**三方向挂在主 API 上**（Remove、Empty、opAssign、GetKeys、foreach），其余 overload 保持 Observe。

---

## 6. 运行时异常

Throw 入口在 `../Exception/`（`@Harness RuntimeException`），**不要**写进本目录的 Observe 文件。L1 的 `opIndex` 合法键仍靠 `TMapIndexAccess`。`Contains` 返回 false、`Find` 返回 false 也不是 Throw。

---

## 7. Function 文件清单

| 文件 | 角色 |
|---|---|
| `TMapEmptyConstruction.as` | 空不变量 + 类型 Key（无 RoundTrip 三格） |
| `TMapAdd.as` | Add Observe + 三方向 + 类型后缀；含 overwrite |
| `TMapContains.as` | Contains Observe + 三方向 + 类型后缀 |
| `TMapNum.as` | Num Observe + 三方向 + 类型后缀 |
| `TMapIndexAccess.as` | 合法 `[]` Observe + 三方向 + 类型后缀 |
| `TMapRemove.as` | Remove 三方向 + 类型后缀；RemoveAndCopyValue 仅 int Observe |
| `TMapFind.as` | Find Observe + 三方向 + 类型后缀 |
| `TMapFindOrAdd.as` | 默认 FindOrAdd 三方向 + 类型后缀；带 DefaultValue 仅 int Observe |
| `TMapEmptyClear.as` | Empty 三方向 + 类型后缀；Reset 仅 int Observe |
| `TMapCopyAssign.as` | opAssign 三方向 + 类型后缀；opEquals 仅 int Observe（含不同插入顺序） |
| `TMapGetKeysValues.as` | GetKeys 三方向 + 类型后缀；GetValues 仅 int Observe |
| `TMapForEach.as` | foreach 三方向 + 类型后缀；Iterator / RemoveCurrent 仅 int Observe |
| `SupportedLogLevelsMapToAutomationSafeVerbosity.as` | 错位：Log helper |
| `EnhancedInputRuntimeMappingContextMatrix.as` | 错位：Enhanced Input |
| `EnhancedInputMappingContextAndActionValues.as` | 错位：Enhanced Input |

组合 Extra 在 `../Advance/`，见该目录 `Coverage.md`。
