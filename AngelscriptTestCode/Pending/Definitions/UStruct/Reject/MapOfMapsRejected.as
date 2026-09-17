/**
 * @version v1
 * @summary TMap of TMap of USTRUCT is a nested container, so this program is rejected.
 * @topic Definitions
 */
/**
 * @version root
 * @summary TMap of TMap of USTRUCT is a nested container, so this program is rejected.
 * @topic Negative
 */
USTRUCT(BlueprintType)
struct FNestedMapMapStruct
{
	UPROPERTY()
	int Value = 0;
}

UCLASS()
class ACoverageStructMapOfMapsActor : AActor
{
	UPROPERTY()
	TMap<int, TMap<int, FNestedMapMapStruct>> Groups;
}
/** @end */
