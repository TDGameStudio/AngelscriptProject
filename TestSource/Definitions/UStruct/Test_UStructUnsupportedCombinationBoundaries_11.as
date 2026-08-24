// Theme: Definitions.UStruct. NegativeDiagnostic: TOptional<TArray<FStruct>> nested containers.
// C++: AngelscriptCoverageUStructTests.cpp::UStructUnsupportedCombinationBoundaries
// ExpectCompileFailureWithDiagnostic: "Containers cannot be nested in other containers".
// Isolate the failing program. DiagnosticOnly.

USTRUCT(BlueprintType)
struct FOptionalArrayPayloadStruct
{
	UPROPERTY()
	int Value = 0;
}

UCLASS()
class ACoverageStructOptionalArrayActor : AActor
{
	UPROPERTY()
	TOptional<TArray<FOptionalArrayPayloadStruct>> Values;
}
