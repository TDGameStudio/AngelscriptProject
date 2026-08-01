# Control Flow And Language Features Coverage Matrix

> **This matrix is the design specification header for control-flow / language-feature tests**: each row is a concrete verifiable scenario guiding 11 test files. ⬜ means pending, ✅ identifies the covering `TEST_METHOD`, and 🚫 means fork unsupported.
>
> - Test files: `Conditional`(10) / `Loop`(9) / `Jump`(6) / `SpecialControlFlow`(3) / `Namespace`(8) / `Comment`(1) / `Preprocessor`(7) / `TypeConversion`(6) / `Mixin`(7) / `Const`(3) / `OperatorOverload`(3) Tests.cpp
> - Automation prefix: `Angelscript.TestModule.Coverage.<topic>`
> - See `../coverage-matrix.md` for the legend.

## 1. Conditionals, ConditionalTests 10

| Scenario | Status | Coverage Test Method |
|------|------|------------|
| if basics / nesting / conditions | ✅ | `IfBasic` `IfNested` `IfConditions` |
| Ternary operator | ✅ | `TernaryOperator` |
| switch basics / fallthrough / enum / types | ✅ | `SwitchBasic` `SwitchFallthrough` `SwitchEnum` `SwitchTypes` |
| switch enum missing case warning | ✅ | `SwitchEnumMissingCaseWarns` |
| switch unsupported types | 🚫 | `SwitchUnsupportedTypes` |

## 2. Loops, LoopTests 8

| Scenario | Status | Coverage Test Method / Notes |
|------|------|------------|
| for basics / variants / nesting | ✅ | `ForBasic` `ForVariations` `ForNested` |
| for-each | ✅ | `ForEach`, value/reference/const reference, TArray/TSet, explicit `TMapIterator` iteration |
| while / do-while | ✅ | `WhileBasic` `DoWhileBasic`, while includes continue / compound conditions / nesting; do-while runs at least once |
| infinite loops | ✅ | `InfiniteLoops` |
| `for (auto& Pair : TMap)` unsupported | 🚫 | `TMapForEachPairUnsupported` |
| Mutating containers during for-each iteration | 🟡 | `ForEachContainerMutationSurface` locks compile reachability; runtime invalidation semantics remain a deliberate follow-up assertion surface |

## 3. Jumps, JumpTests 6

| Scenario | Status | Coverage Test Method |
|------|------|------------|
| break, loop/switch | ✅ | `BreakInLoop` `BreakInSwitch` |
| continue | ✅ | `ContinueInLoop` |
| return, early/multiple returns | ✅ | `ReturnEarly` `MultipleReturns` |
| combined jumps | ✅ | `CombinedJumps` |

## 4. Special Control Flow, SpecialControlFlowTests 3

| Scenario | Status | Coverage Test Method |
|------|------|------------|
| Short-circuit skips right-hand side | ✅ | `ShortCircuitSkipsRightHandSide` |
| Comma expression in for clauses compiles and executes | ✅ | `ForCommaClausesCompileAndExecute` |
| Comma expression outside for clauses unsupported | 🚫 | `CommaExpressionUnsupportedOutsideForClauses` |

## 5. Namespaces And Scope, NamespaceTests 8

| Scenario | Status | Coverage Test Method |
|------|------|------------|
| Declaration / nesting / using / qualified names | ✅ | `NamespaceDeclaration` `NamespaceNested` `NamespaceUsing` `NamespaceQualifiedName` |
| Scope variables / shadowing / lifecycle | ✅ | `ScopeVariables` `ScopeShadowing` `ScopeLifecycle` |
| Types inside namespaces | ✅ | `NamespaceWithTypes` |

## 6. Comments, CommentTests 1

| Scenario | Status | Coverage Test Method |
|------|------|------------|
| Comment forms compile | ✅ | `CommentFormsCompile` |

## 7. Preprocessor, PreprocessorTests 7

| Scenario | Status | Coverage Test Method |
|------|------|------------|
| import dependency and conditional branches / disabled import branch ignored | ✅ | `ImportDependencyAndConditionalBranches` `DisabledImportBranchIsIgnored` |
| #if/#elif/#else/#endif branches | ✅ | `IfElifElseEndifBranches` |
| Editor configuration flag branch | ✅ | `EditorConfigurationFlagBranch` |
| Coverage fixture shape summary | ✅ | `SummaryReportsCoverageFixtureShape` |
| Unregistered legacy macro name diagnostics / #include unsupported diagnostic | 🚫 | `UnregisteredLegacyMacroNamesReportDiagnostics` `IncludeDirectiveReportsUnsupportedDiagnostic` |

## 8. Type Conversion, TypeConversionTests 6

| Scenario | Status | Coverage Test Method |
|------|------|------------|
| Numeric / enum / string conversions | ✅ | `NumericEnumAndStringConversions` |
| Object Cast and type checks | ✅ | `ObjectCastAndTypeChecks` |
| TSubclassOf parameters and UClass conversions | ✅ | `TSubclassOfParameterAndUClassConversions` |
| Member references and nullable handle conversions | ✅ | `MemberReferenceAndNullableHandleConversions` |
| String/Name/Text conversion round trips | ✅ | `StringNameTextConversionRoundTrips` |
| Negative compile conversion cases | 🚫 | `ConversionNegativeCompile` |

## 9. Mixin, MixinTests 7

| Scenario | Status | Coverage Test Method |
|------|------|------------|
| Free function mixin dispatch and defaults | ✅ | `FreeFunctionMixinDispatchAndDefaults` |
| Mixin methods can be composed | ✅ | `MixinMethodsCanBeComposed` |
| Overloads resolve across script inheritance / conflict resolution uses explicit base receiver | ✅ | `MixinOverloadsResolveAcrossScriptInheritance` `MixinConflictResolutionUsesExplicitBaseReceiverView` |
| Mixin virtual calls dispatch to overrides / read and write UPROPERTY boundaries | ✅ | `MixinDispatchesVirtualCallsToOverrides` `MixinReadsAndWritesUPropertyBoundaries` |
| mixin class syntax rejected | 🚫 | `MixinClassSyntaxRejected` |

## 10. const, ConstTests 3

| Scenario | Status | Coverage Test Method |
|------|------|------------|
| const values / methods / references | ✅ | `ConstValuesMethodsAndReferences` |
| const UFUNCTION and property reflection | ✅ | `ConstUFunctionAndPropertyReflection` |
| const violation negative compile | 🚫 | `ConstViolationNegativeCompile` |

## 11. Operator Overload, OperatorOverloadTests 3

| Scenario | Status | Coverage Test Method |
|------|------|------------|
| Arithmetic / comparison / assignment operators | ✅ | `ArithmeticComparisonAndAssignmentOperators` |
| Unary / index / conversion operators | ✅ | `UnaryIndexAndConversionOperators` |
| Operator negative compile | 🚫 | `OperatorNegativeCompile` |

---

## Summary

| File | Methods |
|------|------|
| Conditional | 10 |
| Loop | 9 |
| Jump | 6 |
| SpecialControlFlow | 3 |
| Namespace | 8 |
| Comment | 1 |
| Preprocessor | 7 |
| TypeConversion | 6 |
| Mixin | 7 |
| Const | 3 |
| OperatorOverload | 3 |
| **Total** | **64** |

**Implementation status**: `G19` is represented by `ForEachContainerMutationSurface`; it records compile reachability and keeps the runtime invalidation expectation explicit for a later semantics-focused pass.

> The remaining language feature coverage is mature, and unsupported forms are locked through 🚫 negative assertions.
