/**
 * The retired Haze NetFunction specifier is unknown. It is not a legal
 * UFUNCTION specifier on this fork. This file is the illegal program itself.
 *
 * @Theme Definitions.UFunction
 * @Subject UFunction.HazeNetFunctionSpecifier
 * @Harness CompileReject
 * @Tag Definitions.UFunction.HazeNetFunctionSpecifier
 * @Kind CompileReject
 * @Covers UFunction.Specifier
 * @Inputs UFUNCTION(NetFunction) void HazeNetFunction()
 * @Return does not compile; diagnostic "Unknown function specifier NetFunction on method ACoverageUFunctionHazeNetFunctionActor::HazeNetFunction."
 * @Provenance Theme: Definitions.UFunction. NegativeDiagnostic: retired Haze NetFunction specifier is unknown.
 * @Provenance C++: AngelscriptCoverageUFunctionTests.cpp::UnsupportedUFunctionShapeDiagnostics case Haze NetFunction.
 * @Provenance Expected compile failure: "Unknown function specifier NetFunction on method ACoverageUFunctionHazeNetFunctionActor::HazeNetFunction."
 */

UCLASS()
class ACoverageUFunctionHazeNetFunctionActor : AActor
{
	/**
	 * Illegal UFUNCTION using the retired NetFunction specifier.
	 *
	 * @Kind CompileReject
	 * @Covers UFunction.Specifier
	 * @Inputs UFUNCTION(NetFunction)
	 * @Return does not compile
	 */
	UFUNCTION(NetFunction)
	void HazeNetFunction()
	{
	}
}
