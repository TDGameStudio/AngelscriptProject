// Theme: Containers.TArray. NegativeDiagnostic: nested TArray<TArray<bool>>
// reflected properties are unsupported.
// C++: AngelscriptCoverageBoolPropertyTests.cpp::BoolNestedArrayProperties
// Expected: compile Error and diagnostic
// "Attempting to instantiate invalid template type 'TArray<bool[]>': Containers cannot be nested in other containers".
// Isolate the failing UCLASS. DiagnosticOnly.

UCLASS()
class ACoverageBoolNestedArrayActor : AActor
{
	UPROPERTY()
	TArray<TArray<bool>> Matrix;
}
