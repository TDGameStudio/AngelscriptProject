/**
 * @version v1
 * @summary An unrecognised UFUNCTION specifier is rejected and named in the diagnostic. This file is the illegal program itself; do not substitute a known specifier, since the unknown one is the point.
 * @topic Language
 */
/**
 * @version root
 * @summary An unrecognised UFUNCTION specifier is rejected and named in the diagnostic. This file is the illegal program itself; do not substitute a known specifier, since the unknown one is the point.
 * @topic Negative
 */
UCLASS()
class UBadCarrier : UObject
{
	/**
	 * The method carrying the unknown specifier. It never runs, since the
	 * specifier is rejected first.
	 *
	 * @Covers Preprocessor.Specifiers
	 * @Inputs none
	 * @Return nothing, never reached
	 */
	UFUNCTION(DefinitelyUnknownSpecifier)
/** */
	void Unknown()
	{
	}
}
/** @end */
