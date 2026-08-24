// Theme: Definitions.UStruct. NegativeDiagnostic: TMap<int,TArray<FStruct>> nested containers.
// C++: AngelscriptCoverageUStructTests.cpp::UStructUnsupportedCombinationBoundaries
// ExpectCompileFailureWithDiagnostic: "Containers cannot be nested in other containers".
// Isolate the failing program. DiagnosticOnly.

USTRUCT(BlueprintType)
struct FNestedMapStruct
{
	UPROPERTY()
	int Value = 0;
}

UCLASS()
class ACoverageStructMapOfArraysActor : AActor
{
	UPROPERTY()
	TMap<int, TArray<FNestedMapStruct>> Groups;
}
