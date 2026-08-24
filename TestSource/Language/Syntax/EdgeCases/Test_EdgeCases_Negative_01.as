// Theme: Language.Syntax.EdgeCases. Isolated compile-fail: unmatched opening brace.
// C++: AngelscriptSyntaxMiscTests.cpp::EdgeCases_Negative block 1 AssertFailsToCompile.
// sha256=ed17ddd5ad2df64ba2fe118e49a50f59a79d07df08afafb581175d2474fe781a; lines 280-282.
// Expected diagnostic: unmatched opening brace / missing closing brace.
// DiagnosticOnly. Do not close the function body.

void Test()
{
	int X = 1;
