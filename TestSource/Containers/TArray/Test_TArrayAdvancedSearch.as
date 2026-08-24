// Theme: Containers.TArray. WorldStory: last index of 5 is 4; Contains 5 true 100 false;
// IsValidIndex(5) true, (10) false. FixtureIsolated.

UCLASS()
class ACoverageTArraySearchActor : AActor
{
	UPROPERTY()
	int FindLastResult;

	UPROPERTY()
	int ContainsTrue;

	UPROPERTY()
	int ContainsFalse;

	UPROPERTY()
	int IsValidTrue;

	UPROPERTY()
	int IsValidFalse;

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
		int LastIndex = -1;
		for (int i = 0; i < Numbers.Num(); i++)
		{
			if (Numbers[i] == 5)
			{
				LastIndex = i;
			}
		}
		FindLastResult = LastIndex;
		bool HasFive = Numbers.Contains(5);
		bool HasHundred = Numbers.Contains(100);
		ContainsTrue = HasFive ? 1 : 0;
		ContainsFalse = HasHundred ? 1 : 0;
		bool Valid5 = Numbers.IsValidIndex(5);
		bool Valid10 = Numbers.IsValidIndex(10);
		IsValidTrue = Valid5 ? 1 : 0;
		IsValidFalse = Valid10 ? 1 : 0;
	}
}
