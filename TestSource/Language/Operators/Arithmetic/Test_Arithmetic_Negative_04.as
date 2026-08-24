// Theme: Language.Operators.Arithmetic. Isolated compile-fail.
// C++: AngelscriptSyntaxOperatorsTests.cpp::Arithmetic_Negative
// sha256=183c5b89f09586ef97250bdc0350565556191d99752de79de69bbff2f0b80bce; lines 128-130.
// Expected compile failure: "Missing right operand".
// DiagnosticOnly. Isolated failing program.

void Test()
{
	int X = 1 + ;
}
