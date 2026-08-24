// Theme: Containers.TArray. NegativeDiagnostic three-level nested array property.

UCLASS()
class ACoverageTArrayDeepNestedActor : AActor
{
	UPROPERTY()
	TArray<TArray<TArray<int>>> Matrix;
}
