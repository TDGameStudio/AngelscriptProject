/**
 * @version v1
 * @summary A USTRUCT used as a TMap key without Hash or opEquals is rejected.
 * @topic Definitions
 */
/**
 * @version root
 * @summary A USTRUCT used as a TMap key without Hash or opEquals is rejected.
 * @topic Negative
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
/** @end */
