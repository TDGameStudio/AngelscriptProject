// Theme: Language.Syntax.EdgeCases. NegativeDiagnostic: PlayerController.ConsoleCommand.
// C++: AngelscriptCoverageCVarTests.cpp::ConsoleCommandExecutionApisUnsupported block 2
// sha256=eb4e34f77aba29c9f1c235e25df0a024323bacdfc62a9069ac24c39d82d33226; lines 1217-1226.
// Expected diagnostic: APlayerController ConsoleCommand is not script-facing.
// Isolate this failing program. DiagnosticOnly.

void TryPlayerControllerConsoleCommand(APlayerController Controller)
{
	Controller.ConsoleCommand("stat fps");
	Controller.ConsoleCommand("stat unit");
	Controller.ConsoleCommand("r.SetRes 1920x1080w");
	Controller.ConsoleCommand("show collision");
	Controller.ConsoleCommand("viewmode unlit");
}
