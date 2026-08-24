// Theme: Feature.PropertyAccess. WorldStory TSet Contains/Remove/Empty.
// C++: AngelscriptCoverageTSetAdvancedTests.cpp::TSetAdvancedOperations block 1
// CompileScriptModule + spawn + BeginPlay. VerifyByPath:
// bContainsElement==true, bRemoved20==true, bRemoved40==true,
// SizeBeforeEmpty==3, SizeAfterEmpty==0.
// Extra: local construct empty set and false/zero flags; copy independence.
// FixtureIsolated. Keep VerifyByPath UPROPERTY names.

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
}

bool Observe_TSetAdvanced_DefaultEmpty(ACoverageTSetAdvancedActor Actor)
{
	if (Actor is null)
	{
		throw("Test_TSetAdvancedOperations_01 setup: required Actor is null");
	}
	return Actor.bContainsElement == false
		&& Actor.bRemoved20 == false
		&& Actor.bRemoved40 == false
		&& Actor.SizeBeforeEmpty == 0
		&& Actor.SizeAfterEmpty == 0
		&& Actor.TestSet.Num() == 0;
}

bool Observe_TSetAdvanced_CopyIndependence(ACoverageTSetAdvancedActor First, ACoverageTSetAdvancedActor Second)
{
	if (First is null)
	{
		throw("Test_TSetAdvancedOperations_01 setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_TSetAdvancedOperations_01 setup: required Second is null");
	}
	First.TestSet.Add(10);
	return First.TestSet.Num() == 1 && Second.TestSet.Num() == 0;
}
