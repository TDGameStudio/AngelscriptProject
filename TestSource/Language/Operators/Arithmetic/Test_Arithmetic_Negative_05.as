// Theme: Language.Operators.Arithmetic. Isolated compile-fail.
// C++: AngelscriptSyntaxOperatorsTests.cpp::Arithmetic_Negative
// sha256=ccb5f2e6fb39e46cd474ed2899834701bf4910b1c6c439594646172303545a67; lines 136-138.
// Expected compile failure: "Increment on literal".
// DiagnosticOnly. Isolated failing program.

void Test()
{
	++5;
}
