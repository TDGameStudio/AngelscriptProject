// Theme: Definitions.UProperty. WorldStory: local TArray/TMap (not UPROPERTY) still write reflected results.
// C++: VerifyByPath LocalArrayResult 3; TempMapResult 2.
// Extra: empty local array/map Num is 0. FixtureIsolated.

UCLASS()
class ACoverageContainerNonUPropActor : AActor
{
	UPROPERTY()
	int LocalArrayResult;

	UPROPERTY()
	int TempMapResult;

	void ProcessLocalArray()
	{
		Print("=== ProcessLocalArray ===");
		TArray<int> LocalArray;
		LocalArray.Add(100);
		LocalArray.Add(200);
		LocalArray.Add(300);
		Print("Local array size: " + LocalArray.Num());
		LocalArrayResult = LocalArray.Num();
	}

	void UseTempMap()
	{
		Print("=== UseTempMap ===");
		TMap<int, int> TempMap;
		TempMap.Add(1, 10);
		TempMap.Add(2, 20);
		TempMapResult = TempMap.Num();
		Print("Temp map size: " + TempMapResult);
	}

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Print("=== Non-UPROPERTY Containers Test ===");
		ProcessLocalArray();
		UseTempMap();
	}
}

int Observe_EmptyLocalArrayNum()
{
	TArray<int> LocalArray;
	return LocalArray.Num();
}

int Observe_EmptyTempMapNum()
{
	TMap<int, int> TempMap;
	return TempMap.Num();
}
