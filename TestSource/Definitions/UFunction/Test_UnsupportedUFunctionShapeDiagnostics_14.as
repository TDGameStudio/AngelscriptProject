// Theme: Definitions.UFunction. NegativeDiagnostic: BlueprintOverride signature mismatch vs parent event.
// C++: AngelscriptCoverageUFunctionTests.cpp::UnsupportedUFunctionShapeDiagnostics case override signature mismatch.
// Expected diagnostic: "BlueprintOverride method ComputeValue in class ACoverageUFunctionMismatchChildActor does not match signature of event declared in superclass ACoverageUFunctionMismatchBaseActor."
// Isolate this failing program. DiagnosticOnly.

UCLASS()
class ACoverageUFunctionMismatchBaseActor : AActor
{
	UFUNCTION(BlueprintEvent)
	int ComputeValue(int Value)
	{
		return Value + 1;
	}
}

UCLASS()
class ACoverageUFunctionMismatchChildActor : ACoverageUFunctionMismatchBaseActor
{
	UFUNCTION(BlueprintOverride)
	int ComputeValue(FString Value)
	{
		return Value.Len();
	}
}
