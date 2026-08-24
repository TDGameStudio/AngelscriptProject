// Theme: Definitions.UFunction. NegativeDiagnostic: network specifier cannot mix with BlueprintOverride.
// C++: AngelscriptCoverageUFunctionTests.cpp::UnsupportedUFunctionShapeDiagnostics case network BlueprintOverride.
// Expected diagnostic: "UFUNCTION() Conflict cannot be both BlueprintEvent and BlueprintOverride."
// Isolate this failing program. DiagnosticOnly.

UCLASS()
class ACoverageUFunctionNetOverrideConflictActor : AActor
{
	UFUNCTION(Server, BlueprintOverride)
	void Conflict()
	{
	}
}
