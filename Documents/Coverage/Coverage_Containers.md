# AngelScript 容器类型全覆盖矩阵

> 本文覆盖 AngelScript 中 **UE 容器类型**的完整用法。
> 包括 TArray、TMap、TSet 的所有操作、性能特征、嵌套使用等。

## 对应测试文件

| 用法分组 | 测试文件 | 状态 |
|---------|---------|------|
| TArray 完整覆盖 | `AngelscriptTest/Coverage/AngelscriptCoverageTArrayAdvancedTests.cpp` | ✅ 已完成 |
| TMap 完整覆盖 | `AngelscriptTest/Coverage/AngelscriptCoverageTMapAdvancedTests.cpp` | ✅ 已完成 |
| TSet 完整覆盖 | `AngelscriptTest/Coverage/AngelscriptCoverageTSetAdvancedTests.cpp` | ✅ 已完成 |
| 嵌套容器覆盖 | `AngelscriptTest/Coverage/AngelscriptCoverageContainerNestedTests.cpp` | ✅ 已完成 |
| 容器高级用法 | `AngelscriptTest/Coverage/AngelscriptCoverageContainerAdvancedTests.cpp` | ⬜ 计划 |

✅ 所有三种容器的高级操作已覆盖
✅ 嵌套容器（2D 数组、Map of Array、Array of Map、Array of Set、Map of Map）已覆盖

## 图例

- `✅ 已覆盖` ｜ `🟡 部分覆盖` ｜ `⬜ 待写` ｜ `🚫 不适用/不支持`

---

## 子矩阵 1：TArray（动态数组）

### 1.1 TArray 声明和构造

| 声明方式 | 写法示例 | 状态 | 说明 |
|---------|---------|------|------|
| 默认构造 | `TArray<int> Arr;` | ✅ | 空数组 |
| 初始化列表 | `TArray<int> Arr = {1, 2, 3};` | ✅ | |
| 预分配容量 | `TArray<int> Arr; Arr.Reserve(100);` | ✅ | |
| 拷贝构造 | `TArray<int> Arr2 = Arr1;` | ✅ | 深拷贝 |

### 1.2 TArray 元素类型覆盖

| 元素类型 | 状态 | 说明 |
|---------|------|------|
| 基础类型（int/float/bool） | ✅ | 已在 int 测试中覆盖 |
| 字符串（FString/FName/FText） | ✅ | |
| 枚举 | ✅ | |
| 结构体（FVector/FTransform） | ✅ | |
| UObject 引用 | ✅ | `TArray<AActor>` |
| TSubclassOf | ✅ | `TArray<TSubclassOf<AActor>>` |
| 接口引用 | ⬜ | `TArray<TScriptInterface<I>>` |

### 1.3 TArray 基础操作

| 操作 | 方法 | 状态 | 说明 |
|------|------|------|------|
| 添加元素 | `Add(Value)` | ✅ | 尾部添加 |
| 插入元素 | `Insert(Value, Index)` | ✅ | 指定位置插入 |
| 添加多个 | `Append(OtherArray)` / `AddUnique(Value)` | ✅ | |
| 移除元素 | `Remove(Value)` | ✅ | 移除第一个匹配 |
| 按索引移除 | `RemoveAt(Index)` / `RemoveAtSwap(Index)` | ✅ | |
| 移除多个 | `RemoveAll(Predicate)` / `RemoveSwap(Value)` | ✅ | |
| 清空 | `Empty()` / `Reset()` | ✅ | |
| 查找 | `Find(Value)` / `FindLast(Value)` | ✅ | 返回索引 |
| 包含 | `Contains(Value)` | ✅ | 返回 bool |
| 索引访问 | `Arr[Index]` | ✅ | |
| 安全访问 | `IsValidIndex(Index)` | ✅ | |
| 获取大小 | `Num()` / `IsEmpty()` | ✅ | |

### 1.4 TArray 遍历

| 遍历方式 | 写法 | 状态 | 说明 |
|---------|------|------|------|
| for 索引 | `for (int i = 0; i < Arr.Num(); i++)` | ✅ | |
| for-each 值 | `for (int Val : Arr)` | ✅ | 拷贝 |
| for-each 引用 | `for (int& Val : Arr)` | ✅ | 可修改 |
| for-each const | `for (const int& Val : Arr)` | ✅ | 只读 |

### 1.5 TArray 高级操作

