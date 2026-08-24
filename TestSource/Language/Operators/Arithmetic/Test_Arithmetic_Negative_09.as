// Theme: Language.Operators.Arithmetic. Isolated compile-fail.
// C++: AngelscriptSyntaxOperatorsTests.cpp::Arithmetic_Negative
// sha256=4690e400b64ee47644beab64d13ca6961f9f25625eb969c75e60b8c30df8bf79; lines 168-170.
// Expected compile failure: "Unary plus on string".
// DiagnosticOnly. Isolated failing program.

void Test()
{
	FString S = +"hello";
}
