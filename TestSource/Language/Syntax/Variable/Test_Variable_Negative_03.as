// Theme: Language.Syntax.Variable. NegativeDiagnostic: auto without initializer.
// C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Variable_Negative block 3 AssertFailsToCompile.
// sha256=606bdf5bc04e492e906c0fc693d08d7c73544f0990127addcd88c755081fc537; lines 583-585.
// Expected diagnostic: "Auto without initializer". Isolate this failing program.
// DiagnosticOnly.

void Test()
{
	auto X;
}
