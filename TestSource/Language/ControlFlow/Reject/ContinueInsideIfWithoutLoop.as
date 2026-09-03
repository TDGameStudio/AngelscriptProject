/**
 * A continue inside an if that sits outside any loop is rejected: an if is
 * not a loop, so there is no iteration to skip. This file is the illegal
 * program itself; do not wrap it in a loop, since the missing loop is the
 * point.
 *
 * @Theme Language.ControlFlow
 * @Subject ControlFlow.ContinueInsideIfWithoutLoop
 * @Harness CompileReject
 * @Tag Language.ControlFlow.ContinueInsideIfWithoutLoop
 * @Kind CompileReject
 * @Covers ControlFlow.Jump
 * @Inputs continue; inside an if body with no enclosing loop
 * @Return does not compile; diagnostic "Invalid 'continue' inside if but not a loop"
 * @Provenance C++: AngelscriptSyntaxControlFlowTests.cpp::BreakContinue_Negative
 * @Provenance sha256=65ef893941cb3f7e3816e6d14e05fdc7a0f7ebeb3528d4b50a1cc10f814c3c1c; lines 406-408.
 * @Provenance Oracle: compile fails — Invalid 'continue' inside if but not a loop.
 */

/** */
void Test()
{
	if (true)
	{
		continue;
	}
}
