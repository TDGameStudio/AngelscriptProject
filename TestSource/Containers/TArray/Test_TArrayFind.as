// Theme: Containers.TArray. WorldStory: FindIndex 100/200/300/999 -> 0,1,2,-1.
// Extra: first occurrence of duplicate 200. FixtureIsolated.

UCLASS()
class ACoverageTArrayFindActor : AActor
{
	UPROPERTY()
	int FindIndex1;

	UPROPERTY()
	int FindIndex2;

	UPROPERTY()
	int FindIndex3;

	UPROPERTY()
	int NotFoundIndex;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		TArray<int> Values;
		Values.Add(100);
		Values.Add(200);
		Values.Add(300);
		Values.Add(200);
		FindIndex1 = Values.FindIndex(100);
		FindIndex2 = Values.FindIndex(200);
		FindIndex3 = Values.FindIndex(300);
		NotFoundIndex = Values.FindIndex(999);
	}
}
