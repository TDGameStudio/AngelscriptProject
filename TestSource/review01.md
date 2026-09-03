# TestSource 命名问题 Review 01

> 审查日期: 2026-08-24
> 范围: TestSource/Bindings 目录下 `.as` 测试文件的函数命名与文件命名

---

## 1. `Observe_<SurfaceName>_<Variant>` 函数命名问题

### 1.1 命名结构概述

当前所有 40 个测试函数统一遵循 `Observe_<SurfaceName>_<Variant>` 三段式：

- `Observe` — 固定前缀，表示"观察行为是否如预期"（返回 bool 聚合断言，非 assert）
- `<SurfaceName>` — 从 C++ 绑定注册代码提取的方法/属性名
- `<Variant>` — 固定为 `Nominal`（标称/正常路径），预留未来 `_EdgeCase` 等扩展

### 1.2 具体问题

#### 问题 A: SurfaceName 退化为编号，完全丧失可读性

```
Observe_Surface043_Nominal   // Test_Behavior_01.as:109
Observe_Surface047_Nominal   // Test_Behavior_02.as:14
```

某些 surface 没有干净的方法名可以提取，直接退化为 `Surface043` / `Surface047` 编号。光看函数名完全无法知道测的是什么，必须查 CSV 才能对应到具体 API。

#### 问题 B: 关键字/保留词作为 SurfaceName

```
Observe_for_Nominal   // Test_Behavior_01.as:78
```

`for` 是语言关键字。实际指的是 `for-in` range 迭代语法糖，但放在函数名中间非常违和，语义也不准确。

#### 问题 C: 属性访问器名被当作方法名

```
Observe_Array_Nominal   // Test_Behavior_01.as:24
```

`Array` 是隐式属性访问器（返回内部 `FScriptArray` 引用），不是方法。叫 `Observe_Array` 让人以为在测整个数组对象，而非测某个具体的 API surface。

#### 问题 D: SurfaceName 不够自描述

```
Observe_Proceed_Nominal   // Test_IndexAndIteration_01.as:57
```

`Proceed` 对应的是迭代器的 `Proceed` 方法，但脱离上下文后不够直观。与同文件中的 `Observe_Iterator_Nominal`、`Observe_ConstIterator_Nominal` 放在一起时，层级关系不清楚（`Proceed` 是 `Iterator` 的子操作）。

### 1.3 根因分析

核心矛盾在于：**`Observe_` 前缀和 `_Nominal` 后缀是给 validator 用的机器约束标记，但中间的 `<SurfaceName>` 承载不了足够的语义**。当 surface 名字本身足够自描述时（如 `Contains`、`AddUnique`、`RemoveAtSwap`），整个函数名尚可阅读；但一旦 surface 名字不够自描述（`for`、`Array`、`Surface043`），整个函数名就变成需要查表才能解读的密码。

### 1.4 改进建议

- **方案 A（最小改动）**: 保留三段式结构，但禁止 `Surface0xx` 退化命名，要求所有 surface 必须提取有意义的语义名；关键字 case（如 `for`）使用转义名（如 `RangeFor`）。
- **方案 B（风格调整）**: 将 `Observe_X_Nominal` 改为 `Test_X_HappyPath`，对人类更友好，对机器可解析性无损失。variant 信息（Nominal/EdgeCase）也可移入 CSV 或注释，函数名只保留 `Test_<SurfaceName>`。

---

## 2. `Test_<ScenarioCategory>_<Part>.as` 文件命名问题

### 2.1 命名结构概述

文件命名统一为 `Test_<ScenarioCategory>_<Part>.as`，其中：

- `<ScenarioCategory>` — 6 个固定分类之一（ConstructionAndAssignment / Operators / IndexAndIteration / Queries / MutationAndLifecycle / Behavior）
- `<Part>` — 零填充序号（`01`、`02`...），表示该分类下的第 N 个分片

### 2.2 具体问题

#### 问题 A: 序号不承载语义

`Test_Behavior_01.as` 和 `Test_Behavior_02.as` 仅靠 `_01` / `_02` 区分，不打开文件无法知道各自测了什么。对于只有单个文件的分类（如 `Operators` 只有 `Test_Operators_01.as`），`_01` 后缀纯属冗余。

#### 问题 B: `Behavior` 分类过于笼统

`Behavior` 作为一个 ScenarioCategory 涵盖了 Swap、Last、Copy、for-in、迭代器协议等多种不相关的行为，缺乏内聚性。与 `MutationAndLifecycle`、`Queries` 等更具体的分类形成对比，`Behavior` 像是一个"兜底"分类。

### 2.3 改进建议

- 在文件头部强制要求 `// @covers: S023, S024, S025` 式的 surface 清单注释，让文件名不需要承载全部语义。
- 考虑将 `Behavior` 拆分为更具体的子分类，或明确其"跨分类行为组合"的定位。

---

## 3. `Bindings/` 与 `Containers/` 两套命名体系不统一

### 3.1 现状

| 维度 | Bindings/ | Containers/ |
|------|-----------|-------------|
| 文件命名 | `Test_<Category>_<Part>.as`（机械分片） | `Test_TArray<SemanticName>.as`（语义命名） |
| 函数命名 | `Observe_<SurfaceName>_Nominal`（返回 bool） | 混合 UCLASS/Actor/BeginPlay + standalone |
| 组织逻辑 | 自下而上从 C++ 绑定源码反推 | 自上而下从使用场景出发 |
| 约束来源 | CSV surface 清单 + validator 机械校验 | 无机械约束，想到什么测什么 |

### 3.2 问题

同一容器类型（TArray）在两个目录下有两套完全不同的命名体系和组织方式，维护者需要切换思维模式。两套体系各有优劣但未对齐，导致：

- API 覆盖有偏差（Bindings 有 Containers 没有的，反之亦然）
- 命名风格不一致，认知负担高
- 难以判断某个 API 到底被哪边覆盖了

### 3.3 改进建议

- 短期：在各自 README 中明确标注定位差异，减少混淆。
- 中期：考虑以 Bindings 的 surface 清单为权威基线，将 Containers 中的场景测试标记为 Bindings surface 的补充用例，建立交叉引用。

---

## 4. Bindings/ 与 Containers/ 的 API 覆盖偏差矩阵

通过逐文件比对 TArray 在两个目录下的实际测试覆盖，发现大量 API 存在单向覆盖（只在一边测到）或覆盖深度不一致的问题。

### 4.1 覆盖偏差汇总

| API Surface | Bindings/ 覆盖 | Containers/ 覆盖 | 偏差说明 |
|-------------|:---:|:---:|------|
| `Add` | ✅ `Observe_Add_Nominal` | ✅ 几乎每个文件都用 | 双覆盖，但 Containers 测了 null/UObject 深度不够 |
| `Append` | ✅ `Observe_Append_Nominal` | ✅ `Test_TArrayAppendAndMerge` + `BulkOperations` | 双覆盖 |
| `AddUnique` | ✅ `Observe_AddUnique_Nominal` | ✅ `Test_TArrayAddUniqueAndRemoveAll` + `BulkOperations` | 双覆盖 |
| `Insert` | ✅ `Observe_Insert_Nominal` | ❌ | **Bindings 独有**，Containers 未测 |
| `Remove` | ✅ `Observe_Remove_Nominal` | ✅ `Test_TArrayAddUniqueAndRemoveAll` | 双覆盖 |
| `RemoveSingle` | ✅ `Observe_RemoveSingle_Nominal` | ❌ | **Bindings 独有** |
| `RemoveSwap` | ✅ `Observe_RemoveSwap_Nominal` | ❌ | **Bindings 独有** |
| `RemoveSingleSwap` | ✅ `Observe_RemoveSingleSwap_Nominal` | ❌ | **Bindings 独有** |
| `RemoveAt` | ✅ `Observe_RemoveAt_Nominal` | ✅ `Test_TArrayInsertAndRemoveAt` | 双覆盖 |
| `RemoveAtSwap` | ✅ `Observe_RemoveAtSwap_Nominal` | ❌ | **Bindings 独有** |
| `Swap` | ✅ `Observe_Swap_Nominal` | ✅ `Test_TArraySwapElements` | 双覆盖 |
| `Sort` | ✅ `Observe_Sort_Nominal` | ✅ `Test_TArraySortAndReverse` + `EdgeCasesEmpty` | 双覆盖 |
| `Shrink` | ✅ `Observe_Shrink_Nominal` | ❌ | **Bindings 独有** |
| `Shuffle` | ✅ `Observe_Shuffle_Nominal` | ❌ | **Bindings 独有** |
| `Empty` | ✅ `Observe_Empty_Nominal` | ✅ `Test_TArraySetNumAndCapacity` | 双覆盖 |
| `Reset` | ✅ `Observe_Reset_Nominal` | ✅ `Test_TArraySetNumAndCapacity` | 双覆盖 |
| `Reserve` | ✅ `Observe_Reserve_Nominal` | ✅ `Test_TArrayReserve` + `BulkOperations` | 双覆盖 |
| `SetNum` | ✅ `Observe_SetNum_Nominal` | ✅ `Test_TArraySetNumAndCapacity` | 双覆盖 |
| `SetNumZeroed` | ✅ `Observe_SetNumZeroed_Nominal` | ❌ | **Bindings 独有** |
| `Contains` | ✅ `Observe_Contains_Nominal` | ✅ `AdvancedSearch` + `EdgeCasesEmpty` + `UObjectReferences` | 双覆盖，但深度不同（见 §5） |
| `Num` | ✅ `Observe_Num_Nominal` | ✅ 几乎每个文件都用 | 双覆盖 |
| `Max` | ✅ `Observe_Max_Nominal` | ❌ | **Bindings 独有** |
| `GetAllocatedSize` | ✅ `Observe_GetAllocatedSize_Nominal` | ❌ | **Bindings 独有** |
| `IsEmpty` | ✅ `Observe_IsEmpty_Nominal` | ❌ | **Bindings 独有** |
| `GetSlack` | ✅ `Observe_GetSlack_Nominal` | ❌ | **Bindings 独有** |
| `IsValidIndex` | ❌ | ✅ `Test_TArrayAdvancedSearch` | **Containers 独有** |
| `FindIndex` | ❌ | ✅ `Test_TArrayFind` + `AdvancedSearch` + `EdgeCasesEmpty` + `UObjectReferences` | **Containers 独有** |
| `Last` | ✅ `Observe_Last_Nominal` | ❌ | **Bindings 独有** |
| `Copy` | ✅ `Observe_Copy_Nominal` | ❌ | **Bindings 独有** |
| `MoveAssignFrom` | ✅ `Observe_MoveAssignFrom_Nominal` | ❌ | **Bindings 独有** |
| `[]` (subscript) | ✅ `Observe_Index_Nominal` | ✅ 隐式使用于多个文件 | 双覆盖，但 Containers 未显式测 alias/write-through |
| `==` (equality) | ✅ `Observe_Equality_Nominal` | ❌ | **Bindings 独有** |
| `=` (copy assign) | ✅ `Observe_Assignment_Nominal` | ❌ | **Bindings 独有** |
| `for-in` (range-for) | ✅ `Observe_for_Nominal` | ✅ `Test_TArrayForEachIteration` | 双覆盖 |
| `Iterator` / `CanProceed` / `Proceed` | ✅ `Observe_Surface043_Nominal` + `Observe_Surface047_Nominal` | ✅ `Test_TArrayForEachIteration` | 双覆盖 |
| `FloatIndex` (隐式转换) | ❌ | ✅ `Test_TArray_Negative_07` | **Containers 独有**，且发现了 CSV 标注错误 |
| `Find`/`FindLast`/`Reverse`/`RemoveAll` (不支持) | ❌ | ✅ `Test_TArrayUnsupportedApiAliases` | **Containers 独有**，负面测试 |
| `UnsupportedAlgorithms` | ❌ | ✅ `Test_TArrayUnsupportedAlgorithms` | **Containers 独有**，负面测试 |
| 嵌套容器 (TArray<TArray<T>>) | ❌ | ✅ 多个 `Test_*Nested*` 文件 | **Containers 独有** |
| FString/FVector/FName 元素类型 | ❌ | ✅ `Test_TArrayFString/FVector/WithFName` | **Containers 独有** |
| UObject 引用元素 | ✅ `Observe_Add_Nominal` (含 null+LiveCdo) | ✅ `Test_TArrayUObjectReferences` | 双覆盖，角度不同 |

