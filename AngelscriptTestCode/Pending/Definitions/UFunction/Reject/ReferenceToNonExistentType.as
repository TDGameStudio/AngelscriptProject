/**
 * @version v1
 * @summary A UFUNCTION reference parameter whose pointee type does not exist is rejected. FNonExistent is not a registered type, so the &in slot cannot be bound. This file is the illegal program itself.
 * @topic Definitions
 */
/**
 * @version root
 * @summary A UFUNCTION reference parameter whose pointee type does not exist is rejected. FNonExistent is not a registered type, so the &in slot cannot be bound. This file is the illegal program itself.
 * @topic Negative
 */
class AUFuncPNRefBadActor : AActor
{
	/**
	 * Illegal UFUNCTION whose reference parameter type is not registered.
	 *
	 * @Kind CompileReject
	 * @Covers UFunction.Parameter
	 * @Inputs FNonExistent&in Ref
	 * @Return does not compile
	 */
	UFUNCTION()
	void Foo(FNonExistent&in Ref)
	{
	}
}
/** @end */
