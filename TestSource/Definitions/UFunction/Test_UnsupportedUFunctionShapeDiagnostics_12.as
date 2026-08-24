// Theme: Definitions.UFunction. NegativeDiagnostic: UFUNCTION names must be unique; no overloads.
// C++: AngelscriptCoverageUFunctionTests.cpp::UnsupportedUFunctionShapeDiagnostics case duplicate UFUNCTION name.
// Expected diagnostic: "Multiple methods with name Duplicate in class ACoverageUFunctionDuplicateNameActor found. UFUNCTION()s must have unique names."
// Isolate this failing program. DiagnosticOnly.

UCLASS()
class ACoverageUFunctionDuplicateNameActor : AActor
{
	UFUNCTION()
	void Duplicate()
	{
	}

	UFUNCTION()
	void Duplicate(int Value)
	{
	}
}
