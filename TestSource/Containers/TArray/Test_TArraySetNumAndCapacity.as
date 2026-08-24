// Theme: Containers.TArray. WorldStory: SetNum 10 then 2; LastElement 0; Reset 0.
// Extra: empty before expand. FixtureIsolated.

UCLASS()
class ACoverageTArraySetNumActor : AActor
{
	UPROPERTY()
	int ExpandedSize;

	UPROPERTY()
	int ShrunkSize;

	UPROPERTY()
	int LastElement;

	UPROPERTY()
	int EmptyResetSize;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		TArray<int> Numbers;
		Numbers.Add(1);
		Numbers.Add(2);
		Numbers.Add(3);
		Numbers.SetNum(10);
		ExpandedSize = Numbers.Num();
		LastElement = Numbers[9];
		Numbers.SetNum(2);
		ShrunkSize = Numbers.Num();
		TArray<int> TestArray;
		for (int i = 0; i < 100; i++)
		{
			TestArray.Add(i);
		}
		TestArray.Empty();
		TestArray.Add(1);
		TestArray.Reset();
		EmptyResetSize = TestArray.Num();
	}
}
