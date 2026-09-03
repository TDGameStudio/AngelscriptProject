/**
 * A child BlueprintCallable may not change the parent signature. ComputeValue
 * takes int on the base and FString on the child. This file is the illegal
 * program itself.
 *
 * @Theme Definitions.UFunction
 * @Subject UFunction.BlueprintCallableParentSignatureMismatch
 * @Harness CompileReject
 * @Tag Definitions.UFunction.BlueprintCallableParentSignatureMismatch
 * @Kind CompileReject
 * @Covers UFunction.Specifier
 * @Inputs child ComputeValue(FString) over parent ComputeValue(int)
 * @Return does not compile; diagnostic "BlueprintCallable method ComputeValue in class ACoverageUFunctionCallableMismatchChildActor is specified in superclass ACoverageUFunctionCallableMismatchBaseActor with a different signature."
 * @Provenance Theme: Definitions.UFunction. NegativeDiagnostic: BlueprintCallable parent signature mismatch.
 * @Provenance C++: AngelscriptCoverageUFunctionTests.cpp::UnsupportedUFunctionShapeDiagnostics case callable parent signature.
 * @Provenance Expected compile failure: "BlueprintCallable method ComputeValue in class ACoverageUFunctionCallableMismatchChildActor is specified in superclass ACoverageUFunctionCallableMismatchBaseActor with a different signature."
 */

UCLASS()
class ACoverageUFunctionCallableMismatchBaseActor : AActor
{
	/**
	 * Parent BlueprintCallable with an int parameter.
	 *
	 * @Kind CompileReject
	 * @Covers UFunction.Specifier
	 * @Inputs int Value
	 * @Return Value
	 */
	UFUNCTION(BlueprintCallable)
	int ComputeValue(int Value)
	{
		return Value;
	}
}

UCLASS()
class ACoverageUFunctionCallableMismatchChildActor : ACoverageUFunctionCallableMismatchBaseActor
{
	/**
	 * Illegal child BlueprintCallable whose parameter type does not match the parent.
	 *
	 * @Kind CompileReject
	 * @Covers UFunction.Specifier
	 * @Inputs FString Value
	 * @Return does not compile
	 */
	UFUNCTION(BlueprintCallable)
	int ComputeValue(FString Value)
	{
		return Value.Len();
	}
}
