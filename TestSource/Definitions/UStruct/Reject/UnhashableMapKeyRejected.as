/**
 * A USTRUCT used as a TMap key without Hash or opEquals is rejected.
 *
 * @Theme Definitions.UStruct
 * @Subject UStruct.UnhashableMapKeyRejected
 * @Harness CompileReject
 * @Tag Definitions.UStruct.UnhashableMapKeyRejected
 * @Kind CompileReject
 * @Covers UStruct.UnhashableMapKeyRejected
 * @Inputs TMap<FUnhashableStructKey, int> Values
 * @Return does not compile; diagnostic "Key type does not have a hash function defined"
 * @Provenance Theme: Definitions.UStruct. NegativeDiagnostic: TMap<FStruct,int> without Hash/opEquals.
 * @Provenance C++: AngelscriptCoverageUStructTests.cpp::UStructUnsupportedCombinationBoundaries
 * @Provenance ExpectCompileFailureWithDiagnostic: "Key type does not have a hash function defined".
 * @Provenance Isolate the failing program. DiagnosticOnly.
 */

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
