/**
 * Unbind removes one (object, function) pair. After BeginPlay, Counter is 201
 * (Handler once plus OtherHandler twice; AddUFunction is unique). Before
 * BeginPlay, Counter is 0 and the event is unbound.
 *
 * @Theme Feature.Delegates
 * @Subject Delegates.MulticastRemoveAll
 * @Harness UClass
 * @Tag Feature.Delegates.MulticastRemoveAll
 * @Provenance Theme: Feature.Delegates. WorldStory: Unbind removes one (object, function) pair.
 * @Provenance C++: AngelscriptCoverageMulticastDelegateTests.cpp::MulticastRemoveAll
 * @Provenance Spawn + BeginPlay oracle: Counter==201 (Handler once + OtherHandler twice; AddUFunction is unique).
 * @Provenance Extra: default Counter 0; default event unbound. Keep Counter.
 * @Provenance FixtureIsolated.
 */

/**
 * A parameterless multicast event.
 *
 * @Covers Delegates.Unbind
 * @Inputs none
 * @Return nothing when broadcast
 */
event void FCoverageMulticastRemoveAllSignal();

UCLASS()
class ACoverageMulticastRemoveAllActor : AActor
{
	UPROPERTY()
	int Counter = 0;

	UPROPERTY()
	FCoverageMulticastRemoveAllSignal OnMulticast;

	/**
	 * Adds Handler uniquely, adds OtherHandler, broadcasts, unbinds Handler, and broadcasts again.
	 *
	 * @Kind WorldStory
	 * @Covers Delegates.Unbind
	 * @Inputs none
	 * @Return nothing; Counter ends at 201
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		OnMulticast.AddUFunction(this, n"Handler");
		OnMulticast.AddUFunction(this, n"Handler");
		OnMulticast.AddUFunction(this, n"Handler");

		OnMulticast.AddUFunction(this, n"OtherHandler");

		OnMulticast.Broadcast();

		OnMulticast.Unbind(this, n"Handler");

		OnMulticast.Broadcast();
	}

	/**
	 * Adds 1 to Counter.
	 *
	 * @Covers Delegates.Unbind
	 * @Inputs none
	 * @Return nothing; Counter gains 1
	 */
	UFUNCTION()
	void Handler()
	{
		Counter += 1;
	}

	/**
	 * Adds 100 to Counter.
	 *
	 * @Covers Delegates.Unbind
	 * @Inputs none
	 * @Return nothing; Counter gains 100
	 */
	UFUNCTION()
	void OtherHandler()
	{
		Counter += 100;
	}

	/**
	 * Observe the pre-BeginPlay Counter.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Unbind
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
	 * @Covers Delegates.Unbind
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
