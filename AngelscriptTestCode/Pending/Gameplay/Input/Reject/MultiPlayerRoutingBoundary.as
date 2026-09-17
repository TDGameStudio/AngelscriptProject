/**
 * @version v1
 * @summary Isolated compile-fail: multi-player routing APIs stay boundaries. C++ compiles this as the module ASCoverageInput_MultiPlayerRoutingBoundary and expects failure. The CSV Positive label is wrong; C++ does not compile.
 * @topic Gameplay
 */
/**
 * @version root
 * @summary Isolated compile-fail: multi-player routing APIs stay boundaries. C++ compiles this as the module ASCoverageInput_MultiPlayerRoutingBoundary and expects failure. The CSV Positive label is wrong; C++ does not compile.
 * @topic Negative
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
/** @end */
