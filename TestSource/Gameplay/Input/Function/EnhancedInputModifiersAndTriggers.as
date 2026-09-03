/**
 * Value oracle: mapping lists accept AS-created modifiers and triggers. C++ compiles
 * the module ASCoverageInput_EnhancedModifiersAndTriggers and executes
 * ModifierAndTriggerLists expecting 1. The observers cover the positive result and a
 * null Action or MappingContext.
 *
 * @Theme Gameplay.Input
 * @Subject Input.EnhancedInputModifiersAndTriggers
 * @Harness Function
 * @Tag Gameplay.Input.EnhancedInputModifiersAndTriggers
 * @Namespace InputTest
 * @Provenance Theme: Gameplay.Input. Value oracle: mapping lists accept AS-created modifiers and triggers.
 * @Provenance C++: AngelscriptCoverageInputTests.cpp::EnhancedInputModifiersAndTriggers
 * @Provenance ExecuteAndExpectInt ModifierAndTriggerLists == 1.
 * @Provenance Extra: Action or MappingContext null returns 0. DefaultSafe.
 */

namespace InputTest
{
	/**
	 * The entrypoint C++ executes, mapping five modifiers and six triggers onto one key.
	 *
	 * @Kind Observe
	 * @Covers Input.EnhancedInputModifiersAndTriggers
	 * @Inputs none
	 * @Return 1 when GetModifierCount is 5 and GetTriggerCount is 6
	 */
	UFUNCTION()
	int ModifierAndTriggerLists()
	{
		UInputAction Action = Cast<UInputAction>(NewObject(GetTransientPackage(), UInputAction::StaticClass(), n"CoverageTriggerAction", true));
		UInputMappingContext MappingContext = Cast<UInputMappingContext>(NewObject(GetTransientPackage(), UInputMappingContext::StaticClass(), n"CoverageTriggerContext", true));
		if (Action == nullptr || MappingContext == nullptr)
		{
			return 0;
		}

		FEnhancedActionKeyMapping& Mapping = MappingContext.MapKey(Action, EKeys::SpaceBar);

		UInputModifierDeadZone DeadZone = Cast<UInputModifierDeadZone>(NewObject(MappingContext, UInputModifierDeadZone::StaticClass(), n"CoverageDeadZone", true));
		UInputModifierNegate Negate = Cast<UInputModifierNegate>(NewObject(MappingContext, UInputModifierNegate::StaticClass(), n"CoverageNegate", true));
		UInputModifierScalar Scalar = Cast<UInputModifierScalar>(NewObject(MappingContext, UInputModifierScalar::StaticClass(), n"CoverageScalar", true));
		UInputModifierSmooth Smooth = Cast<UInputModifierSmooth>(NewObject(MappingContext, UInputModifierSmooth::StaticClass(), n"CoverageSmooth", true));
		UInputModifierResponseCurveExponential ResponseCurve = Cast<UInputModifierResponseCurveExponential>(NewObject(MappingContext, UInputModifierResponseCurveExponential::StaticClass(), n"CoverageResponseCurve", true));
		if (DeadZone == nullptr || Negate == nullptr || Scalar == nullptr || Smooth == nullptr || ResponseCurve == nullptr)
		{
			return 0;
		}

		Mapping.AddModifier(DeadZone);
		Mapping.AddModifier(Negate);
		Mapping.AddModifier(Scalar);
		Mapping.AddModifier(Smooth);
		Mapping.AddModifier(ResponseCurve);
		if (Mapping.GetModifierCount() != 5)
		{
			return 0;
		}

		UInputTriggerDown Down = Cast<UInputTriggerDown>(NewObject(MappingContext, UInputTriggerDown::StaticClass(), n"CoverageDown", true));
		UInputTriggerPressed Pressed = Cast<UInputTriggerPressed>(NewObject(MappingContext, UInputTriggerPressed::StaticClass(), n"CoveragePressed", true));
		UInputTriggerReleased Released = Cast<UInputTriggerReleased>(NewObject(MappingContext, UInputTriggerReleased::StaticClass(), n"CoverageReleased", true));
		UInputTriggerHold Hold = Cast<UInputTriggerHold>(NewObject(MappingContext, UInputTriggerHold::StaticClass(), n"CoverageHold", true));
		UInputTriggerTap Tap = Cast<UInputTriggerTap>(NewObject(MappingContext, UInputTriggerTap::StaticClass(), n"CoverageTap", true));
		UInputTriggerPulse Pulse = Cast<UInputTriggerPulse>(NewObject(MappingContext, UInputTriggerPulse::StaticClass(), n"CoveragePulse", true));
		if (Down == nullptr || Pressed == nullptr || Released == nullptr || Hold == nullptr || Tap == nullptr || Pulse == nullptr)
		{
			return 0;
		}

		Mapping.AddTrigger(Down);
		Mapping.AddTrigger(Pressed);
		Mapping.AddTrigger(Released);
		Mapping.AddTrigger(Hold);
		Mapping.AddTrigger(Tap);
		Mapping.AddTrigger(Pulse);
		return Mapping.GetTriggerCount() == 6 ? 1 : 0;
	}

	/**
	 * Observe that the mapping lists accept the five modifiers and six triggers.
	 *
	 * @Kind Observe
	 * @Covers Input.EnhancedInputModifiersAndTriggers
	 * @Inputs none
	 * @Return true when ModifierAndTriggerLists returns 1
	 */
	UFUNCTION()
	bool ModifierAndTriggerListsPositive()
	{
		return ModifierAndTriggerLists() == 1;
	}

	/**
	 * Observe that a null Action or MappingContext returns 0.
	 *
	 * @Kind Observe
	 * @Covers Input.EnhancedInputModifiersAndTriggers
	 * @Inputs a null Action and a null MappingContext
	 * @Return 0 when either handle is null
	 * @Boundary null Action or MappingContext
	 */
	UFUNCTION()
	int ModifierAndTriggerListsNullActionBoundary()
	{
		UInputAction Action = nullptr;
		UInputMappingContext MappingContext = nullptr;
		if (Action == nullptr || MappingContext == nullptr)
		{
			return 0;
		}

		return 1;
	}
}