| 操作分组 | 方法 | 状态 | 说明 |
|---------|------|------|------|
| 排序 | `Sort()` / `Sort(Predicate)` | ✅ | 升序/自定义 |
| 稳定排序 | `StableSort()` | ✅ | |
| 反转 | `Reverse()` | ✅ | |
| 过滤 | `FilterByPredicate(Predicate)` | ✅ | |
| 查找 | `FindByKey(Key)` / `FindByPredicate(Predicate)` | ✅ | |
| 容量管理 | `Reserve(Num)` / `Shrink()` / `SetNum(Num)` | ✅ | |
| 获取切片 | `Slice(Start, Count)` | ✅ | |
| 交换元素 | `Swap(Index1, Index2)` | ✅ | |
| 堆操作 | `Heapify()` / `HeapPop()` / `HeapPush()` | ✅ | 优先队列 |

### 1.6 TArray 作为 UPROPERTY

| 说明符 | 写法 | 状态 | 验证点 |
|-------|------|------|--------|
| EditAnywhere | `UPROPERTY(EditAnywhere) TArray<int> Values;` | ✅ | 编辑器可编辑 |
| BlueprintReadWrite | `UPROPERTY(BlueprintReadWrite) TArray<int> Values;` | ⬜ | BP 访问 |
| meta=(ClampMin) | 元素限制 | ⬜ | |

---

## 子矩阵 2：TMap（键值映射）

### 2.1 TMap 声明和构造

| 声明方式 | 写法示例 | 状态 | 说明 |
|---------|---------|------|------|
| 默认构造 | `TMap<int, FString> Map;` | ✅ | 空映射 |
| 初始化列表 | `TMap<int, FString> Map = {{1, "A"}, {2, "B"}};` | ✅ | |

### 2.2 TMap 键类型覆盖

| 键类型 | 状态 | 说明 |
|-------|------|------|
| 整型（int/int64/uint） | ✅ | 已覆盖 |
| 字符串（FString/FName） | ✅ | FName 更高效 |
| 枚举 | ✅ | |
| 结构体 | ✅ | 需实现 GetTypeHash 和 == |
| UObject 引用 | ✅ | 指针哈希 |
| FVector/FRotator | 🚫 | 浮点不稳定 |

### 2.3 TMap 值类型覆盖

| 值类型 | 状态 | 说明 |
|-------|------|------|
| 基础类型 | ✅ | int/float/bool |
| 字符串 | ✅ | FString/FName |
| 结构体 | ✅ | FVector/FTransform |
| UObject 引用 | ✅ | |
| 容器 | ✅ | `TMap<int, TArray<int>>` |

### 2.4 TMap 基础操作

| 操作 | 方法 | 状态 | 说明 |
|------|------|------|------|
| 添加/更新 | `Add(Key, Value)` / `Emplace(Key, Value)` | ✅ | |
| 查找 | `Find(Key)` | ✅ | 返回指针（可为 null） |
| 包含 | `Contains(Key)` | ✅ | 返回 bool |
| 索引访问 | `Map[Key]` | ✅ | 不存在则添加 |
| 移除 | `Remove(Key)` | ✅ | |
| 清空 | `Empty()` / `Reset()` | ✅ | |
| 获取大小 | `Num()` / `IsEmpty()` | ✅ | |
| 获取所有键 | `GetKeys(OutArray)` / `GenerateKeyArray(OutArray)` | ✅ | |
| 获取所有值 | `GenerateValueArray(OutArray)` | ✅ | |

### 2.5 TMap 遍历

| 遍历方式 | 写法 | 状态 | 说明 |
|---------|------|------|------|
| for-each 键值对 | `for (auto& Pair : Map)` | ✅ | Pair.Key / Pair.Value |
| for-each const | `for (const auto& Pair : Map)` | ✅ | 只读 |

### 2.6 TMap 高级操作

| 操作 | 方法 | 状态 | 说明 |
|------|------|------|------|
| 查找或添加 | `FindOrAdd(Key)` | ✅ | 返回引用 |
| 查找引用 | `FindRef(Key)` | ✅ | 不存在返回默认值 |
| 查找已检查 | `FindChecked(Key)` | ✅ | 不存在则断言 |
| 容量管理 | `Reserve(Num)` / `Shrink()` | ✅ | |
| 追加 | `Append(OtherMap)` | ✅ | |
| 过滤 | `FilterByPredicate(Predicate)` | ✅ | |

---

## 子矩阵 3：TSet（集合）

### 3.1 TSet 声明和构造

| 声明方式 | 写法示例 | 状态 | 说明 |
|---------|---------|------|------|
| 默认构造 | `TSet<int> Set;` | ✅ | 空集合 |
| 初始化列表 | `TSet<int> Set = {1, 2, 3};` | ✅ | |

### 3.2 TSet 元素类型覆盖

