// Theme: Containers.TArray. WorldStory: empty Num 0, FindIndex -1, Contains false;
// single element 42 after sort. FixtureIsolated.

UCLASS()
class ACoverageTArrayEdgeCasesActor : AActor
{
	UPROPERTY()
	int EmptyArraySize;

	UPROPERTY()
	int FindInEmpty;

	UPROPERTY()
	int ContainsInEmpty;

	UPROPERTY()
	int SingleElementSize;

	UPROPERTY()
	int SingleElementValue;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		TArray<int> EmptyArray;
		EmptyArraySize = EmptyArray.Num();
		FindInEmpty = EmptyArray.FindIndex(5);
		ContainsInEmpty = EmptyArray.Contains(5) ? 1 : 0;
		EmptyArray.Sort();
		TArray<int> SingleArray;
		SingleArray.Add(42);
		SingleElementSize = SingleArray.Num();
		SingleArray.Sort();
		SingleElementValue = SingleArray[0];
	}
}
