// Purpose: Observe input-action metadata setters and mapping modifier/trigger
// list mutation, including repeated adds and clear restoration.
// AS-facing API: void UInputAction.SetValueType(EInputActionValueType InValueType);
// void UInputAction.SetAccumulationBehavior(EInputActionAccumulationBehavior InBehavior);
// void Mapping.SetAction(const UInputAction InAction);
// void Mapping.SetKey(FKey InKey);
// void Mapping.AddModifier(UInputModifier Modifier);
// void Mapping.ClearModifiers();
// void Mapping.AddTrigger(UInputTrigger Trigger);
// void Mapping.ClearTriggers();
// Inputs: Seeded Boolean/TakeHighestAbsoluteValue action, Axis2D + Cumulative
// mutation arguments, a mapped EKeys::W record, a second action/key, one
// UInputModifierNegate plus UInputModifierScalar, one UInputTriggerDown plus
// UInputTriggerPressed, repeated add of the same modifier, and clear.
// Expected observations: Getters report the last Set. AddModifier/AddTrigger
// increase counts. ClearModifiers/ClearTriggers restore count 0. Repeated add
// appends another entry.
// Boundary/ownership: Modifiers and triggers are evaluated in insertion order
// and remain owned by the mapping/context, not copied by value. Null NewObject
// results are setup failure.

namespace TS_UInputMappingContext_MutationAndLifecycle_01
{
	bool Observe_SetValueType_Nominal()
	{
		UInputAction Action = Cast<UInputAction>(NewObject(GetTransientPackage(), UInputAction::StaticClass(), n"TestSource.Mapping.SetValueType", true));
		if (Action is null)
		{
			throw("TS_UInputMappingContext_MutationAndLifecycle_01 setup: required Action is null");
		}
		Action.SetValueType(EInputActionValueType::Axis1D);
		EInputActionValueType AfterFirst = Action.GetValueType();
		Action.SetValueType(EInputActionValueType::Axis1D);
		EInputActionValueType AfterRepeat = Action.GetValueType();
		Action.SetValueType(EInputActionValueType::Boolean);
		EInputActionValueType Restored = Action.GetValueType();
		return AfterFirst == EInputActionValueType::Axis1D &&
			AfterRepeat == EInputActionValueType::Axis1D &&
			Restored == EInputActionValueType::Boolean;
	}

	bool Observe_SetAccumulationBehavior_Nominal()
	{
		UInputAction Action = Cast<UInputAction>(NewObject(GetTransientPackage(), UInputAction::StaticClass(), n"TestSource.Mapping.SetAccumulation", true));
		if (Action is null)
		{
			throw("TS_UInputMappingContext_MutationAndLifecycle_01 setup: required Action is null");
		}
		Action.SetAccumulationBehavior(EInputActionAccumulationBehavior::Cumulative);
		EInputActionAccumulationBehavior AfterFirst = Action.GetAccumulationBehavior();
		Action.SetAccumulationBehavior(EInputActionAccumulationBehavior::Cumulative);
		EInputActionAccumulationBehavior AfterRepeat = Action.GetAccumulationBehavior();
		Action.SetAccumulationBehavior(EInputActionAccumulationBehavior::TakeHighestAbsoluteValue);
		EInputActionAccumulationBehavior Restored = Action.GetAccumulationBehavior();
		return AfterFirst == EInputActionAccumulationBehavior::Cumulative &&
			AfterRepeat == EInputActionAccumulationBehavior::Cumulative &&
			Restored == EInputActionAccumulationBehavior::TakeHighestAbsoluteValue;
	}

	bool Observe_SetAction_Nominal()
	{
		UInputAction Action = Cast<UInputAction>(NewObject(GetTransientPackage(), UInputAction::StaticClass(), n"TestSource.Mapping.SetAction", true));
		UInputAction Other = Cast<UInputAction>(NewObject(GetTransientPackage(), UInputAction::StaticClass(), n"TestSource.Mapping.SetActionOther", true));
		if (Action is null || Other is null)
		{
			throw("TS_UInputMappingContext_MutationAndLifecycle_01 setup: required Action is null");
		}
		FEnhancedActionKeyMapping Mapping(Action, EKeys::W);
		Mapping.SetAction(Other);
		UInputAction AfterFirst = Mapping.GetAction();
		Mapping.SetAction(Other);
		UInputAction AfterRepeat = Mapping.GetAction();
		Mapping.SetAction(Action);
		UInputAction Restored = Mapping.GetAction();
		UInputAction NullAction = nullptr;
		Mapping.SetAction(NullAction);
		UInputAction AfterNull = Mapping.GetAction();
		return AfterFirst == Other && AfterRepeat == Other && Restored == Action && AfterNull is null;
	}

