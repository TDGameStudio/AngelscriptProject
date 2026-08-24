// Theme: Definitions.UFunction. WorldStory: BlueprintEvent implementation plus script caller.
// C++: AngelscriptCoverageUFunctionTests.cpp::BlueprintEventReflectsAndInvokesImplementation
// Oracle: ComputeEventValue(25)==42 and LastInputValue 25; CallEventFromScript(5)==22.
// Extra: ComputeEventValue(0)==17; default EventCallCount 0; second instance stays 0.
// FixtureIsolated. Runner owns World teardown.

UCLASS()
class ACoverageUFunctionEventActor : AActor
{
	UPROPERTY()
	int EventCallCount = 0;

	UPROPERTY()
	int LastInputValue = 0;

	UFUNCTION(BlueprintEvent, Category="Coverage|Events", meta=(DisplayName="Compute Event Value"))
	int ComputeEventValue(int Value)
	{
		EventCallCount += 1;
		LastInputValue = Value;
		return Value + 17;
	}

	UFUNCTION()
	int CallEventFromScript(int Value)
	{
		return ComputeEventValue(Value);
	}
}

int Observe_BlueprintEvent_Direct25(ACoverageUFunctionEventActor Actor)
{
	if (Actor is null)
	{
		throw("Test_BlueprintEventReflectsAndInvokesImplementation setup: required Actor is null");
	}
	return Actor.ComputeEventValue(25);
}

int Observe_BlueprintEvent_ScriptCaller5(ACoverageUFunctionEventActor Actor)
{
	if (Actor is null)
	{
		throw("Test_BlueprintEventReflectsAndInvokesImplementation setup: required Actor is null");
	}
	Actor.ComputeEventValue(25);
	return Actor.CallEventFromScript(5);
}

int Observe_BlueprintEvent_CallCountAfterBoth(ACoverageUFunctionEventActor Actor)
{
	if (Actor is null)
	{
		throw("Test_BlueprintEventReflectsAndInvokesImplementation setup: required Actor is null");
	}
	Actor.ComputeEventValue(25);
	Actor.CallEventFromScript(5);
	return Actor.EventCallCount;
}

int Observe_BlueprintEvent_ZeroBoundary(ACoverageUFunctionEventActor Actor)
{
	if (Actor is null)
	{
		throw("Test_BlueprintEventReflectsAndInvokesImplementation setup: required Actor is null");
	}
	return Actor.ComputeEventValue(0);
}

int Observe_BlueprintEvent_DefaultCallCount(ACoverageUFunctionEventActor Actor)
{
	if (Actor is null)
	{
		throw("Test_BlueprintEventReflectsAndInvokesImplementation setup: required Actor is null");
	}
	return Actor.EventCallCount;
}

bool Observe_BlueprintEvent_SecondInstanceIndependent(ACoverageUFunctionEventActor First, ACoverageUFunctionEventActor Second)
{
	if (First is null)
	{
		throw("Test_BlueprintEventReflectsAndInvokesImplementation setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_BlueprintEventReflectsAndInvokesImplementation setup: required Second is null");
	}
	First.ComputeEventValue(25);
	return First.EventCallCount == 1 && First.LastInputValue == 25 && Second.EventCallCount == 0;
}
