// Theme: Containers.TMap. WorldStory: overwrite Add, Contains, Remove, GetKeys/GetValues.
// C++ VerifyByPath: bContainsOverwrittenKey true, OverwrittenValue "TwoUpdated",
// bRemovedExistingKey true, bRemovedMissingKey false, bContainsRemovedKey false, FinalSize 2,
// Keys Num 2. Extra: FinalSize 0 until BeginPlay. FixtureIsolated.

UCLASS()
class ACoverageTMapOverwriteLookupActor : AActor
{
	UPROPERTY()
	TMap<int, FString> Values;

	UPROPERTY()
	FString OverwrittenValue;

	UPROPERTY()
	bool bContainsOverwrittenKey = false;

	UPROPERTY()
	bool bRemovedExistingKey = false;

	UPROPERTY()
	bool bRemovedMissingKey = true;

	UPROPERTY()
	bool bContainsRemovedKey = true;

	UPROPERTY()
	TArray<int> Keys;

	UPROPERTY()
	TArray<FString> OutValues;

	UPROPERTY()
	int FinalSize = 0;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Values.Add(1, "One");
		Values.Add(2, "Two");
		Values.Add(2, "TwoUpdated");
		Values.Add(3, "Three");

		bContainsOverwrittenKey = Values.Contains(2);
		Values.Find(2, OverwrittenValue);

		bRemovedExistingKey = Values.Remove(1);
		bRemovedMissingKey = Values.Remove(99);
		bContainsRemovedKey = Values.Contains(1);

		Values.GetKeys(Keys);
		Values.GetValues(OutValues);
		FinalSize = Values.Num();
	}
}
