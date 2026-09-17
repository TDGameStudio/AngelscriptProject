/**
 * @version v1
 * @summary A spawned script actor observes BeginPlay. BeginPlayObserved becomes 1 after the runner enters the world and defaults to 0 before play. Keep BeginPlayObserved.
 * @topic Definitions
 */
/**
 * @version root
 * @summary A spawned script actor observes BeginPlay. BeginPlayObserved becomes 1 after the runner enters the world and defaults to 0 before play. Keep BeginPlayObserved.
 * @topic Baseline
 */
UCLASS()
class ATestScriptClassCanSpawnInTestWorld : AActor
{
	UPROPERTY()
	int BeginPlayObserved = 0;

	/**
	 * WorldStory: BeginPlay records that play started.
	 *
	 * @Kind WorldStory
	 * @Covers UClass.BeginPlay
	 * @Inputs none
	 * @Return BeginPlayObserved = 1
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		BeginPlayObserved = 1;
	}

	/**
	 * Observe BeginPlayObserved before play.
	 *
	 * @Kind Observe
	 * @Covers UClass.BeginPlay
	 * @Inputs a freshly constructed actor
	 * @Return BeginPlayObserved
	 * @Boundary pre-BeginPlay
	 */
	UFUNCTION()
	int BeginPlayObservedDefault()
	{
		return BeginPlayObserved;
	}

	/**
	 * Observe that a nullptr handle is null.
	 *
	 * @Kind Observe
	 * @Covers UClass.BeginPlay
	 * @Inputs ATestScriptClassCanSpawnInTestWorld Actor = nullptr
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool NullDefault()
	{
		ATestScriptClassCanSpawnInTestWorld Actor = nullptr;
		return Actor == nullptr;
	}

	/**
	 * Observe that writing this actor leaves another at its default.
	 *
	 * @Kind Observe
	 * @Covers UClass.BeginPlay
	 * @Param Second Other actor expected to stay at 0
	 * @Inputs this.BeginPlayObserved set to 1
	 * @Return true when Second.BeginPlayObserved is 0
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ATestScriptClassCanSpawnInTestWorld Second)
	{
		if (Second is null)
		{
			throw("CanSpawnInTestWorld setup: required Second is null");
		}
		BeginPlayObserved = 1;
		return Second.BeginPlayObserved == 0;
	}
}
/** @end */
