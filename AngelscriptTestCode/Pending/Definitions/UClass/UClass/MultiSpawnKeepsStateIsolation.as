/**
 * @version v1
 * @summary Two spawned instances keep isolated LocalState. LocalState defaults to 3; after First=11, Second stays 3. Keep LocalState.
 * @topic Definitions
 */
/**
 * @version root
 * @summary Two spawned instances keep isolated LocalState. LocalState defaults to 3; after First=11, Second stays 3. Keep LocalState.
 * @topic Baseline
 */
UCLASS()
class ATestScriptClassMultiSpawnKeepsStateIsolation : AActor
{
	UPROPERTY()
	int LocalState = 3;

	/**
	 * Observe the LocalState default.
	 *
	 * @Kind Observe
	 * @Covers UClass.MultiSpawn
	 * @Inputs a freshly constructed actor
	 * @Return LocalState
	 */
	UFUNCTION()
	int LocalStateDefault()
	{
		return LocalState;
	}

	/**
	 * Observe that writing this actor leaves another at 3.
	 *
	 * @Kind Observe
	 * @Covers UClass.MultiSpawn
	 * @Param Second Other actor expected to stay at 3
	 * @Inputs this.LocalState set to 11
	 * @Return Second.LocalState
	 * @Boundary copy independence
	 */
	UFUNCTION()
	int MutatedFirstKeepsSecond(ATestScriptClassMultiSpawnKeepsStateIsolation Second)
	{
		if (Second is null)
		{
			throw("MultiSpawnKeepsStateIsolation setup: required Second is null");
		}
		LocalState = 11;
		return Second.LocalState;
	}

	/**
	 * Observe writing LocalState to 0.
	 *
	 * @Kind Observe
	 * @Covers UClass.MultiSpawn
	 * @Inputs LocalState set to 0
	 * @Return LocalState
	 * @Boundary zero
	 */
	UFUNCTION()
	int EmptyZeroBoundary()
	{
		LocalState = 0;
		return LocalState;
	}
}
/** @end */
