/**
 * @version v1
 * @summary APlayerController.ConsoleCommand is not exposed to script, so this program is rejected. C++ compiles it as the module ASCoverageNetworking_PlayerControllerNetConsoleUnsupported and expects the diagnostic to name.
 * @topic Gameplay
 */
/**
 * @version root
 * @summary APlayerController.ConsoleCommand is not exposed to script, so this program is rejected. C++ compiles it as the module ASCoverageNetworking_PlayerControllerNetConsoleUnsupported and expects the diagnostic to name.
 * @topic Negative
 */
/**
 * The isolated failing program: APlayerController.ConsoleCommand has no script-facing
 * signature.
 *
 * @Kind CompileReject
 * @Covers Net.PlayerControllerNetConsoleUnsupported
 * @Inputs a player controller whose ConsoleCommand is invoked
 * @Return does not compile; ConsoleCommand is not an Angelscript callable
 * @Param Controller the player controller used to invoke ConsoleCommand
 */
void TryPlayerControllerNetworkConsoleCommands(APlayerController Controller)
{
	Controller.ConsoleCommand("Net PktLag=100");
	Controller.ConsoleCommand("Net PktLoss=10");
	Controller.ConsoleCommand("stat net");
	Controller.ConsoleCommand("stat netgraph");
}
/** @end */
