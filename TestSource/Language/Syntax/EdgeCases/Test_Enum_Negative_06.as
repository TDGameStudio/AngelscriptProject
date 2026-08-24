// Theme: Language.Syntax.EdgeCases. Isolated compile-fail: method inside enum.
// C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Enum_Negative block 6 AssertFailsToCompile.
// sha256=3199251df53905906f1862ac16243d33cb37abb36a898aedc0a7dbfa2397f251; lines 417-419.
// Expected diagnostic: methods are not allowed in enum EEnumMethod.
// DiagnosticOnly. Do not move Foo out of the enum.

enum EEnumMethod
{
	Value1;
	void Foo()
	{
	}
}
