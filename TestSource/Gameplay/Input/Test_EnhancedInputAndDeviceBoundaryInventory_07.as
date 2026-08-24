// Theme: Gameplay.Input. Isolated compile-fail: cursor click and hover APIs stay boundaries.
// C++: AngelscriptCoverageInputTests.cpp::EnhancedInputAndDeviceBoundaryInventory
// CSV Positive; C++ CompileAndExpectFailure (empty diagnostic list).
// Do not drop SetMouseCursor, bEnableClickEvents, or bEnableMouseOverEvents.

UCLASS()
class ACursorEventBoundary : APlayerController
{
	UFUNCTION()
	void ConfigureCursor()
	{
		SetMouseCursor(EMouseCursor::Hand);
		bEnableClickEvents = true;
		bEnableMouseOverEvents = true;
	}
}
