/**
 * Reading a loop variable after its for scope has closed is rejected. This file
 * is the illegal program itself; do not hoist the declaration out of the loop,
 * since the scoped lifetime is the point.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.ForLoopVariableEscapesScope
 * @Harness CompileReject
 * @Tag Language.Syntax.EdgeCases.ForLoopVariableEscapesScope
 * @Kind CompileReject
 * @Covers Syntax.EdgeCases
 * @Inputs a loop variable read after the loop
 * @Return does not compile; diagnostic "Access loop var after loop"
 * @Provenance C++: AngelscriptSyntaxControlFlowTests.cpp::For_Negative ForN_VarAfterLoop
 * @Provenance sha256=4f728ff3ee60900e47b754b12130e4cc201995a0e2afd879c3b40727615f01f8; lines 198-200.
 * @Provenance Expected diagnostic: "Access loop var after loop".
 * @Provenance Isolate this failing program; do not add declarations that would compile it away.
 * @Provenance DiagnosticOnly.
 */

/**
 * A loop whose counter is read after its scope ends.
 *
 * @Covers Syntax.EdgeCases
 * @Inputs none
 * @Return does not compile
 */
void Test()
{
	for (int I = 0; I < 5; ++I)
	{
	}
	int X = I;
}
