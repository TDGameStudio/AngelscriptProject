// Theme: Definitions.UStruct. NegativeDiagnostic: TMap<FStruct,int> without Hash/opEquals.
// C++: AngelscriptCoverageUStructTests.cpp::UStructUnsupportedCombinationBoundaries
// ExpectCompileFailureWithDiagnostic: "Key type does not have a hash function defined".
// Isolate the failing program. DiagnosticOnly.

USTRUCT(BlueprintType)
struct FUnhashableStructKey
{
	UPROPERTY()
	int Value = 0;
}

UCLASS()
class ACoverageStructUnhashableMapKeyActor : AActor
{
	UPROPERTY()
	TMap<FUnhashableStructKey, int> Values;
}
