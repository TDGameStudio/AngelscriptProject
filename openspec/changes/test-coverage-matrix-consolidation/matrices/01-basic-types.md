# 基础类型覆盖矩阵（int / float / bool / FString）

> 域：AngelScript 基础值类型在 属性 / 表达式 / 函数·方法 三个轴上的覆盖。
> 归属：OpenSpec `test-coverage-matrix-consolidation`。图例与列说明见 `../coverage-matrix.md`。

| 主题 | 测试文件 | 方法数 | 状态 | 覆盖要点 |
|------|---------|-------|------|---------|
| IntProperty | AngelscriptCoverageIntPropertyTests.cpp | 15 | ✅ | int8~uint64 全宽度、说明符、容器元素 |
| IntExpression | AngelscriptCoverageIntExpressionTests.cpp | 20 | ✅ | 算术/位运算/比较/溢出 |
| IntFunction | AngelscriptCoverageIntFunctionTests.cpp | 14 | ✅ | 整型全局/数学函数 |
| FloatProperty | AngelscriptCoverageFloatPropertyTests.cpp | 9 | ✅ | float/double 属性、精度、默认值 |
| FloatExpression | AngelscriptCoverageFloatExpressionTests.cpp | 12 | ✅ | 浮点运算/NaN/精度 |
| FloatFunction | AngelscriptCoverageFloatFunctionTests.cpp | 8 | ✅ | 浮点函数、参数模式(in/out/inout)、重载 |
| BoolProperty | AngelscriptCoverageBoolPropertyTests.cpp | 6 | ✅ | bool 属性位域/说明符 |
| BoolExpression | AngelscriptCoverageBoolExpressionTests.cpp | 14 | ✅ | 逻辑运算/短路求值 |
| BoolFunction | AngelscriptCoverageBoolFunctionTests.cpp | 9 | ✅ | bool 相关函数 |
| FStringProperty | AngelscriptCoverageFStringPropertyTests.cpp | 12 | ✅ | FString/FName/FText 属性、容器、复制 |
| FStringExpression | AngelscriptCoverageFStringExpressionTests.cpp | 9 | ✅ | 拼接/比较 |
| FStringFunction | AngelscriptCoverageFStringFunctionTests.cpp | 9 | ✅ | 字符串全局函数 |
| FStringMethod | AngelscriptCoverageFStringMethodTests.cpp | 14 | ✅ | 查找/大小写/裁剪/子串/替换/分割/格式化 |

**小计**：13 文件 / 151 方法

## 已知边界

- `TArray<FText>` / `TMap` 以 FText 为键存在哈希边界（`FTextContainerHashBoundariesRemainUnsupported`），属 fork 不支持，详见 `../coverage-gaps.md §2`。
