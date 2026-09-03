/**
 * UPARAM is not AngelScript parameter syntax. The C++ macro form
 * UPARAM(DisplayName="Input Value") int Value is rejected by the parser.
 * This file is the illegal program itself.
 *
 * @Theme Definitions.UFunction
 * @Subject UFunction.UParamMacroSyntax
 * @Harness CompileReject
 * @Tag Definitions.UFunction.UParamMacroSyntax
 * @Kind CompileReject
 * @Covers UFunction.Parameter
 * @Inputs UPARAM(DisplayName="Input Value") int Value
 * @Return does not compile; diagnostic "Instead found '('"
 * @Provenance Theme: Definitions.UFunction. Isolated compile-fail: UPARAM is not AngelScript parameter syntax.
 * @Provenance C++: AngelscriptCoverageUFunctionTests.cpp::UParamDisplayNameAndRefMatrix block 2
 * @Provenance Expected compile failure: "Instead found '('"
 */

UCLASS()
class ACoverageUFunctionInvalidUParamActor : AActor
{
	/**
	 * Illegal UFUNCTION using UPARAM macro-style parameter syntax.
	 *
	 * @Kind CompileReject
	 * @Covers UFunction.Parameter
	 * @Inputs UPARAM(DisplayName="Input Value") int Value
	 * @Return does not compile
	 */
	UFUNCTION(BlueprintCallable)
	void InvalidUPARAM(UPARAM(DisplayName="Input Value") int Value)
	{
	}
}
