/**
 * @version v1
 * @summary Observe enhanced-input editor-fire flags, clear helpers, and index/handle removal, including repeated clears and empty-index results.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe enhanced-input editor-fire flags, clear helpers, and index/handle removal, including repeated clears and empty-index results.
 * @topic Baseline
 */
// Runner owns the Component fixture. Null Component is setup failure.
// AS-facing API: void UEnhancedInputComponent.SetShouldFireDelegatesInEditor(const bool bInNewValue);
// void UEnhancedInputComponent.ClearActionEventBindings();
// void UEnhancedInputComponent.ClearActionValueBindings();
// void UEnhancedInputComponent.ClearDebugKeyBindings();
// void UEnhancedInputComponent.ClearActionBindings();
// void UEnhancedInputComponent.ClearBindingsForObject(UObject InOwner);
// bool UEnhancedInputComponent.RemoveActionEventBinding(const int32 BindingIndex);
// bool UEnhancedInputComponent.RemoveDebugKeyBinding(const int32 BindingIndex);
// bool UEnhancedInputComponent.RemoveActionValueBinding(const int32 BindingIndex);
// bool UEnhancedInputComponent.RemoveBindingByHandle(const uint32 BindingIndex);
// Inputs: A host object with OnAction/OnDebug, one UInputAction, seeded
// BindAction/BindActionValue/BindDebugKey state, bInNewValue true then false,
// BindingIndex 0 as first valid, BindingIndex -1 as empty/invalid, and the
// numeric handle from GetHandle after BindAction.
// Expected observations: SetShouldFireDelegatesInEditor is visible through
// ShouldFireDelegatesInEditor. Clears drop HasBindings to false. Remove by
// valid index or handle returns true once and false on the empty follow-up.
// Boundary/ownership: BindingIndex is an array index except RemoveBindingByHandle
// which takes the registered handle value. Delegates stay owned by the host
// object; clears do not destroy the host. SetupOwner=Runner.

UCLASS()
class UTSEnhancedInputMutationHost : UObject
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

namespace TS_UEnhancedInputComponent_MutationAndLifecycle_01
{
	bool Observe_SetShouldFireDelegatesInEditor_Nominal(UEnhancedInputComponent Component)
	{
		if (Component is null)
		{
			throw("TS_UEnhancedInputComponent_MutationAndLifecycle_01 setup: required Component is null");
		}
		bool bDefault = Component.ShouldFireDelegatesInEditor();
		Component.SetShouldFireDelegatesInEditor(true);
		bool bEnabled = Component.ShouldFireDelegatesInEditor();
		Component.SetShouldFireDelegatesInEditor(true);
		bool bRepeated = Component.ShouldFireDelegatesInEditor();
		Component.SetShouldFireDelegatesInEditor(false);
		bool bDisabled = Component.ShouldFireDelegatesInEditor();
		Component.SetShouldFireDelegatesInEditor(bDefault);
		return bEnabled && bRepeated && !bDisabled;
	}

	bool Observe_ClearActionEventBindings_Nominal(UEnhancedInputComponent Component)
	{
		if (Component is null)
		{
			throw("TS_UEnhancedInputComponent_MutationAndLifecycle_01 setup: required Component is null");
		}
		UTSEnhancedInputMutationHost Host;
		UInputAction Action = Cast<UInputAction>(NewObject(Host, UInputAction::StaticClass(), n"TestSource.EnhancedInput.ClearEventsAction", true));
		if (Action is null)
		{
			throw("TS_UEnhancedInputComponent_MutationAndLifecycle_01 setup: required Action is null");
		}
		FEnhancedInputActionHandlerDynamicSignature Delegate;
		Delegate.BindUFunction(Host, n"OnAction");
		Component.ClearActionBindings();
		Component.ClearDebugKeyBindings();
		Component.BindAction(Action, ETriggerEvent::Triggered, Delegate);
		bool bBefore = Component.HasBindings();
		Component.ClearActionEventBindings();
		bool bAfter = Component.HasBindings();
		Component.ClearActionEventBindings();
		return bBefore && !bAfter && !Component.HasBindings();
	}

