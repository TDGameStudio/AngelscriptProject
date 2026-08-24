// Theme: Language.Operators.Comparison. Isolated compile-fail.
// C++: AngelscriptSyntaxOperatorsTests.cpp::Comparison_Negative
// sha256=d34a34262a1bb43e776bbbee18426d5c70dc00f56a4f4c3d7340ac2d176f6318; lines 404-406.
// Expected compile failure: "Comparing string to int".
// DiagnosticOnly. Isolated failing program.

void Test()
{
	bool X = ("hello" < 5);
}
