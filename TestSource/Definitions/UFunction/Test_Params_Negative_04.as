// Theme: Definitions.UFunction. NegativeDiagnostic: auto parameter type.
// C++: AngelscriptSyntaxUFunctionTests.cpp::Params_Negative block 4 AssertFailsToCompile.
// sha256=2cbfb17ad1d053c9b46a3c1e7c9ee835c68774eefbf0405fb5fdae349b90f60b; lines 420-426.
// Expected diagnostic: "auto parameter type should fail".
// Isolate this failing program. DiagnosticOnly.

class AUFuncPNAutoActor : AActor
{
	UFUNCTION()
	void Foo(auto X)
	{
	}
}
