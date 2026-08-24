// Theme: Definitions.UStruct. NegativeDiagnostic: TMap<int,TSet<FStruct>> nested containers.
// C++: AngelscriptCoverageUStructTests.cpp::UStructUnsupportedCombinationBoundaries
// ExpectCompileFailureWithDiagnostic: "Containers cannot be nested in other containers".
// Isolate the failing program. DiagnosticOnly.

USTRUCT(BlueprintType)
struct FNestedMapSetStruct
{
	UPROPERTY()
	int Value = 0;
}

UCLASS()
class ACoverageStructMapOfSetsActor : AActor
{
	UPROPERTY()
	TMap<int, TSet<FNestedMapSetStruct>> Groups;
}
