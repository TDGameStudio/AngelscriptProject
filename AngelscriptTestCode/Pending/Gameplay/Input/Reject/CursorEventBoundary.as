/**
 * @version v1
 * @summary Isolated compile-fail: cursor click and hover APIs stay boundaries. C++ compiles this as the module ASCoverageInput_CursorEventBoundary and expects failure. The CSV Positive label is wrong; C++ does not compile this.
 * @topic Gameplay
 */
/**
 * @version root
 * @summary Isolated compile-fail: cursor click and hover APIs stay boundaries. C++ compiles this as the module ASCoverageInput_CursorEventBoundary and expects failure. The CSV Positive label is wrong; C++ does not compile this.
 * @topic Negative
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
/** @end */
