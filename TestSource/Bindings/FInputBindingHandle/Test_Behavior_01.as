// Purpose: Observe FEnhancedInputActionValueBinding default construction and
// construction from a UInputAction, including a null action.
// AS-facing API: FEnhancedInputActionValueBinding ValueBinding();
// FEnhancedInputActionValueBinding ValueBinding(const UInputAction InAction);
// Inputs: Default construction, a null UInputAction, and the UInputAction CDO
// as the non-null boundary.
// Expected observations: Default and null-action bindings report a null
// GetAction and a zero GetValue. A CDO action is stored as the associated
// action when the constructor accepts it.
// Boundary/ownership: The binding does not own InAction. A null InAction is
// a valid unassociated binding.

namespace TS_FInputBindingHandle_Behavior_01
{
	bool Observe_ValueBinding_Nominal()
	{
		FEnhancedInputActionValueBinding DefaultBinding;
		UInputAction DefaultAction = DefaultBinding.GetAction();
		FInputActionValue DefaultValue = DefaultBinding.GetValue();

		UInputAction NullAction;
		FEnhancedInputActionValueBinding NullBinding(NullAction);
		UInputAction NullBoundAction = NullBinding.GetAction();

		TSubclassOf<UInputAction> ActionClass = UInputAction::StaticClass();
		UInputAction ActionCdo = ActionClass.GetDefaultObject();
		if (ActionCdo is null)
		{
			throw("TS_FInputBindingHandle_Behavior_01 setup: required UInputAction CDO is null");
		}
		FEnhancedInputActionValueBinding CdoBinding(ActionCdo);
		UInputAction BoundAction = CdoBinding.GetAction();
		return DefaultAction is null &&
			!DefaultValue.IsNonZero() &&
			NullBoundAction is null &&
			BoundAction == ActionCdo;
	}
}
