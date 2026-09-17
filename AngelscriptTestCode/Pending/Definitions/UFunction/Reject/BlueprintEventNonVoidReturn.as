/**
 * @version v1
 * @summary A BlueprintEvent UFUNCTION must return void. GetVal returning int is illegal. This file is the illegal program itself.
 * @topic Definitions
 */
/**
 * @version root
 * @summary A BlueprintEvent UFUNCTION must return void. GetVal returning int is illegal. This file is the illegal program itself.
 * @topic Negative
 */
class AUFuncBPEvNVActor : AActor
{
	/**
	 * Illegal BlueprintEvent that returns int instead of void.
	 *
	 * @Kind CompileReject
	 * @Covers UFunction.Specifier
	 * @Inputs UFUNCTION(BlueprintEvent) int GetVal()
	 * @Return does not compile
	 */
	UFUNCTION(BlueprintEvent)
	int GetVal()
	{
		return 0;
	}
}
/** @end */
