// Theme: Language.Syntax.EdgeCases. Isolated compile-fail: void struct member.
// C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Struct_Negative block 6 AssertFailsToCompile.
// sha256=37540d53c2b7df406ed1aaa84c1e7ca571adb54cda52a969bc8e20aa30ecea8f; lines 321-323.
// Expected diagnostic: void is not a valid member type for X.
// DiagnosticOnly. Do not replace void with int.

struct FStructVoidMember
{
	void X;
}
