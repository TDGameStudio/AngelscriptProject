// Theme: Language.Operators.Logical. Isolated compile-fail.
// C++: AngelscriptSyntaxOperatorsTests.cpp::Logical_Negative
// sha256=602fc43ada2fb2e42b7ddaabc685c184e12c29d59454c49b0fc5f594f6e13090; lines 324-326.
// Expected compile failure: "Logical NOT on integer".
// DiagnosticOnly. Isolated failing program.

void Test()
{
	int X = !5;
}
