// Theme: Definitions.UFunction. NegativeDiagnostic: UFUNCTION cannot return a reference.
// C++: AngelscriptCoverageUFunctionTests.cpp::UnsupportedUFunctionShapeDiagnostics case return reference.
// Expected diagnostic: "UFUNCTIONs cannot return references, function ReturnStoredValueRef in class ACoverageUFunctionReferenceReturnActor"
// Isolate this failing program. DiagnosticOnly.

UCLASS()
class ACoverageUFunctionReferenceReturnActor : AActor
{
	UPROPERTY()
	int StoredValue = 7;

	UFUNCTION()
	int& ReturnStoredValueRef()
	{
		return StoredValue;
	}
}
