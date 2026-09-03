/**
 * Isolated compile-fail: cursor click and hover APIs stay boundaries. C++ compiles
 * this as the module ASCoverageInput_CursorEventBoundary and expects failure. The
 * CSV Positive label is wrong; C++ does not compile this.
 *
 * @Theme Gameplay.Input
 * @Subject Input.CursorEventBoundary
 * @Harness CompileReject
 * @Tag Gameplay.Input.CursorEventBoundary
 * @Provenance Theme: Gameplay.Input. Isolated compile-fail: cursor click and hover APIs stay boundaries.
 * @Provenance C++: AngelscriptCoverageInputTests.cpp::EnhancedInputAndDeviceBoundaryInventory
 * @Provenance CSV Positive; C++ CompileAndExpectFailure (empty diagnostic list).
 * @Provenance Do not drop SetMouseCursor, bEnableClickEvents, or bEnableMouseOverEvents.
 */

UCLASS()
class ACursorEventBoundary : APlayerController
{
	/**
	 * The isolated failing program: SetMouseCursor and the click/hover flags are not script-facing.
	 *
	 * @Kind CompileReject
	 * @Covers Input.CursorEventBoundary
	 * @Inputs none
	 * @Return does not compile; SetMouseCursor, bEnableClickEvents and bEnableMouseOverEvents stay boundaries
	 */
	UFUNCTION()
	void ConfigureCursor()
	{
		SetMouseCursor(EMouseCursor::Hand);
		bEnableClickEvents = true;
		bEnableMouseOverEvents = true;
	}
}
