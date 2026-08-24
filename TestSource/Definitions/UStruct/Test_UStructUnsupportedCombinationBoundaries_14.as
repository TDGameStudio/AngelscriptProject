// Theme: Definitions.UStruct. NegativeDiagnostic: TArray<TArray<FStruct>> nested containers.
// C++: AngelscriptCoverageUStructTests.cpp::UStructUnsupportedCombinationBoundaries
// ExpectCompileFailureWithDiagnostic: "Containers cannot be nested in other containers".
// Isolate the failing program. DiagnosticOnly.

USTRUCT(BlueprintType)
struct FNestedContainerStruct
{
	UPROPERTY()
	int Value = 0;
}

UCLASS()
class ACoverageStructArrayOfArraysActor : AActor
{
	UPROPERTY()
	TArray<TArray<FNestedContainerStruct>> Matrix;
}
