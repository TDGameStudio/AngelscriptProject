// Theme: Language.Syntax.EdgeCases. WorldStory: remaining int widths in arrays/maps/sets.
// C++: AngelscriptCoverageIntPropertyTests.cpp::IntContainerPropertiesExtended
// sha256=0cf0c35e89ce20ebc3dbb1e44ad6c538c2bad4dd10c64345b928ebc059ddae14; lines 665-752.
// Oracle after BeginPlay: Int8Array[-42, 127]; Int16Array[-12345, 30000];
// UInt16Array[60000, 65535]; UIntArray[3000000000, 4000000000]; UInt64Array one key;
// StringToIntMap Alpha=100; Int8ToStringMap 127="MaxInt8"; sets contain the Add values.
// Extra: local construct keeps empty containers.
// FixtureIsolated. Actor owns container storage.

UCLASS()
class ACoverageIntContainerExtActor : AActor
{
	UPROPERTY()
	TArray<int8> Int8Array;

	UPROPERTY()
	TArray<int16> Int16Array;

	UPROPERTY()
	TArray<uint16> UInt16Array;

	UPROPERTY()
	TArray<uint> UIntArray;

	UPROPERTY()
	TArray<uint64> UInt64Array;

	UPROPERTY()
	TMap<FString, int> StringToIntMap;

	UPROPERTY()
	TMap<int8, FString> Int8ToStringMap;

	UPROPERTY()
	TMap<int64, FString> Int64ToStringMap;

	UPROPERTY()
	TMap<uint, FString> UIntToStringMap;

	UPROPERTY()
	TSet<int> IntSet;

	UPROPERTY()
	TSet<int8> Int8Set;

	UPROPERTY()
	TSet<int64> Int64Set;

	UPROPERTY()
	TSet<uint> UIntSet;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Int8Array.Add(-42);
		Int8Array.Add(127);

		Int16Array.Add(-12345);
		Int16Array.Add(30000);

		UInt16Array.Add(60000);
		UInt16Array.Add(65535);

		UIntArray.Add(3000000000);
		UIntArray.Add(4000000000);

		UInt64Array.Add(10000000000000000000);

		StringToIntMap.Add("Alpha", 100);
		StringToIntMap.Add("Beta", 200);

		Int8ToStringMap.Add(-10, "NegTen");
		Int8ToStringMap.Add(127, "MaxInt8");

		Int64ToStringMap.Add(9000000000, "Billion");
		Int64ToStringMap.Add(-9000000000, "NegBillion");

		UIntToStringMap.Add(3000000000, "Three");
		UIntToStringMap.Add(4000000000, "Four");

		IntSet.Add(5);
		IntSet.Add(10);
		IntSet.Add(15);

		Int8Set.Add(-42);
		Int8Set.Add(0);
		Int8Set.Add(127);

		Int64Set.Add(1000000000000);
		Int64Set.Add(2000000000000);

		UIntSet.Add(3000000000);
		UIntSet.Add(4000000000);
	}

	UFUNCTION()
	bool ObservePopulated()
	{
		return Int8Array[0] == -42
			&& Int8Array[1] == 127
			&& Int16Array[0] == -12345
			&& Int16Array[1] == 30000
			&& UInt16Array[0] == 60000
			&& UInt16Array[1] == 65535
			&& UIntArray[0] == 3000000000
			&& UIntArray[1] == 4000000000
			&& StringToIntMap["Alpha"] == 100
			&& Int8ToStringMap[127] == "MaxInt8"
			&& IntSet.Contains(10)
			&& Int8Set.Contains(0);
	}
}

bool Observe_IntContainerExt_DefaultEmpty(ACoverageIntContainerExtActor Actor)
{
	if (Actor is null)
	{
		throw("Test_IntContainerPropertiesExtended setup: required Actor is null");
	}
	return Actor.Int8Array.Num() == 0 && Actor.StringToIntMap.Num() == 0 && Actor.IntSet.Num() == 0;
}

bool Observe_IntContainerExt_AfterBeginPlay(ACoverageIntContainerExtActor Actor)
{
	if (Actor is null)
	{
		throw("Test_IntContainerPropertiesExtended setup: required Actor is null");
	}
	Actor.BeginPlay();
	return Actor.ObservePopulated();
}