### 4.2 偏差统计

- **Bindings 独有（Containers 缺失）**: 17 个 API surface（Insert、RemoveSingle、RemoveSwap、RemoveSingleSwap、RemoveAtSwap、Shrink、Shuffle、SetNumZeroed、Max、GetAllocatedSize、IsEmpty、GetSlack、Last、Copy、MoveAssignFrom、`==`、`=`）
- **Containers 独有（Bindings 缺失）**: 5 个领域（IsValidIndex、FindIndex、FloatIndex 隐式转换、不支持 API 负面测试、嵌套容器场景）

### 4.3 核心问题

**Containers 测试在 API 覆盖广度上远小于 Bindings，但在场景深度上更丰富**。Containers 的场景测试（嵌套容器、多元素类型、UObject 引用生命周期、隐式类型转换边界）是 Bindings 纯 surface 测试所不具备的。反过来，Bindings 系统性覆盖了 17 个 Containers 完全没碰的 API。

两套体系如果简单合并会造成大量重复，但完全不合并则存在严重的覆盖盲区。

---

## 5. Contains 测试的覆盖重叠分析

用户提出"Contains 测试一定程度上面包含 bind 的测试"，这个直觉部分正确但不完全准确。

### 5.1 Contains 在两套体系中的实际覆盖

**Bindings 侧** (`Test_Queries_01.as`):

```angelscript
bool Observe_Contains_Nominal()
{
    TArray<int32> Empty;
    TArray<int32> Array;
    Array.Add(1); Array.Add(2); Array.Add(1);
    TArray<FString> Texts;
    Texts.Add("Alpha");
    return !Empty.Contains(1) && Array.Contains(2) && !Array.Contains(9) && Texts.Contains("Alpha");
}
```

测试点：空数组 Contains 返回 false、int32 值存在/不存在、FString 值匹配、重复元素不影响结果。

**Containers 侧** — Contains 出现在 4 个独立文件中：

| 文件 | Contains 用法 | 上下文 |
|------|-------------|--------|
| `Test_TArrayAdvancedSearch.as` | `Contains(5)` true + `Contains(100)` false | 与 FindIndex、IsValidIndex 组合 |
| `Test_TArrayEdgeCasesEmpty.as` | `EmptyArray.Contains(5)` → false | 空数组边界 |
| `Test_TArrayUObjectReferences.as` | `ActorReferences.Contains(this)` → true | UObject 引用比较 |
| `Test_TArrayAddUniqueAndRemoveAll.as` | 间接覆盖（AddUnique 内部依赖 Contains 语义） | 无显式 Contains 调用 |

### 5.2 Contains 是否"包含" Bind 测试？

**用户直觉正确的部分**：Contains 作为一个查询方法，其测试必然需要先构造数组（Add）、可能需要遍历（for-in），因此它**间接验证了 Add、Num、[] 等基础 API 的正确性**。如果这些底层 API 坏了，Contains 测试也会跟着失败。

**但直觉不准确的部分**：

1. **Contains 无法覆盖 17 个 Bindings 独有 API**。Contains 测试不会调用 Insert、RemoveSingle、RemoveSwap、Shrink、Shuffle、SetNumZeroed、Max、GetAllocatedSize、GetSlack、Last、Copy、MoveAssignFrom、`==`、`=` 等。这些 API 的正确性与 Contains 无关。

2. **Contains 的覆盖是隐式的、不可追踪的**。即使 Contains 测试因为 Add 坏了而失败，你看到的失败信息是 `Contains(2) returned false`，而不是 `Add is broken`。这正是 Bindings surface 测试存在的价值——每个 `Observe_X_Nominal` 独立隔离地验证单个 API，失败时能精确定位。

3. **Containers 的 Contains 测试也并非全覆盖**。`Test_TArrayAdvancedSearch.as` 中 Contains 只测了 int32 一种类型，而 Bindings 还额外测了 FString。Containers 在 `UObjectReferences` 中测了 UObject 引用的 Contains，这是 Bindings 没有的角度——但反过来，Bindings 测了空数组 Contains，Containers 在 `EdgeCasesEmpty` 中也测了，存在冗余。

### 5.3 结论

Contains 测试确实**间接验证了部分基础 bind API**（Add、Num、`[]`），但：

- 它**不能替代** Bindings 的系统性 surface 覆盖（17 个 API 完全不涉及）
- 它的间接覆盖是**不可追踪的**——失败无法定位到具体 API
- 两套体系中 Contains 自身也存在**冗余覆盖**（空数组 Contains 在两边都测了）

**正确的定位应该是**：Containers 的场景测试（含 Contains）是 Bindings surface 测试的**集成验证层**，验证多个 API 组合在一起能否正确协作。两者是互补关系而非包含关系。Bindings 保证单个 API 正确，Containers 保证组合使用正确。

---

## 6. Containers/ 目录文件归属错误（严重）

> 审查扩展到 Containers/ 全部 8 个子目录后发现：TSet、TMap、TObjectPtr 三个目录存在严重的文件污染——大量文件的实际测试内容与所在容器类型完全无关，但文件头 `// Theme:` 注释却错误标注为该容器类型。

### 6.1 Containers/TSet — 24 个文件中 15 个与 TSet 无关（污染率 63%）

| 文件名 | 实际测试内容 | C++ 来源 | 与 TSet 的关系 |
|--------|------------|----------|:---:|
| `Test_ActorOwnerAndRelevancySettings.as` | AActor 网络复制（SetOwner、NetPriority、SetReplicates） | `AngelscriptCoverageNetworkingTests.cpp` | ❌ 完全无关 |
| `Test_AssetRegistryLiveQueryParity.as` | 资产注册表查询 | — | ❌ 完全无关 |
| `Test_CharacterMovementPhysicsSettings.as` | UCharacterMovementComponent 物理参数 | `AngelscriptCoveragePhysicsTests.cpp` | ❌ 完全无关 |
| `Test_FVectorSpecifierAndSetProperties.as` | FVector 属性设置 | — | ❌ 完全无关 |
| `Test_GlobalLoadObject.as` | 全局对象加载 | — | ❌ 完全无关 |
| `Test_InputBindingCollectionsVisibleAfterSetup.as` | 输入绑定集合 | — | ❌ 完全无关 |
| `Test_InputSettingsAndRuntimeMappingApi.as` | UInputSettings 运行时映射 | — | ❌ 完全无关 |
| `Test_PhysicsConstraintComponentSettings.as` | 物理约束组件 | — | ❌ 完全无关 |
| `Test_PhysicsConstraintPresetRecipes.as` | 物理约束预设 | — | ❌ 完全无关 |
| `Test_PrimitiveCollisionSetup.as` | UStaticMeshComponent 碰撞设置 | — | ❌ 完全无关 |
| `Test_ProjectileMovementSettings.as` | UProjectileMovementComponent | — | ❌ 完全无关 |
| `Test_SetupPlayerInputComponent.as` | PlayerInputComponent 设置 | — | ❌ 完全无关 |
| `Test_SoftPathStringIdentityAndMissingClassBoundaries.as` | 软路径字符串 | — | ❌ 完全无关 |
| `Test_SynchronousSoftClassPathLoad.as` | 软类路径同步加载 | — | ❌ 完全无关 |
| `Test_TextBlockSetFontAppliesSlateFontInfoFields.as` | UTextBlock 字体设置 | — | ❌ 完全无关 |

真正的 TSet 测试仅 9 个文件：`Test_TSet_Positive_01~04`、`Test_TSet_Negative_01~03`、`Test_TSetAsParameter_01~02`、`Test_TSetAsReturnValue`。

所有 15 个不相关文件的头部注释均标注为 `// Theme: Containers.TSet`，Theme 标注与内容完全矛盾。

### 6.2 Containers/TMap — 29 个文件中 4 个与 TMap 无关（污染率 14%）

| 文件名 | 实际测试内容 | 与 TMap 的关系 |
|--------|------------|:---:|
| `Test_EnhancedInputMappingContextAndActionValues.as` | Enhanced Input UInputAction / UInputMappingContext | ❌ 完全无关 |
| `Test_EnhancedInputRuntimeMappingContextMatrix.as` | Enhanced Input WASD/arrow 映射矩阵 | ❌ 完全无关 |
| `Test_SupportedLogLevelsMapToAutomationSafeVerbosity.as` | 日志级别（Log、LogInfo、Warning、Error） | ❌ 完全无关 |
| `Test_StringFamilyMapKeyValueCombinations.as` | FString/FName/FText 字符串族组合 | ⚠️ 使用了 TMap 但焦点是字符串族 |

### 6.3 Containers/TObjectPtr — 12 个文件中 1 个与 TObjectPtr 无关（污染率 8%）

| 文件名 | 实际测试内容 | 与 TObjectPtr 的关系 |
|--------|------------|:---:|
| `Test_EnhancedInputBindingHandlesAndRemoval.as` | Enhanced Input BindAction / BindDebugKey | ❌ 完全无关 |

### 6.4 其余 5 个 Containers 子目录无污染

| 目录 | 文件数 | 污染情况 |
|------|:---:|------|
| `TOptional` | 6 | ✅ 全部为 `Test_TOptional_Mixed_*`，命名规范 |
| `TWeakObjectPtr` | 15 | ✅ 全部为 WeakObjectPtr 相关测试 |
| `TSoftObjectPtr` | 24 | ✅ 全部为 SoftObjectPtr/SoftClassPtr 相关测试 |
| `TSubclassOf` | 16 | ✅ 全部为 TSubclassOf 相关测试 |
| `TArray` | (已分析) | ✅ 无污染 |

### 6.5 根因分析

推测原因是批量迁移或生成脚本将 C++ 测试文件（`AngelscriptCoverage*.cpp`）转换为 `.as` 脚本时，按文件数量而非内容主题分配到 Containers 子目录。TSet 目录污染最严重（63%），可能是脚本将"无明确归属"的文件统一倾倒到了最后一个容器目录。

### 6.6 影响

- **误导维护者**：在 TSet 目录中找 TSet 测试，实际只有 37% 的文件相关
- **覆盖统计失真**：如果按目录统计 TSet 覆盖率，会被 15 个不相关文件严重高估
- **Theme 标注不可信**：所有污染文件的 `// Theme: Containers.TSet/TMap/TObjectPtr` 注释与内容矛盾，破坏了 Theme 标注体系的可信度
- **影响 validator**：如果 validator 依赖 Theme 标注进行分类校验，这些文件会通过校验但实际覆盖的是错误领域

### 6.7 修复建议

- 将 15 个 TSet 污染文件迁移到对应的 Gameplay/ 子目录（网络→Gameplay/Net、物理→Gameplay/Physics、输入→Gameplay/Input、资产→Gameplay/Assets 等）
- 将 3 个 TMap 污染文件迁移到 Gameplay/Input 和 Gameplay/Debug
- 将 1 个 TObjectPtr 污染文件迁移到 Gameplay/Input
- 迁移后修正所有文件的 `// Theme:` 标注
- 添加 CI 检查：文件所在目录路径必须与 Theme 标注和实际内容一致

---

## 7. Bindings/ 与 Gameplay/ 类型覆盖重复

> Bindings/ 和 Gameplay/ 目录下存在 6 个同名的数学类型子目录，两套测试在构造、操作符、成员访问等基础维度上高度重叠。

### 7.1 重叠类型矩阵

