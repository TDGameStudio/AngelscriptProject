/**
 * Component BeginPlay/Tick/EndPlay on a DefaultComponent. After play,
 * LifecycleComp.BeginPlayCalled is 1; TickCount and AccumulatedDeltaTime
 * record ticks; EndPlayCalled becomes 1 after DestroyComponent.
 *
 * @Theme Definitions.UClass
 * @Subject UClass.ComponentLifecycle
 * @Harness UClass
 * @Tag Definitions.UClass.ComponentLifecycle
 * @Provenance Theme: Definitions.UClass. WorldStory component BeginPlay/Tick/EndPlay on a DefaultComponent.
 * @Provenance C++: AngelscriptCoverageClassLifecycleTests.cpp::ComponentLifecycle
 * @Provenance Oracle: LifecycleComp.BeginPlayCalled=1; TickCount=1 AccumulatedDeltaTime=0.25; EndPlayCalled=1 after DestroyComponent.
 * @Provenance Extra: unset handles are null; pre-BeginPlay counters stay 0. FixtureIsolated.
 */

UCLASS()
class ULifecycleComponent : UActorComponent
{
	UPROPERTY()
	int BeginPlayCalled = 0;

	UPROPERTY()
	int TickCount = 0;

	UPROPERTY()
	int EndPlayCalled = 0;

	UPROPERTY()
	float AccumulatedDeltaTime = 0.0f;

	/**
	 * WorldStory: BeginPlay records that the component entered play.
	 *
	 * @Kind WorldStory
	 * @Covers UClass.ComponentLifecycle
	 * @Inputs none
	 * @Return BeginPlayCalled = 1
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		BeginPlayCalled = 1;
	}

	/**
	 * WorldStory: Tick counts frames and accumulates delta time.
	 *
	 * @Kind WorldStory
	 * @Covers UClass.ComponentLifecycle
	 * @Param DeltaSeconds Frame delta
	 * @Inputs TickCount and AccumulatedDeltaTime
	 * @Return TickCount increased; AccumulatedDeltaTime increased by DeltaSeconds
	 */
	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaSeconds)
	{
		TickCount++;
		AccumulatedDeltaTime += DeltaSeconds;
	}

	/**
	 * WorldStory: EndPlay records that the component left play.
	 *
	 * @Kind WorldStory
	 * @Covers UClass.ComponentLifecycle
	 * @Param EndPlayReason Why play ended
	 * @Inputs none
	 * @Return EndPlayCalled = 1
	 */
	UFUNCTION(BlueprintOverride)
	void EndPlay(EEndPlayReason EndPlayReason)
	{
		EndPlayCalled = 1;
	}

	/**
	 * Observe that an unset component handle is null.
	 *
	 * @Kind Observe
	 * @Covers UClass.ComponentLifecycle
	 * @Inputs an unset ULifecycleComponent handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool DefaultHandleIsNull()
	{
		ULifecycleComponent Comp;
		return Comp == nullptr;
	}

	/**
	 * Observe lifecycle counters before play.
	 *
	 * @Kind Observe
	 * @Covers UClass.ComponentLifecycle
	 * @Inputs a freshly constructed component
	 * @Return BeginPlayCalled + TickCount + EndPlayCalled
	 * @Boundary pre-BeginPlay
	 */
	UFUNCTION()
	int CountersDefault()
	{
		return BeginPlayCalled + TickCount + EndPlayCalled;
	}

	/**
	 * Observe Tick with a zero delta.
	 *
	 * @Kind Observe
	 * @Covers UClass.ComponentLifecycle
	 * @Inputs Tick(0.0f)
	 * @Return TickCount after the call
	 * @Boundary zero delta
	 */
	UFUNCTION()
	int TickZeroDeltaBoundary()
	{
		Tick(0.0f);
		return TickCount;
	}
}

UCLASS()
class AComponentOwnerActor : AActor
{
	UPROPERTY(DefaultComponent)
	ULifecycleComponent LifecycleComp;

	/**
	 * Observe that an unset owner handle is null.
	 *
	 * @Kind Observe
	 * @Covers UClass.ComponentLifecycle
	 * @Inputs an unset AComponentOwnerActor handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool DefaultHandleIsNull()
	{
		AComponentOwnerActor Actor;
		return Actor == nullptr;
	}
}
