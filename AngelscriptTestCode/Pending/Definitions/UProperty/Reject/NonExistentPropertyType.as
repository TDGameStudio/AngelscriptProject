/**
 * @version v1
 * @summary A UPROPERTY whose type does not exist is rejected. This file is the illegal program itself; do not declare FNonExistentType.
 * @topic Definitions
 */
/**
 * @version root
 * @summary A UPROPERTY whose type does not exist is rejected. This file is the illegal program itself; do not declare FNonExistentType.
 * @topic Negative
 */
class AUPropNonExistActor : AActor
{
	UPROPERTY()
	FNonExistentType X;
}
/** @end */
