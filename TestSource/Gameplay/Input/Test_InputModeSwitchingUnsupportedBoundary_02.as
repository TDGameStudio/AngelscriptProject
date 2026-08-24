// Theme: Gameplay.Input. Isolated compile-fail: SetInputMode + FInputModeUIOnly is not script-facing.
// C++: AngelscriptCoverageInputTests.cpp::InputModeSwitchingUnsupportedBoundary
// CompileAndExpectFailure diagnostic FInputModeUIOnly.
// CSV NegativeDiagnostic. DiagnosticOnly. Do not drop SetInputMode.

UCLASS()
class AInputModeUIOnlyBoundaryController : APlayerController
{
	UFUNCTION()
	void TryUIOnlyInputMode()
	{
		FInputModeUIOnly UIOnlyMode;
		SetInputMode(UIOnlyMode);
	}
}
