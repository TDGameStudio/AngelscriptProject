/**
 * @version v1
 * @summary APlayerController::ConsoleCommand is not script-facing, so calling it is rejected. This file is the illegal program itself; do not route the calls through another API, since the unsupported method is the point.
 * @topic Language
 */
/**
 * @version root
 * @summary APlayerController::ConsoleCommand is not script-facing, so calling it is rejected. This file is the illegal program itself; do not route the calls through another API, since the unsupported method is the point.
 * @topic Negative
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
/** @end */
