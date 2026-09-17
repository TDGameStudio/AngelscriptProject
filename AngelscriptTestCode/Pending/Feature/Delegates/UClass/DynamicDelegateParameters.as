/**
 * @version v1
 * @summary Dynamic single Execute then multicast Broadcast. After BeginPlay, ReceivedInt is 100 and ReceivedString is "Test". Before BeginPlay, ReceivedInt is 0 and the string is empty.
 * @topic Feature
 */
/**
 * @version root
 * @summary Dynamic single Execute then multicast Broadcast. After BeginPlay, ReceivedInt is 100 and ReceivedString is "Test". Before BeginPlay, ReceivedInt is 0 and the string is empty.
 * @topic Baseline
 */
/**
 * A unicast that takes one int.
 *
 * @Covers Delegates.Parameters
 * @Inputs Value
 * @Return nothing when executed
 */
delegate void FCoverageDynamicIntEvent(int Value);

/**
 * A multicast that takes an int and a string.
 *
 * @Covers Delegates.Parameters
 * @Inputs IntValue and StringValue
 * @Return nothing when broadcast
 */
event void FCoverageDynamicIntStringEvent(int IntValue, FString StringValue);

UCLASS()
class ACoverageDynamicParamsActor : AActor
{
	UPROPERTY()
	int ReceivedInt = 0;

	UPROPERTY()
	FString ReceivedString;

	FCoverageDynamicIntEvent OnIntEvent;
	FCoverageDynamicIntStringEvent OnIntStringEvent;

	/**
	 * Executes the unicast then broadcasts the multicast.
	 *
	 * @Kind WorldStory
	 * @Covers Delegates.Parameters
	 * @Inputs none
	 * @Return nothing; ReceivedInt and ReceivedString record the last payload
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		OnIntEvent.BindUFunction(this, n"HandleIntEvent");
		OnIntEvent.Execute(42);

		OnIntStringEvent.AddUFunction(this, n"HandleIntStringEvent");
		OnIntStringEvent.Broadcast(100, "Test");
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
	void HandleIntEvent(int Value)
	{
		ReceivedInt = Value;
	}

	/**
	 * Stores both Broadcast arguments.
	 *
	 * @Covers Delegates.Parameters
	 * @Param IntValue the integer payload
	 * @Param StringValue the string payload
	 * @Inputs IntValue and StringValue
	 * @Return nothing; ReceivedInt and ReceivedString are written
	 */
	UFUNCTION()
	void HandleIntStringEvent(int IntValue, FString StringValue)
	{
		ReceivedInt = IntValue;
		ReceivedString = StringValue;
	}

	/**
	 * Observe that a default-constructed actor handle is null.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Parameters
	 * @Inputs a local ACoverageDynamicParamsActor
	 * @Return true when the handle is null
	 * @Boundary empty default
	 */
	UFUNCTION()
	bool EmptyDefaultIsNull()
	{
		ACoverageDynamicParamsActor Actor;
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
/** @end */
