/**
 * A break inside an if that sits outside any loop is rejected: an if is not a
 * loop, so there is nothing for the break to exit. This file is the illegal
 * program itself; do not wrap it in a loop, since the missing loop is the
 * point.
 *
 * @Theme Language.ControlFlow
 * @Subject ControlFlow.BreakInsideIfWithoutLoop
 * @Harness CompileReject
 * @Tag Language.ControlFlow.BreakInsideIfWithoutLoop
 * @Kind CompileReject
 * @Covers ControlFlow.Jump
 * @Inputs break; inside an if body with no enclosing loop
 * @Return does not compile; diagnostic "Invalid 'break' inside if but not a loop"
 * @Provenance C++: AngelscriptSyntaxControlFlowTests.cpp::BreakContinue_Negative
 * @Provenance sha256=8d4099a876324f3d371ade28721555bd226b3f259c89fad07cd963cd12659c82; lines 398-400.
 * @Provenance Oracle: compile fails — Invalid 'break' inside if but not a loop.
 */

void Test()
{
	if (true)
	{
		break;
	}
}
