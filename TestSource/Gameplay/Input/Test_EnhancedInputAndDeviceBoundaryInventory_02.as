// Theme: Gameplay.Input. Value oracle: UInputTriggerChordAction preserves ChordAction.
// C++: AngelscriptCoverageInputTests.cpp::EnhancedInputAndDeviceBoundaryInventory
// ExecuteAndExpectInt ChordActionTriggerIsExposed == 1.
// Extra: Action or Trigger null returns 0. DefaultSafe.

int ChordActionTriggerIsExposed()
{
	UInputAction Action = Cast<UInputAction>(NewObject(GetTransientPackage(), UInputAction::StaticClass(), n"CoverageChordAction", true));
	UInputTriggerChordAction Trigger = Cast<UInputTriggerChordAction>(NewObject(GetTransientPackage(), UInputTriggerChordAction::StaticClass(), n"CoverageChordTrigger", true));
	if (Action == nullptr || Trigger == nullptr)
		return 0;

	Trigger.ChordAction = Action;
	return Trigger.ChordAction == Action ? 1 : 0;
}

bool Observe_ChordActionTriggerIsExposed_Nominal()
{
	return ChordActionTriggerIsExposed() == 1;
}

int Observe_ChordActionTriggerIsExposed_NullBoundary()
{
	UInputAction Action = nullptr;
	UInputTriggerChordAction Trigger = nullptr;
	if (Action == nullptr || Trigger == nullptr)
		return 0;

	return 1;
}
