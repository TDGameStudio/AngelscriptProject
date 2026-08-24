// Theme: Language.Syntax.EdgeCases. NegativeDiagnostic: unknown parameter type.
// C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Function_Negative block 6 AssertFailsToCompile.
// sha256=d95f4dfe5a24de1191f7e4a582d196a14d680fc12d056f1a52620a6368d74521; lines 711-713.
// Expected diagnostic: "Non-existent param type". Isolate this failing program.
// DiagnosticOnly.

void Foo(NonExistentType X)
{
}
