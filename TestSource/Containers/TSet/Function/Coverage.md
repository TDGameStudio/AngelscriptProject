# TSet Function 预期覆盖

- 日期: 2026-08-27
- 范围: 仅 `TestSource/Containers/TSet/Function`
- Bind 权威: `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_TSet.cpp`（`TSet.MethodSurface`）
- 约定: 上级 `../Organization.md`；样板 `TSetAdd.as` / `TSetEmptyConstruction.as`

本文只订 **Function harness** 的目标覆盖：能编译的全局 `UFUNCTION`，`@Kind Observe` / `RoundTrip`。运行时 Throw 在 `../Exception/`。UClass Actor 壳 **不是** Function 的来源。缺的 Subject 直接在本目录写 `.as`。

---

## 1. 怎么计数

覆盖率按 **Bind 方法 Subject** 计，不按文件数、不按元素类型。

| 层 | 分母 | 算覆盖的条件 | 目标 |
|---|---|---|---|
| L1 Bind Observe | 下表 14 个方法 | Function 里至少一条 `int` Observe **真正调用** 该方法 | **14/14（100%）** |
| L2 RoundTrip | 3 格：`const&in` / `&out` / `&inout` | 每个 Function Subject 文件（例外见 §5）按 `TSetAdd` 写出 int 三方向 | **3/3（100%）** |
| L3 类型 | 不进分母 | 空不变量 + Add 已有类型表即可；其余 Subject 默认套后缀 | 见 §4 |

**不算进 L1：**

- 析构、`TemplateCallback`、`opForBegin/Next/End/Value` 内部协议（foreach 合成一个 Subject）
- Reject 里的别名：`Find` / `FindOrAdd` / `Reserve` / `Shrink` / `Sort` / `Array` / `GetMaxIndex` / `Union` / `Intersect` / `Difference` / `Includes`
- 容器套容器（`../Negative/`）
- 运行时 Throw（`../Exception/`）
- 组合 Advance（`../Advance/`）
- 必须 World 的活 Actor 引用（留 `UClass/TSetUObjectReferences`）
- 错位：Physics / Input / Asset / FVector specifier 等非 TSet API 文件

`Num` / `Contains` 当观察通道出现在别的 Subject 里，**不**给那些 API 重复计分；只给声明 `@Covers TSet.Xxx` 的文件计。

---

## 2. 当前 vs 目标

| 层 | 当前（Function 内） | 目标 |
|---|---|---|
| L1 Bind Observe | **14 / 14** | 14 / 14 |
| L2 RoundTrip | **3 / 3**（每个 Subject 文件 int 三方向） | 3 / 3 |
| 已按新注释重构 | Function Subject 均已 Observe + `const&in` / `&out` / `&inout` | 同左 |

---

## 3. Bind 方法矩阵（L1）

状态：**有** = 本目录已有真正调用该方法的 Observe。

| # | Subject | 绑定签名要点 | Function 文件 |
|---|---|---|---|
| 1 | Construct | `TSet<T>()` | `TSetEmptyConstruction` |
| 2 | `IsEmpty` | `bool IsEmpty() const` | `TSetEmptyConstruction` |
| 3 | `Num` | `int32 Num() const` | `TSetNum` |
| 4 | `Add` | `void Add(const T&)`；重复 Add 不增长 Num | `TSetAdd` |
| 5 | `Contains` | `bool Contains(const T&) const` | `TSetContains` |
| 6 | `Remove` | `bool Remove(const T&)` | `TSetRemove` |
| 7 | `Append(TArray)` | `void Append(const TArray<T>&)` | `TSetAppend` |
| 8 | `Append(TSet)` | `void Append(const TSet<T>&)` | `TSetAppend`（仅 int Observe） |
| 9 | `opAssign` | `TSet<T>& opAssign(const TSet<T>&)` | `TSetCopyAssign` |
| 10 | `opEquals` | 成员多重集合比较，与插入顺序无关 | `TSetCopyAssign` |
| 11 | `Empty` | `void Empty(int32 Slack=0)` | `TSetEmptyClear` |
| 12 | `Reset` | `void Reset()` | `TSetEmptyClear`（仅 int Observe） |
| 13 | foreach | `for (auto Value : Set)` / `opFor*` | `TSetForEach` |
| 14 | `Iterator` | `TSetIterator<T> Iterator()`；`Proceed()` 返回元素 | `TSetForEach` |

`Find` / `Reserve` / `Union` 等 **不是** 漏测，见 `../Reject/`。TSet **没有** `[]` / `Find` / `FindOrAdd` / `GetKeys`。

`TSetIterator.Proceed` 返回 `const T&`（TArray 风格），不是 TMap 的 GetKey/GetValue。没有 `RemoveCurrent`。

---

## 4. 元素类型（L3，不进覆盖率）

不要再开 `TSetFStringAdd` 这种按类型命名的零散文件。类型走 **同一 Subject 文件的后缀四件套**，和 `TSetAdd.as` 一样：

