# 基础类型覆盖矩阵（int / float / bool / FString）

> **本矩阵是基础类型测试的设计规格("头")**：每行是一个**具体可验证场景**，指导 13 个基础类型测试文件的实现。⬜＝待实现，✅ 注明覆盖它的 `TEST_METHOD`，🚫＝fork 不支持（负向断言守边界）。
>
> - 三轴：属性(Property) / 表达式(Expression) / 函数·方法(Function/Method)
> - Automation 前缀：`Angelscript.TestModule.Coverage.<Int|Float|Bool|FString><Property|Expression|Function|Method>`
> - 图例见 `../coverage-matrix.md`。

## 1. 整型 int（IntProperty 15 / IntExpression 20 / IntFunction 14）

### 1.1 属性

| 场景 | 状态 | 覆盖测试方法 | 要点 / 待实现 |
|------|------|------------|-------------|
| int 家族声明与默认值（int8~uint64） | ✅ | `IntFamilyDeclarationDefaults` `IntFamilyImplicitAndExplicitZeroDefaults` | 全宽度默认值 |
| 写入往返 | ✅ | `IntFamilyWriteRoundTrip` | 读写一致 |
| 边界 / 近边界值 | ✅ | `IntFamilyBoundaryValues` `IntFamilyNearBoundaryValues` | min/max 边界 |
| 容器属性（数组/扩展/全宽度/边界） | ✅ | `IntContainerProperties` `IntContainerPropertiesExtended` `IntContainerWidthCompletion` `IntContainerEdgeCases` | TArray<int*> 元素 |
| struct 内嵌 int（含深层路径） | ✅ | `IntStructNestedPropertyWidths` `IntStructDeepNestedPropertyPaths` | struct 成员宽度 |
| 脚本读写 API 表面 | ✅ | `IntPropertyScriptReadWriteApiSurface` | 反射读写 |
| 说明符标志（含代表性宽度） | ✅ | `IntPropertySpecifierFlags` `IntPropertySpecifierRepresentativeWidths` | EditAnywhere 等 |
| 嵌套数组容器边界 | 🚫 | `IntNestedArrayContainerBoundary` | 嵌套被拒 |

### 1.2 表达式

| 场景 | 状态 | 覆盖测试方法 | 要点 / 待实现 |
|------|------|------------|-------------|
| 局部 / 全局 const 声明 | ✅ | `LocalDeclarations` `GlobalConstDeclarations` | 声明上下文 |
| 算术 / 位运算 / 移位 | ✅ | `ArithmeticOperators` `BitwiseAndShiftOperators` `IntWidthOperatorSamples` | 各宽度运算 |
| 比较 / 复合赋值 | ✅ | `ComparisonOperators` `CompoundAssignmentOperators` | ==/+=/<<= 等 |
| 算术安全（溢出行为） | ✅ | `ArithmeticSafety` | 溢出语义 |
| 字面量（含边界） | ✅ | `IntegerLiterals` `IntegerLiteralEdges` | 进制/边界字面量 |
| 转换（含丢失/越界） | ✅ | `IntegerConversions` `IntegerConversionLossAndOutOfRange` | 隐式/显式转换 |
| 混合类型算术 / 与 UE 数学类型 | ✅ | `MixedTypeArithmetic` `IntWithUEMathTypes` | 类型提升 |
| 运算符优先级与结合性 | ✅ | `OperatorPrecedenceAndAssociativity` | 优先级 |
| 链式数值提升 / 复杂表达式求值 | ✅ | `ChainedNumericPromotionExpressions` `ComplexIntegerExpressionEvaluation` | 复合表达式 |
| 非属性类成员 / 全宽度 | ✅ | `ClassMembersNonProperty` `ClassMembersNonPropertyAllWidths` | 非反射成员 |
| 声明上下文边界 | ✅ | `DeclarationContextEdges` | 边界声明 |

### 1.3 函数

| 场景 | 状态 | 覆盖测试方法 | 要点 / 待实现 |
|------|------|------------|-------------|
| 参数模式 value/in/out/inout | ✅ | `FunctionParametersValue/In/Out/InOut` | 四种参数模式 |
| 引用参数组合 | ✅ | `FunctionReferenceParameterCombinations` | 引用组合 |
| 返回值 / 返回控制流 | ✅ | `FunctionReturnValues` `FunctionReturnControlFlow` | 返回路径 |
| 默认参数（含边界） | ✅ | `FunctionDefaultParameters` `FunctionDefaultParameterEdges` | 默认值 |
| 重载（含 arity/数值解析） | ✅ | `FunctionOverloading` `FunctionOverloadArityAndNumericResolution` | 重载决议 |
| UFUNCTION 参数与返回 | ✅ | `UFunctionParametersAndReturn` `UFunctionSpecifierDefaultsAndOutParameters` | 反射调用 |
| 全整型宽度反射并调用 | ✅ | `UFunctionAllIntegerWidthsReflectAndInvoke` | 全宽度 UFUNCTION |

