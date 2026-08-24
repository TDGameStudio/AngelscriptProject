// Purpose: Observe mapping construction plus MapKey/UnmapKey/UnmapAll mutation
// of a mapping context.
// AS-facing API: FEnhancedActionKeyMapping Mapping(const UInputAction InAction, FKey InKey);
// FEnhancedActionKeyMapping& UInputMappingContext.MapKey(const UInputAction Action, FKey ToKey);
// void UInputMappingContext.UnmapKey(const UInputAction Action, FKey Key);
// void UInputMappingContext.UnmapAllKeysFromAction(const UInputAction Action);
// void UInputMappingContext.UnmapAll();
// Inputs: One move action and one confirm action, EKeys::W/S/Enter, an empty
// context, MapKey alias mutation via SetKey, UnmapKey of a missing key, and
// UnmapAll on an already empty context.
// Expected observations: Constructed mappings preserve action and key. MapKey
// increases GetMappingCount and returns an alias. UnmapKey removes one
// action/key pair. UnmapAllKeysFromAction removes every mapping for that
// action. UnmapAll leaves count 0.
// Boundary/ownership: MapKey returns a reference into the context. Unmap
// helpers do not destroy the action assets. Null NewObject results are setup
// failure.

namespace TS_UInputMappingContext_Behavior_01
{
	bool Observe_Mapping_Nominal()
	{
		UInputAction Action = Cast<UInputAction>(NewObject(GetTransientPackage(), UInputAction::StaticClass(), n"TestSource.Mapping.Construct", true));
		if (Action is null)
		{
			throw("TS_UInputMappingContext_Behavior_01 setup: required Action is null");
		}
		FEnhancedActionKeyMapping Mapping(Action, EKeys::W);
		UInputAction NullAction = nullptr;
		FEnhancedActionKeyMapping Empty(NullAction, EKeys::Invalid);
		return Mapping.GetAction() == Action &&
			Mapping.GetKey() == EKeys::W &&
			Empty.GetAction() is null &&
			!Empty.GetKey().IsValid();
	}

	bool Observe_MapKey_Nominal()
	{
		UInputAction Action = Cast<UInputAction>(NewObject(GetTransientPackage(), UInputAction::StaticClass(), n"TestSource.Mapping.MapKey", true));
		UInputMappingContext Context = Cast<UInputMappingContext>(NewObject(GetTransientPackage(), UInputMappingContext::StaticClass(), n"TestSource.Mapping.MapKeyContext", true));
		if (Action is null)
		{
			throw("TS_UInputMappingContext_Behavior_01 setup: required Action is null");
		}
		if (Context is null)
		{
			throw("TS_UInputMappingContext_Behavior_01 setup: required Context is null");
		}
		FEnhancedActionKeyMapping& Mapped = Context.MapKey(Action, EKeys::W);
		int32 AfterFirst = Context.GetMappingCount();
		UInputAction MappedAction = Mapped.GetAction();
		FKey MappedKey = Mapped.GetKey();
		Mapped.SetKey(EKeys::A);
		FEnhancedActionKeyMapping& Alias = Context.GetMapping(0);
		FKey AliasKey = Alias.GetKey();
		Context.MapKey(Action, EKeys::S);
		int32 AfterSecond = Context.GetMappingCount();
		return AfterFirst == 1 &&
			MappedAction == Action &&
			MappedKey == EKeys::W &&
			AliasKey == EKeys::A &&
			AfterSecond == 2;
	}

	bool Observe_UnmapKey_Nominal()
	{
		UInputAction Action = Cast<UInputAction>(NewObject(GetTransientPackage(), UInputAction::StaticClass(), n"TestSource.Mapping.UnmapKey", true));
		UInputMappingContext Context = Cast<UInputMappingContext>(NewObject(GetTransientPackage(), UInputMappingContext::StaticClass(), n"TestSource.Mapping.UnmapKeyContext", true));
		if (Action is null)
		{
			throw("TS_UInputMappingContext_Behavior_01 setup: required Action is null");
		}
		if (Context is null)
		{
			throw("TS_UInputMappingContext_Behavior_01 setup: required Context is null");
		}
		Context.MapKey(Action, EKeys::W);
		Context.MapKey(Action, EKeys::S);
		Context.UnmapKey(Action, EKeys::W);
		int32 AfterUnmap = Context.GetMappingCount();
		Context.UnmapKey(Action, EKeys::W);
		int32 AfterMissing = Context.GetMappingCount();
		return AfterUnmap == 1 && AfterMissing == 1;
	}

	bool Observe_UnmapAllKeysFromAction_Nominal()
	{
		UInputAction Move = Cast<UInputAction>(NewObject(GetTransientPackage(), UInputAction::StaticClass(), n"TestSource.Mapping.UnmapActionMove", true));
		UInputAction Confirm = Cast<UInputAction>(NewObject(GetTransientPackage(), UInputAction::StaticClass(), n"TestSource.Mapping.UnmapActionConfirm", true));
		UInputMappingContext Context = Cast<UInputMappingContext>(NewObject(GetTransientPackage(), UInputMappingContext::StaticClass(), n"TestSource.Mapping.UnmapActionContext", true));
		if (Move is null || Confirm is null)
		{
			throw("TS_UInputMappingContext_Behavior_01 setup: required Action is null");
		}
		if (Context is null)
		{
			throw("TS_UInputMappingContext_Behavior_01 setup: required Context is null");
		}
		Context.MapKey(Move, EKeys::W);
		Context.MapKey(Move, EKeys::S);
		Context.MapKey(Confirm, EKeys::Enter);
		Context.UnmapAllKeysFromAction(Move);
		int32 AfterMove = Context.GetMappingCount();
		bool bConfirmRemains = Context.HasMappingForInputAction(Confirm);
		Context.UnmapAllKeysFromAction(Move);
		int32 AfterRepeat = Context.GetMappingCount();
		return AfterMove == 1 && bConfirmRemains && AfterRepeat == 1;
	}

	bool Observe_UnmapAll_Nominal()
	{
		UInputAction Action = Cast<UInputAction>(NewObject(GetTransientPackage(), UInputAction::StaticClass(), n"TestSource.Mapping.UnmapAll", true));
		UInputMappingContext Context = Cast<UInputMappingContext>(NewObject(GetTransientPackage(), UInputMappingContext::StaticClass(), n"TestSource.Mapping.UnmapAllContext", true));
		if (Action is null)
		{
			throw("TS_UInputMappingContext_Behavior_01 setup: required Action is null");
		}
		if (Context is null)
		{
			throw("TS_UInputMappingContext_Behavior_01 setup: required Context is null");
		}
		Context.MapKey(Action, EKeys::W);
		Context.MapKey(Action, EKeys::S);
		Context.UnmapAll();
		int32 AfterClear = Context.GetMappingCount();
		Context.UnmapAll();
		int32 AfterRepeat = Context.GetMappingCount();
		return AfterClear == 0 && AfterRepeat == 0;
	}
}