| 后缀 | 类型 | 比较 |
|---|---|---|
| （无） | `TSet<int>` 规范 | `==`；约定成员 `{10,20,30}`，缺席 `99` |
| `_FString` | `TSet<FString>` | `==` |
| `_FName` | `TSet<FName>` | `==` |
| `_bool` | `TSet<bool>` | 只有两个唯一值；Num==2，三元组改成 `{true,false}` |
| `_FVector` | `TSet<FVector>` | Contains，不断言槽位顺序 |
| `_UObject` | `TSet<UObject>` | 指针身份；`UObject` 本身是 Abstract，用本文件 dummy `UCLASS` + `NewObject` |

`TSetEmptyConstruction` 仍是空不变量模板（int Full；其它 Key）。

**每个 Function Subject 的 Observe + 三方向 RoundTrip 都要套这套后缀。** 多 API 合文件只给主 API 四件套加类型；其余 overload 保持 `int` Observe。

例外：

- 没有 `_float`：float 当 set 元素哈希/相等是坑；不进类型后缀
- `TSetEmptyConstruction` 不套 RoundTrip 三格
- Throw 在 `../Exception/`，组合在 `../Advance/`，也不套
- 需要 `SpawnActor` 的活引用仍留 `UClass/TSetUObjectReferences`

foreach / Iterator **不断言迭代顺序**，只断言 Num 与 Contains。inout RoundTrip 用 Add 新成员，不要改写已有元素（会破坏哈希）。

---

## 5. RoundTrip（L2）

Function 里 set 作为 **UFUNCTION 参数**，不是「本地 Add 再读」。样板是 `TSetAdd.as`：同一 Subject 文件里 **Observe 一条 + int 三方向各一条**，注释 `@Kind RoundTrip`，`@Param` 写清方向。不要抽 Helper。

| 方向 | 写法 | 命名习惯 |
|---|---|---|
| `const TSet<int>&in` | `bool Read…(const TSet<int>&in Values)` | 只读，返回观察 |
| `TSet<int>&out` | `void Fill…(TSet<int>&out Result)` | 空 `&out` 填成约定成员 |
| `TSet<int>&inout` | `void …(TSet<int>&inout Values)` | 在已有 set 上改一刀 |

**例外（不套这三格）：** `TSetEmptyConstruction`。运行时 Throw 在 `../Exception/`。组合在 `../Advance/`（含返回 `TSet<int>`）。

多 API 合文件（Append / EmptyClear / CopyAssign / ForEach）**三方向挂在主 API 上**（Append(TArray)、Empty、opAssign、foreach），其余 overload 保持 Observe。

---

## 6. 运行时异常

Throw 入口在 `../Exception/`（`@Harness RuntimeException`），**不要**写进本目录的 Observe 文件。`Contains` 返回 false、`Remove` 返回 false 也不是 Throw。

---

## 7. Function 文件清单

| 文件 | 角色 |
|---|---|
| `TSetEmptyConstruction.as` | 空不变量 + 类型 Key（无 RoundTrip 三格） |
| `TSetAdd.as` | Add Observe + 三方向 + 类型后缀；含 duplicate 不增长 |
| `TSetContains.as` | Contains Observe + 三方向 + 类型后缀 |
| `TSetNum.as` | Num Observe + 三方向 + 类型后缀 |
| `TSetRemove.as` | Remove Observe + 三方向 + 类型后缀 |
| `TSetAppend.as` | Append(TArray) 三方向 + 类型后缀；Append(TSet) 仅 int Observe |
| `TSetEmptyClear.as` | Empty 三方向 + 类型后缀；Reset 仅 int Observe |
| `TSetCopyAssign.as` | opAssign 三方向 + 类型后缀；opEquals 仅 int Observe（含不同插入顺序） |
| `TSetForEach.as` | foreach 三方向 + 类型后缀；Iterator 仅 int Observe |
| `PrimitiveCollisionSetup.as` | 错位：Physics |
| `ProjectileMovementSettings.as` | 错位：Projectile |
| `PhysicsConstraintPresetRecipes.as` | 错位：Physics |
| `PhysicsConstraintComponentSettings.as` | 错位：Physics |
| `CharacterMovementPhysicsSettings.as` | 错位：CharacterMovement |
| `ActorOwnerAndRelevancySettings.as` | 错位：Actor |
| `InputBindingCollectionsVisibleAfterSetup.as` | 错位：Input |
| `TextBlockSetFontAppliesSlateFontInfoFields.as` | 错位：UMG |
| `AssetRegistryLiveQueryParity.as` | 错位：AssetRegistry |
| `SoftPathStringIdentityAndMissingClassBoundaries.as` | 错位：SoftPath |
| `GlobalLoadObject.as` | 错位：LoadObject |
| `SynchronousSoftClassPathLoad.as` | 错位：SoftClassPath |
| `InputSettingsAndRuntimeMappingApi.as` | 错位：InputSettings |
| `FVectorSpecifierAndSetProperties.as` | 错位：EditAnywhere FVector + 原 Actor oracle；真正的 `TSet<FVector>` UPROPERTY 在 `../UClass/TSetProperty` |

组合 Extra 在 `../Advance/`，见该目录 `Coverage.md`。`SetupPlayerInputComponent` 是 CompileReject，在 `../Reject/`。
