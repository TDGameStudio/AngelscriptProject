// Theme: Containers.TArray. NegativeDiagnostic: nested TArray<TArray<int>> property.
// C++ ExpectNestedContainerRejected. Isolate the failing UCLASS. DiagnosticOnly.

UCLASS()
class ACoverageNestedArrayActor : AActor
{
	UPROPERTY()
	TArray<TArray<int>> Matrix;
}
