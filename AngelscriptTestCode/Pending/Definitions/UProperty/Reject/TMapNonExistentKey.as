/**
 * @version v1
 * @summary A TMap UPROPERTY whose key type does not exist is rejected. This file is the illegal program itself; do not declare FNonExistent.
 * @topic Definitions
 */
/**
 * @version root
 * @summary A TMap UPROPERTY whose key type does not exist is rejected. This file is the illegal program itself; do not declare FNonExistent.
 * @topic Negative
 */
class AUPropMapBadKeyActor : AActor
{
	UPROPERTY()
	TMap<FNonExistent, int> BadMap;
}
/** @end */
