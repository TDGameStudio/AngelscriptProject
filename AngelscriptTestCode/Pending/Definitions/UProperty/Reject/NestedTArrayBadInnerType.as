/**
 * @version v1
 * @summary A nested TArray whose inner type does not exist is rejected. This file is the illegal program itself; do not declare FBogus.
 * @topic Definitions
 */
/**
 * @version root
 * @summary A nested TArray whose inner type does not exist is rejected. This file is the illegal program itself; do not declare FBogus.
 * @topic Negative
 */
class AUPropNestedBadActor : AActor
{
	UPROPERTY()
	TArray<TArray<FBogus>> Nested;
}
/** @end */
