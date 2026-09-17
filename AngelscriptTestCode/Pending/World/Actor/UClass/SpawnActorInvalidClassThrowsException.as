/**
 * @version v1
 * @summary SpawnActor called with a null class, which must raise a script exception at runtime. C++ compiles this actor and then invokes the entrypoint expecting the exception, so this is a runtime exception oracle rather than a.
 * @topic World
 */
/**
 * @version root
 * @summary SpawnActor called with a null class, which must raise a script exception at runtime. C++ compiles this actor and then invokes the entrypoint expecting the exception, so this is a runtime exception oracle rather than a.
 * @topic Baseline
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
/** @end */