	bool Observe_SetKey_Nominal()
	{
		UInputAction Action = Cast<UInputAction>(NewObject(GetTransientPackage(), UInputAction::StaticClass(), n"TestSource.Mapping.SetKey", true));
		if (Action is null)
		{
			throw("TS_UInputMappingContext_MutationAndLifecycle_01 setup: required Action is null");
		}
		FEnhancedActionKeyMapping Mapping(Action, EKeys::W);
		Mapping.SetKey(EKeys::S);
		FKey AfterFirst = Mapping.GetKey();
		Mapping.SetKey(EKeys::S);
		FKey AfterRepeat = Mapping.GetKey();
		Mapping.SetKey(EKeys::W);
		FKey Restored = Mapping.GetKey();
		Mapping.SetKey(EKeys::Invalid);
		FKey AfterInvalid = Mapping.GetKey();
		return AfterFirst == EKeys::S && AfterRepeat == EKeys::S && Restored == EKeys::W && !AfterInvalid.IsValid();
	}

	bool Observe_AddModifier_Nominal()
	{
		UInputAction Action = Cast<UInputAction>(NewObject(GetTransientPackage(), UInputAction::StaticClass(), n"TestSource.Mapping.AddModifier", true));
		UInputMappingContext Context = Cast<UInputMappingContext>(NewObject(GetTransientPackage(), UInputMappingContext::StaticClass(), n"TestSource.Mapping.AddModifierContext", true));
		if (Action is null)
		{
			throw("TS_UInputMappingContext_MutationAndLifecycle_01 setup: required Action is null");
		}
		if (Context is null)
		{
			throw("TS_UInputMappingContext_MutationAndLifecycle_01 setup: required Context is null");
		}
		FEnhancedActionKeyMapping& Mapping = Context.MapKey(Action, EKeys::SpaceBar);
		UInputModifierNegate Negate = Cast<UInputModifierNegate>(NewObject(Context, UInputModifierNegate::StaticClass(), n"TestSource.Mapping.AddNegate", true));
		UInputModifierScalar Scalar = Cast<UInputModifierScalar>(NewObject(Context, UInputModifierScalar::StaticClass(), n"TestSource.Mapping.AddScalar", true));
		if (Negate is null || Scalar is null)
		{
			throw("TS_UInputMappingContext_MutationAndLifecycle_01 setup: required Modifier is null");
		}
		Mapping.AddModifier(Negate);
		int32 AfterFirst = Mapping.GetModifierCount();
		Mapping.AddModifier(Negate);
		int32 AfterRepeat = Mapping.GetModifierCount();
		Mapping.AddModifier(Scalar);
		int32 AfterSecond = Mapping.GetModifierCount();
		UInputModifier NullModifier = nullptr;
		Mapping.AddModifier(NullModifier);
		int32 AfterNull = Mapping.GetModifierCount();
		return AfterFirst == 1 && AfterRepeat == 2 && AfterSecond == 3 && AfterNull == 3;
	}

