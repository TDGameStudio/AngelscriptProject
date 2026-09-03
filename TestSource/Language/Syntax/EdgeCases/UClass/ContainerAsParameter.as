/**
 * Containers passed by value, by reference and as an out parameter. BeginPlay
 * exercises all three and records the resulting element counts; a locally
 * constructed actor leaves all counters at zero.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.ContainerAsParameter
 * @Harness UClass
 * @Tag Language.Syntax.EdgeCases.ContainerAsParameter
 * @Provenance C++: AngelscriptCoverageContainerAdvancedTests.cpp::ContainerAsParameter
 * @Provenance sha256=309b172c703247a378c43a6936f1cf2b390653f4cb1505926a19d8355fb1c3a3; lines 57-126.
 * @Provenance Oracle after BeginPlay: ResultByValue=6, ResultByRef=3, ResultByOut=3.
 * @Provenance Extra: empty array SumByValue is 0; local construct leaves results 0.
 * @Provenance FixtureIsolated.
 */

UCLASS()
class ACoverageContainerParameterActor : AActor
{
	UPROPERTY()
	int ResultByValue;

	UPROPERTY()
	int ResultByRef;

	UPROPERTY()
	int ResultByOut;

	/**
	 * Sums a container received by value.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs a container passed by value
	 * @Return the sum of all elements
	 * @Param Arr the copied container
	 */
	int SumByValue(TArray<int> Arr)
	{
		int Sum = 0;
		for (int Val : Arr)
		{
			Sum += Val;
		}
		return Sum;
	}

	/**
	 * Appends to a container received by reference.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs a container passed by reference
	 * @Return nothing; the caller's container gains one element
	 * @Param Arr the container to modify in place
	 */
	void ModifyByRef(TArray<int>&inout Arr)
	{
		Arr.Add(999);
	}

	/**
	 * Fills a container supplied as an out parameter.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs an empty out container
	 * @Return nothing; the container receives three elements
	 * @Param Result the out container to fill
	 */
	void FillOut(TArray<int>&out Result)
	{
		Result.Add(100);
		Result.Add(200);
		Result.Add(300);
	}

	/**
	 * Exercises all three parameter directions.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing; the three counters record the outcome
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		TArray<int> Values;
		Values.Add(1);
		Values.Add(2);
		Values.Add(3);
		ResultByValue = SumByValue(Values);

		TArray<int> RefArray;
		RefArray.Add(10);
		RefArray.Add(20);
		ModifyByRef(RefArray);
		ResultByRef = RefArray.Num();

		TArray<int> OutArray;
		FillOut(OutArray);
		ResultByOut = OutArray.Num();
	}

	/**
	 * Observe that a locally constructed actor leaves all counters at zero.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return true when all three counters are 0
	 * @Boundary default values
	 */
	UFUNCTION()
	bool ContainerParameterResultsDefaultToZero()
	{
		if (ResultByValue != 0)
		{
			return false;
		}

		if (ResultByRef != 0)
		{
			return false;
		}

		return ResultByOut == 0;
	}

	/**
	 * Observe the results after BeginPlay runs.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs BeginPlay() then all three counters
	 * @Return true when the counts are 6, 3 and 3
	 */
	UFUNCTION()
	bool ContainerParameterResultsAfterBeginPlay()
	{
		BeginPlay();

		if (ResultByValue != 6)
		{
			return false;
		}

		if (ResultByRef != 3)
		{
			return false;
		}

		return ResultByOut == 3;
	}

	/**
	 * Observe that passing by value copies rather than aliases.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs an empty array and a three-element array, both summed by value
	 * @Return true when the sums are 0 and 6 and the source is untouched
	 * @Boundary empty array
	 */
	UFUNCTION()
	bool ContainerByValueCopiesIndependently()
	{
		TArray<int> Empty;
		int EmptySum = SumByValue(Empty);
		TArray<int> Values;
		Values.Add(1);
		Values.Add(2);
		Values.Add(3);
		int CopiedSum = SumByValue(Values);

		if (EmptySum != 0)
		{
			return false;
		}

		if (CopiedSum != 6)
		{
			return false;
		}

		return Values.Num() == 3;
	}
}
