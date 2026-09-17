/**
 * @version v1
 * @summary Trailing tokens after a UPROPERTY() macro are rejected. This file is the illegal program itself; do not remove the garbage token.
 * @topic Definitions
 */
/**
 * @version root
 * @summary Trailing tokens after a UPROPERTY() macro are rejected. This file is the illegal program itself; do not remove the garbage token.
 * @topic Negative
 */
class AUPropGarbageActor : AActor
{
	UPROPERTY() garbage int X = 0;
}
/** @end */
