// Theme: Gameplay.Input. Isolated compile-fail: multi-player routing APIs stay boundaries.
// C++: AngelscriptCoverageInputTests.cpp::EnhancedInputAndDeviceBoundaryInventory
// CSV Positive; C++ CompileAndExpectFailure (empty diagnostic list).
// Do not drop CreatePlayer or GetPlayerControllerFromID.

int MultiPlayerRoutingBoundary()
{
	CreatePlayer(1, false);
	GetPlayerControllerFromID(1);
	return 1;
}
