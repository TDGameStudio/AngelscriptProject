/**
 * BlueprintPure must have a return value or an out parameter. PureWithoutResult
 * is a void method with neither. This file is the illegal program itself.
 *
 * @Theme Definitions.UFunction
 * @Subject UFunction.BlueprintPureWithoutResult
 * @Harness CompileReject
 * @Tag Definitions.UFunction.BlueprintPureWithoutResult
 * @Kind CompileReject
 * @Covers UFunction.Specifier
 * @Inputs UFUNCTION(BlueprintPure) void PureWithoutResult()
 * @Return does not compile; diagnostic "BlueprintPure method PureWithoutResult in class ACoverageUFunctionPureWithoutResultActor must have return value."
 * @Provenance Theme: Definitions.UFunction. NegativeDiagnostic: BlueprintPure must have a return or out result.
 * @Provenance C++: AngelscriptCoverageUFunctionTests.cpp::UnsupportedUFunctionShapeDiagnostics case pure without result.
 * @Provenance Expected compile failure: "BlueprintPure method PureWithoutResult in class ACoverageUFunctionPureWithoutResultActor must have return value."
 */

UCLASS()
class ACoverageUFunctionPureWithoutResultActor : AActor
{
	/**
	 * Illegal BlueprintPure void method with no result.
	 *
	 * @Kind CompileReject
	 * @Covers UFunction.Specifier
	 * @Inputs UFUNCTION(BlueprintPure) void PureWithoutResult()
	 * @Return does not compile
	 */
	UFUNCTION(BlueprintPure)
	void PureWithoutResult()
	{
	}
}
