/**
 * A USTRUCT used as a TSet element without Hash or opEquals is rejected.
 *
 * @Theme Definitions.UStruct
 * @Subject UStruct.UnhashableSetElementRejected
 * @Harness CompileReject
 * @Tag Definitions.UStruct.UnhashableSetElementRejected
 * @Kind CompileReject
 * @Covers UStruct.UnhashableSetElementRejected
 * @Inputs TSet<FUnhashableStructElement> Values
 * @Return does not compile; diagnostic "Key type does not have a hash function defined"
 * @Provenance Theme: Definitions.UStruct. NegativeDiagnostic: TSet<FStruct> without Hash/opEquals.
 * @Provenance C++: AngelscriptCoverageUStructTests.cpp::UStructUnsupportedCombinationBoundaries
 * @Provenance ExpectCompileFailureWithDiagnostic: "Key type does not have a hash function defined".
 * @Provenance Isolate the failing program. DiagnosticOnly.
 */

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
