/**
 * Float and double members inside TArray and TMap containers, filled during
 * BeginPlay. The observers confirm the defaults are empty and that a script-side
 * fill lands the expected values.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.FloatContainerProperties
 * @Harness UClass
 * @Tag Language.Syntax.EdgeCases.FloatContainerProperties
 * @Provenance C++: AngelscriptCoverageFloatPropertyTests.cpp::FloatContainerProperties
 * @Provenance sha256=5a9ed8771832eb66db86015f3cd3efc461c26659ac2dc39b9efb6fb5c9717ee2; lines 564-597.
 * @Provenance Oracle after BeginPlay: FloatArray [1.1, 2.2, 3.3]; DoubleArray [4.4, 5.5];
 * @Provenance IntToFloatMap 10->100.5, 20->200.5; StringToDoubleMap Pi and E.
 * @Provenance Extra: local construct leaves empty containers. FixtureIsolated.
 */

UCLASS()
class ACoverageFloatContainerActor : AActor
{
	UPROPERTY()
	TArray<float> FloatArray;

	UPROPERTY()
	TArray<double> DoubleArray;

	UPROPERTY()
	TMap<int, float> IntToFloatMap;

	UPROPERTY()
	TMap<FString, double> StringToDoubleMap;

	/**
	 * Fills every container with its oracle values.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing; all four containers are populated
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		FloatArray.Add(1.1f);
		FloatArray.Add(2.2f);
		FloatArray.Add(3.3f);

		DoubleArray.Add(4.4);
		DoubleArray.Add(5.5);

		IntToFloatMap.Add(10, 100.5f);
		IntToFloatMap.Add(20, 200.5f);

		StringToDoubleMap.Add("Pi", 3.141592653589793);
		StringToDoubleMap.Add("E", 2.718281828459045);
	}

	/**
	 * Observe that a locally constructed actor leaves every container empty.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return true when all four containers report 0
	 * @Boundary default construction
	 */
	UFUNCTION()
	bool FloatContainersDefaultToEmpty()
	{
		if (FloatArray.Num() != 0)
		{
			return false;
		}

		if (DoubleArray.Num() != 0)
		{
			return false;
		}

		if (IntToFloatMap.Num() != 0)
		{
			return false;
		}

		return StringToDoubleMap.Num() == 0;
	}

	/**
	 * Observe that a script-side fill lands the expected values.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs both arrays filled from script
	 * @Return true when both counts and first elements match
	 * @Boundary script fill
	 */
	UFUNCTION()
	bool FloatContainersScriptFillBoundary()
	{
		FloatArray.Add(1.1f);
		FloatArray.Add(2.2f);
		FloatArray.Add(3.3f);
		DoubleArray.Add(4.4);
		DoubleArray.Add(5.5);

		if (FloatArray.Num() != 3)
		{
			return false;
		}

		if (!Math::IsNearlyEqual(FloatArray[0], 1.1, 0.001))
		{
			return false;
		}

		if (DoubleArray.Num() != 2)
		{
			return false;
		}

		return Math::IsNearlyEqual(DoubleArray[0], 4.4, 0.001);
	}
}
