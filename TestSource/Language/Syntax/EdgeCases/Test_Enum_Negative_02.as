// Theme: Language.Syntax.EdgeCases. Isolated compile-fail: duplicate enumerator.
// C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Enum_Negative block 2 AssertFailsToCompile.
// sha256=63d7ab5e068d512097c6160e4cc3fef4489b07b9368226687f2218742c22e155; lines 386-388.
// Expected diagnostic: Value1 is declared twice in EEnumDupVal.
// DiagnosticOnly. Do not rename the second enumerator.

enum EEnumDupVal
{
	Value1,
	Value1
}
