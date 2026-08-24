// Theme: Definitions.UFunction. NegativeDiagnostic: BlueprintCallable parent signature mismatch.
// C++: AngelscriptCoverageUFunctionTests.cpp::UnsupportedUFunctionShapeDiagnostics case callable parent signature.
// Expected diagnostic: "BlueprintCallable method ComputeValue in class ACoverageUFunctionCallableMismatchChildActor is specified in superclass ACoverageUFunctionCallableMismatchBaseActor with a different signature."
// Isolate this failing program. DiagnosticOnly.

UCLASS()
class ACoverageUFunctionCallableMismatchBaseActor : AActor
{
	UFUNCTION(BlueprintCallable)
	int ComputeValue(int Value)
	{
		return Value;
	}
}

UCLASS()
class ACoverageUFunctionCallableMismatchChildActor : ACoverageUFunctionCallableMismatchBaseActor
{
	UFUNCTION(BlueprintCallable)
	int ComputeValue(FString Value)
	{
		return Value.Len();
	}
}
