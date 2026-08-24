// Theme: Gameplay.Input. WorldStory: BindAction preserves all five ETriggerEvent values.
// C++: AngelscriptCoverageInputTests.cpp::EnhancedInputTriggerEventReflectionPreservation
// Oracle: compile/spawn; Configure creates 5 bindings Started/Ongoing/Triggered/Completed/Canceled.
// Extra: default-constructed actor; OnAction remains an empty handler. FixtureIsolated.
// Keep UFUNCTION names OnAction and Configure.

UCLASS()
class ATriggerEventReflectionActor : AActor
{
	UFUNCTION()
	void OnAction(FInputActionValue ActionValue, float32 ElapsedTime, float32 TriggeredTime, const UInputAction SourceAction)
	{
	}

	UFUNCTION()
	void Configure(UEnhancedInputComponent EnhancedComponent, UInputAction Action)
	{
		FEnhancedInputActionHandlerDynamicSignature Delegate;
		Delegate.BindUFunction(this, n"OnAction");
		EnhancedComponent.BindAction(Action, ETriggerEvent::Started, Delegate);
		EnhancedComponent.BindAction(Action, ETriggerEvent::Ongoing, Delegate);
		EnhancedComponent.BindAction(Action, ETriggerEvent::Triggered, Delegate);
		EnhancedComponent.BindAction(Action, ETriggerEvent::Completed, Delegate);
		EnhancedComponent.BindAction(Action, ETriggerEvent::Canceled, Delegate);
	}
}

bool Observe_TriggerEventReflection_DefaultConstructed()
{
	ATriggerEventReflectionActor Actor;
	return Actor != nullptr;
}
