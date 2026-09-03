/**
 * A BlueprintEvent implementation plus a script caller. ComputeEventValue(25)
 * is 42 and LastInputValue 25. CallEventFromScript(5) is 22.
 * ComputeEventValue(0) is 17. Default EventCallCount is 0, and a second
 * instance stays 0.
 *
 * @Theme Definitions.UFunction
 * @Subject UFunction.BlueprintEventReflectsAndInvokesImplementation
 * @Harness UClass
 * @Tag Definitions.UFunction.BlueprintEventReflectsAndInvokesImplementation
 * @Provenance Theme: Definitions.UFunction. WorldStory: BlueprintEvent implementation plus script caller.
 * @Provenance C++: AngelscriptCoverageUFunctionTests.cpp::BlueprintEventReflectsAndInvokesImplementation
 * @Provenance Oracle: ComputeEventValue(25)==42 and LastInputValue 25; CallEventFromScript(5)==22.
 * @Provenance Extra: ComputeEventValue(0)==17; default EventCallCount 0; second instance stays 0.
 * @Provenance FixtureIsolated. Runner owns World teardown.
 */

UCLASS()
class ACoverageUFunctionEventActor : AActor
{
	UPROPERTY()
	int EventCallCount = 0;

	UPROPERTY()
	int LastInputValue = 0;

	/**
	 * BlueprintEvent that records Value and returns Value + 17.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Param Value Event input
	 * @Inputs Value
	 * @Return Value + 17 after incrementing EventCallCount
	 */
	UFUNCTION(BlueprintEvent, Category="Coverage|Events", meta=(DisplayName="Compute Event Value"))
	int ComputeEventValue(int Value)
	{
		EventCallCount += 1;
		LastInputValue = Value;
		return Value + 17;
	}

	/**
	 * Script caller that forwards to ComputeEventValue.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Param Value Event input
	 * @Inputs Value
	 * @Return ComputeEventValue(Value)
	 */
	UFUNCTION()
	int CallEventFromScript(int Value)
	{
		return ComputeEventValue(Value);
	}

	/**
	 * Observe ComputeEventValue(25).
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs ComputeEventValue(25)
	 * @Return 42
	 */
	UFUNCTION()
	int DirectTwentyFive()
	{
		return ComputeEventValue(25);
	}

	/**
	 * Observe CallEventFromScript(5) after ComputeEventValue(25).
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs ComputeEventValue(25) then CallEventFromScript(5)
	 * @Return 22
	 */
	UFUNCTION()
	int ScriptCallerFive()
	{
		ComputeEventValue(25);
		return CallEventFromScript(5);
	}

	/**
	 * Observe EventCallCount after both the direct and script calls.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs ComputeEventValue(25) then CallEventFromScript(5)
	 * @Return 2
	 */
	UFUNCTION()
	int CallCountAfterBoth()
	{
		ComputeEventValue(25);
		CallEventFromScript(5);
		return EventCallCount;
	}

	/**
	 * Observe ComputeEventValue(0).
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs ComputeEventValue(0)
	 * @Return 17
	 * @Boundary zero
	 */
	UFUNCTION()
	int ZeroBoundary()
	{
		return ComputeEventValue(0);
	}

	/**
	 * Observe the default EventCallCount of 0.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs a freshly constructed actor
	 * @Return 0
	 * @Boundary default count
	 */
	UFUNCTION()
	int DefaultCallCount()
	{
		return EventCallCount;
	}

	/**
	 * Observe that dispatching this instance leaves another at 0.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Param Other Second actor that must stay at 0
	 * @Inputs ComputeEventValue(25) on this compared against Other
	 * @Return true when this recorded 25 and Other stays 0
	 * @Boundary instance independence
	 */
	UFUNCTION()
	bool EventIsIndependentAcrossInstances(ACoverageUFunctionEventActor Other)
	{
		ComputeEventValue(25);
		if (EventCallCount != 1)
		{
			return false;
		}
		if (LastInputValue != 25)
		{
			return false;
		}
		return Other.EventCallCount == 0;
	}
}
