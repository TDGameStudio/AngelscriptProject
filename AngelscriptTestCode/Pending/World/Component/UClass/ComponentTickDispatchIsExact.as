/**
 * @version v1
 * @summary A component Tick override counted across an exact number of direct dispatches. C++ dispatches four ticks and compares the count against its expected value. The observers cover the local-construct defaults and copy.
 * @topic World
 */
/**
 * @version root
 * @summary A component Tick override counted across an exact number of direct dispatches. C++ dispatches four ticks and compares the count against its expected value. The observers cover the local-construct defaults and copy.
 * @topic Baseline
 */
UCLASS()
class UTestComponentLifecycleExactTickProbe : UActorComponent
{
	UPROPERTY()
	int TickCount = 0;

	/**
	 * Count every tick dispatch.
	 *
	 * @Kind WorldStory
	 * @Covers Component.TickDispatchIsExact
	 * @Inputs the frame delta, unused
	 * @Return TickCount incremented once per dispatch
	 * @Param DeltaSeconds the frame delta
	 */
	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaSeconds)
	{
		TickCount += 1;
	}

	/**
	 * Observe that a locally constructed probe has not ticked.
	 *
	 * @Kind Observe
	 * @Covers Component.TickDispatchIsExact
	 * @Inputs a probe that has not been dispatched
	 * @Return true when TickCount is 0
	 * @Boundary local construct
	 */
	UFUNCTION()
	bool ProbeDefaultZero()
	{
		return TickCount == 0;
	}

	/**
	 * Observe that writing this probe leaves another probe untouched.
	 *
	 * @Kind Observe
	 * @Covers Component.TickDispatchIsExact
	 * @Inputs this probe plus a second probe
	 * @Return true when this counts 4 and the other stays at 0
	 * @Param Second the other probe, expected to stay at zero
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(UTestComponentLifecycleExactTickProbe Second)
	{
		if (Second is null)
		{
			throw("ComponentTickDispatchIsExact setup: required Second is null");
		}
		TickCount = 4;

		if (TickCount != 4)
		{
			return false;
		}
		return Second.TickCount == 0;
	}
}

UCLASS()
class ATestComponentLifecycleExactTick : AActor
{
	UPROPERTY(DefaultComponent)
	UTestComponentLifecycleExactTickProbe Probe;

	/**
	 * Observe that a locally constructed actor has no probe component.
	 *
	 * @Kind Observe
	 * @Covers Component.TickDispatchIsExact
	 * @Inputs an actor that has not been spawned
	 * @Return true when Probe is null
	 * @Boundary null default component
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		return Probe == nullptr;
	}
}
/** @end */
