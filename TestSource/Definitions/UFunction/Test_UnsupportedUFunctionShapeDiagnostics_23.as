// Theme: Definitions.UFunction. NegativeDiagnostic: BlueprintEvent already specified in AS superclass.
// C++: AngelscriptCoverageUFunctionTests.cpp::UnsupportedUFunctionShapeDiagnostics case duplicate parent event.
// Expected diagnostic: "declared as final and cannot be overridden"
// Isolate this failing program. DiagnosticOnly.

UCLASS()
class ACoverageUFunctionParentEventBaseActor : AActor
{
	UFUNCTION(BlueprintEvent)
	int ComputeParentEvent(int Value)
	{
		return Value + 1;
	}
}

UCLASS()
class ACoverageUFunctionParentEventChildActor : ACoverageUFunctionParentEventBaseActor
{
	UFUNCTION(BlueprintEvent)
	int ComputeParentEvent(int Value)
	{
		return Value + 2;
	}
}
