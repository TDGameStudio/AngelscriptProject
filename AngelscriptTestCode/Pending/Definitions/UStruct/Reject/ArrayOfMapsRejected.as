/**
 * @version v1
 * @summary TArray of TMap of USTRUCT is a nested container, so this program is rejected.
 * @topic Definitions
 */
/**
 * @version root
 * @summary TArray of TMap of USTRUCT is a nested container, so this program is rejected.
 * @topic Negative
 */
USTRUCT(BlueprintType)
struct FNestedArrayMapStruct
{
	UPROPERTY()
	int Value = 0;
}

UCLASS()
class ACoverageStructArrayOfMapsActor : AActor
{
	UPROPERTY()
	TArray<TMap<int, FNestedArrayMapStruct>> Maps;
}
/** @end */
