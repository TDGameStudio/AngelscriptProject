/**
 * @version v1
 * @summary TOptional of a TMap of USTRUCT is a nested container, so this program is rejected.
 * @topic Definitions
 */
/**
 * @version root
 * @summary TOptional of a TMap of USTRUCT is a nested container, so this program is rejected.
 * @topic Negative
 */
USTRUCT(BlueprintType)
struct FOptionalMapPayloadStruct
{
	UPROPERTY()
	int Value = 0;
}

UCLASS()
class ACoverageStructOptionalMapActor : AActor
{
	UPROPERTY()
	TOptional<TMap<int, FOptionalMapPayloadStruct>> Values;
}
/** @end */
