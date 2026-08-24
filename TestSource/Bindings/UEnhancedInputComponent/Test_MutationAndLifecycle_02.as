// Purpose: Observe BindAction, BindActionValue, BindDebugKey, and the four
// RemoveBinding overloads, including returned-reference aliasing.
// Runner owns the Component fixture. Null Component is setup failure.
// AS-facing API: bool UEnhancedInputComponent.RemoveBinding(const FInputBindingHandle& BindingToRemove);
// bool UEnhancedInputComponent.RemoveBinding(const FEnhancedInputActionEventBinding& BindingToRemove);
// bool UEnhancedInputComponent.RemoveBinding(const FEnhancedInputActionValueBinding& BindingToRemove);
// bool UEnhancedInputComponent.RemoveBinding(const FInputDebugKeyBinding& BindingToRemove);
// FEnhancedInputActionEventBinding& UEnhancedInputComponent.BindAction(const UInputAction Action, ETriggerEvent TriggerEvent, FEnhancedInputActionHandlerDynamicSignature Delegate);
// FEnhancedInputActionValueBinding& UEnhancedInputComponent.BindActionValue(const UInputAction Action);
// FInputDebugKeyBinding& UEnhancedInputComponent.BindDebugKey(const FInputChord Chord, const EInputEvent KeyEvent, FInputDebugKeyHandlerDynamicSignature Delegate, bool bExecuteWhenPaused = true);
// Inputs: Host OnAction/OnDebug, one UInputAction, ETriggerEvent::Started and
// Triggered, FInputChord(EKeys::SpaceBar), EInputEvent::IE_Pressed, default
// bExecuteWhenPaused omission plus false, empty handle/value/debug records, and
// live returned bindings.
// Expected observations: Bind helpers return aliases whose GetHandle is reused
// for a follow-up HasBindings read. RemoveBinding is false on empty records and
// true on the live binding they identify. BindDebugKey default and explicit
// paused flags both register.
// Boundary/ownership: Returned references alias component-owned arrays and
// become invalid after a matching remove. Delegates are owned by the host.
// SetupOwner=Runner.

UCLASS()
class UTSEnhancedInputBindHost : UObject
{
	UFUNCTION()
	void OnAction(FInputActionValue ActionValue, float32 ElapsedTime, float32 TriggeredTime, const UInputAction SourceAction)
	{
	}

	UFUNCTION()
	void OnDebug(FKey Key, FInputActionValue ActionValue)
	{
	}
}

namespace TS_UEnhancedInputComponent_MutationAndLifecycle_02
{
	bool Observe_RemoveBinding_Nominal(UEnhancedInputComponent Component)
	{
		if (Component is null)
		{
			throw("TS_UEnhancedInputComponent_MutationAndLifecycle_02 setup: required Component is null");
		}
		UTSEnhancedInputBindHost Host;
		UInputAction Action = Cast<UInputAction>(NewObject(Host, UInputAction::StaticClass(), n"TestSource.EnhancedInput.RemoveBindingAction", true));
		if (Action is null)
		{
			throw("TS_UEnhancedInputComponent_MutationAndLifecycle_02 setup: required Action is null");
		}
		FEnhancedInputActionHandlerDynamicSignature ActionDelegate;
		ActionDelegate.BindUFunction(Host, n"OnAction");
		FInputDebugKeyHandlerDynamicSignature DebugDelegate;
		DebugDelegate.BindUFunction(Host, n"OnDebug");

		Component.ClearActionBindings();
		Component.ClearDebugKeyBindings();

		FInputBindingHandle EmptyHandle;
		bool bEmptyHandleRemoved = Component.RemoveBinding(EmptyHandle);

		FEnhancedInputActionEventBinding& EventBinding = Component.BindAction(Action, ETriggerEvent::Started, ActionDelegate);
		uint32 EventHandle = EventBinding.GetHandle();
		bool bEventRemoved = Component.RemoveBinding(EventBinding);

		FEnhancedInputActionValueBinding EmptyValue;
		bool bEmptyValueRemoved = Component.RemoveBinding(EmptyValue);
		FEnhancedInputActionValueBinding& ValueBinding = Component.BindActionValue(Action);
		uint32 ValueHandle = ValueBinding.GetHandle();
		bool bValueRemoved = Component.RemoveBinding(ValueBinding);

		FInputDebugKeyBinding EmptyDebug;
		bool bEmptyDebugRemoved = Component.RemoveBinding(EmptyDebug);
		FInputDebugKeyBinding& DebugBinding = Component.BindDebugKey(FInputChord(EKeys::SpaceBar), EInputEvent::IE_Pressed, DebugDelegate);
		uint32 DebugHandle = DebugBinding.GetHandle();
		bool bDebugRemoved = Component.RemoveBinding(DebugBinding);

		return !bEmptyHandleRemoved &&
			EventHandle != 0 &&
			bEventRemoved &&
			!bEmptyValueRemoved &&
			ValueHandle != 0 &&
			bValueRemoved &&
			!bEmptyDebugRemoved &&
			DebugHandle != 0 &&
			bDebugRemoved;
	}

