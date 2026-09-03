/**
 * APlayerController::ConsoleCommand is not script-facing, so calling it is
 * rejected. This file is the illegal program itself; do not route the calls
 * through another API, since the unsupported method is the point.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.PlayerControllerConsoleCommandExecution
 * @Harness CompileReject
 * @Tag Language.Syntax.EdgeCases.PlayerControllerConsoleCommandExecution
 * @Kind CompileReject
 * @Covers Syntax.EdgeCases
 * @Inputs several ConsoleCommand calls on a player controller
 * @Return does not compile; diagnostic "APlayerController ConsoleCommand is not script-facing"
 * @Provenance C++: AngelscriptCoverageCVarTests.cpp::ConsoleCommandExecutionApisUnsupported block 2
 * @Provenance sha256=eb4e34f77aba29c9f1c235e25df0a024323bacdfc62a9069ac24c39d82d33226; lines 1217-1226.
 * @Provenance Expected diagnostic: APlayerController ConsoleCommand is not script-facing.
 * @Provenance Isolate this failing program. DiagnosticOnly.
 */

/**
 * Attempt to execute console commands through a player controller.
 *
 * @Covers Syntax.EdgeCases
 * @Inputs a player controller to call the method on
 * @Return does not compile
 * @Param Controller the controller whose ConsoleCommand is not script-facing
 */
void TryPlayerControllerConsoleCommand(APlayerController Controller)
{
	Controller.ConsoleCommand("stat fps");
	Controller.ConsoleCommand("stat unit");
	Controller.ConsoleCommand("r.SetRes 1920x1080w");
	Controller.ConsoleCommand("show collision");
	Controller.ConsoleCommand("viewmode unlit");
}
