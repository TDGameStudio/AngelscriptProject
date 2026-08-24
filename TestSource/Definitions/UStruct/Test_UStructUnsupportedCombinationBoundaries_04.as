// Theme: Definitions.UStruct. NegativeDiagnostic: TOptional<FStruct> inout UFUNCTION parameter.
// C++: AngelscriptCoverageUStructTests.cpp::UStructUnsupportedCombinationBoundaries
// ExpectCompileFailureWithDiagnostic: "Unknown or invalid parameter type for parameter Payload".
// Isolate the failing program. DiagnosticOnly.

USTRUCT(BlueprintType)
struct FOptionalInoutParameterStruct
{
	UPROPERTY()
	int Value = 0;
}

UCLASS()
class ACoverageStructOptionalInoutParameterActor : AActor
{
	UFUNCTION(BlueprintCallable)
	void MutateOptional(TOptional<FOptionalInoutParameterStruct>&inout Payload)
	{
	}
}
