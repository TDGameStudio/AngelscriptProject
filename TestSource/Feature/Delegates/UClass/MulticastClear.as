/**
 * Multicast Clear drops every listener. After BeginPlay, Counter is 1111.
 * Before BeginPlay, Counter is 0 and the event is unbound.
 *
 * @Theme Feature.Delegates
 * @Subject Delegates.MulticastClear
 * @Harness UClass
 * @Tag Feature.Delegates.MulticastClear
 * @Provenance Theme: Feature.Delegates. WorldStory: multicast Clear drops every listener.
 * @Provenance C++: AngelscriptCoverageMulticastDelegateTests.cpp::MulticastClear
 * @Provenance Spawn + BeginPlay oracle: Counter==1111 (1+10+100 then +1000 unbound).
 * @Provenance Extra: default Counter 0; default event unbound. Keep Counter.
 * @Provenance FixtureIsolated.
 */

/**
 * A parameterless multicast event.
 *
 * @Covers Delegates.Clear
 * @Inputs none
 * @Return nothing when broadcast
 */
event void FCoverageMulticastClearSignal();

UCLASS()
class ACoverageMulticastClearActor : AActor
{
	UPROPERTY()
	int Counter = 0;

	UPROPERTY()
	FCoverageMulticastClearSignal OnMulticast;

	/**
	 * Adds three listeners, broadcasts, clears, and broadcasts again.
	 *
	 * @Kind WorldStory
	 * @Covers Delegates.Clear
	 * @Inputs none
	 * @Return nothing; Counter ends at 1111
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		OnMulticast.AddUFunction(this, n"Listener1");
		OnMulticast.AddUFunction(this, n"Listener2");
		OnMulticast.AddUFunction(this, n"Listener3");

		OnMulticast.Broadcast();

		OnMulticast.Clear();

		OnMulticast.Broadcast();

		if (!OnMulticast.IsBound())
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
	void Listener1()
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
	void Listener2()
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
	void Listener3()
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
	 * Observe that OnMulticast starts unbound.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Clear
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
