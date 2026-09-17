/**
 * @version v1
 * @summary Nesting a TArray inside another TArray is rejected: containers cannot be nested in other containers. This file is the illegal program itself; do not change the element type, since the nesting is the point.
 * @topic Language
 */
/**
 * @version root
 * @summary Nesting a TArray inside another TArray is rejected: containers cannot be nested in other containers. This file is the illegal program itself; do not change the element type, since the nesting is the point.
 * @topic Negative
 */
UCLASS()
class ACoverageFloatNestedArrayActor : AActor
{
	UPROPERTY()
	TArray<TArray<float>> Matrix;
}
/** @end */
