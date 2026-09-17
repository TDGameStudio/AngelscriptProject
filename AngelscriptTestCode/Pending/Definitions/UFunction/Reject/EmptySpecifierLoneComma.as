/**
 * @version v1
 * @summary A UFUNCTION specifier list may not be an empty comma. UFUNCTION(,) has no specifier name. This file is the illegal program itself.
 * @topic Definitions
 */
/**
 * @version root
 * @summary A UFUNCTION specifier list may not be an empty comma. UFUNCTION(,) has no specifier name. This file is the illegal program itself.
 * @topic Negative
 */
class AUFuncEmptyCommaActor : AActor
{
	/**
	 * Illegal UFUNCTION whose specifier list is a lone comma.
	 *
	 * @Kind CompileReject
	 * @Covers UFunction.Specifier
	 * @Inputs UFUNCTION(,)
	 * @Return does not compile
	 */
	UFUNCTION(,)
	void Foo()
	{
	}
}
/** @end */
