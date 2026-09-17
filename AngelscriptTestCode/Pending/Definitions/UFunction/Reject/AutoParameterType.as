/**
 * @version v1
 * @summary A UFUNCTION parameter may not be typed auto. UFUNCTION signatures need a concrete reflected type, and auto is not one. This file is the illegal program itself.
 * @topic Definitions
 */
/**
 * @version root
 * @summary A UFUNCTION parameter may not be typed auto. UFUNCTION signatures need a concrete reflected type, and auto is not one. This file is the illegal program itself.
 * @topic Negative
 */
class AUFuncPNAutoActor : AActor
{
	/**
	 * Illegal UFUNCTION whose parameter type is auto.
	 *
	 * @Kind CompileReject
	 * @Covers UFunction.Parameter
	 * @Inputs auto X
	 * @Return does not compile
	 */
	UFUNCTION()
	void Foo(auto X)
	{
	}
}
/** @end */
