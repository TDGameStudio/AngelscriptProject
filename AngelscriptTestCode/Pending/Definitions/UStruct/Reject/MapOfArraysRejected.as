/**
 * @version v1
 * @summary TMap of TArray of USTRUCT is a nested container, so this program is rejected.
 * @topic Definitions
 */
/**
 * @version root
 * @summary TMap of TArray of USTRUCT is a nested container, so this program is rejected.
 * @topic Negative
 */
USTRUCT(BlueprintType)
struct FNestedMapStruct
{
	UPROPERTY()
	int Value = 0;
}

UCLASS()
class ACoverageStructMapOfArraysActor : AActor
{
	UPROPERTY()
	TMap<int, TArray<FNestedMapStruct>> Groups;
}
/** @end */
