/**
 * An integer do-while condition is rejected: like the while form, the
 * condition must be a boolean expression. This file is the illegal program
 * itself.
 *
 * @Theme Language.ControlFlow
 * @Subject ControlFlow.DoWhileIntegerCondition
 * @Harness CompileReject
 * @Tag Language.ControlFlow.DoWhileIntegerCondition
 * @Kind CompileReject
 * @Covers ControlFlow.DoWhile
 * @Inputs do { } while (1);
 * @Return does not compile; diagnostic "do-while condition must be a boolean expression"
 */

void Test()
{
	do
	{
	} while (1);
}
