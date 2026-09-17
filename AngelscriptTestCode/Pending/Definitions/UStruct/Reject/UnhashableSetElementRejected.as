/**
 * @version v1
 * @summary A USTRUCT used as a TSet element without Hash or opEquals is rejected.
 * @topic Definitions
 */
/**
 * @version root
 * @summary A USTRUCT used as a TSet element without Hash or opEquals is rejected.
 * @topic Negative
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
/** @end */
