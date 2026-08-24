// Theme: Definitions.UStruct. NegativeDiagnostic: TMap<TOptional<FStruct>,int> nested containers.
// C++: AngelscriptCoverageUStructTests.cpp::UStructUnsupportedCombinationBoundaries
// ExpectCompileFailureWithDiagnostic: "Containers cannot be nested in other containers".
// Isolate the failing program. DiagnosticOnly.

USTRUCT(BlueprintType)
struct FOptionalMapKeyStruct
{
	UPROPERTY()
	int Value = 0;
}

UCLASS()
class ACoverageStructMapKeyOptionalActor : AActor
{
	UPROPERTY()
	TMap<TOptional<FOptionalMapKeyStruct>, int> Values;
}
