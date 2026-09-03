/**
 * Ordering two booleans with the less-than operator is rejected: booleans have
 * no ordering, only equality. This file is the illegal program itself; do not
 * substitute a comparison, since the unsupported operator is the point.
 *
 * @Theme Language.Operators
 * @Subject Operators.BooleanOrderingComparison
 * @Harness CompileReject
 * @Tag Language.Operators.BooleanOrderingComparison
 * @Kind CompileReject
 * @Covers Operators.Comparison
 * @Inputs true < false
 * @Return does not compile; diagnostic "Comparing booleans with <"
 * @Provenance C++: AngelscriptSyntaxOperatorsTests.cpp::Comparison_Negative
 * @Provenance sha256=cdf4f496b47261da23db00599f9ca4f51df85b0833ab9c489256275079fc5876; lines 432-434.
 * @Provenance Expected compile failure: "Comparing booleans with <".
 * @Provenance DiagnosticOnly. Isolated failing program.
 */

/** */
void Test()
{
	bool X = (true < false);
}
