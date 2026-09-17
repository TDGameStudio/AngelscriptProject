/**
 * @version v1
 * @summary A Blueprint child of a script actor preserves BeginPlay. BeginPlayCount defaults to 0 and becomes 1 after the runner's BeginPlay. Keep BeginPlayCount.
 * @topic Definitions
 */
/**
 * @version root
 * @summary A Blueprint child of a script actor preserves BeginPlay. BeginPlayCount defaults to 0 and becomes 1 after the runner's BeginPlay. Keep BeginPlayCount.
 * @topic Baseline
 */
UCLASS()
class ATestScriptClassBlueprintChildCompiles : AActor
{
	UPROPERTY()
	int BeginPlayCount = 0;

	/**
	 * WorldStory: BeginPlay increments BeginPlayCount.
	 *
	 * @Kind WorldStory
	 * @Covers UClass.BeginPlay
	 * @Inputs none
	 * @Return BeginPlayCount increased by 1
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		BeginPlayCount += 1;
	}

	/**
	 * Observe BeginPlayCount before play.
	 *
	 * @Kind Observe
	 * @Covers UClass.BeginPlay
	 * @Inputs a freshly constructed actor
	 * @Return BeginPlayCount
	 * @Boundary pre-BeginPlay
	 */
	UFUNCTION()
	int BeginPlayCountDefault()
	{
		return BeginPlayCount;
	}

	/**
	 * Observe that a nullptr handle is null.
	 *
	 * @Kind Observe
	 * @Covers UClass.BeginPlay
	 * @Inputs ATestScriptClassBlueprintChildCompiles Actor = nullptr
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool NullDefault()
	{
		ATestScriptClassBlueprintChildCompiles Actor = nullptr;
		return Actor == nullptr;
	}

	/**
	 * Observe that writing this actor leaves another at its default.
	 *
	 * @Kind Observe
	 * @Covers UClass.BeginPlay
	 * @Param Second Other actor expected to stay at 0
	 * @Inputs this.BeginPlayCount set to 1
	 * @Return true when Second.BeginPlayCount is 0
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ATestScriptClassBlueprintChildCompiles Second)
	{
		if (Second is null)
		{
			throw("BlueprintChildCompiles setup: required Second is null");
		}
		BeginPlayCount = 1;
		return Second.BeginPlayCount == 0;
	}
}
/** @end */
