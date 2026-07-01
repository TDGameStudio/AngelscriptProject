# 容器覆盖矩阵（TArray / TMap / TSet）

> **本矩阵是容器测试的设计规格("头")**：每行是一个**具体可验证场景**，指导 6 个容器测试文件的实现。⬜ 行＝待实现，✅ 行注明覆盖它的 `TEST_METHOD`，🚫 行＝fork 拒绝（已用负向编译断言守住边界）。
>
> - 测试文件：`TArrayAdvanced`(23) / `TMapAdvanced`(11) / `TSetAdvanced`(8) / `ContainerAdvanced`(7) / `ContainerNested`(7) / `ContainerParameter`(4) Tests.cpp
> - Automation 前缀：`Angelscript.TestModule.Coverage.<上述主题>`
> - 图例见 `../coverage-matrix.md`；fork 边界详见 `../coverage-gaps.md §2.1/§2.2`。

## 1. TArray — 操作（AngelscriptCoverageTArrayAdvancedTests.cpp）

| 场景 | 状态 | 覆盖测试方法 | 要点 / 待实现 |
|------|------|------------|-------------|
| 排序与反转（Sort/反向遍历） | ✅ | `TArraySortAndReverse` | 升序排序、反向遍历 |
| 插入与按索引删除 | ✅ | `TArrayInsertAndRemoveAt` | Insert / RemoveAt |
| 查找（FindIndex/Contains） | ✅ | `TArrayFind` / `TArrayAdvancedSearch` | 受支持的查找路径 |
| 预留容量 Reserve | ✅ | `TArrayReserve` / `TArraySetNumAndCapacity` | Reserve / SetNum / Max |
| for-each 迭代 | ✅ | `TArrayForEachIteration` | 范围遍历 |
| 索引有效性查询 IsValidIndex | ✅ | `TArrayEdgeCasesEmpty` 内 | 仅查询有效性 |
| 越界 `[]` 访问的运行期语义 | ✅ | `TArrayOutOfBoundsIndexAccess` | 读/写越界 `[]` 均抛出稳定脚本异常 `Array index out of bounds.` |
| 追加与合并 | ✅ | `TArrayAppendAndMerge` | Append |
| AddUnique 与 RemoveAll(值) | ✅ | `TArrayAddUniqueAndRemoveAll` | 去重添加/按值移除 |
| 交换元素 | ✅ | `TArraySwapElements` | Swap |
| 批量操作 | ✅ | `TArrayBulkOperations` | 批量增删 |
| 重复元素处理 | ✅ | `TArrayDuplicateHandling` | 重复值语义 |
| 空数组边界 | ✅ | `TArrayEdgeCasesEmpty` | 空容器操作 |
| 元素类型：FString / FVector / FName / UObject 引用 | ✅ | `TArrayFString` `TArrayFVector` `TArrayWithFName` `TArrayUObjectReferences` | 各元素类型 |
| 属性说明符与 meta | ✅ | `TArrayPropertySpecifiersAndMeta` | EditAnywhere 等标志 |
| 未绑定 API 别名（Find/FindLast/Reverse/RemoveAll(Pred)） | 🚫 | `TArrayUnsupportedApiAliases` | 期望编译失败 |
| 未绑定算法（StableSort/Heap/FilterByPredicate 等） | 🚫 | `TArrayUnsupportedAlgorithms` | 期望编译失败 |
| 嵌套 `TArray<TArray<>>`（含深层/局部） | 🚫 | `TArrayNestedContainers` | 诊断 `Containers cannot be nested` |
| 嵌套 `TArray<TMap<>>` / `TArray<TSet<>>` | 🚫 | `TArrayNestedMapAndSetContainers` | 同上 |

## 2. TMap — 操作（AngelscriptCoverageTMapAdvancedTests.cpp）

| 场景 | 状态 | 覆盖测试方法 | 要点 / 待实现 |
|------|------|------------|-------------|
| 增删查综合 | ✅ | `TMapAdvancedOperations` / `TMapOverwriteRemoveContainsKeysValues` | Add/Remove/Contains/Keys/Values |
| 迭代 | ✅ | `TMapIteration` | 显式迭代器 |
| 键类型矩阵 | ✅ | `TMapKeyTypes` | int/FString/FName 等作键 |
| 值类型矩阵（FString/FVector/int） | ✅ | `TMapValueTypes` | 标量与数学 struct 作值 |
| 值为用户 USTRUCT 的存取往返 | ✅ | `TMapUserStructValues` | `TMap<int, 用户USTRUCT>` Add/Find/index/overwrite 往返 |
| FindOrAdd | ✅ | `TMapFindOrAdd` | FindOrAdd 语义 |
| 移除操作 | ✅ | `TMapRemoveOperations` | Remove 变体 |
| 空 Map 边界 | ✅ | `TMapEdgeCases` | 空容器 |
| 未绑定 API 别名（指针式 Find/Generate*Array/FindRef 等） | 🚫 | `TMapUnsupportedApiAliases` | 期望编译失败 |
| 嵌套 `TMap<K,TArray<>>` | 🚫 | `TMapWithArrayValues` | 诊断 `Containers cannot be nested` |

