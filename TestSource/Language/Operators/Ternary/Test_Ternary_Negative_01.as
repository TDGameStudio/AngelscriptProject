// Theme: Language.Operators.Ternary. Isolated compile-fail: non-bool condition.
// C++: AngelscriptSyntaxOperatorsTests.cpp::Ternary_Negative AssertFailsToCompile
// TernN_NonBool; lines 594-596;
// sha256=4affb84b8079ee3bd4cd15f600eba559c619346e3ac10773a57291fc0195b0f1.
// Expected diagnostic: non-bool ternary condition (int 5).
// Do not wrap 5 in a comparison that would make this compile.
// DiagnosticOnly.

void Test()
{
	int X = 5 ? 1 : 0;
}
