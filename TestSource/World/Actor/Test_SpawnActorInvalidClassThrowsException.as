// Theme: World.Actor. C++ compiles this actor then expects a runtime Angelscript error
// when RunSpawnInvalidClassTest calls SpawnActor(nullptr). CSV marks NegativeDiagnostic;
// the method is a runtime exception oracle, not a compile-fail.
// C++: AngelscriptActorInteractionTests.cpp::SpawnActorInvalidClassThrowsException
// Spawn is the oracle (invalid class). FixtureIsolated.

UCLASS()
class ATestActorSpawnInvalidClass : AActor
{
	UFUNCTION()
	void RunSpawnInvalidClassTest()
	{
		AActor Spawned = SpawnActor(nullptr, FVector::ZeroVector, FRotator::ZeroRotator, n"InvalidSpawn");
	}
}
