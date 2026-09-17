/**
 * @version v1
 * @summary Actor lifecycle overrides combined with a custom event broadcast from both BeginPlay and EndPlay. The observers confirm the default state and the BeginPlay path; the world runner supplies Tick and Destroy for the rest.
 * @topic Language
 */
/**
 * @version root
 * @summary Actor lifecycle overrides combined with a custom event broadcast from both BeginPlay and EndPlay. The observers confirm the default state and the BeginPlay path; the world runner supplies Tick and Destroy for the rest.
 * @topic Baseline
 */
/**
 * The lifecycle event broadcast from BeginPlay and EndPlay.
 *
 * @Covers Syntax.EdgeCases
 * @Inputs none
 * @Return nothing when broadcast
 */
event void FCoverageLifecycleEvent();

UCLASS()
class ACoverageEventLifecycleActor : AActor
{
	UPROPERTY()
	int BeginPlayCount = 0;

	UPROPERTY()
	int TickCount = 0;

	UPROPERTY()
	int EndPlayCount = 0;

	UPROPERTY()
	int LifecycleEventCount = 0;

	UPROPERTY()
	FCoverageLifecycleEvent OnLifecycle;

	/**
	 * Binds the lifecycle handler and broadcasts the first time.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing; BeginPlayCount gains 1 and the event fires
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		OnLifecycle.AddUFunction(this, n"HandleLifecycle");
		BeginPlayCount += 1;
		OnLifecycle.Broadcast();
	}

	/**
	 * Counts each world tick.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the frame delta
	 * @Return nothing; TickCount gains 1
	 * @Param DeltaTime the seconds since the last tick
	 */
	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaTime)
	{
		TickCount += 1;
	}

	/**
	 * Broadcasts the lifecycle event a final time.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the reason play is ending
	 * @Return nothing; EndPlayCount gains 1 and the event fires
	 * @Param Reason why the actor is leaving play
	 */
	UFUNCTION(BlueprintOverride)
	void EndPlay(EEndPlayReason Reason)
	{
		EndPlayCount += 1;
		OnLifecycle.Broadcast();
	}

	/**
	 * Records each lifecycle broadcast.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing; LifecycleEventCount gains 1
	 */
	UFUNCTION()
	void HandleLifecycle()
	{
		LifecycleEventCount += 1;
	}

	/**
	 * Observe that a locally constructed actor has counted nothing.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return true when all four counters are 0
	 * @Boundary default construction
	 */
	UFUNCTION()
	bool EventLifecycleCountersDefaultToZero()
	{
		if (BeginPlayCount != 0)
		{
			return false;
		}

		if (TickCount != 0)
		{
			return false;
		}

		if (EndPlayCount != 0)
		{
			return false;
		}

		return LifecycleEventCount == 0;
	}

	/**
	 * Observe the counts after the BeginPlay path runs.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs BeginPlay() then the counters
	 * @Return true when BeginPlayCount and LifecycleEventCount are both 1
	 */
	UFUNCTION()
	bool EventLifecycleBeginPlayBroadcastsOnce()
	{
		BeginPlay();

		if (BeginPlayCount != 1)
		{
			return false;
		}

		return LifecycleEventCount == 1;
	}
}
/** @end */
