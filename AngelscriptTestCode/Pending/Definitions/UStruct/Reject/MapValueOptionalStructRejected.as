/**
 * @version v1
 * @summary TMap with a TOptional USTRUCT value is a nested container, so this program is rejected.
 * @topic Definitions
 */
/**
 * @version root
 * @summary TMap with a TOptional USTRUCT value is a nested container, so this program is rejected.
 * @topic Negative
 */
USTRUCT(BlueprintType)
struct FOptionalMapValueStruct
{
	UPROPERTY()
	int Value = 0;
}

UCLASS()
class ACoverageStructMapValueOptionalActor : AActor
{
	UPROPERTY()
	TMap<int, TOptional<FOptionalMapValueStruct>> Values;
}
/** @end */
