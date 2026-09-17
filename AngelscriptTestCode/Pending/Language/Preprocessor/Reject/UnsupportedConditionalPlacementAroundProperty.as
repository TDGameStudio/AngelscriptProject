/**
 * @version v1
 * @summary A UPROPERTY may only sit inside a preprocessor condition when that condition is EDITOR or a flag declared in configuration. Guarding one with an unknown flag is rejected. This file is the illegal program itself; do not.
 * @topic Language
 */
/**
 * @version root
 * @summary A UPROPERTY may only sit inside a preprocessor condition when that condition is EDITOR or a flag declared in configuration. Guarding one with an unknown flag is rejected. This file is the illegal program itself; do not.
 * @topic Negative
 */
UCLASS()
class UBadPropertyConditionalCarrier : UObject
{
	/**
	 * The rejected condition: UNKNOWN_FLAG is neither EDITOR nor a configured
	 * flag, so the property inside is rejected.
	 *
	 * @Covers Preprocessor.Conditionals
	 * @Inputs the macro name UNKNOWN_FLAG
	 * @Return does not preprocess
	 */
#ifndef UNKNOWN_FLAG
	UPROPERTY()
	int BadValue;
#endif
}
/** @end */
