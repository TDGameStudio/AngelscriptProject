/**
 * Isolated compile-fail: multi-player routing APIs stay boundaries. C++ compiles
 * this as the module ASCoverageInput_MultiPlayerRoutingBoundary and expects
 * failure. The CSV Positive label is wrong; C++ does not compile this.
 *
 * @Theme Gameplay.Input
 * @Subject Input.MultiPlayerRoutingBoundary
 * @Harness CompileReject
 * @Tag Gameplay.Input.MultiPlayerRoutingBoundary
 * @Provenance Theme: Gameplay.Input. Isolated compile-fail: multi-player routing APIs stay boundaries.
 * @Provenance C++: AngelscriptCoverageInputTests.cpp::EnhancedInputAndDeviceBoundaryInventory
 * @Provenance CSV Positive; C++ CompileAndExpectFailure (empty diagnostic list).
 * @Provenance Do not drop CreatePlayer or GetPlayerControllerFromID.
 */

/**
 * The isolated failing program: CreatePlayer and GetPlayerControllerFromID have no script-facing signatures.
 *
 * @Kind CompileReject
 * @Covers Input.MultiPlayerRoutingBoundary
 * @Inputs none
 * @Return does not compile; CreatePlayer and GetPlayerControllerFromID stay explicit boundaries
 */
int MultiPlayerRoutingBoundary()
{
	CreatePlayer(1, false);
	GetPlayerControllerFromID(1);
	return 1;
}
