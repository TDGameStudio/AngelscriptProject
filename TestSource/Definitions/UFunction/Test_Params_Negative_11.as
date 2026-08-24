// Theme: Definitions.UFunction. NegativeDiagnostic: three parameters with the same name.
// C++: AngelscriptSyntaxUFunctionTests.cpp::Params_Negative block 11 AssertFailsToCompile.
// sha256=11dba41b215d19b0c0dc343ef38d271643c8610a61f98e0904c34fcd16e3a1f0; lines 497-503.
// Expected diagnostic: "Three parameters with same name should fail".
// Isolate this failing program. DiagnosticOnly.

class AUFuncPNTripleDupActor : AActor
{
	UFUNCTION()
	void Foo(int A, int A, int A)
	{
	}
}
