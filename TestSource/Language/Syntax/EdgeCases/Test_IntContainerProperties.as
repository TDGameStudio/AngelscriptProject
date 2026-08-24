// Theme: Language.Syntax.EdgeCases. WorldStory: int-family TArray/TMap filled in BeginPlay.
// C++: AngelscriptCoverageIntPropertyTests.cpp::IntContainerProperties VerifyByPath
// sha256=451b217a2b4a75b8eaa0ac9d0a521eb180e531fa700fa36cd11b8e492310a0db; lines 551-590.
// Oracle after BeginPlay: IntArray length 3, [0]=10 [2]=30; Int64Array[1]=2000000000000;
// ByteArray[1]=255; IntToIntMap length 2 and [2]=200; IntToStringMap[9]="Nine".
// Extra: local construct keeps empty containers (BeginPlay not run).
// FixtureIsolated. Actor owns container storage.

UCLASS()
class ACoverageIntContainerActor : AActor
{
	UPROPERTY()
	TArray<int> IntArray;

	UPROPERTY()
	TArray<int64> Int64Array;

	UPROPERTY()
	TArray<uint8> ByteArray;

	UPROPERTY()
	TMap<int, int> IntToIntMap;

	UPROPERTY()
	TMap<int, FString> IntToStringMap;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		IntArray.Add(10);
		IntArray.Add(20);
		IntArray.Add(30);

		Int64Array.Add(1000000000000);
		Int64Array.Add(2000000000000);

		ByteArray.Add(1);
		ByteArray.Add(255);

		IntToIntMap.Add(1, 100);
		IntToIntMap.Add(2, 200);

		IntToStringMap.Add(7, "Seven");
		IntToStringMap.Add(9, "Nine");
	}

	UFUNCTION()
	bool ObservePopulated()
	{
		return IntArray.Num() == 3
			&& IntArray[0] == 10
			&& IntArray[2] == 30
			&& Int64Array[1] == 2000000000000
			&& ByteArray[1] == 255
			&& IntToIntMap.Num() == 2
			&& IntToIntMap[2] == 200
			&& IntToStringMap[9] == "Nine";
	}
}

bool Observe_IntContainerProperties_DefaultEmpty(ACoverageIntContainerActor Actor)
{
	if (Actor is null)
	{
		throw("Test_IntContainerProperties setup: required Actor is null");
	}
	return Actor.IntArray.Num() == 0 && Actor.Int64Array.Num() == 0 && Actor.ByteArray.Num() == 0 && Actor.IntToIntMap.Num() == 0 && Actor.IntToStringMap.Num() == 0;
}

bool Observe_IntContainerProperties_AfterBeginPlay(ACoverageIntContainerActor Actor)
{
	if (Actor is null)
	{
		throw("Test_IntContainerProperties setup: required Actor is null");
	}
	Actor.BeginPlay();
	return Actor.ObservePopulated();
}