| 类型 | Bindings/ 文件数 | Gameplay/ 文件数 | 重叠维度 |
|------|:---:|:---:|------|
| `FVector` | 13 | 26 | 构造、操作符、成员访问、查询方法 |
| `FLinearColor` | 8 | 18 | 构造、操作符、成员访问、方法 |
| `FQuat` | 11 | 8 | 构造、操作符、成员访问、转换方法 |
| `FRotator` | 10 | 19 | 构造、操作符、成员访问、转换方法 |
| `FTransform` | 9 | 23 | 构造、操作符、成员访问、组合/逆变换 |
| `FVector2D` | 10 | 18 | 构造、操作符、成员访问、点积 |

### 7.2 以 FVector 为例的具体重叠分析

**Bindings/FVector**（13 文件，`Test_<Category>_<Part>.as` 命名）:
- `Test_ConstructionAndAssignment_01.as` — FVector 构造函数 + 赋值
- `Test_Operators_01.as` — 算术/比较操作符
- `Test_Queries_01~03.as` — 长度、距离、归一化等查询
- `Test_Behavior_01~05.as` — 各种行为组合

**Gameplay/FVector**（26 文件，语义命名）:
- `Test_FVectorConstruction_01~02.as` — 构造函数（与 Bindings 的 ConstructionAndAssignment 重叠）
- `Test_FVectorArithmeticOperators.as` — 算术操作符（与 Bindings 的 Operators 重叠）
- `Test_FVectorComparisonOperators.as` — 比较操作符（与 Bindings 的 Operators 重叠）
- `Test_FVectorMemberAccess.as` — 成员访问（与 Bindings 的 Behavior 部分重叠）
- `Test_FVectorMethods_01~02.as` — 方法测试（与 Bindings 的 Queries 部分重叠）
- `Test_FVectorDotAndCross_01~02.as` — 点积叉积（Bindings 的 Queries 中也有）
- `Test_FVectorExtendedOperatorsAndMethods.as` — 扩展操作符方法

**Gameplay 独有维度**（Bindings 未覆盖）:
- `Test_FVectorContainerProperties.as` — 作为 UProperty 容器属性
- `Test_FVectorDeclarationDefaults.as` — 声明默认值
- `Test_FVectorWriteRoundTrip.as` — 写入回读
- `Test_FVectorScriptMemberAndLocalUsage.as` — 脚本成员与局部使用
- `Test_DefaultFVectorPropertyApplied.as` — 默认属性应用
- `Test_FunctionParameters*.as` / `Test_FunctionReturnValues.as` — 函数参数/返回值语义
- `Test_Vector4IntPointIntVectorExpressions.as` — 跨类型表达式

**Bindings 独有维度**（Gameplay 未覆盖）:
- `Test_ConversionAndFormatting_01.as` — 转换与格式化（FVector3f、FVector_NetQuantize 等）
- `Test_NamespaceAndGlobalFunctions_01.as` — 命名空间与全局函数（ZeroVector、ForwardVector 等）
- `Test_MutationAndLifecycle_01.as` — 突变与生命周期

### 7.3 两套体系的定位差异

| 维度 | Bindings/ | Gameplay/ |
|------|-----------|-----------|
| 命名风格 | `Test_<Category>_<Part>.as`（机械分片） | `Test_FVector<Semantic>.as`（语义命名） |
| 覆盖逻辑 | 从 C++ Bind 源码反推 surface | 从脚本使用场景出发 |
| 函数风格 | `Observe_<Surface>_Nominal`（返回 bool） | 描述性函数名 + assert |
| 独特价值 | surface 级隔离验证、转换/格式化、命名空间 | 容器属性语义、函数参数/返回值、声明默认值、写入回读 |

### 7.4 问题

1. **维护成本翻倍**：同一个类型（如 FVector）的基础操作（构造、操作符）在两套体系中各测一遍，修改 API 后需要同步两处测试
2. **风格不一致加剧认知负担**：Bindings 用 `Observe_X_Nominal`，Gameplay 用 `Test_FVectorConstruction`，同一类型两套函数命名风格
3. **Gameplay 目录功能膨胀**：Gameplay/FVector 有 26 个文件，其中 `Test_FunctionParameters*.as` / `Test_FunctionReturnValues.as` 等并非 FVector 专属测试，而是函数参数传递语义测试（以 FVector 为载体），放在 FVector 子目录下归类不准

### 7.5 修复建议

- **短期**：建立交叉引用表，标注哪些 Gameplay 测试覆盖了哪些 Bindings surface，避免重复维护
- **中期**：将 Gameplay 独有维度（容器属性、函数参数语义、声明默认值、写入回读）迁移到 Bindings 体系作为补充 surface；将 Bindings 独有维度（转换/格式化、命名空间）迁移到 Gameplay 作为补充场景
- **长期**：统一为一套体系，按 surface + 场景双层组织，消除重复
- 将 Gameplay/<Type>/Test_FunctionParameters*.as 和 Test_FunctionReturnValues.as 迁移到独立的 `FunctionSemantics/` 目录，它们测的是函数参数传递语义而非类型本身

---

## 8. Language/ 目录多层级文件污染（严重）

> Language/ 是 TestSource 中最大的目录之一，包含 9 个子目录（Access、Casting、Const、ControlFlow、Literals、Namespace、Operators、Preprocessor、Syntax）。审查发现至少 4 个子目录存在严重的文件污染或分类混乱，其中 `Literals/FString/` 和 `Syntax/EdgeCases/` 已退化为无序的"倾倒场"。

### 8.1 Language/Literals/FString/ — 60+ 文件的字符串测试倾倒场

该目录名义上是"FString 字面量测试"，实际包含 60+ 文件，覆盖了几乎所有与字符串相关的测试，大量文件与"字面量"无关：

| 文件类别 | 代表文件 | 与"字面量"的关系 |
|----------|----------|:---:|
| 函数参数传递 | `Test_FunctionParametersIn/InOut/Out/Value.as` | ❌ 完全无关 |
| 函数默认参数 | `Test_FunctionDefaultParameters.as` | ❌ 完全无关 |
| 函数重载 | `Test_FunctionOverloading.as` | ❌ 完全无关 |
| 函数返回值 | `Test_FunctionReturnValues.as` | ❌ 完全无关 |
| 全局常量声明 | `Test_GlobalConstDeclarations.as` | ❌ 完全无关 |
| 字符串方法 | `Test_ReplaceMethods/ReverseMethods/SearchMethods/SplitMethods/SubstringMethods/TrimMethods.as` | ❌ 方法测试非字面量 |
| 格式化 | `Test_FormatMethods.as` / `Test_FormatStringRewriteProducesExpectedOutput.as` | ❌ 格式化非字面量 |
| 容器属性 | `Test_StringContainerProperties.as` | ❌ 容器属性非字面量 |
| 声明上下文 | `Test_StringDeclarationContexts.as` | ❌ 声明非字面量 |
| 字符串族 | `Test_StringFamilyDeclarationDefaults/ReplicatedProperties/ScriptSpecialTextValues/WriteRoundTrip.as` | ❌ 跨 FString/FName/FText |
| FName 测试 | `Test_FName_Mixed_01~04.as` | ❌ FName 非 FString 字面量 |
| FText 哈希 | `Test_FTextContainerHashBoundariesRemainUnsupported_01~02.as` | ❌ FText 非字面量 |
| 属性读写 | `Test_StringPropertyScriptReadWriteApiSurface.as` | ❌ 属性 API 非字面量 |
| 可变字符串 | `Test_MutableStringEdgeCases.as` / `Test_MutableStringMethods.as` | ❌ 可变性非字面量 |
| 不支持边界 | `Test_UnsupportedStringExpressionBoundaries_01~08.as` / `Test_UnsupportedFunctionSignatureBoundaries.as` | ❌ 负面边界非字面量 |

真正的"字面量"测试仅有 `Test_Literals_Positive_01~07.as`（7 个文件）和 `Test_StringLiterals.as`，占目录的约 12%。

### 8.2 Language/Syntax/EdgeCases/ — 200+ 文件的终极倾倒场

该目录是整个 TestSource 中最大的单一子目录，包含 200+ 文件，涵盖完全不相关的多个领域：

| 污染类别 | 代表文件 | 应属目录 | 文件数 |
|----------|----------|----------|:---:|
| GC 垃圾回收 | `Test_GCBasicReclaim.as` / `Test_GCCollectionMethods.as` / `Test_GCContainerProtection.as` 等 | `Language/GC/` 或独立目录 | ~10 |
| 输入系统 | `Test_GamepadInput.as` / `Test_KeyboardKeys.as` / `Test_MouseInput.as` / `Test_KeyDirectBinding.as` 等 | `Gameplay/Input/` | ~8 |
| CVar 控制台变量 | `Test_CommonCVarUsagePatterns.as` / `Test_RegisteredCVarNameMatrix.as` / `Test_ExistingEngineCVarSmokePreservesAndRestoresValues.as` 等 | `Gameplay/CVar/` | ~5 |
| 事件系统 | `Test_EventBindAndTrigger.as` / `Test_EventBusDecouplesPublisherAndReceiver.as` / `Test_EventChaining.as` 等 | `Feature/Delegates/` 或独立目录 | ~8 |
| 控制台命令 | `Test_ConsoleCommandCommonStringMatrixDispatch.as` / `Test_ConsoleCommandRegistrationArgumentsAndUnload.as` 等 | `Gameplay/Debug/` | ~5 |
| 运行时编译 | `Test_RuntimeCompile*.as` / `Test_ParseEventsAreBroadcast*.as` / `Test_SuccessfulCompileEmits*.as` 等 | `Feature/Compile/` 或独立目录 | ~6 |
| 声明导入 | `Test_DeclaredFunctionImportRoundTrip_01~02.as` / `Test_DeclaredFunctionImportRebindsAfterProviderReload_01~03.as` | `Feature/Provider/` 或 `HotReload/` | ~5 |
| 布尔类型 | `Test_BoolContainerProperties.as` / `Test_BoolDeclarationDefaults.as` / `Test_BoolReplicatedProperties.as` / `Test_BoolWriteRoundTrip.as` | `Bindings/bool/` 或 `Definitions/UProperty/` | ~4 |
| 整数类型 | `Test_IntContainerProperties.as` / `Test_IntFamilyBoundaryValues.as` / `Test_IntFamilyWriteRoundTrip.as` 等 | `Bindings/int/` 或 `Definitions/UProperty/` | ~10 |
| 浮点类型 | `Test_FloatContainerProperties.as` / `Test_FloatFamilyBoundaryValues.as` / `Test_FloatPropertyScriptMutationRoundTrip.as` 等 | `Bindings/float/` 或 `Definitions/UProperty/` | ~8 |
| FQuat 类型 | `Test_FQuatClassMemberRuntimeFlow.as` / `Test_FQuatContainerProperties.as` / `Test_FQuatDeclarationDefaults.as` 等 | `Bindings/FQuat/` 或 `Gameplay/FQuat/` | ~4 |
| FBox 类型 | `Test_FBoxOperations.as` / `Test_FBox2DUnsupportedBoundary.as` | `Bindings/FBox/` | ~2 |
| UObject | `Test_UObjectFlagMutationAndTransientState.as` / `Test_UObjectOuterChainAndPathMatrix.as` | `Definitions/UClass/` | ~2 |
| Handle | `Test_HandleBasics.as` / `Test_HandleCast.as` / `Test_HandleInContainers.as` 等 | 独立 `Handle/` 目录 | ~6 |
| 世界流送 | `Test_WorldStreamingNullGuards.as` | `World/` | ~1 |
| 委托导入 | `Test_DeclaredFunctionImportRebindsAfterProviderReload_*.as` | `Feature/Delegates/` 或 `HotReload/` | ~3 |

真正的"语法边缘情况"测试（如 `Test_EdgeCases_Positive/Negative_*.as`、`Test_Class_Negative/Positive_*.as`、`Test_EmptySourceFailsWithoutStateLeak.as`、`Test_InfiniteLoops.as`、`Test_RecursiveFrameIsolation.as` 等）约占 40%，其余 60% 为污染文件。

### 8.3 Language/ControlFlow/Jump/ — 函数参数/返回值测试错位

