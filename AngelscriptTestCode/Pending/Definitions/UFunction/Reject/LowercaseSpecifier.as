/**
 * @version v1
 * @summary UFUNCTION specifiers are case-sensitive. blueprintcallable is not the BlueprintCallable specifier, so the declaration is illegal. This file is the illegal program itself.
 * @topic Definitions
 */
/**
 * @version root
 * @summary UFUNCTION specifiers are case-sensitive. blueprintcallable is not the BlueprintCallable specifier, so the declaration is illegal. This file is the illegal program itself.
 * @topic Negative
 */
class AUFuncCaseActor : AActor
{
	/**
	 * Illegal UFUNCTION using a lowercase specifier token.
	 *
	 * @Kind CompileReject
	 * @Covers UFunction.Specifier
	 * @Inputs UFUNCTION(blueprintcallable)
	 * @Return does not compile
	 */
	UFUNCTION(blueprintcallable)
	void Foo()
	{
	}
}
/** @end */
