/**
 * A comma expression outside a for clause is rejected: this fork supports the
 * comma operator only inside for clauses. This file is the illegal program
 * itself; do not wrap it in a for clause, since the comma expression is the
 * point.
 *
 * @Theme Language.Operators
 * @Subject Operators.CommaExpressionOutsideForClause
 * @Harness CompileReject
 * @Tag Language.Operators.CommaExpressionOutsideForClause
 * @Kind CompileReject
 * @Covers Operators.Arithmetic
 * @Inputs (A, B, C) assigned to an int outside any for clause
 * @Return does not compile; diagnostic "Expected ')' / comma expression outside a for clause is not supported by this fork"
 * @Provenance C++: AngelscriptCoverageSpecialControlFlowTests.cpp::CommaExpressionUnsupportedOutsideForClauses AssertFailsWithError.
 * @Provenance sha256=a9167c874335b6351635a201ff62c7a05d4117e9a28937981a6fc6e409a9e37b; lines 122-131.
 * @Provenance Expected diagnostic: Expected ')' / comma expression outside a for clause is not supported by this fork.
 * @Provenance Isolate this failing construct; do not add a for-clause that would compile it away.
 * @Provenance DiagnosticOnly.
 */

int CommaExpression()
{
	int A = 1;
	int B = 2;
	int C = 3;
	int X = (A, B, C);
	return X;
}
