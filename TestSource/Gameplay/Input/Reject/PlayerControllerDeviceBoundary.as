/**
 * Isolated compile-fail: PlayerController device query APIs stay boundaries. C++
 * compiles this as the module ASCoverageInput_PlayerControllerDeviceBoundary and
 * expects failure. The CSV Positive label is wrong; C++ does not compile this.
 *
 * @Theme Gameplay.Input
 * @Subject Input.PlayerControllerDeviceBoundary
 * @Harness CompileReject
 * @Tag Gameplay.Input.PlayerControllerDeviceBoundary
 * @Provenance Theme: Gameplay.Input. Isolated compile-fail: PlayerController device query APIs stay boundaries.
 * @Provenance C++: AngelscriptCoverageInputTests.cpp::EnhancedInputAndDeviceBoundaryInventory
 * @Provenance CSV Positive; C++ CompileAndExpectFailure (empty diagnostic list).
 * @Provenance Do not drop GetMousePosition, GetInputMotionState, or GetInputAnalogKeyState.
 */

UCLASS()
class APlayerControllerDeviceBoundary : APlayerController
{
	/**
	 * The isolated failing program: the device query helpers have no script-facing signatures.
	 *
	 * @Kind CompileReject
	 * @Covers Input.PlayerControllerDeviceBoundary
	 * @Inputs none
	 * @Return does not compile; GetMousePosition, GetInputMotionState and GetInputAnalogKeyState stay boundaries
	 */
	UFUNCTION()
	void QueryDevices()
	{
		float32 MouseX = 0.0f;
		float32 MouseY = 0.0f;
		GetMousePosition(MouseX, MouseY);
		GetInputMotionState(MouseX, MouseY, MouseX, MouseY, MouseX, MouseY);
		GetInputAnalogKeyState(EKeys::Gamepad_LeftX);
	}
}
