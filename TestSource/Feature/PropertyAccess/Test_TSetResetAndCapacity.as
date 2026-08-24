// Theme: Feature.PropertyAccess. WorldStory TSet Reset then re-add.
// C++: AngelscriptCoverageTSetAdvancedTests.cpp::TSetResetAndCapacity
// After BeginPlay: SizeBeforeReset==5, SizeAfterReset==0, bReAddSuccess==true.
// Extra: local construct zeros/empty; copy independence.
// FixtureIsolated. Keep SizeBeforeReset / SizeAfterReset / bReAddSuccess.

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
}

bool Observe_TSetReset_DefaultEmpty(ACoverageTSetResetCapacityActor Actor)
{
	if (Actor is null)
	{
		throw("Test_TSetResetAndCapacity setup: required Actor is null");
	}
	return Actor.TestSet.Num() == 0
		&& Actor.SizeBeforeReset == 0
		&& Actor.SizeAfterReset == 0
		&& Actor.bReAddSuccess == false;
}

bool Observe_TSetReset_CopyIndependence(ACoverageTSetResetCapacityActor First, ACoverageTSetResetCapacityActor Second)
{
	if (First is null)
	{
		throw("Test_TSetResetAndCapacity setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_TSetResetAndCapacity setup: required Second is null");
	}
	First.TestSet.Add(10);
	First.TestSet.Reset();
	First.TestSet.Add(100);
	return First.TestSet.Num() == 1 && Second.TestSet.Num() == 0;
}
