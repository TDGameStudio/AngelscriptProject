// Theme: Definitions.UFunction. NegativeDiagnostic: duplicate parameter names.
// C++: AngelscriptSyntaxUFunctionTests.cpp::Params_Negative block 3 AssertFailsToCompile.
// sha256=c555a16e35e96b943dedd3eb71dee3fcd3634f2f5d17af0668ae598fc7db8371; lines 409-415.
// Expected diagnostic: "Duplicate parameter names should fail".
// Isolate this failing program. DiagnosticOnly.

class AUFuncPNDupNameActor : AActor
{
	UFUNCTION()
	void Foo(int X, float X)
	{
	}
}
