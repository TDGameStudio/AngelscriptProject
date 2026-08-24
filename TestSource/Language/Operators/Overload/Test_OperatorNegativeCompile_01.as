// Theme: Language.Operators.Overload. Isolated compile-fail.
// C++: AngelscriptCoverageOperatorOverloadTests.cpp::OperatorNegativeCompile
// sha256=687b496a47b199c21696ea7f4c4ce315a6067f8dfe97d70d7eb86b5b95319708; lines 228-240.
// Expected compile failure: "using + without opAdd should fail".
// DiagnosticOnly. Isolated failing program.

struct FNoPlus
{
	int Value = 0;
}

void Test()
{
	FNoPlus A;
	FNoPlus B;
	FNoPlus C = A + B;
}
