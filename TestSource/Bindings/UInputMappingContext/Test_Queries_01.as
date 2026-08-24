// Purpose: Observe input-action metadata, mapping field queries, mapping-count
// lookups, and GetMapping aliasing.
// AS-facing API: EInputActionValueType UInputAction.GetValueType() const;
// EInputActionAccumulationBehavior UInputAction.GetAccumulationBehavior() const;
// const UInputAction Mapping.GetAction() const; FKey Mapping.GetKey() const;
// int32 Mapping.GetModifierCount() const; int32 Mapping.GetTriggerCount() const;
// bool UInputMappingContext.HasMappingForInputAction(const UInputAction Action) const;
// int32 UInputMappingContext.GetMappingCount() const;
// FEnhancedActionKeyMapping& UInputMappingContext.GetMapping(int32 Index);
// Inputs: Default UInputAction metadata, Axis2D + Cumulative after setters, a
// mapped EKeys::W entry, empty context count 0, Index 0 as first valid, a second
// mapping as last valid, a null action lookup, and GetMapping alias mutation.
// Expected observations: Default value type is Boolean. After SetValueType it is
// Axis2D. Empty mapping count is 0. HasMappingForInputAction is true only for
// the mapped action. GetMapping(0) aliases the context so SetKey is visible on
// a later GetMapping(0).
// Boundary/ownership: GetMapping returns a reference into the context. Invalid
// indices follow the native TArray bounds policy. Null NewObject results are
// setup failure.

namespace TS_UInputMappingContext_Queries_01
{
	bool Observe_GetValueType_Nominal()
	{
		UInputAction Action = Cast<UInputAction>(NewObject(GetTransientPackage(), UInputAction::StaticClass(), n"TestSource.Mapping.ValueType", true));
		if (Action is null)
		{
			throw("TS_UInputMappingContext_Queries_01 setup: required Action is null");
		}
		EInputActionValueType DefaultType = Action.GetValueType();
		Action.SetValueType(EInputActionValueType::Axis2D);
		EInputActionValueType AxisType = Action.GetValueType();
		Action.SetValueType(EInputActionValueType::Boolean);
		EInputActionValueType BooleanType = Action.GetValueType();
		return DefaultType == EInputActionValueType::Boolean &&
			AxisType == EInputActionValueType::Axis2D &&
			BooleanType == EInputActionValueType::Boolean;
	}

	bool Observe_GetAccumulationBehavior_Nominal()
	{
		UInputAction Action = Cast<UInputAction>(NewObject(GetTransientPackage(), UInputAction::StaticClass(), n"TestSource.Mapping.Accumulation", true));
		if (Action is null)
		{
			throw("TS_UInputMappingContext_Queries_01 setup: required Action is null");
		}
		EInputActionAccumulationBehavior DefaultBehavior = Action.GetAccumulationBehavior();
		Action.SetAccumulationBehavior(EInputActionAccumulationBehavior::Cumulative);
		EInputActionAccumulationBehavior Cumulative = Action.GetAccumulationBehavior();
		Action.SetAccumulationBehavior(EInputActionAccumulationBehavior::TakeHighestAbsoluteValue);
		EInputActionAccumulationBehavior Highest = Action.GetAccumulationBehavior();
		return DefaultBehavior == EInputActionAccumulationBehavior::TakeHighestAbsoluteValue &&
			Cumulative == EInputActionAccumulationBehavior::Cumulative &&
			Highest == EInputActionAccumulationBehavior::TakeHighestAbsoluteValue;
	}

	bool Observe_GetAction_Nominal()
	{
		UInputAction Action = Cast<UInputAction>(NewObject(GetTransientPackage(), UInputAction::StaticClass(), n"TestSource.Mapping.GetAction", true));
		if (Action is null)
		{
			throw("TS_UInputMappingContext_Queries_01 setup: required Action is null");
		}
		FEnhancedActionKeyMapping Mapping(Action, EKeys::W);
		FEnhancedActionKeyMapping Empty;
		return Mapping.GetAction() == Action && Empty.GetAction() is null;
	}

	bool Observe_GetKey_Nominal()
	{
		UInputAction Action = Cast<UInputAction>(NewObject(GetTransientPackage(), UInputAction::StaticClass(), n"TestSource.Mapping.GetKey", true));
		if (Action is null)
		{
			throw("TS_UInputMappingContext_Queries_01 setup: required Action is null");
		}
		FEnhancedActionKeyMapping Mapping(Action, EKeys::W);
		FEnhancedActionKeyMapping Empty;
		return Mapping.GetKey() == EKeys::W && !Empty.GetKey().IsValid();
	}

	bool Observe_GetModifierCount_Nominal()
	{
		UInputAction Action = Cast<UInputAction>(NewObject(GetTransientPackage(), UInputAction::StaticClass(), n"TestSource.Mapping.ModifierCount", true));
		UInputMappingContext Context = Cast<UInputMappingContext>(NewObject(GetTransientPackage(), UInputMappingContext::StaticClass(), n"TestSource.Mapping.ModifierCountContext", true));
		if (Action is null)
		{
			throw("TS_UInputMappingContext_Queries_01 setup: required Action is null");
		}
		if (Context is null)
		{
			throw("TS_UInputMappingContext_Queries_01 setup: required Context is null");
		}
		FEnhancedActionKeyMapping& Mapping = Context.MapKey(Action, EKeys::SpaceBar);
		int32 EmptyCount = Mapping.GetModifierCount();
		UInputModifierNegate Negate = Cast<UInputModifierNegate>(NewObject(Context, UInputModifierNegate::StaticClass(), n"TestSource.Mapping.Negate", true));
		if (Negate is null)
		{
			throw("TS_UInputMappingContext_Queries_01 setup: required Modifier is null");
		}
		Mapping.AddModifier(Negate);
		int32 PopulatedCount = Mapping.GetModifierCount();
		return EmptyCount == 0 && PopulatedCount == 1;
	}

