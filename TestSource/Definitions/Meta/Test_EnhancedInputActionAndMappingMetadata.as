// Theme: Definitions.Meta. Positive: Enhanced Input action/mapping metadata helpers.
// C++: AngelscriptCoverageInputTests.cpp::EnhancedInputActionAndMappingMetadata
// Oracle: ActionAndMappingMetadata() == 1 after MapKey, modifiers, triggers, then clear and rebind.
// Extra: null NewObject path returns 0. DefaultSafe. Source owns locals.

int ActionAndMappingMetadata()
{
	UInputAction MoveAction = Cast<UInputAction>(NewObject(GetTransientPackage(), UInputAction::StaticClass(), n"CoverageMetadataMoveAction", true));
	UInputAction ConfirmAction = Cast<UInputAction>(NewObject(GetTransientPackage(), UInputAction::StaticClass(), n"CoverageMetadataConfirmAction", true));
	UInputMappingContext MappingContext = Cast<UInputMappingContext>(NewObject(GetTransientPackage(), UInputMappingContext::StaticClass(), n"CoverageMetadataContext", true));
	if (MoveAction == nullptr || ConfirmAction == nullptr || MappingContext == nullptr)
	{
		return 0;
	}

	MoveAction.SetValueType(EInputActionValueType::Axis2D);
	MoveAction.SetAccumulationBehavior(EInputActionAccumulationBehavior::Cumulative);
	ConfirmAction.SetValueType(EInputActionValueType::Boolean);
	ConfirmAction.SetAccumulationBehavior(EInputActionAccumulationBehavior::TakeHighestAbsoluteValue);
	if (MoveAction.GetValueType() != EInputActionValueType::Axis2D)
	{
		return 0;
	}
	if (MoveAction.GetAccumulationBehavior() != EInputActionAccumulationBehavior::Cumulative)
	{
		return 0;
	}
	if (ConfirmAction.GetValueType() != EInputActionValueType::Boolean)
	{
		return 0;
	}

	FEnhancedActionKeyMapping& MoveMapping = MappingContext.MapKey(MoveAction, EKeys::Gamepad_Left2D);
	FEnhancedActionKeyMapping& ConfirmMapping = MappingContext.MapKey(ConfirmAction, EKeys::Gamepad_FaceButton_Bottom);
	if (MappingContext.GetMappingCount() != 2)
	{
		return 0;
	}

	UInputModifierNegate Negate = Cast<UInputModifierNegate>(NewObject(MappingContext, UInputModifierNegate::StaticClass(), n"CoverageMetadataNegate", true));
	UInputModifierScalar Scalar = Cast<UInputModifierScalar>(NewObject(MappingContext, UInputModifierScalar::StaticClass(), n"CoverageMetadataScalar", true));
	UInputTriggerCombo Combo = Cast<UInputTriggerCombo>(NewObject(MappingContext, UInputTriggerCombo::StaticClass(), n"CoverageMetadataCombo", true));
	UInputTriggerDown Down = Cast<UInputTriggerDown>(NewObject(MappingContext, UInputTriggerDown::StaticClass(), n"CoverageMetadataDown", true));
	if (Negate == nullptr || Scalar == nullptr || Combo == nullptr || Down == nullptr)
	{
		return 0;
	}

	MoveMapping.AddModifier(Negate);
	MoveMapping.AddModifier(Scalar);
	ConfirmMapping.AddTrigger(Combo);
	ConfirmMapping.AddTrigger(Down);
	if (MoveMapping.GetModifierCount() != 2 || ConfirmMapping.GetTriggerCount() != 2)
	{
		return 0;
	}

	MoveMapping.ClearModifiers();
	ConfirmMapping.ClearTriggers();
	if (MoveMapping.GetModifierCount() != 0 || ConfirmMapping.GetTriggerCount() != 0)
	{
		return 0;
	}

	ConfirmMapping.SetAction(MoveAction);
	ConfirmMapping.SetKey(EKeys::Enter);
	return ConfirmMapping.GetAction() == MoveAction && ConfirmMapping.GetKey() == EKeys::Enter ? 1 : 0;
}

int Observe_ActionAndMappingMetadata_Nominal()
{
	return ActionAndMappingMetadata();
}

int Observe_ActionAndMappingMetadata_NullObjectBoundary()
{
	UInputAction Missing = Cast<UInputAction>(nullptr);
	return Missing == nullptr ? 0 : 1;
}
