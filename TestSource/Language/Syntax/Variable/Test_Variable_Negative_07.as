// Theme: Language.Syntax.Variable. NegativeDiagnostic: void variable.
// C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Variable_Negative block 7 AssertFailsToCompile.
// sha256=db160d8f8ad749b323fa05123f681652827495223494e20c7a50671450132b1f; lines 610-612.
// Expected diagnostic: "Void variable". Isolate this failing program.
// DiagnosticOnly.

void Test()
{
	void X;
}