	bool Observe_BindAction_Nominal(UEnhancedInputComponent Component)
	{
		if (Component is null)
		{
			throw("TS_UEnhancedInputComponent_MutationAndLifecycle_02 setup: required Component is null");
		}
		UTSEnhancedInputBindHost Host;
		UInputAction Action = Cast<UInputAction>(NewObject(Host, UInputAction::StaticClass(), n"TestSource.EnhancedInput.BindActionAction", true));
		if (Action is null)
		{
			throw("TS_UEnhancedInputComponent_MutationAndLifecycle_02 setup: required Action is null");
		}
		FEnhancedInputActionHandlerDynamicSignature Delegate;
		Delegate.BindUFunction(Host, n"OnAction");
		Component.ClearActionEventBindings();
		FEnhancedInputActionEventBinding& Started = Component.BindAction(Action, ETriggerEvent::Started, Delegate);
		FEnhancedInputActionEventBinding& Triggered = Component.BindAction(Action, ETriggerEvent::Triggered, Delegate);
		uint32 StartedHandle = Started.GetHandle();
		UInputAction StartedAction = Started.GetAction();
		ETriggerEvent StartedTrigger = Started.GetTriggerEvent();
		uint32 TriggeredHandle = Triggered.GetHandle();
		bool bHasBindings = Component.HasBindings();
		return StartedAction == Action &&
			StartedTrigger == ETriggerEvent::Started &&
			StartedHandle != TriggeredHandle &&
			bHasBindings;
	}

	bool Observe_BindActionValue_Nominal(UEnhancedInputComponent Component)
	{
		if (Component is null)
		{
			throw("TS_UEnhancedInputComponent_MutationAndLifecycle_02 setup: required Component is null");
		}
		UTSEnhancedInputBindHost Host;
		UInputAction Action = Cast<UInputAction>(NewObject(Host, UInputAction::StaticClass(), n"TestSource.EnhancedInput.BindActionValueAction", true));
		if (Action is null)
		{
			throw("TS_UEnhancedInputComponent_MutationAndLifecycle_02 setup: required Action is null");
		}
		Component.ClearActionValueBindings();
		FEnhancedInputActionValueBinding& ValueBinding = Component.BindActionValue(Action);
		UInputAction BoundAction = ValueBinding.GetAction();
		uint32 Handle = ValueBinding.GetHandle();
		FInputActionValue Value = ValueBinding.GetValue();
		FEnhancedInputActionValueBinding& Alias = Component.BindActionValue(Action);
		uint32 AliasHandle = Alias.GetHandle();
		return BoundAction == Action &&
			!Value.IsNonZero() &&
			Component.HasBindings() &&
			Handle == AliasHandle;
	}

	bool Observe_BindDebugKey_Nominal(UEnhancedInputComponent Component)
	{
		if (Component is null)
		{
			throw("TS_UEnhancedInputComponent_MutationAndLifecycle_02 setup: required Component is null");
		}
		UTSEnhancedInputBindHost Host;
		FInputDebugKeyHandlerDynamicSignature Delegate;
		Delegate.BindUFunction(Host, n"OnDebug");
		Component.ClearDebugKeyBindings();
		FInputDebugKeyBinding& DefaultPaused = Component.BindDebugKey(FInputChord(EKeys::SpaceBar), EInputEvent::IE_Pressed, Delegate);
		FInputDebugKeyBinding& ExplicitPaused = Component.BindDebugKey(FInputChord(EKeys::F), EInputEvent::IE_Pressed, Delegate, true);
		FInputDebugKeyBinding& Unpaused = Component.BindDebugKey(FInputChord(EKeys::G), EInputEvent::IE_Released, Delegate, false);
		uint32 DefaultHandle = DefaultPaused.GetHandle();
		uint32 ExplicitHandle = ExplicitPaused.GetHandle();
		uint32 UnpausedHandle = Unpaused.GetHandle();
		return Component.HasBindings() &&
			DefaultHandle != ExplicitHandle &&
			ExplicitHandle != UnpausedHandle &&
			DefaultHandle != UnpausedHandle;
	}
}
