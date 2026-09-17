/**
 * @version v1
 * @summary Isolated compile-fail: Force Feedback and Haptic APIs stay boundaries. C++ compiles this as the module ASCoverageInput_ForceFeedbackBoundary and expects failure. The CSV Positive label is wrong; C++ does not compile.
 * @topic Gameplay
 */
/**
 * @version root
 * @summary Isolated compile-fail: Force Feedback and Haptic APIs stay boundaries. C++ compiles this as the module ASCoverageInput_ForceFeedbackBoundary and expects failure. The CSV Positive label is wrong; C++ does not compile.
 * @topic Negative
 */
UCLASS()
class AForceFeedbackBoundary : APlayerController
{
	/**
	 * The isolated failing program: ClientPlayForceFeedback and SetHapticsByValue have no script-facing signatures.
	 *
	 * @Kind CompileReject
	 * @Covers Input.ForceFeedbackBoundary
	 * @Inputs none
	 * @Return does not compile; ClientPlayForceFeedback and SetHapticsByValue stay explicit boundaries
	 */
	UFUNCTION()
	void PlayFeedback()
	{
		ClientPlayForceFeedback(nullptr);
		SetHapticsByValue(0.5f, 0.5f, 0.5f, 0.5f);
	}
}
/** @end */
