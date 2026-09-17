/**
 * @version v1
 * @summary Isolated compile-fail: mouse cursor control helpers. C++ compiles this as the module ASCoverageInput_ModeControlUnsupported and expects diagnostics naming SetShowMouseCursor and GetShowMouseCursor. Do not add extra.
 * @topic Gameplay
 */
/**
 * @version root
 * @summary Isolated compile-fail: mouse cursor control helpers. C++ compiles this as the module ASCoverageInput_ModeControlUnsupported and expects diagnostics naming SetShowMouseCursor and GetShowMouseCursor. Do not add extra.
 * @topic Negative
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
/** @end */