| 元素类型 | 状态 | 说明 |
|---------|------|------|
| 整型 | ✅ | 已覆盖 |
| 字符串（FString/FName） | ✅ | |
| 枚举 | ✅ | |
| 结构体 | ✅ | 需实现 GetTypeHash 和 == |
| UObject 引用 | ✅ | |
| 浮点 | 🚫 | 不稳定 |

### 3.3 TSet 基础操作

| 操作 | 方法 | 状态 | 说明 |
|------|------|------|------|
| 添加 | `Add(Value)` / `Emplace(Value)` | ✅ | 返回是否新增 |
| 移除 | `Remove(Value)` | ✅ | |
| 包含 | `Contains(Value)` | ✅ | |
| 清空 | `Empty()` / `Reset()` | ✅ | |
| 获取大小 | `Num()` / `IsEmpty()` | ✅ | |
| 查找 | `Find(Value)` | ✅ | 返回指针 |
| 转数组 | `Array()` | ✅ | 返回 TArray |

### 3.4 TSet 遍历

| 遍历方式 | 写法 | 状态 | 说明 |
|---------|------|------|------|
| for-each | `for (int Val : Set)` | ✅ | |
| for-each const | `for (const int& Val : Set)` | ✅ | |

### 3.5 TSet 集合操作

| 操作 | 方法 | 状态 | 说明 |
|------|------|------|------|
| 并集 | `Union(OtherSet)` / `Append(OtherSet)` | ✅ | A ∪ B |
| 交集 | `Intersect(OtherSet)` | ✅ | A ∩ B |
| 差集 | `Difference(OtherSet)` | ✅ | A - B |
| 包含检查 | `Includes(OtherSet)` | ✅ | A ⊇ B |
| 过滤 | `FilterByPredicate(Predicate)` | ✅ | |

---

## 子矩阵 4：容器嵌套和组合

### 4.1 二维容器

| 组合 | 写法 | 状态 | 说明 |
|------|------|------|------|
| 数组的数组 | `TArray<TArray<int>>` | ✅ | 矩阵 |
| Map 的数组 | `TArray<TMap<int, FString>>` | ✅ | |
| 数组的 Map | `TMap<int, TArray<int>>` | ✅ | 一对多 |
| Set 的数组 | `TArray<TSet<int>>` | ✅ | |

### 4.2 复杂嵌套

| 组合 | 写法 | 状态 | 说明 |
|------|------|------|------|
| Map<Key, Map> | `TMap<int, TMap<FString, float>>` | ✅ | 二维映射 |
| Array<Struct<Array>> | struct 内含数组，再放数组 | ⬜ | 待后续扩展 |

---

## 子矩阵 5：容器性能和选择

### 5.1 操作复杂度

| 容器 | 添加 | 查找 | 删除 | 遍历 | 内存 |
|------|------|------|------|------|------|
| TArray | O(1)* | O(n) | O(n) | O(n) | 连续 |
| TMap | O(1)* | O(1)* | O(1)* | O(n) | 哈希表 |
| TSet | O(1)* | O(1)* | O(1)* | O(n) | 哈希表 |

*平均情况，最坏情况可能为 O(n)

### 5.2 容器选择指南

| 需求 | 推荐容器 | 原因 |
|------|---------|------|
| 有序存储 | TArray | 索引访问 O(1) |
| 快速查找 | TMap/TSet | 哈希查找 O(1) |
| 唯一性保证 | TSet | 自动去重 |
| 键值关联 | TMap | |
| 频繁插入/删除 | TMap/TSet | 避免数组移动 |
| 内存紧凑 | TArray | 连续存储 |

---

## 子矩阵 6：容器与算法

### 6.1 排序和查找

| 算法 | 适用容器 | 状态 | 说明 |
|------|---------|------|------|
| 排序 | TArray | ⬜ | Sort() / StableSort() |
| 二分查找 | TArray（已排序） | ⬜ | LowerBound() / UpperBound() |
| 线性查找 | TArray | ⬜ | Find() / FindByPredicate() |
| 哈希查找 | TMap/TSet | ⬜ | Contains() / Find() |

### 6.2 变换和过滤

| 算法 | 状态 | 说明 |
|------|------|------|
| 过滤 | ⬜ | FilterByPredicate() |
| 映射 | ⬜ | 手动 for-each + Add |
| 归约 | ⬜ | 手动 for-each |

---

## 子矩阵 7：容器在不同场景的用法

### 7.1 作为类成员

| 场景 | 写法 | 状态 |
|------|------|------|
| UPROPERTY 数组 | `UPROPERTY() TArray<int> Values;` | ✅ |
| UPROPERTY Map | `UPROPERTY() TMap<int, FString> Data;` | ✅ |
| UPROPERTY Set | `UPROPERTY() TSet<int> Flags;` | ✅ |
| 非 UPROPERTY | `TArray<int> TempData;` | ⬜ |

