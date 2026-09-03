/**
 * A break inside a function that is called from a loop is rejected: break only
 * exits the loop it is lexically inside, and does not propagate out through a
 * call. This file is the illegal program itself; do not move the break into
 * the loop, since the non-propagation is the point.
 *
 * @Theme Language.ControlFlow
 * @Subject ControlFlow.BreakInFunctionCalledFromLoop
 * @Harness CompileReject
 * @Tag Language.ControlFlow.BreakInFunctionCalledFromLoop
 * @Kind CompileReject
 * @Covers ControlFlow.Jump
 * @Inputs A helper function containing a bare break, called from inside a for loop
 * @Return does not compile; diagnostic "break does not propagate out of a called function"
 * @Provenance C++: AngelscriptSyntaxControlFlowTests.cpp::BreakContinue_Negative
 * @Provenance sha256=6cdb47cd2e19aaed71c3b7a12fc1043c7ae24af6c3c5a1f172063b5dcfbd412e; lines 414-421.
 * @Provenance Oracle: compile fails — Invalid 'break' inside a function called from a loop.
 */

void Foo()
{
	break;
}

void Test()
{
	for (int I = 0; I < 5; ++I)
	{
		Foo();
	}
}
