/**
 * TSet Reset then re-add on a spawned actor. After BeginPlay: SizeBeforeReset==5,
 * SizeAfterReset==0, bReAddSuccess==true. Keep SizeBeforeReset / SizeAfterReset /
 * bReAddSuccess.
 *
 * @Theme Feature.PropertyAccess
 * @Subject PropertyAccess.TSetResetAndCapacity
 * @Harness UClass
 * @Tag Feature.PropertyAccess.TSetResetAndCapacity
 * @Provenance Theme: Feature.PropertyAccess. WorldStory TSet Reset then re-add.
 * @Provenance C++: AngelscriptCoverageTSetAdvancedTests.cpp::TSetResetAndCapacity
 * @Provenance After BeginPlay: SizeBeforeReset==5, SizeAfterReset==0, bReAddSuccess==true.
 * @Provenance Extra: local construct zeros/empty; copy independence.
 * @Provenance FixtureIsolated. Keep SizeBeforeReset / SizeAfterReset / bReAddSuccess.
 */

UCLASS()
class ACoverageTSetResetCapacityActor : AActor
{
	UPROPERTY()
	TSet<int> TestSet;

	UPROPERTY()
	int SizeBeforeReset = 0;

	UPROPERTY()
	int SizeAfterReset = 0;

	UPROPERTY()
	bool bReAddSuccess = false;

	/**
	 * WorldStory: BeginPlay fills TestSet, Reset, then re-adds 100 and 200.
	 *
	 * @Kind WorldStory
	 * @Covers PropertyAccess.TSetResetAndCapacity
	 * @Inputs none
	 * @Return SizeBeforeReset, SizeAfterReset, bReAddSuccess
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		// Add elements
		TestSet.Add(10);
		TestSet.Add(20);
		TestSet.Add(30);
		TestSet.Add(40);
		TestSet.Add(50);

		SizeBeforeReset = TestSet.Num();

		// Test Reset (clears but may preserve capacity)
		TestSet.Reset();
		SizeAfterReset = TestSet.Num();

		// Verify we can re-add elements after reset
		TestSet.Add(100);
		TestSet.Add(200);
		bReAddSuccess = (TestSet.Num() == 2) && TestSet.Contains(100) && TestSet.Contains(200);
	}

	/**
	 * Observe a locally constructed actor: empty set and zero/false flags.
	 *
	 * @Kind Observe
	 * @Covers PropertyAccess.TSetResetAndCapacity
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when TestSet is empty and every flag is at its initializer
	 * @Boundary local construct
	 */
	UFUNCTION()
	bool TSetReset_DefaultEmpty()
	{
		if (TestSet.Num() != 0)
		{
			return false;
		}
		if (SizeBeforeReset != 0)
		{
			return false;
		}
		if (SizeAfterReset != 0)
		{
			return false;
		}
		return !bReAddSuccess;
	}

	/**
	 * Observe that Reset and re-add on this actor leave another actor empty.
	 *
	 * @Kind Observe
	 * @Covers PropertyAccess.TSetResetAndCapacity
	 * @Inputs a second actor that must stay empty
	 * @Return true when this holds one member and the other stays empty
	 * @Param Second the other actor
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool TSetReset_CopyIndependence(ACoverageTSetResetCapacityActor Second)
	{
		if (Second is null)
		{
			throw("TSetResetAndCapacity setup: required Second is null");
		}
		TestSet.Add(10);
		TestSet.Reset();
		TestSet.Add(100);
		if (TestSet.Num() != 1)
		{
			return false;
		}
		return Second.TestSet.Num() == 0;
	}
}
