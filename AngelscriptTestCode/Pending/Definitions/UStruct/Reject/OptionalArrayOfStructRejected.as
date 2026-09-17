/**
 * @version v1
 * @summary TOptional of a TArray of USTRUCT is a nested container, so this program is rejected.
 * @topic Definitions
 */
/**
 * @version root
 * @summary TOptional of a TArray of USTRUCT is a nested container, so this program is rejected.
 * @topic Negative
 */
USTRUCT(BlueprintType)
struct FOptionalArrayPayloadStruct
{
	UPROPERTY()
	int Value = 0;
}

UCLASS()
class ACoverageStructOptionalArrayActor : AActor
{
	UPROPERTY()
	TOptional<TArray<FOptionalArrayPayloadStruct>> Values;
}
/** @end */
