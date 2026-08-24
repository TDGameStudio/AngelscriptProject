// Theme: Definitions.UStruct. NegativeDiagnostic: TArray<TSet<FStruct>> nested containers.
// C++: AngelscriptCoverageUStructTests.cpp::UStructUnsupportedCombinationBoundaries
// ExpectCompileFailureWithDiagnostic: "Containers cannot be nested in other containers".
// Isolate the failing program. DiagnosticOnly.

USTRUCT(BlueprintType)
struct FNestedSetStruct
{
	UPROPERTY()
	int Value = 0;
}

UCLASS()
class ACoverageStructArrayOfSetsActor : AActor
{
	UPROPERTY()
	TArray<TSet<FNestedSetStruct>> Sets;
}
