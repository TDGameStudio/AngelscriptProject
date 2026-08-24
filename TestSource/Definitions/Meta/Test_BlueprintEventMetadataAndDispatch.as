// Theme: Definitions.Meta. WorldStory: BlueprintEvent dispatch through TriggerEvent.
// C++: AngelscriptCoverageMacrosTests.cpp::BlueprintEventMetadataAndDispatch
// Oracle after BeginPlay TriggerEvent(21): EventCallCount == 1, EventValue == 42.
// Extra: CalculateValue(0) == 0; TriggerEvent(0) writes EventValue 0. FixtureIsolated.

UCLASS()
class ACoveragesMacrosBlueprintEventActor : AActor
{
	UPROPERTY()
	int EventCallCount = 0;

	UPROPERTY()
	int EventValue = 0;

	// BlueprintEvent - can be overridden by Blueprint child classes
	UFUNCTION(BlueprintEvent, Category="Events")
	void OnCustomEvent(int Value)
	{
		EventCallCount++;
		EventValue = Value;
	}

	// BlueprintEvent with return value
	UFUNCTION(BlueprintEvent, Category="Events")
	int CalculateValue(int Input)
	{
		return Input * 2;
	}

	// BlueprintEvent with multiple parameters
	UFUNCTION(BlueprintEvent, Category="Events")
	void OnComplexEvent(int IntParam, FString StringParam, FVector VectorParam)
	{
		EventCallCount += IntParam;
		EventValue = int(VectorParam.X);
	}

	// Function that would call the event (in real usage)
	UFUNCTION(BlueprintCallable, Category="Testing")
	void TriggerEvent(int Value)
	{
		OnCustomEvent(CalculateValue(Value));
	}

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		TriggerEvent(21);
	}
}

int Observe_BlueprintEventDispatch_EventCallCount(ACoveragesMacrosBlueprintEventActor Actor)
{
	return Actor.EventCallCount;
}

int Observe_BlueprintEventDispatch_EventValue(ACoveragesMacrosBlueprintEventActor Actor)
{
	return Actor.EventValue;
}

int Observe_BlueprintEventDispatch_CalculateZeroBoundary(ACoveragesMacrosBlueprintEventActor Actor)
{
	return Actor.CalculateValue(0);
}

int Observe_BlueprintEventDispatch_TriggerZero(ACoveragesMacrosBlueprintEventActor Actor)
{
	Actor.EventCallCount = 0;
	Actor.TriggerEvent(0);
	return Actor.EventValue;
}
