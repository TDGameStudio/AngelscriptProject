/**
 * UserConstructionScript then BeginPlay. ConstructionScriptCalled is >0 on
 * spawn and BeginPlaySawConstruction becomes 1.
 *
 * @Theme Definitions.UClass
 * @Subject UClass.ActorConstructionScript
 * @Harness UClass
 * @Tag Definitions.UClass.ActorConstructionScript
 * @Provenance Theme: Definitions.UClass. WorldStory UserConstructionScript then BeginPlay.
 * @Provenance C++: AngelscriptCoverageClassLifecycleTests.cpp::ActorConstructionScript
 * @Provenance Oracle: ConstructionScriptCalled>0 on spawn; BeginPlaySawConstruction=1.
 * @Provenance Extra: unset handle is null; pre-spawn counters stay 0. FixtureIsolated.
 */

UCLASS()
class AConstructionActor : AActor
{
	UPROPERTY()
	int ConstructionScriptCalled = 0;

	UPROPERTY()
	int BeginPlaySawConstruction = 0;

	/**
	 * WorldStory: UserConstructionScript increments ConstructionScriptCalled.
	 *
	 * @Kind WorldStory
	 * @Covers UClass.ConstructionScript
	 * @Inputs none
	 * @Return ConstructionScriptCalled increased by 1
	 */
	UFUNCTION(BlueprintOverride)
	void UserConstructionScript()
	{
		ConstructionScriptCalled++;
	}

	/**
	 * WorldStory: BeginPlay records that construction already ran.
	 *
	 * @Kind WorldStory
	 * @Covers UClass.ConstructionScript
	 * @Inputs ConstructionScriptCalled
	 * @Return BeginPlaySawConstruction = 1 when construction ran
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		if (ConstructionScriptCalled > 0)
		{
			BeginPlaySawConstruction = 1;
		}
	}

	/**
	 * Observe that an unset handle is null.
	 *
	 * @Kind Observe
	 * @Covers UClass.ConstructionScript
	 * @Inputs an unset AConstructionActor handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool DefaultHandleIsNull()
	{
		AConstructionActor Actor;
		return Actor == nullptr;
	}

	/**
	 * Observe construction counters before spawn.
	 *
	 * @Kind Observe
	 * @Covers UClass.ConstructionScript
	 * @Inputs a freshly constructed actor
	 * @Return ConstructionScriptCalled + BeginPlaySawConstruction
	 * @Boundary pre-spawn
	 */
	UFUNCTION()
	int CountersDefault()
	{
		return ConstructionScriptCalled + BeginPlaySawConstruction;
	}
}
