/**
 * Bool-return and int-return unicast delegates. After BeginPlay, BoolResult is
 * true and IntResult is 100 (50*2). Before BeginPlay, BoolResult is false and
 * IntResult is 0.
 *
 * @Theme Feature.Delegates
 * @Subject Delegates.DelegateReturnValue
 * @Harness UClass
 * @Tag Feature.Delegates.DelegateReturnValue
 * @Provenance Theme: Feature.Delegates. WorldStory bool return and int return+param delegates.
 * @Provenance C++: AngelscriptCoverageDelegateTests.cpp::DelegateReturnValue
 * @Provenance Oracle after BeginPlay: BoolResult==true, IntResult==100 (50*2).
 * @Provenance Extra: empty actor is null; pre-BeginPlay false / 0. FixtureIsolated.
 */

/**
 * A unicast that returns bool.
 *
 * @Covers Delegates.ReturnValue
 * @Inputs none
 * @Return the bound handler's bool
 */
delegate bool FCoverageBoolRetDelegate();

/**
 * A unicast that returns int from an int argument.
 *
 * @Covers Delegates.ReturnValue
 * @Inputs Value
 * @Return the bound handler's int
 */
delegate int FCoverageIntRetIntDelegate(int Value);

UCLASS()
class ACoverageDelegateRetValActor : AActor
{
	UPROPERTY()
	bool BoolResult = false;

	UPROPERTY()
	int IntResult = 0;

	FCoverageBoolRetDelegate OnBoolRetDelegate;
	FCoverageIntRetIntDelegate OnIntRetIntDelegate;

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
		OnBoolRetDelegate.BindUFunction(this, n"HandleBoolRetDelegate");
		BoolResult = OnBoolRetDelegate.Execute();

		OnIntRetIntDelegate.BindUFunction(this, n"HandleIntRetIntDelegate");
		IntResult = OnIntRetIntDelegate.Execute(50);
	}

	/**
	 * Returns true.
	 *
	 * @Covers Delegates.ReturnValue
	 * @Inputs none
	 * @Return true
	 */
	UFUNCTION()
	bool HandleBoolRetDelegate()
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
	int HandleIntRetIntDelegate(int Value)
	{
		return Value * 2;
	}

	/**
	 * Observe that a default-constructed actor handle is null.
	 *
	 * @Kind Observe
	 * @Covers Delegates.ReturnValue
	 * @Inputs a local ACoverageDelegateRetValActor
	 * @Return true when the handle is null
	 * @Boundary empty default
	 */
	UFUNCTION()
	bool EmptyDefaultIsNull()
	{
		ACoverageDelegateRetValActor Actor;
		return Actor == nullptr;
	}

	/**
	 * Observe the pre-BeginPlay BoolResult.
	 *
	 * @Kind Observe
	 * @Covers Delegates.ReturnValue
	 * @Inputs this
	 * @Return false
	 * @Boundary pre-BeginPlay
	 */
	UFUNCTION()
	bool BoolDefaultFalse()
	{
		return BoolResult;
	}

	/**
	 * Observe the pre-BeginPlay IntResult.
	 *
	 * @Kind Observe
	 * @Covers Delegates.ReturnValue
	 * @Inputs this
	 * @Return 0
	 * @Boundary pre-BeginPlay
	 */
	UFUNCTION()
	int IntDefault()
	{
		return IntResult;
	}
}
