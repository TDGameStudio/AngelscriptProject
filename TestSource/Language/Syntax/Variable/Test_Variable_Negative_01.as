// Theme: Language.Syntax.Variable. NegativeDiagnostic: undeclared type.
// C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Variable_Negative block 1 AssertFailsToCompile.
// sha256=1375780ba5ef11f0b7ad7e58a2568d8d7ae469de9a7eaa881545c43007493605; lines 571-573.
// Expected diagnostic: "Undeclared type". Isolate this failing program.
// DiagnosticOnly.

void Test()
{
	NonExistentType X;
}
