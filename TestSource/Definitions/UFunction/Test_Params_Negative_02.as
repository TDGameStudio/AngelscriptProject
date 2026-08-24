// Theme: Definitions.UFunction. NegativeDiagnostic: void parameter type.
// C++: AngelscriptSyntaxUFunctionTests.cpp::Params_Negative block 2 AssertFailsToCompile.
// sha256=d9e938e8d063dbe27df057df9371d9ede37e57b8f0c139d27f958b4afd88eb95; lines 398-404.
// Expected diagnostic: "void parameter type should fail".
// Isolate this failing program. DiagnosticOnly.

class AUFuncPNVoidActor : AActor
{
	UFUNCTION()
	void Foo(void Param)
	{
	}
}
