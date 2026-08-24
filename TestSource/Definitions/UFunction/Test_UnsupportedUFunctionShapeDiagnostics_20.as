// Theme: Definitions.UFunction. NegativeDiagnostic: retired Haze CrumbFunction specifier is unknown.
// C++: AngelscriptCoverageUFunctionTests.cpp::UnsupportedUFunctionShapeDiagnostics case Haze CrumbFunction.
// Expected diagnostic: "Unknown function specifier CrumbFunction on method ACoverageUFunctionHazeCrumbFunctionActor::HazeCrumbFunction."
// Isolate this failing program. DiagnosticOnly.

UCLASS()
class ACoverageUFunctionHazeCrumbFunctionActor : AActor
{
	UFUNCTION(CrumbFunction)
	void HazeCrumbFunction()
	{
	}
}
