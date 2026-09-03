/**
 * The global ConsoleCommand function is not script-facing, so calling it is
 * rejected. This file is the illegal program itself; do not route the calls
 * through another API, since the unsupported function is the point.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.GlobalConsoleCommandExecution
 * @Harness CompileReject
 * @Tag Language.Syntax.EdgeCases.GlobalConsoleCommandExecution
 * @Kind CompileReject
 * @Covers Syntax.EdgeCases
 * @Inputs several global ConsoleCommand calls
 * @Return does not compile; diagnostic "ConsoleCommand is not script-facing"
 * @Provenance C++: AngelscriptCoverageCVarTests.cpp::ConsoleCommandExecutionApisUnsupported block 1
 * @Provenance sha256=4eda5fe90b3986730977397ad98675a2299c4bad8a0a91c50e9c716acc2cc5a7; lines 1203-1216.
 * @Provenance Expected diagnostic: ConsoleCommand is not script-facing.
 * @Provenance Isolate this failing program. DiagnosticOnly.
 */

/**
 * Attempt to execute console commands through the global function.
 *
 * @Covers Syntax.EdgeCases
 * @Inputs none
 * @Return does not compile
 */
void TryExecuteConsoleCommand()
{
	ConsoleCommand("stat fps");
	ConsoleCommand("stat unit");
	ConsoleCommand("stat game");
	ConsoleCommand("stat gpu");
	ConsoleCommand("r.SetRes 1920x1080w");
	ConsoleCommand("show collision");
	ConsoleCommand("show bounds");
	ConsoleCommand("viewmode wireframe");
	ConsoleCommand("viewmode unlit");
}
