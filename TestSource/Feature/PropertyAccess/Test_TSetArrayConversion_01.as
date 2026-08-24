// Theme: Feature.PropertyAccess. WorldStory TSet.Append(TArray).
// CSV NegativeDiagnostic. C++ TSetArrayConversion block 1 compiles, spawns,
// and checks SetSize==4, bSetContainsAll==true.
// Extra: local construct empty UniqueSet/SourceArray; copy independence.
// FixtureIsolated. Keep SetSize / bSetContainsAll.

UCLASS()
class ACoverageTSetArrayConversionActor : AActor
{
	UPROPERTY()
	TSet<int> UniqueSet;

	UPROPERTY()
	TArray<int> SourceArray;

	UPROPERTY()
	int SetSize = 0;

	UPROPERTY()
	bool bSetContainsAll = false;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		SourceArray.Add(100);
		SourceArray.Add(200);
		SourceArray.Add(300);
		SourceArray.Add(400);
		SourceArray.Add(400);

		UniqueSet.Append(SourceArray);
		SetSize = UniqueSet.Num();

		// Verify all elements present (order may vary)
		bSetContainsAll =
			UniqueSet.Contains(100) &&
			UniqueSet.Contains(200) &&
			UniqueSet.Contains(300) &&
			UniqueSet.Contains(400);
	}
}

bool Observe_TSetArrayAppend_DefaultEmpty(ACoverageTSetArrayConversionActor Actor)
{
	if (Actor is null)
	{
		throw("Test_TSetArrayConversion_01 setup: required Actor is null");
	}
	return Actor.UniqueSet.Num() == 0
		&& Actor.SourceArray.Num() == 0
		&& Actor.SetSize == 0
		&& Actor.bSetContainsAll == false;
}

bool Observe_TSetArrayAppend_CopyIndependence(ACoverageTSetArrayConversionActor First, ACoverageTSetArrayConversionActor Second)
{
	if (First is null)
	{
		throw("Test_TSetArrayConversion_01 setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_TSetArrayConversion_01 setup: required Second is null");
	}
	First.SourceArray.Add(100);
	First.UniqueSet.Append(First.SourceArray);
	return First.UniqueSet.Num() == 1 && Second.UniqueSet.Num() == 0 && Second.SourceArray.Num() == 0;
}
