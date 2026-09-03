/**
 * Iterating a primitive value is rejected: range-for needs a container. This
 * file is the illegal program itself.
 *
 * @Theme Language.ControlFlow
 * @Subject ControlFlow.ForeachOverPrimitive
 * @Harness CompileReject
 * @Tag Language.ControlFlow.ForeachOverPrimitive
 * @Kind CompileReject
 * @Covers ControlFlow.Foreach
 * @Inputs for (int Val : X) where X is an int
 * @Return does not compile; diagnostic "range-for requires a container"
 */

/** */
void Test()
{
	int X = 5;
	for (int Val : X)
	{
	}
}
