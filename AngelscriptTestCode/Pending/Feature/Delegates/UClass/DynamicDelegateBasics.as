/**
 * @version v1
 * @summary Dynamic single-cast IsBound, BindUFunction, Execute, and Clear. After BeginPlay, Counter is 3 and DelegateWasCalled is true. Before BeginPlay, Counter is 0 and DelegateWasCalled is false.
 * @topic Feature
 */
/**
 * @version root
 * @summary Dynamic single-cast IsBound, BindUFunction, Execute, and Clear. After BeginPlay, Counter is 3 and DelegateWasCalled is true. Before BeginPlay, Counter is 0 and DelegateWasCalled is false.
 * @topic Baseline
 */
/**
 * A parameterless void unicast used as a dynamic delegate.
 *
 * @Covers Delegates.Dynamic
 * @Inputs none
 * @Return nothing when executed
 */
delegate void FCoverageDynamicSimpleDelegate();

UCLASS()
class ACoverageDynamicDelegateBasicsActor : AActor
{
	UPROPERTY()
	int Counter = 0;

	UPROPERTY()
	bool DelegateWasCalled = false;

	FCoverageDynamicSimpleDelegate OnDynamicEvent;

	/**
	 * Walks IsBound, BindUFunction, Execute, and Clear on the dynamic unicast.
	 *
	 * @Kind WorldStory
	 * @Covers Delegates.Dynamic
	 * @Inputs none
	 * @Return nothing; Counter ends at 3 and the handler sets DelegateWasCalled
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		if (!OnDynamicEvent.IsBound())
		{
			Counter = 1;
		}

		OnDynamicEvent.BindUFunction(this, n"HandleDynamicDelegate");

		if (OnDynamicEvent.IsBound())
		{
			Counter = 2;
		}

		OnDynamicEvent.Execute();

		OnDynamicEvent.Clear();
		if (!OnDynamicEvent.IsBound())
		{
			Counter = 3;
		}
	}

	/**
	 * Records that the dynamic unicast ran.
	 *
	 * @Covers Delegates.Dynamic
	 * @Inputs none
	 * @Return nothing; DelegateWasCalled becomes true
	 */
	UFUNCTION()
	void HandleDynamicDelegate()
	{
		DelegateWasCalled = true;
	}

	/**
	 * Observe that a default-constructed actor handle is null.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Dynamic
	 * @Inputs a local ACoverageDynamicDelegateBasicsActor
	 * @Return true when the handle is null
	 * @Boundary empty default
	 */
	UFUNCTION()
	bool EmptyDefaultIsNull()
	{
		ACoverageDynamicDelegateBasicsActor Actor;
		return Actor == nullptr;
	}

	/**
	 * Observe the pre-BeginPlay Counter.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Dynamic
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
	 * Observe that the handler has not run before BeginPlay.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Dynamic
	 * @Inputs this
	 * @Return true when DelegateWasCalled is false
	 * @Boundary pre-BeginPlay
	 */
	UFUNCTION()
	bool CalledDefaultFalse()
	{
		return DelegateWasCalled == false;
	}
}
/** @end */
