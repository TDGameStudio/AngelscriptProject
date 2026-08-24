// Theme: Definitions.UFunction. NegativeDiagnostic: TArray of a non-existent element type.
// C++: AngelscriptSyntaxUFunctionTests.cpp::Params_Negative block 6 AssertFailsToCompile.
// sha256=b24281d7082a7692e9f8820205f821d4ac4f2f4dfab54ac3f6f3cc5e933784de; lines 442-448.
// Expected diagnostic: "TArray param with non-existent element type should fail".
// Isolate this failing program. DiagnosticOnly.

class AUFuncPNArrBadActor : AActor
{
	UFUNCTION()
	void Foo(TArray<FBogus> Items)
	{
	}
}
