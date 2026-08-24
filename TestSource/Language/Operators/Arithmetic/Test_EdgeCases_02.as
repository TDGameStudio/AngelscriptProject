// Theme: Language.Operators.Arithmetic. Isolated compile-fail.
// C++: AngelscriptSyntaxOperatorsTests.cpp::EdgeCases
// sha256=8182105cb9380f58f9d0850cbb25f47431244b9680041ba410cce1f788dd365d; lines 667-669.
// CSV SourceShape Positive is wrong; C++ AssertFailsToCompile.
// Expected compile failure: "Unmatched parenthesis".
// DiagnosticOnly. Isolated failing program.

void Test()
{
	int X = (1 + 2;
}
