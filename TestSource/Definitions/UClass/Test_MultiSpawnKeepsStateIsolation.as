// Theme: Definitions.UClass. WorldStory: two spawned instances keep isolated LocalState.
// C++: AngelscriptScriptClassCreationTests.cpp::MultiSpawnKeepsStateIsolation SetPropertyValue 11 vs default 3.
// Oracle: LocalState defaults to 3; after First=11, Second stays 3.
// Extra: default 3 is the empty/default vector; 0 is a false/boundary write.
// FixtureIsolated. Runner owns spawn and World teardown. Keep LocalState.

UCLASS()
class ATestScriptClassMultiSpawnKeepsStateIsolation : AActor
{
	UPROPERTY()
	int LocalState = 3;
}

int Observe_MultiSpawn_LocalStateDefault(ATestScriptClassMultiSpawnKeepsStateIsolation Actor)
{
	return Actor.LocalState;
}

int Observe_MultiSpawn_MutatedFirstKeepsSecond(ATestScriptClassMultiSpawnKeepsStateIsolation First, ATestScriptClassMultiSpawnKeepsStateIsolation Second)
{
	First.LocalState = 11;
	return Second.LocalState;
}

int Observe_MultiSpawn_EmptyZeroBoundary(ATestScriptClassMultiSpawnKeepsStateIsolation Actor)
{
	Actor.LocalState = 0;
	return Actor.LocalState;
}
