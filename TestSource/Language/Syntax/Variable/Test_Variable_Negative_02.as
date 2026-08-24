// Theme: Language.Syntax.Variable. NegativeDiagnostic: duplicate local variable.
// C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Variable_Negative block 2 AssertFailsToCompile.
// sha256=fbd99f3fd6d2f5a8f5e23d00b073a1e41e0d787bf958110c34228796a1e8ade8; lines 577-579.
// Expected diagnostic: "Duplicate variable". Isolate this failing program.
// DiagnosticOnly.

void Test()
{
	int X = 1;
	int X = 2;
}
