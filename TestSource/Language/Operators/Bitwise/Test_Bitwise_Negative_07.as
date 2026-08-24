// Theme: Language.Operators.Bitwise. Isolated compile-fail.
// C++: AngelscriptSyntaxOperatorsTests.cpp::Bitwise_Negative
// sha256=fdf1b9d0fb6535f005c6af04f0c88544f874126cd71630aad3b206251722c02c; lines 271-273.
// Expected compile failure: "Shift on string".
// DiagnosticOnly. Isolated failing program.

void Test()
{
	auto X = "abc" >> 2;
}
