# Basic Types Coverage Matrix, int / float / bool / FString

> **This matrix is the design specification header for basic type tests**: each row is a concrete verifiable scenario guiding 13 basic type test files. ⬜ means pending, ✅ identifies the covering `TEST_METHOD`, and 🚫 means fork unsupported, guarded by negative assertions.
>
> - Three axes: Property / Expression / Function or Method
> - Automation prefix: `Angelscript.TestModule.Coverage.<Int|Float|Bool|FString><Property|Expression|Function|Method>`
> - See `../coverage-matrix.md` for the legend.

## 1. Integer int, IntProperty 15 / IntExpression 20 / IntFunction 14

### 1.1 Properties

| Scenario | Status | Coverage Test Method | Notes / Pending Work |
|------|------|------------|-------------|
| int family declarations and defaults, int8 through uint64 | ✅ | `IntFamilyDeclarationDefaults` `IntFamilyImplicitAndExplicitZeroDefaults` | All-width defaults |
| Write round trip | ✅ | `IntFamilyWriteRoundTrip` | Read/write consistency |
| Boundary / near-boundary values | ✅ | `IntFamilyBoundaryValues` `IntFamilyNearBoundaryValues` | min/max boundaries |
| Container properties, arrays / extended / all widths / boundaries | ✅ | `IntContainerProperties` `IntContainerPropertiesExtended` `IntContainerWidthCompletion` `IntContainerEdgeCases` | TArray<int*> elements |
| Nested int in struct, including deep paths | ✅ | `IntStructNestedPropertyWidths` `IntStructDeepNestedPropertyPaths` | Struct member widths |
| Script read/write API surface | ✅ | `IntPropertyScriptReadWriteApiSurface` | Reflective read/write |
| Specifier flags, including representative widths | ✅ | `IntPropertySpecifierFlags` `IntPropertySpecifierRepresentativeWidths` | EditAnywhere and related flags |
| Nested array container boundary | 🚫 | `IntNestedArrayContainerBoundary` | Nesting rejected |

### 1.2 Expressions

| Scenario | Status | Coverage Test Method | Notes / Pending Work |
|------|------|------------|-------------|
| Local / global const declarations | ✅ | `LocalDeclarations` `GlobalConstDeclarations` | Declaration contexts |
| Arithmetic / bitwise / shift operators | ✅ | `ArithmeticOperators` `BitwiseAndShiftOperators` `IntWidthOperatorSamples` | Operators across widths |
| Comparison / compound assignment | ✅ | `ComparisonOperators` `CompoundAssignmentOperators` | ==, +=, <<=, and related forms |
| Arithmetic safety, overflow behavior | ✅ | `ArithmeticSafety` | Overflow semantics |
| Literals, including boundaries | ✅ | `IntegerLiterals` `IntegerLiteralEdges` | Base formats and boundary literals |
| Conversions, including loss and out-of-range | ✅ | `IntegerConversions` `IntegerConversionLossAndOutOfRange` | Implicit/explicit conversion |
| Mixed-type arithmetic / UE math type interaction | ✅ | `MixedTypeArithmetic` `IntWithUEMathTypes` | Type promotion |
| Operator precedence and associativity | ✅ | `OperatorPrecedenceAndAssociativity` | Precedence |
| Chained numeric promotions / complex expression evaluation | ✅ | `ChainedNumericPromotionExpressions` `ComplexIntegerExpressionEvaluation` | Compound expressions |
| Non-property class members / all widths | ✅ | `ClassMembersNonProperty` `ClassMembersNonPropertyAllWidths` | Non-reflected members |
| Declaration context boundaries | ✅ | `DeclarationContextEdges` | Boundary declarations |

### 1.3 Functions

| Scenario | Status | Coverage Test Method | Notes / Pending Work |
|------|------|------------|-------------|
| Parameter modes value/in/out/inout | ✅ | `FunctionParametersValue/In/Out/InOut` | Four parameter modes |
| Reference parameter combinations | ✅ | `FunctionReferenceParameterCombinations` | Reference combinations |
| Return values / return control flow | ✅ | `FunctionReturnValues` `FunctionReturnControlFlow` | Return paths |
| Default parameters, including edges | ✅ | `FunctionDefaultParameters` `FunctionDefaultParameterEdges` | Defaults |
| Overloading, including arity/numeric resolution | ✅ | `FunctionOverloading` `FunctionOverloadArityAndNumericResolution` | Overload resolution |
| UFUNCTION parameters and return | ✅ | `UFunctionParametersAndReturn` `UFunctionSpecifierDefaultsAndOutParameters` | Reflective invocation |
| All integer widths reflect and invoke through UFUNCTION | ✅ | `UFunctionAllIntegerWidthsReflectAndInvoke` | All-width UFUNCTION coverage |

