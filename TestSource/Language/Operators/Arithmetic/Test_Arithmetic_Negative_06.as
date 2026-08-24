// Theme: Language.Operators.Arithmetic. Isolated compile-fail.
// C++: AngelscriptSyntaxOperatorsTests.cpp::Arithmetic_Negative
// sha256=869e4e859213ef4befff766cc2d8c085f4ee3c0c76cebdc68f0317d9d0402c9f; lines 144-146.
// Expected compile failure: "Increment on const".
// DiagnosticOnly. Isolated failing program.

void Test()
{
	const int X = 5;
	++X;
}
