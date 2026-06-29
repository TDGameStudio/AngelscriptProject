# 容器覆盖矩阵（TArray / TMap / TSet）

> 域：UE 容器类型的声明、增删查、迭代、参数/返回值、嵌套边界。
> 归属：OpenSpec `test-coverage-matrix-consolidation`。图例与列说明见 `../coverage-matrix.md`。

| 主题 | 测试文件 | 方法数 | 状态 | 覆盖要点 |
|------|---------|-------|------|---------|
| TArrayAdvanced | AngelscriptCoverageTArrayAdvancedTests.cpp | 22 | 🟡 | 排序/插删/查找/Reserve/迭代/各元素类型；部分 UE API 未绑定 |
| TMapAdvanced | AngelscriptCoverageTMapAdvancedTests.cpp | 10 | 🟡 | 增删查/FindOrAdd/迭代器/键值类型；Pair 语法不支持 |
| TSetAdvanced | AngelscriptCoverageTSetAdvancedTests.cpp | 8 | 🟡 | 增删查/集合运算/去重/容量；部分集合运算未绑定 |
| ContainerAdvanced | AngelscriptCoverageContainerAdvancedTests.cpp | 7 | ✅ | 参数/返回值/引用返回/非 UPROPERTY 容器/迭代器高级操作 |
| ContainerNested | AngelscriptCoverageContainerNestedTests.cpp | 7 | ✅ | 嵌套边界（容器禁止互相嵌套，作为边界验证） |
| ContainerParameter | AngelscriptCoverageContainerParameterTests.cpp | 4 | ✅ | 容器作参数/返回值的值/引用/out 语义 |

**小计**：6 文件 / 58 方法

## 已知边界（fork 不支持，详见 `../coverage-gaps.md §2.1/2.2`）

- TArray 未绑定：`RemoveAll(Pred)` / `Find` / `FindLast` / `StableSort` / `Reverse` / `FilterByPredicate` / Heap 系列 / `LowerBound`·`UpperBound`（已由 `TArrayUnsupportedApiAliases`/`TArrayUnsupportedAlgorithms` 作边界记录）。
- TMap 未绑定：指针式 `Find` / `Generate*Array` / `FindRef` / `FindChecked` / `Append` / `Filter` / `for(Pair)` 语法。
- TSet 未绑定：`Find` / `Array()` / `Union` / `Intersect` / `Difference` / `Includes` / `Filter`。
- 容器嵌套：`TArray<TArray<>>` / `TMap<K,TArray<>>` 等编译器直接拒绝（`Containers cannot be nested`）。
