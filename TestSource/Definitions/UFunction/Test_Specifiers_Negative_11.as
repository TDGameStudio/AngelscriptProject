// Theme: Definitions.UFunction. NegativeDiagnostic: numeric literal as specifier.
// C++: AngelscriptSyntaxUFunctionTests.cpp::Specifiers_Negative block 11 AssertFailsToCompile.
// sha256=c3b28dab76b937949b5bbae8ec759b23e29a5a07378e7655e3f1faa5290c74dd; lines 315-321.
// Expected diagnostic: "Numeric literal as specifier should fail".
// Isolate this failing program. DiagnosticOnly.

class AUFuncNumSpecActor : AActor
{
	UFUNCTION(999)
	void Foo()
	{
	}
}
