/**
 * A Blueprint child of a script actor preserves BeginPlay. BeginPlayCount
 * defaults to 0 and becomes 1 after the runner's BeginPlay. Keep BeginPlayCount.
 *
 * @Theme Definitions.UClass
 * @Subject UClass.BlueprintChildCompiles
 * @Harness UClass
 * @Tag Definitions.UClass.BlueprintChildCompiles
 * @Provenance Theme: Definitions.UClass. WorldStory: Blueprint child of a script actor preserves BeginPlay.
 * @Provenance C++: AngelscriptScriptClassCreationTests.cpp::BlueprintChildCompiles spawn BlueprintClass then BeginPlayCount == 1.
 * @Provenance Oracle: BeginPlayCount defaults to 0 and becomes 1 after the runner's BeginPlay.
 * @Provenance Extra: default 0 is the empty vector; mutating one actor does not write the other.
 * @Provenance FixtureIsolated. Runner owns Blueprint child, spawn, and World teardown. Keep BeginPlayCount.
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
