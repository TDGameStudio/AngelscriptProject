// Theme: Definitions.UFunction. NegativeDiagnostic: BlueprintEvent cannot also be BlueprintOverride.
// C++: AngelscriptCoverageUFunctionTests.cpp::UnsupportedUFunctionShapeDiagnostics case event/override conflict.
// Expected diagnostic: "UFUNCTION() Conflict cannot be both BlueprintEvent and BlueprintOverride."
// Isolate this failing program. DiagnosticOnly.

UCLASS()
class ACoverageUFunctionConflictActor : AActor
{
	UFUNCTION(BlueprintEvent, BlueprintOverride)
	void Conflict()
	{
	}
}
