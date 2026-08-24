// Theme: Definitions.UFunction. NegativeDiagnostic: BlueprintPure must have a return or out result.
// C++: AngelscriptCoverageUFunctionTests.cpp::UnsupportedUFunctionShapeDiagnostics case pure without result.
// Expected diagnostic: "BlueprintPure method PureWithoutResult in class ACoverageUFunctionPureWithoutResultActor must have return value."
// Isolate this failing program. DiagnosticOnly.

UCLASS()
class ACoverageUFunctionPureWithoutResultActor : AActor
{
	UFUNCTION(BlueprintPure)
	void PureWithoutResult()
	{
	}
}
