// Theme: Definitions.UClass. WorldStory: spawned script actor observes BeginPlay.
// C++: AngelscriptScriptClassCreationTests.cpp::CanSpawnInTestWorld BeginPlayActor then ReadPropertyValue.
// Oracle: BeginPlayObserved == 1 after the runner enters the world. Property defaults to 0 before play.
// Extra: default 0 is the empty vector; mutating one actor does not write the other.
// FixtureIsolated. Runner owns spawn, BeginPlay, and World teardown. Keep BeginPlayObserved.

UCLASS()
class ATestScriptClassCanSpawnInTestWorld : AActor
{
	UPROPERTY()
	int BeginPlayObserved = 0;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		BeginPlayObserved = 1;
	}
}

int Observe_CanSpawn_BeginPlayObservedDefault(ATestScriptClassCanSpawnInTestWorld Actor)
{
	return Actor.BeginPlayObserved;
}

bool Observe_CanSpawn_NullDefault()
{
	ATestScriptClassCanSpawnInTestWorld Actor = nullptr;
	return Actor == nullptr;
}

bool Observe_CanSpawn_CopyIndependent(ATestScriptClassCanSpawnInTestWorld First, ATestScriptClassCanSpawnInTestWorld Second)
{
	First.BeginPlayObserved = 1;
	return Second.BeginPlayObserved == 0;
}
