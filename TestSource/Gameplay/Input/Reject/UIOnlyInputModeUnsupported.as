/**
 * Isolated compile-fail: SetInputMode + FInputModeUIOnly is not script-facing.
 * C++ compiles this as the module ASCoverageInput_UIOnlyInputModeUnsupported
 * and expects a diagnostic naming FInputModeUIOnly. Do not drop SetInputMode.
 *
 * @Theme Gameplay.Input
 * @Subject Input.UIOnlyInputModeUnsupported
 * @Harness CompileReject
 * @Tag Gameplay.Input.UIOnlyInputModeUnsupported
 * @Provenance Theme: Gameplay.Input. Isolated compile-fail: SetInputMode + FInputModeUIOnly is not script-facing.
 * @Provenance C++: AngelscriptCoverageInputTests.cpp::InputModeSwitchingUnsupportedBoundary
 * @Provenance CompileAndExpectFailure diagnostic FInputModeUIOnly.
 * @Provenance CSV NegativeDiagnostic. DiagnosticOnly. Do not drop SetInputMode.
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
