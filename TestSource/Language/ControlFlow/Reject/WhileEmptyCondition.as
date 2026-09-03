/**
 * A while loop with an empty condition is rejected: there is nothing to test.
 * This file is the illegal program itself.
 *
 * @Theme Language.ControlFlow
 * @Subject ControlFlow.WhileEmptyCondition
 * @Harness CompileReject
 * @Tag Language.ControlFlow.WhileEmptyCondition
 * @Kind CompileReject
 * @Covers ControlFlow.While
 * @Inputs while () { }
 * @Return does not compile; diagnostic "expected an expression inside the while condition"
 */

/** */
void Test()
{
	while ()
	{
	}
}
