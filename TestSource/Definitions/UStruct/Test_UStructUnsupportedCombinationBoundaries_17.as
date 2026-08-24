// Theme: Definitions.UStruct. NegativeDiagnostic: TArray<TMap<int,FStruct>> nested containers.
// C++: AngelscriptCoverageUStructTests.cpp::UStructUnsupportedCombinationBoundaries
// ExpectCompileFailureWithDiagnostic: "Containers cannot be nested in other containers".
// Isolate the failing program. DiagnosticOnly.

USTRUCT(BlueprintType)
struct FNestedArrayMapStruct
{
	UPROPERTY()
	int Value = 0;
}

UCLASS()
class ACoverageStructArrayOfMapsActor : AActor
{
	UPROPERTY()
	TArray<TMap<int, FNestedArrayMapStruct>> Maps;
}
