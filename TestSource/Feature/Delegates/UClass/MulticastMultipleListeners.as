/**
 * Three multicast listeners run in add order. After BeginPlay, Counter is 111
 * and Result is "ABC". Before BeginPlay, Counter is 0 and Result is empty.
 *
 * @Theme Feature.Delegates
 * @Subject Delegates.MulticastMultipleListeners
 * @Harness UClass
 * @Tag Feature.Delegates.MulticastMultipleListeners
 * @Provenance Theme: Feature.Delegates. WorldStory: three multicast listeners run in add order.
 * @Provenance C++: AngelscriptCoverageMulticastDelegateTests.cpp::MulticastMultipleListeners
 * @Provenance Spawn + BeginPlay oracle: Counter==111 (1+10+100), Result=="ABC".
 * @Provenance Extra: default Counter 0 / empty Result; default event unbound. Keep Counter, Result.
 * @Provenance FixtureIsolated.
 */

/**
 * A parameterless multicast event.
 *
 * @Covers Delegates.Multicast
 * @Inputs none
 * @Return nothing when broadcast
 */
event void FCoverageMulticastMultipleSignal();

UCLASS()
class ACoverageMulticastMultipleActor : AActor
{
	UPROPERTY()
	int Counter = 0;

	UPROPERTY()
	FString Result;

	UPROPERTY()
	FCoverageMulticastMultipleSignal OnMulticast;

	/**
	 * Adds three listeners and broadcasts once.
	 *
	 * @Kind WorldStory
	 * @Covers Delegates.Multicast
	 * @Inputs none
	 * @Return nothing; Counter ends at 111 and Result is ABC
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		OnMulticast.AddUFunction(this, n"Listener1");
		OnMulticast.AddUFunction(this, n"Listener2");
		OnMulticast.AddUFunction(this, n"Listener3");

		OnMulticast.Broadcast();
	}

	/**
	 * Adds 1 and appends A.
	 *
	 * @Covers Delegates.Multicast
	 * @Inputs none
	 * @Return nothing; Counter and Result are updated
	 */
	UFUNCTION()
	void Listener1()
	{
		Counter += 1;
		Result += "A";
	}

	/**
	 * Adds 10 and appends B.
	 *
	 * @Covers Delegates.Multicast
	 * @Inputs none
	 * @Return nothing; Counter and Result are updated
	 */
	UFUNCTION()
	void Listener2()
	{
		Counter += 10;
		Result += "B";
	}

	/**
	 * Adds 100 and appends C.
	 *
	 * @Covers Delegates.Multicast
	 * @Inputs none
	 * @Return nothing; Counter and Result are updated
	 */
	UFUNCTION()
	void Listener3()
	{
		Counter += 100;
		Result += "C";
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
	 * Observe that Result starts empty.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Multicast
	 * @Inputs this
	 * @Return true when Result is empty
	 * @Boundary default empty
	 */
	UFUNCTION()
	bool ResultDefaultEmpty()
	{
		return Result.Len() == 0;
	}

	/**
	 * Observe that appending to a copy leaves the original string.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Multicast
	 * @Inputs Original "ABC"; Copy += "X"
	 * @Return true when Original is ABC and Copy is ABCX
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool StringCopyIndependence()
	{
		FString Original = "ABC";
		FString Copy = Original;
		Copy += "X";
		if (Original != "ABC")
		{
			return false;
		}
		return Copy == "ABCX";
	}
}
