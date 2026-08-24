// Theme: Containers.TArray. WorldStory: Swap(0,4) ints -> 50 first; strings Swap(0,2).
// Extra: empty not swapped. FixtureIsolated.

UCLASS()
class ACoverageTArraySwapActor : AActor
{
	UPROPERTY()
	TArray<int> SwappedArray;

	UPROPERTY()
	TArray<FString> StringSwapped;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		TArray<int> Numbers;
		Numbers.Add(10);
		Numbers.Add(20);
		Numbers.Add(30);
		Numbers.Add(40);
		Numbers.Add(50);
		Numbers.Swap(0, 4);
		for (int i = 0; i < Numbers.Num(); i++)
		{
			SwappedArray.Add(Numbers[i]);
		}
		TArray<FString> Words;
		Words.Add("First");
		Words.Add("Second");
		Words.Add("Third");
		Words.Swap(0, 2);
		for (int i = 0; i < Words.Num(); i++)
		{
			StringSwapped.Add(Words[i]);
		}
	}
}
