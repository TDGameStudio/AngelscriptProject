// Theme: Language.Operators.Ternary. Isolated compile-fail: missing colon/false branch.
// C++: AngelscriptSyntaxOperatorsTests.cpp::Ternary_Negative AssertFailsToCompile
// TernN_NoColon; lines 608-610;
// sha256=4bacce4cc4694010d86312dd07466f8b197bef663c5a9482b9f708e2e3d2e0cb.
// Expected diagnostic: ternary without colon.
// Do not add : 0 that would make this compile.
// DiagnosticOnly.

void Test()
{
	int X = true ? 1;
}
