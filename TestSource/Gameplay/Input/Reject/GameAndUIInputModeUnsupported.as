/**
 * Isolated compile-fail: SetInputMode + FInputModeGameAndUI is not script-facing.
 * C++ compiles this as the module ASCoverageInput_GameAndUIInputModeUnsupported
 * and expects a diagnostic naming FInputModeGameAndUI. Do not drop SetInputMode.
 *
 * @Theme Gameplay.Input
 * @Subject Input.GameAndUIInputModeUnsupported
 * @Harness CompileReject
 * @Tag Gameplay.Input.GameAndUIInputModeUnsupported
 * @Provenance Theme: Gameplay.Input. Isolated compile-fail: SetInputMode + FInputModeGameAndUI is not script-facing.
 * @Provenance C++: AngelscriptCoverageInputTests.cpp::InputModeSwitchingUnsupportedBoundary
 * @Provenance CompileAndExpectFailure diagnostic FInputModeGameAndUI.
 * @Provenance CSV NegativeDiagnostic. DiagnosticOnly. Do not drop SetInputMode.
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
