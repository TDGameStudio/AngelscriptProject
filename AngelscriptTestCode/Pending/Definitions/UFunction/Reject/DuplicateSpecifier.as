/**
 * @version v1
 * @summary A UFUNCTION specifier may not be repeated. BlueprintCallable listed twice is illegal. This file is the illegal program itself.
 * @topic Definitions
 */
/**
 * @version root
 * @summary A UFUNCTION specifier may not be repeated. BlueprintCallable listed twice is illegal. This file is the illegal program itself.
 * @topic Negative
 */
class AUFuncDupSpecActor : AActor
{
	/**
	 * Illegal UFUNCTION that repeats BlueprintCallable.
	 *
	 * @Kind CompileReject
	 * @Covers UFunction.Specifier
	 * @Inputs UFUNCTION(BlueprintCallable, BlueprintCallable)
	 * @Return does not compile
	 */
	UFUNCTION(BlueprintCallable, BlueprintCallable)
	void Foo()
	{
	}
}
/** @end */
