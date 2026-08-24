// Theme: Containers.TArray. NegativeDiagnostic: TMap<int, TArray<int>> property.
// C++ ExpectNestedContainerRejected. DiagnosticOnly.

UCLASS()
class ACoverageMapOfArraysActor : AActor
{
	UPROPERTY()
	TMap<int, TArray<int>> GroupedData;
}
