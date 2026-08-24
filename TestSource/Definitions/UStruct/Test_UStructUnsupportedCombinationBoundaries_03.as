// Theme: Definitions.UStruct. NegativeDiagnostic: TOptional<FStruct> out UFUNCTION parameter.
// C++: AngelscriptCoverageUStructTests.cpp::UStructUnsupportedCombinationBoundaries
// ExpectCompileFailureWithDiagnostic: "Unknown or invalid parameter type for parameter Payload".
// Isolate the failing program. DiagnosticOnly.

USTRUCT(BlueprintType)
struct FOptionalOutParameterStruct
{
	UPROPERTY()
	int Value = 0;
}

UCLASS()
class ACoverageStructOptionalOutParameterActor : AActor
{
	UFUNCTION(BlueprintCallable)
	void FillOptional(TOptional<FOptionalOutParameterStruct>&out Payload)
	{
	}
}
