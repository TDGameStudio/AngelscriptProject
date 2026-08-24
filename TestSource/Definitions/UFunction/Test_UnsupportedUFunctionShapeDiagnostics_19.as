// Theme: Definitions.UFunction. NegativeDiagnostic: retired Haze NetFunction specifier is unknown.
// C++: AngelscriptCoverageUFunctionTests.cpp::UnsupportedUFunctionShapeDiagnostics case Haze NetFunction.
// Expected diagnostic: "Unknown function specifier NetFunction on method ACoverageUFunctionHazeNetFunctionActor::HazeNetFunction."
// Isolate this failing program. DiagnosticOnly.

UCLASS()
class ACoverageUFunctionHazeNetFunctionActor : AActor
{
	UFUNCTION(NetFunction)
	void HazeNetFunction()
	{
	}
}
