/**
 * BlueprintEvent callable, pure, and out combinations. Direct OutEvent(25,
 * "Direct") returns 36 and writes 31. DispatchEventCombinationMatrix returns
 * 131. After dispatch-only, each call count is 1. PureConstEvent(0) is 20.
 * Default call counts are 0. OutEvent(0,"") writes 0 and returns 5.
 *
 * @Theme Definitions.UFunction
 * @Subject UFunction.BlueprintEventCallablePureAndOutParameterMatrix
 * @Harness UClass
 * @Tag Definitions.UFunction.BlueprintEventCallablePureAndOutParameterMatrix
 * @Provenance Theme: Definitions.UFunction. WorldStory: BlueprintEvent callable/pure/out combination.
 * @Provenance C++: AngelscriptCoverageUFunctionTests.cpp::BlueprintEventCallablePureAndOutParameterMatrix
 * @Provenance Direct OutEvent(25,"Direct") returns 36 writes 31; DispatchEventCombinationMatrix returns 131.
 * @Provenance After dispatch-only: PlainEventCalls 1, CallableEventCalls 1, OutEventCalls 1.
 * @Provenance Extra: PureConstEvent(0)==20; default call counts 0; OutEvent(0,"") writes 0 returns 5.
 * @Provenance FixtureIsolated. Runner owns World teardown.
 */

UCLASS()
class ACoverageUFunctionEventCombinationActor : AActor
{
	UPROPERTY()
	int PlainEventCalls = 0;

	UPROPERTY()
	int CallableEventCalls = 0;

	UPROPERTY()
	int OutEventCalls = 0;

	/**
	 * Plain BlueprintEvent that increments PlainEventCalls.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs none
	 * @Return void
	 */
	UFUNCTION(BlueprintEvent, Category="Coverage|EventCombos")
	void PlainEvent()
	{
		PlainEventCalls += 1;
	}

	/**
	 * Callable BlueprintEvent that returns Value + 10.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Param Value Event input
	 * @Inputs Value
	 * @Return Value + 10
	 */
	UFUNCTION(BlueprintEvent, BlueprintCallable, Category="Coverage|EventCombos", meta=(DisplayName="Callable Event", Keywords="event callable"))
	int CallableEvent(int Value)
	{
		CallableEventCalls += 1;
		return Value + 10;
	}

	/**
	 * Pure const BlueprintEvent that returns Value + 20.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Param Value Event input
	 * @Inputs Value
	 * @Return Value + 20
	 */
	UFUNCTION(BlueprintEvent, BlueprintPure, Category="Coverage|EventCombos", meta=(CompactNodeTitle="PEV"))
	int PureConstEvent(int Value) const
	{
		return Value + 20;
	}

	/**
	 * Callable BlueprintEvent that writes Value + Label.Len() and returns that plus 5.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Param Value Event input
	 * @Param Label AdvancedDisplay label
	 * @Param OutValue Destination received as int&out
	 * @Inputs Value, Label, OutValue
	 * @Return OutValue + 5
	 */
	UFUNCTION(BlueprintEvent, BlueprintCallable, Category="Coverage|EventCombos", meta=(AdvancedDisplay="Label"))
	int OutEvent(int Value, FString Label, int&out OutValue)
	{
		OutEventCalls += 1;
		OutValue = Value + Label.Len();
		return OutValue + 5;
	}

	/**
	 * Dispatch the four event forms and score the results.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs PlainEvent, CallableEvent(12), PureConstEvent(10), OutEvent(30, "Seven!!")
	 * @Return the summed score including OutValue
	 */
	UFUNCTION(BlueprintCallable, Category="Coverage|EventCombos")
	int DispatchEventCombinationMatrix()
	{
		PlainEvent();
		int Score = CallableEvent(12);
		Score += PureConstEvent(10);
		int OutValue = 0;
		Score += OutEvent(30, "Seven!!", OutValue);
		return Score + OutValue;
	}

	/**
	 * Observe OutEvent(25, "Direct").
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Inputs OutEvent(25, "Direct")
	 * @Return 36, or -1 if OutValue is not 31
	 */
	UFUNCTION()
	int DirectOutEvent()
	{
		int OutValue = 0;
		int Result = OutEvent(25, "Direct", OutValue);
		if (OutValue != 31)
		{
			return -1;
		}
		return Result;
	}

	/**
	 * Observe DispatchEventCombinationMatrix.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs DispatchEventCombinationMatrix()
	 * @Return 131
	 */
	UFUNCTION()
	int DispatchScore()
	{
		return DispatchEventCombinationMatrix();
	}

	/**
	 * Observe call counts after a dispatch-only run.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs DispatchEventCombinationMatrix()
	 * @Return true when each call count is 1
	 */
	UFUNCTION()
	bool DispatchCallCounts()
	{
		DispatchEventCombinationMatrix();
		if (PlainEventCalls != 1)
		{
			return false;
		}
		if (CallableEventCalls != 1)
		{
			return false;
		}
		return OutEventCalls == 1;
	}

	/**
	 * Observe PureConstEvent(0).
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs PureConstEvent(0)
	 * @Return 20
	 * @Boundary zero
	 */
	UFUNCTION()
	int PureZeroBoundary()
	{
		return PureConstEvent(0);
	}

	/**
	 * Observe the default call-count sum of 0.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs a freshly constructed actor
	 * @Return 0
	 * @Boundary default counts
	 */
	UFUNCTION()
	int DefaultCallCounts()
	{
		return PlainEventCalls + CallableEventCalls + OutEventCalls;
	}

	/**
	 * Observe OutEvent(0, "") writing 0 and returning 5.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Inputs OutEvent(0, "")
	 * @Return 5, or -1 if OutValue is not 0
	 * @Boundary empty label
	 */
	UFUNCTION()
	int EmptyOutBoundary()
	{
		int OutValue = -1;
		int Result = OutEvent(0, "", OutValue);
		if (OutValue != 0)
		{
			return -1;
		}
		return Result;
	}
}
