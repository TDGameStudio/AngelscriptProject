// Theme: Definitions.UStruct. NegativeDiagnostic: TSet<TArray<FStruct>> nested containers.
// C++: AngelscriptCoverageUStructTests.cpp::UStructUnsupportedCombinationBoundaries
// ExpectCompileFailureWithDiagnostic: "Containers cannot be nested in other containers".
// Isolate the failing program. DiagnosticOnly.

USTRUCT(BlueprintType)
struct FNestedSetArrayStruct
{
	UPROPERTY()
	int Value = 0;
}

UCLASS()
class ACoverageStructSetOfArraysActor : AActor
{
	UPROPERTY()
	TSet<TArray<FNestedSetArrayStruct>> Groups;
}
