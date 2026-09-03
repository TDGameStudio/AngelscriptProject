/**
 * Global ConsoleCommand is not exposed to script, so this program is rejected. C++
 * compiles it as the module ASCoverageNetworking_GlobalNetConsoleUnsupported and
 * expects the diagnostic to name ConsoleCommand. The CSV Positive label is wrong;
 * C++ does not compile this.
 *
 * @Theme Gameplay.Net
 * @Subject Net.GlobalNetConsoleUnsupported
 * @Harness CompileReject
 * @Tag Gameplay.Net.GlobalNetConsoleUnsupported
 * @Provenance Theme: Gameplay.Net. Isolated compile-fail: global ConsoleCommand is not script-facing.
 * @Provenance C++: AngelscriptCoverageNetworkingTests.cpp::NetworkConsoleAndClientTravelBoundaries
 * @Provenance CompileAndExpectFailure diagnostic ConsoleCommand.
 * @Provenance CSV Positive; C++ does not compile. Do not drop ConsoleCommand.
 */

/**
 * The isolated failing program: ConsoleCommand has no script-facing signature.
 *
 * @Kind CompileReject
 * @Covers Net.GlobalNetConsoleUnsupported
 * @Inputs none
 * @Return does not compile; ConsoleCommand is not an Angelscript callable
 */
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
