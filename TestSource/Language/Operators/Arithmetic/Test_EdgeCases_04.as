// Theme: Language.Operators.Arithmetic. Isolated compile-fail.
// C++: AngelscriptSyntaxOperatorsTests.cpp::EdgeCases
// sha256=bbaedb1e1de68d626523e025069f9ee53cf855c0a52725234d0236f190ea4f8e; lines 681-683.
// CSV SourceShape Positive is wrong; C++ AssertFailsToCompile.
// Expected compile failure: "Trailing operator".
// DiagnosticOnly. Isolated failing program.

void Test()
{
	int X = 1 +;
}
