/**
 * @version v1
 * @summary A UFUNCTION whose return type does not exist is rejected. FNonExistentType is not a registered script or engine type, so the result cannot be bound. This file is the illegal program itself.
 * @topic Definitions
 */
/**
 * @version root
 * @summary A UFUNCTION whose return type does not exist is rejected. FNonExistentType is not a registered script or engine type, so the result cannot be bound. This file is the illegal program itself.
 * @topic Negative
 */
class AUFuncPNBadRetActor : AActor
{
	/**
	 * Illegal UFUNCTION whose return type is not registered.
	 *
	 * @Kind CompileReject
	 * @Covers UFunction.Return
	 * @Inputs FNonExistentType Foo()
	 * @Return does not compile
	 */
	UFUNCTION()
	FNonExistentType Foo()
	{
	}
}
/** @end */
