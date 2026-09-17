/**
 * @version v1
 * @summary Global ConsoleCommand is not exposed to script, so this program is rejected. C++ compiles it as the module ASCoverageNetworking_GlobalNetConsoleUnsupported and expects the diagnostic to name ConsoleCommand. The CSV.
 * @topic Gameplay
 */
/**
 * @version root
 * @summary Global ConsoleCommand is not exposed to script, so this program is rejected. C++ compiles it as the module ASCoverageNetworking_GlobalNetConsoleUnsupported and expects the diagnostic to name ConsoleCommand. The CSV.
 * @topic Negative
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
/** @end */
