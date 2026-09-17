/**
 * @version v1
 * @summary A UFUNCTION may not take a void parameter. void is a result kind, not a value that can occupy a parameter slot. This file is the illegal program itself.
 * @topic Definitions
 */
/**
 * @version root
 * @summary A UFUNCTION may not take a void parameter. void is a result kind, not a value that can occupy a parameter slot. This file is the illegal program itself.
 * @topic Negative
 */
class AUFuncPNVoidActor : AActor
{
	/**
	 * Illegal UFUNCTION whose parameter type is void.
	 *
	 * @Kind CompileReject
	 * @Covers UFunction.Parameter
	 * @Inputs void Param
	 * @Return does not compile
	 */
	UFUNCTION()
	void Foo(void Param)
	{
	}
}
/** @end */
