// Theme: Language.Literals.FString. NegativeDiagnostic: unterminated string literal.
// C++: AngelscriptSyntaxFStringTests.cpp::Negative block 1 AssertFailsToCompile.
// sha256=818dd5253ab99c4dead3d63c6de6cf0131fac350de7edefc97310e7f39a28236; lines 120-122.
// Expected diagnostic: unterminated string literal.
// Isolate this failing construct; do not add declarations that would compile it away.
// DiagnosticOnly.

void Test()
{
	FString S = "unterminated;
}
