// Theme: Definitions.UStruct. NegativeDiagnostic: TOptional<TMap<int,FStruct>> nested containers.
// C++: AngelscriptCoverageUStructTests.cpp::UStructUnsupportedCombinationBoundaries
// ExpectCompileFailureWithDiagnostic: "Containers cannot be nested in other containers".
// Isolate the failing program. DiagnosticOnly.

USTRUCT(BlueprintType)
struct FOptionalMapPayloadStruct
{
	UPROPERTY()
	int Value = 0;
}

UCLASS()
class ACoverageStructOptionalMapActor : AActor
{
	UPROPERTY()
	TOptional<TMap<int, FOptionalMapPayloadStruct>> Values;
}
