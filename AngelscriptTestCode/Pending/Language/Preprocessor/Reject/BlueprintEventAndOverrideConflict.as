/**
 * @version v1
 * @summary A function cannot be both BlueprintEvent and BlueprintOverride, since the two specifiers describe opposite directions of the call. Declaring both is rejected. This file is the illegal program itself; do not drop either.
 * @topic Language
 */
/**
 * @version root
 * @summary A function cannot be both BlueprintEvent and BlueprintOverride, since the two specifiers describe opposite directions of the call. Declaring both is rejected. This file is the illegal program itself; do not drop either.
 * @topic Negative
 */
UCLASS()
class UBadCarrier : UObject
{
	/**
	 * The conflictingly specified method. It never runs, since the specifier
	 * conflict is rejected first.
	 *
	 * @Covers Preprocessor.Specifiers
	 * @Inputs none
	 * @Return 1, never reached
	 */
	UFUNCTION(BlueprintEvent, BlueprintOverride)
/** */
	int Conflict()
	{
		return 1;
	}
}
/** @end */
