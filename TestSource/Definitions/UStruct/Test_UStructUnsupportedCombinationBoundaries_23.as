// Theme: Definitions.UStruct. NegativeDiagnostic: TMap<FStruct,int> with opEquals but no Hash.
// C++: AngelscriptCoverageUStructTests.cpp::UStructUnsupportedCombinationBoundaries
// ExpectCompileFailureWithDiagnostic: "Key type does not have a hash function defined".
// Isolate the failing program. DiagnosticOnly.

USTRUCT(BlueprintType)
struct FOnlyEqualsStructKey
{
	UPROPERTY()
	int Value = 0;

	bool opEquals(const FOnlyEqualsStructKey& Other) const
	{
		return Value == Other.Value;
	}
}

UCLASS()
class ACoverageStructOnlyEqualsMapKeyActor : AActor
{
	UPROPERTY()
	TMap<FOnlyEqualsStructKey, int> Values;
}
