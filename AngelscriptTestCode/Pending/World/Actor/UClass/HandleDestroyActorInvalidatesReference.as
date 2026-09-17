/**
 * @version v1
 * @summary An actor handle invalidated by DestroyActor. C++ verifies DestroyCalled and InvalidAfterDestroy by path. The CSV NegativeDiagnostic label is a heuristic: the method is a lifecycle oracle, not a compile failure. A missing.
 * @topic World
 */
/**
 * @version root
 * @summary An actor handle invalidated by DestroyActor. C++ verifies DestroyCalled and InvalidAfterDestroy by path. The CSV NegativeDiagnostic label is a heuristic: the method is a lifecycle oracle, not a compile failure. A missing.
 * @topic Baseline
 */
UCLASS()
class ACoverageHandleDestroyActor : AActor
{
	UPROPERTY()
	AActor Victim;

	UPROPERTY()
	bool DestroyCalled = false;

	UPROPERTY()
	bool InvalidAfterDestroy = false;

	/**
	 * WorldStory: BeginPlay spawns a victim, destroys it, then records that the handle
	 * went invalid.
	 *
	 * @Kind WorldStory
	 * @Covers Actor.HandleDestroyActorInvalidatesReference
	 * @Inputs none
	 * @Return DestroyCalled true once the victim was destroyed; InvalidAfterDestroy true once
	 * the handle no longer resolves
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Victim = SpawnActor(AActor::StaticClass());
		if (Victim != nullptr)
		{
			Victim.DestroyActor();
			DestroyCalled = true;
		}
		InvalidAfterDestroy = !IsValid(Victim);
	}

	/**
	 * Observe that a locally constructed actor has destroyed nothing.
	 *
	 * @Kind Observe
	 * @Covers Actor.HandleDestroyActorInvalidatesReference
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when the victim is null, DestroyCalled is clear and InvalidAfterDestroy is clear
	 * @Boundary local construct
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (Victim != nullptr)
		{
			return false;
		}
		if (DestroyCalled)
		{
			return false;
		}
		return !InvalidAfterDestroy;
	}
}
/** @end */
