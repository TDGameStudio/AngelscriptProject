// Theme: Language.Syntax.EdgeCases. Isolated compile-fail: class without a name.
// C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Class_Negative block 1 is #if 0
// AssertFailsToCompile (preprocessor-ensure-crash on anonymous class).
// sha256=587cd2a88497e058d85c07de93ef8d8bcb4d3cf694e03bf9645cb68f59632d47; lines 133-135.
// Expected diagnostic: unnamed class / DetectClasses ensure. Successful compile is failure.
// DiagnosticOnly. Do not invent a class name.

class : AActor
{
}
