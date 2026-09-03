/**
 * A break outside a loop is rejected: there is no enclosing loop to exit.
 * This file is the illegal program itself; do not wrap it in a loop, since
 * the missing loop is the point.
 *
 * @Theme Language.ControlFlow
 * @Subject ControlFlow.BreakOutsideLoop
 * @Harness CompileReject
 * @Tag Language.ControlFlow.BreakOutsideLoop
 * @Kind CompileReject
 * @Covers ControlFlow.Jump
 * @Inputs break; at function scope with no enclosing loop
 * @Return does not compile; diagnostic "Invalid 'break' outside a loop"
 * @Provenance C++: AngelscriptSyntaxControlFlowTests.cpp::BreakContinue_Negative
 * @Provenance sha256=20b1873e55a903e345d7b8bb263dc2fc832b6609412653cd7fb4415842ff86bb; lines 382-384.
 * @Provenance Oracle: compile fails — Invalid 'break' outside a loop.
 */

/** */
void Test()
{
	break;
}
