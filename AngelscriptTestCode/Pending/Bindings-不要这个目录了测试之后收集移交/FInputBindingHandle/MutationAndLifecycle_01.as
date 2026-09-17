/**
 * @version v1
 * @summary Observe Execute dispatch and editor script-guard mutation on default Enhanced Input event and debug bindings.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe Execute dispatch and editor script-guard mutation on default Enhanced Input event and debug bindings.
 * @topic Baseline
 */
// EventBinding.SetShouldFireWithEditorScriptGuard(const bool bNewValue);
// DebugBinding.Execute(const FInputActionValue& ActionValue) const;
// Inputs: Default-constructed bindings, a default FInputActionInstance, a
// zero FInputActionValue, then true followed by false for the editor guard.
// Expected observations: Execute returns on an unbound default binding.
// SetShouldFireWithEditorScriptGuard accepts both true and false. Repeated
// Execute still returns.
// Boundary/ownership: Execute borrows ActionData/ActionValue. Unbound
// bindings do not own a callback target.

namespace TS_FInputBindingHandle_MutationAndLifecycle_01
{
	bool Observe_Execute_Nominal()
	{
		FEnhancedInputActionEventBinding EventBinding;
		FInputActionInstance ActionData;
		EventBinding.Execute(ActionData);
		EventBinding.Execute(ActionData);
		FInputDebugKeyBinding DebugBinding;
		FInputActionValue ActionValue;
		DebugBinding.Execute(ActionValue);
		FInputActionValue NonZero(1.0);
		DebugBinding.Execute(NonZero);
		return EventBinding.GetHandle() == 0 && DebugBinding.GetHandle() == 0;
	}

	bool Observe_SetShouldFireWithEditorScriptGuard_Nominal()
	{
		FEnhancedInputActionEventBinding EventBinding;
		EventBinding.SetShouldFireWithEditorScriptGuard(true);
		EventBinding.SetShouldFireWithEditorScriptGuard(false);
		EventBinding.SetShouldFireWithEditorScriptGuard(false);
		return EventBinding.GetHandle() == 0;
	}
}
/** @end */