## 2. Floating Point float / double, FloatProperty 9 / FloatExpression 12 / FloatFunction 8

### 2.1 Properties

| Scenario | Status | Coverage Test Method | Notes / Pending Work |
|------|------|------------|-------------|
| float/double declarations and defaults | ✅ | `FloatFamilyDeclarationDefaults` | Defaults |
| Write / script mutation round trip | ✅ | `FloatFamilyWriteRoundTrip` `FloatPropertyScriptMutationRoundTrip` | Read/write consistency |
| Boundary values / special values, NaN/Inf/+0/-0 | ✅ | `FloatFamilyBoundaryValues` `FloatFamilySpecialValues` | Special floating point values |
| Container properties | ✅ | `FloatContainerProperties` | TArray<float> |
| Replicated properties | ✅ | `FloatReplicatedProperties` | Replicated |
| Specifier flags | ✅ | `FloatPropertySpecifierFlags` | Flags |
| Nested container boundary | 🚫 | `FloatNestedContainerBoundary` | Nesting rejected |

### 2.2 Expressions

| Scenario | Status | Coverage Test Method | Notes / Pending Work |
|------|------|------------|-------------|
| Local / global const declarations | ✅ | `LocalDeclarations` `GlobalConstDeclarations` | Declarations |
| Arithmetic / comparison / compound assignment / ternary | ✅ | `ArithmeticOperators` `ComparisonOperators` `CompoundAssignmentOperators` `TernaryOperators` | Operators |
| Literals | ✅ | `FloatLiterals` | Float literals |
| Conversions | ✅ | `FloatConversions` | Type conversion |
| Special value expressions | ✅ | `SpecialValues` | NaN/Inf expressions |
| Non-property class members | ✅ | `ClassMembersNonProperty` | Non-reflected members |
| Unsupported literal suffixes | 🚫 | `FloatLiteralUnsupportedSuffixBoundaries` | Suffixes rejected |
| `Math::NaN/Inf` names unsupported | 🚫 | `MathNaNInfNamesRemainUnsupported` | Names unbound |

### 2.3 Functions

| Scenario | Status | Coverage Test Method | Notes / Pending Work |
|------|------|------------|-------------|
| Parameter modes value/in/out/inout | ✅ | `FunctionParametersValue/In/Out/InOut` | Four parameter modes |
| Return values | ✅ | `FunctionReturnValues` | Return paths |
| Default parameters / overloading | ✅ | `FunctionDefaultParameters` `FunctionOverloading` | Defaults / overloads |
| UFUNCTION parameters and return | ✅ | `UFunctionParametersAndReturn` | Reflective invocation |

## 3. Boolean bool, BoolProperty 6 / BoolExpression 14 / BoolFunction 9

### 3.1 Properties

| Scenario | Status | Coverage Test Method | Notes / Pending Work |
|------|------|------------|-------------|
| Declaration and defaults | ✅ | `BoolDeclarationDefaults` | Defaults |
| Write round trip | ✅ | `BoolWriteRoundTrip` | Read/write consistency |
| Container properties | ✅ | `BoolContainerProperties` | TArray<bool> |
| Replicated properties | ✅ | `BoolReplicatedProperties` | Replicated |
| Specifier flags | ✅ | `BoolPropertySpecifierFlags` | Flags |
| Nested array property boundary | 🚫 | `BoolNestedArrayProperties` | Nesting rejected |

### 3.2 Expressions

| Scenario | Status | Coverage Test Method | Notes / Pending Work |
|------|------|------------|-------------|
| Local declarations / auto deduction | ✅ | `LocalDeclarations` `AutoDeduction` | Declarations |
| Global const declarations | ✅ | `GlobalConstDeclarations` | Global constants |
| Logical / equality / bitwise operators | ✅ | `LogicalOperators` `EqualityOperators` `BitwiseOperators` | Operators |
| Short-circuit evaluation | ✅ | `LogicalShortCircuit` | && / \|\| short-circuit |
| Literals, including case sensitivity | ✅ | `BoolLiterals` `CaseSensitiveLiterals` | true/false |
| Conversions, including handle conversions | ✅ | `BoolConversions` `HandleConversions` | bool conversion |
| bool in control flow | ✅ | `BoolInControlFlow` | if/while conditions |
| Non-property class members | ✅ | `ClassMembersNonProperty` | Non-reflected members |
| Global mutable declarations unsupported | 🚫 | `GlobalMutableDeclarationsUnsupported` | Global mutable variables rejected |

### 3.3 Functions