## 2. 浮点 float / double（FloatProperty 9 / FloatExpression 12 / FloatFunction 8）

### 2.1 属性

| 场景 | 状态 | 覆盖测试方法 | 要点 / 待实现 |
|------|------|------------|-------------|
| float/double 声明与默认 | ✅ | `FloatFamilyDeclarationDefaults` | 默认值 |
| 写入 / 脚本变更往返 | ✅ | `FloatFamilyWriteRoundTrip` `FloatPropertyScriptMutationRoundTrip` | 读写一致 |
| 边界值 / 特殊值（NaN/Inf/±0） | ✅ | `FloatFamilyBoundaryValues` `FloatFamilySpecialValues` | 特殊浮点值 |
| 容器属性 | ✅ | `FloatContainerProperties` | TArray<float> |
| 复制属性 | ✅ | `FloatReplicatedProperties` | Replicated |
| 说明符标志 | ✅ | `FloatPropertySpecifierFlags` | 标志位 |
| 嵌套容器边界 | 🚫 | `FloatNestedContainerBoundary` | 嵌套被拒 |

### 2.2 表达式

| 场景 | 状态 | 覆盖测试方法 | 要点 / 待实现 |
|------|------|------------|-------------|
| 局部 / 全局 const 声明 | ✅ | `LocalDeclarations` `GlobalConstDeclarations` | 声明 |
| 算术 / 比较 / 复合赋值 / 三元 | ✅ | `ArithmeticOperators` `ComparisonOperators` `CompoundAssignmentOperators` `TernaryOperators` | 运算符 |
| 字面量 | ✅ | `FloatLiterals` | 浮点字面量 |
| 转换 | ✅ | `FloatConversions` | 类型转换 |
| 特殊值表达式 | ✅ | `SpecialValues` | NaN/Inf 表达式 |
| 非属性类成员 | ✅ | `ClassMembersNonProperty` | 非反射成员 |
| 不支持的字面量后缀 | 🚫 | `FloatLiteralUnsupportedSuffixBoundaries` | 后缀被拒 |
| `Math::NaN/Inf` 命名不支持 | 🚫 | `MathNaNInfNamesRemainUnsupported` | 名称未绑定 |

### 2.3 函数

| 场景 | 状态 | 覆盖测试方法 | 要点 / 待实现 |
|------|------|------------|-------------|
| 参数模式 value/in/out/inout | ✅ | `FunctionParametersValue/In/Out/InOut` | 四种参数模式 |
| 返回值 | ✅ | `FunctionReturnValues` | 返回路径 |
| 默认参数 / 重载 | ✅ | `FunctionDefaultParameters` `FunctionOverloading` | 默认/重载 |
| UFUNCTION 参数与返回 | ✅ | `UFunctionParametersAndReturn` | 反射调用 |

## 3. 布尔 bool（BoolProperty 6 / BoolExpression 14 / BoolFunction 9）

### 3.1 属性

| 场景 | 状态 | 覆盖测试方法 | 要点 / 待实现 |
|------|------|------------|-------------|
| 声明与默认 | ✅ | `BoolDeclarationDefaults` | 默认值 |
| 写入往返 | ✅ | `BoolWriteRoundTrip` | 读写一致 |
| 容器属性 | ✅ | `BoolContainerProperties` | TArray<bool> |
| 复制属性 | ✅ | `BoolReplicatedProperties` | Replicated |
| 说明符标志 | ✅ | `BoolPropertySpecifierFlags` | 标志位 |
| 嵌套数组属性边界 | 🚫 | `BoolNestedArrayProperties` | 嵌套被拒 |

### 3.2 表达式

| 场景 | 状态 | 覆盖测试方法 | 要点 / 待实现 |
|------|------|------------|-------------|
| 局部声明 / auto 推导 | ✅ | `LocalDeclarations` `AutoDeduction` | 声明 |
| 全局 const 声明 | ✅ | `GlobalConstDeclarations` | 全局常量 |
| 逻辑 / 相等 / 位运算 | ✅ | `LogicalOperators` `EqualityOperators` `BitwiseOperators` | 运算符 |
| 短路求值 | ✅ | `LogicalShortCircuit` | && / \|\| 短路 |
| 字面量（含大小写敏感） | ✅ | `BoolLiterals` `CaseSensitiveLiterals` | true/false |
| 转换（含 handle 转换） | ✅ | `BoolConversions` `HandleConversions` | bool 转换 |
| 控制流中的 bool | ✅ | `BoolInControlFlow` | if/while 条件 |
| 非属性类成员 | ✅ | `ClassMembersNonProperty` | 非反射成员 |
| 全局可变声明不支持 | 🚫 | `GlobalMutableDeclarationsUnsupported` | 全局可变变量被拒 |

### 3.3 函数

