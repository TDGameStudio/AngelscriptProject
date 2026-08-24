// Theme: Containers.TArray. WorldStory UFUNCTION array store/out writeback.
// C++: StoreAndReturn inverse; FillOutRotatorArray appends Zero then (30,60,90).
// Extra: empty AcceptRotatorArray LastArrayCount 0. FixtureIsolated.

UCLASS()
class ACoverageFRotatorFunctionArrayActor : AActor
{
	UPROPERTY()
	FRotator StoredRotator;

	UPROPERTY()
	TArray<FRotator> StoredRotators;

	UPROPERTY()
	int LastArrayCount = 0;

	UFUNCTION()
	FRotator StoreAndReturn(FRotator Value)
	{
		StoredRotator = Value;
		return StoredRotator.GetInverse();
	}

	UFUNCTION()
	int AcceptRotatorArray(const TArray<FRotator>&in Values)
	{
		LastArrayCount = Values.Num();
		StoredRotator = FRotator::ZeroRotator;
		for (FRotator Value : Values)
		{
			StoredRotator += Value;
		}
		return LastArrayCount;
	}

	UFUNCTION()
	TArray<FRotator> MakeRotatorArray(FRotator First, FRotator Second)
	{
		TArray<FRotator> Result;
		Result.Add(First);
		Result.Add(Second);
		StoredRotators = Result;
		return Result;
	}

	UFUNCTION()
	void FillOutRotatorArray(TArray<FRotator>&out Result)
	{
		Result.Add(FRotator::ZeroRotator);
		Result.Add(FRotator(30, 60, 90));
		StoredRotators = Result;
	}
}
