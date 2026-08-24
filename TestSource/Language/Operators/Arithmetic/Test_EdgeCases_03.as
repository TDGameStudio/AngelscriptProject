// Theme: Language.Operators.Arithmetic. Isolated compile-fail.
// C++: AngelscriptSyntaxOperatorsTests.cpp::EdgeCases
// sha256=e7950e42833fa3b379db54291222977ebeaca4f61e566defb566e894907bb8e6; lines 674-676.
// CSV SourceShape Positive is wrong; C++ AssertFailsToCompile.
// Expected compile failure: "Empty parentheses as value".
// DiagnosticOnly. Isolated failing program.

void Test()
{
	int X = ();
}
