# 数学结构覆盖矩阵（FVector / FRotator / FQuat / FTransform / FLinearColor / FVector2D + Math）

> **本矩阵是数学结构测试的设计规格("头")**：每行是一个**具体可验证场景**，指导 20 个数学结构测试文件的实现。⬜＝待实现，✅ 注明覆盖它的 `TEST_METHOD`，🚫＝fork 不支持（负向断言守边界）。
>
> - 三轴：属性(Property) / 表达式(Expression) / 函数(Function)，外加 Math 命名空间与几何结构。
> - Automation 前缀：`Angelscript.TestModule.Coverage.<Struct><Property|Expression|Function>` 等。
> - 图例见 `../coverage-matrix.md`。
> - 函数轴统一覆盖参数模式 value/in/out/inout + 返回值 + 默认参数 + UFUNCTION 调用（各 struct 的 `Function` 文件方法名一致）。

## 1. FVector（Property 6 / Expression 8 / Function 7）

| 轴 | 场景 | 状态 | 覆盖测试方法 |
|----|------|------|------------|
| 属性 | 声明默认 / 写入往返 / 容器 / 说明符与 Set / 脚本成员与局部 / UFUNCTION 属性往返 | ✅ | `FVectorDeclarationDefaults` `FVectorWriteRoundTrip` `FVectorContainerProperties` `FVectorSpecifierAndSetProperties` `FVectorScriptMemberAndLocalUsage` `FVectorUFunctionPropertyRoundTrip` |
| 表达式 | 构造 / 算术 / 比较 / 点乘叉乘 / 方法 / 成员访问 / 声明与索引访问 / 扩展运算符与方法 | ✅ | `FVectorConstruction` `FVectorArithmeticOperators` `FVectorComparisonOperators` `FVectorDotAndCross` `FVectorMethods` `FVectorMemberAccess` `FVectorDeclarationsAndIndexAccess` `FVectorExtendedOperatorsAndMethods` |
| 函数 | value/in/out/inout + 返回 + 默认参 + UFUNCTION | ✅ | `FunctionParametersValue/In/Out/InOut` `FunctionReturnValues` `FunctionDefaultParameters` `UFunctionParametersAndReturn` |

## 2. FVector2D（Property 3 / Expression 5 / Function 7）

| 轴 | 场景 | 状态 | 覆盖测试方法 |
|----|------|------|------------|
| 属性 | 声明默认 / 写入往返 / 容器 | ✅ | `FVector2DDeclarationDefaults` `FVector2DWriteRoundTrip` `FVector2DContainerProperties` |
| 表达式 | 构造 / 算术 / 比较 / 点乘 / 成员访问 | ✅ | `Vector2DConstruction` `Vector2DArithmeticOperators` `Vector2DComparisonOperators` `Vector2DDotProduct` `Vector2DMemberAccess` |
| 函数 | value/in/out/inout + 返回 + 默认参 + UFUNCTION | ✅ | `FunctionParameters*` `FunctionReturnValues` `FunctionDefaultParameters` `UFunctionParametersAndReturn` |

## 3. FRotator（Property 4 / Expression 10 / Function 8）

| 轴 | 场景 | 状态 | 覆盖测试方法 |
|----|------|------|------------|
| 属性 | 声明默认 / 写入往返 / 容器 / 说明符 | ✅ | `FRotatorDeclarationDefaults` `FRotatorWriteRoundTrip` `FRotatorContainerProperties` `FRotatorPropertySpecifierFlags` |
| 表达式 | 构造 / 算术 / 比较 / 成员访问 / 归一化 / 转换 / 静态方法 / 声明与确认方法 | ✅ | `RotatorConstruction` `RotatorArithmeticOperators` `RotatorComparisonOperators` `RotatorMemberAccess` `RotatorNormalizationMethods` `RotatorConversionMethods` `RotatorStaticMethods` `RotatorDeclarationsAndConfirmedMethods` |
| 表达式（边界） | 不支持的运算符 / 不支持的静态方法 | 🚫 | `RotatorUnsupportedOperators` `RotatorUnsupportedStaticMethods` |
| 函数 | value/in/out/inout + 返回 + 默认参 + UFUNCTION + const 数组/存储成员往返 | ✅ | `FunctionParameters*` `FunctionReturnValues` `FunctionDefaultParameters` `UFunctionParametersAndReturn` `FunctionConstArrayAndStoredMemberRoundTrip` |

## 4. FQuat（Property 4 / Expression 8 / Function 8）

| 轴 | 场景 | 状态 | 覆盖测试方法 |
|----|------|------|------------|
| 属性 | 声明默认 / 写入往返 / 容器 / 类成员运行流 | ✅ | `FQuatDeclarationDefaults` `FQuatWriteRoundTrip` `FQuatContainerProperties` `FQuatClassMemberRuntimeFlow` |
| 表达式 | 构造 / 成员访问 / 乘法 / 逆与归一化 / 旋转向量 / 转换 / 静态方法 / 高级运算符与方法 | ✅ | `QuatConstruction` `QuatMemberAccess` `QuatMultiplicationOperator` `QuatInverseAndNormalize` `QuatRotateVector` `QuatConversionMethods` `QuatStaticMethods` `QuatAdvancedOperatorsAndMethods` |
| 函数 | value/in/out/inout + 返回 + 默认参 + UFUNCTION + const 数组/out 路径 | ✅ | `FunctionParameters*` `FunctionReturnValues` `FunctionDefaultParameters` `UFunctionParametersAndReturn` `UFunctionConstArrayAndOutPaths` |

