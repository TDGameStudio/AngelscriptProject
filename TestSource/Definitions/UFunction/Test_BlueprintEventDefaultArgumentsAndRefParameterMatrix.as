// Theme: Definitions.UFunction. WorldStory: BlueprintEvent defaults and mutable ref.
// C++: AngelscriptCoverageUFunctionTests.cpp::BlueprintEventDefaultArgumentsAndRefParameterMatrix
// Oracle: EventWithDefaults() == 23 LastLabel DefaultLabel; EventWithMutableRef(20) writes 25
// returns 26; DispatchDefaultEvents == 74; EventCallCount 4 after defaults+mutable+dispatch.
// Extra: EventWithDefaults(0,"") == 0; default EventCallCount 0 LastMutable 0.
// FixtureIsolated. Runner owns World teardown.

UCLASS()
class ACoverageUFunctionEventDefaultRefActor : AActor
{
	UPROPERTY()
	int LastMutable = 0;

	UPROPERTY()
	FString LastLabel;

	UPROPERTY()
	int EventCallCount = 0;

	UFUNCTION(BlueprintEvent, BlueprintCallable, Category="Coverage|EventDefaults", meta=(AutoCreateRefTerm="Label"))
	int EventWithDefaults(int Value = 11, const FString&in Label = "DefaultLabel")
	{
		EventCallCount += 1;
		LastLabel = Label;
		return Value + Label.Len();
	}

	UFUNCTION(BlueprintEvent, BlueprintCallable, Category="Coverage|EventDefaults", meta=(DisplayName="Mutable Ref Event"))
	int EventWithMutableRef(int&inout MutableValue, int Bonus = 5)
	{
		EventCallCount += 1;
		MutableValue += Bonus;
		LastMutable = MutableValue;
		return MutableValue + 1;
	}

	UFUNCTION(BlueprintCallable, Category="Coverage|EventDefaults")
	int DispatchDefaultEvents()
	{
		int Score = EventWithDefaults();
		int Mutable = 20;
		Score += EventWithMutableRef(Mutable);
		return Score + Mutable;
	}
}

int Observe_EventDefaults_OmittedArgs(ACoverageUFunctionEventDefaultRefActor Actor)
{
	if (Actor is null)
	{
		throw("Test_BlueprintEventDefaultArgumentsAndRefParameterMatrix setup: required Actor is null");
	}
	return Actor.EventWithDefaults();
}

int Observe_EventDefaults_MutableRef20(ACoverageUFunctionEventDefaultRefActor Actor)
{
	if (Actor is null)
	{
		throw("Test_BlueprintEventDefaultArgumentsAndRefParameterMatrix setup: required Actor is null");
	}
	int Mutable = 20;
	int Result = Actor.EventWithMutableRef(Mutable);
	if (Mutable != 25 || Actor.LastMutable != 25)
	{
		return -1;
	}
	return Result;
}

int Observe_EventDefaults_Dispatch(ACoverageUFunctionEventDefaultRefActor Actor)
{
	if (Actor is null)
	{
		throw("Test_BlueprintEventDefaultArgumentsAndRefParameterMatrix setup: required Actor is null");
	}
	return Actor.DispatchDefaultEvents();
}

bool Observe_EventDefaults_DispatchState(ACoverageUFunctionEventDefaultRefActor Actor)
{
	if (Actor is null)
	{
		throw("Test_BlueprintEventDefaultArgumentsAndRefParameterMatrix setup: required Actor is null");
	}
	Actor.DispatchDefaultEvents();
	return Actor.EventCallCount == 2 && Actor.LastMutable == 25 && Actor.LastLabel == "DefaultLabel";
}

int Observe_EventDefaults_EmptyZeroBoundary(ACoverageUFunctionEventDefaultRefActor Actor)
{
	if (Actor is null)
	{
		throw("Test_BlueprintEventDefaultArgumentsAndRefParameterMatrix setup: required Actor is null");
	}
	return Actor.EventWithDefaults(0, "");
}

int Observe_EventDefaults_DefaultCallCount(ACoverageUFunctionEventDefaultRefActor Actor)
{
	if (Actor is null)
	{
		throw("Test_BlueprintEventDefaultArgumentsAndRefParameterMatrix setup: required Actor is null");
	}
	return Actor.EventCallCount;
}
