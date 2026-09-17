/**
 * @version v1
 * @summary A function type is not a UPROPERTY type. This file is the illegal program itself; do not replace void() with a value type.
 * @topic Definitions
 */
/**
 * @version root
 * @summary A function type is not a UPROPERTY type. This file is the illegal program itself; do not replace void() with a value type.
 * @topic Negative
 */
class AUPropFuncTypeActor : AActor
{
	UPROPERTY()
	void() Callback;
}
/** @end */
