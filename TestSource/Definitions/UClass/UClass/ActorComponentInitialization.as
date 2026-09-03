/**
 * A DefaultComponent is available at BeginPlay. BeginPlayCalled and
 * RootComponentAvailableAtBeginPlay become 1; RootComp is owned and registered.
 *
 * @Theme Definitions.UClass
 * @Subject UClass.ActorComponentInitialization
 * @Harness UClass
 * @Tag Definitions.UClass.ActorComponentInitialization
 * @Provenance Theme: Definitions.UClass. WorldStory DefaultComponent available at BeginPlay.
 * @Provenance C++: AngelscriptCoverageClassLifecycleTests.cpp::ActorComponentInitialization
 * @Provenance Oracle: BeginPlayCalled=1; RootComponentAvailableAtBeginPlay=1; RootComp owned and registered.
 * @Provenance Extra: unset handle is null; pre-BeginPlay counters stay 0. FixtureIsolated.
 */

UCLASS()
class AComponentInitActor : AActor
{
	UPROPERTY()
	int BeginPlayCalled = 0;

	UPROPERTY()
	int RootComponentAvailableAtBeginPlay = 0;

	UPROPERTY(DefaultComponent)
	USceneComponent RootComp;

	/**
	 * WorldStory: BeginPlay records that RootComp is already available.
	 *
	 * @Kind WorldStory
	 * @Covers UClass.DefaultComponent
	 * @Inputs RootComp
	 * @Return BeginPlayCalled = 1; RootComponentAvailableAtBeginPlay = 1 when RootComp is non-null
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		BeginPlayCalled = 1;
		if (RootComp != nullptr)
		{
			RootComponentAvailableAtBeginPlay = 1;
		}
	}

	/**
	 * Observe that an unset handle is null.
	 *
	 * @Kind Observe
	 * @Covers UClass.DefaultComponent
	 * @Inputs an unset AComponentInitActor handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool DefaultHandleIsNull()
	{
		AComponentInitActor Actor;
		return Actor == nullptr;
	}

	/**
	 * Observe initialization counters before BeginPlay.
	 *
	 * @Kind Observe
	 * @Covers UClass.DefaultComponent
	 * @Inputs a freshly constructed actor
	 * @Return BeginPlayCalled + RootComponentAvailableAtBeginPlay
	 * @Boundary pre-BeginPlay
	 */
	UFUNCTION()
	int CountersDefault()
	{
		return BeginPlayCalled + RootComponentAvailableAtBeginPlay;
	}
}
