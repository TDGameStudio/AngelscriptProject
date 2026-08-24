// Theme: Language.Operators.Arithmetic. Isolated compile-fail.
// C++: AngelscriptSyntaxOperatorsTests.cpp::Arithmetic_Negative
// sha256=198a78a1684413b01849cfb66b234243bb61b71afb727b72968d7d20517491d1; lines 119-121.
// Expected compile failure: "Float modulo".
// C++ currently #if 0 this case (#as-engine-behavior: float modulo is allowed).
// DiagnosticOnly. Isolated failing program.

void Test()
{
	float X = 10.0f % 3.0f;
}
