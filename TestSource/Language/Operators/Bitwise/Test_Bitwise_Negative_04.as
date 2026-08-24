// Theme: Language.Operators.Bitwise. Isolated compile-fail.
// C++: AngelscriptSyntaxOperatorsTests.cpp::Bitwise_Negative
// sha256=232ef98ec5a8af2fbfdea957ad5b239074b55813572514f907c55dd12cc9aa15; lines 247-249.
// Expected compile failure: "Bitwise NOT on string".
// DiagnosticOnly. Isolated failing program.

void Test()
{
	auto S = ~"hello";
}
