// Theme: Language.Syntax.EdgeCases. Isolated compile-fail: unmatched parenthesis.
// C++: AngelscriptSyntaxMiscTests.cpp::EdgeCases_Negative block 3 AssertFailsToCompile.
// sha256=8182105cb9380f58f9d0850cbb25f47431244b9680041ba410cce1f788dd365d; lines 292-294.
// Expected diagnostic: unmatched parenthesis in (1 + 2.
// DiagnosticOnly. Do not close the parenthesis.

void Test()
{
	int X = (1 + 2;
}
