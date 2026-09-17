/**
 * @version v1
 * @summary WorldStory: BindAction preserves all five ETriggerEvent values. C++ compiles and spawns ATriggerEventReflectionActor, then Configure creates five bindings. The observer covers a default-constructed actor; OnAction.
 * @topic Gameplay
 */
/**
 * @version root
 * @summary WorldStory: BindAction preserves all five ETriggerEvent values. C++ compiles and spawns ATriggerEventReflectionActor, then Configure creates five bindings. The observer covers a default-constructed actor; OnAction.
 * @topic Baseline
 */
UCLASS()
class ATriggerEventReflectionActor : AActor
{
	/**
	 * Empty handler kept so BindUFunction can bind the five trigger events.
	 *
	 * @Kind Observe
	 * @Covers Input.EnhancedInputTriggerEventReflectionPreservation
	 * @Inputs the bound action callback arguments
	 * @Return void; the handler body stays empty
	 * @Param ActionValue the action value delivered to the handler
	 * @Param ElapsedTime elapsed time delivered to the handler
	 * @Param TriggeredTime triggered time delivered to the handler
	 * @Param SourceAction the source action delivered to the handler
	 */
	UFUNCTION()
	void OnAction(FInputActionValue ActionValue, float32 ElapsedTime, float32 TriggeredTime, const UInputAction SourceAction)
	{
	}

	/**
	 * WorldStory: bind the same handler to Started, Ongoing, Triggered, Completed and Canceled.
	 *
	 * @Kind WorldStory
	 * @Covers Input.EnhancedInputTriggerEventReflectionPreservation
	 * @Inputs an enhanced input component and an input action
	 * @Return five BindAction calls, one per ETriggerEvent value
	 * @Param EnhancedComponent the enhanced input component to bind
	 * @Param Action the action bound to all five trigger events
	 */
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

	/**
	 * Observe that a default-constructed actor handle is live.
	 *
	 * @Kind Observe
	 * @Covers Input.EnhancedInputTriggerEventReflectionPreservation
	 * @Inputs a default-constructed ATriggerEventReflectionActor
	 * @Return true when the actor handle is not null
	 * @Boundary default-constructed actor
	 */
	UFUNCTION()
	bool DefaultConstructed()
	{
		ATriggerEventReflectionActor Actor;
		return Actor != nullptr;
	}
}
/** @end */
