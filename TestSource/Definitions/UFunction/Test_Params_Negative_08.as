// Theme: Definitions.UFunction. NegativeDiagnostic: keyword as parameter name.
// C++: AngelscriptSyntaxUFunctionTests.cpp::Params_Negative block 8 AssertFailsToCompile.
// sha256=f8f54c34b46b6812d2f1928e6d9c52b5e2883b8755dcc909a58654242fb1949f; lines 464-470.
// Expected diagnostic: "Keyword as parameter name should fail".
// Isolate this failing program. DiagnosticOnly.

class AUFuncPNKeywordActor : AActor
{
	UFUNCTION()
	void Foo(int class)
	{
	}
}