`Jump/` 子目录应测试 break/continue/return 等跳转控制流，但包含多个完全无关的文件：

| 文件名 | 实际内容 | 与 Jump 的关系 |
|--------|----------|:---:|
| `Test_ContainerAsReturnValue.as` | 容器作为返回值（TArray/TMap 返回） | ❌ 无关 |
| `Test_FMatrixReturnApiCompiles.as` | FMatrix 返回 API 编译验证 | ❌ 无关 |
| `Test_FunctionReturnValues.as` | bool 函数返回值 | ❌ 无关 |
| `Test_FunctionReturnValues_R01154.as` | 函数返回值回归测试 | ❌ 无关 |
| `Test_FunctionReturnValues_R01179.as` | 函数返回值回归测试 | ❌ 无关 |
| `Test_FunctionReturnValues_R01428.as` | 函数返回值回归测试 | ❌ 无关 |
| `Test_GeometricStructFunctionParametersAndReturns.as` | 几何结构体参数与返回值 | ❌ 无关 |

文件头 `// Theme: Language.ControlFlow.Jump` 标注与实际内容完全矛盾——这些文件测的是函数签名语义，不是跳转语句。

### 8.4 Language/Access/ — World 流送测试错位

`Access/` 子目录应测试访问修饰符（public/private/protected），但包含：

| 文件名 | 实际内容 | 与 Access 的关系 |
|--------|----------|:---:|
| `Test_WorldStreamingAccess.as` | World 流送关卡访问（GetStreamingLevels） | ❌ 完全无关 |

该文件应属于 `World/` 目录。

### 8.5 根因与影响

**根因**：`Language/` 目录在项目初期可能确实是语言级测试的唯一归属地，但随着测试数量增长，新测试被不断倾倒到 `Syntax/EdgeCases/` 和 `Literals/FString/` 等已有大目录中，而非创建新的分类目录。`ControlFlow/Jump/` 的污染可能是迁移脚本将所有含 "Return" 关键字的文件统一归入了 "Jump"。

**影响**：
- `Syntax/EdgeCases/` 已无法作为"语法边缘情况"的可靠索引——维护者在此目录中找不到纯粹的语法测试
- 覆盖统计严重失真：GC 覆盖率被埋在 Syntax 下无法被发现，输入测试在 Language 下而非 Gameplay 下导致 Gameplay/Input 覆盖被低估
- Theme 标注体系在 Language/ 子目录中大面积失效

### 8.6 修复建议

- 将 `Syntax/EdgeCases/` 拆分为按领域分类的独立目录（`GC/`、`Handle/`、`RuntimeCompile/`、`ConsoleCommand/` 等）
- 将类型相关测试（bool/int/float/FQuat/FBox）迁移到 `Bindings/` 对应类型目录
- 将输入/CVar/事件测试迁移到 `Gameplay/` 对应子目录
- 将 `Literals/FString/` 拆分为 `StringMethods/`、`StringFamily/`、`FunctionParameters/`（后者应迁出到独立目录）等
- 将 `ControlFlow/Jump/` 中的函数返回值测试迁移到 `FunctionSemantics/` 目录
- 清理后 `Language/` 应仅保留真正的语言级测试：语法、操作符、控制流、字面量、命名空间、预处理、常量、转换

---

## 9. 跨目录命名模式不统一

> 在审查 Language/ 及其他目录时发现，TestSource 中至少存在 3 种并行的文件命名模式，且在同一目录内混用。

### 9.1 三种命名模式

| 模式 | 格式 | 代表目录 | 代表文件 |
|------|------|----------|----------|
| A: 正面/负面编号 | `Test_<Topic>_Positive_<NN>.as` / `Test_<Topic>_Negative_<NN>.as` | `Language/Casting/`、`Language/Operators/`、`Definitions/UFunction/` | `Test_Cast_Positive_01.as`、`Test_Arithmetic_Negative_03.as` |
| B: 混合编号 | `Test_<Topic>_Mixed_<NN>.as` | `Language/Namespace/`、`Containers/TOptional/` | `Test_Namespace_Mixed_01.as`、`Test_TOptional_Mixed_03.as` |
| C: 语义描述 | `Test_<DescriptiveName>.as` | `Gameplay/`、`HotReload/`、`Containers/TArray/` | `Test_TArraySortAndReverse.as`、`Test_SoftReloadUpdatesMemberFunctionBodyWithoutReplacingClass.as` |

### 9.2 同目录混用问题

| 目录 | 混用情况 |
|------|----------|
| `Language/Literals/FString/` | 模式 A（`Test_Literals_Positive_01~07`、`Test_Negative_01~10`、`Test_Methods_Positive_01~05`）与模式 C（`Test_ReplaceMethods.as`、`Test_SearchMethods.as`、`Test_FormatMethods.as`）混用 |
| `Language/Syntax/EdgeCases/` | 模式 A（`Test_Class_Positive_01~08`、`Test_Class_Negative_01~10`、`Test_EdgeCases_Positive_01~06`）与模式 C（`Test_GCBasicReclaim.as`、`Test_HandleBasics.as`）混用 |
| `Language/Syntax/Keywords/` | 模式 A（`Test_Keywords_Positive_01~05`、`Test_Keywords_Negative_01~05`） |
| `Language/Casting/` | 模式 A（`Test_Cast_Positive_01~03`、`Test_Cast_Negative_01~11`）与模式 C（`Test_StringConversions.as`、`Test_ObjectCastAndTypeChecks.as`）混用 |

### 9.3 未文档化的 `_R0xxxx` 回归测试后缀

在多个目录中发现一种未在 TestConventions 中记录的命名模式——`_R0xxxx` 后缀：

| 目录 | 文件示例 | 数量 |
|------|----------|:---:|
| `Language/Syntax/EdgeCases/` | `Test_FunctionParametersIn_R01151.as`、`Test_FunctionParametersValue_R01150.as`、`Test_FunctionDefaultParameters_R01155.as` | ~15 |
| `Definitions/UFunction/` | `Test_UFunctionParametersAndReturn_R01131.as`、`Test_UFunctionParametersAndReturn_R01157.as`、`Test_UFunctionParametersAndReturn_R01278.as` | ~9 |
| `Definitions/UInterface/` | `Test_UInterfaceMacroDeclarationRejected_R01967.as` | ~1 |
| `Language/ControlFlow/Jump/` | `Test_FunctionReturnValues_R01154.as`、`Test_FunctionReturnValues_R01179.as`、`Test_FunctionReturnValues_R01428.as` | ~3 |

这些 `_R0xxxx` 文件是同一基名的回归变体，但：
- 后缀含义未文档化（推测为回归用例 ID 或报告 ID）
- 同一基名有多个 `_R0xxxx` 变体（如 `Test_UFunctionParametersAndReturn` 有 R01131/R01157/R01181/R01203/R01234/R01278/R01301/R01324/R01431 共 9 个），但变体之间的差异未在文件名或注释中体现
- 维护者无法从文件名判断是否需要保留所有变体

### 9.4 修复建议

- 统一为模式 C（语义描述命名）作为主标准，模式 A/B 仅在确实需要编号序列时使用
- 在 TestConventions.md 中补充 `_R0xxxx` 回归后缀的命名规范和含义
- 回归变体应在文件头注释中标注与基名文件的差异点

---

## 10. Debugger/ 目录覆盖极度稀疏且命名退化

> Debugger/ 目录仅有 3 个子目录，每个子目录仅含 1 个文件，全部命名为 `Test_Block_01.as`，是整个 TestSource 中命名最退化的目录。

### 10.1 目录结构

| 子目录 | 文件名 | C++ 来源 |
|--------|--------|----------|
| `FunctionEvaluationGuards/` | `Test_Block_01.as` | `AngelscriptDebuggerValueTests.cpp::FunctionEvaluationGuards` |
| `GetterPropertyTracking/` | `Test_Block_01.as` | （同类 C++ 测试） |
| `InheritedGetterTracksBasePropertyAddress/` | `Test_Block_01.as` | （同类 C++ 测试） |

### 10.2 问题

1. **覆盖极度稀疏**：调试器是一个复杂的功能领域（断点、变量查看、调用栈、表达式求值、步进），但仅有 3 个测试文件，覆盖范围远不足以保障调试器质量
2. **命名完全退化**：`Test_Block_01.as` 不携带任何语义——不看文件内容完全无法知道测的是什么；`_01` 后缀在只有 1 个文件的目录中纯属噪声
3. **Theme 标注模糊**：文件头注释为 `// Theme: Debugger marker`，"marker" 不是有意义的分类
4. **与 Bindings/ 命名体系脱节**：Debugger 目录未采用 `Observe_<Surface>_Nominal` 命名，也未采用 `Test_<ScenarioCategory>_<Part>` 文件命名，是第三种风格

### 10.3 修复建议

- 将 `Test_Block_01.as` 重命名为语义名（如 `Test_FunctionEvaluationGuardSkipsAutoEval.as`）
- 扩展调试器测试覆盖：断点命中、步进（StepIn/StepOver/StepOut）、调用栈检查、变量查看、条件断点、热重载中断点保持等
- 确定 Debugger/ 应遵循的命名约定（建议与 Bindings/ 对齐或独立定义）

---

## 11. Feature/PropertyAccess/ 包含 TSet 测试 — 容器测试再次错位

> 在 §6 中已发现 Containers/TSet/ 存在严重文件污染，审查 Feature/ 目录后发现 TSet 测试同样散落在 Feature/PropertyAccess/ 中，构成第三处容器测试错位。

### 11.1 Feature/PropertyAccess/ 中的 TSet 文件

| 文件名 | 实际内容 | 与 PropertyAccess 的关系 |
|--------|----------|:---:|
| `Test_TSetAdvancedOperations_01.as` | TSet 高级操作（Add/Remove/Contains） | ❌ TSet 测试 |
| `Test_TSetAdvancedOperations_02.as` | TSet 高级操作续 | ❌ TSet 测试 |
| `Test_TSetArrayConversion_01.as` | TSet 与 TArray 转换 | ❌ TSet 测试 |
| `Test_TSetArrayConversion_02.as` | TSet 与 TArray 转换续 | ❌ TSet 测试 |
| `Test_TSetAsParameter.as` | TSet 作为函数参数 | ❌ TSet 测试 |
| `Test_TSetDuplicateDedupeRemoveReset.as` | TSet 去重/删除/重置 | ❌ TSet 测试 |
| `Test_TSetElementTypes.as` | TSet 元素类型 | ❌ TSet 测试 |
| `Test_TSetIteration.as` | TSet 迭代 | ❌ TSet 测试 |
| `Test_TSetResetAndCapacity.as` | TSet 重置与容量 | ❌ TSet 测试 |
| `Test_TSetSetOperations_01.as` | TSet 集合操作（交集/并集） | ❌ TSet 测试 |
| `Test_TSetSetOperations_02.as` | TSet 集合操作续 | ❌ TSet 测试 |

共 11 个 TSet 文件散落在 PropertyAccess/ 中，与该目录其他文件（BlueprintGetter、PropertyDecorator、CVarGetSet、RawFieldAccess 等属性访问测试）完全不相关。

### 11.2 TSet 测试的碎片化分布

综合 §6 和本节，TSet 测试目前分布在三个不相关的位置：

| 位置 | TSet 相关文件数 | 实际状态 |
|------|:---:|------|
| `Containers/TSet/` | ~10 | 25 个文件中仅 10 个相关，15 个为污染文件 |
| `Feature/PropertyAccess/` | 11 | 全部为 TSet 测试但目录错误 |
| `Bindings/TSet/` | (未单独审查) | 应为 surface 级覆盖 |

### 11.3 修复建议

- 将 `Feature/PropertyAccess/` 中的 11 个 TSet 文件迁移到 `Containers/TSet/`（场景测试）或 `Bindings/TSet/`（surface 测试），按内容性质分类
- 清理 `Containers/TSet/` 中的 15 个污染文件后，将 PropertyAccess 的 TSet 文件合并进去
- 确保所有 TSet 测试集中管理，避免碎片化分布

