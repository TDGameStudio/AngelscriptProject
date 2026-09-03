/**
 * A while condition that is just an int variable is rejected: the condition
 * must be a boolean expression, not a bare integer. This file is the illegal
 * program itself.
 *
 * @Theme Language.ControlFlow
 * @Subject ControlFlow.WhileVariableCondition
 * @Harness CompileReject
 * @Tag Language.ControlFlow.WhileVariableCondition
 * @Kind CompileReject
 * @Covers ControlFlow.While
 * @Inputs while (X) { } where X is an int
 * @Return does not compile; diagnostic "while condition must be a boolean expression"
 */

void Test()
{
	int X = 1;
	while (X)
	{
		break;
	}
}
