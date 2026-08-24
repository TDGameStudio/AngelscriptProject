// Theme: Language.Syntax.EdgeCases. Isolated compile-fail: interface data member.
// C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Interface_Mixed block 2 AssertFailsToCompile.
// CSV SourceShape Positive is wrong; the C++ method is AssertFailsToCompile.
// sha256=894f664193697fe12edd79a6b07144d7108fc2583b77d73c42e1597dfb156da7; lines 448-450.
// Expected diagnostic: interface UIntfMember may not declare member variable X.
// DiagnosticOnly. Do not drop the data member.

interface UIntfMember
{
	int X;
}
