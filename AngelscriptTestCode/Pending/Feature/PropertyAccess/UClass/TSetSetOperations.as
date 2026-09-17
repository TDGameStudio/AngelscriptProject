/**
 * @version v1
 * @summary TSet Append union on a spawned actor. C++ compiles, spawns, and checks UnionResult size 7 containing 1 and 7. Keep UnionResult / SetA / SetB.
 * @topic Feature
 */
/**
 * @version root
 * @summary TSet Append union on a spawned actor. C++ compiles, spawns, and checks UnionResult size 7 containing 1 and 7. Keep UnionResult / SetA / SetB.
 * @topic Baseline
 */
UCLASS()
class ACoverageTSetSetOperationsActor : AActor
{
	UPROPERTY()
	TSet<int> SetA;

	UPROPERTY()
	TSet<int> SetB;

	UPROPERTY()
	TSet<int> UnionResult;

	/**
	 * WorldStory: BeginPlay fills SetA and SetB, then Append produces UnionResult.
	 *
	 * @Kind WorldStory
	 * @Covers PropertyAccess.TSetSetOperations
	 * @Inputs none
	 * @Return UnionResult is SetA plus SetB
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		// Setup SetA: {1, 2, 3, 4, 5}
		SetA.Add(1);
		SetA.Add(2);
		SetA.Add(3);
		SetA.Add(4);
		SetA.Add(5);

		// Setup SetB: {3, 4, 5, 6, 7}
		SetB.Add(3);
		SetB.Add(4);
		SetB.Add(5);
		SetB.Add(6);
		SetB.Add(7);

		// Test Append(Set): A plus B = {1, 2, 3, 4, 5, 6, 7}
		UnionResult = SetA;
		UnionResult.Append(SetB);
	}

	/**
	 * Observe a locally constructed actor: all three sets empty.
	 *
	 * @Kind Observe
	 * @Covers PropertyAccess.TSetSetOperations
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when SetA, SetB, and UnionResult are empty
	 * @Boundary local construct
	 */
	UFUNCTION()
	bool TSetUnion_DefaultEmpty()
	{
		if (SetA.Num() != 0)
		{
			return false;
		}
		if (SetB.Num() != 0)
		{
			return false;
		}
		return UnionResult.Num() == 0;
	}

	/**
	 * Observe that writing this actor's SetA leaves another actor empty.
	 *
	 * @Kind Observe
	 * @Covers PropertyAccess.TSetSetOperations
	 * @Inputs a second actor that must stay empty
	 * @Return true when this UnionResult has 1 and the other stays empty
	 * @Param Second the other actor
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool TSetUnion_CopyIndependence(ACoverageTSetSetOperationsActor Second)
	{
		if (Second is null)
		{
			throw("TSetSetOperations setup: required Second is null");
		}
		SetA.Add(1);
		UnionResult = SetA;
		if (UnionResult.Num() != 1)
		{
			return false;
		}
		if (Second.SetA.Num() != 0)
		{
			return false;
		}
		return Second.UnionResult.Num() == 0;
	}
}
/** @end */
