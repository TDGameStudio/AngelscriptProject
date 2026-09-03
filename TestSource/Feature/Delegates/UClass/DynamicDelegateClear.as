/**
 * Multicast Clear removes all dynamic bindings. After BeginPlay, Counter is
 * 1111. Before BeginPlay, Counter is 0 and the event is unbound.
 *
 * @Theme Feature.Delegates
 * @Subject Delegates.DynamicDelegateClear
 * @Harness UClass
 * @Tag Feature.Delegates.DynamicDelegateClear
 * @Provenance Theme: Feature.Delegates. WorldStory: multicast Clear removes all dynamic bindings.
 * @Provenance C++: AngelscriptCoverageDynamicDelegateTests.cpp::DynamicDelegateClear
 * @Provenance Spawn + BeginPlay oracle: Counter==1111 (1+10+100 first broadcast, then +1000 when unbound).
 * @Provenance Extra: default Counter 0; default event is unbound. Keep Counter.
 * @Provenance FixtureIsolated.
 */

/**
 * A parameterless multicast event.
 *
 * @Covers Delegates.Clear
 * @Inputs none
 * @Return nothing when broadcast
 */
event void FCoverageDynamicClearEvent();

UCLASS()
class ACoverageDynamicClearActor : AActor
{
	UPROPERTY()
	int Counter = 0;

	FCoverageDynamicClearEvent OnEvent;

	/**
	 * Adds three handlers, broadcasts, clears, and broadcasts again.
	 *
	 * @Kind WorldStory
	 * @Covers Delegates.Clear
	 * @Inputs none
	 * @Return nothing; Counter ends at 1111
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		OnEvent.AddUFunction(this, n"Handler1");
		OnEvent.AddUFunction(this, n"Handler2");
		OnEvent.AddUFunction(this, n"Handler3");

		OnEvent.Broadcast();

		OnEvent.Clear();

		OnEvent.Broadcast();

		if (!OnEvent.IsBound())
		{
			Counter += 1000;
		}
	}

	/**
	 * Adds 1 to Counter.
	 *
	 * @Covers Delegates.Clear
	 * @Inputs none
	 * @Return nothing; Counter gains 1
	 */
	UFUNCTION()
	void Handler1()
	{
		Counter += 1;
	}

	/**
	 * Adds 10 to Counter.
	 *
	 * @Covers Delegates.Clear
	 * @Inputs none
	 * @Return nothing; Counter gains 10
	 */
	UFUNCTION()
	void Handler2()
	{
		Counter += 10;
	}

	/**
	 * Adds 100 to Counter.
	 *
	 * @Covers Delegates.Clear
	 * @Inputs none
	 * @Return nothing; Counter gains 100
	 */
	UFUNCTION()
	void Handler3()
	{
		Counter += 100;
	}

	/**
	 * Observe the pre-BeginPlay Counter.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Clear
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
	 * Observe that OnEvent starts unbound.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Clear
	 * @Inputs this
	 * @Return true when OnEvent is unbound
	 * @Boundary default unbound
	 */
	UFUNCTION()
	bool OnEventDefaultUnbound()
	{
		return !OnEvent.IsBound();
	}
}
