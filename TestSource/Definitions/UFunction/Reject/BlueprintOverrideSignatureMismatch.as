/**
 * A BlueprintOverride must match the parent event signature. The child
 * ComputeValue takes FString while the parent event takes int. This file is
 * the illegal program itself.
 *
 * @Theme Definitions.UFunction
 * @Subject UFunction.BlueprintOverrideSignatureMismatch
 * @Harness CompileReject
 * @Tag Definitions.UFunction.BlueprintOverrideSignatureMismatch
 * @Kind CompileReject
 * @Covers UFunction.Specifier
 * @Inputs child ComputeValue(FString) over parent event ComputeValue(int)
 * @Return does not compile; diagnostic "BlueprintOverride method ComputeValue in class ACoverageUFunctionMismatchChildActor does not match signature of event declared in superclass ACoverageUFunctionMismatchBaseActor."
 * @Provenance Theme: Definitions.UFunction. NegativeDiagnostic: BlueprintOverride signature mismatch vs parent event.
 * @Provenance C++: AngelscriptCoverageUFunctionTests.cpp::UnsupportedUFunctionShapeDiagnostics case override signature mismatch.
 * @Provenance Expected compile failure: "BlueprintOverride method ComputeValue in class ACoverageUFunctionMismatchChildActor does not match signature of event declared in superclass ACoverageUFunctionMismatchBaseActor."
 */

UCLASS()
class ACoverageUFunctionMismatchBaseActor : AActor
{
	/**
	 * Parent BlueprintEvent with an int parameter.
	 *
	 * @Kind CompileReject
	 * @Covers UFunction.Specifier
	 * @Inputs int Value
	 * @Return Value + 1
	 */
	UFUNCTION(BlueprintEvent)
	int ComputeValue(int Value)
	{
		return Value + 1;
	}
}

UCLASS()
class ACoverageUFunctionMismatchChildActor : ACoverageUFunctionMismatchBaseActor
{
	/**
	 * Illegal BlueprintOverride whose parameter type does not match the parent event.
	 *
	 * @Kind CompileReject
	 * @Covers UFunction.Specifier
	 * @Inputs FString Value
	 * @Return does not compile
	 */
	UFUNCTION(BlueprintOverride)
	int ComputeValue(FString Value)
	{
		return Value.Len();
	}
}
