/**
 * @version v1
 * @summary A component Tick override incrementing a counter. C++ enables ticking, ticks the world five times and verifies the count by path. The observers cover the local-construct default and copy independence.
 * @topic World
 */
/**
 * @version root
 * @summary A component Tick override incrementing a counter. C++ enables ticking, ticks the world five times and verifies the count by path. The observers cover the local-construct default and copy independence.
 * @topic Baseline
 */
UCLASS()
class UTestComponentTick : UActorComponent
{
	UPROPERTY()
	int TickCount = 0;

	/**
	 * WorldStory: Tick increments the counter once per dispatch.
	 *
	 * @Kind WorldStory
	 * @Covers Component.Tick
	 * @Inputs the frame delta, unused
	 * @Return TickCount incremented once per tick
	 * @Param DeltaSeconds the frame delta
	 */
	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaSeconds)
	{
		TickCount += 1;
	}

	/**
	 * Observe that a locally constructed component has not ticked.
	 *
	 * @Kind Observe
	 * @Covers Component.Tick
	 * @Inputs a component that has not been ticked
	 * @Return true when TickCount is 0
	 * @Boundary local construct
	 */
	UFUNCTION()
	bool DefaultZero()
	{
		return TickCount == 0;
	}

	/**
	 * Observe that writing this component leaves another component untouched.
	 *
	 * @Kind Observe
	 * @Covers Component.Tick
	 * @Inputs this component plus a second component
	 * @Return true when this counts 5 and the other stays at 0
	 * @Param Second the other component, expected to stay at zero
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(UTestComponentTick Second)
	{
		if (Second is null)
		{
			throw("Tick setup: required Second is null");
		}
		TickCount = 5;

		if (TickCount != 5)
		{
			return false;
		}
		return Second.TickCount == 0;
	}
}
/** @end */
