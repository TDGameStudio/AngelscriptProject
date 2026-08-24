// Theme: Feature.Access. NegativeDiagnostic: use a block-local variable after the block ends.
// C++: AngelscriptSyntaxAccessSpecifierTests.cpp::Scope_Negative block 1 AssertFailsToCompile.
// Expected compile failure: "Access variable after block ends".
// Isolate the failing program. DiagnosticOnly.

void Test()
{
	{
		int X = 1;
	}
	int Y = X;
}
