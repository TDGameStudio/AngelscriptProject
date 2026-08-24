// Theme: Language.Operators.Arithmetic. Isolated compile-fail.
// C++: AngelscriptSyntaxOperatorsTests.cpp::Arithmetic_Negative
// sha256=086bd5231bafb5d9f0c8b7335c9203c73ab1e1c42dfed90fd7f334ac1c8f94c4; lines 176-178.
// Expected compile failure: "String * int".
// DiagnosticOnly. Isolated failing program.

void Test()
{
	auto S = "abc" * 3;
}
