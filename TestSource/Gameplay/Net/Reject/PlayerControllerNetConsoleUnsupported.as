/**
 * APlayerController.ConsoleCommand is not exposed to script, so this program is
 * rejected. C++ compiles it as the module
 * ASCoverageNetworking_PlayerControllerNetConsoleUnsupported and expects the
 * diagnostic to name ConsoleCommand. The CSV Positive label is wrong; C++ does
 * not compile this.
 *
 * @Theme Gameplay.Net
 * @Subject Net.PlayerControllerNetConsoleUnsupported
 * @Harness CompileReject
 * @Tag Gameplay.Net.PlayerControllerNetConsoleUnsupported
 * @Provenance Theme: Gameplay.Net. Isolated compile-fail: APlayerController.ConsoleCommand is not script-facing.
 * @Provenance C++: AngelscriptCoverageNetworkingTests.cpp::NetworkConsoleAndClientTravelBoundaries
 * @Provenance CompileAndExpectFailure diagnostic ConsoleCommand.
 * @Provenance CSV Positive; C++ does not compile. Do not drop Controller.ConsoleCommand.
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
