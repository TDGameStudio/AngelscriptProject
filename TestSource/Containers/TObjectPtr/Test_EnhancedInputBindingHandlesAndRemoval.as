// Theme: Containers.TObjectPtr. WorldStory: Enhanced Input BindAction / BindDebugKey handles.
// C++ VerifyByPath bSetupRan true after SetupEnhancedInput; two Started/Triggered bindings.
// Extra: Action default null; bSetupRan false until SetupEnhancedInput. FixtureIsolated.

UCLASS()
class AEnhancedInputBindingHandleActor : AActor
{
	UPROPERTY()
	UInputAction Action;

	UPROPERTY()
	bool bSetupRan = false;

	UFUNCTION()
	void OnAction(FInputActionValue ActionValue, float32 ElapsedTime, float32 TriggeredTime, const UInputAction SourceAction)
	{
	}

	UFUNCTION()
	void OnDebug(FKey Key, FInputActionValue ActionValue)
	{
	}

	UFUNCTION()
	void SetupEnhancedInput(UEnhancedInputComponent EnhancedComponent)
	{
		if (Action == nullptr || EnhancedComponent == nullptr)
		{
			return;
		}

		FEnhancedInputActionHandlerDynamicSignature ActionDelegate;
		ActionDelegate.BindUFunction(this, n"OnAction");
		EnhancedComponent.BindAction(Action, ETriggerEvent::Started, ActionDelegate);
		EnhancedComponent.BindAction(Action, ETriggerEvent::Triggered, ActionDelegate);
		EnhancedComponent.BindActionValue(Action);

		FInputDebugKeyHandlerDynamicSignature DebugDelegate;
		DebugDelegate.BindUFunction(this, n"OnDebug");
		EnhancedComponent.BindDebugKey(FInputChord(EKeys::F), EInputEvent::IE_Pressed, DebugDelegate, true);
		bSetupRan = EnhancedComponent.HasBindings();
	}
}
