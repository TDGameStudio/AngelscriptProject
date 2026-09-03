/**
 * A while condition without parentheses is rejected: the condition must be
 * wrapped, unlike an if in some other languages. This file is the illegal
 * program itself.
 *
 * @Theme Language.ControlFlow
 * @Subject ControlFlow.WhileUnparenthesizedCondition
 * @Harness CompileReject
 * @Tag Language.ControlFlow.WhileUnparenthesizedCondition
 * @Kind CompileReject
 * @Covers ControlFlow.While
 * @Inputs while true { } with no parentheses around the condition
 * @Return does not compile; diagnostic "expected '(' after while"
 */

void Test()
{
	while true
	{
	}
}
