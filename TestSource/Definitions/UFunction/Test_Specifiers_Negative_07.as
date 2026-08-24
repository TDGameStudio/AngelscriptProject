// Theme: Definitions.UFunction. NegativeDiagnostic: BlueprintEvent with non-void return.
// C++: AngelscriptSyntaxUFunctionTests.cpp::Specifiers_Negative block 7 AssertFailsToCompile.
// sha256=77648f9a3c595b56ced25e90118004867a0d875cf7c864e25b7328ac518aaf1c; lines 267-273.
// C++ currently wraps this AssertFailsToCompile in #if 0
// (#as-engine-behavior structural-validation-absent). Isolated failing program kept.
// Expected diagnostic: "BlueprintEvent with non-void return should fail".
// DiagnosticOnly.

class AUFuncBPEvNVActor : AActor
{
	UFUNCTION(BlueprintEvent)
	int GetVal()
	{
		return 0;
	}
}
