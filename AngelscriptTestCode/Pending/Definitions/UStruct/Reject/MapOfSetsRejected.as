/**
 * @version v1
 * @summary TMap of TSet of USTRUCT is a nested container, so this program is rejected.
 * @topic Definitions
 */
/**
 * @version root
 * @summary TMap of TSet of USTRUCT is a nested container, so this program is rejected.
 * @topic Negative
 */
USTRUCT(BlueprintType)
struct FNestedMapSetStruct
{
	UPROPERTY()
	int Value = 0;
}

UCLASS()
class ACoverageStructMapOfSetsActor : AActor
{
	UPROPERTY()
	TMap<int, TSet<FNestedMapSetStruct>> Groups;
}
/** @end */
