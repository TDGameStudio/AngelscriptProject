/**
 * @version v1
 * @summary TMap with a TOptional USTRUCT key is a nested container, so this program is rejected.
 * @topic Definitions
 */
/**
 * @version root
 * @summary TMap with a TOptional USTRUCT key is a nested container, so this program is rejected.
 * @topic Negative
 */
USTRUCT(BlueprintType)
struct FOptionalMapKeyStruct
{
	UPROPERTY()
	int Value = 0;
}

UCLASS()
class ACoverageStructMapKeyOptionalActor : AActor
{
	UPROPERTY()
	TMap<TOptional<FOptionalMapKeyStruct>, int> Values;
}
/** @end */
