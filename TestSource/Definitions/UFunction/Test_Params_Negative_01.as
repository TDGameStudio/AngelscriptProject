// Theme: Definitions.UFunction. NegativeDiagnostic: non-existent parameter type.
// C++: AngelscriptSyntaxUFunctionTests.cpp::Params_Negative block 1 AssertFailsToCompile.
// sha256=0bdf62d8fbe3ea3eb5f860e3764970d2bf0af7eeb999f66669f24fd9f50ba02d; lines 387-393.
// Expected diagnostic: "Non-existent parameter type should fail".
// Isolate this failing program. DiagnosticOnly.

class AUFuncPNBadTypeActor : AActor
{
	UFUNCTION()
	void Foo(FNonExistentType Param)
	{
	}
}
