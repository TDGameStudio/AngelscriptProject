// Theme: Definitions.UStruct. NegativeDiagnostic: TOptional<FStruct> UFUNCTION parameter.
// C++: AngelscriptCoverageUStructTests.cpp::UStructUnsupportedCombinationBoundaries
// ExpectCompileFailureWithDiagnostic: "Unknown or invalid parameter type for parameter Payload".
// Isolate the failing program. Do not add declarations that would compile it away.
// DiagnosticOnly.

USTRUCT(BlueprintType)
struct FOptionalParameterStruct
{
	UPROPERTY()
	int Value = 0;
}

UCLASS()
class ACoverageStructOptionalParameterActor : AActor
{
	UFUNCTION(BlueprintCallable)
	void AcceptOptional(TOptional<FOptionalParameterStruct> Payload)
	{
	}
}
