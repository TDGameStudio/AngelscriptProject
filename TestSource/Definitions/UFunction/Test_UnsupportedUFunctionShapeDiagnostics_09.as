// Theme: Definitions.UFunction. NegativeDiagnostic: BlueprintOverride with no parent event.
// C++: AngelscriptCoverageUFunctionTests.cpp::UnsupportedUFunctionShapeDiagnostics case missing override parent.
// Expected diagnostic: "BlueprintOverride method MissingOverride in class ACoverageUFunctionMissingOverrideChildActor does not exist in superclass ACoverageUFunctionMissingOverrideBaseActor."
// Isolate this failing program. DiagnosticOnly.

UCLASS()
class ACoverageUFunctionMissingOverrideBaseActor : AActor
{
}

UCLASS()
class ACoverageUFunctionMissingOverrideChildActor : ACoverageUFunctionMissingOverrideBaseActor
{
	UFUNCTION(BlueprintOverride)
	void MissingOverride()
	{
	}
}
