# 数学结构覆盖矩阵（FVector / FRotator / FQuat / FTransform / FLinearColor / FVector2D）

> 域：UE 数学结构在 属性 / 表达式 / 函数 三轴的覆盖，外加数学命名空间与几何结构。
> 归属：OpenSpec `test-coverage-matrix-consolidation`。图例与列说明见 `../coverage-matrix.md`。

| 主题 | 测试文件 | 方法数 | 状态 | 覆盖要点 |
|------|---------|-------|------|---------|
| FVectorProperty | AngelscriptCoverageFVectorPropertyTests.cpp | 6 | ✅ | FVector 声明/默认/往返/容器/说明符 |
| FVectorExpression | AngelscriptCoverageFVectorExpressionTests.cpp | 8 | ✅ | 向量运算符 |
| FVectorFunction | AngelscriptCoverageFVectorFunctionTests.cpp | 7 | ✅ | FVector 成员/全局函数 |
| FVector2DProperty | AngelscriptCoverageFVector2DPropertyTests.cpp | 3 | ✅ | FVector2D 属性 |
| FVector2DExpression | AngelscriptCoverageFVector2DExpressionTests.cpp | 5 | ✅ | 2D 向量运算符 |
| FVector2DFunction | AngelscriptCoverageFVector2DFunctionTests.cpp | 7 | ✅ | FVector2D 函数 |
| FRotatorProperty | AngelscriptCoverageFRotatorPropertyTests.cpp | 4 | ✅ | FRotator 属性 |
| FRotatorExpression | AngelscriptCoverageFRotatorExpressionTests.cpp | 8 | ✅ | 旋转运算符 |
| FRotatorFunction | AngelscriptCoverageFRotatorFunctionTests.cpp | 8 | ✅ | FRotator 成员/全局函数 |
| FQuatProperty | AngelscriptCoverageFQuatPropertyTests.cpp | 4 | ✅ | FQuat 属性 |
| FQuatExpression | AngelscriptCoverageFQuatExpressionTests.cpp | 8 | ✅ | 四元数运算符 |
| FQuatFunction | AngelscriptCoverageFQuatFunctionTests.cpp | 8 | ✅ | FQuat 函数 |
| FTransformProperty | AngelscriptCoverageFTransformPropertyTests.cpp | 5 | ✅ | FTransform 属性 |
| FTransformExpression | AngelscriptCoverageFTransformExpressionTests.cpp | 8 | ✅ | 构造/成员/组合/逆/插值/比较 |
| FTransformFunction | AngelscriptCoverageFTransformFunctionTests.cpp | 8 | ✅ | FTransform 函数、参数模式 |
| FLinearColorProperty | AngelscriptCoverageFLinearColorPropertyTests.cpp | 4 | ✅ | FLinearColor 属性 |
| FLinearColorExpression | AngelscriptCoverageFLinearColorExpressionTests.cpp | 6 | ✅ | 颜色运算符 |
| FLinearColorFunction | AngelscriptCoverageFLinearColorFunctionTests.cpp | 8 | ✅ | FLinearColor 函数 |
| MathNamespaceFunctions | AngelscriptCoverageMathNamespaceFunctions.cpp | 13 | ✅ | `Math::` 命名空间函数 |
| MathGeometricStructs | AngelscriptCoverageMathGeometricStructs.cpp | 11 | ✅ | FBox/FSphere/FPlane 等几何结构 |

**小计**：20 文件 / 139 方法
