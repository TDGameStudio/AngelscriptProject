// Theme: Definitions.UFunction. NegativeDiagnostic: TSubclassOf of a non-UObject.
// C++: AngelscriptSyntaxUFunctionTests.cpp::Params_Negative block 10 AssertFailsToCompile.
// sha256=c1f3790b2ab1dd25b9674272ca1ac5da128855a277f51efe9759125ce948dccc; lines 486-492.
// Expected diagnostic: "TSubclassOf with non-UObject param type should fail".
// Isolate this failing program. DiagnosticOnly.

class AUFuncPNSubNonObjActor : AActor
{
	UFUNCTION()
	void Foo(TSubclassOf<int> C)
	{
	}
}
