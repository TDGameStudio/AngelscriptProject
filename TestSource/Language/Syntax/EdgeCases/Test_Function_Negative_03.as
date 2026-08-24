// Theme: Language.Syntax.EdgeCases. NegativeDiagnostic: duplicate function signature.
// C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Function_Negative block 3 AssertFailsToCompile.
// sha256=4d435a7ada163cb5b51ffb640ab38428ac39d6a6d841fc2b322d70e7341ecae4; lines 692-695.
// Expected diagnostic: "Duplicate signature". Isolate this failing program.
// DiagnosticOnly.

void Foo(int X)
{
}

void Foo(int X)
{
}
