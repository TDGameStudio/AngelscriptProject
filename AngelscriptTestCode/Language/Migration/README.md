# Language fixture migration census

Disposition for every inspected `TestSource-old/Language` source. Byte equality is against migrated container clean source, not these 624 wrappers.

Legacy files: 624. Accepted FileTags: 47.

| Legacy path | Disposition | Destination | Reason |
| --- | --- | --- | --- |
| `TestSource-old/Language/Casting/Function/CastDowncast.as` | adapted | `Language/Casting/ClassCast` | anchor for Language/Casting/ClassCast; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/Casting/Function/CastNullptrIsNull.as` | adapted | `Language/Casting/Nullptr` | anchor for Language/Casting/Nullptr; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/Casting/Function/CastRoundTripWithNullCheck.as` | adapted | `Language/Casting/ClassCast` | anchor for Language/Casting/ClassCast; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/Casting/Function/CastToParentClass.as` | adapted | `Language/Casting/ClassCast` | anchor for Language/Casting/ClassCast; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/Casting/Function/ExplicitFloatToInt.as` | adapted | `Language/Casting/NumericExplicit` | anchor for Language/Casting/NumericExplicit; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/Casting/Function/ExplicitIntToFloat.as` | adapted | `Language/Casting/NumericExplicit` | anchor for Language/Casting/NumericExplicit; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/Casting/Function/ExplicitIntToUint8.as` | adapted | `Language/Casting/NumericExplicit` | anchor for Language/Casting/NumericExplicit; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/Casting/Function/FStringCaseConversion.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Casting/Function/FStringConversionMethods.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Casting/Function/ImplicitBoolToInt.as` | adapted | `Language/Casting/NumericImplicit` | anchor for Language/Casting/NumericImplicit; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/Casting/Function/ImplicitDerivedToBase.as` | adapted | `Language/Casting/NumericImplicit` | anchor for Language/Casting/NumericImplicit; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/Casting/Function/ImplicitFloatToInt.as` | adapted | `Language/Casting/NumericImplicit` | anchor for Language/Casting/NumericImplicit; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/Casting/Function/ImplicitFloatToUint8.as` | adapted | `Language/Casting/NumericImplicit` | anchor for Language/Casting/NumericImplicit; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/Casting/Function/ImplicitInt64ToInt.as` | adapted | `Language/Casting/NumericImplicit` | anchor for Language/Casting/NumericImplicit; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/Casting/Function/ImplicitIntToFloat.as` | adapted | `Language/Casting/NumericImplicit` | anchor for Language/Casting/NumericImplicit; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/Casting/Function/ImplicitIntToInt64.as` | adapted | `Language/Casting/NumericImplicit` | anchor for Language/Casting/NumericImplicit; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/Casting/Function/ImplicitLiteralToFloat.as` | adapted | `Language/Casting/NumericImplicit` | anchor for Language/Casting/NumericImplicit; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/Casting/Function/ImplicitUint8ToInt.as` | adapted | `Language/Casting/NumericImplicit` | anchor for Language/Casting/NumericImplicit; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/Casting/Function/NullptrComparison.as` | adapted | `Language/Casting/Nullptr` | anchor for Language/Casting/Nullptr; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/Casting/Function/NullptrHandleAssignment.as` | adapted | `Language/Casting/Nullptr` | anchor for Language/Casting/Nullptr; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/Casting/Function/NumericEnumAndStringConversions.as` | adapted | `Language/Casting/NumericImplicit` | anchor for Language/Casting/NumericImplicit; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/Casting/Function/StringNameTextConversions.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Casting/Function/UnaryIndexAndConversionOperators.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Casting/Reject/CastBetweenUnrelatedTypes.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Casting/Reject/CastNullptrAsRvalue.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Casting/Reject/CastOnPrimitive.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Casting/Reject/CastResultAssignment.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Casting/Reject/CastToEnum.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Casting/Reject/CastToStruct.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Casting/Reject/CastToUndeclaredClass.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Casting/Reject/CastWithTwoArguments.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Casting/Reject/CastWithTwoTemplateArguments.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Casting/Reject/CastWithoutArgument.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Casting/Reject/CastWithoutTemplateArgument.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Casting/Reject/ExplicitActorToInt.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Casting/Reject/ExplicitBoolToFString.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Casting/Reject/ExplicitMultipleArguments.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Casting/Reject/ExplicitStringToInt.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Casting/Reject/ExplicitToVoid.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Casting/Reject/ImplicitArrayToInt.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Casting/Reject/ImplicitBaseToDerived.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Casting/Reject/ImplicitIntToBool.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Casting/Reject/ImplicitStringToInt.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Casting/Reject/ImplicitVectorToRotator.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Casting/Reject/NullptrArithmetic.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Casting/Reject/NullptrToBool.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Casting/Reject/NullptrToFloat.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Casting/Reject/NullptrToInt.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Casting/Reject/NullptrToStruct.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Casting/UClass/ObjectCastAndTypeChecks.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Casting/UClass/StringNameTextConversionRoundTrips.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Const/Reject/ConstLocalMutation.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Const/Reject/ConstMethodMemberMutation.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Const/Reject/ConstValueParameterMutation.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/ControlFlow/Function/BreakInLoop.as` | adapted | `Language/ControlFlow/LoopJump` | anchor for Language/ControlFlow/LoopJump; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/ControlFlow/Function/ContinueInLoop.as` | adapted | `Language/ControlFlow/LoopJump` | anchor for Language/ControlFlow/LoopJump; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/ControlFlow/Function/DoWhileLoop.as` | adapted | `Language/ControlFlow/While` | anchor for Language/ControlFlow/While; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/ControlFlow/Function/FMatrixReturnApi.as` | adapted | `Language/ControlFlow/Return` | anchor for Language/ControlFlow/Return; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/ControlFlow/Function/ForeachBreakContinue.as` | adapted | `Language/ControlFlow/Foreach` | anchor for Language/ControlFlow/Foreach; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/ControlFlow/Function/ForeachContainerMutation.as` | adapted | `Language/ControlFlow/Foreach` | anchor for Language/ControlFlow/Foreach; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/ControlFlow/Function/ForeachValueReference.as` | adapted | `Language/ControlFlow/Foreach` | anchor for Language/ControlFlow/Foreach; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/ControlFlow/Function/FunctionReturnBoolValues.as` | adapted | `Language/ControlFlow/Return` | anchor for Language/ControlFlow/Return; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/ControlFlow/Function/FunctionReturnControlFlow.as` | adapted | `Language/ControlFlow/Return` | anchor for Language/ControlFlow/Return; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/ControlFlow/Function/FunctionReturnFloatValues.as` | adapted | `Language/ControlFlow/Return` | anchor for Language/ControlFlow/Return; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/ControlFlow/Function/FunctionReturnIntegerWidths.as` | adapted | `Language/ControlFlow/Return` | anchor for Language/ControlFlow/Return; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/ControlFlow/Function/FunctionReturnQuatValues.as` | adapted | `Language/ControlFlow/Return` | anchor for Language/ControlFlow/Return; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/ControlFlow/Function/GeometricStructParametersAndReturns.as` | adapted | `Language/ControlFlow/Return` | anchor for Language/ControlFlow/Return; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/ControlFlow/Function/IfBasic.as` | adapted | `Language/ControlFlow/If` | anchor for Language/ControlFlow/If; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/ControlFlow/Function/IfConditions.as` | adapted | `Language/ControlFlow/If` | anchor for Language/ControlFlow/If; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/ControlFlow/Function/IfElseForms.as` | adapted | `Language/ControlFlow/IfElse` | anchor for Language/ControlFlow/IfElse; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/ControlFlow/Function/IfNested.as` | adapted | `Language/ControlFlow/IfNested` | anchor for Language/ControlFlow/IfNested; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/ControlFlow/Function/MultipleReturns.as` | adapted | `Language/ControlFlow/Return` | anchor for Language/ControlFlow/Return; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/ControlFlow/Function/ReturnEarly.as` | adapted | `Language/ControlFlow/Return` | anchor for Language/ControlFlow/Return; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/ControlFlow/Function/ReturnExpression.as` | adapted | `Language/ControlFlow/Return` | anchor for Language/ControlFlow/Return; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/ControlFlow/Function/ReturnFloatAsInt.as` | adapted | `Language/ControlFlow/Return` | anchor for Language/ControlFlow/Return; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/ControlFlow/Function/ReturnInt.as` | adapted | `Language/ControlFlow/Return` | anchor for Language/ControlFlow/Return; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/ControlFlow/Function/ReturnVoid.as` | adapted | `Language/ControlFlow/Return` | anchor for Language/ControlFlow/Return; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/ControlFlow/Function/SwitchBasic.as` | adapted | `Language/ControlFlow/Switch` | anchor for Language/ControlFlow/Switch; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/ControlFlow/Function/SwitchBreak.as` | adapted | `Language/ControlFlow/Switch` | anchor for Language/ControlFlow/Switch; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/ControlFlow/Function/SwitchEnum.as` | adapted | `Language/ControlFlow/Switch` | anchor for Language/ControlFlow/Switch; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/ControlFlow/Function/SwitchIntegerTypes.as` | adapted | `Language/ControlFlow/Switch` | anchor for Language/ControlFlow/Switch; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/ControlFlow/Function/TernaryOperator.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/ControlFlow/Function/WhileLoop.as` | adapted | `Language/ControlFlow/While` | anchor for Language/ControlFlow/While; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/ControlFlow/Reject/BreakInFunctionCalledFromLoop.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/ControlFlow/Reject/BreakInsideIfWithoutLoop.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/ControlFlow/Reject/BreakOutsideLoop.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/ControlFlow/Reject/CaseOutsideSwitch.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/ControlFlow/Reject/ContinueInsideIfWithoutLoop.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/ControlFlow/Reject/ContinueOutsideLoop.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/ControlFlow/Reject/DoWhileIntegerCondition.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/ControlFlow/Reject/DoWhileMissingSemicolon.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/ControlFlow/Reject/ElseWithoutIf.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/ControlFlow/Reject/ForeachElementTypeMismatch.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/ControlFlow/Reject/ForeachMissingColon.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/ControlFlow/Reject/ForeachOverIntegerLiteral.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/ControlFlow/Reject/ForeachOverPrimitive.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/ControlFlow/Reject/ForeachOverStringLiteral.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/ControlFlow/Reject/IfEmptyCondition.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/ControlFlow/Reject/IfFloatCondition.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/ControlFlow/Reject/IfIntegerCondition.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/ControlFlow/Reject/IfStringCondition.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/ControlFlow/Reject/IfUnparenthesizedCondition.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/ControlFlow/Reject/IfVariableIntegerCondition.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/ControlFlow/Reject/ReturnStringForInt.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/ControlFlow/Reject/ReturnValueInVoidFunction.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/ControlFlow/Reject/ReturnWithoutValueInIntFunction.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/ControlFlow/Reject/SwitchDuplicateCase.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/ControlFlow/Reject/SwitchDuplicateDefault.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/ControlFlow/Reject/SwitchFloatCaseLabel.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/ControlFlow/Reject/SwitchOverBool.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/ControlFlow/Reject/SwitchOverFName.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/ControlFlow/Reject/SwitchStringCaseLabel.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/ControlFlow/Reject/SwitchVariableCaseLabel.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/ControlFlow/Reject/SwitchWithoutBraces.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/ControlFlow/Reject/WhileEmptyCondition.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/ControlFlow/Reject/WhileIntegerCondition.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/ControlFlow/Reject/WhileUnparenthesizedCondition.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/ControlFlow/Reject/WhileVariableCondition.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/ControlFlow/UClass/ContainerAsReturnValue.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Literals/FString/Exception/ClassMembersNonProperty.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Literals/FString/Function/EmptyStringLiteral.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Literals/FString/Function/FNameLiteral.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Literals/FString/Function/FStringInterpolatesExpression.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Literals/FString/Function/FStringInterpolatesInt.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Literals/FString/Function/FStringInterpolatesMultipleTypes.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Literals/FString/Function/FormatMethods.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Literals/FString/Function/FormatStringRewriteProducesExpectedOutput.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Literals/FString/Function/FunctionDefaultParameters.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Literals/FString/Function/FunctionOverloading.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Literals/FString/Function/FunctionParametersIn.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Literals/FString/Function/FunctionParametersInOut.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Literals/FString/Function/FunctionParametersOut.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Literals/FString/Function/FunctionParametersValue.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Literals/FString/Function/FunctionReturnValues.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Literals/FString/Function/GlobalConstDeclarations.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Literals/FString/Function/IsNumericMethod.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Literals/FString/Function/LengthAndEmpty.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Literals/FString/Function/LocalDeclarations.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Literals/FString/Function/MutableStringEdgeCases.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Literals/FString/Function/MutableStringMethods.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Literals/FString/Function/NameAndTextComparisonOperators.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Literals/FString/Function/NameAndTextSpecificOperations.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Literals/FString/Function/ReplaceMethods.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Literals/FString/Function/ReverseMethods.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Literals/FString/Function/SearchMethods.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Literals/FString/Function/SplitMethods.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Literals/FString/Function/StringConcatenationPlus.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Literals/FString/Function/StringConcatenationPlusAssign.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Literals/FString/Function/StringDeclarationContexts.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Literals/FString/Function/StringEqualityOperator.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Literals/FString/Function/StringInequalityOperator.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Literals/FString/Function/StringLiteralAssignment.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Literals/FString/Function/StringLiterals.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Literals/FString/Function/StringOperators.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Literals/FString/Function/SubstringMethods.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Literals/FString/Function/TrimMethods.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Literals/FString/Reject/EmptyNameLiteral.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Literals/FString/Reject/EscapedInterpolationBraces.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Literals/FString/Reject/FCStringAtof.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Literals/FString/Reject/FCStringAtoi.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Literals/FString/Reject/FNameFromInt.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Literals/FString/Reject/FNameOrderingOperator.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Literals/FString/Reject/FStringComparedToInt.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Literals/FString/Reject/FTextDefaultLiteralRejected.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Literals/FString/Reject/FTextEqualityOperator.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Literals/FString/Reject/FTextMapKeyRejected.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Literals/FString/Reject/FTextOrderingOperator.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Literals/FString/Reject/FTextSetElementRejected.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Literals/FString/Reject/IntToFStringAssignment.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Literals/FString/Reject/MutableGlobalFString.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Literals/FString/Reject/NullptrToFStringAssignment.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Literals/FString/Reject/StringBitwiseAnd.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Literals/FString/Reject/StringDivision.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Literals/FString/Reject/StringMultiplication.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Literals/FString/Reject/StringSubtraction.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Literals/FString/Reject/StringToFloatMethod.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Literals/FString/Reject/StringToIntMethod.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Literals/FString/Reject/UnclosedInterpolationBrace.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Literals/FString/Reject/UnterminatedStringLiteral.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Literals/FString/UClass/DefaultFStringPropertyApplied.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Literals/FString/UClass/FStringInterpolationAndFNameLiteralRuntimeValues.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Literals/FString/UClass/StringContainerProperties.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Literals/FString/UClass/StringFamilyDeclarationDefaults.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Literals/FString/UClass/StringFamilyReplicatedProperties.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Literals/FString/UClass/StringFamilyScriptSpecialTextValues.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Literals/FString/UClass/StringFamilyWriteRoundTrip.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Literals/FString/UClass/StringPropertyScriptReadWriteApiSurface.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Literals/FString/UClass/StringSpecialValues.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Namespace/Exception/NamespacedScriptClassLocal.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Namespace/Function/NamespaceGlobalVersusScoped.as` | adapted | `Language/Namespace/GlobalVersusScoped` | anchor for Language/Namespace/GlobalVersusScoped; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/Namespace/Function/NamespaceNestedAccess.as` | adapted | `Language/Namespace/Nested` | anchor for Language/Namespace/Nested; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/Namespace/Function/NamespaceNestedScope.as` | adapted | `Language/Namespace/Nested` | anchor for Language/Namespace/Nested; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/Namespace/Function/NamespaceQualifiedCall.as` | adapted | `Language/Namespace/QualifiedName` | anchor for Language/Namespace/QualifiedName; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/Namespace/Function/NamespaceQualifiedName.as` | adapted | `Language/Namespace/QualifiedName` | anchor for Language/Namespace/QualifiedName; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/Namespace/Function/NamespaceScopeShadowing.as` | adapted | `Language/Namespace/Shadowing` | anchor for Language/Namespace/Shadowing; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/Namespace/Function/NamespaceScopedGlobal.as` | adapted | `Language/Namespace/GlobalVersusScoped` | anchor for Language/Namespace/GlobalVersusScoped; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/Namespace/Function/NamespaceWithEnum.as` | adapted | `Language/Namespace/Enum` | anchor for Language/Namespace/Enum; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/Namespace/Function/NamespacedAnnotatedClassStaticHelper.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Namespace/Reject/NamespaceAnonymous.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Namespace/Reject/NamespaceMissingMember.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Namespace/Reject/NamespaceUndeclared.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Namespace/Reject/NamespaceUsingDirective.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Namespace/Reject/NamespaceUsingSymbol.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Namespace/UClass/NamespaceScopeLifecycle.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Operators/Advance/BitmaskProtocol.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Operators/Advance/ExpressionPrecedenceChains.as` | adapted | `Language/Operators/Precedence` | anchor for Language/Operators/Precedence; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/Operators/Arithmetic/Exception/IntegerDivisionFaults.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Operators/Arithmetic/Function/ArithmeticOperators.as` | adapted | `Language/Operators/Arithmetic` | anchor for Language/Operators/Arithmetic; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/Operators/Arithmetic/Function/ColorAndRandomStreamExpressions.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Operators/Arithmetic/Function/ExpressionEdgeCases.as` | adapted | `Language/Operators/ExpressionEdges` | anchor for Language/Operators/ExpressionEdges; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/Operators/Arithmetic/Reject/ArithmeticMissingRightOperand.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Operators/Arithmetic/Reject/AssignToExpressionResult.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Operators/Arithmetic/Reject/BoolAddition.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Operators/Arithmetic/Reject/CommaExpressionOutsideForClause.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Operators/Arithmetic/Reject/DoubleOperatorInExpression.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Operators/Arithmetic/Reject/EmptyParenthesesAsValue.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Operators/Arithmetic/Reject/FloatModulo.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Operators/Arithmetic/Reject/IncrementOnConst.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Operators/Arithmetic/Reject/IncrementOnLiteral.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Operators/Arithmetic/Reject/LeadingBinaryOperator.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Operators/Arithmetic/Reject/StringPlusInt.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Operators/Arithmetic/Reject/StringTimesInt.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Operators/Arithmetic/Reject/TrailingOperator.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Operators/Arithmetic/Reject/UnaryPlusOnString.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Operators/Arithmetic/Reject/UnmatchedParenthesis.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Operators/Assignment/Function/AssignmentOperators.as` | adapted | `Language/Operators/Assignment` | anchor for Language/Operators/Assignment; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/Operators/Assignment/Function/BranchDefiniteAssignment.as` | adapted | `Language/Operators/DefiniteAssignment` | anchor for Language/Operators/DefiniteAssignment; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/Operators/Assignment/Function/PartialDefiniteAssignment.as` | adapted | `Language/Operators/DefiniteAssignment` | anchor for Language/Operators/DefiniteAssignment; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/Operators/Assignment/Reject/AddAssignStringToInt.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Operators/Assignment/Reject/AssignmentToConst.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Operators/Assignment/Reject/AssignmentToExpression.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Operators/Assignment/Reject/AssignmentToFunctionReturn.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Operators/Assignment/Reject/AssignmentToLiteral.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Operators/Assignment/Reject/AssignmentToUndeclaredVariable.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Operators/Assignment/Reject/ModAssignOnFloat.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Operators/Assignment/Reject/ShiftAssignOnFloat.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Operators/Assignment/Reject/StringAssignedToInt.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Operators/Bitwise/Function/BitwiseOperators.as` | adapted | `Language/Operators/Bitwise` | anchor for Language/Operators/Bitwise; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/Operators/Bitwise/Reject/BitwiseAndMissingOperand.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Operators/Bitwise/Reject/BitwiseAndOnFloat.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Operators/Bitwise/Reject/BitwiseNotOnString.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Operators/Bitwise/Reject/BitwiseOrOnFloat.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Operators/Bitwise/Reject/BitwiseXorOnBool.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Operators/Bitwise/Reject/ShiftOnFloat.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Operators/Bitwise/Reject/ShiftOnString.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Operators/Comparison/Function/ComparisonOperators.as` | adapted | `Language/Operators/Comparison` | anchor for Language/Operators/Comparison; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/Operators/Comparison/Reject/BooleanOrderingComparison.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Operators/Comparison/Reject/CompareStringToInt.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Operators/Comparison/Reject/ComparisonMissingRightOperand.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Operators/Comparison/Reject/TripleEqualsOperator.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Operators/Comparison/Reject/VectorOrderingComparison.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Operators/Comparison/UClass/HandleComparison.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Operators/Logical/Function/LogicalOperators.as` | adapted | `Language/Operators/Logical` | anchor for Language/Operators/Logical; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/Operators/Logical/Reject/LogicalAndOnFloats.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Operators/Logical/Reject/LogicalAndOnIntegers.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Operators/Logical/Reject/LogicalMissingRightOperand.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Operators/Logical/Reject/LogicalNotOnInteger.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Operators/Logical/Reject/LogicalOrOnStrings.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Operators/Logical/Reject/TripleAmpersandOperator.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Operators/Overload/Function/ContainerOpIndex.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Operators/Overload/Function/FValCmpOverload.as` | adapted | `Language/Operators/Overload` | anchor for Language/Operators/Overload; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/Operators/Overload/Function/FVecAddAssignOverload.as` | adapted | `Language/Operators/Overload` | anchor for Language/Operators/Overload; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/Operators/Overload/Function/FVecAddOverload.as` | adapted | `Language/Operators/Overload` | anchor for Language/Operators/Overload; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/Operators/Overload/Function/FVecEqualsOverload.as` | adapted | `Language/Operators/Overload` | anchor for Language/Operators/Overload; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/Operators/Overload/Function/FVecMulOverload.as` | adapted | `Language/Operators/Overload` | anchor for Language/Operators/Overload; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/Operators/Overload/Function/FVecNegOverload.as` | adapted | `Language/Operators/Overload` | anchor for Language/Operators/Overload; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/Operators/Overload/Function/FVecSubOverload.as` | adapted | `Language/Operators/Overload` | anchor for Language/Operators/Overload; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/Operators/Overload/Function/FVecUsageOverload.as` | adapted | `Language/Operators/Overload` | anchor for Language/Operators/Overload; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/Operators/Overload/Function/ScoreOperatorSuite.as` | adapted | `Language/Operators/Overload` | anchor for Language/Operators/Overload; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/Operators/Overload/Reject/AdditionWithoutOpAdd.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Operators/Overload/Reject/AdditionWithoutOpAddCoverage.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Operators/Overload/Reject/DuplicateOpAdd.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Operators/Overload/Reject/DuplicateOpAddCoverage.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Operators/Overload/Reject/GlobalOperatorOverload.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Operators/Overload/Reject/InvalidOperatorName.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Operators/Overload/Reject/OpAddReturnsVoid.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Operators/Overload/Reject/OpAddWithoutParameter.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Operators/Overload/Reject/OpCmpNonIntReturn.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Operators/Overload/Reject/OpEqualsNonBoolReturn.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Operators/Overload/Reject/OpIndexReturnsVoid.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Operators/Overload/Reject/OpNegWithParameter.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Operators/Ternary/Function/TernaryOperators.as` | adapted | `Language/Operators/Ternary` | anchor for Language/Operators/Ternary; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/Operators/Ternary/Reject/TernaryBranchTypeMismatch.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Operators/Ternary/Reject/TernaryFloatCondition.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Operators/Ternary/Reject/TernaryMissingColon.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Operators/Ternary/Reject/TernaryMissingTrueBranch.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Operators/Ternary/Reject/TernaryNonBoolCondition.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Operators/Ternary/Reject/TernaryStringCondition.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Operators/UClass/OperatorStateOnActor.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Preprocessor/Function/AddSourcePreprocessesMemoryText.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Preprocessor/Function/AddSourceRejectsInvalidVirtualPathDescriptor.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Preprocessor/Function/AsyncProviderModule.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Preprocessor/Function/AutomaticModeManualImportConsumer.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Preprocessor/Function/AutomaticWarningConfigConsumer.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Preprocessor/Function/BackslashPathConsumer.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Preprocessor/Function/BasicParse.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Preprocessor/Function/ConditionalImportConsumerUndefined.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Preprocessor/Function/ConditionalImportEnabledConsumer.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Preprocessor/Function/ConditionalImportProviderModule.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Preprocessor/Function/DeadBranchImportConsumer.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Preprocessor/Function/DisabledImportBranchConsumer.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Preprocessor/Function/DuplicateImportDedupConsumer.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Preprocessor/Function/DuplicateImportProvider.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Preprocessor/Function/EditorConfigurationFlagBranch.as` | adapted | `Language/Preprocessor/IfElifElse` | anchor for Language/Preprocessor/IfElifElse; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/Preprocessor/Function/FormatStringExpansion.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Preprocessor/Function/IfElifElseEndifBranches.as` | adapted | `Language/Preprocessor/IfElifElse` | anchor for Language/Preprocessor/IfElifElse; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/Preprocessor/Function/ImportParsingConsumerModule.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Preprocessor/Function/ImportParsingProviderModule.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Preprocessor/Function/NameLiteralRoundTrip.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Preprocessor/Function/PlainSourcePreprocessorRoundTrip.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Preprocessor/Function/PostProcessCodeReplacement.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Preprocessor/Function/PreprocessSingleUseFirstModule.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Preprocessor/Function/PreprocessSingleUseSecondModule.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Preprocessor/Function/RangeForRewritePreservesUEBehavior.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Preprocessor/Function/RestrictUsageAllowPattern.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Preprocessor/Function/RestrictUsageInactiveBranchIgnored.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Preprocessor/Function/SharedImportProviderModule.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Preprocessor/Function/StringLiteralDoesNotTriggerDirectiveLexer.as` | adapted | `Language/Preprocessor/DirectiveInString` | anchor for Language/Preprocessor/DirectiveInString; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/Preprocessor/Function/TopologicalChainBase.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Preprocessor/Function/TopologicalChainConsumer.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Preprocessor/Function/TopologicalChainMiddle.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Preprocessor/Function/WideImportGraphFanInConsumer.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Preprocessor/Function/WideImportGraphFanOutA.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Preprocessor/Function/WideImportGraphFanOutB.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Preprocessor/Function/WideImportGraphFanOutC.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Preprocessor/Function/WideImportGraphRoot.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Preprocessor/Reject/BlueprintEventAndOverrideConflict.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Preprocessor/Reject/CircularImportChainFromA.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Preprocessor/Reject/CircularImportChainFromB.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Preprocessor/Reject/GlobalFunctionMarkedBlueprintEvent.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Preprocessor/Reject/ImportMissingTerminatingSemicolon.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Preprocessor/Reject/IncludeDirectiveUnsupported.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Preprocessor/Reject/NamespaceMissingOpeningBrace.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Preprocessor/Reject/TreatAsDeletedProducesEmptyModule.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Preprocessor/Reject/UnknownFunctionSpecifier.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Preprocessor/Reject/UnknownSuperTypeOnClass.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Preprocessor/Reject/UnregisteredPlatformWindowsCondition.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Preprocessor/Reject/UnregisteredWithEditorCondition.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Preprocessor/Reject/UnsupportedConditionalPlacementAroundFunction.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Preprocessor/Reject/UnsupportedConditionalPlacementAroundProperty.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Preprocessor/UClass/AsyncLoadConsumerActor.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Preprocessor/UClass/ClassAnalyzeHookCarrier.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Preprocessor/UClass/DefaultBlueprintAccessUsesSettings.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Preprocessor/UClass/DuplicateClassNameFirstBatchFile.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Preprocessor/UClass/DuplicateClassNameSecondBatchFile.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Preprocessor/UClass/DuplicateClassNameSeedCarrier.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Preprocessor/UClass/EditorConditionalMembers.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Preprocessor/UClass/ExplicitContextControlsFlagsAndDefaults.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Preprocessor/UClass/HookMomentsEmitSummaryBackedCompilationEvents.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Preprocessor/UClass/MacroDetection.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Preprocessor/UClass/SummaryAvailableAtExistingHookPoints.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Preprocessor/UClass/SummaryReportsCoverageFixtureShape.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/Comments/Function/BlockCommentBeforeFunction.as` | adapted | `Language/Syntax/Comments` | anchor for Language/Syntax/Comments; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/Syntax/Comments/Function/BlockCommentWithSeparateMarkers.as` | adapted | `Language/Syntax/Comments` | anchor for Language/Syntax/Comments; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/Syntax/Comments/Function/CommentBeforeFunction.as` | adapted | `Language/Syntax/Comments` | anchor for Language/Syntax/Comments; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/Syntax/Comments/Function/DocumentationComment.as` | adapted | `Language/Syntax/Comments` | anchor for Language/Syntax/Comments; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/Syntax/Comments/Function/InlineCommentInsideFunction.as` | adapted | `Language/Syntax/Comments` | anchor for Language/Syntax/Comments; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/Syntax/Comments/Function/MultiLineBlockComment.as` | adapted | `Language/Syntax/Comments` | anchor for Language/Syntax/Comments; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/Syntax/Comments/Function/RangeBasedForRewriteSkipsLiterals.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/Comments/Function/SingleLineComment.as` | adapted | `Language/Syntax/Comments` | anchor for Language/Syntax/Comments; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/Syntax/Comments/Function/TrailingBlockCommentImportConsumer.as` | adapted | `Language/Syntax/Comments` | anchor for Language/Syntax/Comments; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/Syntax/Comments/UClass/StringDefaultPreservesCommentMarkers.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/Function/AnnotatedStructRoundTrip.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/Function/AnonymousStructCompiles.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/Function/BasicEnumValues.as` | adapted | `Language/Syntax/Enum` | anchor for Language/Syntax/Enum; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/Syntax/EdgeCases/Function/BasicScriptStruct.as` | adapted | `Language/Syntax/StructFields` | anchor for Language/Syntax/StructFields; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/Syntax/EdgeCases/Function/BoolDefaultParameters.as` | adapted | `Language/Syntax/DefaultParameters` | anchor for Language/Syntax/DefaultParameters; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/Syntax/EdgeCases/Function/BoolInOutParameter.as` | adapted | `Language/Syntax/Parameters` | anchor for Language/Syntax/Parameters; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/Syntax/EdgeCases/Function/BoolIntOverloadResolution.as` | adapted | `Language/Syntax/Overload` | anchor for Language/Syntax/Overload; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/Syntax/EdgeCases/Function/BoolOutParameter.as` | adapted | `Language/Syntax/Parameters` | anchor for Language/Syntax/Parameters; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/Syntax/EdgeCases/Function/BoolReferenceInParameter.as` | adapted | `Language/Syntax/Parameters` | anchor for Language/Syntax/Parameters; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/Syntax/EdgeCases/Function/BoolValueParameters.as` | adapted | `Language/Syntax/Parameters` | anchor for Language/Syntax/Parameters; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/Syntax/EdgeCases/Function/CombinedJumps.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/Function/CommonCVarUsagePatterns.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/Function/ConsoleCommandCommonStringMatrixDispatch.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/Function/ConsoleCommandRegistrationArgumentsAndUnload.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/Function/ConsoleCommandStringConstructionCompileBoundary.as` | adapted | `Language/Syntax/Const` | anchor for Language/Syntax/Const; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/Syntax/EdgeCases/Function/DeeplyNestedBlocks.as` | adapted | `Language/Syntax/Blocks` | anchor for Language/Syntax/Blocks; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/Syntax/EdgeCases/Function/DeeplyParenthesizedAddition.as` | adapted | `Language/Syntax/Blocks` | anchor for Language/Syntax/Blocks; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/Syntax/EdgeCases/Function/DefaultParameterFunction.as` | adapted | `Language/Syntax/DefaultParameters` | anchor for Language/Syntax/DefaultParameters; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/Syntax/EdgeCases/Function/EmptyEnumDeclaration.as` | adapted | `Language/Syntax/Enum` | anchor for Language/Syntax/Enum; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/Syntax/EdgeCases/Function/EmptyFunctionBodyCompiles.as` | adapted | `Language/Syntax/EmptyFunction` | anchor for Language/Syntax/EmptyFunction; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/Syntax/EdgeCases/Function/EmptySourceRecovery.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/Function/EmptyVoidFunction.as` | adapted | `Language/Syntax/EmptyFunction` | anchor for Language/Syntax/EmptyFunction; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/Syntax/EdgeCases/Function/EnumAvailability.as` | adapted | `Language/Syntax/Enum` | anchor for Language/Syntax/Enum; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/Syntax/EdgeCases/Function/EnumExplicitValues.as` | adapted | `Language/Syntax/Enum` | anchor for Language/Syntax/Enum; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/Syntax/EdgeCases/Function/EnumLocalUsage.as` | adapted | `Language/Syntax/Enum` | anchor for Language/Syntax/Enum; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/Syntax/EdgeCases/Function/ExistingEngineCVarSmokePreservesAndRestoresValues.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/Function/ExistingEngineRenderAndScalabilityCVarsPreserveAndRestoreValues.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/Function/FBoxOperations.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/Function/FPlaneOperations.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/Function/FQuatDefaultParameters.as` | adapted | `Language/Syntax/DefaultParameters` | anchor for Language/Syntax/DefaultParameters; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/Syntax/EdgeCases/Function/FQuatInOutParameter.as` | adapted | `Language/Syntax/Parameters` | anchor for Language/Syntax/Parameters; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/Syntax/EdgeCases/Function/FQuatOutParameters.as` | adapted | `Language/Syntax/Parameters` | anchor for Language/Syntax/Parameters; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/Syntax/EdgeCases/Function/FQuatReferenceInParameter.as` | adapted | `Language/Syntax/Parameters` | anchor for Language/Syntax/Parameters; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/Syntax/EdgeCases/Function/FQuatValueParameters.as` | adapted | `Language/Syntax/Parameters` | anchor for Language/Syntax/Parameters; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/Syntax/EdgeCases/Function/FirstCompilationContextPayload.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/Function/FloatDefaultParameters.as` | adapted | `Language/Syntax/DefaultParameters` | anchor for Language/Syntax/DefaultParameters; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/Syntax/EdgeCases/Function/FloatDoubleOverloadResolution.as` | adapted | `Language/Syntax/Overload` | anchor for Language/Syntax/Overload; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/Syntax/EdgeCases/Function/FloatInOutParameters.as` | adapted | `Language/Syntax/Parameters` | anchor for Language/Syntax/Parameters; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/Syntax/EdgeCases/Function/FloatOutParameters.as` | adapted | `Language/Syntax/Parameters` | anchor for Language/Syntax/Parameters; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/Syntax/EdgeCases/Function/FloatReferenceInParameters.as` | adapted | `Language/Syntax/Parameters` | anchor for Language/Syntax/Parameters; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/Syntax/EdgeCases/Function/FloatValueParameters.as` | adapted | `Language/Syntax/Parameters` | anchor for Language/Syntax/Parameters; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/Syntax/EdgeCases/Function/ForBasicShapes.as` | adapted | `Language/Syntax/ForClauses` | anchor for Language/Syntax/ForClauses; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/Syntax/EdgeCases/Function/ForCommaClauses.as` | adapted | `Language/Syntax/ForClauses` | anchor for Language/Syntax/ForClauses; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/Syntax/EdgeCases/Function/ForNestedLoops.as` | adapted | `Language/Syntax/ForNested` | anchor for Language/Syntax/ForNested; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/Syntax/EdgeCases/Function/ForOmittedClauses.as` | adapted | `Language/Syntax/ForClauses` | anchor for Language/Syntax/ForClauses; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/Syntax/EdgeCases/Function/ForPositiveSyntaxForms.as` | adapted | `Language/Syntax/ForClauses` | anchor for Language/Syntax/ForClauses; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/Syntax/EdgeCases/Function/FunctionDefaultParameterEdges.as` | adapted | `Language/Syntax/DefaultParameters` | anchor for Language/Syntax/DefaultParameters; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/Syntax/EdgeCases/Function/FunctionOverloadArityAndNumericResolution.as` | adapted | `Language/Syntax/Overload` | anchor for Language/Syntax/Overload; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/Syntax/EdgeCases/Function/FunctionParametersMultipleOut.as` | adapted | `Language/Syntax/Parameters` | anchor for Language/Syntax/Parameters; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/Syntax/EdgeCases/Function/ImportConsumerModule.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/Function/ImportProviderModule.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/Function/ImportReloadConsumerModule.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/Function/ImportReloadProviderV1.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/Function/ImportReloadProviderV2.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/Function/InfiniteLoops.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/Function/IntFamilyDefaultParameters.as` | adapted | `Language/Syntax/DefaultParameters` | anchor for Language/Syntax/DefaultParameters; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/Syntax/EdgeCases/Function/IntFamilyInOutParameters.as` | adapted | `Language/Syntax/Parameters` | anchor for Language/Syntax/Parameters; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/Syntax/EdgeCases/Function/IntFamilyOutParameters.as` | adapted | `Language/Syntax/Parameters` | anchor for Language/Syntax/Parameters; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/Syntax/EdgeCases/Function/IntFamilyReferenceInParameters.as` | adapted | `Language/Syntax/Parameters` | anchor for Language/Syntax/Parameters; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/Syntax/EdgeCases/Function/IntFamilyValueParameters.as` | adapted | `Language/Syntax/Parameters` | anchor for Language/Syntax/Parameters; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/Syntax/EdgeCases/Function/IntReturnFunction.as` | adapted | `Language/Syntax/FunctionReturn` | anchor for Language/Syntax/FunctionReturn; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/Syntax/EdgeCases/Function/IntWidthOverloadResolution.as` | adapted | `Language/Syntax/Overload` | anchor for Language/Syntax/Overload; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/Syntax/EdgeCases/Function/LongChainedAddition.as` | adapted | `Language/Syntax/Blocks` | anchor for Language/Syntax/Blocks; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/Syntax/EdgeCases/Function/MemorySourceCompilesWithFullVirtualPathIdentity.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/Function/ModuleFunctionInspection.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/Function/MultipleStatementsInOneFunction.as` | adapted | `Language/Syntax/Blocks` | anchor for Language/Syntax/Blocks; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/Syntax/EdgeCases/Function/NamedArgumentsMixedPartialOrder.as` | adapted | `Language/Syntax/NamedArguments` | anchor for Language/Syntax/NamedArguments; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/Syntax/EdgeCases/Function/NoListenerCompileIsSilentAndPreservesResult.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/Function/ParameterlessMappingGettersDispatchWithNativeParity.as` | adapted | `Language/Syntax/Parameters` | anchor for Language/Syntax/Parameters; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/Syntax/EdgeCases/Function/ParseEventsAreBroadcastFromMainThreadInDeterministicOrder.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/Function/RangeBasedForRewriteSupportsBlockAndSingleLine.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/Function/RecursiveFrameIsolation.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/Function/ReferenceWriteParameter.as` | adapted | `Language/Syntax/Parameters` | anchor for Language/Syntax/Parameters; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/Syntax/EdgeCases/Function/RegisteredCVarNameMatrix.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/Function/RegisteredListenerReceivesValueStyleCompileEvents.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/Function/RuntimeCompileRunsObservableBuilderStages.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/Function/RuntimeFloatCurveInstanceSurface.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/Function/SecondCompilationContextPayload.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/Function/ShortCircuitSkipsRightHandSide.as` | adapted | `Language/Syntax/Blocks` | anchor for Language/Syntax/Blocks; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/Syntax/EdgeCases/Function/StaticDeltaAndRelativeHelpers.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/Function/StructConstMethod.as` | adapted | `Language/Syntax/StructConst` | anchor for Language/Syntax/StructConst; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/Syntax/EdgeCases/Function/StructConstReaderMethod.as` | adapted | `Language/Syntax/StructConst` | anchor for Language/Syntax/StructConst; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/Syntax/EdgeCases/Function/StructConstructors.as` | adapted | `Language/Syntax/StructConstructors` | anchor for Language/Syntax/StructConstructors; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/Syntax/EdgeCases/Function/StructMemberDefaults.as` | adapted | `Language/Syntax/StructFields` | anchor for Language/Syntax/StructFields; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/Syntax/EdgeCases/Function/SuccessfulCompileEmitsOrderedStageEvents.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/Function/TouchAndGestureApiBoundaries.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/Function/UEnumReflection.as` | adapted | `Language/Syntax/Enum` | anchor for Language/Syntax/Enum; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/Syntax/EdgeCases/Function/UEnumWithoutPrefixNaming.as` | adapted | `Language/Syntax/Enum` | anchor for Language/Syntax/Enum; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/Syntax/EdgeCases/Function/UStructPropertyZeroDefault.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/Function/UStructWithoutPrefixNaming.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/Function/VoidOverloadSet.as` | adapted | `Language/Syntax/Overload` | anchor for Language/Syntax/Overload; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/Syntax/EdgeCases/Reject/ClassInvalidMemberType.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Syntax/EdgeCases/Reject/ClassRemovedLegacyParent.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Syntax/EdgeCases/Reject/ClassSelfInheritance.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Syntax/EdgeCases/Reject/ClassUnknownSuperType.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Syntax/EdgeCases/Reject/ClassWithoutBraces.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Syntax/EdgeCases/Reject/ClassWithoutName.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Syntax/EdgeCases/Reject/DefaultNonExistentProperty.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Syntax/EdgeCases/Reject/DefaultOutsideClassScope.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Syntax/EdgeCases/Reject/DefaultTypeMismatch.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Syntax/EdgeCases/Reject/DuplicateClassName.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Syntax/EdgeCases/Reject/DuplicateEnumerator.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Syntax/EdgeCases/Reject/DuplicateFunctionSignature.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Syntax/EdgeCases/Reject/DuplicateStructName.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Syntax/EdgeCases/Reject/EnumWithoutName.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Syntax/EdgeCases/Reject/EventAddDynamicBoundary.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Syntax/EdgeCases/Reject/EventLambdaSyntaxIsUnsupported.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Syntax/EdgeCases/Reject/ExtraClosingBrace.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Syntax/EdgeCases/Reject/FBox2DUnsupportedBoundary.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Syntax/EdgeCases/Reject/FailedCompileEmitsPairedEndEvent.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Syntax/EdgeCases/Reject/FloatNestedContainerBoundary.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Syntax/EdgeCases/Reject/ForHeaderWithoutSemicolons.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Syntax/EdgeCases/Reject/ForLoopVariableEscapesScope.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Syntax/EdgeCases/Reject/ForNonBoolCondition.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Syntax/EdgeCases/Reject/ForWithTwoClausesOnly.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Syntax/EdgeCases/Reject/ForWithoutParentheses.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Syntax/EdgeCases/Reject/FunctionUnknownParameterType.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Syntax/EdgeCases/Reject/FunctionUnknownReturnType.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Syntax/EdgeCases/Reject/FunctionWithoutBody.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Syntax/EdgeCases/Reject/FunctionWithoutReturnType.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Syntax/EdgeCases/Reject/GarbageTokens.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Syntax/EdgeCases/Reject/GlobalConsoleCommandExecution.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Syntax/EdgeCases/Reject/GlobalPlusFunctionCombo.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Syntax/EdgeCases/Reject/HttpBindLambdaCallbackBoundary.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Syntax/EdgeCases/Reject/InterfaceDataMember.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Syntax/EdgeCases/Reject/InterfaceKeywordUnsupported.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Syntax/EdgeCases/Reject/InterfaceMethodBody.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Syntax/EdgeCases/Reject/InterfaceWithoutName.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Syntax/EdgeCases/Reject/LegacyMappingGetterArguments.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Syntax/EdgeCases/Reject/MethodInsideEnum.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Syntax/EdgeCases/Reject/MissingSemicolonBetweenDeclarations.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Syntax/EdgeCases/Reject/NamedArgumentDuplicateName.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Syntax/EdgeCases/Reject/NamedArgumentUnknownName.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Syntax/EdgeCases/Reject/NestedContainerCombinations.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Syntax/EdgeCases/Reject/NonDefaultParameterAfterDefault.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Syntax/EdgeCases/Reject/NonIntegerEnumerator.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Syntax/EdgeCases/Reject/OutOfScopeUse.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Syntax/EdgeCases/Reject/PlayerControllerConsoleCommandExecution.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Syntax/EdgeCases/Reject/StructInheritance.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Syntax/EdgeCases/Reject/StructInvalidMemberType.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Syntax/EdgeCases/Reject/StructVoidMember.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Syntax/EdgeCases/Reject/SyntaxErrorMissingSemicolon.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Syntax/EdgeCases/Reject/TimerLambdaCallbackBoundary.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Syntax/EdgeCases/Reject/TopLevelAssignment.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Syntax/EdgeCases/Reject/UnknownGhostBuilderType.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Syntax/EdgeCases/Reject/UnmatchedOpeningBrace.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Syntax/EdgeCases/Reject/UnmatchedParenthesis.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Syntax/EdgeCases/Reject/VoidParameterType.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Syntax/EdgeCases/UClass/AbstractUClassWithConcreteChild.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/UClass/ActionBinding.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/UClass/ActorMembersWithInitializers.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/UClass/ActorMethodsCompiling.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/UClass/ActorWithoutPrefixNaming.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/UClass/AnnotatedMethodExecutes.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/UClass/AxisBinding.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/UClass/BlueprintEventWrapperExecutesImplementation.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/UClass/BlueprintEventWrapperUsesMixedPushPaths.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/UClass/BoolContainerProperties.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/UClass/BoolDeclarationDefaults.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/UClass/BoolReplicatedProperties.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/UClass/BoolWriteRoundTrip.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/UClass/ClassLikeMethodExecutionRoundTrip.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/UClass/ClassLikeReflectionShape.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/UClass/CompilesAndRegistersProperties.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/UClass/ContainerAsParameter.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/UClass/ContainerIteratorAdvancedOperations.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/UClass/DefaultEnumPropertyApplied.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/UClass/DefaultFNamePropertyApplied.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/UClass/DefaultFloatAndBoolPropertyApplied.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/UClass/DefaultTagsAddExecutedOnCDO.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/UClass/EmptyActorSubclass.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/UClass/EventBindAndTrigger.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/UClass/EventBusDecouplesPublisherAndReceiver.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/UClass/EventChaining.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/UClass/EventCustomGameEvents.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/UClass/EventLifecycle.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/UClass/EventMultipleHandlers.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/UClass/EventUnbinding.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/UClass/FQuatClassMemberRuntimeFlow.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/UClass/FQuatContainerProperties.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/UClass/FQuatDeclarationDefaults.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/UClass/FQuatWriteRoundTrip.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/UClass/FinalActorSubclass.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/UClass/FloatContainerProperties.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/UClass/FloatFamilyBoundaryValues.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/UClass/FloatFamilyDeclarationDefaults.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/UClass/FloatFamilySpecialValues.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/UClass/FloatFamilyWriteRoundTrip.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/UClass/FloatPropertyScriptMutationRoundTrip.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/UClass/FloatReplicatedProperties.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/UClass/GCBasicReclaim.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/UClass/GCCollectionMethods.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/UClass/GCContainerProtection.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/UClass/GCCrossFrameHold.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/UClass/GCIsValidCheck.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/UClass/GCNewObjectOuterAndCollection.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/UClass/GCRootReachability.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/UClass/GCStrongCycleReclaim.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/UClass/GCWeakPtrInvalidation.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/UClass/GamepadInput.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/UClass/GeometricStructReflectionPropertiesAndContainers.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/UClass/HandleAsParameter.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/UClass/HandleAsProperty.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/UClass/HandleBasics.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/UClass/HandleCast.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/UClass/HandleInContainers.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/UClass/HandleOperations.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/UClass/ImmediateFailureCallbacks.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/UClass/InheritFromFinalActor.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/UClass/IntContainerEdgeCases.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/UClass/IntContainerProperties.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/UClass/IntContainerPropertiesExtended.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/UClass/IntContainerWidthCompletion.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/UClass/IntFamilyBoundaryValues.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/UClass/IntFamilyDeclarationDefaults.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/UClass/IntFamilyImplicitAndExplicitZeroDefaults.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/UClass/IntFamilyNearBoundaryValues.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/UClass/IntFamilyWriteRoundTrip.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/UClass/IntPropertyScriptReadWriteApiSurface.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/UClass/IntStructDeepNestedPropertyPaths.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/UClass/IntStructNestedPropertyWidths.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/UClass/KeyDirectBinding.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/UClass/KeyboardKeys.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/UClass/LegacyInputPriorityAndConsumeSurface.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/UClass/MixedContainerParameters.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/UClass/MouseInput.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/UClass/MultipleCommaSeparatedBases.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/UClass/PropertyDefaultsCompile.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/UClass/ScriptConstructorAssignsMember.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/UClass/SyntaxErrorInitialCarrier.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/UClass/SyntaxErrorRecoveredCarrier.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/UClass/TouchStateQuerySurface.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/UClass/TwoLevelInheritanceChain.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/UClass/UClassPropertyDefaults.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/UClass/UObjectFlagMutationAndTransientState.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/UClass/UObjectOuterChainAndPathMatrix.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/EdgeCases/UClass/Vector4IntPointIntVectorReflection.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/Keywords/Function/ConstMethodOnStruct.as` | adapted | `Language/Syntax/StructConst` | anchor for Language/Syntax/StructConst; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/Syntax/Keywords/Reject/InheritFromFinalClass.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Syntax/Keywords/Reject/MutateMemberInConstMethod.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Syntax/Keywords/Reject/OverrideWithoutParentMethod.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Syntax/Keywords/Reject/SuperOutsideClass.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Syntax/Keywords/Reject/ThisOutsideClass.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Syntax/Keywords/UClass/FinalClassModifier.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/Keywords/UClass/OverrideKeywordOnChildMethod.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/Keywords/UClass/SuperCallInBlueprintOverride.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/Keywords/UClass/ThisKeywordMemberAssignment.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/Reference/Function/ConstValuesMethodsAndReferences.as` | adapted | `Language/Syntax/Const` | anchor for Language/Syntax/Const; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/Syntax/Reference/Function/FunctionReferenceParameterCombinations.as` | adapted | `Language/Syntax/Parameters` | anchor for Language/Syntax/Parameters; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/Syntax/Reference/UClass/ContainerReferenceReturn.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/Reference/UClass/MemberReferenceAndNullableHandleConversions.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
| `TestSource-old/Language/Syntax/Variable/Function/PrimitiveAndReferenceLocals.as` | adapted | `Language/Syntax/Variables` | anchor for Language/Syntax/Variables; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/Syntax/Variable/Function/ScopeVariables.as` | adapted | `Language/Syntax/Variables` | anchor for Language/Syntax/Variables; UFUNCTION/Observe/host wrappers stripped, language declarations retained |
| `TestSource-old/Language/Syntax/Variable/Reject/AutoWithoutInitializer.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Syntax/Variable/Reject/ConstWithoutInitializer.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Syntax/Variable/Reject/DuplicateLocalVariable.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Syntax/Variable/Reject/IdentifierStartingWithDigit.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Syntax/Variable/Reject/KeywordAsVariableName.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Syntax/Variable/Reject/UndeclaredType.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Syntax/Variable/Reject/UseBeforeDeclaration.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Syntax/Variable/Reject/VoidVariable.as` | excluded |  | theme reject outside the accepted FileTag, or host/diagnostic-only program |
| `TestSource-old/Language/Syntax/Variable/UClass/GCLocalVariableNoProtection.as` | excluded |  | host observer, UE type, or UFUNCTION wrapper; not language-only source material |
