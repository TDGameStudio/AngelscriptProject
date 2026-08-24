// Theme: Definitions.UStruct. NegativeDiagnostic: TOptional<FStruct> delegate parameter.
// C++: AngelscriptCoverageUStructTests.cpp::UStructUnsupportedCombinationBoundaries
// ExpectCompileFailureWithDiagnostic: "Unknown or invalid parameter type for parameter Payload to delegate FOptionalStructSignal".
// Isolate the failing program. DiagnosticOnly.

USTRUCT(BlueprintType)
struct FOptionalDelegateParameterStruct
{
	UPROPERTY()
	int Value = 0;
}

delegate void FOptionalStructSignal(TOptional<FOptionalDelegateParameterStruct> Payload);

UCLASS()
class ACoverageStructOptionalDelegateParameterActor : AActor
{
	UPROPERTY()
	FOptionalStructSignal Signal;
}
