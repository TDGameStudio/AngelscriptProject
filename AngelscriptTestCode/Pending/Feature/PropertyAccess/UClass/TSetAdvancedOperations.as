/**
 * @version v1
 * @summary TSet Contains/Remove/Empty on a spawned actor. C++ CompileScriptModule + spawn + BeginPlay, then VerifyByPath: bContainsElement==true, bRemoved20==true, bRemoved40==true, SizeBeforeEmpty==3, SizeAfterEmpty==0. Keep those.
 * @topic Feature
 */
/**
 * @version root
 * @summary TSet Contains/Remove/Empty on a spawned actor. C++ CompileScriptModule + spawn + BeginPlay, then VerifyByPath: bContainsElement==true, bRemoved20==true, bRemoved40==true, SizeBeforeEmpty==3, SizeAfterEmpty==0. Keep those.
 * @topic Baseline
 */
UCLASS()
class ACoverageTSetAdvancedActor : AActor
{
	UPROPERTY()
	TSet<int> TestSet;

	UPROPERTY()
	bool bContainsElement = false;

	UPROPERTY()
	bool bRemoved20 = false;

	UPROPERTY()
	bool bRemoved40 = false;

	UPROPERTY()
	int SizeBeforeEmpty = 0;

	UPROPERTY()
	int SizeAfterEmpty = 0;

	/**
	 * WorldStory: BeginPlay fills TestSet, then Contains/Remove/Empty write the flags.
	 *
	 * @Kind WorldStory
	 * @Covers PropertyAccess.TSetAdvancedOperations
	 * @Inputs none
	 * @Return bContainsElement, bRemoved20, bRemoved40, SizeBeforeEmpty, SizeAfterEmpty
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		// Setup test data
		TestSet.Add(10);
		TestSet.Add(20);
		TestSet.Add(30);
		TestSet.Add(40);
		TestSet.Add(50);

		// Test Contains()
		bContainsElement = TestSet.Contains(30);

		// Test Remove()
		bRemoved20 = TestSet.Remove(20);
		bRemoved40 = TestSet.Remove(40);

		// Test Empty()
		SizeBeforeEmpty = TestSet.Num();
		TestSet.Empty();
		SizeAfterEmpty = TestSet.Num();
	}

	/**
	 * Observe a locally constructed actor: empty set and false/zero flags.
	 *
	 * @Kind Observe
	 * @Covers PropertyAccess.TSetAdvancedOperations
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when the set is empty and every flag is at its initializer
	 * @Boundary local construct
	 */
	UFUNCTION()
	bool TSetAdvanced_DefaultEmpty()
	{
		if (bContainsElement)
		{
			return false;
		}
		if (bRemoved20)
		{
			return false;
		}
		if (bRemoved40)
		{
			return false;
		}
		if (SizeBeforeEmpty != 0)
		{
			return false;
		}
		if (SizeAfterEmpty != 0)
		{
			return false;
		}
		return TestSet.Num() == 0;
	}

	/**
	 * Observe that writing this actor leaves another actor's set empty.
	 *
	 * @Kind Observe
	 * @Covers PropertyAccess.TSetAdvancedOperations
	 * @Inputs a second actor that must stay empty
	 * @Return true when this holds one member and the other stays empty
	 * @Param Second the other actor
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool TSetAdvanced_CopyIndependence(ACoverageTSetAdvancedActor Second)
	{
		if (Second is null)
		{
			throw("TSetAdvancedOperations setup: required Second is null");
		}
		TestSet.Add(10);
		if (TestSet.Num() != 1)
		{
			return false;
		}
		return Second.TestSet.Num() == 0;
	}
}
/** @end */
