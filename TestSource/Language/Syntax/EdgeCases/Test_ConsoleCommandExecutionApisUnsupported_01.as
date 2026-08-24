// Theme: Language.Syntax.EdgeCases. NegativeDiagnostic: global ConsoleCommand.
// C++: AngelscriptCoverageCVarTests.cpp::ConsoleCommandExecutionApisUnsupported block 1
// sha256=4eda5fe90b3986730977397ad98675a2299c4bad8a0a91c50e9c716acc2cc5a7; lines 1203-1216.
// Expected diagnostic: ConsoleCommand is not script-facing.
// Isolate this failing program. DiagnosticOnly.

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
