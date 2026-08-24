// Theme: Language.Operators.Logical. Isolated compile-fail.
// C++: AngelscriptSyntaxOperatorsTests.cpp::Logical_Negative
// sha256=bba1fbe0d0d63c9df1c2b11e826c9ddcc6d476d81ab7176987407d79a6b1a04c; lines 331-333.
// Expected compile failure: "Missing right operand".
// DiagnosticOnly. Isolated failing program.

void Test()
{
	bool X = true && ;
}
