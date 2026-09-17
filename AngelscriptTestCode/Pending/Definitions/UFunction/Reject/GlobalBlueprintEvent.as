/**
 * @version v1
 * @summary A global UFUNCTION may not be marked BlueprintEvent. Events belong on a UCLASS, not on a free function. This file is the illegal program itself.
 * @topic Definitions
 */
/**
 * @version root
 * @summary A global UFUNCTION may not be marked BlueprintEvent. Events belong on a UCLASS, not on a free function. This file is the illegal program itself.
 * @topic Negative
 */
/**
 * Illegal global BlueprintEvent UFUNCTION.
 *
 * @Kind CompileReject
 * @Covers UFunction.Specifier
 * @Inputs UFUNCTION(BlueprintEvent) int BadGlobalEvent()
 * @Return does not compile
 */
UFUNCTION(BlueprintEvent)
int BadGlobalEvent()
{
	return 1;
}
/** @end */
