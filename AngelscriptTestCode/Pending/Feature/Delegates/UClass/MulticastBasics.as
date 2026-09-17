/**
 * @version v1
 * @summary Multicast IsBound, AddUFunction, Broadcast, and Clear. After BeginPlay, Counter is 4. Before BeginPlay, Counter is 0 and the event is unbound.
 * @topic Feature
 */
/**
 * @version root
 * @summary Multicast IsBound, AddUFunction, Broadcast, and Clear. After BeginPlay, Counter is 4. Before BeginPlay, Counter is 0 and the event is unbound.
 * @topic Baseline
 */
/**
 * A parameterless multicast event.
 *
 * @Covers Delegates.Multicast
 * @Inputs none
 * @Return nothing when broadcast
 */
event void FCoverageMulticastBasicsSignal();

UCLASS()
class ACoverageMulticastBasicsActor : AActor
{
	UPROPERTY()
	int Counter = 0;

	UPROPERTY()
	FCoverageMulticastBasicsSignal OnMulticast;

	/**
	 * Walks IsBound, AddUFunction, Broadcast, and Clear.
	 *
	 * @Kind WorldStory
	 * @Covers Delegates.Multicast
	 * @Inputs none
	 * @Return nothing; Counter ends at 4
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		if (!OnMulticast.IsBound())
		{
			Counter = 1;
		}

		OnMulticast.AddUFunction(this, n"HandleMulticast");

		if (OnMulticast.IsBound())
		{
			Counter = 2;
		}

		OnMulticast.Broadcast();

		OnMulticast.Clear();
		if (!OnMulticast.IsBound())
		{
			Counter = 4;
		}
	}

	/**
	 * Sets Counter to 3 when the broadcast runs.
	 *
	 * @Covers Delegates.Multicast
	 * @Inputs none
	 * @Return nothing; Counter becomes 3
	 */
	UFUNCTION()
	void HandleMulticast()
	{
		Counter = 3;
	}

	/**
	 * Observe the pre-BeginPlay Counter.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Multicast
	 * @Inputs this
	 * @Return 0
	 * @Boundary default Counter
	 */
	UFUNCTION()
	int CounterDefaultZero()
	{
		return Counter;
	}

	/**
	 * Observe that OnMulticast starts unbound.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Multicast
	 * @Inputs this
	 * @Return true when OnMulticast is unbound
	 * @Boundary default unbound
	 */
	UFUNCTION()
	bool OnMulticastDefaultUnbound()
	{
		return !OnMulticast.IsBound();
	}
}
/** @end */
