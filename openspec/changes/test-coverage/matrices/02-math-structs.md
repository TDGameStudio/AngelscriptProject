# Math Structs Coverage Matrix, FVector / FRotator / FQuat / FTransform / FLinearColor / FVector2D + Math

> **This matrix is the design specification header for math struct tests**: each row is a concrete verifiable scenario guiding 20 math struct test files. ⬜ means pending, ✅ identifies the covering `TEST_METHOD`, and 🚫 means fork unsupported, guarded by negative assertions.
>
> - Three axes: Property / Expression / Function, plus the Math namespace and geometry structs.
> - Automation prefix examples: `Angelscript.TestModule.Coverage.<Struct><Property|Expression|Function>`.
> - See `../coverage-matrix.md` for the legend.
> - The Function axis consistently covers parameter modes value/in/out/inout, return values, default parameters, and UFUNCTION invocation; method names are aligned across struct Function files.

## 1. FVector, Property 6 / Expression 8 / Function 7

| Axis | Scenario | Status | Coverage Test Method |
|----|------|------|------------|
| Property | Declaration defaults / write round trip / containers / specifiers and Set / script members and locals / UFUNCTION property round trip | ✅ | `FVectorDeclarationDefaults` `FVectorWriteRoundTrip` `FVectorContainerProperties` `FVectorSpecifierAndSetProperties` `FVectorScriptMemberAndLocalUsage` `FVectorUFunctionPropertyRoundTrip` |
| Expression | Construction / arithmetic / comparison / dot and cross / methods / member access / declarations and index access / extended operators and methods | ✅ | `FVectorConstruction` `FVectorArithmeticOperators` `FVectorComparisonOperators` `FVectorDotAndCross` `FVectorMethods` `FVectorMemberAccess` `FVectorDeclarationsAndIndexAccess` `FVectorExtendedOperatorsAndMethods` |
| Function | value/in/out/inout + return + default parameters + UFUNCTION | ✅ | `FunctionParametersValue/In/Out/InOut` `FunctionReturnValues` `FunctionDefaultParameters` `UFunctionParametersAndReturn` |

## 2. FVector2D, Property 3 / Expression 5 / Function 7

| Axis | Scenario | Status | Coverage Test Method |
|----|------|------|------------|
| Property | Declaration defaults / write round trip / containers | ✅ | `FVector2DDeclarationDefaults` `FVector2DWriteRoundTrip` `FVector2DContainerProperties` |
| Expression | Construction / arithmetic / comparison / dot product / member access | ✅ | `Vector2DConstruction` `Vector2DArithmeticOperators` `Vector2DComparisonOperators` `Vector2DDotProduct` `Vector2DMemberAccess` |
| Function | value/in/out/inout + return + default parameters + UFUNCTION | ✅ | `FunctionParameters*` `FunctionReturnValues` `FunctionDefaultParameters` `UFunctionParametersAndReturn` |

## 3. FRotator, Property 4 / Expression 10 / Function 8

| Axis | Scenario | Status | Coverage Test Method |
|----|------|------|------------|
| Property | Declaration defaults / write round trip / containers / specifiers | ✅ | `FRotatorDeclarationDefaults` `FRotatorWriteRoundTrip` `FRotatorContainerProperties` `FRotatorPropertySpecifierFlags` |
| Expression | Construction / arithmetic / comparison / member access / normalization / conversion / static methods / declarations and confirmed methods | ✅ | `RotatorConstruction` `RotatorArithmeticOperators` `RotatorComparisonOperators` `RotatorMemberAccess` `RotatorNormalizationMethods` `RotatorConversionMethods` `RotatorStaticMethods` `RotatorDeclarationsAndConfirmedMethods` |
| Expression, boundary | Unsupported operators / unsupported static methods | 🚫 | `RotatorUnsupportedOperators` `RotatorUnsupportedStaticMethods` |
| Function | value/in/out/inout + return + default parameters + UFUNCTION + const array / stored member round trip | ✅ | `FunctionParameters*` `FunctionReturnValues` `FunctionDefaultParameters` `UFunctionParametersAndReturn` `FunctionConstArrayAndStoredMemberRoundTrip` |

## 4. FQuat, Property 4 / Expression 8 / Function 8

| Axis | Scenario | Status | Coverage Test Method |
|----|------|------|------------|
| Property | Declaration defaults / write round trip / containers / class member runtime flow | ✅ | `FQuatDeclarationDefaults` `FQuatWriteRoundTrip` `FQuatContainerProperties` `FQuatClassMemberRuntimeFlow` |
| Expression | Construction / member access / multiplication / inverse and normalize / rotate vector / conversion / static methods / advanced operators and methods | ✅ | `QuatConstruction` `QuatMemberAccess` `QuatMultiplicationOperator` `QuatInverseAndNormalize` `QuatRotateVector` `QuatConversionMethods` `QuatStaticMethods` `QuatAdvancedOperatorsAndMethods` |
| Function | value/in/out/inout + return + default parameters + UFUNCTION + const array/out paths | ✅ | `FunctionParameters*` `FunctionReturnValues` `FunctionDefaultParameters` `UFunctionParametersAndReturn` `UFunctionConstArrayAndOutPaths` |