	bool Observe_ClearActionValueBindings_Nominal(UEnhancedInputComponent Component)
	{
		if (Component is null)
		{
			throw("TS_UEnhancedInputComponent_MutationAndLifecycle_01 setup: required Component is null");
		}
		UTSEnhancedInputMutationHost Host;
		UInputAction Action = Cast<UInputAction>(NewObject(Host, UInputAction::StaticClass(), n"TestSource.EnhancedInput.ClearValuesAction", true));
		if (Action is null)
		{
			throw("TS_UEnhancedInputComponent_MutationAndLifecycle_01 setup: required Action is null");
		}
		Component.ClearActionBindings();
		Component.ClearDebugKeyBindings();
		Component.BindActionValue(Action);
		bool bBefore = Component.HasBindings();
		Component.ClearActionValueBindings();
		bool bAfter = Component.HasBindings();
		Component.ClearActionValueBindings();
		return bBefore && !bAfter;
	}

	bool Observe_ClearDebugKeyBindings_Nominal(UEnhancedInputComponent Component)
	{
		if (Component is null)
		{
			throw("TS_UEnhancedInputComponent_MutationAndLifecycle_01 setup: required Component is null");
		}
		UTSEnhancedInputMutationHost Host;
		FInputDebugKeyHandlerDynamicSignature Delegate;
		Delegate.BindUFunction(Host, n"OnDebug");
		Component.ClearActionBindings();
		Component.ClearDebugKeyBindings();
		Component.BindDebugKey(FInputChord(EKeys::SpaceBar), EInputEvent::IE_Pressed, Delegate);
		bool bBefore = Component.HasBindings();
		Component.ClearDebugKeyBindings();
		bool bAfter = Component.HasBindings();
		Component.ClearDebugKeyBindings();
		return bBefore && !bAfter;
	}

	bool Observe_ClearActionBindings_Nominal(UEnhancedInputComponent Component)
	{
		if (Component is null)
		{
			throw("TS_UEnhancedInputComponent_MutationAndLifecycle_01 setup: required Component is null");
		}
		UTSEnhancedInputMutationHost Host;
		UInputAction Action = Cast<UInputAction>(NewObject(Host, UInputAction::StaticClass(), n"TestSource.EnhancedInput.ClearActionsAction", true));
		if (Action is null)
		{
			throw("TS_UEnhancedInputComponent_MutationAndLifecycle_01 setup: required Action is null");
		}
		FEnhancedInputActionHandlerDynamicSignature Delegate;
		Delegate.BindUFunction(Host, n"OnAction");
		Component.ClearActionBindings();
		Component.ClearDebugKeyBindings();
		Component.BindAction(Action, ETriggerEvent::Started, Delegate);
		Component.BindActionValue(Action);
		bool bBefore = Component.HasBindings();
		Component.ClearActionBindings();
		bool bAfter = Component.HasBindings();
		Component.ClearActionBindings();
		return bBefore && !bAfter;
	}

	bool Observe_ClearBindingsForObject_Nominal(UEnhancedInputComponent Component)
	{
		if (Component is null)
		{
			throw("TS_UEnhancedInputComponent_MutationAndLifecycle_01 setup: required Component is null");
		}
		UTSEnhancedInputMutationHost Host;
		UInputAction Action = Cast<UInputAction>(NewObject(Host, UInputAction::StaticClass(), n"TestSource.EnhancedInput.ClearForObjectAction", true));
		if (Action is null)
		{
			throw("TS_UEnhancedInputComponent_MutationAndLifecycle_01 setup: required Action is null");
		}
		FEnhancedInputActionHandlerDynamicSignature Delegate;
		Delegate.BindUFunction(Host, n"OnAction");
		Component.ClearActionBindings();
		Component.ClearDebugKeyBindings();
		Component.BindAction(Action, ETriggerEvent::Triggered, Delegate);
		bool bBefore = Component.HasBindings();
		UObject NullOwner = nullptr;
		Component.ClearBindingsForObject(NullOwner);
		bool bAfterNull = Component.HasBindings();
		Component.ClearBindingsForObject(Host);
		bool bAfterHost = Component.HasBindings();
		Component.ClearBindingsForObject(Host);
		return bBefore && bAfterNull && !bAfterHost;
	}

