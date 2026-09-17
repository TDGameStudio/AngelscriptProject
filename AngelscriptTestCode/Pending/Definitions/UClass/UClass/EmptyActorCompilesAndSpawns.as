/**
 * @version v1
 * @summary An empty actor compiles, spawns, BeginPlay, and Destroy. C++ counts 0 declared user properties, so this class must not grow a UPROPERTY.
 * @topic Definitions
 */
/**
 * @version root
 * @summary An empty actor compiles, spawns, BeginPlay, and Destroy. C++ counts 0 declared user properties, so this class must not grow a UPROPERTY.
 * @topic Baseline
 */
UCLASS()
class AEmptyScriptActor : AActor
{
	/**
	 * Observe that a nullptr handle is null.
	 *
	 * @Kind Observe
	 * @Covers UClass.EmptyActor
	 * @Inputs AEmptyScriptActor Actor = nullptr
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool NullDefault()
	{
		AEmptyScriptActor Actor = nullptr;
		return Actor == nullptr;
	}

	/**
	 * Observe that the generated class is an AActor child.
	 *
	 * @Kind Observe
	 * @Covers UClass.EmptyActor
	 * @Inputs AEmptyScriptActor::StaticClass()
	 * @Return true when IsChildOf(AActor::StaticClass())
	 */
	UFUNCTION()
	bool IsActorChild()
	{
		return AEmptyScriptActor::StaticClass().IsChildOf(AActor::StaticClass());
	}

	/**
	 * Observe that two spawned handles remain distinct objects.
	 *
	 * @Kind Observe
	 * @Covers UClass.EmptyActor
	 * @Param Second Other spawned actor
	 * @Inputs this and Second
	 * @Return true when both are non-null and not the same object
	 * @Boundary instance independence
	 */
	UFUNCTION()
	bool TwoHandlesIndependent(AEmptyScriptActor Second)
	{
		if (Second is null)
		{
			throw("EmptyActorCompilesAndSpawns setup: required Second is null");
		}
		return this != Second;
	}
}
/** @end */
