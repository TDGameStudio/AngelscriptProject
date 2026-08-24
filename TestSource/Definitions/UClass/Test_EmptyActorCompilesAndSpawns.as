// Theme: Definitions.UClass. WorldStory empty actor compiles, spawns, BeginPlay, Destroy.
// C++: AngelscriptScriptClassShapeTests.cpp::EmptyActorCompilesAndSpawns
// Oracle: no declared user properties; actor-derived; CDO present; BeginPlay then Destroy.
// Extra: nullptr handle is the empty vector; two spawned instances remain distinct objects.
// FixtureIsolated. Do not add UPROPERTY; C++ counts 0 declared user properties.

UCLASS()
class AEmptyScriptActor : AActor
{
}

bool Observe_EmptyActor_NullDefault()
{
	AEmptyScriptActor Actor = nullptr;
	return Actor == nullptr;
}

bool Observe_EmptyActor_IsActorChild()
{
	return AEmptyScriptActor::StaticClass().IsChildOf(AActor::StaticClass());
}

bool Observe_EmptyActor_TwoHandlesIndependent(AEmptyScriptActor First, AEmptyScriptActor Second)
{
	return First != nullptr && Second != nullptr && First != Second;
}
