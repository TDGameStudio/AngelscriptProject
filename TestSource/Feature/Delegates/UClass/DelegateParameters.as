/**
 * One-param then two-param Execute. After BeginPlay, ReceivedInt is 100 and
 * ReceivedString is "Test". Before BeginPlay, ReceivedInt is 0 and the string
 * is empty.
 *
 * @Theme Feature.Delegates
 * @Subject Delegates.DelegateParameters
 * @Harness UClass
 * @Tag Feature.Delegates.DelegateParameters
 * @Provenance Theme: Feature.Delegates. WorldStory one-param then two-param Execute.
 * @Provenance C++: AngelscriptCoverageDelegateTests.cpp::DelegateParameters
 * @Provenance Oracle after BeginPlay: ReceivedInt==100, ReceivedString=="Test".
 * @Provenance Extra: empty actor is null; pre-BeginPlay 0 / empty string. FixtureIsolated.
 */

/**
 * A unicast that takes one int.
 *
 * @Covers Delegates.Parameters
 * @Inputs Value
 * @Return nothing when executed
 */
delegate void FCoverageIntDelegate(int Value);

/**
 * A unicast that takes an int and a string.
 *
 * @Covers Delegates.Parameters
 * @Inputs IntValue and StringValue
 * @Return nothing when executed
 */
delegate void FCoverageIntStringDelegate(int IntValue, FString StringValue);

UCLASS()
class ACoverageDelegateParamsActor : AActor
{
	UPROPERTY()
	int ReceivedInt = 0;

	UPROPERTY()
	FString ReceivedString;

	FCoverageIntDelegate OnIntDelegate;
	FCoverageIntStringDelegate OnIntStringDelegate;

	/**
	 * Binds both delegates and executes them.
	 *
	 * @Kind WorldStory
	 * @Covers Delegates.Parameters
	 * @Inputs none
	 * @Return nothing; ReceivedInt and ReceivedString record the last Execute
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		OnIntDelegate.BindUFunction(this, n"HandleIntDelegate");
		OnIntDelegate.Execute(42);

		OnIntStringDelegate.BindUFunction(this, n"HandleIntStringDelegate");
		OnIntStringDelegate.Execute(100, "Test");
	}

	/**
	 * Stores Value in ReceivedInt.
	 *
	 * @Covers Delegates.Parameters
	 * @Param Value the Execute argument
	 * @Inputs Value
	 * @Return nothing; ReceivedInt becomes Value
	 */
	UFUNCTION()
	void HandleIntDelegate(int Value)
	{
		ReceivedInt = Value;
	}

	/**
	 * Stores both Execute arguments.
	 *
	 * @Covers Delegates.Parameters
	 * @Param IntValue the integer payload
	 * @Param StringValue the string payload
	 * @Inputs IntValue and StringValue
	 * @Return nothing; ReceivedInt and ReceivedString are written
	 */
	UFUNCTION()
	void HandleIntStringDelegate(int IntValue, FString StringValue)
	{
		ReceivedInt = IntValue;
		ReceivedString = StringValue;
	}

	/**
	 * Observe that a default-constructed actor handle is null.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Parameters
	 * @Inputs a local ACoverageDelegateParamsActor
	 * @Return true when the handle is null
	 * @Boundary empty default
	 */
	UFUNCTION()
	bool EmptyDefaultIsNull()
	{
		ACoverageDelegateParamsActor Actor;
		return Actor == nullptr;
	}

	/**
	 * Observe the pre-BeginPlay ReceivedInt.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Parameters
	 * @Inputs this
	 * @Return 0
	 * @Boundary pre-BeginPlay
	 */
	UFUNCTION()
	int ReceivedIntDefault()
	{
		return ReceivedInt;
	}

	/**
	 * Observe the pre-BeginPlay ReceivedString.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Parameters
	 * @Inputs this
	 * @Return the empty string
	 * @Boundary pre-BeginPlay
	 */
	UFUNCTION()
	FString ReceivedStringDefault()
	{
		return ReceivedString;
	}
}
