/**
 * A do-while loop without a trailing semicolon after the condition is
 * rejected: the while clause ends the statement. This file is the illegal
 * program itself.
 *
 * @Theme Language.ControlFlow
 * @Subject ControlFlow.DoWhileMissingSemicolon
 * @Harness CompileReject
 * @Tag Language.ControlFlow.DoWhileMissingSemicolon
 * @Kind CompileReject
 * @Covers ControlFlow.DoWhile
 * @Inputs do { } while (true) with no trailing semicolon
 * @Return does not compile; diagnostic "expected ';' after the do-while condition"
 */

/** */
void Test()
{
	do
	{
	} while (true)
}
