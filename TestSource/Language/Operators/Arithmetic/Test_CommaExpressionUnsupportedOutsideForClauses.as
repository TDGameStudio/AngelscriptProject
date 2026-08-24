// Theme: Language.Operators.Arithmetic. NegativeDiagnostic: comma expression outside for clauses.
// C++: AngelscriptCoverageSpecialControlFlowTests.cpp::CommaExpressionUnsupportedOutsideForClauses AssertFailsWithError.
// sha256=a9167c874335b6351635a201ff62c7a05d4117e9a28937981a6fc6e409a9e37b; lines 122-131.
// Expected diagnostic: Expected ')' / comma expression outside a for clause is not supported by this fork.
// Isolate this failing construct; do not add a for-clause that would compile it away.
// DiagnosticOnly.

int CommaExpression()
{
	int A = 1;
	int B = 2;
	int C = 3;
	int X = (A, B, C);
	return X;
}
