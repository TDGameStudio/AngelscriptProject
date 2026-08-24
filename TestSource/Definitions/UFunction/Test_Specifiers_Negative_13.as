// Theme: Definitions.UFunction. NegativeDiagnostic: BlueprintPure on non-const void.
// C++: AngelscriptSyntaxUFunctionTests.cpp::Specifiers_Negative block 13 AssertFailsToCompile.
// sha256=f941a8c1b8ca33f0d70692804d9a7d5c4c04b335919220b6ab7c6d0258fb0df4; lines 337-343.
// Expected diagnostic: "BlueprintPure on non-const void function should fail".
// Isolate this failing program. DiagnosticOnly.

class AUFuncPureNCActr : AActor
{
	UFUNCTION(BlueprintPure)
	void Mutate()
	{
	}
}
