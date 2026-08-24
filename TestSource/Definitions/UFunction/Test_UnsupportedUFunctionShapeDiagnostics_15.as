// Theme: Definitions.UFunction. NegativeDiagnostic: WithValidation without _Validate companion.
// C++: AngelscriptCoverageUFunctionTests.cpp::UnsupportedUFunctionShapeDiagnostics case missing validate companion.
// Expected diagnostic: "UFUNCTION() ServerMissingValidate in class ACoverageUFunctionMissingValidateActor is marked as WithValidate but no _Validate function provided! Is it marked as UFUNCTION()?"
// Isolate this failing program. DiagnosticOnly.

UCLASS()
class ACoverageUFunctionMissingValidateActor : AActor
{
	default SetReplicates(true);

	UFUNCTION(Server, WithValidation)
	void ServerMissingValidate(int Value)
	{
	}
}
