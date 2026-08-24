// Theme: Language.Operators.Bitwise. Isolated compile-fail.
// C++: AngelscriptSyntaxOperatorsTests.cpp::Bitwise_Negative
// sha256=68ad17fe2c5fbd6a4cbe468cf9eda0254321d90b1e731afd7638010dd6bfc01f; lines 233-235.
// Expected compile failure: "Bitwise OR on float".
// DiagnosticOnly. Isolated failing program.

void Test()
{
	float X = 1.0f | 2.0f;
}
