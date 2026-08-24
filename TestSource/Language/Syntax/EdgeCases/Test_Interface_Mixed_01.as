// Theme: Language.Syntax.EdgeCases. Isolated compile-fail: interface keyword.
// C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Interface_Mixed block 1 was AssertCompiles
// but is #if 0 (feature-not-supported: AS 2.33 fork rejects interface).
// CSV SourceShape Positive is not a compile-success on this fork.
// sha256=e31ad9c0e92b75da82828b85c33ffe06086dfe5d44ef8e34d89d63eef0cb064b; lines 436-442.
// Expected diagnostic: interface is not a supported declaration.
// Isolate this program. Do not rewrite UIntfBasic as a class.

interface UIntfBasic
{
	void DoSomething();
	int GetValue();
}