	bool Observe_GetTriggerCount_Nominal()
	{
		UInputAction Action = Cast<UInputAction>(NewObject(GetTransientPackage(), UInputAction::StaticClass(), n"TestSource.Mapping.TriggerCount", true));
		UInputMappingContext Context = Cast<UInputMappingContext>(NewObject(GetTransientPackage(), UInputMappingContext::StaticClass(), n"TestSource.Mapping.TriggerCountContext", true));
		if (Action is null)
		{
			throw("TS_UInputMappingContext_Queries_01 setup: required Action is null");
		}
		if (Context is null)
		{
			throw("TS_UInputMappingContext_Queries_01 setup: required Context is null");
		}
		FEnhancedActionKeyMapping& Mapping = Context.MapKey(Action, EKeys::SpaceBar);
		int32 EmptyCount = Mapping.GetTriggerCount();
		UInputTriggerDown Down = Cast<UInputTriggerDown>(NewObject(Context, UInputTriggerDown::StaticClass(), n"TestSource.Mapping.Down", true));
		if (Down is null)
		{
			throw("TS_UInputMappingContext_Queries_01 setup: required Trigger is null");
		}
		Mapping.AddTrigger(Down);
		int32 PopulatedCount = Mapping.GetTriggerCount();
		return EmptyCount == 0 && PopulatedCount == 1;
	}

	bool Observe_HasMappingForInputAction_Nominal()
	{
		UInputAction Action = Cast<UInputAction>(NewObject(GetTransientPackage(), UInputAction::StaticClass(), n"TestSource.Mapping.HasMapping", true));
		UInputAction Other = Cast<UInputAction>(NewObject(GetTransientPackage(), UInputAction::StaticClass(), n"TestSource.Mapping.HasMappingOther", true));
		UInputMappingContext Context = Cast<UInputMappingContext>(NewObject(GetTransientPackage(), UInputMappingContext::StaticClass(), n"TestSource.Mapping.HasMappingContext", true));
		if (Action is null || Other is null)
		{
			throw("TS_UInputMappingContext_Queries_01 setup: required Action is null");
		}
		if (Context is null)
		{
			throw("TS_UInputMappingContext_Queries_01 setup: required Context is null");
		}
		UInputAction NullAction = nullptr;
		bool bEmpty = Context.HasMappingForInputAction(Action);
		bool bNull = Context.HasMappingForInputAction(NullAction);
		Context.MapKey(Action, EKeys::W);
		bool bMapped = Context.HasMappingForInputAction(Action);
		bool bOther = Context.HasMappingForInputAction(Other);
		return !bEmpty && !bNull && bMapped && !bOther;
	}

	bool Observe_GetMappingCount_Nominal()
	{
		UInputAction Action = Cast<UInputAction>(NewObject(GetTransientPackage(), UInputAction::StaticClass(), n"TestSource.Mapping.Count", true));
		UInputMappingContext Context = Cast<UInputMappingContext>(NewObject(GetTransientPackage(), UInputMappingContext::StaticClass(), n"TestSource.Mapping.CountContext", true));
		if (Action is null)
		{
			throw("TS_UInputMappingContext_Queries_01 setup: required Action is null");
		}
		if (Context is null)
		{
			throw("TS_UInputMappingContext_Queries_01 setup: required Context is null");
		}
		int32 EmptyCount = Context.GetMappingCount();
		Context.MapKey(Action, EKeys::W);
		int32 FirstCount = Context.GetMappingCount();
		Context.MapKey(Action, EKeys::S);
		int32 LastCount = Context.GetMappingCount();
		return EmptyCount == 0 && FirstCount == 1 && LastCount == 2;
	}

	bool Observe_GetMapping_Nominal()
	{
		UInputAction Action = Cast<UInputAction>(NewObject(GetTransientPackage(), UInputAction::StaticClass(), n"TestSource.Mapping.GetMapping", true));
		UInputMappingContext Context = Cast<UInputMappingContext>(NewObject(GetTransientPackage(), UInputMappingContext::StaticClass(), n"TestSource.Mapping.GetMappingContext", true));
		if (Action is null)
		{
			throw("TS_UInputMappingContext_Queries_01 setup: required Action is null");
		}
		if (Context is null)
		{
			throw("TS_UInputMappingContext_Queries_01 setup: required Context is null");
		}
		Context.MapKey(Action, EKeys::W);
		Context.MapKey(Action, EKeys::S);
		FEnhancedActionKeyMapping& First = Context.GetMapping(0);
		FKey FirstKey = First.GetKey();
		First.SetKey(EKeys::A);
		FEnhancedActionKeyMapping& Alias = Context.GetMapping(0);
		FKey AliasKey = Alias.GetKey();
		FEnhancedActionKeyMapping& Last = Context.GetMapping(1);
		FKey LastKey = Last.GetKey();
		return FirstKey == EKeys::W && AliasKey == EKeys::A && LastKey == EKeys::S;
	}

	void ExerciseExpectedFailure()
	{
		UInputMappingContext Context = Cast<UInputMappingContext>(NewObject(GetTransientPackage(), UInputMappingContext::StaticClass(), n"TestSource.Mapping.InvalidIndex", true));
		FEnhancedActionKeyMapping& Invalid = Context.GetMapping(0);
		FKey InvalidKey = Invalid.GetKey();
	}
}
