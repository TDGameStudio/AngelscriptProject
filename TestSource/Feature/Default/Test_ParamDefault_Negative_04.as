// Theme: Feature.Default. Isolated compile-fail: non-const variable as a parameter default.
// C++: AngelscriptSyntaxDefaultStatementTests.cpp::ParamDefault_Negative AssertFailsToCompile
// ASSyntaxDS_ParamNonConst. Expected diagnostic: "Non-const variable as default should fail".
// DiagnosticOnly. Do not replace GlobalVal with a literal.

int GlobalVal = 5;
void Foo(int X = GlobalVal)
{
}
