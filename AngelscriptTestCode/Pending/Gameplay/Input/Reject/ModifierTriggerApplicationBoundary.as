/**
 * @version v1
 * @summary Isolated compile-fail: ModifyRaw and UpdateState stay explicit boundaries. C++ compiles this as the module ASCoverageInput_ModifierTriggerApplicationBoundary and expects failure. The CSV Positive label is wrong; C++ does.
 * @topic Gameplay
 */
/**
 * @version root
 * @summary Isolated compile-fail: ModifyRaw and UpdateState stay explicit boundaries. C++ compiles this as the module ASCoverageInput_ModifierTriggerApplicationBoundary and expects failure. The CSV Positive label is wrong; C++ does.
 * @topic Negative
 */
/**
 * The isolated failing program: ModifyRaw and UpdateState have no script-facing signatures.
 *
 * @Kind CompileReject
 * @Covers Input.ModifierTriggerApplicationBoundary
 * @Inputs none
 * @Return does not compile; ModifyRaw and UpdateState stay explicit boundaries
 */
int ModifierAndTriggerApplicationBoundary()
{
	UInputModifierNegate Modifier;
	UInputTriggerDown Trigger;
	FInputActionValue Value;
	Modifier.ModifyRaw(Value, 0.016f);
	Trigger.UpdateState(Value, 0.016f);
	return 1;
}
/** @end */
