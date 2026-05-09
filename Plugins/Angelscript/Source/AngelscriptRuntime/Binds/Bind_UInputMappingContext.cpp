#include "EnhancedActionKeyMapping.h"
#include "InputAction.h"
#include "InputMappingContext.h"
#include "InputModifiers.h"
#include "InputTriggers.h"

#include "AngelscriptBinds.h"

AS_FORCE_LINK const FAngelscriptBinds::FBind Bind_UInputAction_Late(FAngelscriptBinds::EOrder::Late, []
{
	auto UInputAction_ = FAngelscriptBinds::ExistingClass("UInputAction");

	UInputAction_.Method("void SetValueType(EInputActionValueType InValueType)", [](UInputAction* Action, EInputActionValueType InValueType)
	{
		if (Action != nullptr)
		{
			Action->ValueType = InValueType;
		}
	});
	UInputAction_.Method("EInputActionValueType GetValueType() const", [](const UInputAction* Action) -> EInputActionValueType
	{
		return Action != nullptr ? Action->ValueType : EInputActionValueType::Boolean;
	});

	UInputAction_.Method("void SetAccumulationBehavior(EInputActionAccumulationBehavior InBehavior)", [](UInputAction* Action, EInputActionAccumulationBehavior InBehavior)
	{
		if (Action != nullptr)
		{
			Action->AccumulationBehavior = InBehavior;
		}
	});
	UInputAction_.Method("EInputActionAccumulationBehavior GetAccumulationBehavior() const", [](const UInputAction* Action) -> EInputActionAccumulationBehavior
	{
		return Action != nullptr ? Action->AccumulationBehavior : EInputActionAccumulationBehavior::TakeHighestAbsoluteValue;
	});
});

AS_FORCE_LINK const FAngelscriptBinds::FBind Bind_FEnhancedActionKeyMapping_Late(FAngelscriptBinds::EOrder::Late, []
{
	auto FEnhancedActionKeyMapping_ = FAngelscriptBinds::ExistingClass("FEnhancedActionKeyMapping");

	FEnhancedActionKeyMapping_.Constructor("void f(const UInputAction InAction, FKey InKey)", [](FEnhancedActionKeyMapping* Address, const UInputAction* InAction, FKey InKey)
	{
		new(Address) FEnhancedActionKeyMapping(InAction, InKey);
	});
	SCRIPT_TRIVIAL_NATIVE_CONSTRUCTOR(FEnhancedActionKeyMapping_, "FEnhancedActionKeyMapping");

	FEnhancedActionKeyMapping_.Method("bool opEquals(const FEnhancedActionKeyMapping& Other) const", METHOD_TRIVIAL(FEnhancedActionKeyMapping, operator==));

	FEnhancedActionKeyMapping_.Method("const UInputAction GetAction() const", [](const FEnhancedActionKeyMapping* Mapping) -> const UInputAction*
	{
		return Mapping != nullptr ? Mapping->Action.Get() : nullptr;
	});
	FEnhancedActionKeyMapping_.Method("void SetAction(const UInputAction InAction)", [](FEnhancedActionKeyMapping* Mapping, const UInputAction* InAction)
	{
		if (Mapping != nullptr)
		{
			Mapping->Action = InAction;
		}
	});

	FEnhancedActionKeyMapping_.Method("FKey GetKey() const", [](const FEnhancedActionKeyMapping* Mapping) -> FKey
	{
		return Mapping != nullptr ? Mapping->Key : EKeys::Invalid;
	});
	FEnhancedActionKeyMapping_.Method("void SetKey(FKey InKey)", [](FEnhancedActionKeyMapping* Mapping, FKey InKey)
	{
		if (Mapping != nullptr)
		{
			Mapping->Key = InKey;
		}
	});

	FEnhancedActionKeyMapping_.Method("void AddModifier(UInputModifier Modifier)", [](FEnhancedActionKeyMapping* Mapping, UInputModifier* Modifier)
	{
		if (Mapping != nullptr && Modifier != nullptr)
		{
			Mapping->Modifiers.Add(Modifier);
		}
	});
	FEnhancedActionKeyMapping_.Method("void ClearModifiers()", [](FEnhancedActionKeyMapping* Mapping)
	{
		if (Mapping != nullptr)
		{
			Mapping->Modifiers.Reset();
		}
	});
	FEnhancedActionKeyMapping_.Method("int32 GetModifierCount() const", [](const FEnhancedActionKeyMapping* Mapping) -> int32
	{
		return Mapping != nullptr ? Mapping->Modifiers.Num() : 0;
	});

	FEnhancedActionKeyMapping_.Method("void AddTrigger(UInputTrigger Trigger)", [](FEnhancedActionKeyMapping* Mapping, UInputTrigger* Trigger)
	{
		if (Mapping != nullptr && Trigger != nullptr)
		{
			Mapping->Triggers.Add(Trigger);
		}
	});
	FEnhancedActionKeyMapping_.Method("void ClearTriggers()", [](FEnhancedActionKeyMapping* Mapping)
	{
		if (Mapping != nullptr)
		{
			Mapping->Triggers.Reset();
		}
	});
	FEnhancedActionKeyMapping_.Method("int32 GetTriggerCount() const", [](const FEnhancedActionKeyMapping* Mapping) -> int32
	{
		return Mapping != nullptr ? Mapping->Triggers.Num() : 0;
	});
});

AS_FORCE_LINK const FAngelscriptBinds::FBind Bind_UInputMappingContext_Late(FAngelscriptBinds::EOrder::Late, []
{
	auto UInputMappingContext_ = FAngelscriptBinds::ExistingClass("UInputMappingContext");

	UInputMappingContext_.Method("FEnhancedActionKeyMapping& MapKey(const UInputAction Action, FKey ToKey)", [](UInputMappingContext* Context, const UInputAction* Action, FKey ToKey) -> FEnhancedActionKeyMapping&
	{
		return Context->MapKey(Action, ToKey);
	});
	UInputMappingContext_.Method("void UnmapKey(const UInputAction Action, FKey Key)", METHODPR_TRIVIAL(void, UInputMappingContext, UnmapKey, (const UInputAction*, FKey)));
	UInputMappingContext_.Method("void UnmapAllKeysFromAction(const UInputAction Action)", METHODPR_TRIVIAL(void, UInputMappingContext, UnmapAllKeysFromAction, (const UInputAction*)));
	UInputMappingContext_.Method("void UnmapAll()", METHOD_TRIVIAL(UInputMappingContext, UnmapAll));
	UInputMappingContext_.Method("bool HasMappingForInputAction(const UInputAction Action) const", METHODPR_TRIVIAL(bool, UInputMappingContext, HasMappingForInputAction, (const UInputAction*) const));
	UInputMappingContext_.Method("int32 GetMappingCount() const", [](const UInputMappingContext* Context) -> int32
	{
		return Context != nullptr ? Context->GetMappings().Num() : 0;
	});
	UInputMappingContext_.Method("FEnhancedActionKeyMapping& GetMapping(int32 Index)", [](UInputMappingContext* Context, int32 Index) -> FEnhancedActionKeyMapping&
	{
		return Context->GetMapping(Index);
	});
});
