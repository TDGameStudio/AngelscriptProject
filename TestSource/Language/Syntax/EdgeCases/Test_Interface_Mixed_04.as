// Theme: Language.Syntax.EdgeCases. Isolated compile-fail: unnamed interface.
// C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Interface_Mixed block 4 AssertFailsToCompile.
// CSV SourceShape Positive is wrong; the C++ method is AssertFailsToCompile.
// sha256=173f6fdfbaafe86dd181abc6a85c7567b562df83aff052a66392fea164a6308c; lines 460-462.
// Expected diagnostic: interface without a name is invalid.
// DiagnosticOnly. Do not invent an interface name.

interface
{
	void Foo();
}
