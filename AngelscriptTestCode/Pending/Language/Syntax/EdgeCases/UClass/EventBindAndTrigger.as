/**
 * @version v1
 * @summary Two script events bound through AddUFunction and broadcast during BeginPlay. The parameterless event appends to the log, and the data event contributes its payload to the count.
 * @topic Language
 */
/**
 * @version root
 * @summary Two script events bound through AddUFunction and broadcast during BeginPlay. The parameterless event appends to the log, and the data event contributes its payload to the count.
 * @topic Baseline
 */
/**
 * A parameterless script event.
 *
 * @Covers Syntax.EdgeCases
 * @Inputs none
 * @Return nothing when broadcast
 */
event void FCoverageCustomEvent();

/**
 * A script event carrying a numeric and a string payload.
 *
 * @Covers Syntax.EdgeCases
 * @Inputs the payload Value and Data
 * @Return nothing when broadcast
 */
event void FCoverageDataChangedEvent(int Value, FString Data);

UCLASS()
class ACoverageEventBindTriggerActor : AActor
{
	UPROPERTY()
	int EventCount = 0;

	UPROPERTY()
	FString EventLog;

	FCoverageCustomEvent OnCustomEvent;
	FCoverageDataChangedEvent OnDataChanged;

	/**
	 * Binds both handlers and broadcasts both events.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing; the handlers record the broadcasts
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		OnCustomEvent.AddUFunction(this, n"HandleCustomEvent");
		OnDataChanged.AddUFunction(this, n"HandleDataChanged");

		OnCustomEvent.Broadcast();
		OnDataChanged.Broadcast(42, "TestData");
	}

	/**
	 * Records the parameterless broadcast.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing; the count gains 1 and the log gains a marker
	 */
	UFUNCTION()
	void HandleCustomEvent()
	{
		EventCount++;
		EventLog += "Custom;";
	}

	/**
	 * Records the data broadcast.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the payload Value and Data
	 * @Return nothing; the count gains Value and the log gains Data
	 * @Param Value the numeric payload
	 * @Param Data the string payload
	 */
	UFUNCTION()
	void HandleDataChanged(int Value, FString Data)
	{
		EventCount += Value;
		EventLog += Data + ";";
	}

	/**
	 * Observe that a locally constructed actor has recorded nothing.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return true when the count is 0 and the log is empty
	 * @Boundary default construction
	 */
	UFUNCTION()
	bool EventBindCountersDefaultToZero()
	{
		if (EventCount != 0)
		{
			return false;
		}

		return EventLog.Len() == 0;
	}

	/**
	 * Observe the state after BeginPlay broadcasts both events.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs BeginPlay() then both counters
	 * @Return true when the count is 43 and the log is "Custom;TestData;"
	 */
	UFUNCTION()
	bool EventBindBroadcastsReachHandlers()
	{
		BeginPlay();

		if (EventCount != 43)
		{
			return false;
		}

		return EventLog == "Custom;TestData;";
	}
}
/** @end */