---

## 12. HotReload/ 目录扁平化 — 100+ 文件无子分类

> HotReload/ 目录包含 100+ 个文件，全部为描述性命名（无 `_01` 序号），但整个目录是扁平结构，没有任何子目录分类。

### 12.1 文件分布

100+ 文件覆盖了热重载的多个子领域，但全部平铺在一个目录下：

| 子领域 | 代表文件 | 估计文件数 |
|--------|----------|:---:|
| Soft Reload | `SoftReloadUpdatesMemberFunctionBodyWithoutReplacingClass.as`、`SoftReloadPreservesNamespaceOverloadDispatch.as` 等 | ~20 |
| Full Reload | `FullReloadAddsPropertyAndUpdatesDefaults.as`、`FullReloadKeepsOpenEditorLevelBlueprintRecoverableAfterParentShapeChange.as` 等 | ~15 |
| PIE 交互 | `ReloadBeforePIEStartsUsesReloadedScriptInPIE.as`、`SoftReloadDuringPIEUpdatesLiveLevelScriptBody.as` 等 | ~10 |
| 委托重载 | `DelegateSignatureChange.as`、`DelegateAddedSuggestsFullReload.as`、`MulticastDelegateRuntimeRunsAcrossReloads.as` 等 | ~15 |
| 属性重载 | `PropertyCountChange.as`、`PropertyRemovalDropsFieldFromReplacementClass.as`、`PropertySpecifierReloadUpdatesFlags.as` 等 | ~10 |
| 枚举重载 | `EnumValueChange.as`、`EnumReloadMarksBlueprintVariablesAndPinsImpacted.as` 等 | ~5 |
| 函数重载 | `FunctionAddedSuggestsFullReload.as`、`FunctionSignatureChanged.as` 等 | ~10 |
| 结构体重载 | `StructFullReloadReplacesScriptStructAndKeepsVersionChain.as`、`StructLayoutReloadMarksBlueprintVariablesAndPinsImpacted.as` 等 | ~5 |
| 失败处理 | `FailedReloadDoesNotBroadcastReloadDelegates.as`、`FailedReloadKeepsOldClassAndProperties.as`、`FailureKeepsOldCodeAndDiagnostics.as` | ~5 |
| Blueprint 子类 | `SoftReloadKeepsBlueprintChildInstanceOnUpdatedParentBody.as`、`StructuralReloadKeepsExistingAndFreshBlueprintChildDefaults.as` 等 | ~5 |

### 12.2 问题

1. **无法浏览**：100+ 文件平铺在一个目录下，维护者无法快速定位特定子领域的测试
2. **与 TestFramework/HotReload/ 概念重叠**：`HotReload/`（100+ 文件）测试 AngelScript 热重载功能本身，`TestFramework/HotReload/`（7 文件）测试测试框架自身的热重载行为——两者都叫 "HotReload" 但测的是不同层面，命名未区分
3. **文件命名风格良好但组织缺失**：文件名都是语义描述（如 `SoftReloadUpdatesMemberFunctionBodyWithoutReplacingClass.as`），但缺少目录级分类来支撑导航

### 12.3 修复建议

- 按 SoftReload/FullReload/PIE/Delegate/Property/Function/Struct/Failure/BlueprintImpact 等子领域创建子目录
- 将 `TestFramework/HotReload/` 重命名为 `TestFramework/RegistryHotReload/` 或类似名称，明确其测试的是测试框架自身的注册表热重载行为而非 AngelScript 热重载功能
- 考虑将 HotReload/ 的文件命名前缀化（如 `SoftReload_UpdatesMemberFunctionBodyWithoutReplacingClass.as`）以在扁平视图中也能分组排序

---

## 13. World/Component/ 目录 — 70+ 文件扁平化且内容混杂

> World/Component/ 包含 70+ 文件，全部平铺无子目录。文件覆盖了组件声明、生命周期、Tick、碰撞、输入、音频、相机等多种子领域，但组织结构无法支撑导航。

### 13.1 子领域分布

| 子领域 | 代表文件 | 估计文件数 |
|--------|----------|:---:|
| 组件声明与创建 | `Test_ComponentBasicDeclaration.as`、`Test_CreateComponent.as`、`Test_GetOrCreateComponent.as`、`Test_CustomScriptComponent.as` | ~8 |
| 生命周期与激活 | `Test_ComponentLifecycle.as`、`Test_ComponentActivation.as`、`Test_ComponentDestruction.as`、`Test_ComponentRegistrationAndActivation.as` | ~10 |
| Tick 控制 | `Test_ComponentTickControl.as`、`Test_ComponentTickConfigurationAndPrerequisites.as`、`Test_ComponentTickDispatchIsExact.as`、`Test_ComponentRuntimeTickIntervalControl.as` | ~5 |
| 碰撞 (Primitive) | `Test_PrimitiveCollisionChannelMatrixReadback.as`、`Test_PrimitiveCollisionConfigurationReadback.as`、`Test_PrimitiveCollisionEvents.as`、`Test_PrimitiveCollisionResponse.as`、`Test_PrimitiveHitEvents.as`、`Test_PrimitivePhysics.as`、`Test_PrimitivePhysicsStateReadback.as`、`Test_PrimitiveRendering.as`、`Test_PrimitiveTraceObjectQueryReadback.as`、`Test_PrimitiveHiddenInGame.as` | ~12 |
| 特定组件类型 | `Test_AudioComponentDeclarationAndControls.as`、`Test_CameraComponent.as`、`Test_CapsuleComponent.as`、`Test_BoxComponent.as`、`Test_SphereComponent.as`、`Test_SpringArmComponent.as`、`Test_StaticMeshComponent.as`、`Test_CharacterMovementComponent.as` | ~10 |
| 输入组件 | `Test_AdvancedInputComponentBindingCollections.as`、`Test_EnhancedInputComponentBindingEventsAndRemoval.as`、`Test_InputComponentFinding.as` | ~3 |
| SceneComponent 变换 | `Test_SceneComponentCompleteTransform.as`、`Test_SceneComponentHierarchy.as`、`Test_SceneComponentRelativeTransform.as`、`Test_SceneComponentWorldTransform.as`、`Test_SceneComponentTags.as` | ~5 |
| 查询与查找 | `Test_ComponentFinding.as`、`Test_ComponentFindingByClassAndTag.as`、`Test_GetAllComponents.as`、`Test_GetComponent.as`、`Test_NameAndClassFilteringAreStrict.as` | ~6 |
| Actor 级测试（错位） | `Test_ActorOwner.as`、`Test_BeginPlay.as`、`Test_Tick.as`、`Test_EventBuiltInActorAndComponentInstances.as` | ~4 |

### 13.2 问题

1. **Primitive 碰撞测试占 12/70（17%）**：这些文件全部以 `Test_Primitive*` 开头，形成了一个内聚的子领域，但与组件声明/生命周期测试混在同一目录
2. **Actor 级测试错位**：`Test_ActorOwner.as`、`Test_BeginPlay.as`、`Test_Tick.as` 测试的是 Actor 生命周期事件而非 Component 特有行为，应归属 `World/Actor/`
3. **输入组件测试孤立**：3 个输入相关文件散落在组件目录中，与 `World/Actor/` 中的 `Test_EnhancedInputComponentBindingEventsAndRemoval.as` 存在概念重叠
4. **无子目录分类**：70+ 文件平铺，维护者无法按子领域快速定位

### 13.3 修复建议

- 创建 `Primitive/` 子目录收纳 12 个碰撞测试
- 创建 `Lifecycle/` 子目录收纳生命周期/激活/销毁测试
- 创建 `SceneComponent/` 子目录收纳变换/层级测试
- 将 `Test_ActorOwner.as`、`Test_BeginPlay.as`、`Test_Tick.as` 迁移到 `World/Actor/`
- 将特定组件类型测试（Audio/Camera/Capsule/Box/Sphere/SpringArm/StaticMesh/CharacterMovement）归入 `Types/` 子目录

---

## 14. Definitions/UFunction/ — `_R0xxxx` 后缀实质是类型覆盖测试而非回归变体

> `Test_UFunctionParametersAndReturn_R0xxxx` 系列共 9 个文件（R01131、R01157、R01181、R01203、R01234、R01278、R01301、R01324、R01431），文件名暗示是同一个测试的回归变体，但实际内容显示每个文件测试的是完全不同的类型。

### 14.1 文件内容对比

| 文件 | Theme 描述 | 测试类型 | Actor 类名 |
|------|-----------|----------|-----------|
| `Test_UFunctionParametersAndReturn.as`（基文件） | bool UFUNCTION echo/toggle | `bool` | `ACoverageBoolFunctionActor` |
| `_R01131.as` | FLinearColor mix/luminance/out/clamp | `FLinearColor` | `ACoverageFLinearColorFunctionActor` |
| `_R01157.as` | float/double value, &out, &inout | `float`/`double` | `ACoverageFloatFunctionActor` |
| `_R01431.as` | int/int64/uint UFUNCTION plus &out | `int`/`int64`/`uint` | `ACoverageIntFunctionActor` |

### 14.2 问题

1. **命名严重误导**：`_R0xxxx` 后缀在测试惯例中通常表示"回归用例 ID"，暗示是对同一 bug 的回归验证。但这些文件实际是按类型（bool/float/int/FLinearColor/...）拆分的独立覆盖测试，彼此测试内容完全不同
2. **基文件与"变体"关系模糊**：基文件 `Test_UFunctionParametersAndReturn.as` 测试 bool 类型，而"变体"测试其他类型——基文件并非"模板"而是系列中的一个成员
3. **R0xxxx ID 含义不透明**：无法从文件名推断 R01131 对应什么类型、R01157 对应什么类型，必须打开文件才能知道
4. **C++ 来源不同**：每个文件的 `// C++:` 来源不同（`AngelscriptCoverageBoolFunctionTests.cpp`、`AngelscriptCoverageFLinearColorFunctionTests.cpp`、`AngelscriptCoverageFloatFunctionTests.cpp`、`AngelscriptCoverageIntFunctionTests.cpp`），进一步证明它们是独立测试而非变体

### 14.3 修复建议

- 将 `_R0xxxx` 后缀替换为类型描述性后缀，如 `Test_UFunctionParametersAndReturn_Bool.as`、`Test_UFunctionParametersAndReturn_FLinearColor.as`、`Test_UFunctionParametersAndReturn_FloatDouble.as`、`Test_UFunctionParametersAndReturn_IntInt64UInt.as`
- 如果 R0xxxx 确实是内部回归 ID，在 `TestConventions.md` 中文档化该约定，并在文件头注释中补充类型描述
- 考虑将基文件重命名为 `Test_UFunctionParametersAndReturn_Bool.as` 以与系列一致

---

## 15. Definitions/UClass/ — 包含 21 个热重载测试归属错误

> Definitions/UClass/ 目录包含 100+ 文件，其中 21 个文件与热重载（Reload/Recompile/Rename/Retarget/Provider/Depend）相关，应归属 HotReload/ 目录。

### 15.1 错位文件清单

| 子领域 | 文件 | 数量 |
|--------|------|:---:|
| 依赖重定向 | `Test_BodyOnlyProviderReloadDoesNotEscalateDependents_01~02`、`Test_ContainerSubtypeDependencyRetargetsArrayInnerType_01~02`、`Test_CyclicPropertyDependencyTerminatesAndRetargetsBothSides_01~02`、`Test_MethodSignatureDependencyRetargetsParametersAndReturnValue_01~02`、`Test_MultiHopPropertyDependencyRetargetsEntireChain_01~02`、`Test_SingleHopPropertyDependencyRetargetsAfterProviderFullReload_01~02`、`Test_SuperClassDependencyRetargetsChildToReloadedBase_01~02` | 14 |
| 重编译 | `Test_RecompileDoesNotCrashClassSwitch_01~02` | 2 |
| 重命名 | `Test_RenameReplacesOldClass_01~02` | 2 |
| 修复拒绝重载 | `Test_FixingRejectedReloadPublishesCorrectedClass_01~03` | 3 |

