// Theme: Language.Syntax.Variable. NegativeDiagnostic: use before declaration.
// C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Variable_Negative block 8 AssertFailsToCompile.
// sha256=9c99c253ead1b2be40b5b95eb89af778f84bfcb1664802b5a5229ad99936f6d9; lines 616-618.
// Expected diagnostic: "Use before declaration". Isolate this failing program.
// DiagnosticOnly.

void Test()
{
	int Y = X;
	int X = 5;
}
