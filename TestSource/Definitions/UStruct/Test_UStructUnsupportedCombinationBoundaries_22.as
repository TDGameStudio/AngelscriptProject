// Theme: Definitions.UStruct. NegativeDiagnostic: TSet<FStruct> without Hash/opEquals.
// C++: AngelscriptCoverageUStructTests.cpp::UStructUnsupportedCombinationBoundaries
// ExpectCompileFailureWithDiagnostic: "Key type does not have a hash function defined".
// Isolate the failing program. DiagnosticOnly.

USTRUCT(BlueprintType)
struct FUnhashableStructElement
{
	UPROPERTY()
	int Value = 0;
}

UCLASS()
class ACoverageStructUnhashableSetActor : AActor
{
	UPROPERTY()
	TSet<FUnhashableStructElement> Values;
}
