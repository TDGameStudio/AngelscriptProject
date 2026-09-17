# ControlFlow migration

| FileTag | Disposition | Legacy sources |
| --- | --- | --- |
| `Language/ControlFlow/If` | adapted language forms; host observers excluded | `TestSource-old/Language/ControlFlow/Function/IfBasic.as`; `TestSource-old/Language/ControlFlow/Function/IfConditions.as` |
| `Language/ControlFlow/IfElse` | adapted language forms; host observers excluded | `TestSource-old/Language/ControlFlow/Function/IfElseForms.as` |
| `Language/ControlFlow/IfNested` | adapted language forms; host observers excluded | `TestSource-old/Language/ControlFlow/Function/IfNested.as` |
| `Language/ControlFlow/While` | adapted language forms; host observers excluded | `TestSource-old/Language/ControlFlow/Function/DoWhileLoop.as`; `TestSource-old/Language/ControlFlow/Function/WhileLoop.as` |
| `Language/ControlFlow/DoWhile` | adapted language forms; host observers excluded | `TestSource-old/Language/ControlFlow/Function/DoWhileLoop.as` |
| `Language/ControlFlow/Switch` | adapted language forms; host observers excluded | `TestSource-old/Language/ControlFlow/Function/SwitchBasic.as`; `TestSource-old/Language/ControlFlow/Function/SwitchBreak.as`; `TestSource-old/Language/ControlFlow/Function/SwitchEnum.as`; `TestSource-old/Language/ControlFlow/Function/SwitchIntegerTypes.as` |
| `Language/ControlFlow/LoopJump` | adapted language forms; host observers excluded | `TestSource-old/Language/ControlFlow/Function/BreakInLoop.as`; `TestSource-old/Language/ControlFlow/Function/ContinueInLoop.as` |
| `Language/ControlFlow/Return` | adapted language forms; host observers excluded | `TestSource-old/Language/ControlFlow/Function/FMatrixReturnApi.as`; `TestSource-old/Language/ControlFlow/Function/FunctionReturnBoolValues.as`; `TestSource-old/Language/ControlFlow/Function/FunctionReturnControlFlow.as`; `TestSource-old/Language/ControlFlow/Function/FunctionReturnFloatValues.as`; `TestSource-old/Language/ControlFlow/Function/FunctionReturnIntegerWidths.as`; `TestSource-old/Language/ControlFlow/Function/FunctionReturnQuatValues.as`; `TestSource-old/Language/ControlFlow/Function/GeometricStructParametersAndReturns.as`; `TestSource-old/Language/ControlFlow/Function/MultipleReturns.as`; `TestSource-old/Language/ControlFlow/Function/ReturnEarly.as`; `TestSource-old/Language/ControlFlow/Function/ReturnExpression.as`; `TestSource-old/Language/ControlFlow/Function/ReturnFloatAsInt.as`; `TestSource-old/Language/ControlFlow/Function/ReturnInt.as`; `TestSource-old/Language/ControlFlow/Function/ReturnVoid.as` |
| `Language/ControlFlow/Foreach` | adapted language forms; host observers excluded | `TestSource-old/Language/ControlFlow/Function/ForeachBreakContinue.as`; `TestSource-old/Language/ControlFlow/Function/ForeachContainerMutation.as`; `TestSource-old/Language/ControlFlow/Function/ForeachValueReference.as` |

## Theme exclusions

- Dropped `UFUNCTION` Observe helpers, namespace test wrappers, and UE types (`FString`, `FQuat`, `UEnum`, `TArray`).
- Reject files that only encode host diagnostics stay excluded; language-illegal forms are `invalid-*` children of `root`.
- Preprocessor and comment-literal versions may carry `SourceOnly`; admission is not compilation.
