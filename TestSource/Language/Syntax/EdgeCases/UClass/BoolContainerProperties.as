/**
 * Boolean members inside UE containers, filled during BeginPlay: an array, three
 * maps keyed and valued on bool in both directions, and a set that must dedupe a
 * repeated true. A locally constructed actor leaves all of them empty.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.BoolContainerProperties
 * @Harness UClass
 * @Tag Language.Syntax.EdgeCases.BoolContainerProperties
 * @Provenance C++: AngelscriptCoverageBoolPropertyTests.cpp::BoolContainerProperties
 * @Provenance sha256=5abc62565f51b3c98025408ed063633b1dad39d33fd2778294781bd40e25d168; lines 249-289.
 * @Provenance Oracle after spawn+BeginPlay: BoolArray 3 elems true/false/true; IntToBoolMap
 * @Provenance 2 entries; BoolToIntMap true=100 false=200; StringToBoolMap Enabled/Hidden;
 * @Provenance BoolSet size 2 after duplicate true. Extra: local construct leaves containers
 * @Provenance empty. FixtureIsolated.
 */

UCLASS()
class ACoverageBoolContainerActor : AActor
{
	UPROPERTY()
	TArray<bool> BoolArray;

	UPROPERTY()
	TMap<int, bool> IntToBoolMap;

	UPROPERTY()
	TMap<bool, int> BoolToIntMap;

	UPROPERTY()
	TMap<FString, bool> StringToBoolMap;

	UPROPERTY()
	TSet<bool> BoolSet;

	/**
	 * Fills every container.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing; all five containers are populated
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		BoolArray.Add(true);
		BoolArray.Add(false);
		BoolArray.Add(true);

		IntToBoolMap.Add(1, true);
		IntToBoolMap.Add(2, false);

		BoolToIntMap.Add(true, 100);
		BoolToIntMap.Add(false, 200);

		StringToBoolMap.Add("Enabled", true);
		StringToBoolMap.Add("Hidden", false);

		BoolSet.Add(true);
		BoolSet.Add(false);
		BoolSet.Add(true);  // Duplicate
	}

	/**
	 * Observe that a locally constructed actor leaves every container empty.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a locally constructed actor
	 * @Return true when all five containers report 0
	 * @Boundary default construction
	 */
	UFUNCTION()
	bool BoolContainersDefaultToEmpty()
	{
		if (BoolArray.Num() != 0)
		{
			return false;
		}

		if (IntToBoolMap.Num() != 0)
		{
			return false;
		}

		if (BoolToIntMap.Num() != 0)
		{
			return false;
		}

		if (StringToBoolMap.Num() != 0)
		{
			return false;
		}

		return BoolSet.Num() == 0;
	}

	/**
	 * Observe the contents of every container after BeginPlay.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs BeginPlay() then all five containers
	 * @Return true when every element, entry and set member matches
	 */
	UFUNCTION()
	bool BoolContainersHoldExpectedValues()
	{
		BeginPlay();

		bool IntTrue = false;
		int TrueMapped = 0;
		int FalseMapped = 0;
		bool Enabled = false;
		bool Hidden = true;

		if (BoolArray.Num() != 3)
		{
			return false;
		}

		if (BoolArray[0] != true)
		{
			return false;
		}

		if (BoolArray[1] != false)
		{
			return false;
		}

		if (BoolArray[2] != true)
		{
			return false;
		}

		if (IntToBoolMap.Num() != 2)
		{
			return false;
		}

		if (!IntToBoolMap.Find(1, IntTrue))
		{
			return false;
		}

		if (IntTrue != true)
		{
			return false;
		}

		if (BoolToIntMap.Num() != 2)
		{
			return false;
		}

		if (!BoolToIntMap.Find(true, TrueMapped))
		{
			return false;
		}

		if (TrueMapped != 100)
		{
			return false;
		}

		if (!BoolToIntMap.Find(false, FalseMapped))
		{
			return false;
		}

		if (FalseMapped != 200)
		{
			return false;
		}

		if (StringToBoolMap.Num() != 2)
		{
			return false;
		}

		if (!StringToBoolMap.Find("Enabled", Enabled))
		{
			return false;
		}

		if (Enabled != true)
		{
			return false;
		}

		if (!StringToBoolMap.Find("Hidden", Hidden))
		{
			return false;
		}

		if (Hidden != false)
		{
			return false;
		}

		if (BoolSet.Num() != 2)
		{
			return false;
		}

		if (!BoolSet.Contains(true))
		{
			return false;
		}

		return BoolSet.Contains(false);
	}
}
