/**
 * @version v1
 * @summary Int-family members inside TArray and TMap containers, filled during BeginPlay: three int lanes, an int64 lane, a byte lane, and two maps keyed by int.
 * @topic Language
 */
/**
 * @version root
 * @summary Int-family members inside TArray and TMap containers, filled during BeginPlay: three int lanes, an int64 lane, a byte lane, and two maps keyed by int.
 * @topic Baseline
 */
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

	/**
	 * Fills every container with its oracle values.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing; all five containers are populated
	 */
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

	/**
	 * Observe that a locally constructed actor leaves every container empty.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return true when all five containers report 0
	 * @Boundary default construction
	 */
	UFUNCTION()
	bool IntContainersDefaultToEmpty()
	{
		if (IntArray.Num() != 0)
		{
			return false;
		}

		if (Int64Array.Num() != 0)
		{
			return false;
		}

		if (ByteArray.Num() != 0)
		{
			return false;
		}

		if (IntToIntMap.Num() != 0)
		{
			return false;
		}

		return IntToStringMap.Num() == 0;
	}

	/**
	 * Observe the populated state after BeginPlay runs.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs BeginPlay() then every container
	 * @Return true when every count and element matches
	 */
	UFUNCTION()
	bool IntContainersPopulatedAfterBeginPlay()
	{
		BeginPlay();

		if (IntArray.Num() != 3)
		{
			return false;
		}

		if (IntArray[0] != 10)
		{
			return false;
		}

		if (IntArray[2] != 30)
		{
			return false;
		}

		if (Int64Array[1] != 2000000000000)
		{
			return false;
		}

		if (ByteArray[1] != 255)
		{
			return false;
		}

		if (IntToIntMap.Num() != 2)
		{
			return false;
		}

		if (IntToIntMap[2] != 200)
		{
			return false;
		}

		return IntToStringMap[9] == "Nine";
	}
}
/** @end */
