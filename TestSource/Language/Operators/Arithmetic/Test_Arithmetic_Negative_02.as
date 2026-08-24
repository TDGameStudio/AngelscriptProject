// Theme: Language.Operators.Arithmetic. NegativeDiagnostic: bool + bool is not an int.
// C++: AngelscriptSyntaxOperatorsTests.cpp::Arithmetic_Negative block 2 AssertFailsToCompile (currently #if 0, implicit-conversion-permissive).
// sha256=eeb7095010fc58c679289aa5481f18d0887382a88bb38e92bc8873f652e499f4; lines 108-110.
// Expected diagnostic: bool addition.
// Isolate this failing construct; do not add declarations that would compile it away.
// DiagnosticOnly.

void Test()
{
	bool A = true;
	bool B = false;
	int X = A + B;
}
