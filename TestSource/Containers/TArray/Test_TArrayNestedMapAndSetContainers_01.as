// Theme: Containers.TArray. NegativeDiagnostic TArray<TMap<int,FString>>.

UCLASS()
class ACoverageTArrayNestedMapActor : AActor
{
	UPROPERTY()
	TArray<TMap<int, FString>> Rows;
}
