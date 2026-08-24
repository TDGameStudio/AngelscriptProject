// Theme: Feature.PropertyAccess. WorldStory TSet as const-ref, inout, and return.
// C++: AngelscriptCoverageTSetAdvancedTests.cpp::TSetAsParameter
// After BeginPlay: OriginalSet 3, SumFromConstRef==6, ModifiedSet 5, ReturnedSet 6.
// Extra: empty SumSetElements==0; CreateEvenNumberSet(-1) empty; copy independence.
// FixtureIsolated. Keep OriginalSet / ModifiedSet / ReturnedSet / SumFromConstRef.

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

	// Function taking const ref (read-only)
	int SumSetElements(const TSet<int>&in InSet)
	{
		int Sum = 0;
		for (int Value : InSet)
		{
			Sum += Value;
		}
		return Sum;
	}

	// Function taking mutable ref (can modify)
	void AddElementsToSet(TSet<int>&inout InSet, int Value1, int Value2)
	{
		InSet.Add(Value1);
		InSet.Add(Value2);
	}

	// Function returning TSet
	TSet<int> CreateEvenNumberSet(int MaxValue)
	{
		TSet<int> Result;
		for (int i = 0; i <= MaxValue; i += 2)
		{
			Result.Add(i);
		}
		return Result;
	}

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
}

bool Observe_TSetParam_DefaultEmpty(ACoverageTSetParameterActor Actor)
{
	if (Actor is null)
	{
		throw("Test_TSetAsParameter setup: required Actor is null");
	}
	return Actor.OriginalSet.Num() == 0
		&& Actor.ModifiedSet.Num() == 0
		&& Actor.ReturnedSet.Num() == 0
		&& Actor.SumFromConstRef == 0;
}

int Observe_TSetParam_EmptySum(ACoverageTSetParameterActor Actor)
{
	if (Actor is null)
	{
		throw("Test_TSetAsParameter setup: required Actor is null");
	}
	TSet<int> Empty;
	return Actor.SumSetElements(Empty);
}

int Observe_TSetParam_NegativeMaxBoundary(ACoverageTSetParameterActor Actor)
{
	if (Actor is null)
	{
		throw("Test_TSetAsParameter setup: required Actor is null");
	}
	TSet<int> Evens = Actor.CreateEvenNumberSet(-1);
	return Evens.Num();
}

bool Observe_TSetParam_CopyIndependence(ACoverageTSetParameterActor First, ACoverageTSetParameterActor Second)
{
	if (First is null)
	{
		throw("Test_TSetAsParameter setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_TSetAsParameter setup: required Second is null");
	}
	First.OriginalSet.Add(1);
	First.AddElementsToSet(First.OriginalSet, 4, 5);
	return First.OriginalSet.Num() == 3 && Second.OriginalSet.Num() == 0;
}
