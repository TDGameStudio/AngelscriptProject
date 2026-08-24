// Theme: Definitions.UFunction. NegativeDiagnostic: reference to a non-existent type.
// C++: AngelscriptSyntaxUFunctionTests.cpp::Params_Negative block 5 AssertFailsToCompile.
// sha256=ae436ce986c6600c8c994430c17909edc370434bea1630e51e6733b3e4ffce8b; lines 431-437.
// Expected diagnostic: "Reference to non-existent type should fail".
// Isolate this failing program. DiagnosticOnly.

class AUFuncPNRefBadActor : AActor
{
	UFUNCTION()
	void Foo(FNonExistent& Ref)
	{
	}
}
