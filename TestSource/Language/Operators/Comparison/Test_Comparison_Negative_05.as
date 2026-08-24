// Theme: Language.Operators.Comparison. Isolated compile-fail.
// C++: AngelscriptSyntaxOperatorsTests.cpp::Comparison_Negative
// sha256=cdf4f496b47261da23db00599f9ca4f51df85b0833ab9c489256275079fc5876; lines 432-434.
// Expected compile failure: "Comparing booleans with <".
// DiagnosticOnly. Isolated failing program.

void Test()
{
	bool X = (true < false);
}
