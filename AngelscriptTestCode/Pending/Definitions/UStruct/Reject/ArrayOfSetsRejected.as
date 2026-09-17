/**
 * @version v1
 * @summary TArray of TSet of USTRUCT is a nested container, so this program is rejected.
 * @topic Definitions
 */
/**
 * @version root
 * @summary TArray of TSet of USTRUCT is a nested container, so this program is rejected.
 * @topic Negative
 */
USTRUCT(BlueprintType)
struct FNestedSetStruct
{
	UPROPERTY()
	int Value = 0;
}

UCLASS()
class ACoverageStructArrayOfSetsActor : AActor
{
	UPROPERTY()
	TArray<TSet<FNestedSetStruct>> Sets;
}
/** @end */
