/**
 * @version v1
 * @summary IsBound, BindUFunction, Execute, and Clear on a unicast. After BeginPlay, Counter is 3 and DelegateWasCalled is true. Before BeginPlay, Counter is 0 and DelegateWasCalled is false.
 * @topic Feature
 */
/**
 * @version root
 * @summary IsBound, BindUFunction, Execute, and Clear on a unicast. After BeginPlay, Counter is 3 and DelegateWasCalled is true. Before BeginPlay, Counter is 0 and DelegateWasCalled is false.
 * @topic Baseline
 */
/**
 * A parameterless void unicast.
 *
 * @Covers Delegates.IsBound
 * @Inputs none
 * @Return nothing when executed
 */
delegate void FCoverageSimpleDelegate();

UCLASS()
class ACoverageDelegateBasicsActor : AActor
{
	UPROPERTY()
	int Counter = 0;

	UPROPERTY()
	bool DelegateWasCalled = false;

	FCoverageSimpleDelegate OnSimpleDelegate;

	/**
	 * Walks IsBound, BindUFunction, Execute, and Clear.
	 *
	 * @Kind WorldStory
	 * @Covers Delegates.IsBound
	 * @Inputs none
	 * @Return nothing; Counter ends at 3 and the handler sets DelegateWasCalled
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		if (!OnSimpleDelegate.IsBound())
		{
			Counter = 1;
		}

		OnSimpleDelegate.BindUFunction(this, n"HandleSimpleDelegate");

		if (OnSimpleDelegate.IsBound())
		{
			Counter = 2;
		}

		OnSimpleDelegate.Execute();

		OnSimpleDelegate.Clear();
		if (!OnSimpleDelegate.IsBound())
		{
			Counter = 3;
		}
	}

	/**
	 * Records that the unicast ran.
	 *
	 * @Covers Delegates.Execute
	 * @Inputs none
	 * @Return nothing; DelegateWasCalled becomes true
	 */
	UFUNCTION()
	void HandleSimpleDelegate()
	{
		DelegateWasCalled = true;
	}

	/**
	 * Observe that a default-constructed actor handle is null.
	 *
	 * @Kind Observe
	 * @Covers Delegates.IsBound
	 * @Inputs a local ACoverageDelegateBasicsActor
	 * @Return true when the handle is null
	 * @Boundary empty default
	 */
	UFUNCTION()
	bool EmptyDefaultIsNull()
	{
		ACoverageDelegateBasicsActor Actor;
		return Actor == nullptr;
	}

	/**
	 * Observe the pre-BeginPlay Counter.
	 *
	 * @Kind Observe
	 * @Covers Delegates.IsBound
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
	 * @Covers Delegates.Execute
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