### 15.2 问题

1. **概念归属错误**：这 21 个文件测试的是热重载机制（依赖追踪、重编译、重命名替换、修复拒绝），不是 UClass 定义本身。它们的 Theme 标注为 `Definitions.UClass` 但实际内容与 HotReload/ 目录的测试属于同一领域
2. **`_01~02` 序号无差异说明**：每对 `_01`/`_02` 之间的差异未在文件名或注释中体现，维护者无法判断为何需要两个文件
3. **加剧 HotReload/ 目录膨胀**：HotReload/ 已有 100+ 文件，这 21 个文件如果迁移过去将使该目录进一步膨胀——但归属正确性优先于目录大小，应先迁移再按 §12.3 建议子分类

### 15.3 修复建议

- 将 21 个热重载文件迁移到 `HotReload/` 目录
- 迁移后按 §12.3 建议归入 `HotReload/Dependency/` 子目录
- 在迁移时为 `_01`/`_02` 对补充差异注释（如 `_01_SoftReload`、`_02_FullReload`）

---

## 16. Definitions/UProperty/ — 包含 UClass 测试和 AnimNotify 测试

> Definitions/UProperty/ 目录有 74 个文件，其中至少 16 个文件不属于 UProperty 测试范畴。

### 16.1 UClass 测试错位

以下 14 个文件以 `Test_UClass*` 开头，Theme 标注为 `Definitions.UProperty`，但实际测试的是 UClass 的属性访问、容器成员、接口成员等行为：

| 文件 | 实际测试内容 |
|------|------------|
| `Test_UClassAccessAndBlueprintVisibilityMatrix.as` | UClass 属性访问修饰符矩阵 |
| `Test_UClassContainerMemberMatrix.as` | UClass 容器成员 |
| `Test_UClassEnumContainerMemberMatrix.as` | UClass 枚举容器成员 |
| `Test_UClassInterfaceMemberMatrix.as` | UClass 接口成员 |
| `Test_UClassNonUPropertyMemberMatrix.as` | UClass 非 UProperty 成员 |
| `Test_UClassOptionalMemberMatrix.as` | UClass Optional 成员 |
| `Test_UClassPropertySpecifierAndMetadataMatrix.as` | UClass 属性修饰符和元数据 |
| `Test_UClassReferenceContainerMemberMatrix_01~02.as` | UClass 引用容器成员 |
| `Test_UClassReferenceMemberMatrix.as` | UClass 引用成员 |
| `Test_UClassScalarTextStructMemberMatrix.as` | UClass 标量/文本/结构体成员 |
| `Test_UClassScriptStructMemberContainerMatrix.as` | UClass ScriptStruct 成员容器 |

### 16.2 AnimNotify 测试错位

以下 2 个文件测试 AnimNotify 子类注册行为，与 UProperty 无关：

- `Test_SubclassRegistersUPropertyAndDerivesFromUAnimNotify.as`
- `Test_SubclassRegistersUPropertyAndDerivesFromUAnimNotifyState.as`

### 16.3 问题

1. **UClass 测试放在 UProperty 目录**：14 个 `Test_UClass*` 文件的 Theme 标注为 `Definitions.UProperty`，但测试类名和内容都是 UClass 级别的属性行为。虽然属性是 UClass 的组成部分，但这些测试的焦点是 UClass 的成员矩阵行为，而非 UProperty 本身的修饰符/标志行为
2. **AnimNotify 测试与 UProperty 无关**：2 个 AnimNotify 文件测试的是子类注册和派生行为
3. **UProperty 目录自身已有清晰的 UProperty 专用测试**：如 `Test_BoolPropertySpecifierFlags.as`、`Test_EditConstSpecifierSetsCPFEditConst.as`、`Test_TransientSpecifierSetsCPFTransient.as` 等，错位文件干扰了对 UProperty 覆盖范围的判断

### 16.4 修复建议

- 将 14 个 `Test_UClass*` 文件迁移到 `Definitions/UClass/`
- 将 2 个 AnimNotify 文件迁移到 `Definitions/UClass/` 或新建 `Definitions/AnimNotify/`
- 迁移后更新 Theme 标注

---

## 17. Definitions/Meta/ — 重复文件与非元数据测试污染

> Definitions/Meta/ 目录有 46 个文件，存在重复文件和多个非元数据测试的错位文件。

### 17.1 重复文件

`Test_GeneratedBodyInsideInterfaceRejected.as` 同时存在于 `Definitions/Meta/` 和 `Definitions/UInterface/`，内容测试相同（GENERATED_BODY 在接口内被拒绝），但 Theme 标注不同：

| 位置 | Theme | C++ 来源 |
|------|-------|---------|
| `Meta/` | `Definitions.Meta` | `GeneratedBodyInsideInterfaceRejected CompileAndExpectFailure`（无具体 .cpp 文件名） |
| `UInterface/` | `Definitions.UInterface` | `AngelscriptCoverageUInterfaceTests.cpp::GeneratedBodyInsideInterfaceRejected` |

两个文件头注释格式不同、Theme 不同、C++ 来源详细度不同，但测试的是同一个编译失败场景。

### 17.2 非元数据测试污染

以下文件的 Theme 标注为 `Definitions.Meta`，但实际测试内容与元数据无关：

| 文件 | 实际测试内容 | 应归属 |
|------|------------|--------|
| `Test_ComponentDestroyComponentPromoteChildrenAndK2Metadata.as` | DestroyComponent 销毁时子组件提升行为 | `World/Component/` |
| `Test_DeveloperOnlyModuleReportsEditorOnlyRootDiagnosticDuringGeneration.as` | 开发者模块的 EditorOnly 诊断 | `Definitions/UClass/` |
| `Test_EditorOnlyRootRejectedForRuntimeActor.as` | Runtime Actor 拒绝 EditorOnly 根 | `Definitions/UClass/` |
| `Test_NonEditorComponentCannotAttachToEditorOnlyParent.as` | 非 Editor 组件不能附加到 EditorOnly 父级 | `World/Component/` |
| `Test_InvalidAttachParentFailsClosed.as` | 无效附加父级失败处理 | `World/Component/` |
| `Test_GeneratedBodyInsideInterfaceRejected.as` | 接口内 GENERATED_BODY 被拒绝（重复） | `Definitions/UInterface/` |
| `Test_IsFunctionImplementedInScriptTurnsFalseAfterDiscard.as` | 函数实现在脚本丢弃后变为 false | `Definitions/UFunction/` |
| `Test_MacroExpansionIgnoresCommentsStringsAndInactiveBranches.as` | 宏展开忽略注释/字符串/非活跃分支 | `Language/Preprocessor/` |

### 17.3 问题

1. **重复文件浪费维护成本**：同一测试在两处维护，修改时容易遗漏一处
2. **8 个非元数据测试错位**：Meta/ 目录中约 17%（8/46）的文件与元数据无关，干扰了对元数据覆盖范围的评估
3. **Theme 标注全面失效**：错位文件的 Theme 全部标注为 `Definitions.Meta`，但实际内容属于 Component/UClass/UFunction/Preprocessor 等不同领域

### 17.4 修复建议

- 删除 `Meta/Test_GeneratedBodyInsideInterfaceRejected.as`，保留 `UInterface/` 版本（其 C++ 来源更详细）
- 将 8 个错位文件迁移到各自正确的目录
- 迁移后更新 Theme 标注

---

## 18. 全局汇总与优先级修复路线图

### 18.1 问题统计

| 编号 | 目录 | 问题类型 | 影响文件数 | 严重程度 |
|:---:|------|---------|:---:|:---:|
| §1 | Bindings/ | 函数命名模式问题 | 全部 | 中 |
| §2 | Bindings/ | 文件命名模式问题 | 全部 | 中 |
| §3 | 全局 | 两套命名体系不统一 | 全部 | 高 |
| §4 | Bindings/ vs Containers/ | API 覆盖偏差 | — | 高 |
| §5 | Containers/ | Contains 覆盖重叠 | — | 中 |
| §6 | Containers/ | 文件归属错误（TSet 60% 污染） | ~25 | 高 |
| §7 | Bindings/ vs Gameplay/ | 6 个数学类型重复覆盖 | ~12 | 中 |
| §8 | Language/ | 多层级文件污染 | ~130+ | 高 |
| §9 | 全局 | 3 种命名模式混用 + _R0xxxx 未文档化 | — | 中 |
| §10 | Debugger/ | 覆盖极度稀疏（3 文件） | 3 | 高 |
| §11 | Feature/PropertyAccess/ | TSet 测试错误分类 | 11 | 中 |
| §12 | HotReload/ | 100+ 文件扁平化 | 100+ | 中 |
| §13 | World/Component/ | 70+ 文件扁平化 + Actor 错位 | ~4 错位 | 中 |
| §14 | Definitions/UFunction/ | _R0xxxx 误导性命名 | 9 | 高 |
| §15 | Definitions/UClass/ | 21 个热重载测试错位 | 21 | 中 |
| §16 | Definitions/UProperty/ | 16 个 UClass/AnimNotify 错位 | 16 | 中 |
| §17 | Definitions/Meta/ | 1 重复 + 8 个非元数据错位 | 9 | 中 |

### 18.2 优先级修复路线图

**P0 — 立即修复（影响测试正确性理解）**

1. §10 Debugger/ 覆盖稀疏：仅 3 个文件无法保障调试器质量，需补充 DAP 协议、断点、调用栈、变量检视等核心场景测试
2. §14 UFunction _R0xxxx 重命名：9 个文件的命名严重误导，将 `_R0xxxx` 替换为类型描述性后缀
3. §17 Meta/ 重复文件删除：删除 `Meta/Test_GeneratedBodyInsideInterfaceRejected.as`，消除维护歧义

**P1 — 短期修复（影响目录可导航性）**

4. §8 Language/ 污染清理：`Syntax/EdgeCases/` 200+ 文件中约 60% 需迁移，`Literals/FString/` 60+ 文件中约 88% 需迁移——按实际内容重新分类
5. §6 Containers/ 污染清理：TSet 目录 15 个污染文件迁移，TMap/TObjectPtr 同步清理
6. §11 PropertyAccess/ TSet 迁移：11 个 TSet 文件迁移到 Containers/ 或 Bindings/
7. §15 UClass/ 热重载迁移：21 个文件迁移到 HotReload/
8. §16 UProperty/ UClass 迁移：16 个文件迁移到 UClass/

**P2 — 中期修复（改善组织结构）**

9. §12 HotReload/ 子分类：100+ 文件按 SoftReload/FullReload/PIE/Delegate 等创建子目录
10. §13 World/Component/ 子分类：70+ 文件按 Primitive/Lifecycle/SceneComponent/Types 创建子目录
11. §17 Meta/ 错位迁移：8 个非元数据文件迁移到正确目录
12. §3 命名体系统一：制定统一的文件命名规范，消除 Bindings/ 与 Containers/ 两套体系的分歧

**P3 — 长期改善（文档与规范）**

13. §9 命名约定文档化：在 `TestConventions.md` 中补充 `_R0xxxx` 回归后缀、正/负编号、混合编号、语义描述等命名模式的适用场景和定义
14. §4 API 覆盖偏差对齐：对齐 Bindings/ 与 Containers/ 的 API 覆盖范围，消除偏差
15. §7 Bindings/ 与 Gameplay/ 去重：6 个数学类型在两套体系下的重复覆盖合并或明确分工
16. §1-2 函数与文件命名优化：评估 `Observe_*_Nominal` 三段式和 `Test_*_*` 两段式的改进方案

### 18.3 修复原则

- **先迁移后子分类**：对于污染目录（§6/§8/§11/§15/§16/§17），先将错位文件迁移到正确目录，再对目标目录进行子分类
- **Theme 标注同步更新**：每次文件迁移后必须更新文件头的 `// Theme:` 标注，保持标注与目录一致
- **命名变更需文档化**：任何命名模式的变更（如 §14 的 _R0xxxx 重命名）必须在 `TestConventions.md` 中同步记录
- **避免引入新问题**：迁移时检查目标目录是否已有同名或同内容的文件，防止新的重复

