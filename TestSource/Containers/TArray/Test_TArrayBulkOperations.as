// Theme: Containers.TArray. WorldStory: 100 bulk adds; merge 150; unique 5.
// Extra: empty merge stays 0 before append. FixtureIsolated.

UCLASS()
class ACoverageTArrayBulkActor : AActor
{
	UPROPERTY()
	int BulkAddedSize;

	UPROPERTY()
	int ReservedCapacity;

	UPROPERTY()
	int MergedSize;

	UPROPERTY()
	int DuplicateRemoved;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		TArray<int> LargeArray;
		LargeArray.Reserve(100);
		ReservedCapacity = LargeArray.Max();
		for (int i = 0; i < 100; i++)
		{
			LargeArray.Add(i);
		}
		BulkAddedSize = LargeArray.Num();
		TArray<int> Array1;
		for (int i = 0; i < 50; i++)
		{
			Array1.Add(i);
		}
		TArray<int> Array2;
		for (int i = 50; i < 100; i++)
		{
			Array2.Add(i);
		}
		TArray<int> Array3;
		for (int i = 100; i < 150; i++)
		{
			Array3.Add(i);
		}
		TArray<int> Merged;
		Merged.Append(Array1);
		Merged.Append(Array2);
		Merged.Append(Array3);
		MergedSize = Merged.Num();
		TArray<int> WithDuplicates;
		WithDuplicates.Add(1);
		WithDuplicates.Add(2);
		WithDuplicates.Add(3);
		WithDuplicates.Add(2);
		WithDuplicates.Add(4);
		WithDuplicates.Add(3);
		WithDuplicates.Add(5);
		WithDuplicates.Add(1);
		TArray<int> NoDuplicates;
		for (int i = 0; i < WithDuplicates.Num(); i++)
		{
			NoDuplicates.AddUnique(WithDuplicates[i]);
		}
		DuplicateRemoved = NoDuplicates.Num();
	}
}
