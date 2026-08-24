// Theme: Gameplay.Input. Isolated compile-fail: mouse cursor control helpers.
// C++: AngelscriptCoverageInputTests.cpp::InputModeControl
// CompileAndExpectFailure diagnostics: No matching signatures to
// 'SetShowMouseCursor(const bool)' and 'GetShowMouseCursor()'.
// CSV WorldStory; C++ does not compile. DiagnosticOnly.
// Do not add extra declarations that would compile this away.

UCLASS()
class AInputModeController : APlayerController
{
	UPROPERTY()
	bool MouseCursorShown = false;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		// Show/hide mouse cursor
		SetShowMouseCursor(true);
		MouseCursorShown = GetShowMouseCursor();

		SetShowMouseCursor(false);
		MouseCursorShown = GetShowMouseCursor();
	}
}
