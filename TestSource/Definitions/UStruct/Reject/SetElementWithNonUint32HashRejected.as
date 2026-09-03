/**
 * A USTRUCT TSet element whose Hash returns int rather than uint32 is rejected.
 *
 * @Theme Definitions.UStruct
 * @Subject UStruct.SetElementWithNonUint32HashRejected
 * @Harness CompileReject
 * @Tag Definitions.UStruct.SetElementWithNonUint32HashRejected
 * @Kind CompileReject
 * @Covers UStruct.SetElementWithNonUint32HashRejected
 * @Inputs TSet<FBadHashStructElement> Values
 * @Return does not compile; diagnostic "Key type does not have a hash function defined"
 * @Provenance Theme: Definitions.UStruct. NegativeDiagnostic: TSet<FStruct> with non-uint32 Hash.
 * @Provenance C++: AngelscriptCoverageUStructTests.cpp::UStructUnsupportedCombinationBoundaries
 * @Provenance ExpectCompileFailureWithDiagnostic: "Key type does not have a hash function defined".
 * @Provenance Isolate the failing program. DiagnosticOnly.
 */

USTRUCT(BlueprintType)
struct FBadHashStructElement
{
	UPROPERTY()
	int Value = 0;

	/**
	 * Compare two elements by Value.
	 *
	 * @Kind CompileReject
	 * @Covers UStruct.SetElementWithNonUint32HashRejected
	 * @Inputs another FBadHashStructElement
	 * @Return true when Value matches
	 * @Param Other the other element
	 */
	bool opEquals(const FBadHashStructElement&in Other) const
	{
		return Value == Other.Value;
	}

	/**
	 * The isolated failing Hash: int is not a uint32 hash function.
	 *
	 * @Kind CompileReject
	 * @Covers UStruct.SetElementWithNonUint32HashRejected
	 * @Inputs none
	 * @Return does not compile as a set-element hash; Hash must be uint32
	 */
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
