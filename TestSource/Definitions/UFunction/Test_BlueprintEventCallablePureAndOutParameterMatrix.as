// Theme: Definitions.UFunction. WorldStory: BlueprintEvent callable/pure/out combination.
// C++: AngelscriptCoverageUFunctionTests.cpp::BlueprintEventCallablePureAndOutParameterMatrix
// Direct OutEvent(25,"Direct") returns 36 writes 31; DispatchEventCombinationMatrix returns 131.
// After dispatch-only: PlainEventCalls 1, CallableEventCalls 1, OutEventCalls 1.
// Extra: PureConstEvent(0)==20; default call counts 0; OutEvent(0,"") writes 0 returns 5.
// FixtureIsolated. Runner owns World teardown.

UCLASS()
class ACoverageUFunctionEventCombinationActor : AActor
{
	UPROPERTY()
	int PlainEventCalls = 0;

	UPROPERTY()
	int CallableEventCalls = 0;

	UPROPERTY()
	int OutEventCalls = 0;

	UFUNCTION(BlueprintEvent, Category="Coverage|EventCombos")
	void PlainEvent()
	{
		PlainEventCalls += 1;
	}

	UFUNCTION(BlueprintEvent, BlueprintCallable, Category="Coverage|EventCombos", meta=(DisplayName="Callable Event", Keywords="event callable"))
	int CallableEvent(int Value)
	{
		CallableEventCalls += 1;
		return Value + 10;
	}

	UFUNCTION(BlueprintEvent, BlueprintPure, Category="Coverage|EventCombos", meta=(CompactNodeTitle="PEV"))
	int PureConstEvent(int Value) const
	{
		return Value + 20;
	}

	UFUNCTION(BlueprintEvent, BlueprintCallable, Category="Coverage|EventCombos", meta=(AdvancedDisplay="Label"))
	int OutEvent(int Value, FString Label, int&out OutValue)
	{
		OutEventCalls += 1;
		OutValue = Value + Label.Len();
		return OutValue + 5;
	}

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
}

int Observe_EventCombo_DirectOutEvent(ACoverageUFunctionEventCombinationActor Actor)
{
	if (Actor is null)
	{
		throw("Test_BlueprintEventCallablePureAndOutParameterMatrix setup: required Actor is null");
	}
	int OutValue = 0;
	int Result = Actor.OutEvent(25, "Direct", OutValue);
	if (OutValue != 31)
	{
		return -1;
	}
	return Result;
}

int Observe_EventCombo_Dispatch(ACoverageUFunctionEventCombinationActor Actor)
{
	if (Actor is null)
	{
		throw("Test_BlueprintEventCallablePureAndOutParameterMatrix setup: required Actor is null");
	}
	return Actor.DispatchEventCombinationMatrix();
}

bool Observe_EventCombo_DispatchCallCounts(ACoverageUFunctionEventCombinationActor Actor)
{
	if (Actor is null)
	{
		throw("Test_BlueprintEventCallablePureAndOutParameterMatrix setup: required Actor is null");
	}
	Actor.DispatchEventCombinationMatrix();
	return Actor.PlainEventCalls == 1 && Actor.CallableEventCalls == 1 && Actor.OutEventCalls == 1;
}

int Observe_EventCombo_PureZeroBoundary(ACoverageUFunctionEventCombinationActor Actor)
{
	if (Actor is null)
	{
		throw("Test_BlueprintEventCallablePureAndOutParameterMatrix setup: required Actor is null");
	}
	return Actor.PureConstEvent(0);
}

int Observe_EventCombo_DefaultCallCounts(ACoverageUFunctionEventCombinationActor Actor)
{
	if (Actor is null)
	{
		throw("Test_BlueprintEventCallablePureAndOutParameterMatrix setup: required Actor is null");
	}
	return Actor.PlainEventCalls + Actor.CallableEventCalls + Actor.OutEventCalls;
}

int Observe_EventCombo_EmptyOutBoundary(ACoverageUFunctionEventCombinationActor Actor)
{
	if (Actor is null)
	{
		throw("Test_BlueprintEventCallablePureAndOutParameterMatrix setup: required Actor is null");
	}
	int OutValue = -1;
	int Result = Actor.OutEvent(0, "", OutValue);
	if (OutValue != 0)
	{
		return -1;
	}
	return Result;
}
