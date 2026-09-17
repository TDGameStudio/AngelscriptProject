# Operators migration

| FileTag | Disposition | Legacy sources |
| --- | --- | --- |
| `Language/Operators/Arithmetic` | adapted language forms; host observers excluded | `TestSource-old/Language/Operators/Arithmetic/Function/ArithmeticOperators.as` |
| `Language/Operators/Assignment` | adapted language forms; host observers excluded | `TestSource-old/Language/Operators/Assignment/Function/AssignmentOperators.as` |
| `Language/Operators/DefiniteAssignment` | adapted language forms; host observers excluded | `TestSource-old/Language/Operators/Assignment/Function/BranchDefiniteAssignment.as`; `TestSource-old/Language/Operators/Assignment/Function/PartialDefiniteAssignment.as` |
| `Language/Operators/Bitwise` | adapted language forms; host observers excluded | `TestSource-old/Language/Operators/Bitwise/Function/BitwiseOperators.as` |
| `Language/Operators/Comparison` | adapted language forms; host observers excluded | `TestSource-old/Language/Operators/Comparison/Function/ComparisonOperators.as` |
| `Language/Operators/Logical` | adapted language forms; host observers excluded | `TestSource-old/Language/Operators/Logical/Function/LogicalOperators.as` |
| `Language/Operators/Ternary` | adapted language forms; host observers excluded | `TestSource-old/Language/Operators/Ternary/Function/TernaryOperators.as` |
| `Language/Operators/Precedence` | adapted language forms; host observers excluded | `TestSource-old/Language/Operators/Advance/ExpressionPrecedenceChains.as` |
| `Language/Operators/ExpressionEdges` | adapted language forms; host observers excluded | `TestSource-old/Language/Operators/Arithmetic/Function/ExpressionEdgeCases.as` |
| `Language/Operators/Overload` | adapted language forms; host observers excluded | `TestSource-old/Language/Operators/Overload/Function/FValCmpOverload.as`; `TestSource-old/Language/Operators/Overload/Function/FVecAddAssignOverload.as`; `TestSource-old/Language/Operators/Overload/Function/FVecAddOverload.as`; `TestSource-old/Language/Operators/Overload/Function/FVecEqualsOverload.as`; `TestSource-old/Language/Operators/Overload/Function/FVecMulOverload.as`; `TestSource-old/Language/Operators/Overload/Function/FVecNegOverload.as`; `TestSource-old/Language/Operators/Overload/Function/FVecSubOverload.as`; `TestSource-old/Language/Operators/Overload/Function/FVecUsageOverload.as`; `TestSource-old/Language/Operators/Overload/Function/ScoreOperatorSuite.as` |

## Theme exclusions

- Dropped `UFUNCTION` Observe helpers, namespace test wrappers, and UE types (`FString`, `FQuat`, `UEnum`, `TArray`).
- Reject files that only encode host diagnostics stay excluded; language-illegal forms are `invalid-*` children of `root`.
- Preprocessor and comment-literal versions may carry `SourceOnly`; admission is not compilation.
