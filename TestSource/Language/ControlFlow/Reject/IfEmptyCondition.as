/**
 * An if with an empty condition is rejected: there is nothing to test. This
 * file is the illegal program itself; do not supply a condition, since the
 * emptiness is the point.
 *
 * @Theme Language.ControlFlow
 * @Subject ControlFlow.IfEmptyCondition
 * @Harness CompileReject
 * @Tag Language.ControlFlow.IfEmptyCondition
 * @Kind CompileReject
 * @Covers ControlFlow.If
 * @Inputs if () { }
 * @Return does not compile; diagnostic "expected an expression inside the if condition"
 * @Provenance C++: AngelscriptSyntaxControlFlowTests.cpp::IfElse_Negative
 * @Provenance sha256=5131f6b1fffe4a04dda8b5940c45553f7fad7df014a43dccd8682a74c6798e3d; lines 96-98.
 * @Provenance Oracle: compile fails — empty if condition.
 */

/** */
void Test()
{
	if ()
	{
	}
}
