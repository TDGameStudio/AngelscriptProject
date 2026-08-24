// Theme: Gameplay.Net. Isolated compile-fail: global ConsoleCommand is not script-facing.
// C++: AngelscriptCoverageNetworkingTests.cpp::NetworkConsoleAndClientTravelBoundaries
// CompileAndExpectFailure diagnostic ConsoleCommand.
// CSV Positive; C++ does not compile. Do not drop ConsoleCommand.

void TryNetworkConsoleCommands()
{
	ConsoleCommand("Net PktLag=100");
	ConsoleCommand("Net PktLoss=10");
	ConsoleCommand("stat net");
	ConsoleCommand("stat netgraph");
	ConsoleCommand("Log LogNet Verbose");
	ConsoleCommand("Log LogNetTraffic Verbose");
	ConsoleCommand("Log LogRep Verbose");
}
