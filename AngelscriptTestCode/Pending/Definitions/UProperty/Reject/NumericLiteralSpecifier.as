/**
 * @version v1
 * @summary A numeric literal used as a UPROPERTY specifier is rejected. This file is the illegal program itself; do not replace 123 with a named specifier.
 * @topic Definitions
 */
/**
 * @version root
 * @summary A numeric literal used as a UPROPERTY specifier is rejected. This file is the illegal program itself; do not replace 123 with a named specifier.
 * @topic Negative
 */
class AUPropNumSpecActor : AActor
{
	UPROPERTY(123)
	int X = 0;
}
/** @end */
