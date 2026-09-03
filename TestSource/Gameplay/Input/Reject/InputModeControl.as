/**
 * Isolated compile-fail: mouse cursor control helpers. C++ compiles this as the
 * module ASCoverageInput_ModeControlUnsupported and expects diagnostics naming
 * SetShowMouseCursor and GetShowMouseCursor. Do not add extra declarations that
 * would compile this away.
 *
 * @Theme Gameplay.Input
 * @Subject Input.InputModeControl
 * @Harness CompileReject
 * @Tag Gameplay.Input.InputModeControl
 * @Provenance Theme: Gameplay.Input. Isolated compile-fail: mouse cursor control helpers.
 * @Provenance C++: AngelscriptCoverageInputTests.cpp::InputModeControl
 * @Provenance CompileAndExpectFailure diagnostics: No matching signatures to
 * @Provenance 'SetShowMouseCursor(const bool)' and 'GetShowMouseCursor()'.
 * @Provenance CSV WorldStory; C++ does not compile. DiagnosticOnly.
 * @Provenance Do not add extra declarations that would compile this away.
 */

UCLASS()
class AInputModeController : APlayerController
{
	UPROPERTY()
	bool MouseCursorShown = false;

	/**
	 * The isolated failing program: SetShowMouseCursor and GetShowMouseCursor have no matching signatures.
	 *
	 * @Kind CompileReject
	 * @Covers Input.InputModeControl
	 * @Inputs none
	 * @Return does not compile; "No matching signatures to 'SetShowMouseCursor(const bool)'" and "No matching signatures to 'GetShowMouseCursor()'"
	 */
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
