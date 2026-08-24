// Theme: Language.Syntax.Variable. NegativeDiagnostic: keyword used as a variable name.
// C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Variable_Negative block 6 AssertFailsToCompile.
// sha256=ddc232de4f2a730c8c1f3782cfcdb981ee2cdda0075376b5f7587bf14907713e; lines 604-606.
// Expected diagnostic: "Keyword as variable name". Isolate this failing program.
// DiagnosticOnly.

void Test()
{
	int class = 0;
}
