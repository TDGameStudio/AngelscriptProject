// Theme: Definitions.UFunction. NegativeDiagnostic: empty specifier with lone comma.
// C++: AngelscriptSyntaxUFunctionTests.cpp::Specifiers_Negative block 12 AssertFailsToCompile.
// sha256=be2643902abcfbc70dc4e4b455bd0e7b6057d5492f443a93e4d4f09c50a4a647; lines 326-332.
// Expected diagnostic: "Empty specifier with lone comma should fail".
// Isolate this failing program. DiagnosticOnly.

class AUFuncEmptyCommaActor : AActor
{
	UFUNCTION(,)
	void Foo()
	{
	}
}
