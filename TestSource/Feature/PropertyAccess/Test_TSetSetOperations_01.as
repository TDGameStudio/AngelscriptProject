// Theme: Feature.PropertyAccess. WorldStory TSet Append union.
// CSV NegativeDiagnostic. C++ TSetSetOperations block 1 compiles, spawns,
// and checks UnionResult size 7 containing 1 and 7.
// Extra: local construct empty sets; copy independence of SetA.
// FixtureIsolated. Keep UnionResult / SetA / SetB.

UCLASS()
class ACoverageTSetSetOperationsActor : AActor
{
	UPROPERTY()
	TSet<int> SetA;

	UPROPERTY()
	TSet<int> SetB;

	UPROPERTY()
	TSet<int> UnionResult;

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
}

bool Observe_TSetUnion_DefaultEmpty(ACoverageTSetSetOperationsActor Actor)
{
	if (Actor is null)
	{
		throw("Test_TSetSetOperations_01 setup: required Actor is null");
	}
	return Actor.SetA.Num() == 0 && Actor.SetB.Num() == 0 && Actor.UnionResult.Num() == 0;
}

bool Observe_TSetUnion_CopyIndependence(ACoverageTSetSetOperationsActor First, ACoverageTSetSetOperationsActor Second)
{
	if (First is null)
	{
		throw("Test_TSetSetOperations_01 setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_TSetSetOperations_01 setup: required Second is null");
	}
	First.SetA.Add(1);
	First.UnionResult = First.SetA;
	return First.UnionResult.Num() == 1 && Second.SetA.Num() == 0 && Second.UnionResult.Num() == 0;
}
