// Theme: Definitions.UStruct. NegativeDiagnostic: TSet<TOptional<FStruct>> nested containers.
// C++: AngelscriptCoverageUStructTests.cpp::UStructUnsupportedCombinationBoundaries
// ExpectCompileFailureWithDiagnostic: "Containers cannot be nested in other containers".
// Isolate the failing program. DiagnosticOnly.

USTRUCT(BlueprintType)
struct FOptionalSetElementStruct
{
	UPROPERTY()
	int Value = 0;
}

UCLASS()
class ACoverageStructSetOfOptionalActor : AActor
{
	UPROPERTY()
	TSet<TOptional<FOptionalSetElementStruct>> Values;
}
