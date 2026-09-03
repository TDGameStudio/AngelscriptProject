/**
 * TSet as const-ref, inout, and return on a spawned actor. After BeginPlay:
 * OriginalSet 3, SumFromConstRef==6, ModifiedSet 5, ReturnedSet 6. Keep
 * OriginalSet / ModifiedSet / ReturnedSet / SumFromConstRef.
 *
 * @Theme Feature.PropertyAccess
 * @Subject PropertyAccess.TSetAsParameter
 * @Harness UClass
 * @Tag Feature.PropertyAccess.TSetAsParameter
 * @Provenance Theme: Feature.PropertyAccess. WorldStory TSet as const-ref, inout, and return.
 * @Provenance C++: AngelscriptCoverageTSetAdvancedTests.cpp::TSetAsParameter
 * @Provenance After BeginPlay: OriginalSet 3, SumFromConstRef==6, ModifiedSet 5, ReturnedSet 6.
 * @Provenance Extra: empty SumSetElements==0; CreateEvenNumberSet(-1) empty; copy independence.
 * @Provenance FixtureIsolated. Keep OriginalSet / ModifiedSet / ReturnedSet / SumFromConstRef.
 */

UCLASS()
class ACoverageTSetParameterActor : AActor
{
	UPROPERTY()
	TSet<int> OriginalSet;

	UPROPERTY()
	TSet<int> ModifiedSet;

	UPROPERTY()
	TSet<int> ReturnedSet;

	UPROPERTY()
	int SumFromConstRef = 0;

	/**
	 * Read-only: sum every element of a const-ref TSet.
	 *
	 * @Kind WorldStory
	 * @Covers PropertyAccess.TSetAsParameter
	 * @Inputs InSet received as const TSet<int>&in
	 * @Return the sum of the members
	 * @Param InSet the set to read
	 */
	int SumSetElements(const TSet<int>&in InSet)
	{
		int Sum = 0;
		for (int Value : InSet)
		{
			Sum += Value;
		}
		return Sum;
	}

	/**
	 * Mutable ref: Add Value1 and Value2 onto InSet.
	 *
	 * @Kind WorldStory
	 * @Covers PropertyAccess.TSetAsParameter
	 * @Inputs InSet received as TSet<int>&inout plus two values
	 * @Return void; both values are members of InSet
	 * @Param InSet the set to mutate
	 * @Param Value1 first value to add
	 * @Param Value2 second value to add
	 */
	void AddElementsToSet(TSet<int>&inout InSet, int Value1, int Value2)
	{
		InSet.Add(Value1);
		InSet.Add(Value2);
	}

	/**
	 * Return a TSet of even numbers from 0 through MaxValue.
	 *
	 * @Kind WorldStory
	 * @Covers PropertyAccess.TSetAsParameter
	 * @Inputs MaxValue inclusive upper bound
	 * @Return a TSet of even integers
	 * @Param MaxValue inclusive upper bound
	 */
	TSet<int> CreateEvenNumberSet(int MaxValue)
	{
		TSet<int> Result;
		for (int i = 0; i <= MaxValue; i += 2)
		{
			Result.Add(i);
		}
		return Result;
	}

	/**
	 * WorldStory: BeginPlay fills OriginalSet, sums it, copies and extends ModifiedSet,
	 * then stores CreateEvenNumberSet(10).
	 *
	 * @Kind WorldStory
	 * @Covers PropertyAccess.TSetAsParameter
	 * @Inputs none
	 * @Return OriginalSet, SumFromConstRef, ModifiedSet, ReturnedSet
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		// Setup original set
		OriginalSet.Add(1);
		OriginalSet.Add(2);
		OriginalSet.Add(3);

		// Test const ref parameter
		SumFromConstRef = SumSetElements(OriginalSet);

		// Test mutable ref parameter
		ModifiedSet = OriginalSet; // Copy
		AddElementsToSet(ModifiedSet, 4, 5);

		// Test return value
		ReturnedSet = CreateEvenNumberSet(10);
	}

	/**
	 * Observe a locally constructed actor: empty sets and zero sum.
	 *
	 * @Kind Observe
	 * @Covers PropertyAccess.TSetAsParameter
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when every set is empty and SumFromConstRef is 0
	 * @Boundary local construct
	 */
	UFUNCTION()
	bool TSetParam_DefaultEmpty()
	{
		if (OriginalSet.Num() != 0)
		{
			return false;
		}
		if (ModifiedSet.Num() != 0)
		{
			return false;
		}
		if (ReturnedSet.Num() != 0)
		{
			return false;
		}
		return SumFromConstRef == 0;
	}

	/**
	 * Observe SumSetElements of an empty set.
	 *
	 * @Kind Observe
	 * @Covers PropertyAccess.TSetAsParameter
	 * @Inputs an empty TSet<int>
	 * @Return 0
	 * @Boundary empty SumSetElements
	 */
	UFUNCTION()
	int TSetParam_EmptySum()
	{
		TSet<int> Empty;
		return SumSetElements(Empty);
	}

	/**
	 * Observe CreateEvenNumberSet(-1): the loop does not run.
	 *
	 * @Kind Observe
	 * @Covers PropertyAccess.TSetAsParameter
	 * @Inputs MaxValue -1
	 * @Return 0
	 * @Boundary CreateEvenNumberSet(-1)
	 */
	UFUNCTION()
	int TSetParam_NegativeMaxBoundary()
	{
		TSet<int> Evens = CreateEvenNumberSet(-1);
		return Evens.Num();
	}

	/**
	 * Observe that mutating this actor's OriginalSet leaves another actor empty.
	 *
	 * @Kind Observe
	 * @Covers PropertyAccess.TSetAsParameter
	 * @Inputs a second actor that must stay empty
	 * @Return true when this OriginalSet has 3 and the other stays empty
	 * @Param Second the other actor
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool TSetParam_CopyIndependence(ACoverageTSetParameterActor Second)
	{
		if (Second is null)
		{
			throw("TSetAsParameter setup: required Second is null");
		}
		OriginalSet.Add(1);
		AddElementsToSet(OriginalSet, 4, 5);
		if (OriginalSet.Num() != 3)
		{
			return false;
		}
		return Second.OriginalSet.Num() == 0;
	}
}
