/**
 * @version v1
 * @summary Mixed UFUNCTION listeners then a targeted Unbind. After BeginPlay, Counter is 21 (1+10, then Handler2 only +10). Before BeginPlay, Counter is 0 and the event is unbound.
 * @topic Feature
 */
/**
 * @version root
 * @summary Mixed UFUNCTION listeners then a targeted Unbind. After BeginPlay, Counter is 21 (1+10, then Handler2 only +10). Before BeginPlay, Counter is 0 and the event is unbound.
 * @topic Baseline
 */
/**
 * A parameterless multicast event.
 *
 * @Covers Delegates.Multicast
 * @Inputs none
 * @Return nothing when broadcast
 */
event void FCoverageMixedUFunctionSignal();

UCLASS()
class ACoverageMulticastMixedUFunctionActor : AActor
{
	UPROPERTY()
	int Counter = 0;

	UPROPERTY()
	FCoverageMixedUFunctionSignal OnMulticast;

	/**
	 * Adds two handlers, broadcasts, unbinds Handler, and broadcasts again.
	 *
	 * @Kind WorldStory
	 * @Covers Delegates.Multicast
	 * @Inputs none
	 * @Return nothing; Counter ends at 21
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		OnMulticast.AddUFunction(this, n"Handler");
		OnMulticast.AddUFunction(this, n"Handler2");
		OnMulticast.Broadcast();

		OnMulticast.Unbind(this, n"Handler");
		OnMulticast.Broadcast();
	}

	/**
	 * Adds 1 to Counter.
	 *
	 * @Covers Delegates.Multicast
	 * @Inputs none
	 * @Return nothing; Counter gains 1
	 */
	UFUNCTION()
	void Handler()
	{
		Counter += 1;
	}

	/**
	 * Adds 10 to Counter.
	 *
	 * @Covers Delegates.Multicast
	 * @Inputs none
	 * @Return nothing; Counter gains 10
	 */
	UFUNCTION()
	void Handler2()
	{
		Counter += 10;
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
