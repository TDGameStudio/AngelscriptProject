/**
 * @version v1
 * @summary Multicast AddUFunction; C++ ProcessDelegate after BeginPlay. EventTriggerCount is 0 until HandleDamaged runs. C++ owns the later Broadcast.
 * @topic Feature
 */
/**
 * @version root
 * @summary Multicast AddUFunction; C++ ProcessDelegate after BeginPlay. EventTriggerCount is 0 until HandleDamaged runs. C++ owns the later Broadcast.
 * @topic Baseline
 */
/**
 * A multicast event that reports health and a label.
 *
 * @Covers Delegates.Broadcast
 * @Inputs NewHealth and Label
 * @Return nothing when broadcast
 */
event void FOnDamaged(int32 NewHealth, const FString&in Label);

UCLASS()
class ATestDelegateMulticast : AActor
{
	UPROPERTY()
	FOnDamaged OnDamaged;

	UPROPERTY()
	int EventTriggerCount = 0;

	/**
	 * Binds HandleDamaged.
	 *
	 * @Kind WorldStory
	 * @Covers Delegates.Broadcast
	 * @Inputs none
	 * @Return nothing; OnDamaged becomes bound
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		OnDamaged.AddUFunction(this, n"HandleDamaged");
	}

	/**
	 * Increments EventTriggerCount.
	 *
	 * @Covers Delegates.Broadcast
	 * @Param NewHealth the payload
	 * @Param Label the payload label
	 * @Inputs NewHealth and Label
	 * @Return nothing; EventTriggerCount gains 1
	 */
	UFUNCTION()
	void HandleDamaged(int32 NewHealth, const FString&in Label)
	{
		EventTriggerCount += 1;
	}

	/**
	 * Observe the default EventTriggerCount.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Broadcast
	 * @Inputs this
	 * @Return 0
	 * @Boundary default empty
	 */
	UFUNCTION()
	int DefaultEmpty()
	{
		return EventTriggerCount;
	}

	/**
	 * Observe a zero-health write through the handler.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Broadcast
	 * @Inputs HandleDamaged(0, "")
	 * @Return EventTriggerCount after the zero write
	 * @Boundary zero health
	 */
	UFUNCTION()
	int ZeroHealthWrite()
	{
		HandleDamaged(0, "");
		return EventTriggerCount;
	}

	/**
	 * Observe that writing this leaves Second at 0 and unbound.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Broadcast
	 * @Param Second the other actor, runner-owned when non-null
	 * @Inputs HandleDamaged(33, "Multicast") on this
	 * @Return true when this counted 1 and Second stays 0 unbound
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ATestDelegateMulticast Second)
	{
		if (Second is null)
		{
			throw("BroadcastInvokesScriptHandler setup: required Second is null");
		}
		HandleDamaged(33, "Multicast");
		if (EventTriggerCount != 1)
		{
			return false;
		}
		if (Second.EventTriggerCount != 0)
		{
			return false;
		}
		return !Second.OnDamaged.IsBound();
	}
}
/** @end */
