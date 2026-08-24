// Theme: Containers.TArray. NegativeDiagnostic: three-level nested TArray property.
// C++ ExpectNestedContainerRejected. DiagnosticOnly.

UCLASS()
class ACoverageDeepNestedArrayActor : AActor
{
	UPROPERTY()
	TArray<TArray<TArray<int>>> Matrix;
}
