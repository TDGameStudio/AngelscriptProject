/**
 * @version v1
 * @summary A USTRUCT TSet element whose Hash returns int rather than uint32 is rejected.
 * @topic Definitions
 */
/**
 * @version root
 * @summary A USTRUCT TSet element whose Hash returns int rather than uint32 is rejected.
 * @topic Negative
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
/** @end */
