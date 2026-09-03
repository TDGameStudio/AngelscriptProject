/**
 * A for condition that does not evaluate to bool is rejected. This file is the
 * illegal program itself; do not turn the condition into a comparison, since the
 * non-bool expression is the point.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.ForNonBoolCondition
 * @Harness CompileReject
 * @Tag Language.Syntax.EdgeCases.ForNonBoolCondition
 * @Kind CompileReject
 * @Covers Syntax.EdgeCases
 * @Inputs a for loop whose condition is an int
 * @Return does not compile; diagnostic "Non-bool condition"
 * @Provenance C++: AngelscriptSyntaxControlFlowTests.cpp::For_Negative ForN_NonBoolCond
 * @Provenance sha256=e33bc0ecce0ef65afc67fba7331f9ce5594de336fcf9cab4cb77516379805a3c; lines 177-179.
 * @Provenance Expected diagnostic: "Non-bool condition".
 * @Provenance Isolate this failing program; do not add declarations that would compile it away.
 * @Provenance DiagnosticOnly.
 */

/**
 * A loop whose condition is the loop counter itself.
 *
 * @Covers Syntax.EdgeCases
 * @Inputs none
 * @Return does not compile
 */
void Test()
{
	for (int I = 0; I; ++I)
	{
	}
}
