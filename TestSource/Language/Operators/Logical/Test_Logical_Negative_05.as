// Theme: Language.Operators.Logical. Isolated compile-fail.
// C++: AngelscriptSyntaxOperatorsTests.cpp::Logical_Negative
// sha256=55246348843ead21fa6e789e2f24aaa0a5985b91142e3e4442bd2891e379b8ea; lines 345-347.
// Expected compile failure: "Logical OR on strings".
// DiagnosticOnly. Isolated failing program.

void Test()
{
	auto X = "a" || "b";
}
