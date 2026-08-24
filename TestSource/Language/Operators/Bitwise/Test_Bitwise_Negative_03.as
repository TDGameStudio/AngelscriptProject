// Theme: Language.Operators.Bitwise. Isolated compile-fail.
// C++: AngelscriptSyntaxOperatorsTests.cpp::Bitwise_Negative
// sha256=bf5a24506476aaf34304b61aec13293a25625234150dad0e749fd1bb90a20359; lines 240-242.
// Expected compile failure: "Shift on float".
// DiagnosticOnly. Isolated failing program.

void Test()
{
	float X = 1.0f << 2;
}
