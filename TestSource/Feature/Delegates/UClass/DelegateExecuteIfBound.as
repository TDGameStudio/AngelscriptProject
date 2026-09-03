/**
 * ExecuteIfBound unbound, bound, then cleared. After BeginPlay, Counter is 3.
 * Before BeginPlay, Counter is 0.
 *
 * @Theme Feature.Delegates
 * @Subject Delegates.DelegateExecuteIfBound
 * @Harness UClass
 * @Tag Feature.Delegates.DelegateExecuteIfBound
 * @Provenance Theme: Feature.Delegates. WorldStory ExecuteIfBound unbound / bound / cleared.
 * @Provenance C++: AngelscriptCoverageDelegateTests.cpp::DelegateExecuteIfBound
 * @Provenance Oracle after BeginPlay: Counter==3. Extra: empty actor is null; pre-BeginPlay Counter==0.
 * @Provenance FixtureIsolated.
 */

/**
 * A parameterless void unicast.
 *
 * @Covers Delegates.ExecuteIfBound
 * @Inputs none
 * @Return nothing when executed
 */
delegate void FCoverageExecuteIfBoundDelegate();

UCLASS()
class ACoverageDelegateExecuteIfBoundActor : AActor
{
	UPROPERTY()
	int Counter = 0;

	FCoverageExecuteIfBoundDelegate OnDelegate;

	/**
	 * Walks ExecuteIfBound unbound, bound, and cleared.
	 *
	 * @Kind WorldStory
	 * @Covers Delegates.ExecuteIfBound
	 * @Inputs none
	 * @Return nothing; Counter ends at 3
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		OnDelegate.ExecuteIfBound();
		Counter = 1;

		OnDelegate.BindUFunction(this, n"HandleDelegate");
		OnDelegate.ExecuteIfBound();

		OnDelegate.Clear();
		OnDelegate.ExecuteIfBound();
		Counter = 3;
	}

	/**
	 * Sets Counter to 2 when the bound ExecuteIfBound runs.
	 *
	 * @Covers Delegates.ExecuteIfBound
	 * @Inputs none
	 * @Return nothing; Counter becomes 2
	 */
	UFUNCTION()
	void HandleDelegate()
	{
		Counter = 2;
	}

	/**
	 * Observe that a default-constructed actor handle is null.
	 *
	 * @Kind Observe
	 * @Covers Delegates.ExecuteIfBound
	 * @Inputs a local ACoverageDelegateExecuteIfBoundActor
	 * @Return true when the handle is null
	 * @Boundary empty default
	 */
	UFUNCTION()
	bool EmptyDefaultIsNull()
	{
		ACoverageDelegateExecuteIfBoundActor Actor;
		return Actor == nullptr;
	}

	/**
	 * Observe the pre-BeginPlay Counter.
	 *
	 * @Kind Observe
	 * @Covers Delegates.ExecuteIfBound
	 * @Inputs this
	 * @Return 0
	 * @Boundary pre-BeginPlay
	 */
	UFUNCTION()
	int CounterDefault()
	{
		return Counter;
	}
}
