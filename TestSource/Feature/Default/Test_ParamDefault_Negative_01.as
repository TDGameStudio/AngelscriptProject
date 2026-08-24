// Theme: Feature.Default. Isolated compile-fail: non-default parameter after a default.
// C++: AngelscriptSyntaxDefaultStatementTests.cpp::ParamDefault_Negative AssertFailsToCompile
// ASSyntaxDS_ParamOrder. Expected diagnostic: "Non-default param after default should fail".
// DiagnosticOnly. Do not add a default for Y.

void Foo(int X = 5, int Y)
{
}
