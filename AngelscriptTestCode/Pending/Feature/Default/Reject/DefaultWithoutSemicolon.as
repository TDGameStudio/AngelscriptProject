/**
 * @version v1
 * @summary A default statement without a terminating semicolon is rejected. This file is the illegal program itself; do not add the missing semicolon.
 * @topic Feature
 */
/**
 * @version root
 * @summary A default statement without a terminating semicolon is rejected. This file is the illegal program itself; do not add the missing semicolon.
 * @topic Negative
 */
class AAttrNoSemiActor : AActor
{
	UPROPERTY()
	int X = 0;

	default X = 5
}
/** @end */
