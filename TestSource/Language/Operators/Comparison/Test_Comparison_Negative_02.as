// Theme: Language.Operators.Comparison. Isolated compile-fail.
// C++: AngelscriptSyntaxOperatorsTests.cpp::Comparison_Negative
// sha256=ce2d96b2b30188b97978b809da9d39de65ae59e403e17deae3f247a5dd64c80a; lines 411-413.
// Expected compile failure: "Missing right operand".
// DiagnosticOnly. Isolated failing program.

void Test()
{
	bool X = (1 == );
}