## 5. FTransform, Property 5 / Expression 8 / Function 8

| Axis | Scenario | Status | Coverage Test Method |
|----|------|------|------------|
| Property | Declaration defaults / write round trip / method access / containers / specifiers and runtime flow | ✅ | `FTransformDeclarationDefaults` `FTransformWriteRoundTrip` `FTransformMemberAccess` `FTransformContainerProperties` `FTransformPropertySpecifierAndRuntimeFlow` |
| Expression | Construction / member access / composition / position and vector / inverse / advanced methods and mutators / interpolation / comparison | ✅ | `TransformConstruction` `TransformMemberAccess` `TransformComposition` `TransformPositionAndVector` `TransformInverse` `TransformAdvancedMethodsAndMutators` `TransformInterpolation` `TransformComparison` |
| Function | value/in/out/inout + return + default parameters + UFUNCTION + const array / stored member round trip | ✅ | `FunctionParameters*` `FunctionReturnValues` `FunctionDefaultParameters` `UFunctionParametersAndReturn` `FunctionConstArrayAndStoredMemberRoundTrip` |

## 6. FLinearColor, Property 4 / Expression 7 / Function 8

| Axis | Scenario | Status | Coverage Test Method |
|----|------|------|------------|
| Property | Declaration defaults / write round trip / containers / class member execution | ✅ | `FLinearColorDeclarationDefaults` `FLinearColorWriteRoundTrip` `FLinearColorContainerProperties` `FLinearColorClassMemberExecution` |
| Expression | Construction / arithmetic / comparison / methods / advanced methods / member access | ✅ | `LinearColorConstruction` `LinearColorArithmeticOperators` `LinearColorComparisonOperators` `LinearColorMethods` `FLinearColorAdvancedMethods` `LinearColorMemberAccess` |
| Expression, boundary | Unsupported methods | 🚫 | `LinearColorUnsupportedMethods` |
| Function | value/in/out/inout + return + array and conversion round trip + default parameters + UFUNCTION | ✅ | `FunctionParameters*` `FunctionReturnValues` `FunctionArrayAndConversionRoundTrip` `FunctionDefaultParameters` `UFunctionParametersAndReturn` |

## 7. Math Namespace Functions, MathNamespaceFunctions 13

| Scenario | Status | Coverage Test Method |
|------|------|------------|
| Trigonometric / power and root / rounding / absolute and sign / Min-Max-Clamp | ✅ | `TrigonometricFunctions` `PowerAndRootFunctions` `RoundingFunctions` `AbsoluteAndSignFunctions` `MinMaxClampFunctions` |
| Special value classification / interpolation / scalar curve and utilities / random | ✅ | `SpecialValueClassificationFunctions` `InterpolationFunctions` `ScalarCurveAndUtilityFunctions` `RandomFunctions` |
| Vector math / geometric math / vector method matrix | ✅ | `VectorMathFunctions` `GeometricMathFunctions` `VectorMethodMatrix` |
| Unsupported vector math namespace boundaries | 🚫 | `UnsupportedVectorMathNamespaceBoundaries` |

## 8. Geometry Structs, MathGeometricStructs 11

| Scenario | Status | Coverage Test Method |
|------|------|------------|
| FTransform construction and operations | ✅ | `FTransformConstruction` `FTransformOperations` |
| FVector4 / FIntPoint / FIntVector expressions and reflection | ✅ | `Vector4IntPointIntVectorExpressions` `Vector4IntPointIntVectorReflection` |
| Geometry struct reflected properties and containers / function parameters and returns | ✅ | `GeometricStructReflectionPropertiesAndContainers` `GeometricStructFunctionParametersAndReturns` |
| Color and RandomStream struct expressions | ✅ | `ColorAndRandomStreamStructExpressions` |
| FBox / FPlane operations | ✅ | `FBoxOperations` `FPlaneOperations` |
| FMatrix / FBox2D unsupported boundaries | 🚫 | `FMatrixUnsupportedBoundaries` `FBox2DUnsupportedBoundary` |

---

## Summary

| Struct | Property | Expression | Function | Subtotal |
|------|----------|-----------|----------|------|
| FVector | 6 | 8 | 7 | 21 |
| FVector2D | 3 | 5 | 7 | 15 |
| FRotator | 4 | 10 | 8 | 22 |
| FQuat | 4 | 8 | 8 | 20 |
| FTransform | 5 | 8 | 8 | 21 |
| FLinearColor | 4 | 7 | 8 | 19 |
| MathNamespace | — | — | 13 | 13 |
| MathGeometric | — | — | 11 | 11 |
| **Total** | | | | **142** |

**Corresponding test methods**: 20 files / 142 methods.
**Pending (⬜)**: no hard gaps currently; each struct's three-axis coverage is mature, and unsupported operators/methods are locked as 🚫.
