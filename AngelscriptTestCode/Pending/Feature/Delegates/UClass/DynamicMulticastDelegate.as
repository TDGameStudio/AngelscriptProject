/**
 * @version v1
 * @summary Multicast AddUFunction, Broadcast, and Unbind. After BeginPlay, Counter is 212 and Result is "ABCAC". Before BeginPlay, Counter is 0 and Result is empty.
 * @topic Feature
 */
/**
 * @version root
 * @summary Multicast AddUFunction, Broadcast, and Unbind. After BeginPlay, Counter is 212 and Result is "ABCAC". Before BeginPlay, Counter is 0 and Result is empty.
 * @topic Baseline
 */
/**
 * A parameterless multicast event.
 *
 * @Covers Delegates.Multicast
 * @Inputs none
 * @Return nothing when broadcast
 */
event void FCoverageDynamicMulticastEvent();

UCLASS()
class ACoverageDynamicMulticastActor : AActor
{
	UPROPERTY()
	int Counter = 0;

	UPROPERTY()
	FString Result;

	FCoverageDynamicMulticastEvent OnMulticastEvent;

	/**
	 * Adds three listeners, broadcasts, unbinds Listener2, and broadcasts again.
	 *
	 * @Kind WorldStory
	 * @Covers Delegates.Multicast
	 * @Inputs none
	 * @Return nothing; Counter ends at 212 and Result is ABCAC
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		OnMulticastEvent.AddUFunction(this, n"Listener1");
		OnMulticastEvent.AddUFunction(this, n"Listener2");
		OnMulticastEvent.AddUFunction(this, n"Listener3");

		OnMulticastEvent.Broadcast();

		OnMulticastEvent.Unbind(this, n"Listener2");

		OnMulticastEvent.Broadcast();
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
	 * Observe that a default-constructed actor handle is null.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Multicast
	 * @Inputs a local ACoverageDynamicMulticastActor
	 * @Return true when the handle is null
	 * @Boundary empty default
	 */
	UFUNCTION()
	bool EmptyDefaultIsNull()
	{
		ACoverageDynamicMulticastActor Actor;
		return Actor == nullptr;
	}

	/**
	 * Observe the pre-BeginPlay Counter.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Multicast
	 * @Inputs this
	 * @Return 0
	 * @Boundary pre-BeginPlay
	 */
	UFUNCTION()
	int CounterDefault()
	{
		return Counter;
	}

	/**
	 * Observe the pre-BeginPlay Result.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Multicast
	 * @Inputs this
	 * @Return the empty string
	 * @Boundary pre-BeginPlay
	 */
	UFUNCTION()
	FString ResultDefault()
	{
		return Result;
	}
}
/** @end */
