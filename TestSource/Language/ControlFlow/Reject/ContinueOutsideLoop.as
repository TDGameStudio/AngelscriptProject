/**
 * A continue outside a loop is rejected: there is no enclosing loop to skip
 * an iteration of. This file is the illegal program itself; do not wrap it in
 * a loop, since the missing loop is the point.
 *
 * @Theme Language.ControlFlow
 * @Subject ControlFlow.ContinueOutsideLoop
 * @Harness CompileReject
 * @Tag Language.ControlFlow.ContinueOutsideLoop
 * @Kind CompileReject
 * @Covers ControlFlow.Jump
 * @Inputs continue; at function scope with no enclosing loop
 * @Return does not compile; diagnostic "Invalid 'continue' outside a loop"
 * @Provenance C++: AngelscriptSyntaxControlFlowTests.cpp::BreakContinue_Negative
 * @Provenance sha256=6e3b7bfbe0962261b58eda1410b6added4231f54b3f87b1d884102dc98afd2c3; lines 390-392.
 * @Provenance Oracle: compile fails — Invalid 'continue' outside a loop.
 */

void Test()
{
	continue;
}
