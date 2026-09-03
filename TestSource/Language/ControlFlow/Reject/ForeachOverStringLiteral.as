/**
 * Iterating a string literal is rejected: a string is not a container of loop
 * elements here. This file is the illegal program itself.
 *
 * @Theme Language.ControlFlow
 * @Subject ControlFlow.ForeachOverStringLiteral
 * @Harness CompileReject
 * @Tag Language.ControlFlow.ForeachOverStringLiteral
 * @Kind CompileReject
 * @Covers ControlFlow.Foreach
 * @Inputs for (int Val : "hello")
 * @Return does not compile; diagnostic "range-for requires a container"
 */

/** */
void Test()
{
	for (int Val : "hello")
	{
	}
}
