/**
 * A for header with only two of its three clauses is rejected. This file is the
 * illegal program itself; do not add the missing clause, since its absence is the
 * point.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.ForWithTwoClausesOnly
 * @Harness CompileReject
 * @Tag Language.Syntax.EdgeCases.ForWithTwoClausesOnly
 * @Kind CompileReject
 * @Covers Syntax.EdgeCases
 * @Inputs a for header missing its increment clause
 * @Return does not compile; diagnostic "For with only two clauses"
 * @Provenance C++: AngelscriptSyntaxControlFlowTests.cpp::For_Negative ForN_TooFew
 * @Provenance sha256=d5d43ed123396e2c84bbcca89cde6cde56794debfe90d5d57783ccc6d9cce2b5; lines 191-193.
 * @Provenance Expected diagnostic: "For with only two clauses".
 * @Provenance Isolate this failing program; do not add declarations that would compile it away.
 * @Provenance DiagnosticOnly.
 */

/**
 * A loop whose header stops after the condition.
 *
 * @Covers Syntax.EdgeCases
 * @Inputs none
 * @Return does not compile
 */
void Test()
{
	for (int I = 0; I < 10)
	{
	}
}
