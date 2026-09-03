/**
 * BlueprintEvent wrappers execute the script implementation. RunEvents is
 * ComputeEvent(37, "Event") plus CallableEvent(2), which is 48. LastInput becomes
 * 37 and LastLabel becomes "Event".
 *
 * @Theme Definitions.Meta
 * @Subject Meta.EventBlueprintEventMetadataAndExecution
 * @Harness UClass
 * @Tag Definitions.Meta.EventBlueprintEventMetadataAndExecution
 * @Provenance Theme: Definitions.Meta. Positive: BlueprintEvent wrappers execute the script implementation.
 * @Provenance C++: AngelscriptCoverageEventTests.cpp::EventBlueprintEventMetadataAndExecution
 * @Provenance Oracle: RunEvents() == 48; LastInput == 37; LastLabel == "Event".
 * @Provenance Extra: ComputeEvent(0, "") == 5; CallableEvent(0) == 0; copy independence. DefaultSafe.
 */

UCLASS()
class UCoverageBlueprintEventObject : UObject
{
	UPROPERTY()
	int LastInput = 0;

	UPROPERTY()
	FString LastLabel;

	/**
	 * Record the input and return Value plus 5.
	 *
	 * @Kind Observe
	 * @Covers Meta.EventBlueprintEventMetadataAndExecution
	 * @Inputs a value and a label
	 * @Return Value + 5
	 * @Param Value the recorded input
	 * @Param Label the recorded label
	 */
	UFUNCTION(BlueprintEvent)
	int ComputeEvent(int Value, const FString&in Label)
	{
		LastInput = Value;
		LastLabel = Label;
		return Value + 5;
	}

	/**
	 * Return Value times 3.
	 *
	 * @Kind Observe
	 * @Covers Meta.EventBlueprintEventMetadataAndExecution
	 * @Inputs a value
	 * @Return Value * 3
	 * @Param Value the input
	 */
	UFUNCTION(BlueprintCallable, BlueprintEvent)
	int CallableEvent(int Value)
	{
		return Value * 3;
	}

	/**
	 * Run ComputeEvent(37, "Event") plus CallableEvent(2).
	 *
	 * @Kind Observe
	 * @Covers Meta.EventBlueprintEventMetadataAndExecution
	 * @Inputs none
	 * @Return 48
	 */
	UFUNCTION()
	int RunEvents()
	{
		return ComputeEvent(37, "Event") + CallableEvent(2);
	}

	/**
	 * Observe the nominal RunEvents result.
	 *
	 * @Kind Observe
	 * @Covers Meta.EventBlueprintEventMetadataAndExecution
	 * @Inputs none
	 * @Return 48
	 */
	UFUNCTION()
	int RunEventsNominal()
	{
		return RunEvents();
	}

	/**
	 * Observe LastInput after RunEvents.
	 *
	 * @Kind Observe
	 * @Covers Meta.EventBlueprintEventMetadataAndExecution
	 * @Inputs none
	 * @Return 37
	 */
	UFUNCTION()
	int LastInputAfterRun()
	{
		RunEvents();
		return LastInput;
	}

	/**
	 * Observe LastLabel after RunEvents.
	 *
	 * @Kind Observe
	 * @Covers Meta.EventBlueprintEventMetadataAndExecution
	 * @Inputs none
	 * @Return "Event"
	 */
	UFUNCTION()
	FString LastLabelAfterRun()
	{
		RunEvents();
		return LastLabel;
	}

	/**
	 * Observe the zero-input boundary of both events.
	 *
	 * @Kind Observe
	 * @Covers Meta.EventBlueprintEventMetadataAndExecution
	 * @Inputs none
	 * @Return 5
	 * @Boundary zero input and empty label
	 */
	UFUNCTION()
	int ZeroBoundary()
	{
		return ComputeEvent(0, "") + CallableEvent(0);
	}

	/**
	 * Observe that running this instance leaves another instance at the defaults.
	 *
	 * @Kind Observe
	 * @Covers Meta.EventBlueprintEventMetadataAndExecution
	 * @Inputs a second object
	 * @Return true when this LastInput is 37 and the other is still 0 with an empty label
	 * @Param Second the other object, expected to keep defaults
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(UCoverageBlueprintEventObject Second)
	{
		if (Second is null)
		{
			throw("EventBlueprintEventMetadataAndExecution setup: required Second is null");
		}
		RunEvents();
		if (LastInput != 37)
		{
			return false;
		}
		if (Second.LastInput != 0)
		{
			return false;
		}
		return Second.LastLabel.Len() == 0;
	}
}
