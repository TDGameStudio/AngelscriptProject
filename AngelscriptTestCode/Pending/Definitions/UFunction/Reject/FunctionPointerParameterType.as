/**
 * @version v1
 * @summary A UFUNCTION may not take a function-pointer parameter. void() is not a reflected UFUNCTION parameter type. This file is the illegal program itself.
 * @topic Definitions
 */
/**
 * @version root
 * @summary A UFUNCTION may not take a function-pointer parameter. void() is not a reflected UFUNCTION parameter type. This file is the illegal program itself.
 * @topic Negative
 */
class AUFuncPNFuncPtrActor : AActor
{
	/**
	 * Illegal UFUNCTION whose parameter type is a function pointer.
	 *
	 * @Kind CompileReject
	 * @Covers UFunction.Parameter
	 * @Inputs void() Callback
	 * @Return does not compile
	 */
	UFUNCTION()
	void Foo(void() Callback)
	{
	}
}
/** @end */
