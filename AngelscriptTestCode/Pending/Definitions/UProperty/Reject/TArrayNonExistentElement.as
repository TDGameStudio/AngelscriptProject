/**
 * @version v1
 * @summary A TArray UPROPERTY whose element type does not exist is rejected. This file is the illegal program itself; do not declare FNonExistent.
 * @topic Definitions
 */
/**
 * @version root
 * @summary A TArray UPROPERTY whose element type does not exist is rejected. This file is the illegal program itself; do not declare FNonExistent.
 * @topic Negative
 */
class AUPropArrBadActor : AActor
{
	UPROPERTY()
	TArray<FNonExistent> Items;
}
/** @end */
