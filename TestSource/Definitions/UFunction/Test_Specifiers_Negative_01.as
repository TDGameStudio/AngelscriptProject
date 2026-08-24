// Theme: Definitions.UFunction. NegativeDiagnostic: unknown UFUNCTION specifier.
// C++: AngelscriptSyntaxUFunctionTests.cpp::Specifiers_Negative block 1 AssertFailsToCompile.
// sha256=5122ab921557e4fbae355c52149b9e8a3b6f750c6783c885bc18c8f08a9c82fa; lines 199-205.
// Expected diagnostic: "Unknown function specifier" (Contains, 3).
// Isolate this failing program. DiagnosticOnly.

class AUFuncInvalidActor : AActor
{
	UFUNCTION(InvalidSpecifier)
	void Foo()
	{
	}
}
