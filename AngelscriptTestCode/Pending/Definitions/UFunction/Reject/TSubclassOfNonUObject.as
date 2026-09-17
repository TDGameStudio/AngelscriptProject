/**
 * @version v1
 * @summary TSubclassOf may only wrap a UObject-derived class. int is not a UObject, so TSubclassOf<int> is rejected as a UFUNCTION parameter. This file is the illegal program itself.
 * @topic Definitions
 */
/**
 * @version root
 * @summary TSubclassOf may only wrap a UObject-derived class. int is not a UObject, so TSubclassOf<int> is rejected as a UFUNCTION parameter. This file is the illegal program itself.
 * @topic Negative
 */
class AUFuncPNSubNonObjActor : AActor
{
	/**
	 * Illegal UFUNCTION whose TSubclassOf argument is not a UObject class.
	 *
	 * @Kind CompileReject
	 * @Covers UFunction.Parameter
	 * @Inputs TSubclassOf<int> C
	 * @Return does not compile
	 */
	UFUNCTION()
	void Foo(TSubclassOf<int> C)
	{
	}
}
/** @end */