---

## 19. 测试模式缺失分析 — 正例模式

> 当前 TestSource 中实际使用的正例模式仅有 3 种：WorldStory（Actor 生命周期 + 属性验证）、Observe（函数返回值验证）、DefaultSafe（默认值验证辅助标签）。覆盖面严重不足，以下 8 种模式建议补充。

### 19.1 当前模式盘点

| 模式 | 文件数（估） | 描述 | 状态 |
|---|---:|---|---|
| WorldStory | ~20 | Actor 生命周期中属性状态变化验证 | ✓ 已有 |
| Observe | ~11 | 纯函数调用 + 返回值断言 | ✓ 已有 |
| NegativeDiagnostic | ~25 | 编译失败验证 | ✓ 已有（详见 §20） |
| DefaultSafe / FixtureIsolated / Oracle | 少量 | 辅助标签，非独立模式 | ✓ 辅助 |

### 19.2 建议新增的正例模式

#### P1. RoundTrip（数据往返验证）★ 优先级最高

验证数据通过 UFUNCTION 参数（in/out/return）往返后保持值不变，覆盖序列化/反序列化准确性。

```
// Pattern: RoundTrip. Data passes through UFUNCTION boundary and returns unchanged.
// C++: CompileAndExecute, verify output matches input.
```

当前虽有 5 个 TArray 函数往返测试（FRotator/FTransform RoundTrip + UFunctionStoreAndOut），但仅限容器类型，缺少标量类型和结构体的系统覆盖。需扩展：
- 基础类型往返（int, float, bool, FString, FName, FVector, FRotator, FTransform, FLinearColor）
- UFUNCTION out 参数往返（`&out` 修饰）
- UFUNCTION const&in 参数往返
- 混合参数签名往返（in + out + return 同时存在）
- 容器嵌套往返（TArray<TArray<FVector>>）
- 结构体往返（USTRUCT 含多个属性）

**预估文件数**: 12-15

#### P2. PropertyDefault（属性默认值验证）★ 优先级最高

验证 UPROPERTY 在 CDO（Class Default Object）状态下的默认值是否正确。当前完全缺失。

```
// Pattern: PropertyDefault. CDO property values match C++ constructor defaults.
// C++: Verify default object property values before BeginPlay.
```

需覆盖：
- 标量类型默认值（int=0, float=0.0, bool=false, FString="", FName="None"）
- 容器默认空状态（TArray.Num()==0, TMap.IsEmpty, TSet.IsEmpty, TOptional.IsValid==false）
- UObject 引用默认 null
- 结构体成员默认值（FVector(0,0,0), FRotator(0,0,0), FTransform identity）
- C++ 构造函数赋值的非零默认值

**预估文件数**: 8-10

#### P3. RuntimeExpect（运行时异常验证）

将部分 NegativeDiagnostic 中的运行时错误（OOB、null deref）从编译期诊断转为运行时值验证。

```
// Pattern: RuntimeExpect. Module compiles; execution throws AS exception.
// C++: CompileAndExpectException, verify exception type.
```

与 §20.1 的 RuntimeException 一致，详见负例模式章节。

#### P4. Lifecycle（生命周期验证）

验证 GC 回收、热重载重实例化后容器/UObject 引用的状态一致性。

```
// Pattern: Lifecycle. Object destroyed/reinstanced; container state remains valid.
// C++: Destroy actor, verify array contents, weak ptr invalidation.
```

需覆盖：
- Actor Destroy 后 TArray<AActor*> 中引用变为 null 或被移除
- Hot Reload 重实例化后 UPROPERTY TArray 内容保留/重置行为
- GC 后 TWeakObjectPtr 失效
- Map/Set 在 Owner 销毁后的行为

**预估文件数**: 8-12

#### P5. Replication（网络复制验证）

验证 TArray/TMap UPROPERTY 在网络复制中的行为。当前完全缺失。

```
// Pattern: Replication. Server modifies array; client receives replicated state.
// C++: Network test harness, verify client-side array contents.
```

**预估文件数**: 5-8（需要网络测试基础设施支持）

#### P6. Sequence（多步序列验证）

分阶段验证中间状态不变量，与 WorldStory 的区别在于显式检查每一步后的状态而非仅最终状态。

```
// Pattern: Sequence. Multi-step operation; each step has explicit invariant.
// C++: Verify state after each step, not just final.
```

**预估文件数**: 6-8

#### P7. ReflectionMeta（反射元数据验证）

验证 UArrayProperty / UMapProperty 等的反射契约（元素类型、Key/Value 类型、NetFieldVisibility 等）。

```
// Pattern: ReflectionMeta. UPROPERTY reflection metadata matches declaration.
// C++: Query UArrayProperty->Inner, verify type, flags, metadata.
```

**预估文件数**: 5-8

#### P8. CapacityOracle（容量/性能预言机）

验证 Reserve 后的 Max()、Slack 行为，以及容量与性能的关系。

```
// Pattern: CapacityOracle. Reserve(N) → Max() >= N, Slack == Max - Num.
// C++: Query Max(), GetSlack(), verify capacity invariants.
```

**预估文件数**: 4-6

### 19.3 正例模式优先级

| 模式 | 优先级 | 理由 |
|---|---|---|
| RoundTrip | P0 | UFUNCTION 边界往返是 AS 绑定的核心契约，当前仅 5 个文件覆盖容器子集 |
| PropertyDefault | P0 | CDO 默认值验证是基础契约，完全缺失 |
| Lifecycle | P1 | GC/HotReload 后状态一致性影响运行时稳定性 |
| RuntimeExpect | P1 | 运行时异常验证当前仅 1 个文件（详见 §20） |
| Sequence | P1 | 多步不变量验证增强 WorldStory 的中间状态覆盖 |
| ReflectionMeta | P2 | 反射元数据验证依赖 C++ 侧查询接口 |
| Replication | P2 | 依赖网络测试基础设施 |
| CapacityOracle | P2 | 容量行为当前仅有 Reserve 的基础验证 |

---

## 20. 测试模式缺失分析 — 负例模式

> 当前 NegativeDiagnostic 实际上是 4 种不同模式的混合体，绝大多数为 CompileReject（编译时拒绝），运行时异常验证仅 1 个文件，存在严重覆盖缺口。

### 20.1 当前负例模式盘点

| 模式 | 文件数（估） | 描述 | 状态 |
|---|---:|---|---|
| CompileReject | ~150 | 编译时失败验证 | ✓ 主体（占 90%+） |
| RuntimeException | 1 | 运行时异常验证 | ⚠ 仅 1 个文件，6 个异常挤在一起 |
| 误分类 | ~20+ | CSV 标注为 NegativeDiagnostic 但实际为正例 | ❌ 需修正 |
| UnsupportedApiBoundary | ~8 | API 边界拒绝 | ✓ CompileReject 子类 |

### 20.2 当前 CompileReject 分布

| 目录 | 文件数 | 典型内容 |
|---|---:|---|
| Definitions/UInterface/ | ~12 | 拒绝 `UINTERFACE(BlueprintType)`、`script interface` 关键字 |
| Definitions/UStruct/ | ~32 | `UnsupportedCombinationBoundaries_01-24` + `UnsupportedBoundaryInventory_01-05` + `UnsupportedSpecifiers_01-03` |
| Definitions/UProperty/ | ~6 | `Specifiers_Negative_02,06,09,10,12` |
| Containers/TArray/ | ~10 | VoidType、UnknownElementType、NestedArray、UnsupportedApi |
| Containers/TMap/ | ~9 | `TMap_Negative_01-06` + UnsupportedApi |
| Containers/TSet/ | ~4 | `TSet_Negative_01-03` |
| Containers/TWeakObjectPtr/ | ~5 | `TWeakObjectPtr_Negative_01-05` |
| Containers/TSoftObjectPtr/ | ~5 | `TSoftObjectPtr_Negative_01-05` |
| Containers/TSubclassOf/ | ~5 | `TSubclassOf_Negative_01-05` |
| Language/Syntax/ | ~19 | Keywords/Variable/Ternary 负例系列 |
| Language/Const/ | 3 | `ConstViolationNegativeCompile_01-03` |
| Feature/Mixin/ | ~10+ | `Negative_01-10+` |
| Gameplay/Debug/ | ~19 | `FailToCompile_01-07` x 3 系列 |
| Gameplay/FVector/FRotator/FLinearColor/ | ~6 | 不支持的方法/运算符 |
| World/Actor/ | ~4 | NetworkRole、OldInstigatorAlias 拒绝 |

### 20.3 建议新增的负例模式

#### N1. RuntimeException（运行时异常验证）★ 优先级最高

当前仅 `Test_NegativeRuntimeAndCompileBoundaries.as` 1 个文件，将 6 种异常（OOB、null deref、除零、insert OOB、负 Num、self move-assign）挤在一起。应按异常类型拆分，每个文件聚焦 1-3 个触发器。

```
// Pattern: RuntimeException. Module compiles; C++ catches AS exception.
// Expected: "Array index out of bounds"
```

需覆盖：
- OOB index access（Get/Set 分别）
- OOB Insert（正值/负值）
- Null actor dereference（方法调用、属性访问分别）
- Null component dereference
- Division by zero（int/float 分别）
- Negative SetNum
- Self move-assign
- Empty container Pop/Last 访问
- Invalid TimerHandle 操作
- Invalid WeakObjectPtr Get（失效后访问）
- Invalid SoftObjectPtr load

**预估文件数**: 15-20

#### N2. InvalidHandleState（无效句柄状态迁移）

验证 TimerHandle、WeakObjectPtr、SoftObjectPtr 等在无效状态下调用操作时的行为。编译时无法捕获，运行时层面重要。

```
// Pattern: InvalidHandleState. Handle is invalid; operation must fail/return default.
// C++: IsValid()==false, Get()==null, or exception thrown.
```

与 RuntimeException 的区别：验证句柄生命周期的**状态迁移正确性**，而非单纯异常触发。

**预估文件数**: 8-10

#### N3. TypeMismatchReject（类型系统拒绝）

当前仅有 `AddWrongElementType` 和 `AssignWrongElementType` 两个 TArray 片段。应系统化扩展到所有容器和类型系统。

```
// Pattern: TypeMismatchReject. Compile fails on type-unsafe assignment.
// TArray<int> = TArray<float>, TMap<int,string> = TMap<int,int>, etc.
```

需覆盖：
- 容器间类型不匹配（TArray, TMap, TSet, TOptional）
- TSubclassOf 不匹配（子类 → 无关类）
- UPROPERTY 标量类型不匹配
- 委托签名不匹配
- 接口实现不足

**预估文件数**: 10-12

#### N4. DiagnosticPrecision（诊断信息精确验证）

当前 CompileReject 仅验证"是否编译失败"，**未验证错误信息是否正确**。应模式化验证精确诊断文本。

```
// Pattern: DiagnosticPrecision. Compile fails with EXACT diagnostic text.
// C++: CompileAndExpectFailure with expected message substring.
// Expected: "Expected identifier" / "Instead found '('"
```

部分文件（如 `UInterfaceSpecifierDeclarationRejected.as`）已在注释中写明 expected diagnostic，但 C++ 侧是否实际验证待确认。应将其模式化。

**预估文件数**: 全部 CompileReject 文件可升级（~150），优先对关键诊断路径（容器、UFunction、UProperty）的 ~30-40 个文件先行升级

#### N5. ResourceLeakOnFailure（失败路径资源泄漏）

验证错误路径是否进行了正确清理。异常发生后 TArray/TMap 元素和 UObject 引用不应泄漏。

```
// Pattern: ResourceLeakOnFailure. Exception thrown mid-operation;
// C++ verifies: container state is consistent, no dangling refs.
```

**预估文件数**: 5-8

#### N6. OverflowBoundary（溢出边界）

验证整数溢出和容量极限。当前零覆盖。

