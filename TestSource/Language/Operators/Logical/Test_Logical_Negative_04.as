// Theme: Language.Operators.Logical. Isolated compile-fail.
// C++: AngelscriptSyntaxOperatorsTests.cpp::Logical_Negative
// sha256=6569005458d973229ac7721ed5029db5393651d479219d24c063e0cc4690c5b3; lines 338-340.
// Expected compile failure: "Triple & is invalid".
// DiagnosticOnly. Isolated failing program.

void Test()
{
	bool X = true &&& false;
}
