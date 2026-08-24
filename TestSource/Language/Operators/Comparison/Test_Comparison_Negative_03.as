// Theme: Language.Operators.Comparison. Isolated compile-fail.
// C++: AngelscriptSyntaxOperatorsTests.cpp::Comparison_Negative
// sha256=905ef858cda8d3508f5b130402cfa6c290c73999dd941716cc3d37d5403782e9; lines 418-420.
// Expected compile failure: "Triple equals not valid".
// DiagnosticOnly. Isolated failing program.

void Test()
{
	bool X = (1 === 1);
}
