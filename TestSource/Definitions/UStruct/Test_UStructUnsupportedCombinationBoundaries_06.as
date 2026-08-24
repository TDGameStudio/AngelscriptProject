// Theme: Definitions.UStruct. NegativeDiagnostic: TOptional<FStruct> multicast event parameter.
// C++: AngelscriptCoverageUStructTests.cpp::UStructUnsupportedCombinationBoundaries
// ExpectCompileFailureWithDiagnostic: "Unknown or invalid parameter type for parameter Payload to delegate FOptionalStructEvent".
// Isolate the failing program. DiagnosticOnly.

USTRUCT(BlueprintType)
struct FOptionalEventParameterStruct
{
	UPROPERTY()
	int Value = 0;
}

event void FOptionalStructEvent(TOptional<FOptionalEventParameterStruct> Payload);

UCLASS()
class ACoverageStructOptionalEventParameterActor : AActor
{
	UPROPERTY()
	FOptionalStructEvent Signal;
}
