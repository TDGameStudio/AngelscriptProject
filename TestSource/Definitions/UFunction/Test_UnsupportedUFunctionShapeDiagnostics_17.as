// Theme: Definitions.UFunction. NegativeDiagnostic: _Validate companion parameters must match.
// C++: AngelscriptCoverageUFunctionTests.cpp::UnsupportedUFunctionShapeDiagnostics case validate parameter mismatch.
// Expected diagnostic: "UFUNCTION() ServerBadValidateParams in class ACoverageUFunctionBadValidateParamsActor has a _Validate function but the parameters don't match!"
// Isolate this failing program. DiagnosticOnly.

UCLASS()
class ACoverageUFunctionBadValidateParamsActor : AActor
{
	default SetReplicates(true);

	UFUNCTION(Server, WithValidation)
	void ServerBadValidateParams(int Value)
	{
	}

	UFUNCTION()
	bool ServerBadValidateParams_Validate(FString Value)
	{
		return !Value.IsEmpty();
	}
}