## 5. FTransform（Property 5 / Expression 8 / Function 8）

| 轴 | 场景 | 状态 | 覆盖测试方法 |
|----|------|------|------------|
| 属性 | 声明默认 / 写入往返 / 方法访问 / 容器 / 说明符与运行流 | ✅ | `FTransformDeclarationDefaults` `FTransformWriteRoundTrip` `FTransformMemberAccess` `FTransformContainerProperties` `FTransformPropertySpecifierAndRuntimeFlow` |
| 表达式 | 构造 / 成员访问 / 组合 / 位置与向量 / 逆 / 高级方法与变更器 / 插值 / 比较 | ✅ | `TransformConstruction` `TransformMemberAccess` `TransformComposition` `TransformPositionAndVector` `TransformInverse` `TransformAdvancedMethodsAndMutators` `TransformInterpolation` `TransformComparison` |
| 函数 | value/in/out/inout + 返回 + 默认参 + UFUNCTION + const 数组/存储成员往返 | ✅ | `FunctionParameters*` `FunctionReturnValues` `FunctionDefaultParameters` `UFunctionParametersAndReturn` `FunctionConstArrayAndStoredMemberRoundTrip` |

## 6. FLinearColor（Property 4 / Expression 7 / Function 8）

| 轴 | 场景 | 状态 | 覆盖测试方法 |
|----|------|------|------------|
| 属性 | 声明默认 / 写入往返 / 容器 / 类成员执行 | ✅ | `FLinearColorDeclarationDefaults` `FLinearColorWriteRoundTrip` `FLinearColorContainerProperties` `FLinearColorClassMemberExecution` |
| 表达式 | 构造 / 算术 / 比较 / 方法 / 高级方法 / 成员访问 | ✅ | `LinearColorConstruction` `LinearColorArithmeticOperators` `LinearColorComparisonOperators` `LinearColorMethods` `FLinearColorAdvancedMethods` `LinearColorMemberAccess` |
| 表达式（边界） | 不支持的方法 | 🚫 | `LinearColorUnsupportedMethods` |
| 函数 | value/in/out/inout + 返回 + 数组与转换往返 + 默认参 + UFUNCTION | ✅ | `FunctionParameters*` `FunctionReturnValues` `FunctionArrayAndConversionRoundTrip` `FunctionDefaultParameters` `UFunctionParametersAndReturn` |

## 7. Math 命名空间函数（MathNamespaceFunctions 13）

| 场景 | 状态 | 覆盖测试方法 |
|------|------|------------|
| 三角 / 幂与根 / 取整 / 绝对值与符号 / Min-Max-Clamp | ✅ | `TrigonometricFunctions` `PowerAndRootFunctions` `RoundingFunctions` `AbsoluteAndSignFunctions` `MinMaxClampFunctions` |
| 特殊值分类 / 插值 / 标量曲线与工具 / 随机 | ✅ | `SpecialValueClassificationFunctions` `InterpolationFunctions` `ScalarCurveAndUtilityFunctions` `RandomFunctions` |
| 向量数学 / 几何数学 / 向量方法矩阵 | ✅ | `VectorMathFunctions` `GeometricMathFunctions` `VectorMethodMatrix` |
| 不支持的向量数学命名空间边界 | 🚫 | `UnsupportedVectorMathNamespaceBoundaries` |

## 8. 几何结构（MathGeometricStructs 11）

| 场景 | 状态 | 覆盖测试方法 |
|------|------|------------|
| FTransform 构造与操作 | ✅ | `FTransformConstruction` `FTransformOperations` |
| FVector4 / FIntPoint / FIntVector 表达式与反射 | ✅ | `Vector4IntPointIntVectorExpressions` `Vector4IntPointIntVectorReflection` |
| 几何结构反射属性与容器 / 函数参数与返回 | ✅ | `GeometricStructReflectionPropertiesAndContainers` `GeometricStructFunctionParametersAndReturns` |
| 颜色与 RandomStream 结构表达式 | ✅ | `ColorAndRandomStreamStructExpressions` |
| FBox / FPlane 操作 | ✅ | `FBoxOperations` `FPlaneOperations` |
| FMatrix / FBox2D 不支持边界 | 🚫 | `FMatrixUnsupportedBoundaries` `FBox2DUnsupportedBoundary` |

---

## 汇总

| 结构 | Property | Expression | Function | 小计 |
|------|----------|-----------|----------|------|
| FVector | 6 | 8 | 7 | 21 |
| FVector2D | 3 | 5 | 7 | 15 |
| FRotator | 4 | 10 | 8 | 22 |
| FQuat | 4 | 8 | 8 | 20 |
| FTransform | 5 | 8 | 8 | 21 |
| FLinearColor | 4 | 7 | 8 | 19 |
| MathNamespace | — | — | 13 | 13 |
| MathGeometric | — | — | 11 | 11 |
| **合计** | | | | **142** |

**对应测试方法**：20 文件 / 142 方法。
**待实现（⬜）**：当前无硬缺口；各 struct 三轴成熟，不支持运算符/方法均以 🚫 固化。
