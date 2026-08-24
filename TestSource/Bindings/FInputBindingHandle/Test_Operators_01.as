// Purpose: Observe equality of FInputBindingHandle and the three Enhanced
// Input binding value types.
// AS-facing API: bool bEqual = LeftHandle == RightHandle;
// bool bEqual = LeftEventBinding == RightEventBinding;
// bool bEqual = LeftValueBinding == RightValueBinding;
// bool bEqual = LeftDebugBinding == RightDebugBinding;
// Inputs: Default-constructed pairs as identity, a second default as the
// zero operand, and a value binding constructed from a null UInputAction as
// the boundary.
// Expected observations: Default handles compare equal to another default.
// A value binding from a null action still participates in equality. True
// and false outcomes are both consumed.
// Boundary/ownership: Equality compares handle identity. Copies are
// independent values.

namespace TS_FInputBindingHandle_Operators_01
{
	bool Observe_Equality_Nominal()
	{
		FInputBindingHandle LeftHandle;
		FInputBindingHandle RightHandle;
		FEnhancedInputActionEventBinding LeftEventBinding;
		FEnhancedInputActionEventBinding RightEventBinding;
		FEnhancedInputActionValueBinding LeftValueBinding;
		FEnhancedInputActionValueBinding RightValueBinding;
		UInputAction Action;
		FEnhancedInputActionValueBinding FromNullAction(Action);
		FInputDebugKeyBinding LeftDebugBinding;
		FInputDebugKeyBinding RightDebugBinding;
		return (LeftHandle == RightHandle) &&
			(LeftEventBinding == RightEventBinding) &&
			(LeftValueBinding == RightValueBinding) &&
			(FromNullAction == LeftValueBinding) &&
			(LeftDebugBinding == RightDebugBinding);
	}
}
