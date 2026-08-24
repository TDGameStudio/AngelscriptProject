// Theme: Language.Operators.Arithmetic. Isolated compile-fail.
// C++: AngelscriptSyntaxOperatorsTests.cpp::EdgeCases
// sha256=bbb5389e0885c41e441067e820b0db109c27321f9522e163b23d74cbe0872fef; lines 688-690.
// CSV SourceShape Positive is wrong; C++ AssertFailsToCompile.
// Expected compile failure: "Leading binary operator".
// DiagnosticOnly. Isolated failing program.

void Test()
{
	int X = * 2;
}
