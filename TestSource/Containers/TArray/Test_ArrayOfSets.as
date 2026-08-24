// Theme: Containers.TArray. NegativeDiagnostic: TArray<TSet<int>> property.
// C++ ExpectNestedContainerRejected. DiagnosticOnly.

UCLASS()
class ACoverageArrayOfSetsActor : AActor
{
	UPROPERTY()
	TArray<TSet<int>> SetCollection;
}
