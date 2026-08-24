// Theme: Containers.TArray. NegativeDiagnostic: TArray<TMap<int,FString>> property.
// C++ ExpectNestedContainerRejected. DiagnosticOnly.

UCLASS()
class ACoverageArrayOfMapsActor : AActor
{
	UPROPERTY()
	TArray<TMap<int, FString>> Dictionaries;
}
