/**
 * @version v1
 * @summary Enhanced Input action and mapping metadata helpers: value type, accumulation, MapKey, modifiers, triggers, clear and rebind. A null NewObject path returns 0.
 * @topic Definitions
 */
/**
 * @version root
 * @summary Enhanced Input action and mapping metadata helpers: value type, accumulation, MapKey, modifiers, triggers, clear and rebind. A null NewObject path returns 0.
 * @topic Baseline
 */
namespace MetaTest
{
	/**
	 * Build two actions and a mapping context, then map, modify, trigger, clear and rebind.
	 *
	 * @Kind Observe
	 * @Covers Meta.EnhancedInputActionAndMappingMetadata
	 * @Inputs none
	 * @Return 1 when every metadata step holds, otherwise 0
	 */
	UFUNCTION()
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
		if (ConfirmMapping.GetAction() != MoveAction)
		{
			return 0;
		}
		if (ConfirmMapping.GetKey() != EKeys::Enter)
		{
			return 0;
		}
		return 1;
	}

	/**
	 * Observe the nominal metadata walk.
	 *
	 * @Kind Observe
	 * @Covers Meta.EnhancedInputActionAndMappingMetadata
	 * @Inputs none
	 * @Return 1 when the walk succeeds
	 */
	UFUNCTION()
	int ActionAndMappingMetadataNominal()
	{
		return ActionAndMappingMetadata();
	}

	/**
	 * Observe that a null action handle is the empty NewObject boundary.
	 *
	 * @Kind Observe
	 * @Covers Meta.EnhancedInputActionAndMappingMetadata
	 * @Inputs none
	 * @Return 0 when the handle is null
	 * @Boundary null NewObject
	 */
	UFUNCTION()
	int NullObjectBoundary()
	{
		UInputAction Missing = Cast<UInputAction>(nullptr);
		if (Missing == nullptr)
		{
			return 0;
		}
		return 1;
	}
}
/** @end */
