// Theme: Feature.PropertyAccess. WorldStory TSet for-each and explicit iterator.
// C++: AngelscriptCoverageTSetAdvancedTests.cpp::TSetIteration
// After BeginPlay: Sum==120, IterationCount==4, MaxValue==45,
// ExplicitIteratorSum==120, ExplicitIteratorCount==4.
// Extra: local construct zeros/empty; copy independence.
// FixtureIsolated. Keep VerifyByPath UPROPERTY names.

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
}

bool Observe_TSetIteration_DefaultEmpty(ACoverageTSetIterationActor Actor)
{
	if (Actor is null)
	{
		throw("Test_TSetIteration setup: required Actor is null");
	}
	return Actor.Sum == 0
		&& Actor.IterationCount == 0
		&& Actor.MaxValue == 0
		&& Actor.ExplicitIteratorSum == 0
		&& Actor.ExplicitIteratorCount == 0
		&& Actor.TestSet.Num() == 0;
}

bool Observe_TSetIteration_CopyIndependence(ACoverageTSetIterationActor First, ACoverageTSetIterationActor Second)
{
	if (First is null)
	{
		throw("Test_TSetIteration setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_TSetIteration setup: required Second is null");
	}
	First.TestSet.Add(15);
	return First.TestSet.Num() == 1 && Second.TestSet.Num() == 0;
}
