/**
 * @version v1
 * @summary BlueprintPure on a non-const void method is rejected. Pure functions need a result, and Mutate() has neither a return value nor const. This file is the illegal program itself.
 * @topic Definitions
 */
/**
 * @version root
 * @summary BlueprintPure on a non-const void method is rejected. Pure functions need a result, and Mutate() has neither a return value nor const. This file is the illegal program itself.
 * @topic Negative
 */
class AUFuncPureNCActr : AActor
{
	/**
	 * Illegal BlueprintPure void mutator with no result.
	 *
	 * @Kind CompileReject
	 * @Covers UFunction.Specifier
	 * @Inputs UFUNCTION(BlueprintPure) void Mutate()
	 * @Return does not compile
	 */
	UFUNCTION(BlueprintPure)
	void Mutate()
	{
	}
}
/** @end */
