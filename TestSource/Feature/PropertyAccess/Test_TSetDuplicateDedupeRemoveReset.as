// Theme: Feature.PropertyAccess. WorldStory TSet duplicate / Remove / Reset.
// C++: AngelscriptCoverageTSetAdvancedTests.cpp::TSetDuplicateDedupeRemoveReset
// After BeginPlay: SizeAfterDuplicates==2, bContainsBeforeRemove==true,
// bRemoveExistingReturned==true, bRemoveMissingReturned==false,
// bContainsAfterRemove==false, SizeAfterRemove==1,
// bResetClearedSet==true, bAddAfterResetWorked==true.
// Extra: local construct uses the property initializers; copy independence.
// FixtureIsolated. Keep all VerifyByPath UPROPERTY names.

UCLASS()
class ACoverageTSetDuplicateDedupeRemoveResetActor : AActor
{
	UPROPERTY()
	TSet<int> Values;

	UPROPERTY()
	int SizeAfterDuplicates = 0;

	UPROPERTY()
	bool bContainsBeforeRemove = false;

	UPROPERTY()
	bool bRemoveExistingReturned = false;

	UPROPERTY()
	bool bRemoveMissingReturned = true;

	UPROPERTY()
	bool bContainsAfterRemove = true;

	UPROPERTY()
	int SizeAfterRemove = 0;

	UPROPERTY()
	bool bResetClearedSet = false;

	UPROPERTY()
	bool bAddAfterResetWorked = false;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Values.Add(7);
		Values.Add(7);
		Values.Add(11);
		Values.Add(11);

		SizeAfterDuplicates = Values.Num();
		bContainsBeforeRemove = Values.Contains(7) && Values.Contains(11);

		bRemoveExistingReturned = Values.Remove(7);
		bRemoveMissingReturned = Values.Remove(99);
		bContainsAfterRemove = Values.Contains(7);
		SizeAfterRemove = Values.Num();

		Values.Reset();
		bResetClearedSet = Values.Num() == 0 && !Values.Contains(11);

		Values.Add(13);
		bAddAfterResetWorked = Values.Num() == 1 && Values.Contains(13);
	}
}

bool Observe_TSetDedupe_DefaultInitializers(ACoverageTSetDuplicateDedupeRemoveResetActor Actor)
{
	if (Actor is null)
	{
		throw("Test_TSetDuplicateDedupeRemoveReset setup: required Actor is null");
	}
	return Actor.Values.Num() == 0
		&& Actor.SizeAfterDuplicates == 0
		&& Actor.bContainsBeforeRemove == false
		&& Actor.bRemoveExistingReturned == false
		&& Actor.bRemoveMissingReturned == true
		&& Actor.bContainsAfterRemove == true
		&& Actor.SizeAfterRemove == 0
		&& Actor.bResetClearedSet == false
		&& Actor.bAddAfterResetWorked == false;
}

bool Observe_TSetDedupe_CopyIndependence(ACoverageTSetDuplicateDedupeRemoveResetActor First, ACoverageTSetDuplicateDedupeRemoveResetActor Second)
{
	if (First is null)
	{
		throw("Test_TSetDuplicateDedupeRemoveReset setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_TSetDuplicateDedupeRemoveReset setup: required Second is null");
	}
	First.Values.Add(7);
	First.Values.Add(7);
	return First.Values.Num() == 1 && Second.Values.Num() == 0;
}
