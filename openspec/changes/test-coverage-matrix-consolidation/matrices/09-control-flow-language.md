# 控制流与语言特性覆盖矩阵

> **本矩阵是控制流/语言特性测试的设计规格("头")**：每行是一个**具体可验证场景**，指导 11 个测试文件的实现。⬜＝待实现，✅ 注明覆盖它的 `TEST_METHOD`，🚫＝fork 不支持。
>
> - 测试文件：`Conditional`(10) / `Loop`(8) / `Jump`(6) / `SpecialControlFlow`(3) / `Namespace`(8) / `Comment`(1) / `Preprocessor`(7) / `TypeConversion`(6) / `Mixin`(7) / `Const`(3) / `OperatorOverload`(3) Tests.cpp
> - Automation 前缀：`Angelscript.TestModule.Coverage.<上述主题>`
> - 图例见 `../coverage-matrix.md`。

## 1. 条件（ConditionalTests 10）

| 场景 | 状态 | 覆盖测试方法 |
|------|------|------------|
| if 基础/嵌套/条件 | ✅ | `IfBasic` `IfNested` `IfConditions` |
| 三元运算符 | ✅ | `TernaryOperator` |
| switch 基础/穿透/枚举/类型 | ✅ | `SwitchBasic` `SwitchFallthrough` `SwitchEnum` `SwitchTypes` |
| switch 枚举缺 case 告警 | ✅ | `SwitchEnumMissingCaseWarns` |
| switch 不支持类型 | 🚫 | `SwitchUnsupportedTypes` |

## 2. 循环（LoopTests 8）

| 场景 | 状态 | 覆盖测试方法 / 要点 |
|------|------|------------|
| for 基础/变体/嵌套 | ✅ | `ForBasic` `ForVariations` `ForNested` |
| for-each | ✅ | `ForEach`（值/引用/const 引用、TArray/TSet、`TMapIterator` 显式迭代） |
| while / do-while | ✅ | `WhileBasic` `DoWhileBasic`（while 含 continue / 复合条件 / 嵌套；do-while 至少一次） |
| 无限循环 | ✅ | `InfiniteLoops` |
| `for (auto& Pair : TMap)` 不支持 | 🚫 | `TMapForEachPairUnsupported` |
| for-each 迭代中修改容器（迭代器失效语义） | ⬜ | 待实现（G19）：`ForEach` 仅断言 `int& Val` 元素就地修改；缺 Add/Remove 容器在迭代中修改时的运行期语义断言 |

## 3. 跳转（JumpTests 6）

| 场景 | 状态 | 覆盖测试方法 |
|------|------|------------|
| break（循环/switch） | ✅ | `BreakInLoop` `BreakInSwitch` |
| continue | ✅ | `ContinueInLoop` |
| return（提前/多返回） | ✅ | `ReturnEarly` `MultipleReturns` |
| 组合跳转 | ✅ | `CombinedJumps` |

## 4. 特殊控制流（SpecialControlFlowTests 3）

| 场景 | 状态 | 覆盖测试方法 |
|------|------|------------|
| 短路跳过右侧 | ✅ | `ShortCircuitSkipsRightHandSide` |
| for 子句中的逗号表达式编译并执行 | ✅ | `ForCommaClausesCompileAndExecute` |
| for 子句外逗号表达式不支持 | 🚫 | `CommaExpressionUnsupportedOutsideForClauses` |

## 5. 命名空间与作用域（NamespaceTests 8）

| 场景 | 状态 | 覆盖测试方法 |
|------|------|------------|
| 声明/嵌套/using/限定名 | ✅ | `NamespaceDeclaration` `NamespaceNested` `NamespaceUsing` `NamespaceQualifiedName` |
| 作用域变量/遮蔽/生命周期 | ✅ | `ScopeVariables` `ScopeShadowing` `ScopeLifecycle` |
| 命名空间内类型 | ✅ | `NamespaceWithTypes` |

## 6. 注释（CommentTests 1）

| 场景 | 状态 | 覆盖测试方法 |
|------|------|------------|
| 各注释形式编译 | ✅ | `CommentFormsCompile` |

