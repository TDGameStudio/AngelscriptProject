/**
 * @version v1
 * @summary Isolated compile-fail: SetInputMode + FInputModeGameOnly is not script-facing. C++ compiles this as the module ASCoverageInput_InputModeSwitchingUnsupported and expects a diagnostic naming FInputModeGameOnly. Do not drop.
 * @topic Gameplay
 */
/**
 * @version root
 * @summary Isolated compile-fail: SetInputMode + FInputModeGameOnly is not script-facing. C++ compiles this as the module ASCoverageInput_InputModeSwitchingUnsupported and expects a diagnostic naming FInputModeGameOnly. Do not drop.
 * @topic Negative
 */
UCLASS()
class AInputModeSwitchingBoundaryController : APlayerController
{
	/**
	 * The isolated failing program: FInputModeGameOnly and SetInputMode are not script-facing.
	 *
	 * @Kind CompileReject
	 * @Covers Input.InputModeSwitchingUnsupported
	 * @Inputs none
	 * @Return does not compile; FInputModeGameOnly stays an explicit binding boundary
	 */
	UFUNCTION()
	void TryGameOnlyInputMode()
	{
		FInputModeGameOnly GameOnlyMode;
		SetInputMode(GameOnlyMode);
	}
}
/** @end */
