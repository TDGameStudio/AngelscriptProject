/**
 * The remaining int widths inside arrays, maps and sets: int8 through uint64,
 * signed and unsigned, including extreme values like 127 and 65535.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.IntContainerPropertiesExtended
 * @Harness UClass
 * @Tag Language.Syntax.EdgeCases.IntContainerPropertiesExtended
 * @Provenance C++: AngelscriptCoverageIntPropertyTests.cpp::IntContainerPropertiesExtended
 * @Provenance sha256=0cf0c35e89ce20ebc3dbb1e44ad6c538c2bad4dd10c64345b928ebc059ddae14; lines 665-752.
 * @Provenance Oracle after BeginPlay: Int8Array[-42, 127]; Int16Array[-12345, 30000];
 * @Provenance UInt16Array[60000, 65535]; UIntArray[3000000000, 4000000000]; UInt64Array one key;
 * @Provenance StringToIntMap Alpha=100; Int8ToStringMap 127="MaxInt8"; sets contain the Add values.
 * @Provenance Extra: local construct keeps empty containers.
 * @Provenance FixtureIsolated. Actor owns container storage.
 */

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

	/**
	 * Fills every remaining-width container with its oracle values.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing; all thirteen containers are populated
	 */
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

	/**
	 * Observe that a locally constructed actor leaves the containers empty.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return true when the sampled containers report 0
	 * @Boundary default construction
	 */
	UFUNCTION()
	bool IntContainerExtDefaultEmpty()
	{
		if (Int8Array.Num() != 0)
		{
			return false;
		}

		if (StringToIntMap.Num() != 0)
		{
			return false;
		}

		return IntSet.Num() == 0;
	}

	/**
	 * Observe the populated state after BeginPlay runs.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs BeginPlay() then the sampled containers
	 * @Return true when every sampled element matches
	 */
	UFUNCTION()
	bool IntContainerExtPopulatedAfterBeginPlay()
	{
		BeginPlay();

		if (Int8Array[0] != -42)
		{
			return false;
		}

		if (Int8Array[1] != 127)
		{
			return false;
		}

		if (Int16Array[0] != -12345)
		{
			return false;
		}

		if (Int16Array[1] != 30000)
		{
			return false;
		}

		if (UInt16Array[0] != 60000)
		{
			return false;
		}

		if (UInt16Array[1] != 65535)
		{
			return false;
		}

		if (UIntArray[0] != 3000000000)
		{
			return false;
		}

		if (UIntArray[1] != 4000000000)
		{
			return false;
		}

		if (StringToIntMap["Alpha"] != 100)
		{
			return false;
		}

		if (Int8ToStringMap[127] != "MaxInt8")
		{
			return false;
		}

		if (!IntSet.Contains(10))
		{
			return false;
		}

		return Int8Set.Contains(0);
	}
}
