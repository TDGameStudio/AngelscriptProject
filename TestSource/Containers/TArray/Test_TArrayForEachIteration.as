// Theme: Containers.TArray. WorldStory: for-each by value sum 15; by-ref doubles;
// iterator walks modified values. Extra: empty iterator count 0. FixtureIsolated.

UCLASS()
class ACoverageTArrayForEachActor : AActor
{
	UPROPERTY()
	int SumByValue;

	UPROPERTY()
	int SumByReference;

	UPROPERTY()
	TArray<int> ModifiedArray;

	UPROPERTY()
	int ExplicitIteratorSum = 0;

	UPROPERTY()
	int ExplicitIteratorCount = 0;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		TArray<int> Values;
		Values.Add(1);
		Values.Add(2);
		Values.Add(3);
		Values.Add(4);
		Values.Add(5);

		SumByValue = 0;
		for (int Val : Values)
		{
			SumByValue += Val;
		}

		SumByReference = 0;
		for (int& Val : Values)
		{
			Val *= 2;
			SumByReference += Val;
		}

		TArrayIterator<int> It = Values.Iterator();
		while (It.CanProceed)
		{
			ExplicitIteratorSum += It.Proceed();
			ExplicitIteratorCount++;
		}

		ModifiedArray = Values;
	}
}
