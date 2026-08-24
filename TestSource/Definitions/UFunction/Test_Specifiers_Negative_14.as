// Theme: Definitions.UFunction. NegativeDiagnostic: UFUNCTION on a constructor.
// C++: AngelscriptSyntaxUFunctionTests.cpp::Specifiers_Negative block 14 AssertFailsToCompile.
// sha256=c266124d4f7ff774ec32dc1d9de6809ba879f2c1e9a8bec1b8658bc7dff55e19; lines 348-354.
// Expected diagnostic: "UFUNCTION on constructor should fail".
// Isolate this failing program. DiagnosticOnly.

class AUFuncCtorActor : AActor
{
	UFUNCTION()
	AUFuncCtorActor()
	{
	}
}
