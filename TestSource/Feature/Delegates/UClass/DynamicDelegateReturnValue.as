/**
 * Single-cast dynamic delegates return values. After BeginPlay, BoolResult is
 * true and IntResult is 100. Before BeginPlay, BoolResult is false and
 * IntResult is 0.
 *
 * @Theme Feature.Delegates
 * @Subject Delegates.DynamicDelegateReturnValue
 * @Harness UClass
 * @Tag Feature.Delegates.DynamicDelegateReturnValue
 * @Provenance Theme: Feature.Delegates. WorldStory: single-cast dynamic delegates return values.
 * @Provenance C++: AngelscriptCoverageDynamicDelegateTests.cpp::DynamicDelegateReturnValue
 * @Provenance Spawn + BeginPlay oracle: BoolResult==true, IntResult==100 (Execute(50) doubles).
 * @Provenance Extra: defaults false/0; unbound Execute is not invoked here. Keep BoolResult, IntResult.
 * @Provenance FixtureIsolated.
 */

/**
 * A unicast that returns bool.
 *
 * @Covers Delegates.ReturnValue
 * @Inputs none
 * @Return the bound handler's bool
 */
delegate bool FCoverageDynamicBoolRetEvent();

/**
 * A unicast that returns int from an int argument.
 *
 * @Covers Delegates.ReturnValue
 * @Inputs Value
 * @Return the bound handler's int
 */
delegate int FCoverageDynamicIntRetIntEvent(int Value);

UCLASS()
class ACoverageDynamicRetValActor : AActor
{
	UPROPERTY()
	bool BoolResult = false;

	UPROPERTY()
	int IntResult = 0;

	FCoverageDynamicBoolRetEvent OnBoolRetEvent;
	FCoverageDynamicIntRetIntEvent OnIntRetIntEvent;

	/**
	 * Binds both return delegates and stores Execute results.
	 *
	 * @Kind WorldStory
	 * @Covers Delegates.ReturnValue
	 * @Inputs none
	 * @Return nothing; BoolResult and IntResult record the Execute values
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		OnBoolRetEvent.BindUFunction(this, n"HandleBoolRetEvent");
		BoolResult = OnBoolRetEvent.Execute();

		OnIntRetIntEvent.BindUFunction(this, n"HandleIntRetIntEvent");
		IntResult = OnIntRetIntEvent.Execute(50);
	}

	/**
	 * Returns true.
	 *
	 * @Covers Delegates.ReturnValue
	 * @Inputs none
	 * @Return true
	 */
	UFUNCTION()
	bool HandleBoolRetEvent()
	{
		return true;
	}

	/**
	 * Returns Value * 2.
	 *
	 * @Covers Delegates.ReturnValue
	 * @Param Value the Execute argument
	 * @Inputs Value
	 * @Return Value * 2
	 */
	UFUNCTION()
	int HandleIntRetIntEvent(int Value)
	{
		return Value * 2;
	}

	/**
	 * Observe the pre-BeginPlay BoolResult.
	 *
	 * @Kind Observe
	 * @Covers Delegates.ReturnValue
	 * @Inputs this
	 * @Return true when BoolResult is false
	 * @Boundary default false
	 */
	UFUNCTION()
	bool BoolResultDefaultFalse()
	{
		return !BoolResult;
	}

	/**
	 * Observe the pre-BeginPlay IntResult.
	 *
	 * @Kind Observe
	 * @Covers Delegates.ReturnValue
	 * @Inputs this
	 * @Return 0
	 * @Boundary default zero
	 */
	UFUNCTION()
	int IntResultDefaultZero()
	{
		return IntResult;
	}

	/**
	 * Observe the zero-boundary doubling.
	 *
	 * @Kind Observe
	 * @Covers Delegates.ReturnValue
	 * @Inputs 0 * 2
	 * @Return 0
	 * @Boundary zero
	 */
	UFUNCTION()
	int IntReturnZeroBoundary()
	{
		return 0 * 2;
	}
}
