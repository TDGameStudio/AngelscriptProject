// Theme: Containers.TMap. WorldStory: Find(out), Remove, GetKeys/GetValues, index, Add.
// C++ VerifyByPath: bFoundKey true, FoundValue "Two", bRemovedKey true, bContainsRemovedKey false,
// TestMap Num 4, Keys/Values Num 3 (before index-add), IndexAccessValue "One", key 5 "Five".
// Extra: FoundValue default empty until BeginPlay. FixtureIsolated.

UCLASS()
class ACoverageTMapAdvancedActor : AActor
{
	UPROPERTY()
	TMap<int, FString> TestMap;

	UPROPERTY()
	bool bFoundKey = false;

	UPROPERTY()
	FString FoundValue;

	UPROPERTY()
	bool bRemovedKey = false;

	UPROPERTY()
	bool bContainsRemovedKey = true;

	UPROPERTY()
	TArray<int> Keys;

	UPROPERTY()
	TArray<FString> Values;

	UPROPERTY()
	FString IndexAccessValue;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		// Setup test data
		TestMap.Add(1, "One");
		TestMap.Add(2, "Two");
		TestMap.Add(3, "Three");
		TestMap.Add(4, "Four");

		// Test Find() - copies the value to an out parameter.
		bFoundKey = TestMap.Find(2, FoundValue);

		// Test Remove()
		bRemovedKey = TestMap.Remove(3);
		bContainsRemovedKey = TestMap.Contains(3);

		// Test GetKeys()
		TestMap.GetKeys(Keys);

		// Test GetValues()
		TestMap.GetValues(Values);

		// Test index access (Map[Key])
		IndexAccessValue = TestMap[1];

		// Add a new key after index-read coverage.
		TestMap.Add(5, "Five");
	}
}
