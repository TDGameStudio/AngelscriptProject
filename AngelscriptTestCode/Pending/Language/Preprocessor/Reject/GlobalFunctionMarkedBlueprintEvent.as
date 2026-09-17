/**
 * @version v1
 * @summary A global UFUNCTION may not be marked BlueprintEvent, since that specifier only applies to functions on a class. Marking one is rejected. This file is the illegal program itself; do not drop the specifier or wrap the.
 * @topic Language
 */
/**
 * @version root
 * @summary A global UFUNCTION may not be marked BlueprintEvent, since that specifier only applies to functions on a class. Marking one is rejected. This file is the illegal program itself; do not drop the specifier or wrap the.
 * @topic Negative
 */
/**
 * The invalidly specified global function. It never runs, since the specifier
 * is rejected first.
 *
 * @Covers Preprocessor.Specifiers
 * @Inputs none
 * @Return 1, never reached
 */
UFUNCTION(BlueprintEvent)
/** */
int BadGlobalEvent()
{
	return 1;
}
/** @end */