## 7. 预处理（PreprocessorTests 7）

| 场景 | 状态 | 覆盖测试方法 |
|------|------|------------|
| import 依赖与条件分支 / 失活 import 分支被忽略 | ✅ | `ImportDependencyAndConditionalBranches` `DisabledImportBranchIsIgnored` |
| #if/#elif/#else/#endif 分支 | ✅ | `IfElifElseEndifBranches` |
| 编辑器配置标志分支 | ✅ | `EditorConfigurationFlagBranch` |
| 覆盖夹具形态汇总 | ✅ | `SummaryReportsCoverageFixtureShape` |
| 未注册的旧宏名诊断 / #include 不支持诊断 | 🚫 | `UnregisteredLegacyMacroNamesReportDiagnostics` `IncludeDirectiveReportsUnsupportedDiagnostic` |

## 8. 类型转换（TypeConversionTests 6）

| 场景 | 状态 | 覆盖测试方法 |
|------|------|------------|
| 数值/枚举/字符串转换 | ✅ | `NumericEnumAndStringConversions` |
| 对象 Cast 与类型检查 | ✅ | `ObjectCastAndTypeChecks` |
| TSubclassOf 参数与 UClass 转换 | ✅ | `TSubclassOfParameterAndUClassConversions` |
| 成员引用与可空 handle 转换 | ✅ | `MemberReferenceAndNullableHandleConversions` |
| String/Name/Text 转换往返 | ✅ | `StringNameTextConversionRoundTrips` |
| 转换负向编译 | 🚫 | `ConversionNegativeCompile` |

## 9. Mixin（MixinTests 7）

| 场景 | 状态 | 覆盖测试方法 |
|------|------|------------|
| 自由函数 mixin 分发与默认 | ✅ | `FreeFunctionMixinDispatchAndDefaults` |
| mixin 方法可组合 | ✅ | `MixinMethodsCanBeComposed` |
| 重载跨脚本继承解析 / 冲突解析用显式基类接收者 | ✅ | `MixinOverloadsResolveAcrossScriptInheritance` `MixinConflictResolutionUsesExplicitBaseReceiverView` |
| mixin 虚调用分发到重写 / 读写 UPROPERTY 边界 | ✅ | `MixinDispatchesVirtualCallsToOverrides` `MixinReadsAndWritesUPropertyBoundaries` |
| mixin class 语法被拒 | 🚫 | `MixinClassSyntaxRejected` |

## 10. const（ConstTests 3）

| 场景 | 状态 | 覆盖测试方法 |
|------|------|------------|
| const 值/方法/引用 | ✅ | `ConstValuesMethodsAndReferences` |
| const UFUNCTION 与属性反射 | ✅ | `ConstUFunctionAndPropertyReflection` |
| const 违例负向编译 | 🚫 | `ConstViolationNegativeCompile` |

## 11. 运算符重载（OperatorOverloadTests 3）

| 场景 | 状态 | 覆盖测试方法 |
|------|------|------------|
| 算术/比较/赋值运算符 | ✅ | `ArithmeticComparisonAndAssignmentOperators` |
| 一元/索引/转换运算符 | ✅ | `UnaryIndexAndConversionOperators` |
| 运算符负向编译 | 🚫 | `OperatorNegativeCompile` |

---

## 汇总

| 文件 | 方法 |
|------|------|
| Conditional | 10 |
| Loop | 8 |
| Jump | 6 |
| SpecialControlFlow | 3 |
| Namespace | 8 |
| Comment | 1 |
| Preprocessor | 7 |
| TypeConversion | 6 |
| Mixin | 7 |
| Const | 3 |
| OperatorOverload | 3 |
| **合计** | **63** |

**待实现（⬜）**（2026-06-30 深审新增，**非阻塞**；编号为 `coverage-gaps.md §1` 全局 G 编号）：

- `G19` ⬜ for-each 迭代中修改容器（迭代器失效语义）：现 `ForEach` 仅断言 `int& Val` 元素就地修改；缺 Add/Remove 容器在迭代中修改时的运行期语义断言。

> 其余语言特性覆盖成熟，不支持写法均以 🚫 负向断言固化。
