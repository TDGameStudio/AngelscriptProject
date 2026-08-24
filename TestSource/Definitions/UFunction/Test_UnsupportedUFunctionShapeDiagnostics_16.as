// Theme: Definitions.UFunction. NegativeDiagnostic: _Validate companion must return bool.
// C++: AngelscriptCoverageUFunctionTests.cpp::UnsupportedUFunctionShapeDiagnostics case validate non-bool return.
// Expected diagnostic: "UFUNCTION() ServerBadValidateReturn in class ACoverageUFunctionBadValidateReturnActor has a _Validate function that is returning a non-bool!"
// Isolate this failing program. DiagnosticOnly.

UCLASS()
class ACoverageUFunctionBadValidateReturnActor : AActor
{
	default SetReplicates(true);

	UFUNCTION(Server, WithValidation)
	void ServerBadValidateReturn(int Value)
	{
	}

	UFUNCTION()
	int ServerBadValidateReturn_Validate(int Value)
	{
		return Value;
	}
}
