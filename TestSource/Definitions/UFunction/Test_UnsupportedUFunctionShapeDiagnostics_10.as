// Theme: Definitions.UFunction. NegativeDiagnostic: BlueprintOverride parent is not BlueprintEvent.
// C++: AngelscriptCoverageUFunctionTests.cpp::UnsupportedUFunctionShapeDiagnostics case override non-event parent.
// Expected diagnostic: "BlueprintOverride method NotAnEvent in class ACoverageUFunctionNonEventChildActor is not marked BlueprintEvent in superclass ACoverageUFunctionNonEventBaseActor."
// Isolate this failing program. DiagnosticOnly.

UCLASS()
class ACoverageUFunctionNonEventBaseActor : AActor
{
	UFUNCTION(BlueprintCallable)
	void NotAnEvent()
	{
	}
}

UCLASS()
class ACoverageUFunctionNonEventChildActor : ACoverageUFunctionNonEventBaseActor
{
	UFUNCTION(BlueprintOverride)
	void NotAnEvent()
	{
	}
}
