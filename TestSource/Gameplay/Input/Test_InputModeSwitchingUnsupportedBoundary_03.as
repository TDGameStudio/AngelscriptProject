// Theme: Gameplay.Input. Isolated compile-fail: SetInputMode + FInputModeGameAndUI is not script-facing.
// C++: AngelscriptCoverageInputTests.cpp::InputModeSwitchingUnsupportedBoundary
// CompileAndExpectFailure diagnostic FInputModeGameAndUI.
// CSV NegativeDiagnostic. DiagnosticOnly. Do not drop SetInputMode.

UCLASS()
class AInputModeGameAndUIBoundaryController : APlayerController
{
	UFUNCTION()
	void TryGameAndUIInputMode()
	{
		FInputModeGameAndUI GameAndUIMode;
		SetInputMode(GameAndUIMode);
	}
}
