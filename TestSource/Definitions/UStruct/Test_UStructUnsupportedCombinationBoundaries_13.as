// Theme: Definitions.UStruct. NegativeDiagnostic: TOptional<TSet<FStruct>> nested containers.
// C++: AngelscriptCoverageUStructTests.cpp::UStructUnsupportedCombinationBoundaries
// ExpectCompileFailureWithDiagnostic: "Containers cannot be nested in other containers".
// Isolate the failing program. DiagnosticOnly.

USTRUCT(BlueprintType)
struct FOptionalSetPayloadStruct
{
	UPROPERTY()
	int Value = 0;
}

UCLASS()
class ACoverageStructOptionalSetActor : AActor
{
	UPROPERTY()
	TOptional<TSet<FOptionalSetPayloadStruct>> Values;
}
