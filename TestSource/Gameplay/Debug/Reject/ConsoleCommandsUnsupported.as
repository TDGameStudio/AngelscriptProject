/**
 * ConsoleCommand is not exposed to script, so this program is rejected. C++
 * compiles it as the module ASCoverageDebug_ConsoleCommandsUnsupported and expects
 * the diagnostic to name ConsoleCommand. The CSV Positive label is wrong; C++ does
 * not compile this.
 *
 * @Theme Gameplay.Debug
 * @Subject Debug.ConsoleCommandsUnsupported
 * @Harness CompileReject
 * @Tag Gameplay.Debug.ConsoleCommandsUnsupported
 * @Provenance Theme: Gameplay.Debug. Isolated compile-fail: ConsoleCommand is not AS-facing.
 * @Provenance C++: AngelscriptCoverageDebugTests.cpp::ConsoleProfilerAndDebuggerControlsFailToCompile
 * @Provenance Expected diagnostic: ConsoleCommand (stat/show execution is not directly AS-facing).
 * @Provenance CSV Positive; C++ does not compile. DiagnosticOnly. Do not drop ConsoleCommand.
 */

/**
 * The isolated failing program: ConsoleCommand has no script-facing signature.
 *
 * @Kind CompileReject
 * @Covers Debug.ConsoleCommandsUnsupported
 * @Inputs none
 * @Return does not compile; ConsoleCommand is not an Angelscript callable
 */
void TryConsoleDebugCommands()
{
	ConsoleCommand("stat fps");
	ConsoleCommand("stat unit");
	ConsoleCommand("stat game");
	ConsoleCommand("stat gpu");
	ConsoleCommand("stat memory");
	ConsoleCommand("stat slow");
	ConsoleCommand("show Collision");
	ConsoleCommand("show Bones");
	ConsoleCommand("show Navmesh");
	ConsoleCommand("show Paths");
}
