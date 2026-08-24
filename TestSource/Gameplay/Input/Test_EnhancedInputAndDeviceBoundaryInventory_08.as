// Theme: Gameplay.Input. Isolated compile-fail: Force Feedback and Haptic APIs stay boundaries.
// C++: AngelscriptCoverageInputTests.cpp::EnhancedInputAndDeviceBoundaryInventory
// CSV Positive; C++ CompileAndExpectFailure (empty diagnostic list).
// Do not drop ClientPlayForceFeedback or SetHapticsByValue.

UCLASS()
class AForceFeedbackBoundary : APlayerController
{
	UFUNCTION()
	void PlayFeedback()
	{
		ClientPlayForceFeedback(nullptr);
		SetHapticsByValue(0.5f, 0.5f, 0.5f, 0.5f);
	}
}
