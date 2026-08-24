// Theme: Language.Operators.Comparison. Isolated compile-fail.
// C++: AngelscriptSyntaxOperatorsTests.cpp::Comparison_Negative
// sha256=501e776c3b827eb618ea9c19e2a8412208a7160b6468eda5c9dce510959fa818; lines 425-427.
// Expected compile failure: "Comparing vectors with <".
// DiagnosticOnly. Isolated failing program.

void Test()
{
	bool X = FVector(1,0,0) < FVector(0,1,0);
}
