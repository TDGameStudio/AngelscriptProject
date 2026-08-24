// Theme: Language.Syntax.EdgeCases. WorldStory: remaining TMap/TSet int-width completion.
// C++: AngelscriptCoverageIntPropertyTests.cpp::IntContainerWidthCompletion
// sha256=34a6748544160aa3e51dd72c7d123a1f2878dd3c93733862f61b834aae53d27e; lines 886-961.
// Oracle after BeginPlay: StringToInt8Map["Int8"]=-12; StringToInt16Map["Int16"]=-1234;
// StringToInt64Map["Int64"]=-9000000000; StringToUInt8Map["UInt8"]=250.
// Extra: local construct keeps empty maps/sets.
// FixtureIsolated. Actor owns container storage.

UCLASS()
class ACoverageIntContainerWidthsActor : AActor
{
	UPROPERTY()
	TMap<FString, int8> StringToInt8Map;

	UPROPERTY()
	TMap<FString, int16> StringToInt16Map;

	UPROPERTY()
	TMap<FString, int64> StringToInt64Map;

	UPROPERTY()
	TMap<FString, uint8> StringToUInt8Map;

	UPROPERTY()
	TMap<FString, uint16> StringToUInt16Map;

	UPROPERTY()
	TMap<FString, uint> StringToUIntMap;

	UPROPERTY()
	TMap<FString, uint64> StringToUInt64Map;

	UPROPERTY()
	TMap<int16, FString> Int16ToStringMap;

	UPROPERTY()
	TMap<uint8, FString> UInt8ToStringMap;

	UPROPERTY()
	TMap<uint16, FString> UInt16ToStringMap;

	UPROPERTY()
	TMap<uint64, FString> UInt64ToStringMap;

	UPROPERTY()
	TSet<int16> Int16Set;

	UPROPERTY()
	TSet<uint8> UInt8Set;

	UPROPERTY()
	TSet<uint16> UInt16Set;

	UPROPERTY()
	TSet<uint64> UInt64Set;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		StringToInt8Map.Add("Int8", -12);
		StringToInt16Map.Add("Int16", -1234);
		StringToInt64Map.Add("Int64", -9000000000);
		StringToUInt8Map.Add("UInt8", 250);
		StringToUInt16Map.Add("UInt16", 60000);
		StringToUIntMap.Add("UInt", 3000000000);
		StringToUInt64Map.Add("UInt64", 12000000000000000000);

		Int16ToStringMap.Add(-1234, "Int16Key");
		UInt8ToStringMap.Add(250, "UInt8Key");
		UInt16ToStringMap.Add(60000, "UInt16Key");
		UInt64ToStringMap.Add(12000000000000000000, "UInt64Key");

		Int16Set.Add(-1234);
		Int16Set.Add(30000);
		UInt8Set.Add(1);
		UInt8Set.Add(250);
		UInt16Set.Add(60000);
		UInt16Set.Add(65535);
		UInt64Set.Add(10000000000000000000);
		UInt64Set.Add(12000000000000000000);
	}

	UFUNCTION()
	bool ObservePopulated()
	{
		return StringToInt8Map["Int8"] == -12
			&& StringToInt16Map["Int16"] == -1234
			&& StringToInt64Map["Int64"] == -9000000000
			&& StringToUInt8Map["UInt8"] == 250
			&& Int16ToStringMap[-1234] == "Int16Key"
			&& UInt8Set.Contains(250);
	}
}

bool Observe_IntContainerWidths_DefaultEmpty(ACoverageIntContainerWidthsActor Actor)
{
	if (Actor is null)
	{
		throw("Test_IntContainerWidthCompletion setup: required Actor is null");
	}
	return Actor.StringToInt8Map.Num() == 0 && Actor.Int16Set.Num() == 0 && Actor.UInt64Set.Num() == 0;
}

bool Observe_IntContainerWidths_AfterBeginPlay(ACoverageIntContainerWidthsActor Actor)
{
	if (Actor is null)
	{
		throw("Test_IntContainerWidthCompletion setup: required Actor is null");
	}
	Actor.BeginPlay();
	return Actor.ObservePopulated();
}
