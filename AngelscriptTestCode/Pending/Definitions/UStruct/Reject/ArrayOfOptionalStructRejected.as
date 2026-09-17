/**
 * @version v1
 * @summary TArray of TOptional USTRUCT is a nested container, so this program is rejected.
 * @topic Definitions
 */
/**
 * @version root
 * @summary TArray of TOptional USTRUCT is a nested container, so this program is rejected.
 * @topic Negative
 */
USTRUCT(BlueprintType)
struct FOptionalArrayElementStruct
{
	UPROPERTY()
	int Value = 0;
}

UCLASS()
class ACoverageStructArrayOfOptionalActor : AActor
{
	UPROPERTY()
	TArray<TOptional<FOptionalArrayElementStruct>> Values;
}
/** @end */
