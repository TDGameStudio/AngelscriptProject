// Theme: Definitions.UClass. WorldStory: Blueprint child of a script actor preserves BeginPlay.
// C++: AngelscriptScriptClassCreationTests.cpp::BlueprintChildCompiles spawn BlueprintClass then BeginPlayCount == 1.
// Oracle: BeginPlayCount defaults to 0 and becomes 1 after the runner's BeginPlay.
// Extra: default 0 is the empty vector; mutating one actor does not write the other.
// FixtureIsolated. Runner owns Blueprint child, spawn, and World teardown. Keep BeginPlayCount.

UCLASS()
class ATestScriptClassBlueprintChildCompiles : AActor
{
	UPROPERTY()
	int BeginPlayCount = 0;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		BeginPlayCount += 1;
	}
}

int Observe_BlueprintChild_BeginPlayCountDefault(ATestScriptClassBlueprintChildCompiles Actor)
{
	return Actor.BeginPlayCount;
}

bool Observe_BlueprintChild_NullDefault()
{
	ATestScriptClassBlueprintChildCompiles Actor = nullptr;
	return Actor == nullptr;
}

bool Observe_BlueprintChild_CopyIndependent(ATestScriptClassBlueprintChildCompiles First, ATestScriptClassBlueprintChildCompiles Second)
{
	First.BeginPlayCount = 1;
	return Second.BeginPlayCount == 0;
}