### 7.2 作为函数参数

| 参数形式 | 写法 | 状态 | 说明 |
|---------|------|------|------|
| 值传递 | `void F(TArray<int> Arr)` | ⬜ | 拷贝 |
| const 引用 | `void F(const TArray<int>&in Arr)` | ⬜ | 只读 |
| 引用 | `void F(TArray<int>&inout Arr)` | ⬜ | 可修改 |
| 输出 | `void F(TArray<int>&out Arr)` | ⬜ | 输出参数 |

### 7.3 作为返回值

| 返回方式 | 写法 | 状态 | 说明 |
|---------|------|------|------|
| 值返回 | `TArray<int> F()` | ⬜ | |
| 引用返回 | `TArray<int>& F()` | ⬜ | 返回成员 |

---

## 计划测试方法清单

### AngelscriptCoverageTArrayTests.cpp（扩展）

| 方法 | 覆盖内容 |
|------|---------|
| `TArrayConstruction` | 默认构造、初始化列表、拷贝 |
| `TArrayBasicOperations` | Add/Insert/Remove/RemoveAt/Find/Contains |
| `TArrayIteration` | for 索引、for-each 值/引用 |
| `TArrayAdvancedOperations` | Sort/Reverse/Filter/Reserve/Shrink |
| `TArrayElementTypes` | 各种元素类型（string/struct/UObject） |
| `TArrayAsParameter` | 值/引用/输出参数 |
| `TArrayAsReturn` | 返回数组 |
| `TArrayHeap` | Heapify/HeapPop/HeapPush |

### AngelscriptCoverageTMapTests.cpp（扩展）

| 方法 | 覆盖内容 |
|------|---------|
| `TMapConstruction` | 默认构造、初始化列表 |
| `TMapBasicOperations` | Add/Find/Contains/Remove/GetKeys/GetValues |
| `TMapIteration` | for-each 键值对 |
| `TMapAdvancedOperations` | FindOrAdd/FindRef/Append/Filter |
| `TMapKeyTypes` | 各种键类型 |
| `TMapValueTypes` | 各种值类型 |
| `TMapAsParameter` | 参数和返回值 |

### AngelscriptCoverageTSetTests.cpp（扩展）

| 方法 | 覆盖内容 |
|------|---------|
| `TSetConstruction` | 默认构造、初始化列表 |
| `TSetBasicOperations` | Add/Remove/Contains/Find |
| `TSetIteration` | for-each |
| `TSetSetOperations` | Union/Intersect/Difference/Includes |
| `TSetElementTypes` | 各种元素类型 |
| `TSetAsParameter` | 参数和返回值 |

### AngelscriptCoverageContainerAdvancedTests.cpp

| 方法 | 覆盖内容 |
|------|---------|
| `NestedContainers` | 二维数组、Map of Array 等 |
| `ContainerPerformance` | 性能特征验证（可选） |
| `ContainerAlgorithms` | 排序、查找、过滤 |
| `ContainerCombinations` | 复杂组合场景 |

---

## 待补充清单（按优先级）

### 🔴 高优先级

1. **TArray 高级操作**（Sort/Filter/Reserve）
2. **TMap 完整操作**（FindOrAdd/GetKeys/Iteration）
3. **TSet 集合运算**（Union/Intersect/Difference）

### 🟡 中优先级

4. **容器元素类型扩展**（struct/UObject/string）
5. **容器作为参数和返回值**
6. **初始化列表**

### 🟢 低优先级

7. **嵌套容器**（二维数组等）
8. **容器性能测试**
9. **Heap 操作**

---

## 已覆盖内容（来自 int 测试）

以下容器功能已在 `AngelscriptCoverageIntPropertyTests.cpp` 中覆盖：

✅ TArray<int> 基础：Add / 索引访问 / Num
✅ TArray<int64/uint8> 其他宽度
✅ TMap<int, int> 和 TMap<int, FString> 基础
✅ TMap<FString, int> 字符串键
✅ TSet<int> 基础：Add / Contains / Num
✅ TSet<int8/int64/uint> 其他宽度

**建议**：新的容器测试应专注于：
- 高级操作（Sort/Filter/Union）
- 不同元素类型
- 嵌套容器
- 算法和性能

---

## 总结

容器是 **数据结构的基础**，几乎所有复杂逻辑都需要：
- 存储多个对象 → TArray
- 快速查找 → TMap/TSet
- 关联数据 → TMap
- 去重 → TSet

**估计工作量**：4 个测试文件（扩展现有 + 新增高级），约 25-30 个测试方法
**优先级**：🔴🔴 高（已有基础，需要扩展完整）
