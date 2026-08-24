// Theme: Definitions.UStruct. NegativeDiagnostic: TOptional<FStruct> const-ref UFUNCTION parameter.
// C++: AngelscriptCoverageUStructTests.cpp::UStructUnsupportedCombinationBoundaries
// ExpectCompileFailureWithDiagnostic: "Unknown or invalid parameter type for parameter Payload".
// Isolate the failing program. DiagnosticOnly.

USTRUCT(BlueprintType)
struct FOptionalConstRefParameterStruct
{
	UPROPERTY()
	int Value = 0;
}

UCLASS()
class ACoverageStructOptionalConstRefParameterActor : AActor
{
	UFUNCTION(BlueprintCallable)
	void AcceptOptionalConstRef(const TOptional<FOptionalConstRefParameterStruct>&in Payload)
	{
	}
}
