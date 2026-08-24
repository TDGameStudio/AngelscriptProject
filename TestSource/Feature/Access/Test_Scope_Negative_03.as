// Theme: Feature.Access. NegativeDiagnostic: use a local before its declaration.
// C++: AngelscriptSyntaxAccessSpecifierTests.cpp::Scope_Negative block 3 AssertFailsToCompile.
// Expected compile failure: "Use variable before declaration".
// Isolate the failing program. DiagnosticOnly.

void Test()
{
	int Y = X;
	int X = 5;
}
