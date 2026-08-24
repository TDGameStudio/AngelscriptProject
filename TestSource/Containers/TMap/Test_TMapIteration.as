// Theme: Containers.TMap. WorldStory: TMapIterator key/value walk.
// C++ VerifyByPath: KeySum=60, IterationCount=3, ConcatenatedValues length 3 containing A/B/C.
// Extra: KeySum/IterationCount default 0 until BeginPlay. FixtureIsolated.

UCLASS()
class ACoverageTMapIterationActor : AActor
{
	UPROPERTY()
	TMap<int, FString> TestMap;

	UPROPERTY()
	int KeySum = 0;

	UPROPERTY()
	FString ConcatenatedValues;

	UPROPERTY()
	int IterationCount = 0;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		TestMap.Add(10, "A");
		TestMap.Add(20, "B");
		TestMap.Add(30, "C");

		// Test explicit iterator over key-value pairs.
		TMapIterator<int, FString> It = TestMap.Iterator();
		while (It.CanProceed)
		{
			It.Proceed();
			KeySum += It.GetKey();
			ConcatenatedValues += It.GetValue();
			IterationCount++;
		}
	}
}
