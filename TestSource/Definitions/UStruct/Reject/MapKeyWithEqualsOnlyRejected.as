/**
 * A USTRUCT TMap key that defines opEquals but not Hash is rejected.
 *
 * @Theme Definitions.UStruct
 * @Subject UStruct.MapKeyWithEqualsOnlyRejected
 * @Harness CompileReject
 * @Tag Definitions.UStruct.MapKeyWithEqualsOnlyRejected
 * @Kind CompileReject
 * @Covers UStruct.MapKeyWithEqualsOnlyRejected
 * @Inputs TMap<FOnlyEqualsStructKey, int> Values
 * @Return does not compile; diagnostic "Key type does not have a hash function defined"
 * @Provenance Theme: Definitions.UStruct. NegativeDiagnostic: TMap<FStruct,int> with opEquals but no Hash.
 * @Provenance C++: AngelscriptCoverageUStructTests.cpp::UStructUnsupportedCombinationBoundaries
 * @Provenance ExpectCompileFailureWithDiagnostic: "Key type does not have a hash function defined".
 * @Provenance Isolate the failing program. DiagnosticOnly.
 */

USTRUCT(BlueprintType)
struct FOnlyEqualsStructKey
{
	UPROPERTY()
	int Value = 0;

	/**
	 * Compare two keys by Value. Hash is intentionally absent so the map is rejected.
	 *
	 * @Kind CompileReject
	 * @Covers UStruct.MapKeyWithEqualsOnlyRejected
	 * @Inputs another FOnlyEqualsStructKey
	 * @Return true when Value matches
	 * @Param Other the other key
	 */
	bool opEquals(const FOnlyEqualsStructKey&in Other) const
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
