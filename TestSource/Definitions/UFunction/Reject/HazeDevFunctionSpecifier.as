/**
 * The retired Haze DevFunction specifier is unknown. It is not a legal
 * UFUNCTION specifier on this fork. This file is the illegal program itself.
 *
 * @Theme Definitions.UFunction
 * @Subject UFunction.HazeDevFunctionSpecifier
 * @Harness CompileReject
 * @Tag Definitions.UFunction.HazeDevFunctionSpecifier
 * @Kind CompileReject
 * @Covers UFunction.Specifier
 * @Inputs UFUNCTION(DevFunction) void HazeDevFunction()
 * @Return does not compile; diagnostic "Unknown function specifier DevFunction on method ACoverageUFunctionHazeDevFunctionActor::HazeDevFunction."
 * @Provenance Theme: Definitions.UFunction. NegativeDiagnostic: retired Haze DevFunction specifier is unknown.
 * @Provenance C++: AngelscriptCoverageUFunctionTests.cpp::UnsupportedUFunctionShapeDiagnostics case Haze DevFunction.
 * @Provenance Expected compile failure: "Unknown function specifier DevFunction on method ACoverageUFunctionHazeDevFunctionActor::HazeDevFunction."
 */

UCLASS()
class ACoverageUFunctionHazeDevFunctionActor : AActor
{
	/**
	 * Illegal UFUNCTION using the retired DevFunction specifier.
	 *
	 * @Kind CompileReject
	 * @Covers UFunction.Specifier
	 * @Inputs UFUNCTION(DevFunction)
	 * @Return does not compile
	 */
	UFUNCTION(DevFunction)
	void HazeDevFunction()
	{
	}
}
