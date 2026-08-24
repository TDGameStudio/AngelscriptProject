// Theme: Containers.TArray. WorldStory: FindIndex Enemy is 1; Sort keeps count 5.
// Extra: duplicate Enemy. FixtureIsolated.

UCLASS()
class ACoverageTArrayFNameActor : AActor
{
	UPROPERTY()
	TArray<FName> Names;

	UPROPERTY()
	int FindIndex;

	UPROPERTY()
	int SortedCount;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Names.Add(n"Player");
		Names.Add(n"Enemy");
		Names.Add(n"Weapon");
		Names.Add(n"Item");
		Names.Add(n"Enemy");
		FindIndex = Names.FindIndex(n"Enemy");
		Names.Sort();
		SortedCount = Names.Num();
	}
}
