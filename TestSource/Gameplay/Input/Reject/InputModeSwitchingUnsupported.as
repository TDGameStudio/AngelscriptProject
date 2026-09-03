/**
 * Isolated compile-fail: SetInputMode + FInputModeGameOnly is not script-facing.
 * C++ compiles this as the module ASCoverageInput_InputModeSwitchingUnsupported
 * and expects a diagnostic naming FInputModeGameOnly. Do not drop SetInputMode.
 *
 * @Theme Gameplay.Input
 * @Subject Input.InputModeSwitchingUnsupported
 * @Harness CompileReject
 * @Tag Gameplay.Input.InputModeSwitchingUnsupported
 * @Provenance Theme: Gameplay.Input. Isolated compile-fail: SetInputMode + FInputModeGameOnly is not script-facing.
 * @Provenance C++: AngelscriptCoverageInputTests.cpp::InputModeSwitchingUnsupportedBoundary
 * @Provenance CompileAndExpectFailure diagnostic FInputModeGameOnly.
 * @Provenance CSV NegativeDiagnostic. DiagnosticOnly. Do not drop SetInputMode.
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
