/**
 * @version v1
 * @summary TArray of TArray of USTRUCT is a nested container, so this program is rejected.
 * @topic Definitions
 */
/**
 * @version root
 * @summary TArray of TArray of USTRUCT is a nested container, so this program is rejected.
 * @topic Negative
 */
USTRUCT(BlueprintType)
struct FNestedContainerStruct
{
	UPROPERTY()
	int Value = 0;
}

UCLASS()
class ACoverageStructArrayOfArraysActor : AActor
{
	UPROPERTY()
	TArray<TArray<FNestedContainerStruct>> Matrix;
}
/** @end */
