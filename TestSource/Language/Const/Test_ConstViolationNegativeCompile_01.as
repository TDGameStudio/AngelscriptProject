// Theme: Language.Const. Isolated compile-fail from ConstViolationNegativeCompile.
// C++: AngelscriptCoverageConstTests.cpp::ConstViolationNegativeCompile
// sha256=0f7f163de22f2128aa06ec0502a91ceae5ab3dd299dea15b9bc9e1a9c3435f80; lines 231-237.
// Oracle: compile fails — modifying a const local (Value = 2).
// DiagnosticOnly. Source owns the isolated failing program.

void Test()
{
	const int Value = 1;
	Value = 2;
}
