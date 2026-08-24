// Theme: Containers.TArray. WorldStory: Append 1,2,3 + 4,5 -> MergedSize 5;
// Append empty leaves size. FixtureIsolated.

UCLASS()
class ACoverageTArrayAppendActor : AActor
{
	UPROPERTY()
	int MergedSize;

	UPROPERTY()
	TArray<int> MergedArray;

	UPROPERTY()
	int AppendEmptyResult;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		TArray<int> Array1;
		Array1.Add(1);
		Array1.Add(2);
		Array1.Add(3);
		TArray<int> Array2;
		Array2.Add(4);
		Array2.Add(5);
		Array1.Append(Array2);
		MergedSize = Array1.Num();
		for (int i = 0; i < Array1.Num(); i++)
		{
			MergedArray.Add(Array1[i]);
		}
		TArray<int> EmptyArray;
		int BeforeSize = Array1.Num();
		Array1.Append(EmptyArray);
		AppendEmptyResult = (Array1.Num() == BeforeSize) ? 1 : 0;
	}
}
