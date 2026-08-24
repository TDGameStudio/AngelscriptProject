// Theme: Definitions.UFunction. NegativeDiagnostic: non-existent return type.
// C++: AngelscriptSyntaxUFunctionTests.cpp::Params_Negative block 7 AssertFailsToCompile.
// sha256=3ee321eab5c8fa8cbf0df2a64bacc4f0e4752c07de4ace92d599db794cd4fa96; lines 453-459.
// Expected diagnostic: "Non-existent return type should fail".
// Isolate this failing program. DiagnosticOnly.

class AUFuncPNBadRetActor : AActor
{
	UFUNCTION()
	FNonExistentType Foo()
	{
	}
}
