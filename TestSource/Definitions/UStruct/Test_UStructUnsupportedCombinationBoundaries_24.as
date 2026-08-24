// Theme: Definitions.UStruct. NegativeDiagnostic: TSet<FStruct> with non-uint32 Hash.
// C++: AngelscriptCoverageUStructTests.cpp::UStructUnsupportedCombinationBoundaries
// ExpectCompileFailureWithDiagnostic: "Key type does not have a hash function defined".
// Isolate the failing program. DiagnosticOnly.

USTRUCT(BlueprintType)
struct FBadHashStructElement
{
	UPROPERTY()
	int Value = 0;

	bool opEquals(const FBadHashStructElement& Other) const
	{
		return Value == Other.Value;
	}

	int Hash() const
	{
		return Value;
	}
}

UCLASS()
class ACoverageStructBadHashSetActor : AActor
{
	UPROPERTY()
	TSet<FBadHashStructElement> Values;
}
