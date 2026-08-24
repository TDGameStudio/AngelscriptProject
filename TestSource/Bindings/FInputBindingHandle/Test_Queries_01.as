// Purpose: Observe handle numbers, bound actions, trigger events, object
// ownership, and latest values on default and null-action bindings.
// AS-facing API: uint32 Handle = BindingHandle.GetHandle() const;
// uint32 Handle = EventBinding.GetHandle() const;
// const UInputAction Action = EventBinding.GetAction() const;
// ETriggerEvent Trigger = EventBinding.GetTriggerEvent() const;
// bool bBound = EventBinding.IsBoundToObject(const UObject Object) const;
// uint32 Handle = ValueBinding.GetHandle() const;
// const UInputAction Action = ValueBinding.GetAction() const;
// FInputActionValue Value = ValueBinding.GetValue() const;
// uint32 Handle = DebugBinding.GetHandle() const;
// Inputs: Default-constructed handles, a value binding from a null
// UInputAction, a null UObject, and a live UObject CDO.
// Expected observations: Default GetHandle is 0. GetAction is null. IsBoundToObject
// is false for null and for an unbound CDO. GetValue of an unbound value
// binding is zero.
// Boundary/ownership: GetAction returns a borrowed UInputAction. GetValue
// returns a copied FInputActionValue.

namespace TS_FInputBindingHandle_Queries_01
{
	bool Observe_GetHandle_Nominal()
	{
		FInputBindingHandle BindingHandle;
		FEnhancedInputActionEventBinding EventBinding;
		FEnhancedInputActionValueBinding ValueBinding;
		FInputDebugKeyBinding DebugBinding;
		return BindingHandle.GetHandle() == 0 &&
			EventBinding.GetHandle() == 0 &&
			ValueBinding.GetHandle() == 0 &&
			DebugBinding.GetHandle() == 0;
	}

	bool Observe_GetAction_Nominal()
	{
		FEnhancedInputActionEventBinding EventBinding;
		FEnhancedInputActionValueBinding ValueBinding;
		UInputAction NullAction;
		FEnhancedInputActionValueBinding FromNull(NullAction);
		return EventBinding.GetAction() is null &&
			ValueBinding.GetAction() is null &&
			FromNull.GetAction() is null;
	}

	bool Observe_GetTriggerEvent_Nominal()
	{
		FEnhancedInputActionEventBinding EventBinding;
		ETriggerEvent DefaultTrigger;
		return EventBinding.GetTriggerEvent() == DefaultTrigger;
	}

	bool Observe_IsBoundToObject_Nominal()
	{
		FEnhancedInputActionEventBinding EventBinding;
		UObject NullObject;
		TSubclassOf<UObject> ObjectClass = UObject::StaticClass();
		UObject LiveCdo = ObjectClass.GetDefaultObject();
		if (LiveCdo is null)
		{
			throw("TS_FInputBindingHandle_Queries_01 setup: required UObject CDO is null");
		}
		return !EventBinding.IsBoundToObject(NullObject) && !EventBinding.IsBoundToObject(LiveCdo);
	}

	bool Observe_GetValue_Nominal()
	{
		FEnhancedInputActionValueBinding ValueBinding;
		FInputActionValue EmptyValue = ValueBinding.GetValue();
		UInputAction Action;
		FEnhancedInputActionValueBinding FromNull(Action);
		FInputActionValue FromNullValue = FromNull.GetValue();
		return !EmptyValue.IsNonZero() && !FromNullValue.IsNonZero();
	}
}
