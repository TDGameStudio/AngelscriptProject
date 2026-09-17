/**
 * @version v1
 * @summary A UFUNCTION may only sit inside a preprocessor condition when that condition is EDITOR or a flag declared in configuration. Guarding one with an unknown flag is rejected. This file is the illegal program itself; do not.
 * @topic Language
 */
/**
 * @version root
 * @summary A UFUNCTION may only sit inside a preprocessor condition when that condition is EDITOR or a flag declared in configuration. Guarding one with an unknown flag is rejected. This file is the illegal program itself; do not.
 * @topic Negative
 */
UCLASS()
class UBadFunctionConditionalCarrier : UObject
{
#ifndef UNKNOWN_FLAG
	UFUNCTION()
/** */
	int BadFunction()
	{
		return 1;
	}
#endif
}
/** @end */