| Scenario | Status | Coverage Test Method | Notes / Pending Work |
|------|------|------------|-------------|
| Parameter modes value/in/out/multiple out/inout | ✅ | `FunctionParametersValue/In/Out/MultipleOut/InOut` | Parameter modes |
| Return values | ✅ | `FunctionReturnValues` | Return paths |
| Default parameters / overloading | ✅ | `FunctionDefaultParameters` `FunctionOverloading` | Defaults / overloads |
| UFUNCTION parameters and return | ✅ | `UFunctionParametersAndReturn` | Reflective invocation |

## 4. Strings FString / FName / FText, FStringProperty 12 / Expression 9 / Function 9 / Method 14

### 4.1 Properties

| Scenario | Status | Coverage Test Method | Notes / Pending Work |
|------|------|------------|-------------|
| Declaration contexts / family defaults | ✅ | `StringDeclarationContexts` `StringFamilyDeclarationDefaults` | FString/FName/FText |
| Write round trip | ✅ | `StringFamilyWriteRoundTrip` | Read/write consistency |
| Script read/write API / specifiers | ✅ | `StringPropertyScriptReadWriteApiSurface` `StringPropertySpecifierFlags` | Reflection / flags |
| Replicated properties | ✅ | `StringFamilyReplicatedProperties` | Replicated |
| Special values, empty/Unicode/special text | ✅ | `StringSpecialValues` `StringFamilyScriptSpecialTextValues` | Text boundaries |
| Container properties / Map key-value combinations | ✅ | `StringContainerProperties` `StringFamilyMapKeyValueCombinations` | Container elements |
| UFUNCTION property round trip | ✅ | `StringUFunctionPropertyRoundTrip` | Reflection round trip |
| FText as container hash key boundary | 🚫 | `FTextContainerHashBoundariesRemainUnsupported` | FText not hashable |

### 4.2 Expressions

| Scenario | Status | Coverage Test Method | Notes / Pending Work |
|------|------|------------|-------------|
| Local / global const declarations | ✅ | `LocalDeclarations` `GlobalConstDeclarations` | Declarations |
| String operators, concatenation/comparison | ✅ | `StringOperators` | + / == |
| Literals / conversions | ✅ | `StringLiterals` `StringConversions` | Literals / conversion |
| FName/FText-specific operations and comparisons | ✅ | `NameAndTextSpecificOperations` `NameAndTextComparisonOperators` | Name/Text semantics |
| Non-property class members | ✅ | `ClassMembersNonProperty` | Non-reflected members |
| Unsupported string expression boundaries | 🚫 | `UnsupportedStringExpressionBoundaries` | Rejected forms |

### 4.3 Functions And Methods

| Scenario | Status | Coverage Test Method | Notes / Pending Work |
|------|------|------------|-------------|
| Parameter modes value/in/out/inout | ✅ | `FunctionParametersValue/In/Out/InOut` | Parameter modes |
| Return values / default parameters / overloading | ✅ | `FunctionReturnValues` `FunctionDefaultParameters` `FunctionOverloading` | Function features |
| UFUNCTION parameters and return | ✅ | `UFunctionParametersAndReturn` | Reflective invocation |
| Unsupported function signature boundaries | 🚫 | `UnsupportedFunctionSignatureBoundaries` | FText literal default parameters rejected |
| Length / empty checks | ✅ | `LengthAndEmpty` | Len/IsEmpty |
| Search | ✅ | `SearchMethods` | Find/Contains |
| Case conversion / trimming | ✅ | `CaseConversion` `TrimMethods` | ToUpper/Trim |
| Substring / replace | ✅ | `SubstringMethods` `ReplaceMethods` | Mid/Replace |
| Mutable string methods, including edges | ✅ | `MutableStringMethods` `MutableStringEdgeCases` | Append/InsertAt |
| Split / ParseIntoArray | ✅ | `SplitMethods` `ParseIntoArrayDelimiterVariants` | Split |
| Format / conversion / reverse / numeric check | ✅ | `FormatMethods` `ConversionMethods` `ReverseMethods` `IsNumericMethod` | Formatting and related methods |

---

## Summary

| Type | Files | Methods | Notes |
|------|------|------|------|
| int | IntProperty/Expression/Function | 15+20+14=49 | Includes 1 nesting boundary |
| float | FloatProperty/Expression/Function | 9+12+8=29 | Includes 3 boundaries |
| bool | BoolProperty/Expression/Function | 6+14+9=29 | Includes 2 boundaries |
| FString | FStringProperty/Expression/Function/Method | 12+9+9+14=44 | Includes 3 boundaries |
| **Total** | **13 files** | **151** | |

**Pending (⬜)**: no hard gaps currently; the three-axis coverage for basic types is mature, and unsupported forms are locked through 🚫 negative assertions.
