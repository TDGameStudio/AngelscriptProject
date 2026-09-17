/**
 * @version v1
 * @summary TSet of TArray of USTRUCT is a nested container, so this program is rejected.
 * @topic Definitions
 */
/**
 * @version root
 * @summary TSet of TArray of USTRUCT is a nested container, so this program is rejected.
 * @topic Negative
 */
USTRUCT(BlueprintType)
struct FNestedSetArrayStruct
{
	UPROPERTY()
	int Value = 0;
}

UCLASS()
class ACoverageStructSetOfArraysActor : AActor
{
	UPROPERTY()
	TSet<TArray<FNestedSetArrayStruct>> Groups;
}
/** @end */
