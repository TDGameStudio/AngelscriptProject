/**
 * @version v1
 * @summary A UFUNCTION TArray parameter whose element type does not exist is rejected. FBogus is not a registered type, so TArray<FBogus> cannot be bound. This file is the illegal program itself.
 * @topic Definitions
 */
/**
 * @version root
 * @summary A UFUNCTION TArray parameter whose element type does not exist is rejected. FBogus is not a registered type, so TArray<FBogus> cannot be bound. This file is the illegal program itself.
 * @topic Negative
 */
class AUFuncPNArrBadActor : AActor
{
	/**
	 * Illegal UFUNCTION whose TArray element type is not registered.
	 *
	 * @Kind CompileReject
	 * @Covers UFunction.Parameter
	 * @Inputs TArray<FBogus> Items
	 * @Return does not compile
	 */
	UFUNCTION()
	void Foo(TArray<FBogus> Items)
	{
	}
}
/** @end */
