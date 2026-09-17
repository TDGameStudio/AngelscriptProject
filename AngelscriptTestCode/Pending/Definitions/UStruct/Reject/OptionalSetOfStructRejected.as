/**
 * @version v1
 * @summary TOptional of a TSet of USTRUCT is a nested container, so this program is rejected.
 * @topic Definitions
 */
/**
 * @version root
 * @summary TOptional of a TSet of USTRUCT is a nested container, so this program is rejected.
 * @topic Negative
 */
USTRUCT(BlueprintType)
struct FOptionalSetPayloadStruct
{
	UPROPERTY()
	int Value = 0;
}

UCLASS()
class ACoverageStructOptionalSetActor : AActor
{
	UPROPERTY()
	TOptional<TSet<FOptionalSetPayloadStruct>> Values;
}
/** @end */