| 场景 | 状态 | 覆盖测试方法 | 要点 / 待实现 |
|------|------|------------|-------------|
| 参数模式 value/in/out/多 out/inout | ✅ | `FunctionParametersValue/In/Out/MultipleOut/InOut` | 参数模式 |
| 返回值 | ✅ | `FunctionReturnValues` | 返回路径 |
| 默认参数 / 重载 | ✅ | `FunctionDefaultParameters` `FunctionOverloading` | 默认/重载 |
| UFUNCTION 参数与返回 | ✅ | `UFunctionParametersAndReturn` | 反射调用 |

## 4. 字符串 FString / FName / FText（FStringProperty 12 / Expression 9 / Function 9 / Method 14）

### 4.1 属性

| 场景 | 状态 | 覆盖测试方法 | 要点 / 待实现 |
|------|------|------------|-------------|
| 声明上下文 / 家族默认 | ✅ | `StringDeclarationContexts` `StringFamilyDeclarationDefaults` | FString/FName/FText |
| 写入往返 | ✅ | `StringFamilyWriteRoundTrip` | 读写一致 |
| 脚本读写 API / 说明符 | ✅ | `StringPropertyScriptReadWriteApiSurface` `StringPropertySpecifierFlags` | 反射/标志 |
| 复制属性 | ✅ | `StringFamilyReplicatedProperties` | Replicated |
| 特殊值（空/Unicode/特殊文本） | ✅ | `StringSpecialValues` `StringFamilyScriptSpecialTextValues` | 边界文本 |
| 容器属性 / Map 键值组合 | ✅ | `StringContainerProperties` `StringFamilyMapKeyValueCombinations` | 容器元素 |
| UFUNCTION 属性往返 | ✅ | `StringUFunctionPropertyRoundTrip` | 反射往返 |
| FText 作容器哈希键边界 | 🚫 | `FTextContainerHashBoundariesRemainUnsupported` | FText 不可哈希 |

### 4.2 表达式

| 场景 | 状态 | 覆盖测试方法 | 要点 / 待实现 |
|------|------|------------|-------------|
| 局部 / 全局 const 声明 | ✅ | `LocalDeclarations` `GlobalConstDeclarations` | 声明 |
| 字符串运算符（拼接/比较） | ✅ | `StringOperators` | + / == |
| 字面量 / 转换 | ✅ | `StringLiterals` `StringConversions` | 字面量/转换 |
| FName/FText 专属操作与比较 | ✅ | `NameAndTextSpecificOperations` `NameAndTextComparisonOperators` | Name/Text 语义 |
| 非属性类成员 | ✅ | `ClassMembersNonProperty` | 非反射成员 |
| 不支持的字符串表达式边界 | 🚫 | `UnsupportedStringExpressionBoundaries` | 被拒写法 |

### 4.3 函数与方法

| 场景 | 状态 | 覆盖测试方法 | 要点 / 待实现 |
|------|------|------------|-------------|
| 参数模式 value/in/out/inout | ✅ | `FunctionParametersValue/In/Out/InOut` | 参数模式 |
| 返回值 / 默认参数 / 重载 | ✅ | `FunctionReturnValues` `FunctionDefaultParameters` `FunctionOverloading` | 函数特性 |
| UFUNCTION 参数与返回 | ✅ | `UFunctionParametersAndReturn` | 反射调用 |
| 不支持的函数签名边界 | 🚫 | `UnsupportedFunctionSignatureBoundaries` | FText literal 默认参数被拒 |
| 长度/空 判断 | ✅ | `LengthAndEmpty` | Len/IsEmpty |
| 查找 | ✅ | `SearchMethods` | Find/Contains |
| 大小写 / 裁剪 | ✅ | `CaseConversion` `TrimMethods` | ToUpper/Trim |
| 子串 / 替换 | ✅ | `SubstringMethods` `ReplaceMethods` | Mid/Replace |
| 可变字符串方法（含边界） | ✅ | `MutableStringMethods` `MutableStringEdgeCases` | Append/InsertAt |
| 分割 / ParseIntoArray | ✅ | `SplitMethods` `ParseIntoArrayDelimiterVariants` | Split |
| 格式化 / 转换 / 反转 / 数字判断 | ✅ | `FormatMethods` `ConversionMethods` `ReverseMethods` `IsNumericMethod` | 格式化等 |

---

## 汇总

| 类型 | 文件 | 方法 | 备注 |
|------|------|------|------|
| int | IntProperty/Expression/Function | 15+20+14=49 | 含 1 嵌套边界 |
| float | FloatProperty/Expression/Function | 9+12+8=29 | 含 3 边界 |
| bool | BoolProperty/Expression/Function | 6+14+9=29 | 含 2 边界 |
| FString | FStringProperty/Expression/Function/Method | 12+9+9+14=44 | 含 3 边界 |
| **合计** | **13 文件** | **151** | |

**待实现（⬜）**：当前无硬缺口；基础类型三轴覆盖成熟，不支持写法均以 🚫 负向断言固化。
