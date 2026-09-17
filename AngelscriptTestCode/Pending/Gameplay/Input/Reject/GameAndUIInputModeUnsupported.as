/**
 * @version v1
 * @summary Isolated compile-fail: SetInputMode + FInputModeGameAndUI is not script-facing. C++ compiles this as the module ASCoverageInput_GameAndUIInputModeUnsupported and expects a diagnostic naming FInputModeGameAndUI. Do not.
 * @topic Gameplay
 */
/**
 * @version root
 * @summary Isolated compile-fail: SetInputMode + FInputModeGameAndUI is not script-facing. C++ compiles this as the module ASCoverageInput_GameAndUIInputModeUnsupported and expects a diagnostic naming FInputModeGameAndUI. Do not.
 * @topic Negative
 */
UCLASS()
class AInputModeGameAndUIBoundaryController : APlayerController
{
	/**
	 * The isolated failing program: FInputModeGameAndUI and SetInputMode are not script-facing.
	 *
	 * @Kind CompileReject
	 * @Covers Input.GameAndUIInputModeUnsupported
	 * @Inputs none
	 * @Return does not compile; FInputModeGameAndUI stays an explicit binding boundary
	 */
	UFUNCTION()
	void TryGameAndUIInputMode()
	{
		FInputModeGameAndUI GameAndUIMode;
		SetInputMode(GameAndUIMode);
	}
}
/** @end */
