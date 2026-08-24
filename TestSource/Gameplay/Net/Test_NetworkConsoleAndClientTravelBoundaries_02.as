// Theme: Gameplay.Net. Isolated compile-fail: APlayerController.ConsoleCommand is not script-facing.
// C++: AngelscriptCoverageNetworkingTests.cpp::NetworkConsoleAndClientTravelBoundaries
// CompileAndExpectFailure diagnostic ConsoleCommand.
// CSV Positive; C++ does not compile. Do not drop Controller.ConsoleCommand.

void TryPlayerControllerNetworkConsoleCommands(APlayerController Controller)
{
	Controller.ConsoleCommand("Net PktLag=100");
	Controller.ConsoleCommand("Net PktLoss=10");
	Controller.ConsoleCommand("stat net");
	Controller.ConsoleCommand("stat netgraph");
}
