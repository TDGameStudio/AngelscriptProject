// Theme: Definitions.UStruct. NegativeDiagnostic: TMap<int,TMap<int,FStruct>> nested containers.
// C++: AngelscriptCoverageUStructTests.cpp::UStructUnsupportedCombinationBoundaries
// ExpectCompileFailureWithDiagnostic: "Containers cannot be nested in other containers".
// Isolate the failing program. DiagnosticOnly.

USTRUCT(BlueprintType)
struct FNestedMapMapStruct
{
	UPROPERTY()
	int Value = 0;
}

UCLASS()
class ACoverageStructMapOfMapsActor : AActor
{
	UPROPERTY()
	TMap<int, TMap<int, FNestedMapMapStruct>> Groups;
}
