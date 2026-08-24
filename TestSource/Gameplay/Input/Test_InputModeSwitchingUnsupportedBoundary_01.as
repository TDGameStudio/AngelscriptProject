// Theme: Gameplay.Input. Isolated compile-fail: SetInputMode + FInputModeGameOnly is not script-facing.
// C++: AngelscriptCoverageInputTests.cpp::InputModeSwitchingUnsupportedBoundary
// CompileAndExpectFailure diagnostic FInputModeGameOnly.
// CSV NegativeDiagnostic. DiagnosticOnly. Do not drop SetInputMode.

UCLASS()
class AInputModeSwitchingBoundaryController : APlayerController
{
	UFUNCTION()
	void TryGameOnlyInputMode()
	{
		FInputModeGameOnly GameOnlyMode;
		SetInputMode(GameOnlyMode);
	}
}
