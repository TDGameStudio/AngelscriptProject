// Theme: Gameplay.Input. Isolated compile-fail: ModifyRaw and UpdateState stay explicit boundaries.
// C++: AngelscriptCoverageInputTests.cpp::EnhancedInputAndDeviceBoundaryInventory
// CSV Positive; C++ CompileAndExpectFailure (empty diagnostic list).
// Do not drop Modifier.ModifyRaw or Trigger.UpdateState.

int ModifierAndTriggerApplicationBoundary()
{
	UInputModifierNegate Modifier;
	UInputTriggerDown Trigger;
	FInputActionValue Value;
	Modifier.ModifyRaw(Value, 0.016f);
	Trigger.UpdateState(Value, 0.016f);
	return 1;
}