	bool Observe_ClearModifiers_Nominal()
	{
		UInputAction Action = Cast<UInputAction>(NewObject(GetTransientPackage(), UInputAction::StaticClass(), n"TestSource.Mapping.ClearModifiers", true));
		UInputMappingContext Context = Cast<UInputMappingContext>(NewObject(GetTransientPackage(), UInputMappingContext::StaticClass(), n"TestSource.Mapping.ClearModifiersContext", true));
		if (Action is null)
		{
			throw("TS_UInputMappingContext_MutationAndLifecycle_01 setup: required Action is null");
		}
		if (Context is null)
		{
			throw("TS_UInputMappingContext_MutationAndLifecycle_01 setup: required Context is null");
		}
		FEnhancedActionKeyMapping& Mapping = Context.MapKey(Action, EKeys::SpaceBar);
		UInputModifierNegate Negate = Cast<UInputModifierNegate>(NewObject(Context, UInputModifierNegate::StaticClass(), n"TestSource.Mapping.ClearNegate", true));
		if (Negate is null)
		{
			throw("TS_UInputMappingContext_MutationAndLifecycle_01 setup: required Modifier is null");
		}
		Mapping.AddModifier(Negate);
		Mapping.ClearModifiers();
		int32 AfterClear = Mapping.GetModifierCount();
		Mapping.ClearModifiers();
		int32 AfterRepeat = Mapping.GetModifierCount();
		return AfterClear == 0 && AfterRepeat == 0;
	}

	bool Observe_AddTrigger_Nominal()
	{
		UInputAction Action = Cast<UInputAction>(NewObject(GetTransientPackage(), UInputAction::StaticClass(), n"TestSource.Mapping.AddTrigger", true));
		UInputMappingContext Context = Cast<UInputMappingContext>(NewObject(GetTransientPackage(), UInputMappingContext::StaticClass(), n"TestSource.Mapping.AddTriggerContext", true));
		if (Action is null)
		{
			throw("TS_UInputMappingContext_MutationAndLifecycle_01 setup: required Action is null");
		}
		if (Context is null)
		{
			throw("TS_UInputMappingContext_MutationAndLifecycle_01 setup: required Context is null");
		}
		FEnhancedActionKeyMapping& Mapping = Context.MapKey(Action, EKeys::SpaceBar);
		UInputTriggerDown Down = Cast<UInputTriggerDown>(NewObject(Context, UInputTriggerDown::StaticClass(), n"TestSource.Mapping.AddDown", true));
		UInputTriggerPressed Pressed = Cast<UInputTriggerPressed>(NewObject(Context, UInputTriggerPressed::StaticClass(), n"TestSource.Mapping.AddPressed", true));
		if (Down is null || Pressed is null)
		{
			throw("TS_UInputMappingContext_MutationAndLifecycle_01 setup: required Trigger is null");
		}
		Mapping.AddTrigger(Down);
		int32 AfterFirst = Mapping.GetTriggerCount();
		Mapping.AddTrigger(Down);
		int32 AfterRepeat = Mapping.GetTriggerCount();
		Mapping.AddTrigger(Pressed);
		int32 AfterSecond = Mapping.GetTriggerCount();
		UInputTrigger NullTrigger = nullptr;
		Mapping.AddTrigger(NullTrigger);
		int32 AfterNull = Mapping.GetTriggerCount();
		return AfterFirst == 1 && AfterRepeat == 2 && AfterSecond == 3 && AfterNull == 3;
	}

	bool Observe_ClearTriggers_Nominal()
	{
		UInputAction Action = Cast<UInputAction>(NewObject(GetTransientPackage(), UInputAction::StaticClass(), n"TestSource.Mapping.ClearTriggers", true));
		UInputMappingContext Context = Cast<UInputMappingContext>(NewObject(GetTransientPackage(), UInputMappingContext::StaticClass(), n"TestSource.Mapping.ClearTriggersContext", true));
		if (Action is null)
		{
			throw("TS_UInputMappingContext_MutationAndLifecycle_01 setup: required Action is null");
		}
		if (Context is null)
		{
			throw("TS_UInputMappingContext_MutationAndLifecycle_01 setup: required Context is null");
		}
		FEnhancedActionKeyMapping& Mapping = Context.MapKey(Action, EKeys::SpaceBar);
		UInputTriggerDown Down = Cast<UInputTriggerDown>(NewObject(Context, UInputTriggerDown::StaticClass(), n"TestSource.Mapping.ClearDown", true));
		if (Down is null)
		{
			throw("TS_UInputMappingContext_MutationAndLifecycle_01 setup: required Trigger is null");
		}
		Mapping.AddTrigger(Down);
		Mapping.ClearTriggers();
		int32 AfterClear = Mapping.GetTriggerCount();
		Mapping.ClearTriggers();
		int32 AfterRepeat = Mapping.GetTriggerCount();
		return AfterClear == 0 && AfterRepeat == 0;
	}
}
