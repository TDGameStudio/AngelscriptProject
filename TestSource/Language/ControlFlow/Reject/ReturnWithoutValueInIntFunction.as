/**
 * A bare return in a function declared to return an int is rejected: the
 * function owes a value on every exit path. This file is the illegal program
 * itself; do not change the declared type or supply a value, since the
 * missing value is the point.
 *
 * @Theme Language.ControlFlow
 * @Subject ControlFlow.ReturnWithoutValueInIntFunction
 * @Harness CompileReject
 * @Tag Language.ControlFlow.ReturnWithoutValueInIntFunction
 * @Kind CompileReject
 * @Covers ControlFlow.Return
 * @Inputs int Test() { return; }
 * @Return does not compile; diagnostic "missing return value in a non-void function"
 * @Provenance C++: AngelscriptSyntaxControlFlowTests.cpp::Return_Mixed
 * @Provenance sha256=071ceef72f52ccb6c34ae680d0027dea246bb3c92700fbf1b51a860a9b57b110; lines 567-569.
 * @Provenance Oracle: compile fails — missing return value in a non-void function.
 * @Provenance CSV SourceShape is Positive; C++ AssertFailsToCompile is the TrailingOracle.
 */

/** */
int Test()
{
	return;
}
