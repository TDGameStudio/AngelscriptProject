/**
 * @version v1
 * @summary Enhanced Input action, action-value and debug-key bindings, followed by the three Clear*Bindings calls. C++ verifies the four flags by path. The observers cover the local-construct default and copy independence.
 * @topic World
 */
/**
 * @version root
 * @summary Enhanced Input action, action-value and debug-key bindings, followed by the three Clear*Bindings calls. C++ verifies the four flags by path. The observers cover the local-construct default and copy independence.
 * @topic Baseline
 */
UCLASS()
class AEnhancedInputCoverageActor : AActor
{
	UPROPERTY()
	UInputAction Action;

	UPROPERTY()
	int StartedCount = 0;

	UPROPERTY()
	bool bBindingsAdded = false;

	UPROPERTY()
	bool bActionValueBindingAdded = false;

	UPROPERTY()
	bool bDebugBindingAdded = false;

	UPROPERTY()
	bool bClearRemovedBindings = false;

	/**
	 * Count each triggered action the bindings deliver.
	 *
	 * @Kind EventHandler
	 * @Covers Component.EnhancedInputComponentBindingEventsAndRemoval
	 * @Inputs the action value and trigger timings
	 * @Return StartedCount incremented once per trigger
	 * @Param ActionValue the value delivered with the action
	 * @Param ElapsedTime how long the action has been held
	 * @Param TriggeredTime how long since the trigger fired
	 * @Param SourceAction the action that fired
	 */
	UFUNCTION()
	void OnAction(FInputActionValue ActionValue, float32 ElapsedTime, float32 TriggeredTime, const UInputAction SourceAction)
	{
		StartedCount += 1;
	}

	/**
	 * Receive a debug key binding without recording anything.
	 *
	 * @Kind EventHandler
	 * @Covers Component.EnhancedInputComponentBindingEventsAndRemoval
	 * @Inputs the key and its action value
	 * @Return nothing; the binding existing is what the test observes
	 * @Param Key the debug key that was pressed
	 * @Param ActionValue the value delivered with the key
	 */
	UFUNCTION()
	void OnDebug(FKey Key, FInputActionValue ActionValue)
	{
	}

	/**
	 * WorldStory: build an enhanced input component, install all three binding
	 * kinds, then clear them again.
	 *
	 * @Kind WorldStory
	 * @Covers Component.EnhancedInputComponentBindingEventsAndRemoval
	 * @Inputs none
	 * @Return all four flags true; all stay false when either NewObject fails
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Action = Cast<UInputAction>(NewObject(this, UInputAction::StaticClass(), n"CoverageAction", true));
		UEnhancedInputComponent EnhancedComponent = Cast<UEnhancedInputComponent>(NewObject(this, UEnhancedInputComponent::StaticClass(), n"CoverageEnhancedInputComponent", true));
		if (Action == nullptr || EnhancedComponent == nullptr)
		{
			return;
		}

		FEnhancedInputActionHandlerDynamicSignature StartedDelegate;
		StartedDelegate.BindUFunction(this, n"OnAction");
		EnhancedComponent.BindAction(Action, ETriggerEvent::Started, StartedDelegate);
		EnhancedComponent.BindAction(Action, ETriggerEvent::Ongoing, StartedDelegate);
		EnhancedComponent.BindAction(Action, ETriggerEvent::Triggered, StartedDelegate);
		EnhancedComponent.BindAction(Action, ETriggerEvent::Completed, StartedDelegate);
		EnhancedComponent.BindAction(Action, ETriggerEvent::Canceled, StartedDelegate);
		bBindingsAdded = EnhancedComponent.HasBindings();

		EnhancedComponent.BindActionValue(Action);
		bActionValueBindingAdded = EnhancedComponent.HasBindings();

		FInputDebugKeyHandlerDynamicSignature DebugDelegate;
		DebugDelegate.BindUFunction(this, n"OnDebug");
		EnhancedComponent.BindDebugKey(FInputChord(EKeys::SpaceBar), EInputEvent::IE_Pressed, DebugDelegate, true);
		bDebugBindingAdded = EnhancedComponent.HasBindings();

		EnhancedComponent.ClearActionEventBindings();
		EnhancedComponent.ClearActionValueBindings();
		EnhancedComponent.ClearDebugKeyBindings();
		bClearRemovedBindings = !EnhancedComponent.HasBindings();
	}

	/**
	 * Observe that a locally constructed actor has no action and no flags set.
	 *
	 * @Kind Observe
	 * @Covers Component.EnhancedInputComponentBindingEventsAndRemoval
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when Action is null, the count is 0 and all flags are clear
	 * @Boundary local construct
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (Action != nullptr)
		{
			return false;
		}
		if (StartedCount != 0)
		{
			return false;
		}
		if (bBindingsAdded)
		{
			return false;
		}
		if (bActionValueBindingAdded)
		{
			return false;
		}
		if (bDebugBindingAdded)
		{
			return false;
		}
		return !bClearRemovedBindings;
	}

	/**
	 * Observe that writing this actor leaves another actor untouched.
	 *
	 * @Kind Observe
	 * @Covers Component.EnhancedInputComponentBindingEventsAndRemoval
	 * @Inputs this actor plus a second actor
	 * @Return true when this holds the bound state and the other stays at its defaults
	 * @Param Second the other actor, expected to stay at its defaults
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(AEnhancedInputCoverageActor Second)
	{
		if (Second is null)
		{
			throw("EnhancedInputComponentBindingEventsAndRemoval setup: required Second is null");
		}
		bBindingsAdded = true;
		StartedCount = 1;

		if (!bBindingsAdded)
		{
			return false;
		}
		if (StartedCount != 1)
		{
			return false;
		}
		if (Second.bBindingsAdded)
		{
			return false;
		}
		if (Second.StartedCount != 0)
		{
			return false;
		}
		return Second.Action == nullptr;
	}
}
/** @end */
