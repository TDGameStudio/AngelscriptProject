// Theme: Definitions.UStruct. NegativeDiagnostic: TMap<int,TOptional<FStruct>> nested containers.
// C++: AngelscriptCoverageUStructTests.cpp::UStructUnsupportedCombinationBoundaries
// ExpectCompileFailureWithDiagnostic: "Containers cannot be nested in other containers".
// Isolate the failing program. DiagnosticOnly.

USTRUCT(BlueprintType)
struct FOptionalMapValueStruct
{
	UPROPERTY()
	int Value = 0;
}

UCLASS()
class ACoverageStructMapValueOptionalActor : AActor
{
	UPROPERTY()
	TMap<int, TOptional<FOptionalMapValueStruct>> Values;
}
