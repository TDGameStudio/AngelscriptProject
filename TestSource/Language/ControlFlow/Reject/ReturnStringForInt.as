/**
 * Returning a string from a function declared to return an int is rejected:
 * the returned value must match the declared return type. This file is the
 * illegal program itself; do not change the declared type or the literal,
 * since the mismatch is the point.
 *
 * @Theme Language.ControlFlow
 * @Subject ControlFlow.ReturnStringForInt
 * @Harness CompileReject
 * @Tag Language.ControlFlow.ReturnStringForInt
 * @Kind CompileReject
 * @Covers ControlFlow.Return
 * @Inputs int Test() { return "hello"; }
 * @Return does not compile; diagnostic "return type mismatch (string for int)"
 * @Provenance C++: AngelscriptSyntaxControlFlowTests.cpp::Return_Mixed
 * @Provenance sha256=20fd88fe6b5168541e126a00e0794b9021e58b2167d4ff78b35edbfb8763c71a; lines 553-555.
 * @Provenance Oracle: compile fails — return type mismatch (string for int).
 * @Provenance CSV SourceShape is Positive; C++ AssertFailsToCompile is the TrailingOracle.
 */

int Test()
{
	return "hello";
}
