/**
 * @version v1
 * @summary TSet of TOptional USTRUCT is a nested container, so this program is rejected.
 * @topic Definitions
 */
/**
 * @version root
 * @summary TSet of TOptional USTRUCT is a nested container, so this program is rejected.
 * @topic Negative
 */
USTRUCT(BlueprintType)
struct FOptionalSetElementStruct
{
	UPROPERTY()
	int Value = 0;
}

UCLASS()
class ACoverageStructSetOfOptionalActor : AActor
{
	UPROPERTY()
	TSet<TOptional<FOptionalSetElementStruct>> Values;
}
/** @end */
