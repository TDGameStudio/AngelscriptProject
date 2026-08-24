// Theme: Feature.Default. Isolated compile-fail: non-constant expression as a parameter default.
// C++: AngelscriptSyntaxDefaultStatementTests.cpp::ParamDefault_Negative AssertFailsToCompile
// ASSyntaxDS_ParamExprDefault. Expected diagnostic: "Non-constant expression as default should fail".
// DiagnosticOnly. Do not replace GlobalVal + 1 with a literal.

int GlobalVal = 5;
void Foo(int X = GlobalVal + 1)
{
}
