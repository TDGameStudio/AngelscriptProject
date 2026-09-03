/**
 * A range-for without the colon between the loop variable and the container is
 * rejected. This file is the illegal program itself.
 *
 * @Theme Language.ControlFlow
 * @Subject ControlFlow.ForeachMissingColon
 * @Harness CompileReject
 * @Tag Language.ControlFlow.ForeachMissingColon
 * @Kind CompileReject
 * @Covers ControlFlow.Foreach
 * @Inputs for (int Val Arr) with no colon
 * @Return does not compile; diagnostic "expected ':' in the range-for"
 */

void Test()
{
	TArray<int> Arr;
	for (int Val Arr)
	{
	}
}
