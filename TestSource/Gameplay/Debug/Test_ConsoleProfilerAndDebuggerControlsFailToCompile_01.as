// Theme: Gameplay.Debug. Isolated compile-fail: ConsoleCommand is not AS-facing.
// C++: AngelscriptCoverageDebugTests.cpp::ConsoleProfilerAndDebuggerControlsFailToCompile
// Expected diagnostic: ConsoleCommand (stat/show execution is not directly AS-facing).
// CSV Positive; C++ does not compile. DiagnosticOnly. Do not drop ConsoleCommand.

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
