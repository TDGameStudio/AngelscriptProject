/**
 * @version v1
 * @summary The global ConsoleCommand function is not script-facing, so calling it is rejected. This file is the illegal program itself; do not route the calls through another API, since the unsupported function is the point.
 * @topic Language
 */
/**
 * @version root
 * @summary The global ConsoleCommand function is not script-facing, so calling it is rejected. This file is the illegal program itself; do not route the calls through another API, since the unsupported function is the point.
 * @topic Negative
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
/** @end */
