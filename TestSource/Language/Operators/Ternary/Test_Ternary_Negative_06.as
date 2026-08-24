// Theme: Language.Operators.Ternary. Isolated compile-fail: string condition.
// C++: AngelscriptSyntaxOperatorsTests.cpp::Ternary_Negative AssertFailsToCompile
// TernN_StrCond; lines 629-631;
// sha256=ae6d999058ae6eb6b184312d8718d16225782c309be40167b0b13cf32582a908.
// Expected diagnostic: string as ternary condition.
// Do not compare the string to make this compile.
// DiagnosticOnly.

void Test()
{
	int X = "yes" ? 1 : 0;
}
