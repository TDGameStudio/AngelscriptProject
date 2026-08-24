// Theme: Gameplay.Input. Isolated compile-fail: PlayerController device query APIs stay boundaries.
// C++: AngelscriptCoverageInputTests.cpp::EnhancedInputAndDeviceBoundaryInventory
// CSV Positive; C++ CompileAndExpectFailure (empty diagnostic list).
// Do not drop GetMousePosition, GetInputMotionState, or GetInputAnalogKeyState.

UCLASS()
class APlayerControllerDeviceBoundary : APlayerController
{
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
