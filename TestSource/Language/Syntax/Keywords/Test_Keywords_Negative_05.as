// Theme: Language.Syntax.Keywords. NegativeDiagnostic: Super:: outside a class.
// C++: AngelscriptSyntaxMiscTests.cpp::Keywords_Negative block 5 AssertFailsToCompile.
// sha256=78db4da04dfcbe9777bf9cef53478c70d494053a438e6be00f36ea48cced4c36; lines 213-215.
// Expected diagnostic: "Super outside class should fail". Isolate this failing program.
// DiagnosticOnly.

void Test()
{
	Super::BeginPlay();
}
