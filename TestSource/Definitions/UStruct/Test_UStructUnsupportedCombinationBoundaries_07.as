// Theme: Definitions.UStruct. NegativeDiagnostic: TArray<TOptional<FStruct>> nested containers.
// C++: AngelscriptCoverageUStructTests.cpp::UStructUnsupportedCombinationBoundaries
// ExpectCompileFailureWithDiagnostic: "Containers cannot be nested in other containers".
// Isolate the failing program. DiagnosticOnly.

USTRUCT(BlueprintType)
struct FOptionalArrayElementStruct
{
	UPROPERTY()
	int Value = 0;
}

UCLASS()
class ACoverageStructArrayOfOptionalActor : AActor
{
	UPROPERTY()
	TArray<TOptional<FOptionalArrayElementStruct>> Values;
}
