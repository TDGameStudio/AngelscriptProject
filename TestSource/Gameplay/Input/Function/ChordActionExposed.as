/**
 * Value oracle: UInputTriggerChordAction preserves ChordAction. C++ compiles the
 * module ASCoverageInput_ChordActionExposed and executes ChordActionTriggerIsExposed
 * expecting 1. The observers cover the positive result and a null Action or Trigger.
 *
 * @Theme Gameplay.Input
 * @Subject Input.ChordActionExposed
 * @Harness Function
 * @Tag Gameplay.Input.ChordActionExposed
 * @Namespace InputTest
 * @Provenance Theme: Gameplay.Input. Value oracle: UInputTriggerChordAction preserves ChordAction.
 * @Provenance C++: AngelscriptCoverageInputTests.cpp::EnhancedInputAndDeviceBoundaryInventory
 * @Provenance ExecuteAndExpectInt ChordActionTriggerIsExposed == 1.
 * @Provenance Extra: Action or Trigger null returns 0. DefaultSafe.
 */

namespace InputTest
{
	/**
	 * The entrypoint C++ executes, assigning a chord action onto a trigger.
	 *
	 * @Kind Observe
	 * @Covers Input.ChordActionExposed
	 * @Inputs none
	 * @Return 1 when Trigger.ChordAction still reads as the assigned Action
	 */
	UFUNCTION()
	int ChordActionTriggerIsExposed()
	{
		UInputAction Action = Cast<UInputAction>(NewObject(GetTransientPackage(), UInputAction::StaticClass(), n"CoverageChordAction", true));
		UInputTriggerChordAction Trigger = Cast<UInputTriggerChordAction>(NewObject(GetTransientPackage(), UInputTriggerChordAction::StaticClass(), n"CoverageChordTrigger", true));
		if (Action == nullptr || Trigger == nullptr)
		{
			return 0;
		}

		Trigger.ChordAction = Action;
		return Trigger.ChordAction == Action ? 1 : 0;
	}

	/**
	 * Observe that the assigned chord action is preserved.
	 *
	 * @Kind Observe
	 * @Covers Input.ChordActionExposed
	 * @Inputs none
	 * @Return true when ChordActionTriggerIsExposed returns 1
	 */
	UFUNCTION()
	bool ChordActionTriggerIsExposedPositive()
	{
		return ChordActionTriggerIsExposed() == 1;
	}

	/**
	 * Observe that a null Action or Trigger returns 0.
	 *
	 * @Kind Observe
	 * @Covers Input.ChordActionExposed
	 * @Inputs a null Action and a null Trigger
	 * @Return 0 when either handle is null
	 * @Boundary null Action or Trigger
	 */
	UFUNCTION()
	int ChordActionTriggerIsExposedNullBoundary()
	{
		UInputAction Action = nullptr;
		UInputTriggerChordAction Trigger = nullptr;
		if (Action == nullptr || Trigger == nullptr)
		{
			return 0;
		}

		return 1;
	}
}
