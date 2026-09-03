/**
 * BindUFunction replaces the previous handler. After BeginPlay, Result is 2.
 * Before BeginPlay, Result is 0.
 *
 * @Theme Feature.Delegates
 * @Subject Delegates.DelegateRebinding
 * @Harness UClass
 * @Tag Feature.Delegates.DelegateRebinding
 * @Provenance Theme: Feature.Delegates. WorldStory BindUFunction replaces the previous handler.
 * @Provenance C++: AngelscriptCoverageDelegateTests.cpp::DelegateRebinding
 * @Provenance Oracle after BeginPlay: Result==2. Extra: empty actor is null; pre-BeginPlay Result==0.
 * @Provenance FixtureIsolated.
 */

/**
 * A parameterless void unicast.
 *
 * @Covers Delegates.BindUFunction
 * @Inputs none
 * @Return nothing when executed
 */
delegate void FCoverageRebindingDelegate();

UCLASS()
class ACoverageDelegateRebindingActor : AActor
{
	UPROPERTY()
	int Result = 0;

	FCoverageRebindingDelegate OnDelegate;

	/**
	 * Binds Handler1, executes, then rebinds Handler2 and executes again.
	 *
	 * @Kind WorldStory
	 * @Covers Delegates.BindUFunction
	 * @Inputs none
	 * @Return nothing; Result ends at 2
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		OnDelegate.BindUFunction(this, n"Handler1");
		OnDelegate.Execute();

		OnDelegate.BindUFunction(this, n"Handler2");
		OnDelegate.Execute();
	}

	/**
	 * The first handler.
	 *
	 * @Covers Delegates.Execute
	 * @Inputs none
	 * @Return nothing; Result becomes 1
	 */
	UFUNCTION()
	void Handler1()
	{
		Result = 1;
	}

	/**
	 * The replacement handler.
	 *
	 * @Covers Delegates.Execute
	 * @Inputs none
	 * @Return nothing; Result becomes 2
	 */
	UFUNCTION()
	void Handler2()
	{
		Result = 2;
	}

	/**
	 * Observe that a default-constructed actor handle is null.
	 *
	 * @Kind Observe
	 * @Covers Delegates.BindUFunction
	 * @Inputs a local ACoverageDelegateRebindingActor
	 * @Return true when the handle is null
	 * @Boundary empty default
	 */
	UFUNCTION()
	bool EmptyDefaultIsNull()
	{
		ACoverageDelegateRebindingActor Actor;
		return Actor == nullptr;
	}

	/**
	 * Observe the pre-BeginPlay Result.
	 *
	 * @Kind Observe
	 * @Covers Delegates.BindUFunction
	 * @Inputs this
	 * @Return 0
	 * @Boundary pre-BeginPlay
	 */
	UFUNCTION()
	int ResultDefault()
	{
		return Result;
	}
}
