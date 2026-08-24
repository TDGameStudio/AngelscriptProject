// Theme: Language.Syntax.EdgeCases. Isolated compile-fail: interface method body.
// C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Interface_Mixed block 3 AssertFailsToCompile.
// CSV SourceShape Positive is wrong; the C++ method is AssertFailsToCompile.
// sha256=99991528e3afe92067f5e5db676a6c85c65cf227f03c058dabb4e97cb475ab40; lines 454-456.
// Expected diagnostic: interface UIntfBody method DoSomething may not have a body.
// DiagnosticOnly. Do not strip the method body.

interface UIntfBody
{
	void DoSomething()
	{
	}
}
