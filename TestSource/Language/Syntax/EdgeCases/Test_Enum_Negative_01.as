// Theme: Language.Syntax.EdgeCases. Isolated compile-fail: enum without a name.
// C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Enum_Negative block 1 is #if 0
// AssertFailsToCompile (preprocessor-ensure-crash on anonymous enum).
// sha256=d3f44f1c169a1264b6e73d05ba95325591f3f2113d73231dd6f47770a1afdae6; lines 379-381.
// Expected diagnostic: unnamed enum / DetectEnum ensure. Successful compile is failure.
// DiagnosticOnly. Do not invent an enum name.

enum
{
	Value1
}
