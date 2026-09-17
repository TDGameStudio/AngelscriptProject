/**
 * @version v1
 * @summary A UFUNCTION parameter whose type does not exist is rejected. FNonExistentType is not a registered script or engine type, so the declaration cannot be bound. This file is the illegal program itself.
 * @topic Definitions
 */
/**
 * @version root
 * @summary A UFUNCTION parameter whose type does not exist is rejected. FNonExistentType is not a registered script or engine type, so the declaration cannot be bound. This file is the illegal program itself.
 * @topic Negative
 */
class AUFuncPNBadTypeActor : AActor
{
	/**
	 * Illegal UFUNCTION whose parameter type is not registered.
	 *
	 * @Kind CompileReject
	 * @Covers UFunction.Parameter
	 * @Inputs FNonExistentType Param
	 * @Return does not compile
	 */
	UFUNCTION()
	void Foo(FNonExistentType Param)
	{
	}
}
/** @end */
