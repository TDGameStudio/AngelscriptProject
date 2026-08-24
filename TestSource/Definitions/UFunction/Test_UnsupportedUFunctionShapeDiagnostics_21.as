// Theme: Definitions.UFunction. NegativeDiagnostic: retired Haze DevFunction specifier is unknown.
// C++: AngelscriptCoverageUFunctionTests.cpp::UnsupportedUFunctionShapeDiagnostics case Haze DevFunction.
// Expected diagnostic: "Unknown function specifier DevFunction on method ACoverageUFunctionHazeDevFunctionActor::HazeDevFunction."
// Isolate this failing program. DiagnosticOnly.

UCLASS()
class ACoverageUFunctionHazeDevFunctionActor : AActor
{
	UFUNCTION(DevFunction)
	void HazeDevFunction()
	{
	}
}
