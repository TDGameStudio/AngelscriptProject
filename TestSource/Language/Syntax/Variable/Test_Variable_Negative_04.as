// Theme: Language.Syntax.Variable. NegativeDiagnostic: const without initializer.
// C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Variable_Negative block 4 AssertFailsToCompile.
// sha256=e9b7f2bc8b330523ce2df806a70833c83a4d622241f0db616b3afa19f854edcf; lines 591-593.
// Expected diagnostic: "Const without initializer".
// C++ currently wraps this AssertFailsToCompile in #if 0 (const without init is accepted).
// Isolate this failing program. DiagnosticOnly.

void Test()
{
	const int X;
}
