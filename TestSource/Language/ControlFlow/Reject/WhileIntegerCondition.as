/**
 * An integer while condition is rejected: the condition must be a boolean
 * expression, and this fork does not treat a non-zero integer as true. This
 * file is the illegal program itself.
 *
 * @Theme Language.ControlFlow
 * @Subject ControlFlow.WhileIntegerCondition
 * @Harness CompileReject
 * @Tag Language.ControlFlow.WhileIntegerCondition
 * @Kind CompileReject
 * @Covers ControlFlow.While
 * @Inputs while (5) { }
 * @Return does not compile; diagnostic "while condition must be a boolean expression"
 */

/** */
void Test()
{
	while (5)
	{
	}
}
