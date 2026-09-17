/**
 * @version v1
 * @summary TSet for-each and explicit iterator on a spawned actor. After BeginPlay: Sum==120, IterationCount==4, MaxValue==45, ExplicitIteratorSum==120, ExplicitIteratorCount==4. Keep those VerifyByPath UPROPERTY names.
 * @topic Feature
 */
/**
 * @version root
 * @summary TSet for-each and explicit iterator on a spawned actor. After BeginPlay: Sum==120, IterationCount==4, MaxValue==45, ExplicitIteratorSum==120, ExplicitIteratorCount==4. Keep those VerifyByPath UPROPERTY names.
 * @topic Baseline
 */
UCLASS()
class ACoverageTSetIterationActor : AActor
{
	UPROPERTY()
	TSet<int> TestSet;

	UPROPERTY()
	int Sum = 0;

	UPROPERTY()
	int IterationCount = 0;

	UPROPERTY()
	int MaxValue = 0;

	UPROPERTY()
	int ExplicitIteratorSum = 0;

	UPROPERTY()
	int ExplicitIteratorCount = 0;

	/**
	 * WorldStory: BeginPlay fills TestSet, then walks it with for-each and Iterator().
	 *
	 * @Kind WorldStory
	 * @Covers PropertyAccess.TSetIteration
	 * @Inputs none
	 * @Return Sum, IterationCount, MaxValue, ExplicitIteratorSum, ExplicitIteratorCount
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		TestSet.Add(15);
		TestSet.Add(25);
		TestSet.Add(35);
		TestSet.Add(45);

		// Test for-each iteration
		for (int Value : TestSet)
		{
			Sum += Value;
			IterationCount++;
			if (Value > MaxValue)
			{
				MaxValue = Value;
			}
		}

		// Test explicit iterator API.
		TSetIterator<int> It = TestSet.Iterator();
		while (It.CanProceed)
		{
			ExplicitIteratorSum += It.Proceed();
			ExplicitIteratorCount++;
		}
	}

	/**
	 * Observe a locally constructed actor: empty set and zero totals.
	 *
	 * @Kind Observe
	 * @Covers PropertyAccess.TSetIteration
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when TestSet is empty and every total is 0
	 * @Boundary local construct
	 */
	UFUNCTION()
	bool TSetIteration_DefaultEmpty()
	{
		if (Sum != 0)
		{
			return false;
		}
		if (IterationCount != 0)
		{
			return false;
		}
		if (MaxValue != 0)
		{
			return false;
		}
		if (ExplicitIteratorSum != 0)
		{
			return false;
		}
		if (ExplicitIteratorCount != 0)
		{
			return false;
		}
		return TestSet.Num() == 0;
	}

	/**
	 * Observe that writing this actor leaves another actor's set empty.
	 *
	 * @Kind Observe
	 * @Covers PropertyAccess.TSetIteration
	 * @Inputs a second actor that must stay empty
	 * @Return true when this holds one member and the other stays empty
	 * @Param Second the other actor
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool TSetIteration_CopyIndependence(ACoverageTSetIterationActor Second)
	{
		if (Second is null)
		{
			throw("TSetIteration setup: required Second is null");
		}
		TestSet.Add(15);
		if (TestSet.Num() != 1)
		{
			return false;
		}
		return Second.TestSet.Num() == 0;
	}
}
/** @end */
