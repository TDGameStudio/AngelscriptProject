/**
 * @version v1
 * @summary Isolated compile-fail: SetInputMode + FInputModeUIOnly is not script-facing. C++ compiles this as the module ASCoverageInput_UIOnlyInputModeUnsupported and expects a diagnostic naming FInputModeUIOnly. Do not drop.
 * @topic Gameplay
 */
/**
 * @version root
 * @summary Isolated compile-fail: SetInputMode + FInputModeUIOnly is not script-facing. C++ compiles this as the module ASCoverageInput_UIOnlyInputModeUnsupported and expects a diagnostic naming FInputModeUIOnly. Do not drop.
 * @topic Negative
 */
UCLASS()
class AInputModeUIOnlyBoundaryController : APlayerController
{
	/**
	 * The isolated failing program: FInputModeUIOnly and SetInputMode are not script-facing.
	 *
	 * @Kind CompileReject
	 * @Covers Input.UIOnlyInputModeUnsupported
	 * @Inputs none
	 * @Return does not compile; FInputModeUIOnly stays an explicit binding boundary
	 */
	UFUNCTION()
	void TryUIOnlyInputMode()
	{
		FInputModeUIOnly UIOnlyMode;
		SetInputMode(UIOnlyMode);
	}
}
/** @end */