	bool Observe_RemoveActionEventBinding_Nominal(UEnhancedInputComponent Component)
	{
		if (Component is null)
		{
			throw("TS_UEnhancedInputComponent_MutationAndLifecycle_01 setup: required Component is null");
		}
		UTSEnhancedInputMutationHost Host;
		UInputAction Action = Cast<UInputAction>(NewObject(Host, UInputAction::StaticClass(), n"TestSource.EnhancedInput.RemoveEventAction", true));
		if (Action is null)
		{
			throw("TS_UEnhancedInputComponent_MutationAndLifecycle_01 setup: required Action is null");
		}
		FEnhancedInputActionHandlerDynamicSignature Delegate;
		Delegate.BindUFunction(Host, n"OnAction");
		Component.ClearActionEventBindings();
		Component.BindAction(Action, ETriggerEvent::Triggered, Delegate);
		bool bRemovedFirst = Component.RemoveActionEventBinding(0);
		bool bRemovedEmpty = Component.RemoveActionEventBinding(0);
		bool bRemovedNegative = Component.RemoveActionEventBinding(-1);
		return bRemovedFirst && !bRemovedEmpty && !bRemovedNegative;
	}

	bool Observe_RemoveDebugKeyBinding_Nominal(UEnhancedInputComponent Component)
	{
		if (Component is null)
		{
			throw("TS_UEnhancedInputComponent_MutationAndLifecycle_01 setup: required Component is null");
		}
		UTSEnhancedInputMutationHost Host;
		FInputDebugKeyHandlerDynamicSignature Delegate;
		Delegate.BindUFunction(Host, n"OnDebug");
		Component.ClearDebugKeyBindings();
		Component.BindDebugKey(FInputChord(EKeys::F), EInputEvent::IE_Pressed, Delegate, true);
		bool bRemovedFirst = Component.RemoveDebugKeyBinding(0);
		bool bRemovedEmpty = Component.RemoveDebugKeyBinding(0);
		return bRemovedFirst && !bRemovedEmpty;
	}

	bool Observe_RemoveActionValueBinding_Nominal(UEnhancedInputComponent Component)
	{
		if (Component is null)
		{
			throw("TS_UEnhancedInputComponent_MutationAndLifecycle_01 setup: required Component is null");
		}
		UTSEnhancedInputMutationHost Host;
		UInputAction Action = Cast<UInputAction>(NewObject(Host, UInputAction::StaticClass(), n"TestSource.EnhancedInput.RemoveValueAction", true));
		if (Action is null)
		{
			throw("TS_UEnhancedInputComponent_MutationAndLifecycle_01 setup: required Action is null");
		}
		Component.ClearActionValueBindings();
		Component.BindActionValue(Action);
		bool bRemovedFirst = Component.RemoveActionValueBinding(0);
		bool bRemovedEmpty = Component.RemoveActionValueBinding(0);
		return bRemovedFirst && !bRemovedEmpty;
	}

	bool Observe_RemoveBindingByHandle_Nominal(UEnhancedInputComponent Component)
	{
		if (Component is null)
		{
			throw("TS_UEnhancedInputComponent_MutationAndLifecycle_01 setup: required Component is null");
		}
		UTSEnhancedInputMutationHost Host;
		UInputAction Action = Cast<UInputAction>(NewObject(Host, UInputAction::StaticClass(), n"TestSource.EnhancedInput.RemoveHandleAction", true));
		if (Action is null)
		{
			throw("TS_UEnhancedInputComponent_MutationAndLifecycle_01 setup: required Action is null");
		}
		FEnhancedInputActionHandlerDynamicSignature Delegate;
		Delegate.BindUFunction(Host, n"OnAction");
		Component.ClearActionEventBindings();
		FEnhancedInputActionEventBinding& EventBinding = Component.BindAction(Action, ETriggerEvent::Started, Delegate);
		uint32 Handle = EventBinding.GetHandle();
		bool bRemovedHandle = Component.RemoveBindingByHandle(Handle);
		bool bRemovedAgain = Component.RemoveBindingByHandle(Handle);
		bool bRemovedZero = Component.RemoveBindingByHandle(0);
		return Handle != 0 && bRemovedHandle && !bRemovedAgain && !bRemovedZero;
	}

	void ExerciseExpectedFailure()
	{
		UTSEnhancedInputMutationHost Host;
		UEnhancedInputComponent Component = Cast<UEnhancedInputComponent>(NewObject(Host, UEnhancedInputComponent::StaticClass(), n"TestSource.EnhancedInput.ExpectedFailure", true));
		FEnhancedInputActionHandlerDynamicSignature Delegate;
		Delegate.BindUFunction(Host, n"OnAction");
		UInputAction NullAction = nullptr;
		FEnhancedInputActionEventBinding& EventBinding = Component.BindAction(NullAction, ETriggerEvent::Triggered, Delegate);
		uint32 Handle = EventBinding.GetHandle();
	}
}
/** @end */