```
// Pattern: OverflowBoundary. INT32_MAX + 1 behavior;
// TArray Reserve(huge_value); SetNum(huge_value).
```

**预估文件数**: 3-5

#### N7. ConcurrencyViolation（并发违规）

验证非 GameThread 访问、Tick 中非法重入等。TestSource 中零覆盖。

```
// Pattern: ConcurrencyViolation. Access from non-GameThread;
// C++ verifies: assert/crash or graceful rejection.
```

**预估文件数**: 3-5

### 20.4 负例模式优先级

| 模式 | 优先级 | 理由 |
|---|---|---|
| RuntimeException | P0 | 运行时异常验证仅 1 个文件，覆盖缺口致命 |
| InvalidHandleState | P1 | 句柄生命周期状态迁移完全缺失 |
| TypeMismatchReject | P1 | 类型安全边界仅 2 个文件，系统化不足 |
| DiagnosticPrecision | P1 | 诊断信息精确验证提升 CompileReject 质量 |
| 误分类修正 | P1 | 20+ 文件 CSV 标注错误需立即修正 |
| ResourceLeakOnFailure | P2 | 异常后状态一致性验证 |
| OverflowBoundary | P2 | 整数溢出/容量极限边界 |
| ConcurrencyViolation | P3 | 依赖并发测试基础设施 |

### 20.5 负例模式文件密度估算

| 模式 | 当前文件数 | 目标文件数 | 增量 |
|---|---:|---:|---:|
| CompileReject | ~150 | ~150（升级 DiagnosticPrecision） | 0（质量提升） |
| RuntimeException | 1 | 15-20 | +14~19 |
| InvalidHandleState | 0 | 8-10 | +8~10 |
| TypeMismatchReject | 2 | 10-12 | +8~10 |
| DiagnosticPrecision | 0（注释存在） | 30-40（先行升级） | +30~40（标注升级） |
| ResourceLeakOnFailure | 0 | 5-8 | +5~8 |
| OverflowBoundary | 0 | 3-5 | +3~5 |
| ConcurrencyViolation | 0 | 3-5 | +3~5 |
| **合计新增** | | | **+41~97** |

---

## 21. 容器类型参数化生成测试

> 审查日期: 2026-08-25
> 发现来源: Containers/TArray/ 目录审查中发现同一测试逻辑跨多个元素类型重复手写

### 21.1 问题：同构测试跨类型重复

TArray 是泛型容器，其测试逻辑（空构造、Add、Sort、RoundTrip、Contains、FindIndex 等）**对元素类型正交**。当前每种元素类型各写一个 `.as` 文件，结构几乎完全相同，仅元素类型名和默认值不同。

当前重复实例：

| 测试模式 | int | FString | FVector | FRotator | FTransform | FLinearColor |
|---|---|---|---|---|---|---|
| EmptyConstruction | ✓ (`Test_TArrayEmptyConstruction`) | — | — | — | — | — |
| Add | ✓ (`Test_TArrayAddAndOrder`) | ✓ (`Test_TArrayFStringAdd`) | ✓ (`Test_TArrayFVectorAdd`) | — | — | — |
| RoundTrip | — | — | — | ✓ (`Test_TArrayFRotatorFunctionRoundTrip`) | ✓ (`Test_TArrayFTransformFunctionRoundTrip`) | ✓ (`Test_FunctionArrayAndConversionRoundTrip`) |
| UFunctionStoreAndOut | — | — | — | ✓ (`Test_TArrayFRotatorUFunctionStoreAndOut`) | ✓ (`Test_TArrayFTransformUFunctionStoreAndOut`) | — |
| EmptyDefault 辅助 | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| EdgeCasesEmpty | ✓ (`Test_TArrayEdgeCasesEmpty`) | — | — | — | — | — |

核心矛盾：每新增一种元素类型，都需要**手工复制整套测试文件并逐一改写类型名和默认值**，遗漏率高、维护成本大，且类型覆盖矩阵出现大量空洞（上表中 `—` 即为缺口）。

### 21.2 建议方案：模板生成 + `.Generate` 后缀 + 标签管理

#### 21.2.1 两层生成体系

**Layer 1 — 预生成基线（Ship with repo）**

为高频元素类型预生成 `.as` 测试文件，直接提交到 TestSource 仓库。这些文件是稳定的、可审查的，与手写文件无运行时差异。

预生成基线类型集（建议）：

| 类别 | 类型 | 说明 |
|---|---|---|
| 标量 | `int`, `float`, `double`, `bool`, `uint8` | 基础数值/布尔 |
| 字符串 | `FString`, `FName`, `FText` | 三种 UE 字符串 |
| 数学结构 | `FVector`, `FVector2D`, `FRotator`, `FTransform`, `FLinearColor`, `FQuat`, `FIntPoint`, `FIntVector` | UE 数学类型 |
| UObject 引用 | `AActor`, `UObject` | 对象引用容器 |
| 嵌套 | `TArray<int>`, `TArray<FVector>` | 容器嵌套容器 |

**Layer 2 — UE 侧动态生成（Commandlet / Build-time）**

通过 UE Commandlet 或 Build-time 工具，在引擎环境中扫描实际 Bind 表，发现已绑定的类型并自动扩展测试覆盖。动态生成的文件不提交仓库，由生成器在 CI 或本地构建时产出。

适用场景：
- 新增 Bind 类型后自动生成对应容器测试
- 针对项目特定的自定义 USTRUCT 类型生成测试
- 覆盖矩阵的完整性校验（哪些类型缺少哪些模式的测试）

#### 21.2.2 `.Generate` 后缀命名约定

生成文件使用 `.Generate.as` 双后缀，与手写文件明确区分：

```
手写文件:  Test_TArrayEmptyConstruction.as
生成文件:  Test_TArrayEmptyConstruction_int.Generate.as
生成文件:  Test_TArrayEmptyConstruction_FVector.Generate.as
生成文件:  Test_TArrayRoundTrip_FTransform.Generate.as
```

命名规则：
```
Test_<TestSkeleton>_<ElementType>.Generate.as
```

- `<TestSkeleton>` — 测试骨架名（如 `EmptyConstruction`、`RoundTrip`、`AddAndOrder`），对应一个模板
- `<ElementType>` — 实例化的元素类型名（如 `int`、`FVector`、`FString`）
- `.Generate` — 固定标记后缀，表示此文件由生成器产出

#### 21.2.3 标签管理

生成文件头部使用结构化标签控制生成行为和记录元数据：

```
// @Generate: true
// @Generator: TArrayTestGenerator v1
// @Template: RoundTrip
// @ElementType: FTransform
// @TypeDefaults: FTransform::Identity
// @GeneratedAt: 2026-08-25T12:00:00Z
// @HandEditable: false  — 重新生成将覆盖此文件
```

| 标签 | 用途 |
|---|---|
| `@Generate: true` | 标记此文件为生成文件，CI 可据此统计/校验 |
| `@Generator` | 生成器名称和版本，用于追溯 |
| `@Template` | 使用的模板骨架名 |
| `@ElementType` | 实例化的元素类型 |
| `@TypeDefaults` | 该类型的默认值/零值，用于断言 |
| `@GeneratedAt` | 生成时间戳 |
| `@HandEditable` | `false` 表示纯生成不可手改；`true` 表示生成后允许手工补充 |

### 21.3 模板骨架设计

每个测试模式提取为一个模板骨架（Skeleton），定义类型参数化点：

#### 骨架示例: `EmptyConstruction`

```
// @Template: EmptyConstruction
// @Param: T — 元素类型
// @Param: Default — T 的默认值/零值

namespace TS_TArray_EmptyConstruction_${T}
{
    bool Observe_EmptyDefault()
    {
        TArray<${T}> Array;
        return Array.Num() == 0 && Array.IsEmpty();
    }

    bool Observe_EmptyContainsFalse()
    {
        TArray<${T}> Array;
        return !Array.Contains(${Default});
    }

    bool Observe_EmptyFindIndexMinusOne()
    {
        TArray<${T}> Array;
        return Array.FindIndex(${Default}) == -1;
    }

    bool Observe_EmptySortNoCrash()
    {
        TArray<${T}> Array;
        Array.Sort();
        return Array.Num() == 0;
    }

    bool Observe_EmptyCopyIsAlsoEmpty()
    {
        TArray<${T}> Array;
        TArray<${T}> Copy = Array;
        return Copy.Num() == 0 && Copy.IsEmpty();
    }

    bool Observe_EmptyAppendIsNoOp()
    {
        TArray<${T}> Array;
        TArray<${T}> Empty;
        Array.Append(Empty);
        return Array.Num() == 0;
    }
}
```

参数化点 `${T}` 和 `${Default}` 在生成时替换为具体类型和值。

#### 可参数化的模板骨架清单

| 骨架名 | 类型参数化点 | 值参数化点 | 当前已有手写实例数 |
|---|---|---|---|
| `EmptyConstruction` | T | Default | 7 (int, float, bool, FString, FVector, UObject, AActor) |
| `AddAndOrder` | T | SampleValue1, SampleValue2 | 3 (int, FString, FVector) |
| `RoundTrip` | T | RoundTripValue | 3 (FRotator, FTransform, FLinearColor) |
| `UFunctionStoreAndOut` | T | StoreValue | 2 (FRotator, FTransform) |
| `SortAndReverse` | T | SortValues[] | 1 (int) |
| `Contains` | T | PresentValue, AbsentValue | 1 (int) |
| `AppendAndMerge` | T | SetA[], SetB[] | 1 (int) |
| `SwapElements` | T | SwapA, SwapB | 1 (int) |
| `Reserve` | T | ReserveCount, FillValue | 1 (int) |
| `SetNumAndCapacity` | T | SetNum, FillValue | 1 (int) |

当前 10 个骨架覆盖 21 个手写实例（EmptyConstruction 已扩展至 7 类型），理论上 10 骨架 × 15 基线类型 = **150 个生成文件**可一次性填补矩阵空洞。

### 21.4 与手写文件的关系

| 场景 | 处理方式 |
|---|---|
| 模板可覆盖的标准模式 | 生成 `.Generate.as`，手写文件逐步退役 |
| 类型特殊行为（如 FString 的空字符串 vs 空数组区分） | 保留手写文件，生成文件仅覆盖通用部分 |
| 嵌套容器（TArray<TArray<T>>） | 生成器递归实例化，限制深度为 2 |
| UObject 引用容器（TArray<AActor>） | 生成器需注入 Actor 生命周期 fixture |
| 自定义 USTRUCT | Layer 2 动态生成，不进入基线 |

### 21.5 优先级

| 优先级 | 工作项 | 说明 |
|---|---|---|
| P0 | 设计模板骨架格式和生成器接口 | 确定骨架 DSL 和参数化点语法 |
| P0 | 实现 `EmptyConstruction` + `RoundTrip` 两个骨架 | 验证生成器可行性，覆盖最高价值模式 |
| P1 | 扩展到全部 10 个骨架 | 完成基线类型集的预生成 |
| P1 | `.Generate` 后缀纳入命名规范文档 | 更新 TestConventions.md |
| P2 | 实现 Layer 2 UE Commandlet 动态生成 | 引擎侧扫描 Bind 表自动扩展 |
| P2 | 生成文件 CI 校验 | 确保生成文件与模板一致，未被手改 |
| P3 | 退役被生成覆盖的手写文件 | 减少重复，统一为生成来源 |

### 21.6 与其他 Review 条目的关联

- **§19.2 P1 RoundTrip**: RoundTrip 骨架可直接参数化，是生成器的首要目标
- **§20.3 N3 TypeMismatchReject**: 类型不匹配负例同样可参数化生成（`TArray<int> = TArray<float>` 等）
- **§1 命名规范**: `.Generate.as` 后缀需纳入 `Test_<ScenarioCategory>_<Part>.as` 命名体系的扩展规则
- **§4-5 Bindings/Containers 覆盖偏差**: 生成器可自动检测哪些 Bind 类型缺少容器测试，消除覆盖空洞