## 3. TSet — 操作（AngelscriptCoverageTSetAdvancedTests.cpp）

| 场景 | 状态 | 覆盖测试方法 | 要点 / 待实现 |
|------|------|------------|-------------|
| 增删查综合 | ✅ | `TSetAdvancedOperations` | Add/Remove/Contains |
| 迭代 | ✅ | `TSetIteration` | 遍历 |
| 受支持的集合运算 | ✅ | `TSetSetOperations` | Append(并集) 等受支持路径 |
| 元素类型矩阵 | ✅ | `TSetElementTypes` | 各元素类型 |
| 作参数传递 | ✅ | `TSetAsParameter` | 入参语义 |
| 与数组互转 | ✅ | `TSetArrayConversion` | Set↔Array |
| 去重 / 重置 | ✅ | `TSetDuplicateDedupeRemoveReset` `TSetResetAndCapacity` | 去重、Reset、容量 |

## 4. 跨容器：参数 / 返回值 / 非 UPROPERTY（ContainerAdvanced + ContainerParameter）

| 场景 | 状态 | 覆盖测试方法 | 要点 / 待实现 |
|------|------|------------|-------------|
| 容器作参数（值/in/out/inout） | ✅ | `ContainerAsParameter` / `TMapAsParameter` / `TSetAsParameter` | 各容器入参 |
| 容器作返回值 | ✅ | `ContainerAsReturnValue` / `TSetAsReturnValue` | 返回容器 |
| 容器引用返回 | ✅ | `ContainerReferenceReturn` | 引用返回语义 |
| 混合容器参数 | ✅ | `MixedContainerParameters` | 多容器混合签名 |
| 迭代器高级操作 | ✅ | `ContainerIteratorAdvancedOperations` | 迭代器组合 |
| 非 UPROPERTY 容器（局部/脚本内部） | ✅ | `NonUPropertyContainers` | 非反射容器 |
| struct 含数组、再作数组元素（允许形态） | ✅ | `ArrayOfStructsContainingArrays` | 通过 struct 包装规避嵌套限制 |
| 嵌套组合（统一不支持声明） | 🚫 | `NestedContainerCombinationsUnsupported` | 期望编译失败 |

## 5. 嵌套容器边界（AngelscriptCoverageContainerNestedTests.cpp — 全部 🚫）

> 当前 fork 在编译期拒绝"容器嵌套容器"。本组以负向编译断言守住边界，**避免后续重复尝试**。

| 场景 | 状态 | 覆盖测试方法 |
|------|------|------------|
| `TArray<TArray<int>>`（二维） | 🚫 | `NestedArrays_TwoDimensionalMatrix` |
| `TArray<TArray<TArray<int>>>`（深层） | 🚫 | `NestedArrays_DeepMatrix` |
| 局部深层嵌套数组 | 🚫 | `NestedArrays_LocalDeepMatrix` |
| `TArray<TMap<int,FString>>` | 🚫 | `ArrayOfMaps` |
| `TMap<int,TArray<int>>` | 🚫 | `MapOfArrays_OneToMany` |
| `TArray<TSet<int>>` | 🚫 | `ArrayOfSets` |
| `TMap<int,TMap<FString,float>>` | 🚫 | `MapOfMaps_TwoDimensionalMapping` |

---

## 汇总

| 维度 | 场景 | 已覆盖(✅) | 待实现(⬜) | 边界(🚫) |
|------|------|----------|----------|---------|
| 1 TArray 操作 | 19 | 15 | 0 | 4 |
| 2 TMap 操作 | 10 | 8 | 0 | 2 |
| 3 TSet 操作 | 7 | 7 | 0 | 0 |
| 4 跨容器参数/返回 | 8 | 7 | 0 | 1 |
| 5 嵌套边界 | 7 | 0 | 0 | 7 |

**对应测试方法**：23+11+8+7+7+4 = 60 方法（现有）。
**待实现（⬜，2026-06-30 深审新增）**：无。

**已补充关闭（2026-07-01）**：
- **G5** — TArray 越界 `[]` 访问运行期语义：`TArrayOutOfBoundsIndexAccess` 覆盖读/写越界异常。
- **G6** — `TMap<K, 用户USTRUCT>` 作值的存取往返：`TMapUserStructValues` 覆盖。

其余受支持面已覆盖，未绑定 UE API 与容器嵌套作为 🚫 边界固化。若 fork 后续绑定某 API（见 `../coverage-gaps.md §2.1`），将对应 🚫 行迁移为 ⬜ 并补正向测试。
