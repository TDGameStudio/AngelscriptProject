/**
 * SpawnActor called with a null class, which must raise a script exception at
 * runtime. C++ compiles this actor and then invokes the entrypoint expecting the
 * exception, so this is a runtime exception oracle rather than a compile failure.
 * The observers never call the throwing entrypoint.
 *
 * @Theme World.Actor
 * @Subject Actor.SpawnActorInvalidClassThrowsException
 * @Harness UClass
 * @Tag World.Actor.SpawnActorInvalidClassThrowsException
 * @Provenance Theme: World.Actor. C++ compiles this actor then expects a runtime Angelscript error
 * @Provenance when RunSpawnInvalidClassTest calls SpawnActor(nullptr). CSV marks NegativeDiagnostic;
 * @Provenance the method is a runtime exception oracle, not a compile-fail.
 * @Provenance C++: AngelscriptActorInteractionTests.cpp::SpawnActorInvalidClassThrowsException
 * @Provenance Spawn is the oracle (invalid class). FixtureIsolated.
 */

UCLASS()
class ATestActorSpawnInvalidClass : AActor
{
	/**
	 * The throwing entrypoint: SpawnActor with a null class raises at runtime. C++
	 * invokes this and expects the exception; no observer calls it.
	 *
	 * @Kind Action
	 * @Covers Actor.SpawnActorInvalidClassThrowsException
	 * @Inputs none
	 * @Return nothing; throws before it can return
	 */
	UFUNCTION()
	void RunSpawnInvalidClassTest()
	{
		AActor Spawned = SpawnActor(nullptr, FVector::ZeroVector, FRotator::ZeroRotator, n"InvalidSpawn");
	}
}
