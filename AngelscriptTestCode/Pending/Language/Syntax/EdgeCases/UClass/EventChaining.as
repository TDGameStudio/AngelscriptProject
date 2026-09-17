/**
 * @version v1
 * @summary Event chaining through nested broadcasts: the first handler broadcasts the second event, whose handler broadcasts the third. The ordering recorded in the chain proves the nesting unwinds depth-first.
 * @topic Language
 */
/**
 * @version root
 * @summary Event chaining through nested broadcasts: the first handler broadcasts the second event, whose handler broadcasts the third. The ordering recorded in the chain proves the nesting unwinds depth-first.
 * @topic Baseline
 */
/**
 * The event type shared by all three links of the chain.
 *
 * @Covers Syntax.EdgeCases
 * @Inputs none
 * @Return nothing when broadcast
 */
event void FCoverageChainEvent();

UCLASS()
class ACoverageEventChainingActor : AActor
{
	UPROPERTY()
	int Counter = 0;

	UPROPERTY()
	FString EventChain;

	FCoverageChainEvent OnFirstEvent;
	FCoverageChainEvent OnSecondEvent;
	FCoverageChainEvent OnThirdEvent;

	/**
	 * Binds the three handlers and triggers the chain.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing; the handlers record the chain
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		OnFirstEvent.AddUFunction(this, n"HandleFirstEvent");
		OnSecondEvent.AddUFunction(this, n"HandleSecondEvent");
		OnThirdEvent.AddUFunction(this, n"HandleThirdEvent");

		OnFirstEvent.Broadcast();
	}

	/**
	 * The first link of the chain, broadcasting the second event.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing; the counter gains 1 and the second event fires
	 */
	UFUNCTION()
	void HandleFirstEvent()
	{
		Counter += 1;
		EventChain += "First;";
		OnSecondEvent.Broadcast();
	}

	/**
	 * The second link of the chain, broadcasting the third event.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing; the counter gains 10 and the third event fires
	 */
	UFUNCTION()
	void HandleSecondEvent()
	{
		Counter += 10;
		EventChain += "Second;";
		OnThirdEvent.Broadcast();
	}

	/**
	 * The final link of the chain.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing; the counter gains 100
	 */
	UFUNCTION()
	void HandleThirdEvent()
	{
		Counter += 100;
		EventChain += "Third;";
	}

	/**
	 * Observe that a locally constructed actor has recorded nothing.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return true when the counter is 0 and the chain is empty
	 * @Boundary default construction
	 */
	UFUNCTION()
	bool EventChainDefaultsToEmpty()
	{
		if (Counter != 0)
		{
			return false;
		}

		return EventChain.Len() == 0;
	}

	/**
	 * Observe the chain after BeginPlay triggers the first event.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs BeginPlay() then both counters
	 * @Return true when the counter is 111 and the chain records all three links
	 */
	UFUNCTION()
	bool EventChainTraversesAllLinks()
	{
		BeginPlay();

		if (Counter != 111)
		{
			return false;
		}

		return EventChain == "First;Second;Third;";
	}
}
/** @end */
