// Theme: Feature.Access. NegativeDiagnostic: use a for-loop variable after the loop.
// C++: AngelscriptSyntaxAccessSpecifierTests.cpp::Scope_Negative block 2 AssertFailsToCompile.
// Expected compile failure: "Access loop variable after loop".
// Isolate the failing program. DiagnosticOnly.

void Test()
{
	for (int I = 0; I < 5; ++I)
	{
	}
	int X = I;
}
