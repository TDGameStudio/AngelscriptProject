// Theme: Containers.TArray. WorldStory: first 0 last 6 count 4; after Remove(5) size 3.
// Extra: empty FindIndex -1. FixtureIsolated.

UCLASS()
class ACoverageTArrayDuplicatesActor : AActor
{
	UPROPERTY()
	int FirstOccurrence;

	UPROPERTY()
	int LastOccurrence;

	UPROPERTY()
	int TotalOccurrences;

	UPROPERTY()
	int AfterRemoveSize;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		TArray<int> Numbers;
		Numbers.Add(5);
		Numbers.Add(10);
		Numbers.Add(5);
		Numbers.Add(15);
		Numbers.Add(5);
		Numbers.Add(20);
		Numbers.Add(5);
		FirstOccurrence = Numbers.FindIndex(5);
		int Last = -1;
		int Count = 0;
		for (int i = 0; i < Numbers.Num(); i++)
		{
			if (Numbers[i] == 5)
			{
				Last = i;
				Count++;
			}
		}
		LastOccurrence = Last;
		TotalOccurrences = Count;
		int Removed = Numbers.Remove(5);
		AfterRemoveSize = Numbers.Num();
	}
}
