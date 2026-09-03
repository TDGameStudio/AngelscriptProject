/**
 * Iterating an integer literal is rejected: range-for needs a container. This
 * file is the illegal program itself.
 *
 * @Theme Language.ControlFlow
 * @Subject ControlFlow.ForeachOverIntegerLiteral
 * @Harness CompileReject
 * @Tag Language.ControlFlow.ForeachOverIntegerLiteral
 * @Kind CompileReject
 * @Covers ControlFlow.Foreach
 * @Inputs for (int Val : 42)
 * @Return does not compile; diagnostic "range-for requires a container"
 */

/** */
void Test()
{
	for (int Val : 42)
	{
	}
}
