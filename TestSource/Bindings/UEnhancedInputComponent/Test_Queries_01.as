// Purpose: Observe whether an enhanced input component owns bindings and the
// current accumulated value for a bound action.
// Runner owns the Component fixture. Null Component is setup failure.
// AS-facing API: bool UEnhancedInputComponent.HasBindings() const;
// FInputActionValue UEnhancedInputComponent.GetBoundActionValue(const UInputAction Action);
// Inputs: Runner-owned UEnhancedInputComponent, a bound UInputAction after
// BindActionValue, a second GetBoundActionValue read, and a null action as
// the empty lookup.
// Expected observations: HasBindings is false after clears and true after
// BindActionValue. GetBoundActionValue on an unbound or null action is a zero
// value (IsNonZero false). The bound action value is zero because no live
// input is injected.
// Boundary/ownership: GetBoundActionValue does not take ownership of Action.
// HasBindings does not mutate the component. SetupOwner=Runner.

UCLASS()
class UTSEnhancedInputQueryHost : UObject
{
	UFUNCTION()
	void OnAction(FInputActionValue ActionValue, float32 ElapsedTime, float32 TriggeredTime, const UInputAction SourceAction)
	{
	}
}

namespace TS_UEnhancedInputComponent_Queries_01
{
	bool Observe_HasBindings_Nominal(UEnhancedInputComponent Component)
	{
		if (Component is null)
		{
			throw("TS_UEnhancedInputComponent_Queries_01 setup: required Component is null");
		}
		UTSEnhancedInputQueryHost Host;
		UInputAction Action = Cast<UInputAction>(NewObject(Host, UInputAction::StaticClass(), n"TestSource.EnhancedInput.HasBindingsAction", true));
		if (Action is null)
		{
			throw("TS_UEnhancedInputComponent_Queries_01 setup: required Action is null");
		}
		Component.ClearActionBindings();
		Component.ClearDebugKeyBindings();
		bool bEmptyHasBindings = Component.HasBindings();
		Component.BindActionValue(Action);
		bool bBoundHasBindings = Component.HasBindings();
		Component.ClearActionValueBindings();
		bool bClearedHasBindings = Component.HasBindings();
		return !bEmptyHasBindings && bBoundHasBindings && !bClearedHasBindings;
	}

	bool Observe_GetBoundActionValue_Nominal(UEnhancedInputComponent Component)
	{
		if (Component is null)
		{
			throw("TS_UEnhancedInputComponent_Queries_01 setup: required Component is null");
		}
		UTSEnhancedInputQueryHost Host;
		UInputAction Action = Cast<UInputAction>(NewObject(Host, UInputAction::StaticClass(), n"TestSource.EnhancedInput.BoundValueAction", true));
		if (Action is null)
		{
			throw("TS_UEnhancedInputComponent_Queries_01 setup: required Action is null");
		}
		UInputAction NullAction = nullptr;
		FInputActionValue EmptyValue = Component.GetBoundActionValue(Action);
		FInputActionValue NullValue = Component.GetBoundActionValue(NullAction);
		Component.BindActionValue(Action);
		FInputActionValue BoundValue = Component.GetBoundActionValue(Action);
		Component.ClearActionValueBindings();
		return !EmptyValue.IsNonZero() &&
			!EmptyValue.Get() &&
			!NullValue.IsNonZero() &&
			!BoundValue.IsNonZero() &&
			BoundValue.GetAxis1D() == 0.0;
	}
}
