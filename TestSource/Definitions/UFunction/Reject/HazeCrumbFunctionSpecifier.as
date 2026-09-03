/**
 * The retired Haze CrumbFunction specifier is unknown. It is not a legal
 * UFUNCTION specifier on this fork. This file is the illegal program itself.
 *
 * @Theme Definitions.UFunction
 * @Subject UFunction.HazeCrumbFunctionSpecifier
 * @Harness CompileReject
 * @Tag Definitions.UFunction.HazeCrumbFunctionSpecifier
 * @Kind CompileReject
 * @Covers UFunction.Specifier
 * @Inputs UFUNCTION(CrumbFunction) void HazeCrumbFunction()
 * @Return does not compile; diagnostic "Unknown function specifier CrumbFunction on method ACoverageUFunctionHazeCrumbFunctionActor::HazeCrumbFunction."
 * @Provenance Theme: Definitions.UFunction. NegativeDiagnostic: retired Haze CrumbFunction specifier is unknown.
 * @Provenance C++: AngelscriptCoverageUFunctionTests.cpp::UnsupportedUFunctionShapeDiagnostics case Haze CrumbFunction.
 * @Provenance Expected compile failure: "Unknown function specifier CrumbFunction on method ACoverageUFunctionHazeCrumbFunctionActor::HazeCrumbFunction."
 */

UCLASS()
class ACoverageUFunctionHazeCrumbFunctionActor : AActor
{
	/**
	 * Illegal UFUNCTION using the retired CrumbFunction specifier.
	 *
	 * @Kind CompileReject
	 * @Covers UFunction.Specifier
	 * @Inputs UFUNCTION(CrumbFunction)
	 * @Return does not compile
	 */
	UFUNCTION(CrumbFunction)
	void HazeCrumbFunction()
	{
	}
}
