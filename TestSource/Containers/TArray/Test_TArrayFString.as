// Theme: Containers.TArray. WorldStory: sort then insert AAA; FindIndex Hello/Missing.
// Extra: empty FindIndex Missing stays -1. FixtureIsolated.

UCLASS()
class ACoverageTArrayStringActor : AActor
{
	UPROPERTY()
	TArray<FString> StringArray;

	UPROPERTY()
	int FindIndexHello;

	UPROPERTY()
	int FindIndexNotFound;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		StringArray.Add("Hello");
		StringArray.Add("World");
		StringArray.Add("AngelScript");
		StringArray.Add("Test");
		StringArray.Sort();
		FindIndexHello = StringArray.FindIndex("Hello");
		FindIndexNotFound = StringArray.FindIndex("Missing");
		StringArray.Insert("AAA", 0);
	}
}
