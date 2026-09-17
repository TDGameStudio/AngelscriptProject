/**
 * @version v1
 * @summary Actor BeginPlay/Tick/EndPlay/Destroyed overrides. After spawn+BeginPlay, BeginPlayCalled is 1. Pre-BeginPlay counters stay 0.
 * @topic Definitions
 */
/**
 * @version root
 * @summary Actor BeginPlay/Tick/EndPlay/Destroyed overrides. After spawn+BeginPlay, BeginPlayCalled is 1. Pre-BeginPlay counters stay 0.
 * @topic Baseline
 */
UCLASS()
class ALifecycleActor : AActor
{
	UPROPERTY()
	int BeginPlayCalled = 0;

	UPROPERTY()
	int TickCount = 0;

	UPROPERTY()
	int EndPlayCalled = 0;

	UPROPERTY()
	int DestroyedCalled = 0;

	UPROPERTY()
	float AccumulatedDeltaTime = 0.0f;

	/**
	 * WorldStory: BeginPlay records that play started.
	 *
	 * @Kind WorldStory
	 * @Covers UClass.Lifecycle
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
	 * @Covers UClass.Lifecycle
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
	 * WorldStory: EndPlay records that play ended.
	 *
	 * @Kind WorldStory
	 * @Covers UClass.Lifecycle
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
	 * WorldStory: Destroyed records that the actor was destroyed.
	 *
	 * @Kind WorldStory
	 * @Covers UClass.Lifecycle
	 * @Inputs none
	 * @Return DestroyedCalled = 1
	 */
	UFUNCTION(BlueprintOverride)
	void Destroyed()
	{
		DestroyedCalled = 1;
	}

	/**
	 * Observe that an unset handle is null.
	 *
	 * @Kind Observe
	 * @Covers UClass.Lifecycle
	 * @Inputs an unset ALifecycleActor handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool DefaultHandleIsNull()
	{
		ALifecycleActor Actor;
		return Actor == nullptr;
	}

	/**
	 * Observe lifecycle counters before BeginPlay.
	 *
	 * @Kind Observe
	 * @Covers UClass.Lifecycle
	 * @Inputs a freshly constructed actor
	 * @Return BeginPlayCalled + TickCount + EndPlayCalled + DestroyedCalled
	 * @Boundary pre-BeginPlay
	 */
	UFUNCTION()
	int CountersBeforeBeginPlay()
	{
		return BeginPlayCalled + TickCount + EndPlayCalled + DestroyedCalled;
	}

	/**
	 * Observe Tick with a zero delta.
	 *
	 * @Kind Observe
	 * @Covers UClass.Lifecycle
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
/** @end */
