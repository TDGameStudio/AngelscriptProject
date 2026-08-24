// Theme: Language.Syntax.EdgeCases. NegativeDiagnostic: non-default parameter after a default.
// C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Function_Negative block 4 AssertFailsToCompile.
// sha256=1a7155088a87e3342f2ce75636eb0aa296f62de0f4cf12b8a0fa67c9f5e9a350; lines 699-701.
// Expected diagnostic: "Non-default after default". Isolate this failing program.
// DiagnosticOnly.

void Foo(int X = 5, int Y)
{
}
